# Linux Araçları ve Kabuk Programlama Dersi Zenity Uygulaması Ödevi

## Ödevin Özeti
- Zenity araçlarını kullanarak, ürün ekleme, listeleme, güncelleme ve silme vb. işlemlerini destekleyen, kullanıcı dostu bir grafik arayüz sağlayan basit bir envanter yönetim sistemi.

## Fonksiyonlar

- Kullanıcı Rolleri
  - Yönetici
  - Kullanıcı
- Veri Saklama (depo.csv, kullanici.csv, log.csv)
- Ana Menü
  - Ürün Ekle
  - Ürün Listele
  - Ürün Güncelle
  - Ürün Sil
  - Rapor Al
    - Stokta Azalan Ürünler (Eşik değeri sağlanmalı)
    - En Yüksek Stok Miktarına Sahip Ürünler (Eşik değeri sağlanmalı)
  - Kullanıcı Yönetimi
    - Yeni Kullanıcı Ekle
    - Kullanıcıları Listele
    - Kullanıcı Güncelle
    - Kullanıcı Silme
  - Program Yönetimi
    - Diskteki Alanı Göster (.sh + depo.csv + kullanici.csv + log.csv)
    - Diske Yedekle (depo.csv + kullanici.csv)
    - Hata Kayıtlarını Göster (log.csv)
  - Çıkış

## Arayüz Ekranları
- Giriş
  - Kullanıcı Adı ve Parola
- Ürün Ekle
  - Ürün Numarası, Ürün Adı, Stok Miktarı, Birim Fiyatı, Kategori
- Ürün Listele
  - Ürün Numarası, Ürün Adı, Stok Miktarı, Birim Fiyatı, Kategori
- Ürün Güncelle
  - Ürün Adı, Stok Miktarı, Birim Fiyatı, Kategori
- Ürün Sil
  - Ürün Numarası veya Ürün Adı
- Rapor Al
  - Stokta Azalan Ürünler
  -  En Yüksek Stok Miktarına
- Kullanıcı Yönetimi
  - Yeni Kullanıcı Ekle (No, Adı, Soyadı, Rol, MD5 Parola)
  -  Kullanıcıları Listele
  -  Kullanıcı Güncelle (Adı, Soyadı, Rol, Parola)
  -  Kullanıcı Sil
- Program Yönetimi
  - Diskte Kapladığı Alan Gösterimi
  -  Diske Yedek Alma
  -   Hata Kayıtlarını Görüntüleme
- Çıkış

## Ekran Görüntülü Sistem Anlatımı
- Giriş Ekranı
  -  Bu ekran uygulama çalıştırılınca açılan ilk ekrandır. Giriş yapmanızı sağlar. Eğer herhangi bir hesap oluşturulmadıysa "admin" "admin" girdileriyle sisteme giriş yapabilirsiniz.
- Ana Menü
  - Bu ekran bizim ana menümüzü gösteren ekrandır. Buradaki seçeneklerden istenen seçenek seçilebilir. Kullanıcılar buradaki işlemlerden yalnızca ürün listeleme ve rapor kısımlarını kullanabilirler.
- Ürün Ekle
  - Bu ekran bizim csv klasörümüz altında bulunan depo.csv dosyasına ürün eklememizi sağlamakta. Buraya yazılan bilgiler id,ad,stok,fiyat,kategori tarzındaki bir formatta depolanır. Aynı isimde ürün eklenmesine izin verilmez.
- Başarı Ekranı
  - Ürün ekleme gibi bazı işlemlerin başarılı olması sonucunda bilgi veren ve başarıyı gösteren bir ekran bizi karşılar
- Ürün Listeleme
  - depo.csv dosyamızdaki ürünlerimizin hepsini ekrana listeler.
- Ürün Güncelleme
  - İlk ekranda güncellemek istediğimiz ürünün adı girilir. Sonrasında ise ikinci ekran bizi karşılar. Burada istenen güncellemeler yapılır. Boş bırakılan kısımlar için eski bilgiler korunur. Onay verildiğinde ise depo.csv dosyasında gerekli güncellemeler yapılır.
- Ürün Silme
  - İlk ekranda silinecek ürünü neye göre sileceğimiz istenir. Burada seçilen seçeneğe göre ikinci ekrandan alınan bilgi doğrultusunda depo.csv dosyası içinde bu veri aranır. Silme işlemi geri alınamaz bir işlem olduğundan dolayı sistem emin olup olmadığınızı doğrular. Silme işlemi başarılı olunca başarılı olduğunu belirten bir mesaj yazılır.
- Kullanıcı Yönetimi
  - Bu seçenek seçildiğinde bizi kullanıcı yönetim menüsü karşılar. Burada yapılamk istenen işleme göre seçenek seçilir.
    - Kullanıcı Ekle
      - ekle
    - Kullanıcıları Listele
      - liste
    - Kullanıcı Güncelle
      - güncelle
    - Kullanıcı Sil
      - sil
    - Hesap Kilidi Aç
      - kilit aç

## Bilinmesi Gerekenler
- Program ilk başlatıldığında dosyaları otomatik olarak oluşturacaktır. Bu süreçte hiçbir kullanıcı sisteme henüz kayıtlı olmayacağından dolayı sisteme giriş yapılamayacaktı. Bu durumu engelleme amaçlı kod içerisinde tanımlı, kullanıcı adı ve şifresi "admin" olan özel hesapla sisteme giriş yapabilirsiniz.
- **Yönetici(admin) hesaplar**; ürün ekleme, güncelleme, silme ve kullanıcı yönetimi yapabilmektedir.
- **Kullanıcı(user) hesaplar**; sadece ürünleri görüntüleyebilmekte ve rapor alabilmektedir.
- Kayıtlar, loglar, depolamalar gibi işlemler sistem tarafından oluşturulan csv klasörü içerisinde bulunurlar. Sistem ilk çalıştırıldığı anda bu klasör ve içinde bulunması gereken dosyalar oluşturulur.
- Yöneticilerin ve kulanıcıların şifreleri MD5 yöntemi ile şifrelenmiş bir şekilde depolanır. Bu sayede veri güvenliği sağlanır.
- Sistem her işlem yaptığında gizli bir dosya içerisinde bilgileri depolar, bu da herhangi beklenmedik bir durum sonucunda veri kaybını önler.

## Youtube Tanıtım Videosu Linki
<a href="https://www.youtube.com/c/https://www.youtube.com/" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/youtube.svg" alt="https://www.youtube.com/" height="30" width="40" /></a> https://www.youtube.com/

## Hazırlayan
- **Eren Köse** - 22360859075 - Bursa Teknik Üniversitesi Bilgisayar Mühendisliği 3.Sınıf Öğrencisi
