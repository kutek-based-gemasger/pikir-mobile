# Bab VIII — naskah siap tempel

> **Cara pakai (bagian ini jangan ikut ditempel).**
> Seluruh teks di bawah garis ini adalah naskah bab, ditulis dengan register
> proposal. Tempel apa adanya. Posisi gambar ditandai dengan blok
> `[GAMBAR …]` — ganti blok itu dengan gambarnya, lalu tulis keterangan gambar
> persis seperti yang tertera. Berkas gambar ada di `docs/proposal/gambar/`.
>
> **Urutan gambar 8.9–8.15 berubah sedikit dari yang sudah kamu tempel:**
> tukar posisi *Uji kelayakan* dengan *Pilihanmu*, supaya urutannya mengikuti
> alur fitur (uji kelayakan dulu, baru opsi pembiayaan). Penomoran di naskah
> ini mengikuti urutan tersebut.

---

# Bab VIII
# Mockup, Implementasi Antarmuka, dan Dokumentasi Penggunaan

## 8.1 Mockup High-Fidelity

Berbeda dari mockup statis, seluruh gambar pada bab ini merupakan tangkapan
layar aplikasi yang berjalan pada perangkat nyata (Realme RMX3630, Android 12,
API 31), bukan render dari perkakas desain. Dengan demikian, yang disajikan
bukan rancangan yang diusulkan, melainkan keadaan sistem yang telah dapat
dijalankan dan diverifikasi.

Antarmuka dibangun di atas satu berkas token desain tunggal, sehingga warna,
jarak, radius, dan ukuran huruf pada setiap layar bersumber dari definisi yang
sama. Tidak terdapat satu pun nilai warna literal maupun ukuran huruf di bawah
13sp pada keseluruhan kode antarmuka.

[GAMBAR: 8-01-splash.png, 8-02-tanpa-akun.png, 8-03-izin-perlindungan.png —
sejajar tiga kolom]

**Gambar 8.1 – 8.3 Pembuka dan pemasangan**

Layar "Tanpa Akun" pada Gambar 8.2 menggantikan fungsi layar masuk
konvensional. PIKIR meniadakan kolom masukan data, kata sandi, maupun
integrasi akun pihak ketiga. Sebagai gantinya, antarmuka ini menyajikan tiga
prinsip privasi utama: peniadaan pengumpulan data identitas berupa nama, nomor
telepon, dan surel; larangan transmisi data ke server eksternal; serta
peniadaan akses terhadap kontak maupun media pengguna.

Visualisasi pada Gambar 8.3 menyajikan kondisi aplikasi saat pemasangan awal
dengan status izin yang belum aktif. Representasi ini merefleksikan pengalaman
pengguna perdana, sekaligus mendemonstrasikan transparansi aplikasi dalam
menjelaskan fungsi izin, batas operasionalnya, serta konsekuensi apabila izin
tersebut dinonaktifkan. Pendekatan ini merupakan antitesis terhadap desain layar
izin konvensional yang cenderung meminta kepercayaan pengguna tanpa disertai
transparansi mengenai pemrosesan data.

[GAMBAR: 8-04-beranda.png, 8-05-intervensi-pinjol.png — sejajar dua kolom]

**Gambar 8.4 dan 8.5 Dasbor dan intervensi preventif**

Beranda menampilkan beban utang bulanan sebagai persentase terhadap total
pendapatan, dengan ambang batas aman 30% yang divisualisasikan melalui indikator
*gauge*. Ambang tersebut ditetapkan sebagai referensi umum, bukan aturan mutlak,
dan konsistensi penyebutannya dijaga pada seluruh antarmuka terkait.

Prinsip desain dasbor menghindari penggunaan warna merah secara arbitrer, yang
divalidasi melalui pengujian otomatis pada struktur *widget tree*. Pendekatan
ini menjaga integritas visual sistem peringatan: penggunaan elemen peringatan
yang prematur berisiko menurunkan efektivitas notifikasi kritis ketika situasi
darurat yang sebenarnya terjadi.

Gambar 8.5 merepresentasikan kondisi operasional intervensi yang dipicu oleh
*AccessibilityService*, yakni saat pengguna membuka aplikasi pinjaman daring
yang terdaftar pada daftar putih sistem. Layar PIKIR mengambil alih sebelum
konten tawaran pinjaman sempat terpapar kepada pengguna. Validasi alur
intervensi ini telah diverifikasi melalui pengujian pada aplikasi pinjaman
daring pihak ketiga di perangkat nyata. Terdapat tiga prinsip desain yang
mendasari keputusan produk pada layar ini:

