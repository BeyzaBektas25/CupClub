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



## 4. Nesne Yönelimli Tasarım ve SOLID Prensipleri

Projede SOLID prensipleri şu somut sınıflar ve modüller üzerinden uygulanmıştır:

* **Single Responsibility Principle (Tek Sorumluluk Prensibi):** Her iş alanı bağımsız NestJS modüllerine ayrılmıştır (`OrdersService` yalnızca sipariş yaşam döngüsünden, `CampaignsService` indirim ve çakışma kurallarından, `LoyaltyService` ise puan/QR işlemlerinden sorumludur).
* **Open/Closed Principle (Açık/Kapalı Prensibi):** Kampanya motoru (`CampaignsService`), yeni bir kampanya türü (`PERCENTAGE`, `FIXED_AMOUNT` vb.) eklendiğinde mevcut sipariş akışını değiştirmeden kural tablosu (`CampaignRules`) üzerinden genişletilebilir yapıdadır.
* **Liskov Substitution Principle (Liskov Yerine Geçme Prensibi):** Tüm veri varlıkları (Entity) ve DTO doğrulama sınıfları ortak tip sözleşmelerini bozmadan servis katmanında birbirinin yerine kullanılabilir.
* **Interface Segregation Principle (Arayüz Ayrımı Prensibi):** İstemciler ihtiyaç duymadıkları verilere zorlanmaz; mobil uygulama katalog için `BranchProduct` DTO'larını kullanırken, şube personeli yalnızca kendi şubesine ait sipariş arayüzlerini tüketir.
* **Dependency Inversion Principle (Bağımlılığın Tersine Çevrilmesi):** Controller sınıfları doğrudan veritabanı sorgularına değil, NestJS Dependency Injection (DI) konteyneri üzerinden enjekte edilen soyut servislere (`OrdersService`, `AuthService`) bağımlıdır.



## 5. Mimari Karar Kayıtları (ADR - Architectural Decision Records)

### ADR-001: Mikroservis Yerine Modüler Monolit Mimarisi
* **Karar:** Sistem tek bir NestJS backend uygulaması içinde modüler monolit olarak tasarlanmıştır.
* **Gerekçe:** Sipariş oluşturma, stok kontrolü, kupon tüketimi ve sadakat puanı kazanımı aynı veritabanı transaction sınırı içinde atomik olarak yürütülmelidir. Dağıtık işlem (Saga/2PC) karmaşıklığından kaçınılmıştır.

### ADR-002: İlişkisel Veritabanı Olarak PostgreSQL Seçimi
* **Karar:** Veritabanı katmanında PostgreSQL 15 kullanılmıştır.
* **Gerekçe:** Finansal tutarların (`decimal(10,2)`) kayıpsız saklanması, şube-ürün benzersizlik kısıtları (`UNIQUE INDEX`) ve 27 tablo arasındaki sıkı Foreign Key bütünlüğü ilişkisel veritabanı gerektirmiştir.

### ADR-003: Gerçek Zamanlı İletişim İçin Socket.IO (WebSocket)
* **Karar:** Sipariş durum değişikliklerinin iletimi için HTTP Polling yerine Socket.IO (`OrdersGateway`) tercih edilmiştir.
* **Gerekçe:** Şube personeli sipariş durumunu `Preparing` veya `Ready` yaptığında müşteri mobil ekranının sunucuyu sürekli sorgulamasına gerek kalmadan anında güncellenmesi sağlanmıştır.



## 6. Kullanılan Dış Kaynaklar ve Kütüphaneler
* **Backend:** NestJS (`@nestjs/common`, `@nestjs/typeorm`, `@nestjs/jwt`, `@nestjs/swagger`, `@nestjs/websockets`), TypeORM, PostgreSQL (`pg`), `bcrypt`, `socket.io`.
* **Web Paneli:** React, TypeScript, Vite, Tailwind CSS, Axios.
* **Mobil Uygulama:** Flutter SDK, Dart, `http`/`dio`, `socket_io_client`.
