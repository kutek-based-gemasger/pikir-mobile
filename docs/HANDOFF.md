# PIKIR Mobile — Handoff

Status per 16 Agustus 2026. Berkas ini untuk anggota tim yang membaca repo ini
tanpa konteks percakapan sebelumnya, dan untuk menyusun Bab IV proposal.

**Kalau waktumu cuma lima menit:** baca bagian 1 (status), 3 (backlog), lalu
bagian 10 (sisa pekerjaan). Bagian 4 adalah katalog cara kerja tiap fitur,
lengkap dengan input dan outputnya — dibaca saat butuh, bukan berurutan.

| | Bagian |
|---|---|
| 1 | Ringkasan status |
| 2 | Hal paling penting untuk diketahui lebih dulu |
| 3 | Product Backlog |
| 4 | **Katalog fitur: mekanisme, input, dan output** |
| 5 | Layar: sudah jadi dan masih placeholder |
| 6 | Yang sudah dikerjakan, per bidang |
| 7 | Ketidaksesuaian dengan proposal |
| 8 | Cara menjalankan dan menguji |
| 9 | Yang perlu diperhatikan sebelum merekam demo |
| 10 | Sisa pekerjaan |

Dua berkas terpisah untuk keperluan proposal, bukan untuk pembaca repo:
`docs/proposal/BACKLOG.md` (revisi Tabel 4.2.1) dan
`docs/proposal/BAB_VIII.md` (draf Bab VIII beserta dokumentasi penggunaan).

---

## 1. Ringkasan status

