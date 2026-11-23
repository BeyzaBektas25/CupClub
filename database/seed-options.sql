
BEGIN;

-- 1. Ürünlere seçenek gruplarını ekle

INSERT INTO "ProductOptionGroups"
    ("product_id", "name", "is_required", "min_selectable", "max_selectable")
SELECT
    p.id,
    s.group_name,
    false,
    0,
    1
FROM (
    VALUES
        ('Chai Latte', 'Boyut'),
        ('Matcha Green Latte', 'Boyut'),
        ('Pumpkin Spice Latte', 'Boyut'),
        ('Mocha', 'Boyut'),
        ('Latte', 'Boyut'),
        ('Sıcak Çikolata', 'Boyut'),
        ('Salep', 'Boyut'),
        ('Frappuccino', 'Boyut'),
        ('Cold Brew', 'Boyut'),
        ('Iced Mocha', 'Boyut'),
        ('Iced Latte', 'Boyut'),
        ('Iced Americano', 'Boyut'),
        ('Strawberry Matcha Latte', 'Boyut'),
        ('Iced Matcha Latte', 'Boyut'),

        ('Chai Latte', 'Süt'),
        ('Matcha Green Latte', 'Süt'),
        ('Pumpkin Spice Latte', 'Süt'),
        ('Mocha', 'Süt'),
        ('Latte', 'Süt'),
        ('Sıcak Çikolata', 'Süt'),
        ('Salep', 'Süt'),
        ('Frappuccino', 'Süt'),
        ('Iced Mocha', 'Süt'),
        ('Iced Latte', 'Süt'),
        ('Strawberry Matcha Latte', 'Süt'),
        ('Iced Matcha Latte', 'Süt'),

        ('Chai Latte', 'Şurup'),
        ('Matcha Green Latte', 'Şurup'),
        ('Pumpkin Spice Latte', 'Şurup'),
        ('Mocha', 'Şurup'),
        ('Latte', 'Şurup'),
        ('Frappuccino', 'Şurup'),
        ('Cold Brew', 'Şurup'),
        ('Iced Mocha', 'Şurup'),
        ('Iced Latte', 'Şurup'),
        ('Strawberry Matcha Latte', 'Şurup'),
        ('Iced Matcha Latte', 'Şurup'),

        ('Americano', 'Ekstra Espresso'),
        ('Pumpkin Spice Latte', 'Ekstra Espresso'),
        ('Mocha', 'Ekstra Espresso'),
        ('Latte', 'Ekstra Espresso'),
        ('Frappuccino', 'Ekstra Espresso'),
        ('Iced Mocha', 'Ekstra Espresso'),
        ('Iced Latte', 'Ekstra Espresso'),
        ('Iced Americano', 'Ekstra Espresso')
) AS s(product_name, group_name)
JOIN "Products" p ON p.name = s.product_name
WHERE p.is_active = true
AND NOT EXISTS (
    SELECT 1
    FROM "ProductOptionGroups" g
    WHERE g.product_id = p.id
      AND g.name = s.group_name
);

-- 2. Seçenekleri ve ek fiyatlarını ekle

WITH option_seed(group_name, option_name, additional_price) AS (
    VALUES
        ('Boyut', 'Küçük', 0),
        ('Boyut', 'Orta', 8),
        ('Boyut', 'Büyük', 15),

        ('Süt', 'Normal Süt', 0),
        ('Süt', 'Laktozsuz Süt', 5),
        ('Süt', 'Badem Sütü', 10),
        ('Süt', 'Yulaf Sütü', 10),

        ('Şurup', 'Vanilya', 10),
        ('Şurup', 'Karamel', 10),
        ('Şurup', 'Fındık', 10),

        ('Ekstra Espresso', '1 Ekstra Shot', 12),
        ('Ekstra Espresso', '2 Ekstra Shot', 24)
)
INSERT INTO "ProductOptions"
    ("group_id", "name", "base_additional_price")
SELECT
    g.id,
    s.option_name,
    s.additional_price
FROM "ProductOptionGroups" g
JOIN option_seed s ON s.group_name = g.name
WHERE NOT EXISTS (
    SELECT 1
    FROM "ProductOptions" po
    WHERE po.group_id = g.id
      AND po.name = s.option_name
);

COMMIT;
