"""Filtro de moderación para el chatbot de valenciano: modelo (binP; binM sigue disponible) + lista de palabras + reglas de contenido sexual.

Orden de decisión (se evalúan todas; cada una que salte queda registrada como motivo y basta una para bloquear):
  1. reglas de contenido sexual / petición de fotos o contacto íntimo   -> 'sexual'
  2. insultos fuertes (lista)                                           -> 'insult_llista'
  3. vulgaridad (lista), SOLO en modo infantil                          -> 'vulgar_llista'
  4. modelo -> 'model': P(mensaje entero) > UMBRAL[modo]  O  P(alguna frase) > LLINDAR_FRASE[modo]
     (UMBRAL: 0.5 adulto / 0.3 infantil; LLINDAR_FRASE: 0.97 adulto / 0.9 infantil; si el mensaje está casi todo en
      MAYÚSCULAS se pasa a minúsculas antes de puntuarlo)
Excepción: si el mensaje es una pregunta sobre vocabulario ("què vol dir 'collons'?") y no insulta a quien escribe
ni al bot, las listas (2 y 3) no se aplican; las reglas sexuales y el modelo siguen activos.
"""
import re
import unicodedata

UMBRAL = {"adult": 0.5, "infantil": 0.3}
# Umbral que debe superar UNA FRASE (además del mensaje entero). Elegidos con la mitad de VALIDACIÓN de mensajes largos
# legítimos de WildChat (falsos positivos: 2,3 % con 0,97; 3,8 % con 0,9): adulto prioriza no molestar, infantil detectar.
LLINDAR_FRASE = {"adult": 0.97, "infantil": 0.9}
# UMBRAL y LLINDAR_FRASE se definieron sobre las probabilidades «de laya», con su temperatura tope T_LAYA = 5.
# Con calibración (calibracio_binM.json: temperatura ajustada en una validación limpia, ~7), las probabilidades cambian de escala y los umbrales
# se convierten (sigmoide(logit(p) * T_LAYA / T)) para que CADA decisión sea idéntica; solo cambian el valor de `p_model` y su significado.
T_LAYA = 5.0


def conv_umbral(p, T):
    """Convierte un umbral definido con la temperatura T_LAYA a la escala de una temperatura T."""
    import math
    if not T or abs(T - T_LAYA) < 1e-9:
        return p
    return 1.0 / (1.0 + math.exp(-math.log(p / (1.0 - p)) * T_LAYA / T))


def _temperatura_calibrada(ruta):
    import json
    import os
    try:
        datos = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "calibracio_binM.json"), encoding="utf-8"))
        return {os.path.normpath(k): v["T_ajustada"] for k, v in datos.items()}.get(os.path.normpath(ruta))
    except (OSError, ValueError, KeyError):
        return None


def _temperaturas_binP(ruta):
    """(T_nucli, T_vulgar) ajustadas para un modelo de dos preguntas (calibracio_binP.json), o None. Solo sirven para informar
    probabilidades calibradas: las decisiones se siguen tomando con los umbrales definidos para T = 5."""
    import json
    import os
    try:
        datos = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "calibracio_binP.json"), encoding="utf-8"))
        v = {os.path.normpath(k): v for k, v in datos.items()}[os.path.normpath(ruta)]
        return v["T_nucli"], v["T_vulgar"]
    except (OSError, ValueError, KeyError):
        return None


def _calibra(p, T):
    import math
    p = min(max(p, 1e-9), 1 - 1e-9)
    return 1.0 / (1.0 + math.exp(-math.log(p / (1.0 - p)) * T_LAYA / T))


# ---------------------------------------------------------------- normalización
def _sin_acentos(s):
    """Quita los acentos pero CONSERVA la ñ (si no, «coño» se confunde con «cono», la figura geométrica)."""
    out = []
    for c in unicodedata.normalize("NFD", s):
        if unicodedata.category(c) == "Mn":
            if c == "̃" and out and out[-1] == "n":      # la tilde de la ñ
                out[-1] = "ñ"
            continue
        out.append(c)
    return "".join(out)


_LEET = str.maketrans({"1": "i", "0": "o", "3": "e", "4": "a", "@": "a", "7": "t", "$": "s", "5": "s"})


