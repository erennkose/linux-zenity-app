#!/bin/bash

DIR="csv"
CSVS=("depo.csv" "kullanici.csv" "log.csv")
is_admin=false


# Zenity'nin çalışacağından emin olmak için, koymazsam zenity çalışmıyor
if [ -z "$DISPLAY" ]; then
  echo "Bu script yalnızca GUI ortamında çalıştırılabilir." >> csv/log.csv
  exit 1
fi

# Dosya varsa oluşturma, yoksa oluştur.
file_check() {
  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
    echo "$DIR adında klasör oluşturuldu."
  fi

  for CSV in "${CSVS[@]}"; do
    FILE_PATH="$DIR/$CSV"
    if [ ! -f "$FILE_PATH" ]; then
      > "$FILE_PATH"
      echo "$FILE_PATH dosyası oluşturuldu."
	if [ "$FILE_PATH" == "$DIR/depo.csv" ]; then
		firstFlag=true
	fi
	if [ "$FILE_PATH" == "$DIR/kullanici.csv" ]; then
		firstFlagUser=true
	fi
    else
      echo "$FILE_PATH dosyası zaten mevcut."
      firstFlag=false
      firstFlagUser=false
    fi
  done
  echo "File Check sona erdi."
}

# Hata kaydı yapan fonksiyon
log_error() {
    	local error_message="$1"  # Hata mesajı
    	local product_info="${2:-"N/A,N/A,N/A,N/A"}"   # İlgili ürün bilgisi (opsiyonel)
    	local timestamp
    	local error_id
    	local user_info

    	# Zaman bilgisi al
    	timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    	# Hata numarası hesapla (log dosyasındaki mevcut hataları sayarak)
    	if [ ! -f "csv/log.csv" ]; then
        	error_id=1
    	else
        	last_error_id=$(tail -n +1 "csv/log.csv" | awk -F',' '{print $1}' | sort -n | tail -n 1)
                error_id=$((last_error_id + 1))
    	fi

    	# Kullanıcı bilgisi al
    	user_info=${sessionU:-"Bilinmiyor"} # Kullanıcı adı mevcut değilse Bilinmiyor yazılır.

    	# Log satırını oluştur
    	log_entry="$error_id,$timestamp,$user_info,$product_info,$error_message"

    	# Log dosyasına yaz
    	echo "$log_entry" >> "csv/log.csv"
}

