BEGIN;

-- 1. Yeni 14 alt kategoriyi ekle
INSERT INTO "Categories" ("name", "display_order")
SELECT v.name, v.display_order
FROM (VALUES
    ('Sıcak İçecekler / Çaylar', 1),
    ('Sıcak İçecekler / Kahveler', 2),
    ('Sıcak İçecekler / Diğer Sıcaklar', 3),
    ('Soğuk İçecekler / Soğuk Kahveler', 4),
    ('Soğuk İçecekler / Soğuk Çaylar', 5),
    ('Soğuk İçecekler / Milkshake Çeşitleri', 6),
    ('Soğuk İçecekler / Meyve Suları', 7),
    ('Soğuk İçecekler / Gazlı İçecekler', 8),
    ('Tatlılar / Cheesecake Çeşitleri', 9),
    ('Tatlılar / Kek & Pastalar', 10),
    ('Tatlılar / Baklava Çeşitleri', 11),
    ('Tatlılar / Waffle Çeşitleri', 12),
    ('Tatlılar / Sütlü Tatlılar & Pudingler', 13),
    ('Tatlılar / Kurabiyeler', 14)
) AS v(name, display_order)
WHERE NOT EXISTS (
    SELECT 1 FROM "Categories" c WHERE c.name = v.name
);

-- 2. Eski örnek ürünleri pasife al
UPDATE "Products"
SET "is_active" = false;

-- 3. Gerçek menü ürünlerini ekle
INSERT INTO "Products"
("category_id", "name", "description", "allergens", "unit", "is_active")
SELECT
    c.id,
    v.product_name,
    NULL,
    NULL,
    CASE
        WHEN c.name = 'Tatlılar / Kurabiyeler' THEN 'Adet'
        WHEN c.name LIKE 'Tatlılar / %' THEN 'Porsiyon'
        ELSE 'Adet'
    END,
    true

FROM (VALUES
    ('Sıcak İçecekler / Çaylar', 'Siyah Çay'),
    ('Sıcak İçecekler / Çaylar', 'Yeşil Çay'),
    ('Sıcak İçecekler / Çaylar', 'Ihlamur'),
    ('Sıcak İçecekler / Çaylar', 'Chai Latte'),
    ('Sıcak İçecekler / Çaylar', 'Kuşburnu Çayı'),
    ('Sıcak İçecekler / Çaylar', 'Meyve Çayı'),

    ('Sıcak İçecekler / Kahveler', 'Türk Kahvesi'),
    ('Sıcak İçecekler / Kahveler', 'Filtre Kahve'),
    ('Sıcak İçecekler / Kahveler', 'Espresso'),
    ('Sıcak İçecekler / Kahveler', 'Americano'),
    ('Sıcak İçecekler / Kahveler', 'Latte'),
    ('Sıcak İçecekler / Kahveler', 'Mocha'),
    ('Sıcak İçecekler / Kahveler', 'Pumpkin Spice Latte'),
    ('Sıcak İçecekler / Kahveler', 'Matcha Green Latte'),

    ('Sıcak İçecekler / Diğer Sıcaklar', 'Salep'),
    ('Sıcak İçecekler / Diğer Sıcaklar', 'Sıcak Çikolata'),

    ('Soğuk İçecekler / Soğuk Kahveler', 'Iced Americano'),
    ('Soğuk İçecekler / Soğuk Kahveler', 'Iced Latte'),
    ('Soğuk İçecekler / Soğuk Kahveler', 'Iced Mocha'),
    ('Soğuk İçecekler / Soğuk Kahveler', 'Cold Brew'),
    ('Soğuk İçecekler / Soğuk Kahveler', 'Frappuccino'),

    ('Soğuk İçecekler / Soğuk Çaylar', 'Limonlu Ice Tea'),
    ('Soğuk İçecekler / Soğuk Çaylar', 'Şeftalili Ice Tea'),
    ('Soğuk İçecekler / Soğuk Çaylar', 'Mangolu Ice Tea'),
    ('Soğuk İçecekler / Soğuk Çaylar', 'Iced Matcha Latte'),
    ('Soğuk İçecekler / Soğuk Çaylar', 'Strawberry Matcha Latte'),
    ('Soğuk İçecekler / Soğuk Çaylar', 'Berry Hibiscus'),

    ('Soğuk İçecekler / Milkshake Çeşitleri', 'Çilekli Milkshake'),
    ('Soğuk İçecekler / Milkshake Çeşitleri', 'Muzlu Milkshake'),
    ('Soğuk İçecekler / Milkshake Çeşitleri', 'Çikolatalı Milkshake'),
    ('Soğuk İçecekler / Milkshake Çeşitleri', 'Vanilyalı Milkshake'),
    ('Soğuk İçecekler / Milkshake Çeşitleri', 'Karamelli Milkshake'),
    ('Soğuk İçecekler / Milkshake Çeşitleri', 'Yaban Mersinli Milkshake'),

    ('Soğuk İçecekler / Meyve Suları', 'Limonata'),
    ('Soğuk İçecekler / Meyve Suları', 'Çilekli Limonata'),
    ('Soğuk İçecekler / Meyve Suları', 'Karışık Meyve Suyu'),
    ('Soğuk İçecekler / Meyve Suları', 'Portakal Suyu'),
    ('Soğuk İçecekler / Meyve Suları', 'Şeftali Suyu'),
    ('Soğuk İçecekler / Meyve Suları', 'Kayısı Suyu'),
    ('Soğuk İçecekler / Meyve Suları', 'Vişne Suyu'),

    ('Soğuk İçecekler / Gazlı İçecekler', 'Sade Soda'),
    ('Soğuk İçecekler / Gazlı İçecekler', 'Limonlu Soda'),
    ('Soğuk İçecekler / Gazlı İçecekler', 'Sade Gazoz'),
    ('Soğuk İçecekler / Gazlı İçecekler', 'Portakallı Gazoz'),
    ('Soğuk İçecekler / Gazlı İçecekler', 'Kola'),
    ('Soğuk İçecekler / Gazlı İçecekler', 'Maden Suyu'),

    ('Tatlılar / Cheesecake Çeşitleri', 'Orman Meyveli Cheesecake'),
    ('Tatlılar / Cheesecake Çeşitleri', 'Limonlu Cheesecake'),
    ('Tatlılar / Cheesecake Çeşitleri', 'Fıstıklı Cheesecake'),
    ('Tatlılar / Cheesecake Çeşitleri', 'San Sebastian Cheesecake'),

    ('Tatlılar / Kek & Pastalar', 'Havuçlu Kek'),
    ('Tatlılar / Kek & Pastalar', 'Red Velvet Kek'),
    ('Tatlılar / Kek & Pastalar', 'Mozaik Pasta'),
    ('Tatlılar / Kek & Pastalar', 'Tiramisu'),
    ('Tatlılar / Kek & Pastalar', 'Brownie'),
    ('Tatlılar / Kek & Pastalar', 'Vişneli Brownie'),

    ('Tatlılar / Baklava Çeşitleri', 'Fıstıklı Baklava'),
    ('Tatlılar / Baklava Çeşitleri', 'Cevizli Baklava'),
    ('Tatlılar / Baklava Çeşitleri', 'Fındıklı Baklava'),
    ('Tatlılar / Baklava Çeşitleri', 'Soğuk Baklava'),

    ('Tatlılar / Waffle Çeşitleri', 'Çikolatalı Waffle'),
    ('Tatlılar / Waffle Çeşitleri', 'Çilekli-Muzlu Waffle'),
    ('Tatlılar / Waffle Çeşitleri', 'Orman Meyveli Waffle'),
    ('Tatlılar / Waffle Çeşitleri', 'Karamelli Waffle'),

    ('Tatlılar / Sütlü Tatlılar & Pudingler', 'Magnolia'),
    ('Tatlılar / Sütlü Tatlılar & Pudingler', 'Muhallebi'),
    ('Tatlılar / Sütlü Tatlılar & Pudingler', 'Çikolatalı Puding'),
    ('Tatlılar / Sütlü Tatlılar & Pudingler', 'Muzlu Puding'),
    ('Tatlılar / Sütlü Tatlılar & Pudingler', 'Çilekli Puding'),
    ('Tatlılar / Sütlü Tatlılar & Pudingler', 'Kazandibi'),
    ('Tatlılar / Sütlü Tatlılar & Pudingler', 'Tavukgöğsü'),

    ('Tatlılar / Kurabiyeler', 'Elmalı Kurabiye'),
    ('Tatlılar / Kurabiyeler', 'Fındıklı Kurabiye'),
    ('Tatlılar / Kurabiyeler', 'Brownie Kurabiye'),
    ('Tatlılar / Kurabiyeler', 'Beyaz Çikolatalı Kurabiye'),
    ('Tatlılar / Kurabiyeler', 'Çikolata Parçalı Kurabiye'),
    ('Tatlılar / Kurabiyeler', 'Kakaolu Kurabiye'),
    ('Tatlılar / Kurabiyeler', 'Un Kurabiyesi')
) AS v(category_name, product_name)
JOIN "Categories" c ON c.name = v.category_name
WHERE NOT EXISTS (
    SELECT 1
    FROM "Products" p
    WHERE p.name = v.product_name
      AND p.category_id = c.id
);

