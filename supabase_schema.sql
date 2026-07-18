-- Hyperpure Supabase Database Migration Schema
-- Copy and paste this script into your Supabase SQL Editor: https://app.supabase.com

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Categories Table
CREATE TABLE IF NOT EXISTS public.categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    color_hex TEXT DEFAULT '#E8F3F7',
    short_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    category TEXT REFERENCES public.categories(id) ON DELETE CASCADE,
    subcategory TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    mrp NUMERIC(10, 2) NOT NULL,
    unit TEXT NOT NULL,
    weight TEXT NOT NULL,
    description TEXT,
    in_stock BOOLEAN DEFAULT TRUE,
    is_popular BOOLEAN DEFAULT FALSE,
    rating NUMERIC(3, 2) DEFAULT 4.5,
    review_count INT DEFAULT 0,
    pack_info TEXT,
    custom_badge TEXT,
    recent_buyers_count INT,
    is_ad BOOLEAN DEFAULT FALSE,
    best_rate_text TEXT,
    unit_subtext TEXT,
    min_qty_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_phone TEXT NOT NULL,
    items JSONB NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    status TEXT DEFAULT 'pending',
    delivery_slot TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Row Level Security (RLS) Policies
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Allow public read access to products" ON public.products FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert to orders" ON public.orders FOR INSERT WITH CHECK (true);

-- Seed Initial Categories Data
INSERT INTO public.categories (id, name, icon, color_hex, short_name) VALUES
    ('menu-addons', 'Your Menu Add-ons', '🍱', '#E8F3F7', 'Your Menu Add-ons'),
    ('fruits-vegetables', 'Fruits & Vegetables', '🥬', '#E8F3F7', 'Fruits & Vegetables'),
    ('dairy', 'Dairy', '🧀', '#E8F3F7', 'Dairy'),
    ('masala-spices', 'Masala, Salt & Sugar', '🌶️', '#E8F3F7', 'Masala, Salt & Sugar'),
    ('sauces-seasoning', 'Sauces & Seasoning', '🫙', '#E8F3F7', 'Sauces & Seasoning'),
    ('canned-imported', 'Canned & Imported Items', '🥫', '#E8F3F7', 'Canned & Imported'),
    ('chicken-eggs', 'Chicken & Eggs', '🍗', '#E8F3F7', 'Chicken & Eggs'),
    ('custom-packaging', 'Custom Packaging', '🛍️', '#E8F3F7', 'Custom Packaging'),
    ('frozen', 'Frozen & Instant Food', '🧊', '#E8F3F7', 'Frozen & Instant'),
    ('packaging', 'Packaging Material', '📦', '#E8F3F7', 'Packaging Material'),
    ('bakery', 'Bakery & Chocolates', '🧁', '#E8F3F7', 'Bakery & Chocolates'),
    ('cleaning', 'Cleaning & Consumables', '🧹', '#E8F3F7', 'Cleaning & Consumables'),
    ('pulses', 'Pulses', '🫘', '#E8F3F7', 'Pulses'),
    ('edible-oils', 'Edible Oils', '🛢️', '#E8F3F7', 'Edible Oils'),
    ('beverages', 'Beverages & Mixers', '☕', '#E8F3F7', 'Beverages & Mixers'),
    ('flours', 'Flours', '🌾', '#E8F3F7', 'Flours')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    icon = EXCLUDED.icon,
    short_name = EXCLUDED.short_name;