| | |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` | 137 tes, semua lulus |
| `flutter build apk --debug` | Berhasil |
| Rute terdaftar | 42 |
| Layar sudah jadi | 27 |
| Layar masih placeholder | 15 |
| Story point Must selesai | **91 dari 122 (74,6%)** |

Diuji pada perangkat nyata: **Realme RMX3630, Android 12 (API 31)**.

---

## 2. Hal paling penting untuk diketahui lebih dulu

**Belum ada satu pun panggilan jaringan ke Backend.** Seluruh respons yang
seharusnya datang dari server disuplai oleh kontrak Mock API berupa data statis
terstruktur. Setiap titik integrasi ditandai di kode dengan `TODO(backend):`
beserta nama endpoint tujuannya:

| Endpoint | Dipakai oleh |
|---|---|
| `POST /api/v1/intervene/analyze` | Fitur 1, analisis intervensi |
| `POST /api/v1/mitigation/routing` | Fitur 2, perutean mitigasi |
| `POST /api/v1/notification/generate-warning` | Fitur 3, kalimat peringatan |
| `POST /api/v1/planning/emergency-fund` | Fitur 4, target bertingkat |
| `POST /api/v1/chat/advisor` | Fitur 5, jawaban bersitasi |

Cari dengan `grep -rn "TODO(backend)" lib/` untuk melihat semua titiknya.

**Yang sudah selesai penuh tanpa backend** (murni on-device, tidak menunggu
server): deteksi pemicu lewat AccessibilityService, pemindai notifikasi,
enkripsi basis data lokal, dan ledger utang.

---

## 3. Product Backlog

> Versi yang sudah diaudit ulang per item, lengkap dengan kolom bukti dan dua
> perhitungan persentase, ada di **`docs/proposal/BACKLOG.md`**. Tabel di bawah
> adalah ringkasannya.

Status **Done (kontrak Mock API)** berarti alur klien memenuhi acceptance
criteria dan teruji pada perangkat, dengan respons Backend disuplai data
statis. Status **Done (penuh)** berarti item itu memang tidak memerlukan server
dan sudah selesai seutuhnya.

| ID | User Story | MoSCoW | SP | Sprint | Status | Sisa |
|---|---|---|---|---|---|---|
| PB-01 | Fondasi arsitektur klien, ledger tiga field, kontrak Mock API | Must | 15 | 1 | Done (penuh) | — |
| PB-02 | Klasifikasi kebutuhan otonom / pertanyaan interaktif singkat | Must | 8 | 1 | Done (kontrak Mock API) | Ganti mock dengan endpoint |
| PB-03 | Opportunity cost, rasio 30%, simulasi menunda | Must | 13 | 2 | Done (kontrak Mock API) | Ganti mock dengan endpoint |
| PB-04 | Kebutuhan mendesak diantar tanpa pertanyaan tambahan | Must | 10 | 2 | Done (kontrak Mock API) | Ganti mock dengan endpoint |
| PB-05 | Informasi program bantuan resmi bersumber | Must | 8 | 3 | Done (kontrak Mock API) | Data program masih fixture |
| PB-06 | Kebutuhan bertahan hidup ke bantuan sosial, bukan pinjaman | Must | 8 | 3 | Done (kontrak Mock API) | Ganti mock dengan endpoint |
| PB-07 | Uji kelayakan margin & payback, opsi diurutkan waktu cair | Must | 16 | 4 | Done (kontrak Mock API) | Data pembiayaan masih fixture |
| PB-08 | Target dana darurat bertingkat + pengingat | Must | 8 | 4 | **In Progress** | 3 layar |
| PB-09 | Tanya bebas, jawaban bersitasi, tolak topik luar | Must | 23 | 5 | **In Progress** | 2 layar |
| PB-12 | Deteksi pemicu on-device: AccessibilityService, whitelist aplikasi, deteksi checkout + paylater | Must | 13 | 4 | Done (penuh) | Verifikasi 8 nama paket |
| PB-10 | Notifikasi mencurigakan dihapus senyap + peringatan edukatif | Should | 13 | 6 | Done (penuh) | AC terpenuhi; 3 layar riwayat menyusul di luar AC |
| PB-11 | Istilah bahasa sehari-hari + riwayat keputusan | Should | 8 | 6 | Done (penuh) | — |

**Must: 91 dari 122 SP = 74,6% Done.** Item Should dan Could dikeluarkan dari
penyebut. Item *In Progress* **tidak dihitung** — Definition of Done bersifat
biner, tidak ada kredit parsial.

### PB-12 itu item baru

Backlog lama tidak punya item apa pun untuk AccessibilityService, padahal KF-01
menulis *"pada saat trigger terdeteksi"* seolah pemicunya sudah ada. Tanpa item
ini, PB-02 dan PB-04 terlihat selesai padahal skenarionya belum bisa terjadi di
dunia nyata. Ditambahkan sebagai temuan inspeksi, sejalan dengan narasi
adaptasi backlog di Bab IV.

### Kenapa PB-08 dan PB-09 belum Done

- **PB-08** — dasbor target bertingkat sudah jadi, tapi layar hitung target,
  catat setoran, dan pengingat menabung masih placeholder.
- **PB-09** — chat, sitasi, penolakan topik luar, sesi read-only 2 jam, dan
  penghapusan 24 jam sudah jalan. Yang belum: layar konfirmasi catat ke ledger
  dari chat, dan layar sumber jawaban.

---

## 4. Katalog fitur: mekanisme, input, dan output

Bagian ini menjawab "fitur ini sebenarnya kerjanya bagaimana". Tiap fitur ditulis
dengan urutan yang sama: **apa yang memicunya → apa yang masuk → apa yang
diproses → apa yang keluar**. Nama berkas disertakan supaya bisa langsung dibuka.

Yang perlu diingat saat membaca: bagian **proses** untuk Fitur 1, 2, 4, dan 5
dijalankan oleh kontrak Mock API di dalam perangkat, bukan server. Aturannya
nyata dan deterministik, jadi bisa didemokan dan diuji, tapi belum ada model atau
kecerdasan apa pun di baliknya.

---

### Fitur 1 — Intervensi preventif

**Berkas:** `ScreenWatcherService.kt`, `TriggerRules.kt`,
`lib/features/intervention/`

#### Pemicu

Dua jalur, dan syaratnya berbeda. Ini bagian yang paling sering salah dipahami:

| Jalur | Syarat menyala | Kenapa begitu |
|---|---|---|
| Aplikasi pinjaman | Paket ada di whitelist **dan** jendelanya berganti (`TYPE_WINDOW_STATE_CHANGED`) | Membuka aplikasi pinjol sudah cukup jadi tanda |
| Checkout paylater | Teks layar mengandung kata checkout **DAN** kata paylater | Satu syarat saja akan menginterupsi tiap belanja biasa, dan penggunanya akan belajar menutup PIKIR tanpa membaca |

Pengaman lain di lapisan ini:

- **Jeda 30 detik** antar pemicu, supaya satu sesi belanja tidak diblokir
  berkali-kali.
- **Maksimal 400 node** dibaca per layar, supaya pembacaan tidak membebani HP.
- Cakupannya dibatasi Android sendiri lewat `android:packageNames` di
  `accessibility_service_config.xml` — di luar daftar itu, sistem operasi tidak
  pernah mengirim event apa pun ke PIKIR.

#### Input

| Yang masuk | Dari mana | Contoh |
|---|---|---|
| Nama paket | AccessibilityService | `com.fintopia.idnEasycash.google` |
| Teks layar | Pembacaan node, dibuang setelah dipakai | "Checkout... Bayar nanti... Rp1.250.000" |
| Nominal | Regex `rp\s?([0-9][0-9.,]{3,})` | `1250000` |

Ekstraksi nominal mengambil **angka terbesar** di layar dan mengabaikan yang di
bawah Rp10.000, karena angka kecil biasanya harga satuan atau ongkir, bukan total
yang akan dikomitmen penggunanya.

#### Proses

1. Layar diblokir seketika dengan layar selimut (`blanket_screen.dart`).
2. Analisis dijalankan dengan **tenggat keras 3 detik**
   (`kInterventionTimeout`) memakai `.timeout()`, bukan balapan dengan
   `Future.delayed` — versi balapan meninggalkan timer hidup di belakang tiap
   intervensi.
3. Aturan mock: hitung rasio beban sekarang, dan rasio seandainya cicilan ini
   ditambahkan.

#### Output

Tiga akhir yang mungkin, semuanya sudah jalan:

| Kondisi | Hasil | Layar |
|---|---|---|
| Selisih rasio ≥ 2 poin persen | Layar biaya kesempatan | `opportunity_cost_screen.dart` |
| Selisih rasio < 2 poin persen | Langsung tawaran catat ke ledger | `catat_ledger_screen.dart` |
| Tidak ada jawaban dalam 3 detik, atau gagal | Layar luring + ajakan tarik napas | `fallback_luring_screen.dart` |

Di layar biaya kesempatan, penggunanya diberi **tiga pilihan berukuran sama**:
menunda dan menabung, mencatat ke ledger, atau tetap lanjut. Yang terakhir pakai
tahan 5 detik — friksinya ada di gerakan, bukan di menyembunyikan tombolnya.

Jalur aplikasi pinjaman bercabang lebih dulu lewat pertanyaan **"Kamu mau ngutang
buat apa?"**: jawaban *mendesak atau modal* menyerahkan ke Fitur 2, jawaban
*konsumtif* meminta penggunanya mengetik sendiri nama barangnya (tidak pernah
ditebakkan aplikasi) lalu masuk ke biaya kesempatan.

**Keluar dari intervensi:** "Lanjut ke aplikasi" memanggil `moveTaskToBack`, jadi
penggunanya kembali ke aplikasi yang tadi dibuka — bukan berpindah lebih dalam ke
PIKIR. Dari Mode Demo tidak ada aplikasi di bawah, jadi tombol yang sama kembali
ke layar demo.

---

### Fitur 2 — Routing mitigasi

**Berkas:** `lib/features/mitigation/`, `lib/data/models/mitigation.dart`

#### Input

| Langkah | Yang ditanyakan | Wajib untuk |
|---|---|---|
| 1 | Kebutuhannya untuk apa (5 pilihan) | Semua jalur |
| 2 | Berapa yang benar-benar dibutuhkan | Semua jalur |
| 3 | Untung bersih per bulan | Hanya jalur produktif |

Jalur konsumtif dan mendesak berhenti di 2 langkah, produktif 3.

#### Proses: percabangan tiga, bukan dua

Topik menentukan jalur secara otomatis. Penggunanya tidak pernah diminta menilai
sendiri seberapa mendesak kebutuhannya:

| Topik yang dipilih | Jalur |
|---|---|
| Barang atau keinginan | **Konsumtif** |
| Modal atau alat kerja | **Produktif** |
| Kesehatan, kebutuhan hidup, pendidikan | **Kebutuhan mendesak** |

#### Output per jalur

| Jalur | Yang ditampilkan | Yang **tidak boleh** muncul |
|---|---|---|
| Konsumtif | Biaya kesempatan, simulasi menabung | Produk pinjaman, bantuan sosial |
| Kebutuhan mendesak | Program bantuan resmi dan hak-hak penggunanya | Produk pinjaman, pada bunga berapa pun |
| Produktif | Uji kelayakan, lalu opsi pembiayaan | — |

Uji kelayakan pada jalur produktif:

```
payback (hari) = nominal ÷ (untung bersih bulanan ÷ 30)
layak          = untung bersih > 0  DAN  payback ≤ 90 hari
```

Hasilnya selalu disertai kalimat hitungannya, supaya bisa diperiksa penggunanya
dan bukan vonis yang turun entah dari mana.

**Opsi pembiayaan diurutkan berdasarkan kecepatan cair, bukan bunga termurah.**
Ini disengaja: orang yang motornya rusak hari ini tidak bisa menunggu tiga hari
demi bunga yang lebih rendah, dan menyembunyikan yang cepat justru mendorongnya
balik ke pinjol. Semua biaya — pokok, bunga, biaya layanan, biaya admin, dan
total yang harus dikembalikan — ditampilkan sebelum keputusan diambil.

**Aturan §6.7 ditegakkan di tingkat model, bukan di UI.** `MitigationResult`
menolak dibangun kalau opsi pembiayaan menempel pada hasil konsumtif atau
kebutuhan mendesak, dan sebaliknya untuk program bantuan. Artinya melanggar
aturan ini bukan bug tampilan yang bisa lolos sampai ke rekaman — aplikasinya
gagal saat dikembangkan.

---

### Fitur 3 — Pemindai notifikasi

**Berkas:** `NotificationService.kt`, `NotificationClassifier.kt`,
`ScanLogStore.kt`

#### Input

Judul dan isi tiap notifikasi yang masuk, dari aplikasi mana pun **kecuali PIKIR
sendiri**. Pengecualian itu wajib: tanpanya, notifikasi pengganti yang PIKIR
pasang akan ikut dipindai lalu diganti lagi, tanpa henti.

#### Proses

1. **Normalisasi**: huruf dikecilkan, lalu huruf berulang diciutkan. Ini yang
   membuat `caiiiir` dan `cair` dianggap sama — trik paling umum untuk lolos dari
   filter kata.
2. **15 frasa predatoris** dicek, masing-masing punya alasan yang ikut
   ditampilkan ke penggunanya. Contoh: *"tanpa BI checking"* → *"Menghindari
   pemeriksaan yang wajib pada pemberi pinjaman resmi."*
3. Kalau tidak ada yang cocok, **4 pola tagihan** dicek (`jatuh tempo`,
   `bayar minimum`, `segera bayar`, `tagihan ...`).

Penanda `// TODO(ml)` sudah dipasang di titik ini untuk penggantian TFLite nanti.

