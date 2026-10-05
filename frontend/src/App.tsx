import { useEffect, useRef, useState } from 'react';
import { CHAT_CATEGORIES } from '@parlaval/shared';
import type { User } from '@supabase/supabase-js';
import { Navigate, Route, Routes, useNavigate, useParams } from 'react-router-dom';
import { ScenarioSelect } from './components/ScenarioSelect';
import { SceneLoading, useDashboardAssets, useSceneAssets } from './components/SceneLoading';
import { PageTransition } from './components/ui';
import { supabase } from './lib/supabase';
import { endSession, fetchExam, fetchPractice, fetchResources } from './lib/api';
import type { Exam as ExamResource, Practice as PracticeResource, Resource } from './lib/types';
import { activityRoute, DEFAULT_PROFILE, ROUTES, type Page } from './data/content';
import { HomePage } from './pages/HomePage';
import { AuthPage } from './pages/AuthPage';
import { Dashboard } from './pages/Dashboard';
import { Chat } from './pages/Chat';
import { Exam } from './pages/Exam';
import { Practice } from './pages/Practice';
import { ErrorPractice } from './pages/ErrorPractice';
import { TutorHistory } from './pages/TutorHistory';
import { Lessons } from './pages/Lessons';
import { Summary } from './pages/Summary';
import { Profile } from './pages/Profile';

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
  level, xp, onXpGained, onBack,
}: { level: string; xp: number; onXpGained: (delta: number) => void; onBack: () => void }) {
  const { scenario } = useParams<{ scenario: string }>();
  const navigate = useNavigate();
  const section = useCatalogResource(r => CHAT_CATEGORIES.includes(r.category) && r.type === scenario, scenario);
  // Pantalla de càrrega fins que hi ha la fila, el fons i el robot: el xat no es munta
  // abans perquè en muntar-se ja sona la salutació del personatge.
  const ready = useSceneAssets(scenario, section);

  if (!scenario || section === null) return <Navigate to={ROUTES.scenarioselect} replace />;
  if (section === undefined || !ready) return <SceneLoading />;
  return (
    <PageTransition>
      <Chat
        scenario={scenario}
        category={section.category}
        title={section.section_name ?? section.name}
        voice={section.voice}
        background={section.background}
        initialPrompt={section.initial_prompt}
        actor={section.character}
        summary={section.content}
        objectives={section.objectius ?? []}
        level={level}
        xp={xp}
        onXpGained={onXpGained}
        onEnd={() => navigate(ROUTES.summary)}
        onBack={onBack}
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
  // undefined = carregant; null = no existix.
  const [exam, setExam] = useState<ExamResource | null>();

  useEffect(() => {
    let cancelled = false;
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
  return <PageTransition><Exam exam={exam} onBack={onBack} /></PageTransition>;
}

// Exercicis d'un contingut del temari (/practica/:id), de la taula practice_exercises.
function PracticeRoute({ level, onBack }: { level: string; onBack: () => void }) {
  const { id } = useParams<{ id: string }>();
  // undefined = carregant; null = no existix.
  const [practice, setPractice] = useState<PracticeResource | null>();

  useEffect(() => {
    let cancelled = false;
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
  return <PageTransition><Practice practice={practice} userLevel={level} onBack={onBack} /></PageTransition>;
}

export function App() {
  const navigate = useNavigate();
  const [xp, setXp] = useState(DEFAULT_PROFILE.xp);
  const [level, setLevel] = useState(DEFAULT_PROFILE.level);
  const [name, setName] = useState(DEFAULT_PROFILE.name);
  const [ageGroup, setAgeGroup] = useState(DEFAULT_PROFILE.ageGroup);
  const [motherTongue, setMotherTongue] = useState<string | null>(null);
  const [showMotherTongue, setShowMotherTongue] = useState(true);
  const [user, setUser] = useState<User | null>(null);
  // false mentre es comprova la sessió i es carrega el perfil (sense Supabase, ja està).
  const [profileReady, setProfileReady] = useState(!supabase);
  const loadedProfileFor = useRef<string>();

  // Sync profile details from Supabase if logged in
  const loadProfile = async (uid: string) => {
    if (!supabase) return;
    try {
      const { data } = await supabase
        .from('profiles')
        .select('display_name, level, xp, age_group, mother_tongue, show_mother_tongue')
        .eq('id', uid)
        .single();
      if (data) {
        setName(data.display_name || DEFAULT_PROFILE.name);
        setLevel(data.level || DEFAULT_PROFILE.level);
        setXp(data.xp || 0);
        setAgeGroup(data.age_group || DEFAULT_PROFILE.ageGroup);
        setMotherTongue(data.mother_tongue ?? null);
        setShowMotherTongue(data.show_mother_tongue ?? true);
      }
    } catch (e) {
      console.error('Error carregant perfil:', e);
    } finally {
      loadedProfileFor.current = uid;
      setProfileReady(true);
    }
  };

  const resetProfile = () => {
    loadedProfileFor.current = undefined;
    setProfileReady(true);
    setUser(null);
    setName(DEFAULT_PROFILE.name);
    setLevel(DEFAULT_PROFILE.level);
    setXp(DEFAULT_PROFILE.xp);
    setAgeGroup(DEFAULT_PROFILE.ageGroup);
    setMotherTongue(null);
    setShowMotherTongue(true);
    navigate(ROUTES.home, { replace: true });
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
      void loadProfile(session.user.id);
      const path = window.location.pathname;
      if (path === ROUTES.home || path === ROUTES.auth) {
        navigate(ROUTES.dashboard, { replace: true });
      }
    });

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
      if (!session?.user) return resetProfile();
      setUser(session.user);
      // Un inici de sessió nou torna a mostrar la càrrega; un refresc del token
      // del mateix usuari, no.
      if (loadedProfileFor.current !== session.user.id) setProfileReady(false);
      await loadProfile(session.user.id);
      // Sols redirigix si encara estava a l'inici o a l'autenticació; si ja
      // navegava per l'app (p. ex. refresc del token), es queda on estava.
      const path = window.location.pathname;
      if (path === ROUTES.home || path === ROUTES.auth) {
        navigate(ROUTES.dashboard, { replace: true });
      }
    });

    return () => subscription.unsubscribe();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

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
  };

  const updateShowMotherTongue = (show_mother_tongue: boolean) => {
    setShowMotherTongue(show_mother_tongue);
    void saveProfile({ show_mother_tongue });
  };

  const logOut = async () => {
    // Tanca la sessió al backend abans d'invalidar el token de Supabase.
    await endSession().catch(err => console.error('Error tancant la sessió:', err));
    await supabase?.auth.signOut();
  };

  const goDashboard = () => navigate(ROUTES.dashboard);
  // Callback compatible amb les pàgines que només naveguen entre pantalles
  // simples (sense paràmetres); el xat es gestiona a banda amb `chatRoute`.
  const goToPage = (p: Page) => navigate(ROUTES[p]);

  return (
    <Routes>
      <Route path={ROUTES.home} element={<PageTransition><HomePage setPage={goToPage} /></PageTransition>} />
      <Route path={ROUTES.auth} element={<PageTransition><AuthPage setPage={goToPage} /></PageTransition>} />
      <Route path={ROUTES.dashboard} element={<DashboardRoute name={name} ageGroup={ageGroup} showMotherTongue={showMotherTongue} profileReady={profileReady} setPage={goToPage} />} />
      <Route
        path={ROUTES.scenarioselect}
        element={
          <PageTransition>
            <ScenarioSelect
              name={name}
              level={level}
              onSelect={resource => {
                const route = activityRoute(resource);
                if (route) navigate(route);
              }}
              onBack={goDashboard}
              onProfile={() => navigate(ROUTES.profile)}
              onErrors={() => navigate(ROUTES.errors)}
            />
          </PageTransition>
        }
      />
      <Route
        path={ROUTES.profile}
        element={
          <PageTransition>
            <Profile
              name={name}
              setName={updateName}
              level={level}
              xp={xp}
              back={() => navigate(-1)}
              onLogOut={logOut}
              isDemo={!user}
              ageGroup={ageGroup}
              motherTongue={motherTongue}
              setMotherTongue={updateMotherTongue}
              showMotherTongue={showMotherTongue}
              setShowMotherTongue={updateShowMotherTongue}
            />
          </PageTransition>
        }
      />
      <Route
        path={ROUTES.summary}
        element={<PageTransition><Summary xp={xp} onMap={goDashboard} onContinue={() => navigate(ROUTES.scenarioselect)} /></PageTransition>}
      />
      <Route
        path={`${ROUTES.chat}/:scenario`}
        element={<ChatRoute level={level} xp={xp} onXpGained={delta => setXp(x => x + delta)} onBack={() => navigate(-1)} />}
      />
      <Route path={`${ROUTES.exam}/:id`} element={<ExamRoute onBack={() => navigate(-1)} />} />
      <Route path={`${ROUTES.practice}/:id`} element={<PracticeRoute level={level} onBack={() => navigate(-1)} />} />
      <Route path={ROUTES.errors} element={<PageTransition><ErrorPractice onBack={() => navigate(-1)} /></PageTransition>} />
      <Route path={ROUTES.lessons} element={<PageTransition><Lessons onBack={() => navigate(-1)} motherTongue={motherTongue} showHelp={showMotherTongue} /></PageTransition>} />
      <Route path={ROUTES.tutorhistory} element={<PageTransition><TutorHistory onBack={() => navigate(-1)} onResume={goDashboard} showHelp={showMotherTongue} /></PageTransition>} />
      <Route path="*" element={<Navigate to={ROUTES.home} replace />} />
    </Routes>
  );
}
