# 📊 CupClub — Veritabanı (ER) ve Sistem Akış (UML) Diyagramları

## 1. Varlık-İlişki Diyagramı (ER Diagram)

```mermaid
erDiagram
    Users ||--o{ UserRoles : "sahiptir"
    Roles ||--o{ UserRoles : "atanir"
    Branches ||--o{ UserRoles : "gorev_yeri"
    Categories ||--o{ Products : "icerir"
    Branches ||--o{ BranchProducts : "fiyat_stok_tutar"
    Products ||--o{ BranchProducts : "subede_satilir"
    Products ||--o{ ProductOptionGroups : "secenek_grubu"
    ProductOptionGroups ||--o{ ProductOptions : "secenekler"
    Users ||--o{ Orders : "siparis_verir"
    Branches ||--o{ Orders : "siparisi_alir"
    Orders ||--o{ OrderItems : "kalemleri"
    Products ||--o{ OrderItems : "urun_detayi"
    Campaigns ||--o{ CampaignRules : "kurallari"
    Campaigns ||--o{ Coupons : "kupon_uretir"
    Users ||--|| LoyaltyAccounts : "sadakat_hesabi"
    LoyaltyAccounts ||--o{ LoyaltyTransactions : "puan_hareketleri"
    Users ||--o{ RewardQRs : "odul_qr_kodu"
```

## 2. Uçtan Uca Sipariş ve Canlı Bildirim Akışı (Sequence Diagram)

```mermaid
sequenceDiagram
    actor Musteri as Müşteri (Flutter)
    participant API as Backend API (NestJS)
    participant DB as PostgreSQL
    participant WS as WebSocket (Socket.IO)
    actor Personel as Şube Personeli (React)

    Musteri->>API: POST /api/orders (Şube, Ürünler)
    API->>DB: Şube fiyatını ve stok durumunu doğrula
    DB-->>API: Güncel fiyatlar ve stok onayı
    API->>DB: Siparişi 'Pending' olarak kaydet
    API-->>Musteri: 201 Created (Sipariş No: CC-XXXXXX)
    Personel->>API: GET /api/branches/{id}/orders (BranchAccessGuard)
    API-->>Personel: Şubeye ait bekleyen siparişler
    Personel->>API: PATCH /api/orders/{id}/status ('Ready')
    API->>DB: Durumu güncelle
    API->>WS: Olay yayınla (order-status-{id})
    WS-->>Musteri: Anlık Bildirim: "Siparişiniz Hazır!"
```
## 3. Sınıf Diyagramı (Class Diagram - Domain & Servis Yapısı)

```mermaid
classDiagram
    class User {
        +int id
        +string first_name
        +string last_name
        +string email
        +string password_hash
    }
    class Branch {
        +int id
        +string name
        +string address
        +boolean is_active
    }
    class Product {
        +int id
        +int category_id
        +string name
        +decimal base_price
        +boolean is_active
    }
    class BranchProduct {
        +int id
        +int branch_id
        +int product_id
        +decimal price
        +boolean is_in_stock
    }
    class Order {
        +int id
        +string order_number
        +int user_id
        +int branch_id
        +string status
        +decimal total_amount
        +decimal discount_amount
        +decimal final_amount
        +updateStatus(newStatus)
    }
    class OrderItem {
        +int id
        +int order_id
        +int product_id
        +int quantity
        +decimal unit_price
    }
    class Campaign {
        +int id
        +string title
        +string campaign_type
        +int priority
        +boolean can_combine
        +decimal min_cart_amount
    }
    class LoyaltyAccount {
        +int id
        +int user_id
        +int total_points
        +int total_stamps
    }

    User "1" --> "*" Order : verir
    Branch "1" --> "*" Order : alir
    Branch "1" --> "*" BranchProduct : fiyat_stok_tutar
    Product "1" --> "*" BranchProduct : subede_satilir
    Order "1" *-- "*" OrderItem : icerir
    Product "1" <-- "*" OrderItem : urun_detayi
    User "1" -- "1" LoyaltyAccount : sadakat_hesabi
```

## 4. Kullanım Senaryosu Diyagramı (Use Case Diagram)

```mermaid
flowchart LR
    Musteri((Müşteri - Mobil))
    Personel((Şube Personeli - Web))
    Yonetici((Merkez Yönetici - Web))

    subgraph CupClub Sistemi
        UC1[Kayıt Ol / Giriş Yap]
        UC2[Şube Seç ve Menü Görüntüle]
        UC3[Ürün Özelleştir ve Sepete Ekle]
        UC4[Kupon Uygula ve Sipariş Ver]
        UC5[Canlı Sipariş Durumu Takip Et]
        UC6[QR Ödül Oluştur ve Puan Gör]
        UC7[Şube Sipariş Kuyruğunu Yönet]
        UC8[QR Ödül Doğrula ve Tüket]
        UC9[Şube Bazlı Fiyat ve Stok Güncelle]
        UC10[Kampanya Tanımla ve Raporları Gör]
    end

    Musteri --- UC1
    Musteri --- UC2
    Musteri --- UC3
    Musteri --- UC4
    Musteri --- UC5
    Musteri --- UC6

    Personel --- UC1
    Personel --- UC7
    Personel --- UC8

    Yonetici --- UC1
    Yonetici --- UC9
    Yonetici --- UC10
```