#### Output

| Hasil | Yang terjadi |
|---|---|
| **Mencurigakan** | Notifikasi aslinya dihapus senyap, PIKIR memasang notifikasi edukatif sebagai gantinya |
| **Tagihan** | Hanya dicatat. **Tidak pernah dihapus** — tagihan asli itu urusan penggunanya sendiri |
| **Aman** | Hanya dicatat di riwayat |

Notifikasi pengganti **selalu** membawa dua aksi berukuran sama: **"Lihat
alasannya"** dan **"Tampilkan pesan aslinya"**. Yang kedua tidak boleh hilang
dalam keadaan apa pun — penggunanya tidak pernah boleh dikunci dari pesannya
sendiri.

**Yang disimpan:** potongan 120 karakter beserta pesan aslinya (supaya bisa
ditampilkan lagi), terhapus otomatis dalam 24 jam. Lihat bagian ketidaksesuaian
proposal: klaim "tidak disimpan sama sekali" tidak bisa digabung dengan fitur ini.

---

### Fitur 4 — Dana darurat bertingkat

**Berkas:** `lib/features/emergency_fund/`, `MockEmergencyFundRepository`

#### Input

Pengeluaran wajib bulanan, dan seberapa sering pekerjaannya berhenti (risiko
kerja).

#### Proses

```
Tingkat 1 = bulatkan(pengeluaran wajib × bobot risiko ÷ 2, ke 50.000)
Tingkat 2 = Tingkat 1 × 2
Tingkat 3 = pengeluaran wajib × 3
```

Disusun dari angka penggunanya sendiri, bukan dari patokan "3–6 bulan gaji" yang
tidak bertahan kalau penghasilannya harian. Tingkat 3 ditandai opsional justru
karena untuk kebanyakan pengguna sasaran, angka itu memang jauh.

#### Output

Tiga target, masing-masing dengan keterangan **apa yang ditutupnya** (misal:
"Menutup satu kejadian: servis motor atau berobat mendadak"), plus posisi
tabungan sekarang. Tanpa streak, tanpa poin, tanpa perbandingan dengan pengguna
lain.

---

### Fitur 5 — Tanya PIKIR

**Berkas:** `lib/features/chat/`, `lib/data/models/chat.dart`

#### Input

Pertanyaan bebas. Yang dikirim ke pemroses hanya **10 pesan terakhir**, bukan
seluruh riwayat.

#### Proses

Penolakan topik luar dicek lebih dulu: pertanyaan soal saham, kripto, atau
trading dijawab dengan penolakan yang menyebutkan batas kemampuan aplikasi, bukan
dijawab asal.

#### Output

