# 🧪 CupClub — Test Planı ve Birim Test (Unit Test) Raporu

## 1. Test Yaklaşımı ve Kapsam
Sistemin kritik iş kuralları (sunucu taraflı fiyat doğrulama, kampanya indirimi ve kupon limiti kontrolü, şube bazlı erişim güvenliği ve WebSocket gerçek zamanlı bildirim tetiklemesi) **Jest** ve **@nestjs/testing** altyapısı kullanılarak izole birim testleriyle doğrulanmıştır.

## 2. Test Senaryoları ve Beklenen Sonuçlar

| Test Modülü | Test Senaryosu | Beklenen Davranış | Durum |
| :--- | :--- | :--- | :--- |
| `CampaignsService` | 200 TL üzeri sepette %20 indirim kampanyası | Sepet tutarı 250 TL iken 50 TL indirim hesaplanır, net tutar 200 TL döner. | ✅ PASS |
| `CampaignsService` | Kullanım limiti dolmuş kupon kodu girişi | İşlem reddedilir ve `BadRequestException` fırlatılır. | ✅ PASS |
| `OrdersService` | Boş sepetle sipariş oluşturma denemesi | Geçersiz istek reddedilir ve `BadRequestException` fırlatılır. | ✅ PASS |
| `OrdersService` | Şubede stokta olmayan (`is_in_stock: false`) ürün siparişi | Sipariş engellenir ve `BadRequestException` fırlatılır. | ✅ PASS |
| `OrdersService` | Başka şube personelinin sipariş durumunu değiştirme denemesi | Yetkisiz erişim engellenir ve `403 ForbiddenException` fırlatılır. | ✅ PASS |
| `OrdersService` | Yetkili şube personelinin sipariş durumunu güncellemesi | Sipariş durumu güncellenir ve `OrdersGateway` üzerinden WebSocket bildirimi yayınlanır. | ✅ PASS |
| `OrdersGateway` | WebSocket ağ geçidi başlatma ve bağlantı kontrolü | Socket.IO sunucu bileşeni hatasız tanımlanır. | ✅ PASS |

## 3. Terminal Test Çıktısı (Jest Runner)

```text
> backend@0.0.1 test
> node --experimental-vm-modules ./node_modules/jest/bin/jest.js

 PASS  src/app.controller.spec.ts
 PASS  src/orders/orders.gateway.spec.ts
 PASS  src/campaigns/campaigns.service.spec.ts
 PASS  src/orders/orders.service.spec.ts

Test Suites: 4 passed, 4 total
Tests:       10 passed, 10 total
Snapshots:   0 total
Time:        1.419 s
Ran all test suites.
```