def normaliza(texto):
    """minúsculas, sin acentos, desfaz grafías disfrazadas (c4br0n, p*ta, g.i.l.i.p.o.l.l.a.s) y letras repetidas."""
    s = _sin_acentos(texto.lower())
    s = re.sub(r"\b(?:\w\.){3,}\w\b", lambda m: m.group(0).replace(".", ""), s)       # g.i.l.i...
    s = re.sub(r"(?<=[a-z])[\*\-_](?=[a-z])", "*", s)                                  # p*ta, c-a-b-r-o-n
    toks = []
    for t in s.split():
        if re.search(r"[a-z]", t) and re.search(r"[0-9@$]", t):                        # token mixto letra+símbolo
            t = t.translate(_LEET)
        toks.append(t)
    s = " ".join(toks)
    s = re.sub(r"(.)\1{2,}", r"\1\1", s)                                               # cabrooon -> cabroon
    return s


BASES = ["puta", "putes", "puto", "merda", "collons", "hostia", "gilipolles", "capullo", "cabron", "malparit",
         "imbecil", "idiota", "subnormal", "maricon", "mamon", "carallot", "cretin", "estupid", "cabro", "cony", "joder"]


def desfa_comodins(norm):
    """'p*ta' -> 'puta' si algún término de la lista encaja con la '*' como una sola letra."""
    out = []
    for t in norm.split():
        if "*" in t:
            rx = re.compile(re.escape(t).replace(r"\*", r"[a-z]") + r"$")
            for w in BASES:
                if rx.match(w):
                    t = w
                    break
        out.append(t)
    return " ".join(out)


# ---------------------------------------------------------------- listas
INSULTS_FORTS = [
    r"fills? de puta", r"fill d' ?una gran puta", r"hij[oa]s? de puta", r"gilipoll\w*", r"capull\w*", r"cabrons?", r"cabro",
    r"malparits?", r"mamon\w*", r"imbecil\w*", r"idiot\w*", r"subnormal\w*", r"retrassat\w*", r"retrasad\w*",
    r"maricon\w*", r"marica", r"sudaca\w*", r"carallot\w*", r"cretins?", r"estupid\w*", r"asquer\w+",
    r"escoria", r"mongol[oa]s?(?<!mongols)", r"mongolic\w*", r"tros d'? ?ase", r"feminazi\w*",
    r"cabron\w*",
]
VULGARS = [
    r"collons?", r"hostia\w*", r"merda\w*", r"mecag\w+", r"joder", r"jod[io]\w*", r"carall\w*", r"cony",
    r"put[ao]s?", r"cagad\w+", r"co?ño",      # «coño» con ñ; «cono» sin ñ es la figura geométrica y NO se marca
    # ampliación (octubre 2026, a partir de los avisos del validador): formas castellanas y valencianas que faltaban
    r"mierd\w*", r"cojones", r"co?ñazos?", r"foll(?:ar|a|ando|ado)", r"puñet\w+", r"fotut\w*", r"fotud\w*", r"fodut\w*", r"fodud\w*", r"co?ña", r"conyas?", r"hostias", r"pollas?",
    r"me cago", r"em cag(?:ue|ue?\w*)", r"ens cag\w+", r"cag(?:o|ue) en (?:tot|todo|dios|deu)",
]
RE_FORTS = re.compile(r"\b(?:" + "|".join(INSULTS_FORTS) + r")\b")
RE_VULGAR = re.compile(r"\b(?:" + "|".join(VULGARS) + r")\b")

# preguntas sobre vocabulario (excepción de mención)
RE_CONSULTA = re.compile(
    r"vol dir|volen dir|significa|signifi|com es diu|com es diuen|com se diu|tradu(?:c|e|ir)|origen|etimolog|sinonim|"
    r"registre|paraula|vocabulari|expressio|insult|diccionari|equivalent|diferencia entre|en la frase|a la frase|"
    r"he sentit|he llegit|em va dir|m'ha dit|aquesta frase|corregeix|explica|explicar|quines son les|es correcte|"
    r"per que es considera|puc dir|hauria de dir|dir-li|apropiad|adequat|educad|suau|malsonant|grollera")

def es_consulta(norm):
    return bool(RE_CONSULTA.search(norm))