Jawaban yang membawa sitasi sumber, dengan dua aturan sesi:

| Aturan | Nilai | Alasannya |
|---|---|---|
| Sesi jadi hanya-baca | Setelah 2 jam tanpa aktivitas | Percakapan lama bukan konteks yang aman untuk dilanjutkan |
| Riwayat dihapus | 24 jam | Ditegakkan di lapisan penyimpanan, jalan tiap basis data dibuka |

Chat juga bisa dimasuki konteks dari layar lain: tombol "Tanya lebih lanjut" di
kartu rute mitigasi membuka sesi yang sudah tahu sedang membahas apa.

---

### Ledger utang

**Berkas:** `lib/features/ledger/`, `debt_entry.dart`

#### Input

| Sumber | Kapan |
|---|---|
| Otomatis | Penggunanya memilih lanjut setelah intervensi |
| Manual | Form "Tambah" di Ledger |

Satu catatan berisi: keperluan (kata-kata penggunanya sendiri), pokok, cicilan per
bulan, kategori (boleh dikosongkan), sumber, dan tanggal.

#### Proses

```
rasio beban = total cicilan bulanan utang berjalan ÷ penghasilan bulanan
batas aman  = 30%   (patokan umum, bukan aturan — tiap layar menyebutkannya begitu)
```

Cicilan yang belum diisi ditulis **"Cicilan belum diisi"**, bukan "Rp0 per bulan"
— kosong artinya belum diketahui, dan bedanya penting karena angka inilah yang
membentuk rasio.

#### Output

Total utang aktif, rasio beban dengan status berkata-kata, dan daftar catatan.
Dua aksi per catatan:

| Aksi | Efek | Bisa dibatalkan? |
|---|---|---|
| **Tandai lunas** | Catatan tetap ada, keluar dari total dan dari rasio | Ya |
| **Hapus catatan** | Barisnya hilang permanen, pakai tahan 5 detik | Tidak |

---

### Lapisan penyimpanan

**Berkas:** `pikir_database.dart`, `secure_key_store.dart`

| Hal | Nilai |
|---|---|
| Basis data | SQLite via SQLCipher, **AES-256** |
| Kunci | 256 bit dari sumber acak kriptografis, disimpan di **Android Keystore** |
| Versi skema | 2 (`settled_at` ditambah lewat `ALTER TABLE`, bukan drop-recreate) |
| Keluar jaringan | Tidak ada sama sekali |
| Hapus semua data | Menghancurkan kuncinya **dan** berkas basis datanya |

Penghapusan berkas itu bukan kelebihan: mengosongkan tabel saja akan meninggalkan
ciphertext di disk yang terenkripsi dengan kunci yang sudah dihancurkan, dan
basis data itu tidak akan pernah bisa dibuka lagi.

---

### Izin dan layanan latar

| Izin | Untuk apa | Kalau mati |
|---|---|---|
| Aksesibilitas | Mengenali checkout paylater dan pembukaan aplikasi pinjaman | Intervensi tidak pernah menyala |
| Tampil di atas aplikasi lain | Menampilkan layar PIKIR di atas aplikasi lain | Pemicunya menyala tapi layarnya tidak pernah muncul |
| Akses notifikasi | Membaca notifikasi yang masuk | Pemindai tidak menahan apa pun |
| Mengirim notifikasi (Android 13+) | Memasang notifikasi pengganti | Pemindai jalan tapi penggunanya tidak diberi tahu |

Semua dikelola dari satu halaman: **Pengaturan → Izin perlindungan**, yang juga
muncul otomatis sekali tiap aplikasi dibuka selama masih ada izin yang mati.

Kedua layanan Android berjalan terus meski UI PIKIR ditutup.

---

## 5. Layar

### Sudah jadi (27)

**Pembuka:** Splash, Tanpa Akun (layar masuk).

**Dasbor & pengaturan:** Beranda, Ledger Utang (dengan tab Riwayat Keputusan),
Tambah Utang Manual, Dasbor Dana Darurat, Tanya PIKIR, Pengaturan, Izin
Perlindungan, Privasi dan Data Saya, Mode Demo.

**Fitur 1, intervensi (6):** Blanket Checkout Paylater, Prompt Intervensi
Aplikasi Pinjol, Input Barang Konsumtif, Overlay Opportunity Cost (termasuk
tahan 5 detik), Pengalihan ke Form Ledger, Fallback Luring.

**Fitur 2, mitigasi (9):** Klasifikasi Kebutuhan, Nominal, Untung Bersih, Uji
Kelayakan, Hasil Jalur Konsumtif, Hasil Jalur Kebutuhan Mendesak, Hasil Jalur
Produktif, Detail Program Bantuan, Detail Opsi Pembiayaan.

**Perkakas:** Peta Layar (alat pengembangan, bukan bagian produk).

### Masih placeholder (15)

| Kelompok | Layar |
|---|---|
| Onboarding (5) | Onboarding, Izin Deteksi Layar, Izin Akses Notifikasi, Profil Finansial, Penyiapan Selesai |
| UI Pemindai (3) | Detail Peringatan, Tagihan Terdeteksi, Pengaturan & Riwayat Pemindaian |
| Dana Darurat (3) | Hitung Dana Darurat, Catat Setoran, Pengingat Menabung |
| Chat (2) | Sumber Jawaban, Konfirmasi Catat ke Ledger |
| Lain (2) | Detail Rasio Utang, Klasifikasi Urgensi |

Placeholder menampilkan label **"Belum dibuat"** beserta acuannya di SCREENS.md,
supaya layar yang belum jadi tidak pernah tersamar sebagai layar yang sudah jadi
saat demo.

**Rute yang dihapus:** `/ledger/riwayat` — riwayat keputusan sudah menjadi tab
di dalam Ledger, jadi satu pintu bukan dua. `/mitigasi/urgensi` masih terdaftar
tapi kandidat dihapus, karena percabangan sudah ditentukan penuh di langkah 1.

