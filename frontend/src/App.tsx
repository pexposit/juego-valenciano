import { useEffect, useRef, useState } from 'react';
import { CHAT_CATEGORIES, hasAiPath, hasStudyPaths, isKidsLevel0, isTranslatedTongue } from '@parlaval/shared';
import type { User } from '@supabase/supabase-js';
import { Navigate, Route, Routes, useLocation, useNavigate, useParams } from 'react-router-dom';
import { ScenarioSelect } from './components/ScenarioSelect';
import { SceneLoading, useDashboardAssets, useSceneAssets } from './components/SceneLoading';
import { PageTransition } from './components/ui';
import { supabase } from './lib/supabase';
import { changeLevel, endSession, fetchExam, fetchPractice, fetchResources, finishAbandonedResources, forgetSession, invalidateResources, retranslateTutorConversation } from './lib/api';
import type { Exam as ExamResource, Practice as PracticeResource, Resource } from './lib/types';
import { activityRoute, AI_PATH_ROUTE, DEFAULT_PROFILE, isKidsScenario, KIDS_ROUTES, ROUTES, type Page } from './data/content';
import { HomePage } from './pages/HomePage';
import { AuthPage } from './pages/AuthPage';
import { Dashboard } from './pages/Dashboard';
import { KidsProgress } from './pages/KidsProgress';
import { TeacherClasses } from './pages/TeacherClasses';
import { LearningPath } from './pages/LearningPath';
import { StudyPaths } from './pages/StudyPaths';
import { MyClasses } from './pages/MyClasses';
import { Chat } from './pages/Chat';
import { Exam } from './pages/Exam';
import { Practice } from './pages/Practice';
import { clearLegacyProgress, setProgressUser } from './lib/progressStorage';
import { ErrorPractice } from './pages/ErrorPractice';
import { TutorHistory } from './pages/TutorHistory';
import { Lessons } from './pages/Lessons';
import { Summary } from './pages/Summary';
import { Profile } from './pages/Profile';
import { PlacementTest } from './pages/PlacementTest';
import { KidsAlbum } from './features/kids/KidsAlbum';
import { KidsHome } from './features/kids/KidsHome';
import { KidsIsland } from './features/kids/KidsIsland';
import { KidsLesson } from './features/kids/KidsLessons';
import { InstitutionalBar } from './components/InstitutionalLogos';
import { clearRouteContext, routeBackTo } from './features/paths/routeContext';
import { installAudioTracking, stopAllAudio } from './lib/audioControl';
import { stopVoice } from './features/kids/sound';
import { KidsTranslationProvider, useKidsTranslationLang } from './features/kids/translations';
import { KidsLessons } from './pages/KidsLessons';

type ProfileFields = { display_name?: string; level?: string; show_mother_tongue?: boolean; mother_tongue?: string };