-- Seed Initial Products Data
INSERT INTO public.products (name, category, subcategory, price, mrp, unit, weight, description, in_stock, is_popular, rating, review_count, pack_info, custom_badge, recent_buyers_count, is_ad, best_rate_text, unit_subtext, min_qty_text) VALUES
    ('Eggs (30 Pcs/Tray)', 'chicken-eggs', 'Eggs', 241, 260, 'tray', '30 pc', 'NECC benchmarked fresh farm eggs.', true, true, 4.5, 776, NULL, 'NECC BENCHMARKED', NULL, false, '₹237/tray Best rate', '₹8.03/pc', '2 min. Qty'),
    ('Chicken Breast Boneless Cleaned, 2 Kg P...', 'chicken-eggs', 'Chicken', 740, 800, 'kg', '2 kg', 'ISO certified fresh boneless chicken breast.', true, true, 4.6, 402, NULL, 'ISO CERTIFIED', NULL, false, '₹365/kg Best rate', '₹370/kg', NULL),
    ('Premium Eggs (30 Pcs/Tray)', 'chicken-eggs', 'Eggs', 248, 270, 'tray', '30 pc', 'Selected premium white eggs tray.', true, true, 4.6, 443, NULL, NULL, 975, false, '₹245/tray Best rate', '₹8.27/pc', NULL),
    ('McCain - Spiced Paneer Patty, 960 gm', 'frozen', 'Frozen Patties', 342, 380, 'pack', '0.96 kg', 'Delicious spiced paneer patties by McCain.', true, false, 4.5, 17, NULL, NULL, NULL, true, '₹338/pack Best rate', NULL, NULL),
    ('McCain - French Fries (9 mm), 2.5 Kg', 'frozen', 'French Fries', 365, 410, 'kg', '2.50 kg', 'Classic 9mm cut frozen french fries by McCain.', true, true, 4.7, 221, NULL, NULL, 500, false, '₹141.2/kg Best rate', '₹146/kg', NULL),
    ('Veeba - Eggless Mayonnaise Professional, 1 Kg', 'sauces-seasoning', 'Mayonnaise', 113, 142.88, 'pack', '1 pack', 'Creamy eggless mayonnaise for commercial kitchens.', true, true, 4.9, 445, NULL, NULL, 850, false, '₹112/pack Best rate', NULL, NULL),
    ('Chef''s Art - Piri Piri Sprinkler, 250 gm', 'sauces-seasoning', 'Seasonings', 160, 180, 'kg', '0.25 kg', 'Spicy Piri Piri seasoning sprinkler.', true, true, 4.8, 475, NULL, NULL, NULL, false, '₹604/kg Best rate', NULL, NULL),
    ('Spring Home (By TYJ) - Spring Roll Sheets (Wheat F...', 'canned-imported', 'Imported Sheets', 224, 231, 'pc', '50 pc', 'Imported wheat flour spring roll sheets.', true, true, 4.9, 258, NULL, 'IMPORTED', NULL, false, '₹210/pc Best rate', NULL, NULL),
    ('10on - Soft 1 Ply Napkin, 27 x 30 cm, 100 Pulls (P...', 'packaging', 'Tissue & Napkins', 606, 650, 'pc', '1 pc', 'Soft 1 ply paper napkins for restaurant dining.', true, true, 4.5, 15, 'PACK OF 25', NULL, NULL, true, NULL, NULL, NULL),
    ('White Paper Straws, 8 mm x 197 mm (330 GS...', 'packaging', 'Straws', 22, 25, 'pc', '50 pc', 'Eco-friendly white paper straws for cold beverages.', true, true, 4.8, 224, 'PACK OF 50', NULL, 575, false, '₹0.42/pc Best rate', '₹0.44/pc', '2 min. Qty'),
    ('Nestle - Milkmaid, 380 gm', 'bakery', 'Condensed Milk', 140, 141.9, 'tin', '1 tin', 'Classic sweetened condensed milk for baking and desserts.', true, true, 4.8, 204, NULL, NULL, 320, false, '₹138/pc Best rate', NULL, NULL),
    ('Morde - Dark Compound (COD15), 500 gm', 'bakery', 'Chocolates', 169, 189.52, 'gm', '500 gm', 'Premium dark chocolate compound for baking and desserts.', true, true, 5.0, 237, NULL, NULL, 450, false, '₹164/pc Best rate', '₹0.34/gm', NULL);