**Perlu diputuskan saat onboarding dikerjakan:** dua placeholder
`/onboarding/izin-layar` dan `/onboarding/izin-notifikasi` sekarang tumpang
tindih dengan `/pengaturan/izin` yang sudah jadi. Sebaiknya keduanya memakai
ulang isi halaman itu atau dihapus, jangan ditulis ulang — teks izin yang
bercabang dua tempat pasti akan menyimpang satu sama lain.

---

## 6. Yang sudah dikerjakan

### Fondasi

- Token desain lengkap dari DESIGN.md di `lib/core/theme/`. Tidak ada satu pun
  warna literal atau ukuran huruf di bawah 13sp di seluruh `lib/`.
- Font Plus Jakarta Sans di-bundel sebagai aset (bukan diunduh saat runtime),
  supaya tipografi tetap benar tanpa koneksi.
- 11 widget bersama di `lib/core/widgets/`, termasuk `PikirButton` yang semua
  variannya bermetrik identik dan `HoldToConfirmButton` dengan tahan 5 detik.
- Router berbasis registri tunggal: satu daftar jadi sumber rute sekaligus peta
  layar, jadi keduanya tidak bisa berbeda.

### Data

- Model, interface repository, implementasi mock, dan data seed terkunci ke
  angka CLAUDE.md §8 (3 utang Rp3.150.000, rasio 18%, dana darurat Rp450.000).
- **Percabangan tiga jalur ditegakkan di tingkat model**: `MitigationResult`
  menolak dibangun kalau opsi pembiayaan menempel di hasil konsumtif atau
  kebutuhan mendesak. Aturan §6.7 jadi mustahil dilanggar tanpa mengubah model.

### Penyimpanan terenkripsi (KNF-02)

- SQLite lewat **SQLCipher, AES-256**, di `lib/data/local/pikir_database.dart`.
- Kunci 256 bit dari sumber acak kriptografis, disimpan di **Android Keystore**
  lewat `flutter_secure_storage` — bukan di berkas aplikasi.
- Terbukti di perangkat: 16 byte pertama `pikir.db` adalah byte acak, bukan
  `SQLite format 3` yang selalu mengawali SQLite polos.
- Penghapusan chat 24 jam ditegakkan oleh penyimpanannya, berjalan tiap kali
  basis data dibuka.

### Fitur 1 — intervensi preventif

- `ScreenWatcherService.kt`, AccessibilityService dari nol tanpa pustaka luar.
- **Aturan dua syarat**: checkout **DAN** paylater, tidak boleh salah satu.
  Aplikasi pinjaman diblokir begitu dibuka.
- Cakupan aksesnya dibatasi oleh Android sendiri lewat `android:packageNames`
  di `accessibility_service_config.xml` — di luar daftar itu, sistem operasi
  tidak pernah mengirim event apa pun.
- **Terbukti di perangkat**: membuka Easycash memunculkan layar intervensi
  dalam 1 detik.

### Fitur 3 — pemindai notifikasi

- `NotificationService.kt` dari nol. Notifikasi aman dan tagihan dibiarkan utuh
  tanpa tanda PIKIR; hanya yang predatoris dibungkam lalu diganti.
- Notifikasi pengganti **wajib** membawa aksi "Tampilkan pesan aslinya". Teks
  asli disimpan sebelum dibungkam lalu diposting ulang apa adanya.
- Klasifikasi deterministik (kata kunci + regex, dengan alpha-squashing untuk
  menangkal penyamaran huruf). Titik TFLite ditandai `TODO(ml)`.
- **Terbukti di perangkat**: notifikasi uji berisi *"Cair 3 menit tanpa BI
  Checking"* ditahan dan diganti.

### Alur masuk aplikasi

Sebelumnya aplikasi mendarat di **Peta Layar**, yang sebenarnya alat
pengembangan. Sekarang urutannya seperti aplikasi biasa:

**Splash → Tanpa Akun → (Izin, kalau ada yang mati) → Beranda.**

- **Splash** menampilkan mark dan tagline, lalu maju sendiri setelah 1,6 detik.
  Tidak ada yang dimuat di sini — tidak ada backend, dan basis data lokal
  terbuka dalam milidetik, jadi progress bar cuma sandiwara. Timernya membatalkan
  diri kalau ada layar lain yang sudah naik, supaya intervensi dari
  AccessibilityService tidak tergusur timer yang berjalan sebelum ia ada.
- **Tanpa Akun** menempati slot layar masuk. Tidak ada kolom isian, tidak ada
  kata sandi, tidak ada "lanjut dengan Google" — cuma satu tombol dan tiga janji
  yang dinyatakan sebagai hal yang **tidak** dilakukan aplikasi.
- **Beranda** menggantikan keduanya, bukan menumpuk, jadi tombol back di Beranda
  keluar dari aplikasi dan bukan berjalan mundur lewat pembukaan.

Ada tes yang menjaga layar Tanpa Akun tidak menumbuhkan form login: tidak boleh
ada `TextField`, `CircleAvatar`, maupun kata "Daftar", "Kata sandi", "Email",
"Nomor HP", atau "Masuk dengan". Layar itu duduk persis di tempat layar sign-in
biasanya berada, jadi di situlah aturan §2.2 paling gampang bocor.

### Menutup catatan utang: lunas dan hapus

Tiap kartu di Ledger punya tombol **"Atur catatan ini"** yang membuka sheet
berisi dua pilihan berukuran sama, tidak ada yang dipilih lebih dulu:

| | Artinya | Efeknya |
|---|---|---|
| **Tandai lunas** | Utangnya selesai | Catatan tetap ada, tapi keluar dari total dan dari rasio beban bulanan |
| **Hapus catatan** | Salah catat | Barisnya hilang permanen |

Bedanya dijaga betul, karena satu `removeDebt` untuk keduanya akan menyamakan
akhir yang baik dengan koreksi salah ketik — dan menghapus utang yang lunas
justru membuang bagian ledger yang paling layak dilihat lagi.

- **Lunas bisa dibatalkan.** Tanpa itu, salah pencet cuma bisa diperbaiki dengan
  menghapus catatannya, yang rugi lebih besar daripada salahnya.