1. **Simetri elemen pilihan.** Tidak terdapat hierarki visual eksplisit maupun
   opsi yang terpilih secara *default*, guna menjaga netralitas dan otonomi
   keputusan pengguna.
2. **Aksesibilitas jalan keluar.** Tombol "Lanjut ke aplikasi" ditampilkan
   dengan ukuran dan kontras penuh tanpa reduksi visibilitas, sebagai bentuk
   penghormatan terhadap hak pengguna dalam menentukan pilihan akhir.
3. **Atribusi sistem.** Identitas PIKIR ditempatkan secara konsisten pada bagian
   atas dan bawah layar, memastikan transparansi operasional sebagai aplikasi
   intervensi berbasis *overlay*.

[GAMBAR: 8-06-ledger.png, 8-07-atur-catatan.png, 8-08-lunas.png —
sejajar tiga kolom]

**Gambar 8.6 – 8.8 Ledger utang, pengaturan catatan, dan status lunas**

Penanganan penutupan catatan utang dipisahkan secara tegas menjadi dua tindakan
dengan konsekuensi berbeda. Penandaan lunas mempertahankan catatan di dalam
ledger namun mengeluarkannya dari perhitungan beban bulanan, sedangkan
penghapusan membuang catatan secara permanen dan diperuntukkan bagi koreksi
kesalahan pencatatan. Penyatuan keduanya ke dalam satu tindakan akan menyamakan
penyelesaian kewajiban dengan koreksi galat masukan, dua peristiwa yang secara
substansi berbeda.

Tindakan penghapusan mensyaratkan penekanan tahan selama lima detik, dengan
tombol pembatalan di sebelahnya yang berukuran identik. Friksi kognitif
diletakkan pada gerakan yang dituntut, bukan pada pengecilan maupun penyembunyian
pilihan.

[GAMBAR: 8-09-blanket-checkout.png, 8-10-biaya-kesempatan.png,
8-11-hasil-kebutuhan-mendesak.png, 8-12a-uji-kelayakan.png,
8-12-hasil-produktif.png, 8-13-notifikasi-pengganti.png, 8-14-tanya-pikir.png
— kisi empat kolom di baris atas, tiga kolom di baris bawah]

**Gambar 8.9 – 8.15 Alur lima fitur inti**

Gambar 8.10 menyajikan komponen inti Fitur 1, yakni penerjemahan biaya bunga
sebesar Rp64.000 ke dalam satuan yang konkret bagi pengguna, "setara 8 kali
makan, atau 1,5 hari penghasilanmu", disertai proyeksi kenaikan beban utang dari
18% menjadi 49% yang melampaui ambang aman. Ketiga pilihan yang disediakan di
bawahnya berukuran identik.

Gambar 8.11 memperlihatkan penegakan aturan jalur kebutuhan mendesak. Judul
layar berbunyi "Ini hakmu, bukan pinjaman", dan konten yang ditampilkan berupa
program BPJS Kesehatan PBI serta Program Sembako beserta sumber rujukannya.
Tidak terdapat satu pun produk pinjaman pada layar ini, dan secara arsitektural
tidak dimungkinkan untuk ada, sebagaimana diuraikan pada Subbab 8.2.2.

Gambar 8.12 dan 8.13 menyajikan jalur produktif secara berurutan: uji kelayakan
yang menghitung periode balik modal beserta rincian perhitungannya, kemudian
daftar opsi pembiayaan yang diurutkan berdasarkan kecepatan pencairan.

Gambar 8.14 mendemonstrasikan keberhasilan mekanisme intervensi notifikasi.
Notifikasi promosi pinjaman yang terdeteksi berisiko telah dihapus secara senyap
dan digantikan oleh notifikasi edukatif dari PIKIR, yang menyertakan alasan
pendeteksian beserta dua aksi lanjutan bagi pengguna.

Gambar 8.15 menyajikan keluaran Fitur 5, berupa jawaban yang dilengkapi
perhitungan eksplisit dan sitasi sumber rujukan.

---

## 8.2 Implementasi Antarmuka

### 8.2.1 Cakupan yang telah terbangun

| Aspek | Jumlah |
|---|---|
| Rute terdaftar | 42 |
| Layar selesai | 27 |
| Layar masih *placeholder* | 15 |
| Pengujian otomatis | 137, seluruhnya lulus |

Layar yang belum dibangun tidak disamarkan. Masing-masing menampilkan label
"Belum dibuat" beserta acuannya pada dokumen rancangan layar, sehingga tidak
terdapat layar kosong yang keliru terbaca sebagai layar jadi ketika aplikasi
didemonstrasikan.

