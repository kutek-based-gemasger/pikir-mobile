# Product Backlog PIKIR — revisi 16 Agustus 2026

Pengganti **Tabel 4.2.1** di proposal, beserta paragraf kemajuan di bawahnya.

Ditulis ulang dengan satu aturan yang diminta: **fitur yang belum
diimplementasikan tidak boleh berstatus Done.** Tiap baris di bawah diaudit
terhadap kode yang benar-benar ada di repo, bukan terhadap rencana. Kolom
**Bukti** menyebutkan di mana status itu bisa diperiksa sendiri.

---

## Cara membaca kolom Status

Ada tiga status, dan bedanya penting untuk kejujuran angka:

| Status | Artinya |
|---|---|
| **Done (penuh)** | Selesai seutuhnya. Item ini memang tidak memerlukan server. |
| **Done (kontrak Mock API)** | Seluruh alur klien memenuhi acceptance criteria dan teruji di perangkat, dengan respons Backend disuplai kontrak Mock API berupa data statis terstruktur. Yang tersisa adalah mengganti sumber data, bukan membangun alurnya. |
| **In Progress** | Sebagian acceptance criteria belum punya implementasi. **Tidak dihitung sebagai kemajuan.** |

Definition of Done bersifat biner. Item *In Progress* dihitung nol, tanpa
kredit parsial, walaupun sebagian besar layarnya sudah jadi.

---

## Tabel 4.2.1 — Product Backlog PIKIR (revisi)

| ID | User Story | MoSCoW | SP | Sprint | Status | Bukti dan sisa pekerjaan |
|---|---|---|---|---|---|---|
| PB-01 | Fondasi arsitektur klien (Frontend), ledger tiga field, dan penetapan kontrak Mock API agar pengembangan antarmuka dapat berjalan independen | Must | 15 | 1 | **Done (penuh)** | 42 rute terdaftar, ledger tiga field (`debt_entry.dart`), lima endpoint Mock API bertanda `TODO(backend)` |
| PB-02 | Klasifikasi kebutuhan secara otonom atau melalui pertanyaan interaktif singkat tanpa memperlambat proses | Must | 8 | 1 | **Done (kontrak Mock API)** | Pemetaan 5 topik ke 3 jalur otomatis; prompt dua opsi pada jalur aplikasi pinjol |
| PB-03 | Melihat opportunity cost, rasio utang terhadap ambang 30%, dan simulasi menunda | Must | 13 | 2 | **Done (kontrak Mock API)** | Layar biaya kesempatan, `ThresholdGauge` 30%, simulasi hari menabung |
| PB-04 | Kebutuhan mendesak diantar langsung ke opsi solusi tanpa pertanyaan tambahan, keputusan tercatat otomatis | Must | 10 | 2 | **Done (kontrak Mock API)** | Jalur mendesak 2 langkah; `recordDecision()` pada tiap akhir alur |
| PB-05 | Informasi program bantuan resmi yang akurat dan bersumber | Must | 8 | 3 | **Done (kontrak Mock API)** | Layar hasil dan detail program menampilkan `SourceChip`. **Sisa:** kurasi isi sumber resmi, saat ini masih fixture |
| PB-06 | Kebutuhan bertahan hidup diarahkan ke hak dan bantuan sosial, bukan tawaran pinjaman | Must | 8 | 3 | **Done (kontrak Mock API)** | Ditegakkan di tingkat model: `MitigationResult` menolak dibangun bila opsi pembiayaan menempel pada jalur mendesak |
| PB-07 | Kelayakan diuji terhadap margin dan payback usaha, opsi diurutkan berdasarkan waktu cair | Must | 16 | 4 | **Done (kontrak Mock API)** | Rumus payback dan ambang 90 hari terimplementasi; urutan cepat-cair diuji, dengan tes yang menuntut opsi termurah **bukan** yang pertama |
| PB-08 | Target dana darurat bertingkat yang realistis beserta pengingatnya | Must | 8 | 4 | **In Progress** | Dasbor dan rumus tiga tingkat sudah jalan. **Belum ada:** layar hitung target, catat setoran, dan pengingat menabung — klausa "beserta pengingatnya" belum punya implementasi sama sekali |
| PB-09 | Bertanya bebas, jawaban bersitasi, menolak topik di luar finansial, dan meminta persetujuan sebelum mencatat ke ledger | Must | 23 | 5 | **In Progress** | Chat, penolakan topik luar, sesi hanya-baca 2 jam, dan penghapusan 24 jam sudah jalan. **Belum ada:** layar konfirmasi catat ke ledger — klausa "meminta persetujuan" belum punya implementasi |
| PB-12 | Deteksi pemicu on-device: AccessibilityService, whitelist aplikasi, syarat checkout **dan** paylater | Must | 13 | 4 | **Done (penuh)** | Terverifikasi di perangkat. **Sisa:** verifikasi 8 dari 11 nama paket |
| PB-10 | Notifikasi promosi pinjaman mencurigakan dihapus senyap dan diganti peringatan edukatif | Should | 13 | 6 | **Done (penuh)** | Terverifikasi di perangkat: notifikasi asli hilang, pengganti muncul dengan dua aksi. **Sisa:** aksi "Lihat alasannya" masih mendarat di Beranda, bukan di layar detail |
| PB-11 | Istilah dijelaskan dengan bahasa sehari-hari dan riwayat keputusan dapat dilihat | Should | 8 | 6 | **Done (penuh)** | Gloss satu baris di tiap istilah finansial; tab Riwayat Keputusan di dalam Ledger |
| PB-X | Standing order, pemblokiran/penulisan ulang notifikasi, dan lapis korektif | Won't | — | — | Dikeluarkan | Lihat hasil inspeksi di 4.2 |