- **Hapus pakai tahan 5 detik**, bukan satu ketukan, dan tombol "Batal" di
  sebelahnya berukuran sama persis (§6.4 dan §6.3). Kartu peringatannya menyebut
  apa yang hilang, bukan bertanya "yakin?".
- **Tidak ada perayaan** saat lunas — tidak ada konfeti, poin, atau "Selamat!".
  Melunasi utang itu kerja penggunanya sendiri; aplikasi ikut bertepuk tangan
  berarti ikut mengambil kredit. Ada tes yang menjaga ini (§6.5).
- Kartu lunas ditandai warna **plus ikon plus kata "Lunas"**, bukan sekadar
  diredupkan, dan pindah ke bawah daftar.

Skema basis data naik ke **versi 2** (`settled_at`), dengan `onUpgrade` yang
menambah kolom lewat `ALTER TABLE`. Bukan drop-and-recreate: penyimpanan lokal
ini satu-satunya salinan ledger pengguna dan tidak ada server untuk memulihkan.

Terbukti di RMX3630: setelah satu utang ditandai lunas, beban di Beranda turun
dari **21% ke 18%** dan totalnya dari Rp843.123 ke Rp720.000 — persis sebesar
cicilan utang yang dilunasi.

### Logo dan ikon aplikasi

Logo PIKIR (perisai dengan siluet kepala dan otak) sekarang dipakai di tiga
tempat, semuanya dari satu berkas `assets/brand/pikir_logo.png`:

| Tempat | Bentuk |
|---|---|
| Splash | Perisai langsung di atas hijau, 132dp |
| `PikirMark` | Perisai + wordmark, dipakai di app bar dan overlay |
| Ikon launcher | Ikon adaptif Android: perisai di atas ground putih |

Ikon launchernya dibuat ulang untuk 5 kerapatan layar sekaligus dalam dua
bentuk: `ic_launcher_foreground.png` untuk **ikon adaptif** (kanvas 108dp,
gambar dijaga di dalam zona aman 72dp supaya tidak terpotong topeng launcher)
dan `ic_launcher.png` legacy untuk launcher yang mengabaikan ikon adaptif.
Karena minSdk 30, yang hampir selalu terlihat adalah versi adaptifnya.

Ground-nya putih, bukan hijau: marknya sendiri hijau, dan hijau di atas hijau
hanya menyisakan kepala pucatnya yang terbaca pada ukuran ikon. Alasan yang sama
membuat `PikirLogo` punya opsi `onDark` yang memberi piringan putih saat
diletakkan di atas latar hijau.

Berkas pembuatnya bukan skrip yang disimpan — kalau logonya diganti, jalankan
ulang pembuatan ikon dari `assets/brand/pikir_logo.png` ke lima folder
`mipmap-*`.

### Saklar deteksi layar

Sebelumnya deteksi layar hanya bisa dimatikan dengan mencabut izin
aksesibilitas lewat pengaturan Android — merepotkan, dan gampang lupa
menyalakannya lagi. Sekarang ada saklar di **Pengaturan → Deteksi layar**.

Yang penting dipahami: **saklar ini bukan izinnya.** Keduanya harus hidup supaya
intervensi menyala, dan keduanya mati karena sebab yang berbeda.

| | Izin aksesibilitas | Saklar di aplikasi |
|---|---|---|
| Diberikan di | Pengaturan Android | Dalam PIKIR |
| Disimpan di | Sistem operasi | `WatcherSettings`, SharedPreferences |
| Default | Mati sampai diberikan | **Hidup** |

Pengecekannya ditaruh di `onAccessibilityEvent` **sebelum** apa pun dibaca, jadi
saat dimatikan PIKIR benar-benar berhenti melihat — bukan tetap membaca lalu
diam saja. Barisnya juga menampilkan jumlah aplikasi terdaftar, dibaca dari
whitelist Kotlin lewat channel, supaya angkanya tidak bisa menyimpang dari
daftar yang sebenarnya mengatur deteksi.

Halaman Izin perlindungan ikut menyebutkan keadaan "izin aktif tapi saklarnya
mati", karena tanpa itu satu-satunya cara pengguna menemukannya adalah dengan
heran kenapa tidak terjadi apa-apa.

### Pusat izin

Satu halaman, `/pengaturan/izin`, dipakai dua arah: muncul otomatis sekali tiap
aplikasi dibuka selama masih ada izin yang mati, dan bisa dibuka kapan saja dari
Pengaturan → Izin perlindungan (barisnya menampilkan "N dari 3 izin aktif").

- Tiap kartu menyebut tiga hal: apa yang bisa dilakukan izin itu, **di mana
  batasnya**, dan apa yang tidak jalan selama izin itu mati. Statusnya warna +
  ikon + kata, tidak pernah warna saja (§6.1).
- Popup-nya tidak memaksa: "Nanti saja" berukuran penuh, sama besar dengan
  tombol lain (§6.3), dan hanya muncul sekali per sesi. Kalau aplikasi dibuka
  karena pemicu intervensi, popup ini dilewati supaya tidak menutupi hal yang
  justru ditunggu pengguna.
- Status dibaca ulang tiap kembali ke aplikasi, karena izinnya diberikan di
  pengaturan Android, bukan di sini.
- ColorOS mengabaikan `package:` pada intent overlay dan membuka daftar semua
  aplikasi, jadi kartunya menyebutkan itu di muka: *"Nanti terbuka daftar
  aplikasi. Cari PIKIR di situ, lalu nyalakan."*
- Dua kartu izin yang dulu terduplikasi di Mode Demo diganti satu ringkasan yang
  menunjuk ke halaman ini.

Terbukti di RMX3630: halaman muncul sendiri saat dibuka, hitungannya berubah
dari "2 dari 3" ke "1 dari 3" setelah izin overlay dinyalakan, dan kartunya
berubah jadi "Aktif" begitu kembali dari pengaturan Android.

#### Bug yang diperbaiki: status aksesibilitas selalu "Belum aktif"

Pengecekannya membandingkan teks:

