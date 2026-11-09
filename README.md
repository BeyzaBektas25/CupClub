# ☕ CupClub — Çok Şubeli Mobil Sipariş, Kampanya ve Sadakat Platformu

CupClub; çok şubeli tek bir kahve/içecek markası için geliştirilmiş müşteri mobil siparişi (gel-al), şube sipariş yönetimi, merkez yönetim paneli, çakışma kontrollü kampanya motoru ve QR destekli sadakat platformudur.

---

## 👥 Ekip ve Görev Dağılımı

| Ekip Üyesi | Departman / Sorumluluk | Teknoloji Yığını | Çalışma Dizini |
| :--- | :--- | :--- | :--- |
| **Beyza Bektaş** | Teknik Lider, Backend, Veritabanı ve Mimari | NestJS, TypeScript, TypeORM, PostgreSQL, Docker, Socket.IO | `backend/`, `database/` |
| **Burcu** | Web ve Yönetim Sistemleri (Şube & Merkez Panelleri) | React, TypeScript, Vite, Tailwind CSS | `apps/web/` |
| **Nalan** | Mobil Uygulama ve Müşteri Deneyimi | Flutter, Dart | `apps/mobile/` |

---

## 🏗️ Yazılım Mimarisi

Proje **Modüler Monolit** mimari ile tasarlanmıştır. Tüm iş kuralları (sunucu taraflı fiyat doğrulama, kampanya önceliği/çakışma kontrolü, atomik kupon tüketimi ve sadakat hareketleri) tek bir veritabanı transaction sınırında güvence altına alınmıştır.

* **Backend Modülleri:** `Auth`, `Branches`, `Catalog`, `Orders`, `Campaigns`, `Loyalty`, `Reports`
* **Tasarım Desenleri:** State (Sipariş durum geçişleri), Strategy & Specification (Kampanya kuralları ve indirim hesaplama), Observer (WebSocket/Socket.IO gerçek zamanlı bildirimler), Guard (Şube bazlı erişim kontrolü)

---

## 🚀 Kurulum ve Çalıştırma Adımları

### Gereksinimler
* [Docker Desktop](https://docker.com)
* [Node.js (LTS)](https://nodejs.org)
* [Flutter SDK](https://flutter.dev) *(Mobil geliştirme için)*

### 1. Veritabanını Ayağa Kaldırma (PostgreSQL + Seed Veriler)
Proje ana dizininde terminali açın ve aşağıdaki komutu çalıştırın. Bu komut PostgreSQL 15 veritabanını **5433** portunda başlatır ve otomatik olarak **3 şube, 60 ürün, özelleştirme seçenekleri, kampanyalar ve roller** ile doldurur:

```bash
docker-compose up -d
```

### 2. Backend Sunucusunu (NestJS API) Başlatma
Yeni bir terminal açarak `backend` klasörüne geçin ve sunucuyu başlatın:

```bash
cd backend
npm install
npm run start:dev
```

* **API Base URL:** `http://localhost:3000/api`
* **Swagger / OpenAPI Dokümantasyonu:** [http://localhost:3000/swagger](http://localhost:3000/swagger)

### 3. Web Panellerini Çalıştırma (React)
```bash
cd apps/web
npm install
npm run dev
```

### 4. Mobil Uygulamayı Çalıştırma (Flutter)
```bash
cd apps/mobile
flutter pub get
flutter run
```
*(Not: Android Emülatör üzerinden yerel sunucuya bağlanırken API adresi olarak `http://10.0.2` kullanılmalıdır).*

---

## 🧪 Demo Hesapları ve Test Bilgileri

* **Örnek Şube Personeli (Kadıköy Şubesi - ID: 1):**
  * **E-posta:** `kadikoy.personel@cupclub.com`
  * **Şifre:** `123456`
  * **Yetki Kuralı:** `x-user-role: BRANCH_STAFF` ve `x-branch-id: 1` başlıklarıyla yalnızca 1 numaralı şubenin siparişlerini yönetebilir; diğer şubelere erişim denemesi `403 Forbidden` döner.
* **Örnek Kupon Kodu:** `WELCOME20` *(200 TL ve üzeri sepetlerde %20 indirim uygular)*

---

## 📁 Depo Klasör Yapısı

```text
CupClub/
├── apps/
│   ├── mobile/             # Müşteri mobil uygulaması (Flutter)
│   └── web/                # Şube personeli ve merkez yönetim panelleri (React)
├── backend/                # Modüler Monolit REST API ve WebSocket sunucusu (NestJS)
├── database/
│   └── init.sql            # 27 tablolu ilişkisel şema ve başlangıç (seed) verileri
├── docs/                   # Mimari kararlar, UML ve ERD diyagramları
└── docker-compose.yml      # Tek komutla PostgreSQL kurulum yapılandırması
```