show_progress() {
	# Her işlem yapılırken dosyaların yedeklemesi yapılır, böylece veri kaybı önlenmiş olur. Bunu son kullanıcıdan da gizledim.
	mkdir -p ".tempBackup"
	cp -prf csv/* .tempBackup/
	local operation="$1"
    	{
        	echo "10";
        	echo "# Adım 1: İşlem başlatılıyor..."
        	sleep 1
        	echo "40";
        	echo "# Adım 2: $operation..."
        	sleep 1
        	echo "65";
        	echo "# Adım 3: İşlem tamamlanmak üzere..."
        	sleep 1
        	echo "100";
        	echo "# İşlem tamamlandı!"
    	} | zenity --progress --text="# Adım 1: İşlem başlatılıyor..." --title="İşlem İlerlemesi" --percentage=0 --auto-close

        if [ $? -ne 0 ]; then  # Cancel butonuna basıldığında ana menüye dön
                main_menu
		return
        fi

}

# Ürün ekleme
add_prod() {
	if $is_admin; then
		prodInfos=$(zenity --forms \
			 --title="Eklenecek Ürünün Bilgileri" \
    			 --text="Lütfen eklenecek ürünün bilgilerini girin:" \
			 --add-entry="Ürün Adı:" \
			 --add-entry="Stok Miktarı" \
			 --add-entry="Birim Fiyatı" \
			 --add-entry="Kategori:")

		if [ $? -ne 0 ]; then
    			main_menu  # Cancel butonuna basıldığında ana menüye dön
    			return
  		fi

		prodName=$(echo "$prodInfos" | awk -F'|' '{print $1}')
		prodStock=$(echo "$prodInfos" | awk -F'|' '{print $2}')
		prodPrice=$(echo "$prodInfos" | awk -F'|' '{print $3}')
		prodCat=$(echo "$prodInfos" | awk -F'|' '{print $4}')

		# Boş kalan alan varsa error verme kısmı
		if [[ -z "$prodName" || -z "$prodStock" || -z "$prodPrice" || -z "$prodCat" ]]; then
    			zenity --error --text="Lütfen boş alan bırakmayınız!!" --title="Eksik Bilgi" 
			log_error "add_prod :: Ürün ekleme sırasında eksik bilgi girildi." "Ad: $prodName, Stok: $prodStock, Fiyat: $prodPrice, Kategori: $prodCat"
    			add_prod
			return

		else
			# Stok miktarı ve birim fiyatı 0'dan küçük olamaz
			if [[ $prodStock -lt 0 || $prodPrice -lt 0 ]]; then
				zenity --error --text="Lütfen stok miktarını ve birim fiyatı 0 veya 0'ın üstünde bir değer girin."
				log_error "add_prod :: 0'ın altında stok veya fiyat değeri girildi." "Ad: $prodName, Stok: $prodStock, Fiyat: $prodPrice, Kategori: $prodCat"
				add_prod
				return
  			else
				if grep -q ",$prodName," csv/depo.csv; then
    					zenity --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz: $prodName" --title="Hata"
    					log_error "add_prod :: Aynı isimli girdi denemesi." "Ad: $prodName, Stok: $prodStock, Fiyat: $prodPrice, Kategori: $prodCat"
					add_prod
    					return
  				else
					depo="csv/depo.csv"
					if [ ! -f "$depo" ]; then
    						prodID=1
  					else
						if $firstFlag; then
    							# Eklenen ilk veriyse ID'yi 1 olarak ayarla
    							prodID=1
							firstFlag=false
    						else
							# Mevcut ID'lerin en büyüğünü bul ve bir artır
    							lastID=$(tail -n +1 "$depo" | awk -F',' '{print $1}' | sort -n | tail -n 1)
    							prodID=$((lastID + 1))
						fi
  					fi
					show_progress "Ürün ekleniyor"
					echo "$prodID,$prodName,$prodStock,$prodPrice,$prodCat" >> csv/depo.csv
					zenity --info --text="Ürün başarıyla kaydedildi!\n\nÜrün ID: $prodID\nÜrün Adı: $prodName\nStok: $prodStock\nFiyat: $prodPrice\nKategori: $prodCat" --title="Başarılı!"
					main_menu
					return
				fi
			fi
		fi

	else
		zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
		log_error "add_prod :: Yetkisiz işlem denemesi."
		main_menu
		return
	fi
}

list_prod() {

	# CSV dosyasının yolu
	depo="csv/depo.csv"

	# Dosyanın var olup olmadığını kontrol et
	if [ ! -f "$depo" ] || [ "$(wc -l < "$depo")" -le 0 ]; then
		zenity --error --text="Envanter boş veya dosya bulunamadı!" --title="Hata"
		log_error "list_prod :: depo.csv dosyası bulunamadı."
		main_menu
		return
	fi

	show_progress "Ürünler listeleniyor"

	# Kullanıcıya gösterme kısmı
	zenity --text-info \
       	--title="Envanter" \
       	--width=1000 \
       	--height=400 \
       	--filename="$depo"
	main_menu
	return
}

update_prod() {
	if $is_admin; then
                updateName=$(zenity --entry --title="Ürün Güncelleme" \
			--text="Güncellenecek ürünün adını giriniz:")

			if [ $? -ne 0 ]; then
                        	main_menu  # Cancel butonuna basıldığında ana menüye dön
                        	return
                	fi

			#updateName değişkenini bul
                        if grep -qi ",$updateName," "csv/depo.csv"; then

                                # Yeni bilgileri al
            			newInfos=$(zenity --forms --title="Ürün Güncelleme" \
            			--text="Yeni ürün bilgilerini giriniz (Boş kalan alanlar değişmeyecek):" \
            			--add-entry="Yeni İsim:" \
				--add-entry="Yeni Stok Miktarı:" \
            			--add-entry="Yeni Birim Fiyatı:" \
				--add-entry="Yeni Kategori:")

        	   		# Mevcut ürün bilgilerini al
            			oldLine=$(grep -i ",$updateName," "csv/depo.csv")
				oldName=$(echo "$oldLine" | awk -F',' '{print $2}')
				oldStock=$(echo "$oldLine" | awk -F',' '{print $3}')
				oldPrice=$(echo "$oldLine" | awk -F',' '{print $4}')
				oldCat=$(echo "$oldLine" | awk -F',' '{print $5}')

				# Yeni girdileri formdan çek
				newName=$(echo "$newInfos" | awk -F'|' '{print $1}')
			        newStock=$(echo "$newInfos" | awk -F'|' '{print $2}')
			        newPrice=$(echo "$newInfos" | awk -F'|' '{print $3}')
				newCat=$(echo "$newInfos" | awk -F'|' '{print $4}')

				# Yeni değer girilmediyse aynı kalması için
				newName=${newName:-$oldName}
   			 	newStock=${newStock:-$oldStock}
    				newPrice=${newPrice:-$oldPrice}
				newCat=${newCat:-$oldCat}

				# Başka isimle yeni isimin çakışmasını engellemek için
				if grep -qi ",$newName," "csv/depo.csv" && [ "$newName" != "$oldName" ]; then
        				zenity --error --text="Yeni isim başka bir ürünle çakışıyor!" --title="Hata"
        				log_error "update_prod :: Aynı isimli girdi denemesi." "Ad: $prodName, Stok: $prodStock, Fiyat: $prodPrice, Kategori: $prodCat"
					main_menu
					return
    				fi

				# Yeni satırı oluştur
				newLine=$(echo "$oldLine" | awk -F',' -v nn="$newName" -v ns="$newStock" -v np="$newPrice" -v nc="$newCat" \
				'{print $1","nn","ns","np","nc}')

				# Kullanıcıdan onay al
				zenity --question --text="Bu değişiklikleri yapmak istediğinizden emin misiniz?" --title="Onay Gerekiyor"

				if [ $? -eq 0 ]; then
					# Onay verilirse güncelleme işlemini yap
					show_progress "Ürün güncelleniyor"
					sed -i "s|$oldLine|$newLine|gI" "csv/depo.csv"
  					zenity --info --text="Ürün başarıyla güncellendi." --title="Başarı"
   					main_menu
					return
				else
    					# Onay verilmezse ana menüye dön
    					zenity --info --text="İşlem iptal edildi." --title="İptal Edildi"
    					main_menu
					return
				fi
                        else
                                zenity --error --text="Bu isme sahip bir ürün bulunamadı." --title="Hata"
                                log_error "update_prod :: Bu isim mevcut değil." "Ad: $prodName, Stok: $prodStock, Fiyat: $prodPrice, Kategori: $prodCat"
                                main_menu
                                return
                        fi
        else
                zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
		log_error "update_prod :: Yetkisiz işlem denemesi."
		main_menu
		return
	fi
}

del_prod() {
	# Yönetici olmayan yapamaz
	if $is_admin; then
                option=$(zenity --list --title="Ürün Silme" \
		--text="Silinecek ürünü arama yöntemini seçin:" \
		--column="Seçenekler" "ID ile silme" "İsim ile silme")

		if [ $? -ne 0 ]; then
                        main_menu  # Cancel butonuna basıldığında ana menüye dön
                        return
                fi

		case $option in
			"ID ile silme")
				delInfo=$(zenity --entry --title="Ürün Silme" \
				--text="Silinecek ürünün ID'sini giriniz:")
				# Ürünün idsi depo.csvde bulunur
				if grep -q "^$delInfo," "csv/depo.csv"; then
                    			# Silme işlemi için onay iste
					zenity --question --text="Bu ürünü silmek istediğinizden emin misiniz?" --title="Onay"

					if [ $? -eq 0 ]; then
    						# Kullanıcı Evet seçerse silme işlemini gerçekleştir
    						show_progress "Ürün siliniyor"
						sed -i "/^$delInfo,/d" "csv/depo.csv"
    						zenity --info --text="Ürün başarıyla silindi." --title="Başarı"
						main_menu
						return
					else
    						# Kullanıcı Hayır seçerse ana menüye dön
    						zenity --info --text="Silme işlemi iptal edildi." --title="İptal"
						main_menu
						return
					fi

                		else
                    			zenity --error --text="Bu ID'ye sahip bir ürün bulunamadı." --title="Hata"
					log_error "del_prod :: ID mevcut değil."
					main_menu
					return
                		fi
				;;
			"İsim ile silme")
				delInfo=$(zenity --entry --title="Ürün Silme" \
				--text="Silinecek ürünün adını giriniz:")
				# Ürünün adı depo.csvde bulunur
				if grep -qi ",$delInfo," "csv/depo.csv"; then
                    			# İsmi bulursa, işlem öncesinde onay istenir
					zenity --question --text="Bu ürünü silmek istediğinizden emin misiniz?" --title="Onay Gerekli"

					if [ $? -eq 0 ]; then
    						# Onay verilmişse silme işlemini yap
    						show_progress "Ürün siliniyor"
						sed -i "/,$delInfo,/Id" "csv/depo.csv"
    						zenity --info --text="Ürün başarıyla silindi." --title="Başarı"
    						main_menu
    						return
					else
    						# Onay verilmemişse ana menüye dön
    						zenity --info --text="Silme işlemi iptal edildi." --title="İptal"
    						main_menu
    						return
					fi
                		else
                    			zenity --error --text="Bu isme sahip bir ürün bulunamadı." --title="Hata"
					log_error "del_prod :: İsim mevcut değil."
					main_menu
					return
                		fi
				;;
			*)
				zenity --error --text="Lütfen geçerli bir seçim yapın..."
				log_error "del_prod :: Geçersiz seçim."
				del_prod
				return
				;;
		esac

        else
                zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
		log_error "del_prod :: Yetkisiz işlem denemesi."
		main_menu
		return
	fi
}

report() {
	# Kullanıcıya seçenek sun
    	local choice=$(zenity --list \
        --title="Raporlama" \
        --text="Hangi raporu görmek istersiniz?" \
        --column="Seçenekler" "Stokta Az Kalan Ürünler" "En Yüksek Stok Miktarına Sahip Ürün" "Ana Menüye Dön")

        if [ $? -ne 0 ]; then
                main_menu  # Cancel butonuna basıldığında ana menüye dön
        	return
        fi

    	# CSV dosyası kontrolü
    	local depo_file="csv/depo.csv"
    	if [[ ! -f "$depo_file" ]]; then
        	zenity --error --text="Depo dosyası bulunamadı!" --title="Hata"
		log_error "report :: Depo dosyası yok."
        	main_menu
		return
    	fi

    	case "$choice" in
        	"Stokta Az Kalan Ürünler")
            		# Stok miktarı 50'den az olan ürünleri bul ve listele
			show_progress "Stok hesaplanıyor"
            		local low_stock=$(awk -F',' '$3 < 50 {print "ID: "$1", İsim: "$2", Stok: "$3", Fiyat: "$4}' "$depo_file")
            		if [[ -z "$low_stock" ]]; then
                		zenity --info --text="Stokta az kalan ürün bulunmamaktadır." --title="Bilgi"
            			report
				return
			else
                		zenity --text-info --title="Stokta Az Kalan Ürünler" --filename=<(echo "$low_stock")
				report
				return
            		fi
            		;;
        	"En Yüksek Stok Miktarına Sahip Ürün")
            		# En yüksek stok miktarına sahip ürünü bul
            		local max_stock=$(awk -F',' 'NR==1 || $3 > max {max=$3; line=$0} END {print line}' "$depo_file")
            		if [[ -z "$max_stock" ]]; then
                		zenity --info --text="Depoda ürün bulunmamaktadır." --title="Bilgi"
            			report
				return
			else
				show_progress "Stok hesaplanıyor"
                		local max_stock_info=$(echo "$max_stock" | awk -F',' '{print "ID: "$1"\nİsim: "$2"\nStok: "$3"\nFiyat: "$4}')
				zenity --info --text="$max_stock_info" --title="En Yüksek Stok Miktarına Sahip Ürün"
            			report
				return
			fi
            		;;
        	"Ana Menüye Dön")
			main_menu
			return
			;;
		*)
            		zenity --error --text="Geçersiz seçim yaptınız." --title="Hata"
            		log_error "report :: Geçersiz seçim."
			report
			return
			;;
    esac
}

add_user() {
	if $is_admin; then
		userInfos=$(zenity --forms \
			 --title="Eklenecek Kullanıcı Bilgileri" \
    			 --text="Lütfen eklenecek kullanıcının bilgilerini girin:" \
			 --add-entry="Kullanıcı Adı:" \
			 --add-entry="Ad:" \
			 --add-entry="Soyad:" \
			 --add-entry="Rol (admin veya user):" \
			 --add-entry="Parola:")
		if [ $? -ne 0 ]; then
    			user_mng  # Cancel butonuna basıldığında ana menüye dön
    			return
  		fi

		# Girdiler çekildi
		userName=$(echo "$userInfos" | awk -F'|' '{print $1}')
		name=$(echo "$userInfos" | awk -F'|' '{print $2}')
		surname=$(echo "$userInfos" | awk -F'|' '{print $3}')
		role=$(echo "$userInfos" | awk -F'|' '{print $4}')
		passWord=$(echo "$userInfos" | awk -F'|' '{print $5}' | md5sum | awk '{print $1}')
		passWordNoHash=$(echo "$userInfos" | awk -F'|' '{print $5}') # Bilgi verirken göstermek için

		# Boşta kalan alan varsa hata verir
		if [[ -z "$userName" || -z "$name" || -z "$surname" || -z "$role" || -z "$passWord" ]]; then
    			zenity --error --text="Lütfen boş alan bırakmayınız!!" --title="Eksik Bilgi"
			log_error "add_user :: Eksik girdi."
    			add_prod
			return

		else
			# Girilen rol admin veya user olmalı
			if [[ "$role" != "admin" && "$role" != "user" ]]; then
    				zenity --error --text="Geçersiz rol! Lütfen 'admin' veya 'user' olarak bir rol belirleyin." --title="Hata"
    				log_error "add_user :: Geçersiz rol girdisi."
				add_user
    				return
  			else
				# Kullanıcı adı mevcutsa hata ver
				if grep -q ",$userName," csv/kullanici.csv; then
    					zenity --error --text="Bu kullanıcı adı zaten mevcut: $userName Lütfen farklı bir kullanıcı adı girin." --title="Hata"
    					log_error "add_user :: Mevcut kullanıcı adı girdisi."
					add_user
    					return
  				else
					# Kullanıcı unique ID'sini hesaplama kısmı
					kdepo="csv/kullanici.csv"
					if [ ! -f "$kdepo" ]; then
    						userID=1
  					else
						if $firstFlagUser; then
    							# İlk kullanıcıysa ID'yi 1 olarak ayarla
    							userID=1
							firstFlagUser=false
    						else
							# Mevcut ID'lerin en büyüğünü bul ve bir artır
    							lastID=$(tail -n +1 "$kdepo" | awk -F',' '{print $1}' | sort -n | tail -n 1)
    							userID=$((lastID + 1))
						fi
  					fi
					show_progress "Kullanıcı ekleniyor"
					echo "$userID,$userName,$name,$surname,$role,$passWord" >> csv/kullanici.csv
					zenity --info --text="Kullanıcı başarıyla kaydedildi!\n\nKullanıcı ID: $userID\nKullanıcı Adı: $userName\nAd: $name\nSoyad: $surname\nRol: $role\nParola: $passWordNoHash " --title="Başarılı!"
					user_mng
					return
				fi
			fi
		fi

	else
		zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
		log_error "add_user :: Yetkisiz işlem denemesi."
		main_menu
		return
	fi
}

list_user() {
	# CSV dosyasının yolu
        kdepo="csv/kullanici.csv"

        # Dosyanın var olup olmadığını kontrol et
        if [ ! -f "$kdepo" ] || [ "$(wc -l < "$kdepo")" -le 0 ]; then
                zenity --error --text="Kullanıcılar listesi boş veya dosya bulunamadı!" --title="Hata"
                log_error "list_user :: kullanici.csv dosyası bulunamadı."
                user_mng
                return
        fi

	show_progress "Kullanıcılar listeleniyor"

        # Zenity ile kullanıcıya gösterme kısmı
        zenity --text-info \
        --title="Kullanıcı Listesi" \
        --width=600 \
        --height=400 \
        --filename="$kdepo"
        user_mng
        return
}

update_user() {
	# Yönetici olmayan kullanamaz
	if $is_admin; then
                local updateName=$(zenity --entry --title="Kullanıcı Güncelleme" \
		--text="Güncellenecek kullanıcının kullanıcı adını giriniz:")

                if [ $? -ne 0 ]; then
                	user_mng  # Cancel butonuna basıldığında üst menüye dön
                	return
                fi

                # updateName değişkenini kullanici.csvde bul
                if grep -q ",$updateName," "csv/kullanici.csv"; then
                # Yeni bilgileri al
            		newInfos=$(zenity --forms --title="Kullanıcı Güncelleme" \
            		--text="Yeni kullanıcı bilgilerini giriniz (Boş kalan alanlar değişmeyecek):" \
            		--add-entry="Yeni Ad:" \
			--add-entry="Yeni Soyad:" \
            		--add-entry="Yeni Rol (admin veya user):" \
			--add-entry="Yeni Parola:")

                	if [ $? -ne 0 ]; then
                        	user_mng  # Cancel butonuna basıldığında ana menüye dön
                        	return
                	fi

        	   	# Mevcut ürün bilgilerini al
            		oldLine=$(grep -i ",$updateName," "csv/kullanici.csv")
			oldName=$(echo "$oldLine" | awk -F',' '{print $3}')
			oldSurname=$(echo "$oldLine" | awk -F',' '{print $4}')
			oldRole=$(echo "$oldLine" | awk -F',' '{print $5}')
			oldPassword=$(echo "$oldLine" | awk -F',' '{print $6}')

			# Yeni bilgileri formdan çek
			newName=$(echo "$newInfos" | awk -F'|' '{print $1}')
			newSurname=$(echo "$newInfos" | awk -F'|' '{print $2}')
			newRole=$(echo "$newInfos" | awk -F'|' '{print $3}')
			newPassword=$(echo "$newInfos" | awk -F'|' '{print $4}' | md5sum | awk '{print $1}')

			# Yeni değer girilmediyse aynı kalması için
			newName=${newName:-$oldName}
   			newSurname=${newSurname:-$oldSurname}
    			newRole=${newRole:-$oldRole}
			newPassword=${newPassword:-$oldPassword}

			# Rol admin veya user değilse error ver
			if [[ "$newRole" != "admin" && "$newRole" != "user" ]]; then
                            	zenity --error --text="Geçersiz rol! Lütfen 'admin' veya 'user' olarak bir rol belirleyin." --title="Hata"
                           	log_error "update_user :: Geçersiz rol girdisi."
                        	update_user
                              	return
			fi

			# Yeni satırı oluştur
			newLine=$(echo "$oldLine" | awk -F',' -v nn="$newName" -v ns="$newSurname" -v nr="$newRole" -v np="$newPassword" \
			'{print $1","$2","nn","ns","nr","np}')

			# Güncelleme öncesinde onay iste
			zenity --question --text="Bu kullanıcıyı güncellemek istediğinizden emin misiniz?" --title="Onay Gerekli"

			if [ $? -eq 0 ]; then
    				# Onay verilmişse dosyada eski satırı yeni satırla değiştir
    				show_progress "Kullanıcı güncelleniyor"
				sed -i "s|$oldLine|$newLine|gI" "csv/kullanici.csv"
    				zenity --info --text="Kullanıcı başarıyla güncellendi." --title="Başarı"
    				user_mng
    				return
			else
    				# Onay verilmemişse kullanıcıya bilgi ver ve kullanıcı yönetim menüsüne dön
    				zenity --info --text="Güncelleme işlemi iptal edildi." --title="İptal"
    				user_mng
    				return
			fi

                 else
                 	zenity --error --text="Bu kullanıcı adına sahip bir kullanıcı bulunamadı." --title="Hata"
                        log_error "update_user :: Kullanıcı adı mevcut değil."
                        user_mng
                        return
                 fi
        else
        	zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
		log_error "update_user :: Yetkisiz işlem denemesi."
		main_menu
		return
	fi
}

del_user() {
	# Yönetici olmayan kullanamaz
	if $is_admin; then
                option=$(zenity --list --title="Kullanıcı Silme" \
		--text="Silinecek kullanıcıyı arama yöntemini seçin:" \
		--column="Seçenekler" "ID ile silme" "Kullanıcı adı ile silme")

                if [ $? -ne 0 ]; then
                        user_mng  # Cancel butonuna basıldığında üst  menüye dön
                        return
                fi

		case $option in
			"ID ile silme")
				delInfo=$(zenity --entry --title="Kullanıcı Silme" \
				--text="Silinecek kullanıcının ID'sini giriniz:")

				# ID'yi kullanici.csvde bul
				if grep -q "^$delInfo," "csv/kullanici.csv"; then
                    			# Silme öncesinde onay iste
					zenity --question --text="Bu kullanıcıyı silmek istediğinizden emin misiniz?" --title="Onay Gerekli"

					if [ $? -eq 0 ]; then
    						# Onay verilmişse, ilgili satırı dosyadan sil
    						show_progress "Kullanıcı siliniyor"
						sed -i "/^$delInfo,/d" "csv/kullanici.csv"
    						zenity --info --text="Kullanıcı başarıyla silindi." --title="Başarı"
    						user_mng
    						return
					else
    						# Onay verilmemişse kullanıcıya bilgi ver ve kullanıcı yönetim menüsüne dön
    						zenity --info --text="Silme işlemi iptal edildi." --title="İptal"
    						user_mng
    						return
					fi
                		else
                    			zenity --error --text="Bu ID'ye sahip bir kullanıcı bulunamadı." --title="Hata"
					log_error "del_user :: ID mevcut değil."
					user_mng
					return
                		fi
				;;
			"Kullanıcı adı ile silme")
				delInfo=$(zenity --entry --title="Kullanıcı Silme" \
				--text="Silinecek kullanıcının kullanıcı adını giriniz:")
				# Kullanıcı adını kullanici.csvde bul
    				if awk -F',' -v user="$delInfo" '$2 == user' "csv/kullanici.csv" | grep -q .; then
        				# Silme öncesinde onay iste
					zenity --question --text="Bu kullanıcıyı silmek istediğinizden emin misiniz?" --title="Onay Gerekli"

					if [ $? -eq 0 ]; then
    						# Onay verilmişse, ilgili satırı dosyadan sil
    						show_progress "Kulanıcı siliniyor"
						sed -i "/^[^,]*,${delInfo},/d" "csv/kullanici.csv"
    						zenity --info --text="Kullanıcı başarıyla silindi." --title="Başarı"
    						user_mng
    						return
					else
    						# Onay verilmemişse kullanıcıya bilgi ver ve kullanıcı yönetim menüsüne dön
    						zenity --info --text="Silme işlemi iptal edildi." --title="İptal"
    						user_mng
    						return
					fi
    				else
        				zenity --error --text="Bu kullanıcı adına sahip bir kullanıcı bulunamadı." --title="Hata"
        				log_error "del_user :: username mevcut değil."
        				user_mng
        				return
    				fi
    				;;
			*)
				zenity --error --text="Lütfen geçerli bir seçim yapın..."
				log_error "del_user :: Geçersiz seçim."
				del_user
				return
				;;
		esac

        else
                zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
		log_error "del_user :: Yetkisiz işlem denemesi."
		main_menu
		return
	fi
}

acc_unlock() {
	if $is_admin; then
    		local lockedUname=$(zenity --entry --text="Kilidini kaldırmak istediğiniz hesabın kullanıcı adını giriniz:"  --title="Log Temizleme")

                if [ $? -ne 0 ]; then
                        user_mng  # Cancel butonuna basıldığında üst menüye dön
                        return
                fi

		# log.csv içerisinden hatalı denemelere bak ve dosyadan sil
    		if grep -qi "login_screen :: Hatalı deneme $lockedUname" "csv/log.csv"; then
        		if zenity --question --text="Bu kullanıcının hesabının kildini kaldırmak istediğinizden emin misiniz?" --title="Onay"; then
            			show_progress "Hesap kilidi kaldırılıyor"
				sed -i "/login_screen :: Hatalı deneme $lockedUname/Id" "csv/log.csv"
            			zenity --info --text="$lockedUname kullanıcısının hesabının kilidi kaldırıldı." --title="Başarılı İşlem"
        			user_mng
				return
			else
            			zenity --info --text="İşlem iptal edildi." --title="İptal"
				user_mng
				return
        		fi
    		else
        		zenity --error --text="Bu kullanıcıya ait bir hesap yok veya kilitli değil." --title="Hata"
			log_error "acc_unlock :: Log yok."
			user_mng
			return
    		fi
	else
		zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
                log_error "del_user :: Yetkisiz işlem denemesi."
                main_menu
                return
	fi
}


user_mng() {
	# Yönetici olmayan kullanamaz
	if $is_admin; then
 		# Kullanıcı ekle, listele, güncelle, sil
		local option=$(zenity --list --title="Kullanıcı Yönetimi" \
        	--text="Yapmak istediğiniz işlemi seçin:" \
        	--width=400 \
		--height=400 \
		--column="Seçenekler" "Kullanıcı Ekle" "Kullanıcıları Listele" \
        	"Kullanıcı Güncelle" "Kullanıcı Sil" "Hesap Kilidi Aç" "Ana Menüye Dön")

                if [ $? -ne 0 ]; then
                        main_menu  # Cancel butonuna basıldığında ana menüye dön
                        return
                fi

		case $option in
			"Kullanıcı Ekle")
				add_user
				;;
			"Kullanıcıları Listele")
				list_user
				;;
			"Kullanıcı Güncelle")
				update_user
				;;
			"Kullanıcı Sil")
				del_user
				;;
			"Hesap Kilidi Aç")
				acc_unlock
				;;
			"Ana Menüye Dön")
				main_menu
				;;
			*)
				zenity --error --text="Geçersiz Seçim..." --title="Hata"
                        	log_error "main_menu :: Geçersiz seçenek seçimi."
				user_mng
				return
		esac
	else
                zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
                log_error "user_mng :: Yetkisiz işlem denemesi."
                main_menu
                return
        fi
}

disc_show() {
	# Yönetici olmayan kullanamaz
	if $is_admin; then
		show_progress "Diskte kaplanan alan hesaplanıyor"
    		local disk_usage=$(du -h "csv" "main.sh" | zenity --text-info --title="Diskte Kaplanan Alan" --width=400 --height=300)

    		if [[ $? -ne 0 ]]; then
        		zenity --error --text="Diskte kaplanan alan bilgisi alınamadı." --title="Hata"
        		log_error "disc_show :: Disk kullanım bilgisi alınamadı."
		fi

		program_mng
		return
	else
		zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
                log_error "disc_show :: Yetkisiz işlem denemesi."
                main_menu
                return
	fi
}

disc_backup() {
	# Yönetici olmayan kullanamaz
	if $is_admin; then
		local backup_dir="backup"
		mkdir -p "$backup_dir"  # Yedekleme dizinini oluştur

		for file in csv/*; do
        		if [[ -f "$file" ]]; then
            			local backup_file="$backup_dir/$(basename "$file")"

            			# Eğer backup dizininde aynı ada sahip bir hard link varsa
            			if [[ -e "$backup_file" ]]; then
                			# Orijinal dosya farklı bir inode numarasına sahipse yeni hard link oluştur
                			if [[ $(stat -c "%i" "$file") != $(stat -c "%i" "$backup_file") ]]; then
                    				show_progress "Dosyalar yedekleniyor"
						ln "$file" "$backup_file" -f
                    				zenity --info --text= "$file dosyası güncellendi." --title="Başarılı"
                			else
                    				zenity --info --text="$file zaten yedeklenmiş." --title="Başarısız"
                			fi
            			else
					show_progress "Dosyalar yedekleniyor"
                			# Yedeklemek için hard link oluştur
                			ln "$file" "$backup_file"
                			zenity --info --text="$file yedeklenmesi başarıyla tamamlandı" --title="Başarılı"
				fi
        		fi
    		done

    		if [[ $? -eq 0 ]]; then
        		zenity --info --text="CSV dosyaları başarıyla yedeklendi. Yedekleme dizini: $backup_dir" --title="Başarılı"
    			program_mng
			return
		else
        		zenity --error --text="Yedekleme işlemi başarısız oldu." --title="Hata"
        		log_error "disc_backup :: Yedekleme işlemi başarısız oldu."
			program_mng
			return
    		fi
	else
		zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
                log_error "disc_backup :: Yetkisiz işlem denemesi."
                main_menu
                return
	fi
}

log_show() {
	# Yönetici olmayan kullanamaz
	if $is_admin; then
        	# CSV dosyasının yolu
        	ldepo="csv/log.csv"

        	# Dosyanın var olup olmadığını kontrol et
        	if [ ! -f "$ldepo" ] || [ "$(wc -l < "$ldepo")" -le 0 ]; then
                	zenity --error --text="Hata kayıtları boş veya dosya bulunamadı!" --title="Hata"
                	log_error "log_show :: log.csv dosyası bulunamadı."
                	program_mng
                	return
        	fi

		show_progress "Log dosyası yazdırılıyor"

        	# Zenity ile kullanıcıya göster
        	zenity --text-info \
        	--title="Hata Kayıtları" \
        	--width=600 \
        	--height=400 \
        	--filename="$ldepo"
        	program_mng
        	return
	else
		zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
                log_error "log_show :: Yetkisiz işlem denemesi."
                main_menu
                return
	fi
}

program_mng() {
	# Yönetici olmayan kullanamaz
	if $is_admin; then
		local option=$(zenity --list --title="Program Yönetimi" \
                --text="Yapmak istediğiniz işlemi seçin:" \
                --width=400 \
		--height=400 \
		--column="Seçenekler" "Diskte Kaplanan Alan" "Diske Yedek Alma" \
                "Hata Kayıtlarını Görüntüleme" "Ana Menüye Dön")

                if [ $? -ne 0 ]; then
                        main_menu  # Cancel butonuna basıldığında ana menüye dön
                        return
                fi

                case $option in
                        "Diskte Kaplanan Alan")
                                disc_show
                                ;;
                        "Diske Yedek Alma")
                                disc_backup
                                ;;
                        "Hata Kayıtlarını Görüntüleme")
                                log_show
                                ;;
                        "Ana Menüye Dön")
                                main_menu
                                ;;
                        *)
                                zenity --error --text="Geçersiz Seçim..." --title="Hata"
                                log_error "main_menu :: Geçersiz seçenek seçimi."
                                user_mng
                                return
                esac
	else
		zenity --error --text="Bu işlem yalnızca yetkili biri tarafından yapılabilir..." --title="Yetki Hatası!"
                log_error "program_mng :: Yetkisiz işlem denemesi."
                main_menu
                return
	fi
}


# Ana menü
main_menu() {
	option=$(zenity --list --title="Ana Menü" \
	--text="Yapmak istediğiniz işlemi seçin:" \
	--width=400 \
	--height=400 \
	--column="Seçenekler" "Ürün Ekle" "Ürün Listele" \
	"Ürün Güncelle" "Ürün Sil" "Rapor Al" "Kullanıcı Yönetimi" \
	"Program Yönetimi" "Uygulamayı Kapat")

	case $option in
  		"Ürün Ekle")
    			add_prod
    			;;
  		"Ürün Listele")
    			list_prod
    			;;
  		"Ürün Güncelle")
    			update_prod
    			;;
  		"Ürün Sil")
    			del_prod
    			;;
  		"Rapor Al")
    			report
    			;;
		"Kullanıcı Yönetimi")
			user_mng
			;;
		"Program Yönetimi")
			program_mng
			;;
		"Uygulamayı Kapat")
			zenity --question --text="Çıkmak istediğinizden emin misiniz?" --title="Çıkış Onayı"

			if [ $? -eq 0 ]; then
    				# Evet seçildi
    				exit 1
			else
    				# Hayır seçildi
    				main_menu
			fi

			;;
  		*)
    			zenity --error --text="Geçersiz Seçim..." --title="Hata"
			log_error "main_menu :: Geçersiz seçenek seçimi."
    			main_menu
    			;;
	esac
}


# Giriş Ekranı
login_screen() {
	infos=$(zenity --forms --title="Kullanıcı Girişi" --text="Giriş" --add-entry="Kullanıcı Adı" --add-password="Parola:")

	if [ $? -ne 0 ]; then
		zenity --info --text="Giriş iptal edildi." --title="Bilgilendirme"
		exit 1
  	fi

  	username=$(echo "$infos" | awk -F'|' '{print $1}')
  	password=$(echo "$infos" | awk -F'|' '{print $2}' | md5sum | awk '{print $1}')

	# Sistem ilk başlatıldığında hiç hesap olmadığı için sisteme giriş yapma amaçlı bir yönetici hesabı
  	if [[ "$username" == "admin" && "$(echo -n "$password" | md5sum | awk '{print $1}')" ]]; then
    		show_progress "Giriş yapılıyor"
    		is_admin=true
    		zenity --notification --text="Hoşgeldiniz, admin!" --title="Başarılı Giriş"
    		sessionU="admin"
    		# Global hale getirdim
    		export sessionU
    		main_menu

  	else
		# Dosyadan kullanıcıyı çekme kısmı
		if grep -q "^[^,]*,${username},[^,]*,[^,]*,[^,]*,[^,]*" csv/kullanici.csv; then
			userLine=$(grep "^[^,]*,${username},[^,]*,[^,]*,[^,]*,[^,]*" csv/kullanici.csv)
			role=$(echo "$userLine" | awk -F',' '{print $5}')

			# Kullanıcı admin ise değişkeni true yaptım, değilse false yaptım
			if [[ "$role" == "admin" ]]; then
                		is_admin=true
        		else
                		is_admin=false
        		fi

			# Log dosyasında kaç adet başarısız giriş yapıldığını tespit etme kısmı
        		fail_count=$(grep -ci "login_screen :: Hatalı deneme $username" "csv/log.csv")

        		if [[ $fail_count -ge 3 && $is_admin != true ]]; then
                		zenity --error --text="Hesabınız kilitlendi. Lütfen bir admin ile iletişime geçin." --title="Hesap Kilitlendi"
                		log_error "login_screen :: Kilitli hesap."
                		login_screen
                		return
        		fi
		fi

    		if grep -q "^[^,]*,${username},[^,]*,[^,]*,[^,]*,${password}$" csv/kullanici.csv; then
    			# Kullanıcı bilgilerini dosyadan al
			userLine=$(grep "^[^,]*,${username},[^,]*,[^,]*,[^,]*,${password}$" csv/kullanici.csv)
			role=$(echo "$userLine" | awk -F',' '{print $5}')

    			if [[ "$role" == "admin" ]]; then
        			is_admin=true
    			else
        			is_admin=false
    			fi

			# 2 başarısız ardından 1 başarılı ardından yine 1 başarısız giriş denemesinde hesap kilitlenmemeli
			if grep -qi "login_screen :: Hatalı deneme $username" "csv/log.csv"; then
        			sed -i "/login_screen :: Hatalı deneme $username/Id" "csv/log.csv"
    			fi

			show_progress "Giriş yapılıyor"
    			zenity --info --text="Hoşgeldiniz, $username!" --title="Başarılı Giriş"
    			sessionU="$username"
    			export sessionU
    			main_menu

    		else
      			zenity --error --text="Hatalı kullanıcı adı veya şifre!" --title="Giriş hatası!"
      			log_error "login_screen :: Hatalı deneme $username"
      			login_screen
    		fi
  	fi
}

file_check
login_screen