```kotlin
enabled.contains("$packageName/.ScreenWatcherService")   // salah
```

Android menulis entrinya dalam bentuk panjang,
`com.pikir.pikir/com.pikir.pikir.ScreenWatcherService`, sementara manifes dan
konstanta di kode memakai bentuk pendek `.ScreenWatcherService`. Substring-nya
tidak pernah cocok, jadi aplikasi melaporkan layanan itu mati **padahal sedang
berjalan** — pemicunya bekerja, statusnya saja yang bohong.

Sekarang keduanya di-*unflatten* jadi `ComponentName` lalu dibandingkan, yang
benar untuk kedua bentuk penulisan. Pengecekan akses notifikasi ikut diperbaiki:
sebelumnya cuma `flat.contains(packageName)`, yang bisa cocok dengan paket lain
yang namanya kebetulan memuat nama paket kita.

Terbukti di perangkat lewat izin akses notifikasi, yang tersimpan dalam bentuk
panjang yang sama (`com.pikir.pikir/com.pikir.pikir.NotificationService`) dan
kini terbaca **Aktif** oleh fungsi yang sama.

#### Bug yang diperbaiki: "Lanjut ke aplikasi" nyangkut di splash

Tombolnya memanggil `maybePop()`, yang menutup satu layar di dalam tumpukan
PIKIR sendiri. Setelah pemicu asli, layar di bawah intervensi adalah **splash**,
jadi pengguna yang menekan "Lanjut ke aplikasi" dari Easycash mendarat di layar
splash PIKIR dan diam di situ.

Dua kesalahan bertemu di sana, dan keduanya diperbaiki:

1. **Tujuannya salah.** "Lanjut ke aplikasi" berarti aplikasi yang tadi dibuka
   pengguna, bukan layar di dalam PIKIR. Sekarang memanggil `moveTaskToBack`
   lewat channel, sehingga PIKIR mundur dan Easycash muncul kembali. Task-nya
   yang dipindah, bukan activity-nya di-finish, supaya engine Flutter tetap
   hangat dan pemicu berikutnya tidak perlu cold start sebelum bisa memblokir.
2. **Splash menyerah.** Timernya sengaja tidak menggeser layar kalau ada
   intervensi di atasnya — tapi dulu ia berhenti mencoba selamanya. Sekarang ia
   mengecek lagi tiap 300 ms, jadi begitu intervensi ditutup, splash lanjut
   sendiri.

Bedanya sekarang tercatat di state: `InterventionState.fromRealTrigger`. Dari
Mode Demo tidak ada aplikasi di bawah, jadi keluar tetap berarti kembali ke
layar demo. "Oke, saya tunda" di layar luring mendarat di Beranda — menunda
justru berarti tidak dikembalikan ke aplikasi pinjaman.

#### Izin keempat, khusus Android 13 ke atas

Tiga izin di atas adalah *special access* — Android **tidak punya dialog** untuk
ketiganya, jadi satu-satunya jalan memang membuka layar Settings. Tapi ada izin
keempat yang justru punya dialog bawaan OS, dan sebelumnya **tidak pernah
diminta**: `POST_NOTIFICATIONS`.

Akibatnya nyata dan senyap: di Android 13 ke atas, pemindai tetap menandai dan
tetap menahan notifikasi pinjol, tapi **notifikasi pengganti dari PIKIR tidak
pernah sampai ke panel notifikasi**, tanpa error apa pun. Fitur 3 terlihat mati
padahal jalan. Di Android 12 izin ini diberikan saat pemasangan, jadi bug ini
tidak terlihat di HP uji.

Sekarang izin itu jadi kartu keempat di halaman izin, tapi **hanya muncul di
Android 13 ke atas**; di bawah itu ia dihilangkan dari daftar sekaligus dari
hitungan, supaya tidak ada baris yang tidak bisa diapa-apakan pengguna. Tombolnya
berbunyi "Izinkan", bukan "Buka pengaturan", karena yang muncul memang dialog
sistem. Kalau dialognya sudah ditolak permanen dan berhenti muncul, aplikasi
beralih membuka pengaturan notifikasi aplikasi.

**Batas pembuktian:** jalur Android 13 ini baru terbukti lewat tes widget, belum
di perangkat — HP uji yang ada Android 12, dan di situ cabang ini memang tidak
aktif. Kalau ada anggota tim dengan HP Android 13+, ini yang pertama harus
dicoba: nyalakan pemindai, jalankan "Simulasi notifikasi pinjol masuk" di Mode
Demo, dan pastikan notifikasi PIKIR benar-benar muncul di panel.

### Pengujian

137 tes, termasuk yang menjaga aturan produk agar tidak hilang diam-diam:

- Tiga tombol di layar opportunity cost berlebar sama dan tetap aktif (§6.3).
- Layar refleksi **tidak memuat satu piksel merah pun** — tes menyapu seluruh
  widget tree (DESIGN.md).
- Jalur konsumtif dan kebutuhan mendesak tidak memuat nama produk pinjaman
  apa pun (§6.7).
- Opsi pembiayaan diurutkan cepat-cair, dan tesnya menuntut opsi termurah
  **bukan** yang pertama — kalau seed diubah sampai keduanya sama, tesnya gagal.
- Sapuan tata letak merender **semua** layar di 360dp dan skala teks 1.3x.
- Halaman izin tidak memakai kata mendesak apa pun — tesnya menyapu daftar kata
  seperti "segera" dan "jangan sampai", karena halaman yang meminta sesuatu
  adalah tempat paling gampang tekanan menyelinap masuk (§6.5).

---

## 7. Ketidaksesuaian dengan proposal yang harus diperbaiki

Tiga hal ini **tidak bisa diperbaiki dengan mengubah kode saja**.

**1. TFLite belum ada.** Proposal menyebutnya di §5.1, §5.4, §6.1, KNF-01,
Tabel 6.1, dan metrik §7.3. Kode memakai pencocokan kata kunci dan regex
deterministik. Perlu dilunakkan jadi rencana sprint berikutnya, atau TFLite-nya
dibangun.

