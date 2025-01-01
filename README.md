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

## Bilinmesi Gerekenler
- Program ilk başlatıldığında dosyaları otomatik olarak oluşturacaktır. Bu süreçte hiçbir kullanıcı sisteme henüz kayıtlı olmayacağından dolayı sisteme giriş yapılamayacaktı. Bu durumu engelleme amaçlı kod içerisinde tanımlı, kullanıcı adı ve şifresi "admin" olan özel hesapla sisteme giriş yapabilirsiniz.
- **Yönetici(admin) hesaplar**; ürün ekleme, güncelleme, silme ve kullanıcı yönetimi yapabilmektedir.
- **Kullanıcı(user) hesaplar**; sadece ürünleri görüntüleyebilmekte ve rapor alabilmektedir.

## Youtube Tanıtım Videosu Linki
<a href="https://www.youtube.com/c/https://www.youtube.com/" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/youtube.svg" alt="https://www.youtube.com/" height="30" width="40" /></a> https://www.youtube.com/

## Hazırlayan
- **Eren Köse** - 22360859075 - Bursa Teknik Üniversitesi Bilgisayar Mühendisliği 3.Sınıf Öğrencisi
