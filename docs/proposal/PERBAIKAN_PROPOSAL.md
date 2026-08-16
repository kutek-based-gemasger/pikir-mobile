# Perbaikan proposal — siap tempel

Audit proposal versi 9, 16 Agustus 2026.

Standarnya: **proposal mendeskripsikan aplikasi target (final)**, jadi klaim
rancangan seperti TFLite dan sanitasi PII dibiarkan apa adanya. **Kecuali Bab
IV**, yang harus sesuai progres saat ini.

Sembilan perbaikan, urut dari yang paling penting.

---

## 1. Daftar Pustaka: 8 sitasi tidak punya entri

Dikutip di badan teks tetapi tidak ada di Daftar Pustaka. Seluruh Bab II
bertumpu pada empat nama pertama.

**TEMPEL ke Daftar Pustaka, jaga urutan alfabetis:**

> Adams, P., Guttman-Kenney, B., Hayes, L., Hunt, S., Laibson, D., & Stewart, N. (2022). Do nudges reduce borrowing and consumer confusion in the credit card market? *Economica, 89*(S1), S178–S199.

> Bank Indonesia. (2025). *Survei Konsumen September 2025*. Jakarta: Bank Indonesia.

> Bertrand, M., & Morse, A. (2011). Information disclosure, cognitive biases, and payday borrowing. *The Journal of Finance, 66*(6), 1865–1893.

> Otoritas Jasa Keuangan. (2023). *Sikapi Uangmu: [judul artikel]*. Diakses [tanggal], dari https://sikapiuangmu.ojk.go.id

> Otoritas Jasa Keuangan, & Badan Pusat Statistik. (2024). *Survei Nasional Literasi dan Inklusi Keuangan (SNLIK) 2024*. Jakarta: Otoritas Jasa Keuangan.

> Republik Indonesia. (2020). *Peraturan Presiden Republik Indonesia Nomor 114 Tahun 2020 tentang Strategi Nasional Keuangan Inklusif*. Jakarta: Sekretariat Negara.

> Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness*. Yale University Press.

**Satu lagi harus kalian isi sendiri:** Kuan dan rekan (2025, PNAS) yang dikutip
di §2.1. Saya tidak bisa menyusun entrinya karena tidak tahu makalahnya —
ambil dari sumber yang kalian pakai.

**Periksa juga:** nomor halaman Bertrand & Morse dan Adams dkk. di atas saya
tulis dari ingatan. Cocokkan dengan sumber aslinya sebelum dikumpulkan.

### 1b. Dua entri ada di daftar tetapi tidak pernah dikutip

**Nielsen (1994)** dan **Nielsen & Landauer (1993)**. Pilih salah satu: kutip di
badan teks (paling masuk akal di Bab III saat membahas evaluasi antarmuka), atau
hapus dari daftar.

### 1c. Urutan alfabetis salah

Kedua entri Nielsen sekarang ada di paling bawah, sesudah Thaler. **Pindahkan ke
antara Method Financial dan Otoritas Jasa Keuangan.**

---

## 2. Daftar Isi kehilangan satu subbab

**LOKASI:** Daftar Isi, antara `2.1 Behavioral Finance` dan `2.3 Literasi/Inklusi Keuangan & SDGs`

**TEMPEL baris ini di antaranya:**

> 2.2 Retrieval-Augmented Generation (RAG) & Grounding &nbsp;&nbsp;&nbsp;&nbsp; 10

---

## 3. Bab V §5.2 — kontradiksi di dalam satu kalimat

**LOKASI:** Bab V, §5.2, butir terakhir "Output UI/UX (Nudge)", hal. 28

"Asimetris" dan "mendominasi" bertabrakan dengan "setara" di kalimat yang sama,
sekaligus bertentangan dengan KNF-06.

**CARI seluruh butir yang diawali:** `Output UI/UX (Nudge): Berdasarkan instruksi Backend, layar akan memunculkan intervensi edukasi opportunity cost dengan desain tombol asimetris...`

**GANTI JADI:**

> **Output UI/UX (*Nudge*):** Berdasarkan instruksi Backend, layar memunculkan intervensi edukasi *opportunity cost* dengan tiga pilihan — "Tunda/Menabung", "Tanya Lebih Lanjut", dan "Lanjut Meminjam" — yang seluruhnya berukuran, berkontras, dan berbobot huruf identik. Friksi kognitif tidak diletakkan pada pengecilan atau pemudaran pilihan, melainkan pada gerakannya: "Lanjut Meminjam" mensyaratkan penekanan tahan selama lima detik dengan cincin progres yang terlihat. Pilihan desain ini menegakkan KNF-06, sebab memudarkan atau menyembunyikan opsi keluar justru termasuk *dark pattern* jenis *obstruction* (Mathur dkk., 2019).