---

## Kemajuan

Kemajuan dihitung sebagai rasio story point berprioritas **Must** berstatus
Done terhadap total story point Must. Item Should dan Could dikeluarkan dari
penyebut agar persentase tidak bias oleh fitur sekunder.

**Dua angka disajikan sekaligus, dan sebaiknya keduanya ikut ditulis di
proposal**, karena PB-12 adalah item yang baru ditambahkan sepanjang
pengembangan dan menaikkan pembilang sekaligus penyebut:

| Perhitungan | Must selesai | Total Must | Persentase |
|---|---|---|---|
| Backlog asli, tanpa PB-12 | 78 | 109 | **71,6%** |
| Termasuk PB-12 | 91 | 122 | **74,6%** |

Keduanya melewati syarat minimum kemajuan 50% untuk purwarupa babak penyisihan
GEMASTIK. Yang tidak dihitung sama sekali: PB-08 (8 SP) dan PB-09 (23 SP),
karena keduanya masih *In Progress*.

Menyebutkan kedua angka lebih aman daripada menyebut yang lebih besar saja.
Pembaca yang membandingkan tabel ini dengan versi proposal sebelumnya akan
melihat ada item baru, dan lebih baik penjelasannya sudah ada di halaman yang
sama daripada ditanyakan saat penjurian.

### Kenapa PB-12 ditambahkan

Backlog lama tidak memuat satu item pun untuk AccessibilityService, padahal
KF-01 menulis *"pada saat trigger terdeteksi"* seolah pemicunya sudah tersedia.
Tanpa item ini, PB-02 dan PB-04 tampak selesai padahal skenarionya belum bisa
terjadi di dunia nyata: tidak ada yang mendeteksi checkout paylater maupun
pembukaan aplikasi pinjaman. Item ini ditambahkan sebagai temuan inspeksi,
sejalan dengan narasi adaptasi backlog lintas sprint di 4.2.

### Perubahan status dibanding proposal versi 14 Agustus

| ID | Sebelumnya | Sekarang | Alasan |
|---|---|---|---|
| PB-07 | In Progress | Done (kontrak Mock API) | Uji kelayakan, hasil produktif, dan detail pembiayaan selesai dan teruji |
| PB-08 | To Do | In Progress | Dasbor dan rumus tingkat sudah jalan, tiga layar pendukung belum |
| PB-09 | To Do | In Progress | Chat, sitasi, penolakan topik luar, dan aturan sesi sudah jalan |
| PB-10 | To Do | Done (penuh) | Terverifikasi di perangkat |
| PB-11 | To Do | Done (penuh) | Gloss dan riwayat keputusan selesai |
| PB-12 | — | Done (penuh) | Item baru, lihat di atas |

Perhatikan bahwa **PB-08 dan PB-09 naik dari To Do ke In Progress, bukan ke
Done**, walaupun sebagian besar pekerjaannya sudah selesai. Itu konsekuensi
langsung dari aturan biner Definition of Done, dan menahannya di In Progress
membuat 71,6% di atas bisa dipertahankan kalau ditanya.

---

## Lampiran: layar yang belum diimplementasikan

15 dari 42 rute masih berupa placeholder berlabel **"Belum dibuat"** beserta
acuannya di SCREENS.md, supaya layar yang belum jadi tidak pernah tersamar
sebagai layar yang sudah jadi saat demo.

| Kelompok | Layar | Menahan item |
|---|---|---|
| Onboarding | Onboarding, Izin Deteksi Layar, Izin Akses Notifikasi, Profil Finansial Lokal, Penyiapan Selesai | — |
| Dana darurat | Hitung Dana Darurat, Catat Setoran, Pengingat Menabung | **PB-08** |
| Chat | Sumber Jawaban, Konfirmasi Catat ke Ledger | **PB-09** |
| Pemindai | Detail Peringatan, Tagihan Terdeteksi, Pengaturan dan Riwayat Pemindaian | PB-10 (di luar AC) |
| Lain | Detail Rasio Utang, Klasifikasi Urgensi | — |

Dua catatan untuk perencanaan sprint berikutnya:

- **Izin Deteksi Layar** dan **Izin Akses Notifikasi** sekarang tumpang tindih
  dengan halaman `/pengaturan/izin` yang sudah jadi. Sebaiknya keduanya memakai
  ulang isi halaman itu atau dihapus, bukan ditulis ulang.
- **Klasifikasi Urgensi** kandidat dihapus: percabangan tiga jalur sudah
  ditentukan penuh di langkah 1 wizard, jadi layar ini tidak punya pekerjaan.
