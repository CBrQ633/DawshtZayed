-- ==============================================================================
-- 🚀 Dawsha App CLEAN Unified Database Schema (Supabase)
-- ==============================================================================

-- ⚠️ Warning: This will delete existing tables and data for a clean start!
DROP TABLE IF EXISTS public.post_comments CASCADE;
DROP TABLE IF EXISTS public.post_likes CASCADE;
DROP TABLE IF EXISTS public.challenge_participants CASCADE;
DROP TABLE IF EXISTS public.activities CASCADE;
DROP TABLE IF EXISTS public.challenges CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;
DROP TABLE IF EXISTS public.posts CASCADE;
DROP TABLE IF EXISTS public.events CASCADE;
DROP TABLE IF EXISTS public.store_items CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles Table (Sports & App Stats)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    age INTEGER,
    gender TEXT,
    city TEXT DEFAULT 'Sheikh Zayed',
    avatar_url TEXT,
    fitness_level TEXT DEFAULT 'Beginner',
    preferred_pace TEXT,
    rank TEXT DEFAULT 'مبتدئ',
    coins INTEGER DEFAULT 0,
    xp INTEGER DEFAULT 0,
    total_km NUMERIC DEFAULT 0.0,
    streak_days INTEGER DEFAULT 0,
    last_activity_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone." ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile." ON profiles FOR UPDATE USING (auth.uid() = id);

-- 2. Events Table (Runs & Community)
CREATE TABLE public.events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT NOT NULL,
    image_url TEXT, 
    distance TEXT NOT NULL, 
    difficulty TEXT, -- 'Easy', 'Intermediate', 'Hard'
    is_featured BOOLEAN DEFAULT false,
    coach_name TEXT,
    participants_count INTEGER DEFAULT 0,
    max_participants INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for Events
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Events are viewable by everyone." ON events FOR SELECT USING (true);

-- 3. Posts Table (Community Activity Feed)
CREATE TABLE public.posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    caption TEXT,
    media_url TEXT, 
    media_type TEXT DEFAULT 'image', 
    distance_km NUMERIC DEFAULT 0.0, 
    duration_minutes INTEGER DEFAULT 0,
    pace TEXT, 
    location_tag TEXT,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for Posts
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Posts are viewable by everyone." ON posts FOR SELECT USING (true);
CREATE POLICY "Users can insert their own posts." ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own posts." ON posts FOR DELETE USING (auth.uid() = user_id);

-- 4.1 Post Likes Table
CREATE TABLE public.post_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Likes viewable by everyone" ON post_likes FOR SELECT USING (true);
CREATE POLICY "Users can like posts" ON post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike posts" ON post_likes FOR DELETE USING (auth.uid() = user_id);

-- 4.2 Post Comments Table
CREATE TABLE public.post_comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.post_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Comments viewable by everyone" ON post_comments FOR SELECT USING (true);
CREATE POLICY "Users can comment on posts" ON post_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own comments" ON post_comments FOR DELETE USING (auth.uid() = user_id);

-- 4. Store Items (Marketplace Goods)
CREATE TABLE public.store_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price INTEGER NOT NULL,
    image_url TEXT,
    category TEXT DEFAULT 'gear', 
    stock INTEGER DEFAULT 10,
    is_available BOOLEAN DEFAULT true,
    is_official BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for Store Items
ALTER TABLE public.store_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Store items are viewable by everyone." ON store_items FOR SELECT USING (true);

-- 5. Orders Table (Purchase History)
CREATE TABLE public.orders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    item_id UUID REFERENCES public.store_items(id) ON DELETE CASCADE NOT NULL,
    price_paid INTEGER NOT NULL,
    status TEXT DEFAULT 'completed', 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own orders." ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own orders." ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. Challenges Table
