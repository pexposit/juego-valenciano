-- =========================================================
-- 2. TAULA DE RECOMANACIONS (user_recommendations)
-- Sense claus forànies (independent de cap altra entitat)
-- =========================================================
CREATE TABLE IF NOT EXISTS public.user_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    -- Identificador pla de l'usuari (sense vincle a auth.users)
    user_id UUID NOT NULL,
    
    -- Diagnòstic generat pel subagent
    summary TEXT NOT NULL,
    focus_category TEXT NOT NULL,
    grammar_tip TEXT NOT NULL,
    
    -- Escenari assignat per a entrenar
    recommended_scenario_key TEXT NOT NULL,
    mission_goal TEXT NOT NULL,
    system_reinforcement TEXT NOT NULL,
    
    -- Exercici ràpid (estructurat en JSON lliure)
    quick_drill JSONB,
    
    -- Gestió d'estat
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'dismissed'))
);