### 8.2.2 Aturan antarmuka yang ditegakkan secara teknis

Keenam aturan berikut diturunkan dari kebutuhan non-fungsional pada Bab III,
bukan dari preferensi visual. Yang membedakannya dari pedoman desain pada
umumnya, sebagian besar aturan dijaga oleh pengujian otomatis, sehingga
pelanggarannya menyebabkan kegagalan *pipeline* alih-alih sekadar
ketidakrapian tampilan.

| Aturan | Wujud implementasi | Dijaga oleh |
|---|---|---|
| Status tidak pernah disampaikan melalui warna semata | Kombinasi warna, ikon, dan teks secara simultan | Komponen `StatusChip` mensyaratkan label non-kosong |
| Tidak ada opsi yang terpilih atau terisi lebih dahulu | Ketiadaan parameter "disarankan" pada komponen pilihan | Pengujian jalur mitigasi |
| Pilihan yang setara berukuran setara | Seluruh varian tombol bermetrik identik pada tinggi 56 | Pengujian pengukuran tinggi dan lebar tombol |
| Friksi diletakkan pada gerakan | Penekanan tahan lima detik dengan cincin progres, kontras tetap penuh | Pengujian tahan-untuk-hapus |
| Tanpa hitung mundur, *streak*, poin, maupun konfeti | Tidak terdapat pada keseluruhan kode | Pengujian penyapuan daftar kata terlarang |
| Jalur konsumtif dan mendesak tidak boleh memuat produk pinjaman | Ditegakkan pada tingkat model data | Objek `MitigationResult` menolak dibangun bila dilanggar |

Baris terakhir memerlukan penegasan tersendiri. Aturan tersebut tidak dijaga
pada lapisan tampilan, melainkan pada konstruktor model: objek hasil mitigasi
menolak dibangun apabila opsi pembiayaan menempel pada jalur konsumtif maupun
jalur kebutuhan mendesak. Konsekuensinya, pelanggaran terhadap aturan ini bukan
merupakan galat tampilan yang berpotensi lolos hingga tahap demonstrasi,
melainkan kegagalan yang muncul pada waktu pengembangan.

### 8.2.3 Tipografi dan keterbacaan

Huruf Plus Jakarta Sans dibundel sebagai aset aplikasi, bukan diunduh saat
aplikasi berjalan, sehingga konsistensi tipografi tetap terjaga tanpa koneksi
internet. Ukuran huruf terkecil pada keseluruhan antarmuka adalah 13sp.

Penskalaan huruf sistem secara sengaja tidak dibatasi. Kelompok pengguna sasaran
banyak yang menjalankan perangkatnya pada ukuran huruf besar, sehingga
pembatasan penskalaan berarti menukar keterbacaan pengguna dengan kemudahan tata
letak pengembang. Konsekuensi teknis dari keputusan ini diuji secara otomatis:
sapuan tata letak merender seluruh layar pada lebar 360dp dengan skala teks 1,3×
dan menggagalkan pengujian apabila terdapat satu saja elemen yang meluber.

---

## 8.3 Dokumentasi Penggunaan

### 8.3.1 Pemasangan dan penyiapan awal

Aplikasi PIKIR dipasang melalui berkas APK pada perangkat Android 11 (API Level
30) atau versi yang lebih baru. Setelah aplikasi dibuka, pengguna tidak
dihadapkan pada proses pendaftaran, pengisian kata sandi, maupun permintaan data
pribadi dalam bentuk apa pun. Penyiapan awal diselesaikan melalui satu penekanan
tombol pada layar "Tanpa Akun".

Selanjutnya, halaman "Izin Perlindungan" ditampilkan satu kali apabila masih
terdapat izin yang belum aktif. Pengguna dapat menunda pemberian izin melalui
tombol "Nanti saja" tanpa kehilangan akses ke aplikasi; seluruh fungsi manual
tetap dapat digunakan, dan hanya kapabilitas otomatis yang tidak berjalan.

Keempat izin berikut hanya dapat diberikan oleh pengguna sendiri melalui layar
pengaturan sistem operasi. Aplikasi dapat menjelaskan fungsi dan membukakan
layar pengaturan yang relevan, namun secara teknis tidak dapat mengaktifkannya
secara mandiri.

