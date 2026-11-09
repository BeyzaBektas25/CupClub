# 💻 CUPCLUB — WEB PANELLERİ UYGULAMA REHBERİ (BURCU)

Merhaba Burcu! Backend (NestJS) sunucumuz ve PostgreSQL veritabanımız (3 şube, 60 ürün, kampanya ve güvenlik kuralları) tamamen hazır ve GitHub'da. Senin görevin **Şube Personeli Sipariş Ekranı** ile **Merkez Yönetim ve Rapor Panellerini** (React + TypeScript) geliştirmek.

---

## 🛠️ 1. GÜN: Kurulum ve Ortam Hazırlığı

1. Bilgisayarına şu 4 programı kur:
   * [GitHub Desktop](https://github.com)
   * [Visual Studio Code](https://visualstudio.com)
   * [Node.js (LTS Sürümü)](https://nodejs.org)
   * [Docker Desktop](https://docker.com)
2. **GitHub Desktop** uygulamasını aç ve Beyza'nın paylaştığı **`CupClub`** deposunu bilgisayarına indir (**Clone Repository**).
3. Önce arka planda veritabanımızı ve API sunucumuzu çalıştır (VS Code üst menüden **Terminal -> New Terminal** aç):
   * **1. Terminal (`CupClub` ana klasöründe):**
     ```bash
     docker-compose up -d
     ```
   * **2. Terminal (`backend` klasörüne girerek):**
     ```bash
     cd backend
     npm install
     npm run start:dev
     ```
   *(Kontrol: Tarayıcıda `http://localhost:3000/swagger` adresine girdiğinde API listesini görüyorsan her şey hazır demektir).*

---

## 🚀 2. GÜN: Web Projesini Oluşturma (`apps/web`)

Yeni bir terminal aç, en dış ana klasörde (`CupClub`) olduğundan emin ol ve sırasıyla şu komutları çalıştır:

```bash
mkdir apps
cd apps
npm create vite@latest web -- --template react-ts
cd web
npm install axios socket.io-client
npm run dev
```
* Tarayıcıda çıkan **`http://localhost:5173`** adresine tıkla; ilk React uygulaman açıldı!

---

## ⚡ 3. GÜN: İlk Çalışan Ekran (Şube Sipariş Kuyruğu — API Bağlantılı)

API mantığı çok basittir: `axios` ile Beyza'nın sunucusundan veriyi çeker, ekranda listeleriz.
`apps/web/src/App.tsx` dosyasının içindeki her şeyi sil, aşağıdaki kodu yapıştır ve **`Ctrl + S`** ile kaydet:

```tsx
import { useEffect, useState } from 'react';
import axios from 'axios';

export default function App() {
  const [orders, setOrders] = useState<any[]>([]);
  const branchId = 1; // 1: Kadıköy Şubesi

  // Beyza'nın API'sinden Kadıköy şubesinin siparişlerini çeker
  const fetchOrders = async () => {
    try {
      const res = await axios.get(`http://localhost:3000/api/branches/${branchId}/orders`, {
        headers: {
          'x-user-role': 'BRANCH_STAFF',
          'x-branch-id': '1',
        },
      });
      setOrders(res.data);
    } catch (err) {
      alert('Siparişler çekilirken hata oluştu! Backend açık mı?');
    }
  };

  // Sipariş durumunu günceller
  const updateStatus = async (orderId: number, newStatus: string) => {
    await axios.patch(
      `http://localhost:3000/api/orders/${orderId}/status`,
      { branchId, status: newStatus },
      {
        headers: {
          'x-user-role': 'BRANCH_STAFF',
          'x-branch-id': '1',
        },
      },
    );
    fetchOrders();
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  return (
    <div style={{ padding: '30px', fontFamily: 'sans-serif', maxWidth: '800px', margin: '0 auto' }}>
      <h1>☕ CupClub — Kadıköy Şube Sipariş Ekranı</h1>
      <button onClick={fetchOrders} style={{ marginBottom: '20px', padding: '10px 15px', cursor: 'pointer' }}>
        🔄 Siparişleri Yenile
      </button>

      {orders.length === 0 && <p>Henüz bekleyen sipariş yok.</p>}

      {orders.map((order) => (
        <div key={order.id} style={{ border: '1px solid #ddd', padding: '15px', marginBottom: '12px', borderRadius: '8px' }}>
          <h3>Sipariş No: {order.order_number} — Tutar: {order.final_amount} TL</h3>
          <p>Mevcut Durum: <strong>{order.status}</strong></p>
          <div style={{ display: 'flex', gap: '10px' }}>
            <button onClick={() => updateStatus(order.id, 'Accepted')}>✅ Kabul Et</button>
            <button onClick={() => updateStatus(order.id, 'Preparing')}>🔥 Hazırlanıyor</button>
            <button onClick={() => updateStatus(order.id, 'Ready')}>🔔 Hazır!</button>
            <button onClick={() => updateStatus(order.id, 'Delivered')}>📦 Teslim Edildi</button>
          </div>
        </div>
      ))}
    </div>
  );
}
```

---

## 📅 Kalan Haftalık Görev Planın

| Hafta / Gün | Yapılacak Ekran / Özellik | Kullanılacak API Adresi (Endpoint) |
| :--- | :--- | :--- |
| **1. Hafta** | Personel / Yönetici Giriş Ekranı | `POST http://localhost:3000/api/auth/login` |
| **2. Hafta** | Şube Sipariş Kuyruğu ve Durum Güncelleme | `GET /api/branches/{branchId}/orders` & `PATCH /api/orders/{orderId}/status` |
| **2. Hafta** | Müşteri Ödül QR Kodu Doğrulama Ekranı | `POST http://localhost:3000/api/loyalty/qr/consume` |
| **3. Hafta** | Aktif Kampanyaları Görüntüleme Ekranı | `GET http://localhost:3000/api/campaigns` |
| **4. Hafta** | Merkez Yönetim Şube Satış ve Ciro Raporu | `GET http://localhost:3000/api/admin/reports/branch-sales` |

### ⚠️ GitHub Çalışma Kuralları
* Sadece **`apps/web`** klasörünün içinde çalış. `backend/` veya `database/` klasörlerine dokunma.
* Her gün işin bittiğinde GitHub Desktop üzerinden **Commit & Push** yapmayı unutma.