---

## 4. Tabel 4.2.1 — status PB-10

**LOKASI:** Bab IV, Tabel 4.2.1, baris PB-10, hal. 24

**CARI:** kolom Status berisi `To Do`
**GANTI JADI:** `Done`

Pemindai notifikasi sudah bekerja penuh dan terverifikasi di perangkat.
PB-10 berprioritas Should, jadi **angka 63,9% tidak berubah.**

Jangan ubah PB-12, PB-08, dan PB-09 — ketiganya tepat di *In Progress*.

---

## 5. Tabel 4.2.1 — Sprint 4 kelebihan beban

**LOKASI:** Bab IV, Tabel 4.2.1, kolom Sprint, baris PB-08, hal. 24

§4.2 menyebut kapasitas ±25–30 SP per sprint, tetapi Sprint 4 berisi PB-12 (13)
+ PB-07 (16) + PB-08 (8) = **37 SP**.

**CARI:** baris PB-08, kolom Sprint berisi `4`
**GANTI JADI:** `6`

Hasilnya Sprint 4 = 29 SP, Sprint 6 = 29 SP. Keduanya masuk rentang.

---

## 6. Judul Bab VIII dan IX

Karena dokumentasi penggunaan dipindahkan ke Bab VIII, dan ada typo
"Pengunaan" yang kurang satu huruf g.

**LOKASI:** judul bab dan Daftar Isi, dua tempat masing-masing

**CARI:** `Bab VIII — Mockup & Implementasi Antarmuka`
**GANTI JADI:** `Bab VIII — Mockup, Implementasi Antarmuka, dan Dokumentasi Penggunaan`

**CARI:** `Bab IX — Dokumentasi Pengunaan dan Penutup`
**GANTI JADI:** `Bab IX — Penutup`

---

## 7. Gambar 3.1 tidak ada

**LOKASI:** Bab III

Dokumen memuat **Gambar 3.2 Use Case Diagram**, tetapi tidak ada Gambar 3.1 di
mana pun. Entah ada gambar yang terhapus, atau penomorannya harus dimulai dari
3.1.

Kalau tidak ada gambar lain di Bab III, ubah saja labelnya:

**CARI:** `Gambar 3.2 Use Case Diagram`
**GANTI JADI:** `Gambar 3.1 Use Case Diagram`

---

## 8. KNF-05 — klaim dua ketukan

**LOKASI:** Tabel 3.3, baris KNF-05, hal. 20

Wizard mitigasi dirancang 2–3 langkah, jadi dua ketukan hanya benar untuk alur
intervensi.

**CARI:** `alur utama dapat diselesaikan dalam maksimal dua ketukan`
**GANTI JADI:** `alur intervensi dapat diselesaikan dalam maksimal dua ketukan`

---

## 9. KNF-03 — huruf kecil sesudah titik

**LOKASI:** Tabel 3.3, baris KNF-03, hal. 20

**CARI:** `(pgvector). bila retrieval kosong`
**GANTI JADI:** `(pgvector). Bila retrieval kosong`

---

## Perlu kalian pastikan sendiri

**Nama model Gemini.** Abstrak dan §5.1 menyebut **Gemini 3.5 Flash-Lite** dan
**Gemini Embedding 2**. Saya tidak bisa memastikan penamaan itu benar. Cek
sekali di dokumentasi Google — nama model yang keliru mudah dinilai ceroboh.

## Saran, bukan kesalahan

**Bab V belum punya diagram arsitektur**, padahal §5.1 mendeskripsikan lima
komponen Hybrid Edge-Cloud. Satu gambar di sana akan sangat membantu, dan
Bab III sudah punya use case diagram sebagai preseden gaya.

---

## Yang sudah benar — jangan diutak-atik

- **Klaim TFLite di tujuh lokasi** (§1.6, §5.1, §5.4, §6.1, §7.3, KF-05, KNF-01).
  Itu rancangan produk final, dan Bab IV sudah menyatakan TFLite dijadwalkan
  pada sprint tahap akhir. Konsisten.
- **Sanitasi PII `[REDACTED]`** di §6.2 poin 3. Sama, rancangan untuk integrasi
  backend.
- **KNF-01 dan Tabel 6.1** soal penyimpanan notifikasi 24 jam. Cocok dengan kode.
- **§5.2** soal tombol "ukuran dan tingkat kontras yang setara". Cocok dengan kode.
- **Angka 78 dari 122 (63,9%)** dan total Must 122. Aritmetikanya benar dan
  konsisten antara abstrak dan Bab IV.