# fragmentos entre comillas: "x", «x», 'x' (la comilla simple solo si abre tras espacio y cierra antes de espacio o puntuación,
# para no confundirla con el apóstrofo: l'escola, d'una)
RE_CITAT = re.compile(r"\"([^\"]{1,40})\"|«([^»]{1,40})»|(?:^|(?<=\s))'([^']{1,40}?)'(?=\s|$|[?.!,;:])")


# consulta léxica estricta (solo para las reglas sexuales): preguntar por una palabra, no hablar de ella en general
RE_CONSULTA_LEXICA = re.compile(r"vol dir|volen dir|significa|com es diu|com es diuen|com se diu|tradu(?:c|e|ir)|sinonim|"
                                r"\ba dir\b|en valencia|en castella|com s'escriu|com es pronuncia")


def _sense_mencions(norm):
    """Quita los fragmentos citados CORTOS (una palabra o expresión) cuando el mensaje es una consulta léxica."""
    if not RE_CONSULTA_LEXICA.search(norm):
        return norm
    return RE_CITAT.sub(lambda c: " " if len(c.group(0)) <= 22 else c.group(0), norm)


def _dins_de_cometes(norm, m):
    return any(c.start() <= m.start() and m.end() <= c.end() for c in RE_CITAT.finditer(norm))


# marcas léxicas que preceden a la palabra por la que se pregunta (sin comillas): 'què vol dir idiota', 'la paraula X'
RE_MARCA_LEXICA = re.compile(r"(?:vol dir|volen dir|significa|es diu|es diuen|se diu|paraula|insult|sinonim de|equival a|"
                             r"tradueixes?|traduir|diferencia entre|es considera|origen de)\b[^.?!,;]{0,25}$")


def _es_mencio_lexica(norm, m):
    previo = norm[max(0, m.start() - 40):m.start()]
    return bool(RE_MARCA_LEXICA.search(previo)) and not _insulta_a_algu(norm, m)


def _insulta_a_algu(norm, m):
    """¿La palabra marcada se usa contra alguien (ets un X / calla X / X de merda)?"""
    ini = max(0, m.start() - 30)
    previo = norm[ini:m.start()]
    # vocativo: 'explica'm això, imbècil' (la palabra va tras una coma, a lo sumo con 1-2 palabras en medio)
    vocatiu = bool(re.search(r"[,;:]\s*(?:\w+\s+){0,2}$", previo))
    return bool(re.search(r"\b(?:ets|eres|tu ets|calla|callate|ves-te'?n|vete|vaja|quin|quina|tan)\b[^.?!]{0,28}$", previo)) \
        or vocatiu \
        or bool(re.search(r"^\s*(?:de merda|que ets|i un|i una)", norm[m.end():m.end() + 14]))


# ---------------------------------------------------------------- reglas sexuales
# (los apóstrofos y guiones son habituales: envia'm, ensenya'm, mostra-me)
_VERB_PETICIO = r"\b(?:envia|passa|ensenya|mostra|deixa)(?:[-']?m[ea]?)?\b|\bem deixes veure\b|\bvull veure\b|\bvols ensenyar\b"
_PART_COS = r"\b(?:cos nu|despullat\w*|despullada|sense roba|roba interior|en pilotes|intim\w*|els pits|les tetes|tetes|el cul|cul|genitals|polla|penis|vagina|el teu cos|teu cos)\b"
SEXUAL = [
    # petición de fotos / de ver el cuerpo
    re.compile(r"(?:" + _VERB_PETICIO + r").{0,40}" + _PART_COS),
    re.compile(r"\bfot[oa]s?\b.{0,35}(?:sense roba|despullat\w*|intim\w*|roba interior|en pilotes|nu\b|nua\b)"),
    re.compile(r"(?:\bdespulla-?'?t\b|\bdesvesteix-?te\b|\btreu-?te la roba\b|\btreu-?te la samarreta\b|\bet trau la samarreta\b)"),
    # actos / conversaciones sexuales dirigidas al usuario o al bot
    re.compile(r"(?:fer sexe|fer l'amor|tindre sexe|tenir sexe|\bfollar\b|\bfollem\b|fem l'amor|fem sexe|sexe amb mi|parlem de sexe|parla[-']?m de sexe|parlar de sexe amb)"),
    re.compile(r"(?:coses guarres|paraules calentes|coses sexuals|em calentes|calentet|calentona|sexi\b|sexy\b)"),
    re.compile(r"(?:vull tocar-?te|et toque\b|et bese el coll|besar-?te el coll|tocar el teu|tocar-te el)"),
    re.compile(r"\b(?:descriu|explica|conta)[-']?m[ea]\b.{0,45}(?:cos nu|fer l'amor|\bsexe\b|despullat\w*|nit amb tu)"),
    # grooming: secretismo + contenido corporal/foto
    re.compile(r"(?:no (?:ho )?(?:digues|diguis|li ho digues)|que no ho sapiga ningu|es un secret|en secret).{0,50}(?:fot[oa]|cos|despull\w*|roba|toc)"),
    re.compile(r"(?:fot[oa]|cos|despull\w*|roba).{0,50}(?:no (?:ho )?(?:digues|diguis)|que no ho sapiga ningu|en secret)"),
    # menor + proposición
    re.compile(r"(?:tinc|tens) \d{1,2} anys?.{0,40}(?:sexe|despull\w*|guarr\w*|nu\b|nua\b|tocar)"),
]
# exclusiones: educación sexual / salud / gramática
RE_SEXUAL_EDU = re.compile(r"educacio sexual|salut sexual|sexe biologic|sexe (?:masculi|femeni)|genere gramatical|"
                           r"sexe dels|sexe del bebe")