| Izin | Fungsi yang tidak berjalan tanpanya |
|---|---|
| Deteksi layar (Aksesibilitas) | Intervensi tidak muncul pada titik keputusan |
| Tampil di atas aplikasi lain | Pemicu terdeteksi namun layar intervensi tidak tampil |
| Akses notifikasi | Pemindai tidak menahan notifikasi berisiko |
| Mengirim notifikasi (Android 13+) | Notifikasi pengganti tidak sampai kepada pengguna |

Pada sebagian perangkat, penekanan tombol "Buka pengaturan" membuka daftar
seluruh aplikasi alih-alih halaman PIKIR secara langsung. Antarmuka
mengantisipasi hal ini dengan menyatakan kondisi tersebut sebelum pengguna
berpindah layar.

Selain izin sistem, tersedia pula saklar "Deteksi layar" pada halaman
Pengaturan. Saklar tersebut berfungsi sebagai kendali di dalam aplikasi yang
terpisah dari izin sistem operasi, sehingga pengguna dapat menonaktifkan deteksi
sementara waktu tanpa perlu mencabut izin aksesibilitas melalui pengaturan
Android.

### 8.3.2 Penggunaan Fitur 1 — Intervensi Preventif

Fitur ini tidak menuntut tindakan awal dari pengguna. Sistem muncul secara
otomatis pada dua kondisi pemicu:

1. **Pembukaan aplikasi pinjaman daring terdaftar.** Layar diambil alih
   seketika, kemudian sistem menampilkan pertanyaan "Kamu mau ngutang buat apa?"
   dengan dua opsi klasifikasi.
2. **Pembukaan halaman *checkout* dengan metode *paylater* terpilih.** Kedua
   syarat harus terpenuhi secara simultan. Pemicuan pada setiap proses
   *checkout* akan membiasakan pengguna menutup intervensi tanpa membacanya,
   sehingga melemahkan efektivitas sistem secara keseluruhan.

Tindak lanjut yang tersedia bagi pengguna diuraikan pada tabel berikut.

| Pilihan pengguna | Konsekuensi sistem |
|---|---|
| Kebutuhan mendesak atau modal kerja | Dialihkan ke alur Routing Mitigasi (Subbab 8.3.3) |
| Beli barang atau keinginan | Pengguna diminta menuliskan sendiri nama barang, lalu diarahkan ke layar biaya kesempatan |
| Lanjut ke aplikasi | Pengguna dikembalikan ke aplikasi yang sedang dibukanya, tanpa pertanyaan lanjutan |

Pada layar biaya kesempatan, tersedia tiga pilihan berukuran identik: menunda
pembelian disertai simulasi menabung, mencatat rencana ke ledger, atau tetap
melanjutkan peminjaman. Pilihan terakhir mensyaratkan penekanan tahan selama
lima detik.

Apabila proses analisis tidak memberikan hasil dalam tiga detik, atau perangkat
berada dalam kondisi luring, layar cadangan lokal mengambil alih dengan menyajikan
ajakan menarik napas. Keberadaan layar ini bersifat wajib: intervensi sedang
menutupi aplikasi lain, sehingga kegagalan yang dibiarkan tanpa penanganan akan
membuat perangkat pengguna tidak dapat digunakan.

### 8.3.3 Penggunaan Fitur 2 — Routing Mitigasi

Fitur ini dapat diakses melalui tab "Mitigasi" pada navigasi bawah, atau
diterima sebagai pengalihan dari Fitur 1. Alur terdiri atas dua hingga tiga
langkah bergantung pada jalur kebutuhan:

1. **Penentuan jenis kebutuhan**, melalui lima pilihan topik. Pengguna tidak
   pernah diminta menilai sendiri tingkat urgensi kebutuhannya; topik yang
   dipilih yang menentukan jalur penanganan.
2. **Penentuan nominal** yang benar-benar dibutuhkan, bukan nominal yang
   ditawarkan penyedia pinjaman.
3. **Penentuan untung bersih bulanan**, hanya ditanyakan pada jalur produktif.

Keluaran sistem bercabang secara mutlak sebagaimana tabel berikut.

| Jenis kebutuhan | Keluaran sistem |
|---|---|
| Barang atau keinginan | Biaya kesempatan dan simulasi menabung, tanpa produk pinjaman |
| Kesehatan, kebutuhan hidup, pendidikan | Program bantuan resmi beserta hak pengguna, tanpa produk pinjaman pada tingkat bunga berapa pun |
| Modal atau alat kerja | Uji kelayakan, dilanjutkan opsi pembiayaan yang diurutkan berdasarkan kecepatan pencairan |

