-- ============================================================
-- LOVITZ — Supabase Schema
-- Habit tracker baseado na Pirâmide de Maslow
-- ============================================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE public.users (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email       TEXT UNIQUE NOT NULL,
  full_name   TEXT NOT NULL DEFAULT '',
  avatar_url  TEXT,
  xp_total    INT NOT NULL DEFAULT 0,
  level       INT NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice para lookup por email (login)
CREATE INDEX idx_users_email ON public.users(email);

-- ============================================================
-- 2. HABITS
-- ============================================================
CREATE TABLE public.habits (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  description     TEXT,
  maslow_level    INT NOT NULL CHECK (maslow_level BETWEEN 1 AND 5),
  habit_type      TEXT NOT NULL DEFAULT 'qualitative'
                    CHECK (habit_type IN ('qualitative', 'quantitative')),
  frequency       TEXT NOT NULL DEFAULT 'daily'
                    CHECK (frequency IN ('daily', 'weekly', 'monthly')),
  target_value    NUMERIC,
  unit            TEXT,
  weight          INT NOT NULL DEFAULT 1,
  icon            TEXT,
  color           TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  streak_current  INT NOT NULL DEFAULT 0,
  streak_best     INT NOT NULL DEFAULT 0,
  last_logged_at  DATE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices para queries mais frequentes
CREATE INDEX idx_habits_user        ON public.habits(user_id);
CREATE INDEX idx_habits_user_active ON public.habits(user_id) WHERE is_active = true;
CREATE INDEX idx_habits_level       ON public.habits(user_id, maslow_level);

-- ============================================================
-- 3. HABIT_LOGS (registros diários)
-- ============================================================
CREATE TABLE public.habit_logs (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  habit_id      UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  log_date      DATE NOT NULL DEFAULT CURRENT_DATE,
  completed     BOOLEAN NOT NULL DEFAULT true,
  value         NUMERIC,
  quality       INT CHECK (quality BETWEEN 1 AND 5),
  points        INT NOT NULL DEFAULT 0,
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Um registro por hábito por dia (evita duplicatas)
CREATE UNIQUE INDEX idx_logs_habit_date ON public.habit_logs(habit_id, log_date);

-- Queries otimizadas
CREATE INDEX idx_logs_user_date  ON public.habit_logs(user_id, log_date DESC);
CREATE INDEX idx_logs_habit_date_asc ON public.habit_logs(habit_id, log_date DESC);

-- ============================================================
-- 4. ACHIEVEMENTS (catálogo de conquistas)
-- ============================================================
CREATE TABLE public.achievements (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code        TEXT UNIQUE NOT NULL,
  title       TEXT NOT NULL,
  description TEXT,
  icon        TEXT,
  xp_reward   INT NOT NULL DEFAULT 0,
  condition   JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 5. USER_ACHIEVEMENTS (conquistas desbloqueadas)
-- ============================================================
CREATE TABLE public.user_achievements (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  achievement_id  UUID NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
  unlocked_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  progress        JSONB,

  -- Um usuário não pode desbloquear a mesma conquista duas vezes
  UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user ON public.user_achievements(user_id);

-- ============================================================
-- TRIGGERS — updated_at automático
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_habits_updated_at
  BEFORE UPDATE ON public.habits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- TRIGGER — Recalcula streak ao inserir log
-- ============================================================
CREATE OR REPLACE FUNCTION recalculate_streak()
RETURNS TRIGGER AS $$
DECLARE
  current_streak INT := 0;
  best_streak    INT := 0;
  check_date     DATE;
  log_cursor     RECORD;
BEGIN
  -- Conta streak atual (dias consecutivos a partir de hoje/ontem)
  check_date := NEW.log_date;

  FOR log_cursor IN
    SELECT log_date, completed
    FROM public.habit_logs
    WHERE habit_id = NEW.habit_id
    ORDER BY log_date DESC
  LOOP
    IF log_cursor.completed AND log_cursor.log_date = check_date THEN
      current_streak := current_streak + 1;
      check_date := check_date - INTERVAL '1 day';
    ELSE
      EXIT;
    END IF;
  END LOOP;

  -- Melhor streak (conta total de sequências)
  SELECT COALESCE(MAX(streak), 0) INTO best_streak
  FROM (
    SELECT COUNT(*) AS streak
    FROM (
      SELECT log_date, completed,
             log_date - (ROW_NUMBER() OVER (ORDER BY log_date))::int AS grp
      FROM public.habit_logs
      WHERE habit_id = NEW.habit_id AND completed = true
    ) grouped
    GROUP BY grp
  ) streaks;

  best_streak := GREATEST(best_streak, current_streak);

  -- Atualiza o hábito
  UPDATE public.habits
  SET streak_current = current_streak,
      streak_best    = best_streak,
      last_logged_at = NEW.log_date
  WHERE id = NEW.habit_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recalculate_streak
  AFTER INSERT OR UPDATE ON public.habit_logs
  FOR EACH ROW EXECUTE FUNCTION recalculate_streak();

-- ============================================================
-- TRIGGER — XP do usuário ao completar log
-- ============================================================
CREATE OR REPLACE FUNCTION award_xp_on_log()
RETURNS TRIGGER AS $$
DECLARE
  base_points INT;
  habit_weight INT;
  earned INT;
BEGIN
  IF NEW.completed = true THEN
    -- Busca peso do hábito
    SELECT weight INTO habit_weight
    FROM public.habits WHERE id = NEW.habit_id;

    -- Pontos base + bônus por qualidade
    base_points := 10;
    IF NEW.quality IS NOT NULL THEN
      base_points := base_points + (NEW.quality * 2);
    END IF;

    earned := base_points * COALESCE(habit_weight, 1);

    -- Atualiza pontos no log
    NEW.points := earned;

    -- Soma XP do usuário
    UPDATE public.users
    SET xp_total = xp_total + earned,
        level = GREATEST(1, (xp_total + earned) / 100 + 1)
    WHERE id = NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_award_xp
  BEFORE INSERT ON public.habit_logs
  FOR EACH ROW EXECUTE FUNCTION award_xp_on_log();

-- ============================================================
-- RLS (Row Level Security) — Supabase Auth
-- ============================================================
ALTER TABLE public.users             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_logs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Users: cada um vê e edita só o próprio registro
CREATE POLICY "Users: own data" ON public.users
  FOR ALL USING (id = auth.uid()) WITH CHECK (id = auth.uid());

-- Habits: cada um vê e edita só os seus
CREATE POLICY "Habits: own data" ON public.habits
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Habit logs: cada um vê e edita só os seus
CREATE POLICY "Logs: own data" ON public.habit_logs
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Achievements: catálogo é leitura pública
CREATE POLICY "Achievements: public read" ON public.achievements
  FOR SELECT USING (true);

-- User achievements: cada um vê só os seus
CREATE POLICY "User achievements: own data" ON public.user_achievements
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ============================================================
-- SEED — Catálogo de conquistas
-- ============================================================
INSERT INTO public.achievements (code, title, description, icon, xp_reward, condition) VALUES
  ('first_habit',    'Primeiro Passo',     'Crie seu primeiro hábito',                '🎯', 50,  '{"type": "habits_created", "count": 1}'),
  ('streak_7',       'Sequência de 7',     'Mantenha um hábito por 7 dias seguidos',  '🔥', 100, '{"type": "streak", "days": 7}'),
  ('streak_30',      'Mês Perfeito',       'Mantenha um hábito por 30 dias seguidos', '💎', 500, '{"type": "streak", "days": 30}'),
  ('all_levels',     'Pirâmide Completa',  'Registre hábitos em todos os 5 níveis',   '🏔️', 300, '{"type": "all_levels"}'),
  ('log_100',        'Centenário',         'Registre 100 hábitos completados',        '💯', 200, '{"type": "total_logs", "count": 100}'),
  ('early_bird',     'Madrugador',         'Complete um hábito antes das 7h',         '🌅', 75,  '{"type": "early_log", "before_hour": 7}'),
  ('perfect_week',   'Semana Perfeita',    'Complete todos os hábitos em 7 dias',     '⭐', 250, '{"type": "perfect_week"}'),
  ('xp_1000',        'Mil Pontos',         'Acumule 1000 XP',                        '🏆', 0,   '{"type": "xp", "amount": 1000}'),
  ('habit_master',   'Mestre de Hábitos',  'Crie 10 hábitos diferentes',              '🧠', 400, '{"type": "habits_created", "count": 10}'),
  ('level_5',        'Autorrealizado',     'Alcance o nível 5',                       '🌟', 350, '{"type": "level", "level": 5}');

-- ============================================================
-- VIEWS — Queries úteis pré-computadas
-- ============================================================

-- Resumo do usuário com contagem de hábitos ativos
CREATE VIEW public.user_stats AS
SELECT
  u.id,
  u.full_name,
  u.xp_total,
  u.level,
  COUNT(h.id) FILTER (WHERE h.is_active = true) AS active_habits,
  COALESCE(SUM(h.streak_current), 0) AS total_streak_days
FROM public.users u
LEFT JOIN public.habits h ON h.user_id = u.id
GROUP BY u.id;

-- Progresso diário do usuário
CREATE VIEW public.daily_progress AS
SELECT
  hl.user_id,
  hl.log_date,
  COUNT(*) AS total_logged,
  COUNT(*) FILTER (WHERE hl.completed) AS completed,
  SUM(hl.points) AS total_points
FROM public.habit_logs hl
GROUP BY hl.user_id, hl.log_date
ORDER BY hl.log_date DESC;