-- 4. Gerçek menü ürünlerini aktif tut
UPDATE "Products"
SET "is_active" = true
WHERE category_id IN (
    SELECT id FROM "Categories"
    WHERE name LIKE 'Sıcak İçecekler / %'
       OR name LIKE 'Soğuk İçecekler / %'
       OR name LIKE 'Tatlılar / %'
);

-- 4.1 Ürünlerin satış birimlerini belirle
UPDATE "Products" p
SET "unit" = CASE
    WHEN c.name = 'Tatlılar / Kurabiyeler' THEN 'Adet'
    WHEN c.name LIKE 'Tatlılar / %' THEN 'Porsiyon'
    ELSE 'Adet'
END
FROM "Categories" c
WHERE p.category_id = c.id
  AND (
      c.name LIKE 'Sıcak İçecekler / %'
      OR c.name LIKE 'Soğuk İçecekler / %'
      OR c.name LIKE 'Tatlılar / %'
  );

-- 5. Eski örnek ürünlerin şube stoklarını kapat
UPDATE "BranchProducts"
SET "is_in_stock" = false
WHERE product_id IN (
    SELECT p.id
    FROM "Products" p
    JOIN "Categories" c ON c.id = p.category_id
    WHERE c.name NOT LIKE 'Sıcak İçecekler / %'
      AND c.name NOT LIKE 'Soğuk İçecekler / %'
      AND c.name NOT LIKE 'Tatlılar / %'
);

-- 6. Yeni ürünleri üç şubeyle ilişkilendir
-- Fiyatlar NULL, satış durumu şimdilik kapalı
INSERT INTO "BranchProducts"
("branch_id", "product_id", "is_in_stock", "price")
SELECT b.id, p.id, false, NULL
FROM "Branches" b
CROSS JOIN "Products" p
JOIN "Categories" c ON c.id = p.category_id
WHERE c.name LIKE 'Sıcak İçecekler / %'
   OR c.name LIKE 'Soğuk İçecekler / %'
   OR c.name LIKE 'Tatlılar / %'
ON CONFLICT ("branch_id", "product_id")
DO UPDATE SET "is_in_stock" = false;

COMMIT;
