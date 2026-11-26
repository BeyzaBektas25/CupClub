# CupClub — Mimari Karar Kayıtları (ADR)

## ADR-001: Mikroservis Yerine Modüler Monolit Mimarisi Seçimi
* **Durum:** Kabul Edildi
* **Bağlam:** Sistemde sipariş oluşturma, şube stok kontrolü, kupon kullanım limiti artırma ve sadakat puanı hareketleri birbirine sıkı bağlı iş adımlarıdır.
* **Karar:** Backend uygulaması tek bir NestJS projesi içerisinde alan bazlı bağımsız modüller (`OrdersModule`, `CampaignsModule`, `LoyaltyModule` vb.) olarak yapılandırılmıştır.
* **Sonuçlar:** Dağıtık transaction (Saga / Two-Phase Commit) karmaşıklığından kaçınılmış, veri tutarlılığı tek veritabanı sınırı içinde garanti altına alınmış ve geliştirme/dağıtım hızı artırılmıştır.

## ADR-002: İlişkisel Veritabanı Olarak PostgreSQL Seçimi
* **Durum:** Kabul Edildi
* **Bağlam:** Çok şubeli fiyatlandırma, zorunlu/isteğe bağlı ürün varyantları, kampanya kuralları ve değiştirilemez sadakat hareketleri arasında güçlü ilişkisel bütünlük gereklidir.
* **Karar:** Veritabanı katmanında PostgreSQL kullanılmış ve 27 tabloluk şema Foreign Key kısıtları ile korunmuştur. Finansal tutarlar için `decimal(10,2)` veri tipi zorunlu tutulmuştur.
* **Sonuçlar:** Kuruş kaybı önlenmiş ve şube-ürün eşleşmelerinde `UNIQUE INDEX` ile veri tekrarı engellenmiştir.

## ADR-003: Sunucu Taraflı Fiyat ve İndirim Doğrulaması
* **Durum:** Kabul Edildi
* **Bağlam:** Mobil ve web istemcilerden gelen sepet isteklerinde fiyat veya indirim manipülasyonu riski bulunmaktadır.
* **Karar:** İstemciden yalnızca `productId`, `quantity`, `optionIds` ve `couponCode` bilgileri alınır; tüm ürün fiyatları (`BranchProduct`), seçenek farkları (`BranchOptionPrice`) ve kampanya indirimleri sunucu tarafında (`OrdersService` ve `CampaignsService`) hesaplanır.
* **Sonuçlar:** İstemci kaynaklı fiyat manipülasyonu tamamen engellenmiştir.

## ADR-004: Gerçek Zamanlı Sipariş Takibi İçin Socket.IO (WebSocket) Kullanımı
* **Durum:** Kabul Edildi
* **Bağlam:** Şube personeli sipariş durumunu güncellediğinde müşteri mobil ekranının sayfa yenilemeden anında güncellenmesi gerekmektedir.
* **Karar:** Sürekli HTTP Polling yerine çift yönlü olay tabanlı iletişim için `OrdersGateway` üzerinden Socket.IO tercih edilmiştir.
* **Sonuçlar:** Sunucu yükü azaltılmış ve sipariş durum değişiklikleri milisaniyeler içinde müşteriye iletilmiştir.

## ADR-005: Sadakat Hareketlerinde Ters Kayıt (Reversal) ve Idempotency
* **Durum:** Kabul Edildi
* **Bağlam:** Sipariş tamamlandığında puan kazanımı, iptal edildiğinde ise puan iadesi gerekmektedir; ağ gecikmelerinde aynı işlemin iki kez tetiklenme riski vardır.
* **Karar:** `LoyaltyTransactions` tablosunda geçmiş kayıtlar silinmez veya güncellenmez; iptal durumunda eksi değerli `REVERSAL` kaydı oluşturulur ve `order_id + transaction_type` kontrolü ile çift yazım engellenir.
* **Sonuçlar:** Tam finansal/puan denetim izi (audit trail) sağlanmış ve çift puan kazanımı/iadesi önlenmiştir.
