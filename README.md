# Linux Araçları ve Kabuk Programlama Dersi Zenity Uygulaması Ödevi

## Ödevin Özeti
- Zenity araçlarını kullanarak, ürün ekleme, listeleme, güncelleme ve silme vb. işlemlerini destekleyen, kullanıcı dostu bir grafik arayüz sağlayan basit bir envanter yönetim sistemi.

## Youtube Tanıtım Videosu Linki
<a href="https://youtu.be/CdQimTn2Q0E" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/youtube.svg" alt="https://youtu.be/CdQimTn2Q0E" height="30" width="40" /></a> [Youtube Tanıtım Videosu](https://youtu.be/CdQimTn2Q0E)

## Github Reposu Linki
<a href="https://github.com/erennkose/linux-zenity-app" target="_blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/github.svg" alt="https://github.com/erennkose/linux-zenity-app" height="30" width="40" /></a> [Github Reposu](https://github.com/erennkose/linux-zenity-app)

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
    - Hesap Kilidi Açma
  - Program Yönetimi
    - Diskteki Alanı Göster (main.sh + depo.csv + kullanici.csv + log.csv)
    - Diske Yedekle (depo.csv + kullanici.csv + log.csv)
    - Hata Kayıtlarını Göster (log.csv)
  - Çıkış

## Ekran Görüntülü Sistem Anlatımı

### Giriş Ekranı
![Giriş Ekranı](readme-pics/giris.png)<br>
Bu ekran uygulama çalıştırılınca açılan ilk ekrandır. Giriş yapmanızı sağlar. Eğer herhangi bir hesap oluşturulmadıysa "admin" "admin" girdileriyle sisteme giriş yapabilirsiniz.

---

### Ana Menü
![Ana Menü](readme-pics/menu.png)<br>
Bu ekran bizim ana menümüzü gösteren ekrandır. Buradaki seçeneklerden istenen seçenek seçilebilir. Kullanıcılar buradaki işlemlerden yalnızca ürün listeleme ve rapor kısımlarını kullanabilirler.

#### Ürün Ekle
![Ürün Ekle](readme-pics/add_prod.png)<br>
- Bu ekran bizim `csv` klasörümüz altında bulunan `depo.csv` dosyasına ürün eklememizi sağlar.
- Buraya yazılan bilgiler `id, ad, stok, fiyat, kategori` formatında depolanır.
- Aynı isimde ürün eklenmesine izin verilmez.

#### Ürün Listeleme
![Ürün Listeleme](readme-pics/list_prod.png)<br>
`depo.csv` dosyamızdaki ürünlerin hepsini ekrana listeler.

#### Ürün Güncelleme
- **Adım 1:** <br>
  ![Ürün Güncelleme 1](readme-pics/update_prod1.png)<br>
  İlk ekranda güncellemek istediğimiz ürünün adı girilir.
- **Adım 2:** <br>
  ![Ürün Güncelleme 2](readme-pics/update_prod2.png)<br>
  İkinci ekranda istenen güncellemeler yapılır. Boş bırakılan kısımlar için eski bilgiler korunur. Onay verildiğinde ise `depo.csv` dosyasında gerekli güncellemeler yapılır.

#### Ürün Silme
- **Adım 1:** <br>
  ![Ürün Silme 1](readme-pics/del_prod1.png)<br>
  İlk ekranda silinecek ürünü neye göre sileceğimiz istenir.
- **Adım 2:** <br>
  ![Ürün Silme 2](readme-pics/del_prod2.png)<br>
  Seçilen seçeneğe göre ikinci ekrandan alınan bilgi doğrultusunda `depo.csv` dosyası içinde bu veri aranır. Silme işlemi geri alınamaz olduğundan sistem emin olup olmadığınızı doğrular. İşlem başarılı olunca bir başarı mesajı görüntülenir.

---

### Rapor Al
![Rapor Menüsü](readme-pics/report1.png)<br>
Bu seçenek seçildiğinde, bizi raporlama menüsü karşılar. Burada yapılmak istenen işleme göre seçenek seçilir.

- **Stokta Az Kalan Ürünler** <br>
  ![Stokta Az Kalan Ürünler](readme-pics/report2.png)<br>
  `depo.csv` içerisindeki stok sayısı 50'nin altına düşmüş ürünler ekrana yazdırılır.

- **En Yüksek Stok Miktarına Sahip Ürün** <br>
  ![En Yüksek Stok Miktarı](readme-pics/report3.png)<br>
  `depo.csv` içerisindeki ürünlerden stokta en fazla bulunan ürün ekrana yazdırılır.

---

### Kullanıcı Yönetimi
![Kullanıcı Yönetimi](readme-pics/user_mng.png)<br>
Bu seçenek seçildiğinde bizi kullanıcı yönetim menüsü karşılar. Burada yapılmak istenen işleme göre seçenek seçilir.

- **Kullanıcı Ekle**
  - **Adım 1:** <br>
    ![Kullanıcı Ekle 1](readme-pics/add_user1.png)<br>
    Kullanıcı bilgileri girilir.
  - **Adım 2:** <br>
    ![Kullanıcı Ekle 2](readme-pics/add_user2.png)<br>
    Rol kısmı "admin" veya "user" olmak zorundadır. İşlem başarılı olursa kullanıcıya bilgi verilir.

- **Kullanıcıları Listele** <br>
  ![Kullanıcı Listeleme](readme-pics/list_user.png)<br>
  `kullanici.csv` dosyasında kayıtlı kullanıcılar ekrana yazdırılır.

- **Kullanıcı Güncelle**
  - **Adım 1:** <br>
    ![Kullanıcı Güncelle 1](readme-pics/update_user1.png)<br>
    Güncellenecek hesabın kullanıcı adı istenir.
  - **Adım 2:** <br>
    ![Kullanıcı Güncelle 2](readme-pics/update_user2.png)<br>
    Güncellenmesi istenen kısımlar doldurulur. Boş kalan kısımlar eski haliyle kalır. İşlem onaylandıktan sonra güncelleme tamamlanır.

- **Kullanıcı Sil**
  - **Adım 1:** <br>
    ![Kullanıcı Sil 1](readme-pics/del_user1.png)<br>
    Kullanıcıyı silmek için ID ya da kullanıcı adı seçilir.
  - **Adım 2:** <br>
    ![Kullanıcı Sil 2](readme-pics/del_user2.png)<br>
    İşlem geri alınamayacak olduğundan emin olmanız istenir. Onaylandığında işlem tamamlanır.

- **Hesap Kilidi Aç** <br>
  ![Hesap Kilidi Aç](readme-pics/acc_unlock1.png)<br>
  3 kez başarısız giriş denemesi nedeniyle kilitlenen hesabın kilidini açmak için bu seçenek kullanılır.

---

### Program Yönetimi
![Program Yönetimi](readme-pics/program_mng.png)<br>
Bu seçenek seçildiğinde bizi program yönetim menüsü karşılar. Burada yapılmak istenen işleme göre seçenek seçilir.

- **Diskte Kaplanan Alan** <br>
  ![Diskte Kaplanan Alan](readme-pics/disc_show.png)<br>
  Sistemin ve kullanılan `csv` dosyalarının kapladığı boyut belirtilir.

- **Diske Yedek Alma**
  - **Adım 1:** <br>
    ![Diske Yedek Alma 1](readme-pics/disc_backup1.png)<br>
    Yedekleme işlemi başlatılır.
  - **Adım 2:** <br>
    ![Diske Yedek Alma 2](readme-pics/disc_backup2.png)<br>
  - **Adım 3:** <br>
    ![Diske Yedek Alma 3](readme-pics/disc_backup3.png)<br>
  - **Adım 4:** <br>
    ![Diske Yedek Alma 4](readme-pics/disc_backup4.png)<br>
    Hard link yoluyla yedekleme tamamlanır.

- **Hata Kayıtlarını Görüntüleme** <br>
  ![Hata Kayıtlarını Görüntüleme](readme-pics/log_show.png)<br>
  `log.csv` dosyasındaki hata kayıtları ekrana gösterilir.

---

### Başarı Ekranı
![Başarı Ekranı](readme-pics/add_prod_ok.png)<br>
Ürün ekleme gibi işlemlerin başarılı olması durumunda bilgi veren bir ekran bizi karşılar.

---

### Çıkış Onay Ekranı
![Çıkış Onay Ekranı](readme-pics/exit_question.png)<br>
Sistemden çıkış yapılırken çıkış istemi doğrulanır.

## Bilinmesi Gerekenler
- Program ilk başlatıldığında dosyaları otomatik olarak oluşturacaktır. Bu süreçte hiçbir kullanıcı sisteme henüz kayıtlı olmayacağından dolayı sisteme giriş yapılamayacaktı. Bu durumu engelleme amaçlı kod içerisinde tanımlı, kullanıcı adı ve şifresi "admin" olan özel hesapla sisteme giriş yapabilirsiniz.
- **Yönetici(admin) hesaplar**; ürün ekleme, güncelleme, silme ve kullanıcı yönetimi yapabilmektedir.
- **Kullanıcı(user) hesaplar**; sadece ürünleri görüntüleyebilmekte ve rapor alabilmektedir.
- Kayıtlar, loglar, depolamalar gibi işlemler sistem tarafından oluşturulan csv klasörü içerisinde bulunurlar. Sistem ilk çalıştırıldığı anda bu klasör ve içinde bulunması gereken dosyalar oluşturulur.
- Yöneticilerin ve kulanıcıların şifreleri MD5 yöntemi ile şifrelenmiş bir şekilde depolanır. Bu sayede veri güvenliği sağlanır.
- Sistem her işlem yaptığında .tempBackup adlı gizli bir klasör içerisinde bilgileri depolar, bu da herhangi beklenmedik bir durum sonucunda veri kaybını önler.

## Hazırlayan
- **Eren Köse** - 22360859075 - Bursa Teknik Üniversitesi Bilgisayar Mühendisliği 3.Sınıf Öğrencisi
