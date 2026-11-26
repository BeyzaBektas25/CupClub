# CupClub — Yazılım Mimarisi ve Tasarım Raporu

## 1. Genel Mimari Yaklaşım (Modüler Monolit)
CupClub; müşteri mobil uygulaması (Flutter), şube/merkez yönetim panelleri (React + TypeScript) ve merkezi backend servisinden (NestJS + TypeORM) oluşan **Modüler Monolit** mimaride tasarlanmıştır. Tüm iş alanları gevşek bağlı (loosely coupled) modüllere ayrılmıştır:
* `AuthModule`: JWT kimlik doğrulama, rol yönetimi (`CUSTOMER`, `BRANCH_STAFF`, `CENTRAL_ADMIN`) ve `BranchAccessGuard` ile şube bazlı erişim kontrolü.
* `BranchesModule`: Şube bilgileri, çalışma saatleri ve aktiflik yönetimi.
* `CatalogModule`: Kategoriler, ürünler, ürün seçenek grupları (`ProductOptionGroup`) ve şube bazlı fiyat/stok (`BranchProduct`, `BranchOptionPrice`) yönetimi.
* `OrdersModule`: Sunucu taraflı sepet fiyat hesaplama, durum makinesi (`OrderStateMachine`) ve WebSocket (`OrdersGateway`) bildirimleri.
* `CampaignsModule`: Strateji tabanlı kampanya değerlendirme, öncelik ve kupon kullanım limiti yönetimi.
* `LoyaltyModule`: Puan/damga kazanımı (`EARN`), iptal durumunda ters kayıt iadesi (`REVERSAL`) ve tek kullanımlık QR ödül doğrulama.
* `ReportsModule`: Şube bazlı satış ve operasyonel özet raporları.

## 2. Tasarım Desenleri (Design Patterns) ve Kod Karşılıkları

### A. State Pattern (Durum Tasarım Deseni)
* **Dosya:** `backend/src/orders/order-state.machine.ts` (`OrderStateMachine`)
* **Kullanım Amacı:** Bir siparişin yaşam döngüsündeki durum geçişlerini (`Pending -> Accepted -> Preparing -> Ready -> Delivered`) koruma altına almak. Kabul edilmemiş (`Pending`) bir siparişin doğrudan `Delivered` durumuna atlanmasını veya tamamlanmış siparişlerin değiştirilmesini sunucu seviyesinde engeller.

### B. Strategy Pattern (Strateji Tasarım Deseni)
* **Dosya:** `backend/src/campaigns/campaign.strategies.ts` (`CampaignStrategyFactory`)
* **Kullanım Amacı:** 5 farklı kampanya türünü (`PercentageDiscountStrategy`, `FixedAmountStrategy`, `ComboDiscountStrategy`, `FreeItemStrategy`, `FirstOrderStrategy`) karmaşık `if-else` blokları yerine ayrı strateji sınıfları olarak soyutlamak.

### C. Observer Pattern (Gözlemci Tasarım Deseni)
* **Dosya:** `backend/src/orders/orders.gateway.ts` (`OrdersGateway`)
* **Kullanım Amacı:** Şube personeli sipariş durumunu güncellediğinde (`updateStatus`), ilgili şube ve sipariş odasına abone olan müşteri mobil ekranına WebSocket (`Socket.IO`) üzerinden anlık bildirim yayınlamak.

## 3. SOLID Prensipleri Uygulaması
* **Single Responsibility (Tek Sorumluluk):** `OrdersService` sipariş yaşam döngüsünü, `CampaignsService` indirim kurallarını, `LoyaltyService` ise sadakat hareketlerini tek sorumlulukla yönetir.
* **Open/Closed (Açık/Kapalı):** Yeni bir kampanya stratejisi eklendiğinde `CampaignStrategy` arayüzünü uygulayan yeni bir sınıf eklenir; `OrdersService` veya mevcut hesaplama akışı değiştirilmez.
* **Liskov Substitution (Liskov Yerine Geçme):** Tüm kampanya stratejileri (`PercentageDiscountStrategy`, `FixedAmountStrategy` vb.) `CampaignStrategy` arayüz sözleşmesini bozmadan birbirinin yerine çalışır.
* **Interface Segregation (Arayüz Ayrımı):** İstemciler ihtiyaç duymadıkları verilere zorlanmaz; mobil katalog `BranchProduct` verisini tüketirken, şube personeli yalnızca kendi şubesine ait sipariş arayüzlerini kullanır.
* **Dependency Inversion (Bağımlılığın Tersine Çevrilmesi):** Controller ve servis sınıfları somut veritabanı bağlantılarına değil, NestJS Dependency Injection (DI) konteyneri üzerinden enjekte edilen soyut Repository ve servis arayüzlerine bağımlıdır.

## 4. Kullanılan Dış Kaynaklar ve Kütüphaneler
* **Backend:** `@nestjs/common`, `@nestjs/core`, `@nestjs/typeorm`, `@nestjs/jwt`, `@nestjs/passport`, `@nestjs/swagger`, `@nestjs/websockets`, `typeorm`, `pg`, `bcrypt`, `socket.io`, `jest`.
* **Web Paneli:** `react`, `typescript`, `vite`, `tailwindcss`, `axios`.
* **Mobil Uygulama:** `flutter`, `dart`, `http`/`dio`, `socket_io_client`.
