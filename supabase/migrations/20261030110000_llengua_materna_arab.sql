-- Llengua materna: s'afig l'àrab ('ar') a les triables amb traducció (ajuda del tutor i subtítols
-- del Nivell 0). L'àrab s'escriu de dreta a esquerra: el frontend posa dir="rtl" a les traduccions.
-- Qui tenia 'other' perquè era àrab (20261005185000) l'haurà de triar de nou en el perfil.
-- També les traduccions àrabs dels escenaris del Nivell 0 (resources.metadata.translations.ar).
-- Tornar a aplicar el fitxer no canvia res.

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_mother_tongue_check,
  ADD CONSTRAINT profiles_mother_tongue_check
    CHECK (mother_tongue IS NULL OR mother_tongue IN ('es', 'en', 'fr', 'it', 'ro', 'uk', 'ar', 'ca', 'other'));

-- Igual que en 20261013100000, amb 'ar' entre les llengües triables.
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  initial_level text;
  tongue text;
  group_of_age text;
begin
  group_of_age := case new.raw_user_meta_data ->> 'age_group' when 'child' then 'child' else 'adult' end;

  -- Els xiquets sempre comencen en el Nivell 0; els adults trien el seu nivell (el Nivell 0 o un del MECR).
  initial_level := case
    when group_of_age = 'child' then 'nivell0'
    when new.raw_user_meta_data ->> 'level' in ('nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2') then new.raw_user_meta_data ->> 'level'
    else 'A2'
  end;

  -- Llengua materna: només al Nivell 0 (xiquets i adults); als altres nivells no es guarda.
  if initial_level = 'nivell0' then
    tongue := lower(coalesce(new.raw_user_meta_data ->> 'mother_tongue', ''));
    if tongue = '' then
      tongue := null;
    elsif tongue not in ('es', 'en', 'fr', 'it', 'ro', 'uk', 'ar', 'ca', 'other') then
      tongue := 'other';
    end if;
  else
    tongue := null;
  end if;

  insert into public.profiles (id, display_name, level, mother_tongue, age_group)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    initial_level,
    tongue,
    group_of_age
  )
  on conflict (id) do nothing;

  return new;
end;
$function$;

