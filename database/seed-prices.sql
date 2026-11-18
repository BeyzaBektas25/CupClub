
BEGIN;

WITH price_list(product_name, base_price) AS (
    VALUES
    -- SICAK İÇECEKLER
    ('Siyah Çay', 35),
    ('Yeşil Çay', 40),
    ('Ihlamur', 45),
    ('Chai Latte', 100),
    ('Kuşburnu Çayı', 45),
    ('Meyve Çayı', 50),
    ('Türk Kahvesi', 70),
    ('Filtre Kahve', 80),
    ('Espresso', 60),
    ('Americano', 80),
    ('Latte', 100),
    ('Mocha', 115),
    ('Pumpkin Spice Latte', 130),
    ('Matcha Green Latte', 125),
    ('Salep', 100),
    ('Sıcak Çikolata', 105),

    -- SOĞUK İÇECEKLER
    ('Iced Americano', 90),
    ('Iced Latte', 110),
    ('Iced Mocha', 125),
    ('Cold Brew', 115),
    ('Frappuccino', 130),
    ('Limonlu Ice Tea', 85),
    ('Şeftalili Ice Tea', 85),
    ('Mangolu Ice Tea', 95),
    ('Iced Matcha Latte', 125),
    ('Strawberry Matcha Latte', 135),
    ('Berry Hibiscus', 100),
    ('Çilekli Milkshake', 115),
    ('Muzlu Milkshake', 110),
    ('Çikolatalı Milkshake', 120),
    ('Vanilyalı Milkshake', 110),
    ('Karamelli Milkshake', 120),
    ('Yaban Mersinli Milkshake', 130),
    ('Limonata', 75),
    ('Çilekli Limonata', 90),
    ('Karışık Meyve Suyu', 105),
    ('Portakal Suyu', 95),
    ('Şeftali Suyu', 85),
    ('Kayısı Suyu', 85),
    ('Vişne Suyu', 90),
    ('Sade Soda', 35),
    ('Limonlu Soda', 40),
    ('Sade Gazoz', 45),
    ('Portakallı Gazoz', 45),
    ('Kola', 50),
    ('Maden Suyu', 35),

    -- TATLILAR
    ('Orman Meyveli Cheesecake', 160),
    ('Limonlu Cheesecake', 150),
    ('Fıstıklı Cheesecake', 180),
    ('San Sebastian Cheesecake', 165),
    ('Havuçlu Kek', 100),
    ('Red Velvet Kek', 135),
    ('Mozaik Pasta', 105),
    ('Tiramisu', 145),
    ('Brownie', 115),
    ('Vişneli Brownie', 125),
    ('Fıstıklı Baklava', 185),
    ('Cevizli Baklava', 160),
    ('Fındıklı Baklava', 170),
    ('Soğuk Baklava', 175),
    ('Çikolatalı Waffle', 165),
    ('Çilekli-Muzlu Waffle', 180),
    ('Orman Meyveli Waffle', 190),
    ('Karamelli Waffle', 175),
    ('Magnolia', 115),
    ('Muhallebi', 90),
    ('Çikolatalı Puding', 95),
    ('Muzlu Puding', 95),
    ('Çilekli Puding', 100),
    ('Kazandibi', 100),
    ('Tavukgöğsü', 105),
    ('Elmalı Kurabiye', 60),
    ('Fındıklı Kurabiye', 70),
    ('Brownie Kurabiye', 75),
    ('Beyaz Çikolatalı Kurabiye', 75),
    ('Çikolata Parçalı Kurabiye', 70),
    ('Kakaolu Kurabiye', 60),
    ('Un Kurabiyesi', 55),

     -- ATISTIRMALIKLAR
    ('Kaşarlı Tost', 100),
    ('Sucuklu Tost', 120),
    ('Karışık Tost', 130),
    ('Soğuk Sandviç', 120),
    ('Simit', 25),
    ('Sade Poğaça', 30),
    ('Peynirli Poğaça', 35),
    ('Zeytinli Poğaça', 35),
    ('Patatesli Poğaça', 35)
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