CREATE TABLE public.challenges (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL DEFAULT 'distance', -- 'distance', 'speed', 'streak'
    goal_value NUMERIC NOT NULL,
    reward_coins INTEGER DEFAULT 0,
    reward_xp INTEGER DEFAULT 0,
    image_url TEXT,
    end_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Challenges viewable by everyone" ON challenges FOR SELECT USING (true);

-- 7. Challenge Participants Table
CREATE TABLE public.challenge_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    challenge_id UUID REFERENCES public.challenges(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    progress NUMERIC DEFAULT 0.0,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(challenge_id, user_id)
);

ALTER TABLE public.challenge_participants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their participations" ON challenge_participants FOR SELECT USING (true);
CREATE POLICY "Users can join challenges" ON challenge_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their progress" ON challenge_participants FOR UPDATE USING (auth.uid() = user_id);

-- 8. Activities Table (Running Sessions)
CREATE TABLE public.activities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    type TEXT DEFAULT 'Run',
    distance NUMERIC NOT NULL,
    duration_seconds INTEGER NOT NULL,
    pace NUMERIC,
    calories INTEGER DEFAULT 0,
    route JSONB, -- Storage for [{lat, lng}, ...]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for Activities
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Activities are viewable by everyone." ON activities FOR SELECT USING (true);
CREATE POLICY "Users can insert their own activities." ON activities FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own activities." ON activities FOR DELETE USING (auth.uid() = user_id);

-- 9. Auth Trigger: إنشاء بروفايل تلقائياً عند التسجيل
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, avatar_url)
  VALUES (
    new.id, 
    new.email, 
    COALESCE(new.raw_user_meta_data->>'full_name', 'عداء دوشة'),
    COALESCE(new.raw_user_meta_data->>'avatar_url', 'https://ui-avatars.com/api/?name=' || COALESCE(new.raw_user_meta_data->>'full_name', 'User'))
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 10. Activity Rewards Trigger: حلقة حساب النقاط والتحديات تلقائياً
CREATE OR REPLACE FUNCTION public.fn_on_activity_saved()
RETURNS TRIGGER AS $$
DECLARE
    xp_reward INTEGER;
    coins_reward INTEGER;
    part RECORD;
BEGIN
    -- 1. حساب الجوائز الأساسية (50 XP و 10 عملات لكل كيلو)
    xp_reward := floor(NEW.distance * 50);
    coins_reward := floor(NEW.distance * 10);

    -- 2. تحديث البروفايل الأساسي
    UPDATE public.profiles
    SET 
        total_km = total_km + NEW.distance,
        xp = xp + xp_reward,
        coins = coins + coins_reward,
        streak_days = CASE 
            WHEN (last_activity_date IS NULL OR last_activity_date < CURRENT_DATE - INTERVAL '1 day') THEN 1
            WHEN last_activity_date = CURRENT_DATE - INTERVAL '1 day' THEN streak_days + 1
            ELSE streak_days
        END,
        last_activity_date = CURRENT_DATE
    WHERE id = NEW.user_id;

    -- 3. تحديث التحديات النشطة
    FOR part IN 
        SELECT cp.*, c.goal_value, c.reward_coins, c.reward_xp, c.type as c_type
        FROM public.challenge_participants cp
        JOIN public.challenges c ON cp.challenge_id = c.id
        WHERE cp.user_id = NEW.user_id AND cp.is_completed = false
    LOOP
        -- حالياً ندعم تحديات المسافة فقط
        IF part.c_type = 'distance' THEN
            UPDATE public.challenge_participants
            SET 
                progress = progress + NEW.distance,
                is_completed = (progress + NEW.distance) >= part.goal_value,
                completed_at = CASE WHEN (progress + NEW.distance) >= part.goal_value THEN NOW() ELSE NULL END
            WHERE id = part.id;

            -- لو التحدي اكتمل، ندي الجايزة الاضافية
            IF (part.progress + NEW.distance) >= part.goal_value THEN
                UPDATE public.profiles
                SET 
                    coins = coins + part.reward_coins,
                    xp = xp + part.reward_xp
                WHERE id = NEW.user_id;
            END IF;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_on_activity_saved ON public.activities;
CREATE TRIGGER tr_on_activity_saved
AFTER INSERT ON public.activities
FOR EACH ROW EXECUTE PROCEDURE public.fn_on_activity_saved();

-- 12. Social Interaction Triggers: تحديث أرقام اللايكات والتعليقات تلقائياً
CREATE OR REPLACE FUNCTION public.fn_on_post_interaction()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF (TG_TABLE_NAME = 'post_likes') THEN
            UPDATE public.posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
        ELSIF (TG_TABLE_NAME = 'post_comments') THEN
            UPDATE public.posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        IF (TG_TABLE_NAME = 'post_likes') THEN
            UPDATE public.posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
        ELSIF (TG_TABLE_NAME = 'post_comments') THEN
            UPDATE public.posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Likes Triggers
DROP TRIGGER IF EXISTS tr_after_like_insert ON public.post_likes;
CREATE TRIGGER tr_after_like_insert AFTER INSERT ON public.post_likes FOR EACH ROW EXECUTE PROCEDURE public.fn_on_post_interaction();
DROP TRIGGER IF EXISTS tr_after_like_delete ON public.post_likes;
CREATE TRIGGER tr_after_like_delete AFTER DELETE ON public.post_likes FOR EACH ROW EXECUTE PROCEDURE public.fn_on_post_interaction();

-- Comments Triggers
DROP TRIGGER IF EXISTS tr_after_comment_insert ON public.post_comments;
CREATE TRIGGER tr_after_comment_insert AFTER INSERT ON public.post_comments FOR EACH ROW EXECUTE PROCEDURE public.fn_on_post_interaction();
DROP TRIGGER IF EXISTS tr_after_comment_delete ON public.post_comments;
CREATE TRIGGER tr_after_comment_delete AFTER DELETE ON public.post_comments FOR EACH ROW EXECUTE PROCEDURE public.fn_on_post_interaction();

-- 11. Store Purchase RPC: عملية شراء آمنة (Atomic Transaction)
-- تتعامل مع الرصيد، المخزن، وضافة الطلب في خطوة واحدة
CREATE OR REPLACE FUNCTION public.rpc_purchase_item(
    p_item_id UUID,
    p_user_id UUID,
    p_price INTEGER
)
RETURNS JSONB AS $$
DECLARE
    v_user_coins INTEGER;
    v_item_stock INTEGER;
    v_item_name TEXT;
BEGIN
    -- 1. التأكد من بيانات المستخدم (مع قفل السطر لمنع تعارض العمليات)
    SELECT coins INTO v_user_coins FROM public.profiles WHERE id = p_user_id FOR UPDATE;
    
    -- 2. التأكد من بيانات المنتج
    SELECT name, stock INTO v_item_name, v_item_stock FROM public.store_items WHERE id = p_item_id FOR UPDATE;

    -- 3. التحقق من الشروط
    IF v_user_coins < p_price THEN
        RETURN jsonb_build_object('success', false, 'message', 'رصيدك غير كافٍ');
    END IF;

    IF v_item_stock <= 0 THEN
        RETURN jsonb_build_object('success', false, 'message', 'هذا المنتج نفذ من المخزن');
    END IF;

    -- 4. تنفيذ العملية (خصم العملات، تقليل المخزن، إضافة الطلب)
    UPDATE public.profiles SET coins = coins - p_price WHERE id = p_user_id;
    UPDATE public.store_items SET stock = stock - 1 WHERE id = p_item_id;
    
    INSERT INTO public.orders (user_id, item_id, price_paid, status)
    VALUES (p_user_id, p_item_id, p_price, 'completed');

    RETURN jsonb_build_object(
        'success', true, 
        'message', 'تم شراء ' || v_item_name || ' بنجاح',
        'new_balance', v_user_coins - p_price
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'message', 'حدث خطأ غير متوقع: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 📊 Sample Data for Visuals
-- ==============================================================================

-- 1. Insert Sample Event
INSERT INTO public.events (title, location, event_date, image_url, distance, is_featured, participants_count)
VALUES ('ماراثون زايد الخيري', 'ممشى زايد الدائري', '2025-10-15 07:00:00+00', 'https://images.unsplash.com/photo-1552674605-15cffe483f25', '5KM', true, 342);

-- 2. Insert Store Items
INSERT INTO public.store_items (name, description, price, image_url, category, is_official)
VALUES 
('تيشيرت دوشة الرسمي', 'تيشيرت رياضي مريح بشعار دوشة', 250, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab', 'gear', true),
('قسيمة شراء ديكاتلون', 'قيمة 100 جنيه مصري', 500, 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d', 'voucher', false);

-- 3. Sample Challenges
INSERT INTO public.challenges (title, description, type, goal_value, reward_coins, reward_xp, end_date, image_url)
VALUES 
('تحدي الـ 20 كم الأسبوعي', 'اجرِ مسافة إجمالية 20 كم خلال هذا الأسبوع لتحصل على المكافأة!', 'distance', 20.0, 200, 1000, NOW() + INTERVAL '7 days', 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&q=80&w=400'),
('ماراثون زايد الصغير', 'أكمل 42 كم خلال شهر رمضان واثبت قوتك!', 'distance', 42.1, 500, 2500, NOW() + INTERVAL '30 days', 'https://images.unsplash.com/photo-1532444458054-01a7dd3e9fca?auto=format&fit=crop&q=80&w=400');