**2. Klaim "isi notifikasi tidak disimpan" mustahil dipenuhi.** Tabel 6.1
menulis *"tidak disimpan ke basis data lokal"* dan KNF-01 menulis
*"dihancurkan dari RAM"*. Itu tidak bisa digabung dengan aksi "Tampilkan pesan
aslinya" **dan** layar "Riwayat pemindaian" yang dirancang sendiri — ketiganya
saling meniadakan. Kalimatnya perlu diganti jadi kira-kira *"disimpan terbatas
di perangkat dan terhapus otomatis dalam 24 jam"*, yang sekarang memang sudah
ditegakkan kodenya.

**3. Tombol "Lanjut Meminjam" tidak dipudarkan.** §5.2 proposal menulis tombol
itu *"didesain pudar"*. Itu bertentangan dengan KNF-06 proposal sendiri, yang
melarang dark pattern jenis *obstruction* (Mathur dkk., 2019) — dan Bab VIII
menjadikannya tabel inversi dark pattern. Implementasinya memakai jalan tengah:
ketiga tombol berukuran sama dan sama kontras, friksinya ada pada tahan 5 detik.
Kalimat §5.2 perlu disesuaikan.

---

## 8. Cara menjalankan

```bash
flutter pub get
flutter run          # perlu Android SDK + JDK 17
flutter test         # 130 tes
flutter analyze
```

`minSdk` 30 (Android 11), sesuai CLAUDE.md §3.

### Izin yang harus diaktifkan manual

Untuk menguji fitur native, tiga izin harus aktif. **Realme/ColorOS memblokir
pemberian izin lewat adb** (`WRITE_SECURE_SETTINGS` dan `MANAGE_APP_OPS_MODES`
dicabut dari adb shell), jadi dua di antaranya harus ditekan di layar HP:

| Izin | Cara |
|---|---|
| Akses notifikasi | `adb shell cmd notification allow_listener com.pikir.pikir/com.pikir.pikir.NotificationService` |
| Aksesibilitas | Manual: Pengaturan → Aksesibilitas → PIKIR → aktifkan |
| Tampilkan di atas aplikasi lain | Manual: Pengaturan → Aplikasi → PIKIR |

**Penting:** `flutter install` yang menulis *"Uninstalling old version"*
menghapus semua izin ini. Setelah tiap install ulang, aktifkan lagi sebelum
merekam demo. `adb install -r <apk>` **juga mencabut izin aksesibilitas** di
ColorOS, walau izin overlay dan akses notifikasi bertahan — jadi setelah tiap
pemasangan ulang, aksesibilitas harus dinyalakan lagi dengan tangan. Ini sempat
membuat perbaikan status di atas terlihat gagal padahal layanannya memang baru
saja dimatikan sistem.

Aplikasi sendiri sudah menunjukkan status ketiganya di **Pengaturan → Izin
perlindungan**, jadi tidak perlu `dumpsys` untuk sekadar mengecek.

### Menguji pemindai notifikasi

```bash
adb shell "cmd notification post -S bigtext -t 'Selamat! Limit kamu naik Rp5.000.000' pikirtest 'Cair 3 menit tanpa BI Checking. Klik sekarang!'"
```

Notifikasinya harus hilang dan diganti notifikasi PIKIR. Kutip ganda di luar
wajib, kalau tidak shell di HP memecah argumennya dan kata kuncinya tidak
pernah sampai.

### Memantau

```bash
adb logcat -s PikirScreen PikirScanner
```

### Membuktikan enkripsi

```bash
adb shell run-as com.pikir.pikir od -A x -t x1 -N 16 databases/pikir.db
```

Hasilnya harus byte acak. SQLite polos selalu diawali `53 51 4c 69 74 65` =
`SQLite`.

---

## 9. Yang perlu diperhatikan sebelum merekam demo

**Whitelist aplikasi belum terverifikasi seluruhnya.** Nama paket yang salah
**gagal senyap** — pemicu tidak pernah menyala, tanpa error apa pun. Baru 3
dari 11 terverifikasi di perangkat nyata:

- **Terverifikasi:** Tokopedia, TikTok, Easycash (`com.fintopia.idnEasycash.google`)
- **Belum:** Shopee, Lazada, Bukalapak, Kredivo, Akulaku, AdaKami, Julo, Indodana

Verifikasi dengan `adb shell pm list packages | grep -i <nama>`, lalu ubah di
**dua tempat**: `TriggerRules.kt` dan `accessibility_service_config.xml`. Yang
tidak bisa diverifikasi sebaiknya dihapus, karena entri mati membuat hitungan
"N aplikasi terdaftar" di Mode Demo melebih-lebihkan cakupan.

**Kalau merekam di HP Android 13 ke atas**, buka dulu Pengaturan → Izin
perlindungan dan pastikan **keempat** izin aktif, termasuk "Mengirim
notifikasi". Tanpa yang terakhir, adegan pemindai notifikasi tidak akan
menampilkan apa pun di panel notifikasi meski pemindainya bekerja. Di Android 12
izin ini otomatis, jadi masalahnya baru muncul kalau ganti HP.

**Mode Demo** ada di Pengaturan → Mode demo, berisi empat tombol pemicu langsung
dan reset data ke kondisi seed. Halaman Peta Layar adalah alat pengembangan dan
tidak boleh ikut terekam.

---

## 10. Sisa pekerjaan, berdasarkan dampak ke penilaian

1. **Onboarding (5 layar)** — sisa pembuka video. Splash dan Tanpa Akun
   sudah jadi.
2. **UI pemindai notifikasi (3 layar)** — fitur 3 sudah bekerja di sisi sistem
   tapi belum punya antarmuka sama sekali.
3. **Layar pendukung dana darurat dan chat (5 layar)** — ini yang menahan PB-08
   dan PB-09 di status In Progress.
4. **Detail Rasio Utang** — dicapai dari "Lihat rincian" di Beranda.
5. Verifikasi 8 nama paket yang tersisa.
6. Penyesuaian tiga kalimat proposal di bagian 7 di atas.