Pengurutan berdasarkan kecepatan pencairan, bukan berdasarkan tingkat bunga
terendah, merupakan keputusan desain yang disengaja. Pengguna dengan alat kerja
rusak tidak memiliki kelonggaran waktu untuk menunggu pencairan yang lebih
lambat, dan penyembunyian opsi cepat justru berpotensi mengembalikan pengguna
kepada pinjaman daring predatori. Seluruh komponen biaya ditampilkan sebelum
keputusan diambil.

### 8.3.4 Penggunaan Fitur 3 — Notification Scanner

Fitur ini beroperasi di latar belakang tanpa memerlukan pembukaan aplikasi dan
tanpa koneksi internet. Perlakuan sistem terhadap notifikasi masuk dibedakan
menjadi tiga kategori.

| Kategori notifikasi | Perlakuan sistem |
|---|---|
| Bernada predatoris | Notifikasi asli dihapus senyap, digantikan peringatan edukatif dari PIKIR |
| Pengingat tagihan sah | Hanya dicatat, tidak pernah dihapus |
| Notifikasi umum | Hanya dicatat pada riwayat pemindaian |

Notifikasi pengganti senantiasa menyertakan dua aksi, yakni "Lihat alasannya"
dan "Tampilkan pesan aslinya". Aksi kedua bersifat wajib dan tidak dapat
dihilangkan dalam kondisi apa pun, sehingga pengguna tidak pernah kehilangan
akses terhadap pesan yang ditujukan kepadanya. Pesan asli ditampilkan kembali
secara utuh tanpa perubahan.

### 8.3.5 Penggunaan Fitur 4 — Kalkulasi Dana Darurat

Tab "Dana Darurat" menyajikan tiga tingkat target tabungan yang disusun
berdasarkan pengeluaran wajib dan tingkat risiko pekerjaan pengguna, bukan
berdasarkan patokan konvensional berupa kelipatan gaji bulanan yang tidak
relevan bagi pekerja berpendapatan harian. Setiap tingkat disertai keterangan
mengenai jenis kejadian yang dapat ditanggungnya, misalnya "menutup satu
kejadian: servis motor atau berobat mendadak".

### 8.3.6 Penggunaan Fitur 5 — PIKIR AI

Fitur diakses melalui tombol tengah pada navigasi bawah. Pengguna dapat
mengajukan pertanyaan finansial secara bebas, dan sistem menjawab dengan
menyertakan sitasi sumber. Pertanyaan di luar domain keuangan personal ditolak
dengan menyatakan batas kemampuan sistem, bukan dijawab secara spekulatif.

Dua ketentuan sesi berlaku dan perlu diketahui pengguna: sesi berubah menjadi
hanya-baca setelah dua jam tanpa aktivitas, dan riwayat percakapan terhapus
secara otomatis dalam siklus 24 jam.

### 8.3.7 Penggunaan Ledger Utang

Catatan utang masuk ke dalam ledger melalui dua jalur, yakni pencatatan otomatis
ketika pengguna memilih melanjutkan peminjaman setelah intervensi, dan
pencatatan manual melalui tombol "Tambah".

Setiap catatan dapat ditandai lunas, yang mempertahankan catatan namun
mengeluarkannya dari perhitungan beban bulanan dan dapat dibatalkan, atau
dihapus secara permanen dengan mensyaratkan penekanan tahan lima detik.

### 8.3.8 Privasi dan penghapusan data

Seluruh data tersimpan di dalam perangkat pada basis data terenkripsi AES-256
dengan kunci yang disimpan pada Android Keystore. Tidak terdapat satu pun
transmisi data keluar perangkat pada iterasi ini.

Menu "Hapus semua data di HP ini" pada halaman Pengaturan menghancurkan kunci
enkripsi sekaligus berkas basis datanya. Penghapusan berkas bersifat wajib dan
bukan tindakan tambahan: pengosongan tabel semata akan menyisakan *ciphertext*
pada penyimpanan yang terenkripsi dengan kunci yang telah dihancurkan.

### 8.3.9 Mode Demo

Untuk keperluan pengujian dan perekaman, halaman "Mode Demo" pada Pengaturan
menyediakan empat kendali yang menjalankan alur secara langsung tanpa memerlukan
pemicu eksternal: simulasi *checkout paylater*, simulasi pembukaan aplikasi
pinjaman, simulasi notifikasi pinjaman masuk, serta pengembalian data ke kondisi
awal.

Simulasi notifikasi menjalankan jalur klasifikasi, pencatatan, dan penggantian
yang sesungguhnya, bukan menampilkan representasi hasilnya. Dengan demikian,
perilaku yang tampak pada panel notifikasi merupakan perilaku sistem yang
sebenarnya.
