# Panduan Operasi Database Retail (Final Project Basis Data)

Dokumen ini berisi panduan step-by-step untuk menjalankan (mengeksekusi) file SQL pada project ini secara runtut, beserta penjelasan dari masing-masing file.

Project ini mensimulasikan sistem terintegrasi yang terdiri dari 3 buah database utama yang saling berkaitan:
1. `GUDANG` (Database Master & Pusat)
2. `EXPRESS` (Database Toko Express)
3. `toko_reguler` (Database Toko Reguler)

---

## 🛠️ Urutan Eksekusi (Step-by-Step)

⚠️ **PENTING:** Anda harus menjalankan file-file SQL di bawah ini secara **berurutan (sekuensial)** agar tidak terjadi *error* pada relasi tabel dan *Foreign Key* lintas-database.

### 1. Eksekusi `Gudang.sql`
* **Penjelasan:** File ini bertugas membuat database utama bernama `GUDANG`. Database ini bertindak sebagai pusat kendali untuk data-data master (seperti Master Barang, Master Supplier, dan Rekap Stok dari seluruh toko).
* **Instruksi:** 
  Buka file `Gudang.sql` di SQL Client Anda (seperti MySQL Workbench, DBeaver, phpMyAdmin, atau via CLI) lalu jalankan seluruh script (Run All). Pastikan query berjalan sukses dan database `GUDANG` beserta seluruh data *dummy*-nya terbentuk.

### 2. Eksekusi `TokoExpress.sql`
* **Penjelasan:** File ini membuat database khusus untuk cabang berkonsep "Express" dengan nama database `EXPRESS`. Database ini me-referensi beberapa tabel master yang ada di database `GUDANG`.
* **Instruksi:**
  Setelah `Gudang.sql` berhasil dijalankan, buka file `TokoExpress.sql` lalu eksekusi seluruh scriptnya. Ini akan meng-generate struktur operasional Toko Express beserta transaksi di dalamnya.

### 3. Eksekusi `TokoReguler.sql`
* **Penjelasan:** File ini membuat database cabang dengan skala lebih besar yaitu `toko_reguler`. Konsepnya serupa dengan Toko Express, database ini juga membutuhkan `GUDANG` sebagai sumber *Foreign Key*.
* **Instruksi:**
  Buka file `TokoReguler.sql` dan eksekusi seluruh script. Database toko reguler akan terbentuk lengkap dengan datanya.

### 4. Eksekusi `Triggers.sql`
* **Penjelasan:** File ini berisi kumpulan *Triggers* (otomatisasi) untuk database `EXPRESS` dan `toko_reguler`. Trigger ini menangani *business logic* secara otomatis, seperti mengurangi/mengembalikan stok saat terjadi transaksi, menambah poin *loyalty* pelanggan, hingga melakukan *sinkronisasi real-time* perubahan stok dari toko ke rekap stok di `GUDANG`.
* **Instruksi:**
  Pastikan ketiga database di atas (`GUDANG`, `EXPRESS`, `toko_reguler`) sudah dibuat. Buka file `Triggers.sql` lalu jalankan secara keseluruhan.

### 5. Penggunaan `Dashboard_Queries.sql` (Opsional/Reporting)
* **Penjelasan:** File ini bukan merupakan tahapan instalasi, melainkan kumpulan *Advanced Queries* berupa *Static Pivot* dan *Temporary Tables*. Skrip ini mensimulasikan query analitik yang biasa dipanggil oleh sistem *Dashboard* untuk melihat performa penjualan antar toko, produk yang butuh di-restock, kinerja staf, hingga tagihan *supplier* yang mendesak.
* **Instruksi:**
  Anda bisa menjalankan *block query* secara parsial di dalam file `Dashboard_Queries.sql` untuk melihat hasil laporannya. (Perhatikan: Data dari *temporary table* hanya akan bertahan selama koneksi/sesi Anda ke server database masih aktif).

---

## 💡 Ringkasan Alur Sistem Terintegrasi
1. **Pemusatan Master Data:** Seluruh pengelolaan profil *supplier*, kategori barang, hingga otorisasi/persetujuan harga berpusat di database `GUDANG`.
2. **Kemandirian Transaksi:** Masing-masing toko (Express & Reguler) mencatat transaksi kasir secara mandiri dan memperbarui stok fisiknya sendiri menggunakan *Triggers*.
3. **Sinkronisasi Otomatis:** Meskipun transaksi mandiri, setiap perubahan jumlah stok di masing-masing toko akan langsung tersinkronisasi ke tabel `rekap_stok_toko` di database `GUDANG` melalui *Trigger*. Hal ini memudahkan tim Gudang Pusat memantau inventaris secara global.
