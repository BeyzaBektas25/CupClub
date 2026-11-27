

BEGIN;

WITH price_list(product_name, base_price) AS (
    VALUES
    -- SICAK İÇECEKLER
    ('Siyah Çay', 65),
    ('Yeşil Çay', 70),
    ('Ihlamur', 75),
    ('Chai Latte', 130),
    ('Kuşburnu Çayı', 75),
    ('Meyve Çayı', 80),
    ('Türk Kahvesi', 100),
    ('Filtre Kahve', 110),
    ('Espresso', 90),
    ('Americano', 110),
    ('Latte', 130),
    ('Mocha', 145),
    ('Pumpkin Spice Latte', 160),
    ('Matcha Green Latte', 155),
    ('Salep', 130),
    ('Sıcak Çikolata', 135),

    -- SOĞUK İÇECEKLER
    ('Iced Americano', 120),
    ('Iced Latte', 140),
    ('Iced Mocha', 155),
    ('Cold Brew', 145),
    ('Frappuccino', 160),
    ('Limonlu Ice Tea', 115),
    ('Şeftalili Ice Tea', 115),
    ('Mangolu Ice Tea', 125),
    ('Iced Matcha Latte', 155),
    ('Strawberry Matcha Latte', 165),
    ('Berry Hibiscus', 130),
    ('Çilekli Milkshake', 145),
    ('Muzlu Milkshake', 140),
    ('Çikolatalı Milkshake', 150),
    ('Vanilyalı Milkshake', 140),
    ('Karamelli Milkshake', 150),
    ('Yaban Mersinli Milkshake', 160),
    ('Limonata', 105),
    ('Çilekli Limonata', 120),
    ('Karışık Meyve Suyu', 135),
    ('Portakal Suyu', 125),
    ('Şeftali Suyu', 115),
    ('Kayısı Suyu', 115),
    ('Vişne Suyu', 120),
    ('Sade Soda', 65),
    ('Limonlu Soda', 70),
    ('Sade Gazoz', 75),
    ('Portakallı Gazoz', 75),
    ('Kola', 80),
    ('Maden Suyu', 65),

    -- TATLILAR
    ('Orman Meyveli Cheesecake', 190),
    ('Limonlu Cheesecake', 180),
    ('Fıstıklı Cheesecake', 210),
    ('San Sebastian Cheesecake', 195),
    ('Havuçlu Kek', 130),
    ('Red Velvet Kek', 165),
    ('Mozaik Pasta', 135),
    ('Tiramisu', 175),
    ('Brownie', 145),
    ('Vişneli Brownie', 155),
    ('Fıstıklı Baklava', 215),
    ('Cevizli Baklava', 190),
    ('Fındıklı Baklava', 200),
    ('Soğuk Baklava', 205),
    ('Çikolatalı Waffle', 195),
    ('Çilekli-Muzlu Waffle', 210),
    ('Orman Meyveli Waffle', 220),
    ('Karamelli Waffle', 205),
    ('Magnolia', 145),
    ('Muhallebi', 120),
    ('Çikolatalı Puding', 125),
    ('Muzlu Puding', 125),
    ('Çilekli Puding', 130),
    ('Kazandibi', 130),
    ('Tavukgöğsü', 135),
    ('Elmalı Kurabiye', 90),
    ('Fındıklı Kurabiye', 100),
    ('Brownie Kurabiye', 105),
    ('Beyaz Çikolatalı Kurabiye', 105),
    ('Çikolata Parçalı Kurabiye', 100),
    ('Kakaolu Kurabiye', 90),
    ('Un Kurabiyesi', 85),

    -- ATIŞTIRMALIKLAR
    ('Kaşarlı Tost', 130),
    ('Sucuklu Tost', 150),
    ('Karışık Tost', 160),
    ('Soğuk Sandviç', 150),
    ('Simit', 55),
    ('Sade Poğaça', 60),
    ('Peynirli Poğaça', 65),
    ('Zeytinli Poğaça', 65),
    ('Patatesli Poğaça', 65)
)

UPDATE "BranchProducts" bp
SET "price" = pl.base_price +
    CASE
    WHEN b.name = 'CupClub Kadıköy Moda' THEN
        CASE
            WHEN c.name = 'Atıştırmalıklar' THEN 5
            WHEN c.name LIKE 'Sıcak İçecekler / %' THEN 5
            ELSE 10
        END

    WHEN b.name = 'CupClub Beşiktaş Çarşı' THEN
        CASE
            WHEN c.name = 'Atıştırmalıklar' THEN 10
            WHEN c.name LIKE 'Sıcak İçecekler / %' THEN 10
            WHEN c.name LIKE 'Soğuk İçecekler / %' THEN 12
            ELSE 15
        END
        WHEN b.name = 'CupClub Kadıköy Moda' THEN
            CASE
                WHEN c.name = 'Atıştırmalıklar' THEN 5
                WHEN c.name LIKE 'Sıcak İçecekler / %' THEN 5
                ELSE 10
            END

        WHEN b.name = 'CupClub Beşiktaş Çarşı' THEN
            CASE
                WHEN c.name = 'Atıştırmalıklar' THEN 10
                WHEN c.name LIKE 'Sıcak İçecekler / %' THEN 10
                WHEN c.name LIKE 'Soğuk İçecekler / %' THEN 12
                ELSE 15
            END

        ELSE 0
    END
FROM "Branches" b,
     "Products" p,
     "Categories" c,
     price_list pl
WHERE bp.branch_id = b.id
  AND bp.product_id = p.id
  AND p.category_id = c.id
  AND pl.product_name = p.name
  AND p.is_active = true;

COMMIT;