-- Traduccions àrabs dels escenaris del Nivell 0 (resum, primera frase del personatge i objectius).
UPDATE public.resources AS r
SET metadata = jsonb_set(r.metadata, '{translations,ar}', t.ar)
FROM (VALUES
  ('n0_pocio', $json$
  {
    "content": "الساحر ميرلي يحضّر جرعة سحرية في مختبره، ويحتاج إلى مساعدتك لاختيار المكوّنات.",
    "initial_prompt": "مرحبًا يا صديقي! أنا ميرلي، الساحر. أحضّر جرعة سحرية، لكن تنقصني بعض المكوّنات. هل تساعدني؟",
    "objectius": [
      "إلقاء التحية.",
      "قول الألوان وأشياء الجرعة (أخضر، أحمر، قِدر، نجمة، بيضة...).",
      "عدّ المكوّنات حتى خمسة.",
      "قول ما يعجبه وما لا يعجبه في الجرعة.",
      "إعطاء اسم للجرعة."
    ]
  }
  $json$::jsonb),
  ('n0_zoo', $json$
  {
    "content": "كارمي، حارسة حديقة الحيوانات، عليها أن تطعم الحيوانات وتحتاج إلى مساعدتك.",
    "initial_prompt": "مرحبًا يا صديقي! أنا كارمي، حارسة حديقة الحيوانات. اليوم عندنا عمل كثير: الحيوانات جائعة. هل تساعدني؟",
    "objectius": [
      "إلقاء التحية.",
      "قول أسماء الحيوانات (أسد، فيل، قرد، زرافة، بطريق...).",
      "قول ألوان الحيوانات وهل هي كبيرة أم صغيرة.",
      "عدّ الحيوانات حتى خمسة.",
      "قول أيّ حيوان يحبه أكثر وماذا يأكل."
    ]
  }
  $json$::jsonb),
  ('n0_pati', $json$
  {
    "content": "إنه وقت الاستراحة، ولايا، بنت من صفّك، تريد أن تفعل شيئًا. ساعدها على الاختيار!",
    "initial_prompt": "مرحبًا! أنا لايا، من صفّك. حان وقت الاستراحة! ماذا تريد أن تفعل؟",
    "objectius": [
      "إلقاء التحية.",
      "قول ماذا يريد أن يفعل في الاستراحة (يأكل وجبته، يلعب كرة القدم، يقفز بالحبل...).",
      "قول ماذا عندك لتأكل (شطيرة، فاكهة، عصير...).",
      "قول أيّ لعبة يحب أن يلعبها أكثر."
    ]
  }
  $json$::jsonb),
  ('n0_biblioteca', $json$
  {
    "content": "باو، أمين المكتبة، ينتظرك في المكتبة ليساعدك على اختيار كتاب.",
    "initial_prompt": "مرحبًا يا صديقي! أنا باو، أمين المكتبة. هذه هي المكتبة: فيها كتب كثيرة. أيّ كتاب تريد أن تقرأ؟",
    "objectius": [
      "إلقاء التحية.",
      "قول أيّ نوع من الكتب يريد (قصص، حيوانات، رسوم...).",
      "قول ماذا يرى في الكتاب (حيوانات، ألوان، أشياء...).",
      "طلب الكتاب بقول «من فضلك» وقول «شكرًا».",
      "قول هل يحب القراءة."
    ]
  }
  $json$::jsonb),
  ('n0_ajuntament', $json$
  {
    "content": "تذهب إلى البلدية، وروزا، الموظفة، تساعدك. تتكلم ببطء وبجمل قصيرة جدًا.",
    "initial_prompt": "صباح الخير! أنا روزا. هذه هي البلدية. هل تقول لي ما اسمك؟",
    "objectius": [
      "إلقاء التحية: «Bon dia».",
      "قول اسمك: «Em diuen...».",
      "قول من أيّ بلد أنت: «Soc de...».",
      "طلب ورقة أو موعد: «Vull un paper, per favor».",
      "الشكر والوداع: «Gràcies. Adéu»."
    ]
  }
  $json$::jsonb),
  ('n0_taller', $json$
  {
    "content": "عندك مشكلة في السيارة وتذهب إلى الورشة. طوني، الميكانيكي، يساعدك. يتكلم ببطء وبجمل قصيرة جدًا.",
    "initial_prompt": "صباح الخير! أنا طوني. هذه هي الورشة. ما مشكلة السيارة؟",
    "objectius": [
      "إلقاء التحية: «Bon dia».",
      "قول أيّ سيارة عندك وما لونها: «Tinc un cotxe blanc».",
      "قول ما مشكلة السيارة: «No funciona» أو «Fa soroll».",
      "قول في أيّ يوم تريدها: «Dimarts, per favor».",
      "الشكر والوداع: «Gràcies. Adéu»."
    ]
  }
  $json$::jsonb),
  ('n0_fruiteria', $json$
  {
    "content": "تذهب إلى محل الفواكه لتشتري فاكهة. جوزيب، بائع الفواكه، يساعدك. يتكلم ببطء وبجمل قصيرة جدًا.",
    "initial_prompt": "صباح الخير! أنا جوزيب. هذا محل الفواكه. ماذا تريد؟",
    "objectius": [
      "إلقاء التحية: «Bon dia».",
      "طلب فاكهة: «Vull una poma».",
      "قول كم تريد منها: «Dues, per favor».",
      "السؤال عن السعر: «Quant és?».",
      "الشكر والوداع: «Gràcies. Adéu»."
    ]
  }
  $json$::jsonb)
) AS t(type, ar)
WHERE r.category = 'escenari' AND r.type = t.type AND r.metadata ? 'translations';