// Busca al catàleg de la BDD el recurs que obri una ruta.
// undefined = carregant; null = no existix o no és jugable.
function useCatalogResource(match: (resource: Resource) => boolean, key: string | undefined) {
  const [resource, setResource] = useState<Resource | null>();

  useEffect(() => {
    let cancelled = false;
    fetchResources()
      .then(resources => {
        if (!cancelled) setResource(resources.find(r => r.playable && match(r)) ?? null);
      })
      .catch(error => {
        console.error("Error carregant l'activitat:", error);
        if (!cancelled) setResource(null);
      });
    return () => { cancelled = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key]);

  return resource;
}

// Llig l'escenari de la URL (/xat/:scenario) i el busca al catàleg de la BDD;
// si no existix o no és jugable (enllaç trencat, escrit a mà...), torna a la selecció.
function ChatRoute({
  level, kids, xp, onXpGained, onBack,
}: { level: string; kids: boolean; xp: number; onXpGained: (delta: number) => void; onBack: () => void }) {
  const { scenario } = useParams<{ scenario: string }>();
  const navigate = useNavigate();
  const section = useCatalogResource(r => CHAT_CATEGORIES.includes(r.category) && r.type === scenario, scenario);
  // Pantalla de càrrega fins que hi ha la fila, el fons i el robot: el xat no es munta
  // abans perquè en muntar-se ja sona la salutació del personatge.
  const ready = useSceneAssets(scenario, section);
  // Subtítols en la llengua materna (Nivell 0) si el perfil els té activats i l'escenari els porta.
  const lang = useKidsTranslationLang();
  const translation = level === 'nivell0' && lang ? section?.translations?.[lang] ?? null : null;

  if (!scenario || section === null) return <Navigate to={ROUTES.scenarioselect} replace />;
  // Els escenaris infantils només els fan els xiquets (per l'enllaç directe tampoc).
  if (section && isKidsScenario(section) && !kids) return <Navigate to={ROUTES.dashboard} replace />;
  // I els de persones adultes del Nivell 0, els xiquets no els fan.
  if (section && section.difficulty === 'nivell0' && section.audience === 'adult' && kids) return <Navigate to={KIDS_ROUTES.home} replace />;
  if (section === undefined || !ready) return <SceneLoading />;
  // Obert des d'una ruta, tornar du a la ruta (amb els seus exercicis), no a l'activitat anterior.
  const back = () => { const to = routeBackTo(section.id); if (to) navigate(to); else onBack(); };
  return (
    <PageTransition>
      <Chat
        key={scenario}
        scenario={scenario}
        category={section.category}
        title={section.section_name ?? section.name}
        voice={section.voice}
        background={section.background}
        initialPrompt={section.initial_prompt}
        greetingAudio={section.greeting_audio}
        actor={section.character}
        summary={section.content}
        objectives={section.objectius ?? []}
        translation={translation}
        level={level}
        xp={xp}
        onXpGained={onXpGained}
        onEnd={back}
        onBack={back}
      />
    </PageTransition>
  );
}

// Tauler: no es mostra fins que hi ha el perfil i els recursos (fons, bombolla, robot).
function DashboardRoute({ name, ageGroup, showMotherTongue, profileReady, setPage }: { name: string; ageGroup: string; showMotherTongue: boolean; profileReady: boolean; setPage: (p: Page) => void }) {
  const ready = useDashboardAssets(profileReady);
  if (!ready) return <SceneLoading />;
  return <PageTransition><Dashboard name={name} ageGroup={ageGroup} showMotherTongue={showMotherTongue} setPage={setPage} /></PageTransition>;
}

// Examen interactiu (/examen/:id): el contingut ve de resources.metadata.exam.
function ExamRoute({ onBack }: { onBack: () => void }) {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  // undefined = carregant; null = no existix.
  const [exam, setExam] = useState<ExamResource | null>();

  useEffect(() => {
    let cancelled = false;
    // En canviar d'examen (p. ex. «Següent activitat de la ruta») es comença de zero: no es queda el d'abans.
    setExam(undefined);
    if (!id) return setExam(null);
    fetchExam(id)
      .then(data => { if (!cancelled) setExam(data); })
      .catch(error => {
        console.error("Error carregant l'examen:", error);
        if (!cancelled) setExam(null);
      });
    return () => { cancelled = true; };
  }, [id]);

  if (exam === undefined) return null;
  if (!exam) return <Navigate to={ROUTES.scenarioselect} replace />;
  // Obert des d'una ruta, «Tornar» du a la ruta (amb els seus exercicis), no a l'activitat anterior.
  const back = () => { const to = routeBackTo(exam.id); if (to) navigate(to); else onBack(); };
  return <PageTransition><Exam key={exam.id} exam={exam} onBack={back} /></PageTransition>;
}

// Exercicis d'un contingut del temari (/practica/:id), de la taula practice_exercises.
function PracticeRoute({ level, onBack }: { level: string; onBack: () => void }) {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  // undefined = carregant; null = no existix.
  const [practice, setPractice] = useState<PracticeResource | null>();

  useEffect(() => {
    let cancelled = false;
    // En canviar d'activitat (p. ex. «Següent activitat de la ruta») es comença de zero: no es queda l'estat corregit de l'anterior.
    setPractice(undefined);
    if (!id) return setPractice(null);
    fetchPractice(id)
      .then(data => { if (!cancelled) setPractice(data); })
      .catch(error => {
        console.error('Error carregant els exercicis:', error);
        if (!cancelled) setPractice(null);
      });
    return () => { cancelled = true; };
  }, [id]);

  if (practice === undefined) return null;
  if (!practice) return <Navigate to={ROUTES.scenarioselect} replace />;
  // Obert des d'una ruta, «Tornar» du a la ruta (amb els seus exercicis), no a l'activitat anterior.
  const back = () => { const to = routeBackTo(practice.id); if (to) navigate(to); else onBack(); };
  return <PageTransition><Practice key={practice.id} practice={practice} userLevel={level} onBack={back} /></PageTransition>;
}

// Illa del Nivell 0 (/xiquets/illa/:id).
function KidsIslandRoute({ uid }: { uid: string | undefined }) {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  return (
    <KidsIsland
      id={id}
      uid={uid}
      onHome={() => navigate(KIDS_ROUTES.home)}
      onAlbum={() => navigate(KIDS_ROUTES.album)}
      onLesson={lesson => navigate(`${KIDS_ROUTES.lesson}/${lesson}`)}
    />
  );
}

function KidsLessonRoute({ uid }: { uid: string | undefined }) {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  return (
    <KidsLesson
      key={id}
      id={id}
      uid={uid}
      onLessons={() => navigate(ROUTES.lessons)}
      onIsland={island => navigate(`${KIDS_ROUTES.island}/${island}`)}
    />
  );
}

// On entra cada perfil en iniciar sessió: el professorat, a les seues classes.
const homeFor = (role: string | undefined) => (role === 'teacher' ? ROUTES.classes : ROUTES.dashboard);

export function App() {
  const navigate = useNavigate();
  const { pathname } = useLocation();
  // En canviar de pantalla para tot l'àudio que sonava. És la neteja de l'efecte (no el cos) perquè s'execute abans
  // que les pantalles noves comencen els seus àudios (la salutació d'un xat, la veu d'una illa...).
  installAudioTracking();
  useEffect(() => () => {
    stopAllAudio();
    stopVoice();
  }, [pathname]);
  // Barra institucional fixa al peu de totes les pantalles, menys la d'inici (que té el peu complet).
  const showFooterBar = pathname !== ROUTES.home;
  useEffect(() => {
    document.documentElement.style.setProperty('--app-footer', showFooterBar ? '68px' : '0px');
  }, [showFooterBar]);
  const [xp, setXp] = useState(DEFAULT_PROFILE.xp);
  const [level, setLevel] = useState(DEFAULT_PROFILE.level);
  const [name, setName] = useState(DEFAULT_PROFILE.name);
  const [ageGroup, setAgeGroup] = useState(DEFAULT_PROFILE.ageGroup);
  // Rol del perfil: només el professorat ('teacher') veu i crea classes.
  const [role, setRole] = useState('user');
  const [motherTongue, setMotherTongue] = useState<string | null>(null);
  const [showMotherTongue, setShowMotherTongue] = useState(true);
  const [user, setUser] = useState<User | null>(null);
  // Les claus del progrés guardat en el navegador porten l'usuari (vegeu progressStorage).
  setProgressUser(user?.id);
  useEffect(clearLegacyProgress, []);
  // false mentre es comprova la sessió i es carrega el perfil (sense Supabase, ja està).
  const [profileReady, setProfileReady] = useState(!supabase);
  const loadedProfileFor = useRef<string>();
  // On es torna en tancar la sessió: a l'inici, o al login si qui la tanca és docent.
  const afterLogOut = useRef<string>(ROUTES.home);
  // Xiquets de Nivell 0: en lloc del tauler i les activitats, el món d'illes.
  const kids = isKidsLevel0({ level, age_group: ageGroup });

  // Sync profile details from Supabase if logged in
  const loadProfile = async (uid: string): Promise<string | undefined> => {
    if (!supabase) return;
    try {
      const { data } = await supabase
        .from('profiles')
        .select('display_name, level, xp, age_group, mother_tongue, show_mother_tongue, role')
        .eq('id', uid)
        .single();
      if (data) {
        setName(data.display_name || DEFAULT_PROFILE.name);
        setLevel(data.level || DEFAULT_PROFILE.level);
        setXp(data.xp || 0);
        setAgeGroup(data.age_group || DEFAULT_PROFILE.ageGroup);
        setMotherTongue(data.mother_tongue ?? null);
        setShowMotherTongue(data.show_mother_tongue ?? true);
        setRole(data.role || 'user');
        return data.role;
      }
    } catch (e) {
      console.error('Error carregant perfil:', e);
    } finally {
      loadedProfileFor.current = uid;
      setProfileReady(true);
    }
  };

  const resetProfile = () => {
    // La sessió del backend era de l'usuari que ha eixit (també si ha eixit des d'una altra pestanya).
    forgetSession();
    // El catàleg inclou les activitats de les classes de l'usuari: es torna a demanar.
    invalidateResources();
    loadedProfileFor.current = undefined;
    setProfileReady(true);
    setUser(null);
    setName(DEFAULT_PROFILE.name);
    setLevel(DEFAULT_PROFILE.level);
    setXp(DEFAULT_PROFILE.xp);
    setAgeGroup(DEFAULT_PROFILE.ageGroup);
    setMotherTongue(null);
    setShowMotherTongue(true);
    setRole('user');
    navigate(afterLogOut.current, { replace: true });
    afterLogOut.current = ROUTES.home;
  };

  useEffect(() => {
    if (!supabase) return;

    // Check active session on mount. Sols redirigix si encara estava a l'inici
    // o a l'autenticació: si es recarrega qualsevol altra pàgina (p. ex.
    // /scenaris o /perfil) amb sessió activa, s'hi queda en lloc de tornar
    // sempre al tauler.
    void supabase.auth.getSession().then(({ data: { session } }) => {
      if (!session?.user) return setProfileReady(true);
      setUser(session.user);
      void loadProfile(session.user.id).then(r => {
        const path = window.location.pathname;
        if (path === ROUTES.home || path === ROUTES.auth) navigate(homeFor(r), { replace: true });
      });
    });

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
      if (!session?.user) return resetProfile();
      setUser(session.user);
      // Un inici de sessió nou torna a mostrar la càrrega (i a demanar el catàleg, que depén
      // de l'usuari); un refresc del token del mateix usuari, no.
      if (loadedProfileFor.current !== session.user.id) {
        setProfileReady(false);
        invalidateResources();
      }
      const r = await loadProfile(session.user.id);
      // Sols redirigix si encara estava a l'inici o a l'autenticació; si ja
      // navegava per l'app (p. ex. refresc del token), es queda on estava.
      const path = window.location.pathname;
      if (path === ROUTES.home || path === ROUTES.auth) {
        navigate(homeFor(r), { replace: true });
      }
    });

    return () => subscription.unsubscribe();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Escenaris que es van quedar oberts (pestanya tancada, sense connexió...): es tanquen i s'avaluen ara.
  useEffect(() => {
    if (user) void finishAbandonedResources();
  }, [user?.id]);

  // Actualitza l'estat local a l'instant i desa el canvi a Supabase si hi ha sessió.
  const saveProfile = async (fields: ProfileFields) => {
    if (!supabase || !user) return;
    try {
      await supabase.from('profiles').update(fields).eq('id', user.id);
    } catch (err) {
      console.error('Error desant perfil:', err);
    }
  };

  const updateName = (display_name: string) => {
    setName(display_name);
    void saveProfile({ display_name });
  };

  const updateMotherTongue = (mother_tongue: string) => {
    setMotherTongue(mother_tongue);
    void saveProfile({ mother_tongue });
    // Les traduccions que ja té la conversa del tauler passen a la llengua nova.
    void retranslateTutorConversation(mother_tongue);
  };

  // El nivell el canvia el backend (el client no pot escriure profiles.level). Torna les classes
  // de l'usuari que no són del nivell nou, per a avisar-ne.
  const updateLevel = async (next: string, reason: 'manual' | 'placement' = 'manual') => {
    const { level: saved, classes_outside } = await changeLevel(next, reason);
    setLevel(saved);
    return classes_outside;
  };

  const updateShowMotherTongue = (show_mother_tongue: boolean) => {
    setShowMotherTongue(show_mother_tongue);
    void saveProfile({ show_mother_tongue });
  };

  const logOut = async () => {
    if (role === 'teacher') afterLogOut.current = ROUTES.auth;
    // Tanca la sessió al backend abans d'invalidar el token de Supabase.
    await endSession().catch(err => console.error('Error tancant la sessió:', err));
    await supabase?.auth.signOut();
  };

  const goDashboard = () => navigate(ROUTES.dashboard);
  // Callback compatible amb les pàgines que només naveguen entre pantalles
  // simples (sense paràmetres); el xat es gestiona a banda amb `chatRoute`.
  const goToPage = (p: Page) => navigate(ROUTES[p]);

  // El professorat només té accés a les seues classes: qualsevol altra ruta hi redirigix.
  if (role === 'teacher' && pathname !== ROUTES.classes) return <Navigate to={ROUTES.classes} replace />;

  return (
    // Subtítols en la llengua materna en el Nivell 0, si el perfil els té activats.
    <KidsTranslationProvider lang={showMotherTongue && isTranslatedTongue(motherTongue) ? motherTongue : null}>
      <Routes>
        <Route path={ROUTES.home} element={<PageTransition><HomePage setPage={goToPage} /></PageTransition>} />
        <Route path={ROUTES.auth} element={<PageTransition><AuthPage setPage={goToPage} /></PageTransition>} />
        <Route
          path={ROUTES.dashboard}
          element={<DashboardRoute name={name} ageGroup={ageGroup} showMotherTongue={showMotherTongue} profileReady={profileReady} setPage={goToPage} />}
        />
        <Route
          path={KIDS_ROUTES.home}
          element={
            <KidsHome
              name={name}
              uid={user?.id}
              onBack={() => navigate(ROUTES.dashboard)}
              onIsland={id => navigate(`${KIDS_ROUTES.island}/${id}`)}
              onScenario={resource => {
                const route = activityRoute(resource);
                if (route) navigate(route);
              }}
              onAlbum={() => navigate(KIDS_ROUTES.album)}
              onProfile={() => navigate(ROUTES.profile)}
            />
          }
        />
        <Route path={`${KIDS_ROUTES.island}/:id`} element={<KidsIslandRoute uid={user?.id} />} />
        <Route path={KIDS_ROUTES.album} element={<KidsAlbum uid={user?.id} onHome={() => navigate(KIDS_ROUTES.home)} />} />
        {/* Abans hi havia un índex de lliçons propi; ara totes són a la pàgina de lliçons. */}
        <Route path={KIDS_ROUTES.lessons} element={<Navigate to={ROUTES.lessons} replace />} />
        <Route path={`${KIDS_ROUTES.lesson}/:id`} element={<KidsLessonRoute uid={user?.id} />} />
        <Route
          path={ROUTES.learningpath}
          element={kids ? <Navigate to={KIDS_ROUTES.home} replace /> : (
            <PageTransition>
              {/* De l'A1 al C1: rutes de study_paths (predefinides en l'A2, el B1 i el B2, de classe i pròpies), amb un enllaç a la de la IA on n'hi ha; la resta de nivells, la ruta de la IA. */}
              {hasStudyPaths(level) ? (
                <StudyPaths
                  onOpen={resource => {
                    const route = activityRoute(resource);
                    if (route) navigate(route);
                  }}
                  onBack={goDashboard}
                  onAiPath={hasAiPath(level) ? () => navigate(AI_PATH_ROUTE) : undefined}
                />
              ) : (
                <LearningPath
                  onOpen={resource => {
                    const route = activityRoute(resource);
                    if (route) navigate(route);
                  }}
                  onBack={goDashboard}
                />
              )}
            </PageTransition>
          )}
        />
        <Route
          path={`${ROUTES.learningpath}/:pathId`}
          element={kids ? <Navigate to={KIDS_ROUTES.home} replace /> : (
            <PageTransition>
              {/* De l'A1 al C1: rutes de study_paths (predefinides en l'A2, el B1 i el B2, de classe i pròpies), amb un enllaç a la de la IA on n'hi ha; la resta de nivells, la ruta de la IA. */}
              {hasStudyPaths(level) ? (
                <StudyPaths
                  onOpen={resource => {
                    const route = activityRoute(resource);
                    if (route) navigate(route);
                  }}
                  onBack={goDashboard}
                  onAiPath={hasAiPath(level) ? () => navigate(AI_PATH_ROUTE) : undefined}
                />
              ) : (
                <LearningPath
                  onOpen={resource => {
                    const route = activityRoute(resource);
                    if (route) navigate(route);
                  }}
                  onBack={goDashboard}
                />
              )}
            </PageTransition>
          )}
        />
        <Route
          path={AI_PATH_ROUTE}
          // Fins que no es carrega el perfil no se sap el nivell: no es redirigix abans d'hora.
          element={!profileReady ? null : kids || !hasAiPath(level) ? <Navigate to={ROUTES.learningpath} replace /> : (
            <PageTransition>
              <LearningPath
                onOpen={resource => {
                  const route = activityRoute(resource);
                  if (route) navigate(route);
                }}
                onBack={() => navigate(ROUTES.learningpath)}
              />
            </PageTransition>
          )}
        />
        <Route
          path={ROUTES.myclasses}
          element={kids ? <Navigate to={KIDS_ROUTES.home} replace /> : (
            <PageTransition>
              <MyClasses
                onOpen={resource => {
                  const route = activityRoute(resource);
                  if (route) navigate(route);
                }}
                onBack={goDashboard}
                canJoin={!user?.is_anonymous}
              />
            </PageTransition>
          )}
        />
        <Route
          path={`${ROUTES.myclasses}/ruta/:pathId`}
          element={kids ? <Navigate to={KIDS_ROUTES.home} replace /> : (
            <PageTransition>
              <MyClasses
                onOpen={resource => {
                  const route = activityRoute(resource);
                  if (route) navigate(route);
                }}
                onBack={goDashboard}
                canJoin={!user?.is_anonymous}
              />
            </PageTransition>
          )}
        />
        <Route
          path={ROUTES.scenarioselect}
          element={kids ? <Navigate to={KIDS_ROUTES.home} replace /> : (
            <PageTransition>
              <ScenarioSelect
                name={name}
                level={level}
                onSelect={resource => {
                  clearRouteContext(); // des de la llista d'Activitats no es continua cap ruta
                  const route = activityRoute(resource);
                  if (route) navigate(route);
                }}
                onBack={goDashboard}
                onProfile={() => navigate(ROUTES.profile)}
                onErrors={() => navigate(ROUTES.errors)}
              />
            </PageTransition>
          )}
        />
        <Route
          path={ROUTES.profile}
          element={
            <PageTransition>
              <Profile
                name={name}
                setName={updateName}
                level={level}
                setLevel={next => updateLevel(next)}
                xp={xp}
                back={() => navigate(-1)}
                onLogOut={logOut}
                isGuest={Boolean(user?.is_anonymous)}
                isDemo={!user}
                ageGroup={ageGroup}
                motherTongue={motherTongue}
                setMotherTongue={updateMotherTongue}
                showMotherTongue={showMotherTongue}
                setShowMotherTongue={updateShowMotherTongue}
                onProgress={() => navigate(ROUTES.progress)}
                isTeacher={role === 'teacher'}
                uid={user?.id}
                onClasses={() => navigate(ROUTES.classes)}
              />
            </PageTransition>
          }
        />
        <Route
          path={ROUTES.placement}
          // Només per a adults: el món infantil depén del Nivell 0.
          element={!profileReady ? null : ageGroup === 'child' ? <Navigate to={ROUTES.dashboard} replace /> : (
            <PageTransition>
              <PlacementTest level={level} onAccept={next => updateLevel(next, 'placement')} onDone={goDashboard} />
            </PageTransition>
          )}
        />
        <Route
          path={ROUTES.summary}
          element={<PageTransition><Summary xp={xp} onMap={goDashboard} onContinue={() => navigate(ROUTES.learningpath)} /></PageTransition>}
        />
        <Route
          path={`${ROUTES.chat}/:scenario`}
          element={<ChatRoute level={level} kids={kids} xp={xp} onXpGained={delta => setXp(x => x + delta)} onBack={() => navigate(-1)} />}
        />
        <Route path={`${ROUTES.exam}/:id`} element={!profileReady ? null : <ExamRoute onBack={() => navigate(-1)} />} />
        <Route path={`${ROUTES.practice}/:id`} element={!profileReady ? null : <PracticeRoute level={level} onBack={() => navigate(-1)} />} />
        <Route path={ROUTES.errors} element={<PageTransition><ErrorPractice onBack={() => navigate(-1)} /></PageTransition>} />
        <Route path={ROUTES.tutorhistory} element={<PageTransition><TutorHistory onBack={() => navigate(-1)} onResume={goDashboard}showHelp={showMotherTongue} /></PageTransition>} />
        <Route path={ROUTES.lessons} element={<PageTransition><KidsLessons uid={user?.id} onBack={() => navigate(ROUTES.dashboard)} onOpenLesson={id => navigate(`${KIDS_ROUTES.lesson}/${id}`)} /></PageTransition>} />
        <Route
          path={ROUTES.progress}
          element={<PageTransition><KidsProgress uid={user?.id} name={name} isGuest={Boolean(user?.is_anonymous)} onBack={() => navigate(-1)} onLesson={id => navigate(`${KIDS_ROUTES.lesson}/${id}`)} /></PageTransition>}
        />
        <Route
          path={ROUTES.classes}
          element={
            !profileReady ? null
              : role === 'teacher' ? <PageTransition><TeacherClasses uid={user?.id} onLogOut={logOut} /></PageTransition>
              // Sense sessió (p. ex. just després de tancar-la), al login; no al tauler, que seria el mode demo.
              : <Navigate to={user ? ROUTES.dashboard : ROUTES.auth} replace />
          }
        />
        <Route path="*" element={<Navigate to={ROUTES.home} replace />} />
      </Routes>
      {showFooterBar && <InstitutionalBar />}
    </KidsTranslationProvider>
  );
}
