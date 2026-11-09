# 📱 CUPCLUB — MÜŞTERİ MOBİL UYGULAMA REHBERİ (NALAN)

Merhaba Nalan! Backend (NestJS) sunucumuz ve PostgreSQL veritabanımız (3 şube, 60 ürün, özelleştirme seçenekleri, kampanya ve QR sadakat sistemi) tamamen hazır ve GitHub'da. Senin görevin müşterinin kahve siparişi verdiği **Flutter Mobil Uygulamasını** geliştirmek.

---

## 🛠️ 1. GÜN: Kurulum ve Ortam Hazırlığı

1. Bilgisayarına şu programları kur:
   * [GitHub Desktop](https://github.com)
   * [Visual Studio Code](https://visualstudio.com)
   * [Docker Desktop](https://docker.com)
   * [Flutter SDK](https://flutter.dev) ve [Android Studio](https://android.com) (Android Emulator için)
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

## 🚀 2. GÜN: Flutter Projesini Oluşturma (`apps/mobile`)

1. Android Studio'dan sanal telefonu (**Emulator**) başlat *(veya kendi Android telefonunu USB ile bağla)*.
2. Yeni bir terminal aç, `CupClub/apps` klasörünün içine girip Flutter projesini oluştur:

```bash
cd apps
flutter create mobile
cd mobile
flutter pub add http socket_io_client
flutter run
```

---

## ⚡ 3. GÜN: İlk Çalışan Ekran (Şube Seçimi ve 60 Ürünü Listeleme)

**Çok Önemli Teknik Not:** Android Emülatör bilgisayardaki `localhost` adresine **`http://10.0.2`** üzerinden bağlanır.
`apps/mobile/lib/main.dart` dosyasının içindeki her şeyi sil, aşağıdaki kodu yapıştır ve **`Ctrl + S`** ile kaydet:

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: CupClubHome()));

class CupClubHome extends StatefulWidget {
  const CupClubHome({super.key});
  @override
  State<CupClubHome> createState() => _CupClubHomeState();
}

class _CupClubHomeState extends State<CupClubHome> {
  List branches = [];
  List products = [];
  int selectedBranchId = 1;

  // Beyza'nın API'sinden 3 şubeyi çeker
  Future<void> fetchBranches() async {
    final res = await http.get(Uri.parse('http://10.0.2/branches'));
    if (res.statusCode == 200) {
      setState(() => branches = jsonDecode(res.body));
    }
  }

  // Seçilen şubeye özel fiyat ve stok bilgisiyle 60 ürünü çeker
  Future<void> fetchProducts(int branchId) async {
    final res = await http.get(Uri.parse('http://10.0.2/branches/\$branchId/products'));
    if (res.statusCode == 200) {
      setState(() {
        selectedBranchId = branchId;
        products = jsonDecode(res.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBranches();
    fetchProducts(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('☕ CupClub Mobil Sipariş'), backgroundColor: Colors.brown),
      body: Column(
        children: [
          // Şube Seçim Butonları
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: branches.map((b) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedBranchId == b['id'] ? Colors.brown : Colors.grey[300],
                    foregroundColor: selectedBranchId == b['id'] ? Colors.white : Colors.black,
                  ),
                  onPressed: () => fetchProducts(b['id']),
                  child: Text(b['name']),
                ),
              )).toList(),
            ),
          ),
          // Şubeye Özel Ürün Listesi
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                final prod = item['product'];
                final bool inStock = item['is_in_stock'] ?? true;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(prod['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\({prod['allergens'] ?? ''}\n\){inStock ? "Stokta Var" : "❌ Tükendi"}'),
                    trailing: Text('\${item['price']} TL', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📅 Kalan Haftalık Görev Planın

| Hafta / Gün | Yapılacak Ekran / Özellik | Kullanılacak API Adresi (`10.0.2.2:3000/api`) |
| :--- | :--- | :--- |
| **1. Hafta** | Müşteri Kayıt ve Giriş Ekranları | `POST /api/auth/register` & `POST /api/auth/login` |
| **2. Hafta** | Şube Seçimi, Katalog ve Ürün Özelleştirme | `GET /api/branches/{id}/products` & `GET /api/products/{id}/options` |
| **2. Hafta** | Sepet ve Gel-Al Sipariş Gönderme | `POST /api/orders` |
| **3. Hafta** | Sepette Kampanya / Kupon İndirimi Hesaplama | `POST /api/campaigns/evaluate` |
| **3. Hafta** | Sadakat Puanları ve Tek Kullanımlık QR Üretme | `GET /api/loyalty/{userId}` & `POST /api/loyalty/qr/generate/{userId}` |

### ⚠️ GitHub Çalışma Kuralları
* Sadece **`apps/mobile`** klasörünün içinde çalış. `backend/` veya `database/` klasörlerine dokunma.
* Her gün işin bittiğinde GitHub Desktop üzerinden **Commit & Push** yapmayı unutma.
