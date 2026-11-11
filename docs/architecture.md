# 🏛️ CupClub — Yazılım Mimarisi ve Teknik Karar Dokümanı

## 1. Mimari Yaklaşım: Modüler Monolit (Modular Monolith)
CupClub sunucu katmanı **NestJS (TypeScript)** üzerinde **Modüler Monolit** mimarisiyle inşa edilmiştir.
* **Gerekçe:** Sipariş oluşturma, kupon tüketimi ve sadakat puanı yazımı gibi işlemlerin aynı veritabanı transaction sınırı içinde atomik olarak yürütülmesi ve dağıtık sistem karmaşıklığından kaçınılması hedeflenmiştir.
* **Modüller:** `Auth` (Kimlik & Rol), `Branches` (Şubeler), `Catalog` (Ürün & Şube Fiyatları), `Orders` (Sepet & Sipariş), `Campaigns` (Kampanya & Kupon), `Loyalty` (Puan & QR Ödül), `Reports` (Raporlama).

## 2. Uygulanan Tasarım Desenleri (Design Patterns)
* **State Pattern (Sipariş Durum Makinesi):** Siparişler yalnızca tanımlı yaşam döngüsü (`Pending -> Accepted -> Preparing -> Ready -> Delivered`) üzerinden ilerler.
* **Strategy & Specification Pattern (Kampanya Motoru):** Yüzdesel (`PERCENTAGE`) ve sabit tutar (`FIXED_AMOUNT`) indirim stratejileri öncelik (`priority`), minimum sepet tutarı (`min_cart_amount`) ve birleşebilirlik (`can_combine`) kurallarına göre değerlendirilir.
* **Observer Pattern (Gerçek Zamanlı Bildirimler):** Sipariş durumu güncellendiğinde `OrdersGateway` (Socket.IO) üzerinden hem şube ekranına hem müşteri uygulamasına anlık olay (event) yayınlanır.
* **Guard / Policy Pattern (Güvenlik):** `BranchAccessGuard` her istekte kullanıcının rolünü ve `branch_id` yetkisini doğrular; yetkisiz şube erişimlerini `403 Forbidden` ile engeller.

## 3. Veri Bütünlüğü ve Güvenlik Kararları
* **Sunucu Taraflı Fiyat Doğrulama:** İstemciden (mobil/web) gelen ürün fiyatlarına güvenilmez; tüm tutarlar `BranchProducts` tablosundan sunucuda yeniden hesaplanır.
* **Değiştirilemez Sadakat Defteri:** `LoyaltyTransactions` geçmişi silinmez; iptal edilen siparişlerde `REVERSAL` tipinde ters kayıt oluşturulur.
* **Tek Kullanımlık QR Ödül:** `RewardQRs` tablosunda üretilen token'lar süreli (`expires_at`) ve tek kullanımlıktır (`is_used`).