def regla_sexual(norm):
    if RE_SEXUAL_EDU.search(norm):
        return None
    for i, r in enumerate(SEXUAL):
        if r.search(norm):
            return f"regla{i + 1}"
    return None


# ---------------------------------------------------------------- preparación del texto para el modelo
_SPLIT_FRASES = re.compile(r"(?<=[.!?…])\s+|\n+")


def frases_model(texto):
    """Trocea en frases (las de menos de 3 caracteres se ignoran); si no queda ninguna, el texto entero."""
    fs = [x.strip() for x in _SPLIT_FRASES.split(texto) if len(x.strip()) >= 3]
    return fs or [texto]


def _crida(texto):
    """¿El mensaje está (casi) todo en MAYÚSCULAS? Entonces se pasa a minúsculas antes de puntuarlo."""
    lletres = [c for c in texto if c.isalpha()]
    return len(lletres) >= 4 and sum(c.isupper() for c in lletres) / len(lletres) > 0.7


# ---------------------------------------------------------------- filtro
class Filtre:
    def __init__(self, puntuador=None, ruta_model="./laya-binP", per_frases=True, minuscules_si_crida=True,
                 llindar_frase=None, calibrar=True):
        """puntuador: callable(texto)->P(tòxic); si es None, carga laya con ruta_model.
        per_frases: además del mensaje entero, puntúa cada frase por separado. Una frase solo cuenta si supera
            `llindar_frase` (alto a propósito: con el mismo umbral que el mensaje entero, los falsos positivos en textos
            largos se multiplican; medido en SocialTOX: 8 % -> 21 % con frase > 0.5, 8 % -> 12 % con frase > 0.97).
        minuscules_si_crida: si el mensaje está casi todo en mayúsculas, lo pasa a minúsculas antes de puntuarlo."""
        self.T = None                                   # temperatura de calibración aplicada (None = la de laya)
        self.dos = False                                # modelo con dos preguntas (Nucli, Vulgar), p. ej. binP
        self.T_dos = None                               # (T_nucli, T_vulgar) para informar probabilidades calibradas de binP
        self._ult = None                                # probabilidades crudas del último mensaje entero
        if puntuador is None:
            import json
            import os
            import laya
            agent = laya.load(ruta_model)
            ruta_q = os.path.join(ruta_model, "questions.json")
            qs = json.load(open(ruta_q, encoding="utf-8")) if os.path.exists(ruta_q) else None
            self.dos = bool(qs) and "Nucli" in qs and "Vulgar" in qs
            if self.dos:
                calibrar = False                        # binP: las decisiones usan la escala de laya (T = 5); la calibración solo informa
                self.T_dos = _temperaturas_binP(ruta_model)
            if calibrar:
                self.T = _temperatura_calibrada(ruta_model)
                if self.T:
                    agent.temperature[2] = self.T       # laya limita la temperatura a [0.5, 5] solo AL CARGAR; aquí se fija la ajustada
            q = {"Es_toxic": {"type": "noul",
                              "instructions": "El missatge conté insults, atacs, amenaces, odi o llenguatge vulgar?"}}
            if self.dos:
                # binP: (P(Nucli), P(Vulgar)) por texto; adulto bloquea por Nucli, infantil por el máximo de las dos
                self.puntua_lot = lambda ts: [(r["answers"]["Nucli"]["noul"], r["answers"]["Vulgar"]["noul"])
                                              for r in agent.predict_batch(ts, qs)]
                puntuador = lambda t: self.puntua_lot([t])[0]
            else:
                puntuador = lambda t: agent.predict(t, q)["answers"]["Es_toxic"]["noul"]
                # varias frases en una sola pasada (verificado: mismas probabilidades que de una en una, dif. < 0.001)
                self.puntua_lot = lambda ts: [r["answers"]["Es_toxic"]["noul"] for r in agent.predict_batch(ts, q)]
        else:
            self.puntua_lot = None
        self.puntua = puntuador
        self.per_frases = per_frases
        self.minuscules_si_crida = minuscules_si_crida
        # llindar_frase: un número (igual para los dos modos) o {"adult": x, "infantil": y}. Por defecto LLINDAR_FRASE.
        self.umbral = {m: conv_umbral(u, self.T) for m, u in UMBRAL.items()}
        if llindar_frase is None:
            llindar_frase = {m: conv_umbral(u, self.T) for m, u in LLINDAR_FRASE.items()}
        self.llindar_frase = dict(llindar_frase) if isinstance(llindar_frase, dict) else {m: llindar_frase for m in UMBRAL}
        assert set(self.llindar_frase) == set(UMBRAL), "llindar_frase debe cubrir los modos " + str(list(UMBRAL))

    def _pm(self, p, mode):
        """Con modelo de dos preguntas, p es (nucli, vulgar): adulto usa nucli; infantil, el máximo."""
        if not self.dos:
            return p
        return p[0] if mode == "adult" else max(p)

    def p_model(self, texto, mode="adult"):
        """Puntuación efectiva: max(mensaje entero, frase más alta SI supera llindar_frase[mode]). Así, bloquear con
        p_model > umbral equivale a: entero > umbral  O  alguna frase > llindar_frase[mode]."""
        t = texto.lower() if (self.minuscules_si_crida and _crida(texto)) else texto
        fs = frases_model(t) if self.per_frases else [t]
        if len(fs) <= 1:
            self._ult = self.puntua(t)
            return self._pm(self._ult, mode)
        if self.puntua_lot is not None:
            crudas = self.puntua_lot([t] + fs)                        # una sola pasada: entero + frases
            self._ult = crudas[0]
            p_ent, *p_fr = [self._pm(x, mode) for x in crudas]
        else:
            self._ult = self.puntua(t)
            p_ent, p_fr = self._pm(self._ult, mode), [self._pm(self.puntua(f), mode) for f in fs]
        pf = max(p_fr)
        return max(p_ent, pf if pf > self.llindar_frase[mode] else 0.0)

    def comprova(self, texto, mode="adult"):
        assert mode in UMBRAL
        n = normaliza(texto)
        motius = []
        # en una consulta de vocabulario, lo que va entre comillas es una mención ('dir "despullat"'), no una petición
        r = regla_sexual(_sense_mencions(n))
        if r:
            motius.append(("sexual", r))
        consulta = es_consulta(n)
        for nom, rx, actiu in (("insult_llista", RE_FORTS, True), ("vulgar_llista", RE_VULGAR, mode == "infantil")):
            if not actiu:
                continue
            for m in rx.finditer(desfa_comodins(n)):
                if consulta and (_dins_de_cometes(n, m) or _es_mencio_lexica(n, m)):
                    continue                     # pregunta sobre vocabulario: palabra citada o tras una marca léxica
                motius.append((nom, m.group(0)))
                break
        p = self.p_model(texto, mode)
        if p > self.umbral[mode]:
            motius.append(("model", round(p, 2)))
        res = {"bloquejat": bool(motius), "motius": motius, "p_model": p}
        if self.dos and self.T_dos and self._ult is not None:
            res["p_calibrada"] = {"nucli": round(_calibra(self._ult[0], self.T_dos[0]), 3), "vulgar": round(_calibra(self._ult[1], self.T_dos[1]), 3)}
        return res
