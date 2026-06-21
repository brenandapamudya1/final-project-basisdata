# Panduan Operasi Database Retail (Final Project Basis Data)

Dokumen ini berisi panduan step-by-step untuk menjalankan (mengeksekusi) file SQL pada project ini secara runtut, beserta penjelasan dari masing-masing file.

Syntax SQL pada directory ./SQLSyntax

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

## Ringkasan Alur Sistem Terintegrasi
1. **Pemusatan Master Data:** Seluruh pengelolaan profil *supplier*, kategori barang, hingga otorisasi/persetujuan harga berpusat di database `GUDANG`.
2. **Kemandirian Transaksi:** Masing-masing toko (Express & Reguler) mencatat transaksi kasir secara mandiri dan memperbarui stok fisiknya sendiri menggunakan *Triggers*.
3. **Sinkronisasi Otomatis:** Meskipun transaksi mandiri, setiap perubahan jumlah stok di masing-masing toko akan langsung tersinkronisasi ke tabel `rekap_stok_toko` di database `GUDANG` melalui *Trigger*. Hal ini memudahkan tim Gudang Pusat memantau inventaris secara global.

---

## Domain & Struktur Tabel

Database ini dibagi menjadi **6 Domain** fungsional. Setiap domain merupakan kelompok tabel yang bekerja bersama untuk satu fungsi bisnis.

| # | Domain | Database | Tabel yang Tercakup |
|---|--------|----------|---------------------|
| 1 | **Organisasi & Lokasi** | GUDANG | `tipe_toko`, `toko` |
| 2 | **Kepegawaian (HR)** | GUDANG, EXPRESS, toko_reguler | `divisi`, `pegawai`, `pegawai_divisi`, `absensi` |
| 3 | **Master Barang & Harga** | GUDANG, EXPRESS, toko_reguler | `kategori_barang`, `barang`, `harga_barang`, `display_barang` |
| 4 | **Pemasok & Pembelian** | GUDANG, EXPRESS, toko_reguler | `supplier`, `jadwal_restock`, `hutang_supplier` |
| 5 | **Inventori & Distribusi** | GUDANG, EXPRESS, toko_reguler | `stok_dc`, `stok_toko`, `rekap_stok_toko`, `distribusi_barang`, `detail_distribusi` |
| 6 | **Penjualan & Pelanggan (POS)** | EXPRESS, toko_reguler | `customer`, `promo`, `metode_pembayaran`, `transaksi_penjualan`, `detail_transaksi`, `pembayaran` |

---

## 🔗 Relasi Lintas Domain (Cross-Domain)

Tabel-tabel berikut menjadi **jembatan antar domain** dan merupakan kunci integrasi seluruh sistem.

| Dari | Ke | Kolom Penghubung | Keterangan |
|------|----|------------------|------------|
| D4 `supplier` | D3 `barang` | `barang.id_supplier` | Setiap barang dipasok oleh satu supplier |
| D3 `barang` | D4 `jadwal_restock` | `jadwal_restock.id_barang` | Barang yang dijadwalkan restock dari supplier |
| D3 `barang` | D5 `stok_dc` / `stok_toko` | `id_barang` | Barang dilacak stoknya di DC dan tiap toko |
| D5 `distribusi_barang` | D5 `detail_distribusi` | `detail_distribusi.id_distribusi` | Rincian barang yang dikirim dari DC ke toko |
| D3 `barang` | D6 `detail_transaksi` | `detail_transaksi.id_barang` | Barang yang terjual di kasir toko |
| D3 `harga_barang` | D1 `toko` | `harga_barang.id_toko` | Harga barang bisa berbeda tiap toko |
| D2 `pegawai` | D6 `transaksi_penjualan` | `transaksi_penjualan.id_pegawai` | Pegawai (kasir) yang melayani transaksi |
| D2 `pegawai` | D3 `harga_barang` | `diinput_oleh`, `disetujui_oleh` | Pegawai DC yang input & approval harga |
| D1 `toko` | D2 `pegawai` | `pegawai.id_toko` | Pegawai bertugas di toko tertentu |
| D3 `barang` | D6 `promo` | `promo.id_barang` | Promo diskon diterapkan per barang |

> **Ingin melihat ERD lengkap dengan diagram Mermaid per domain?**
> Lihat file [`ERD_Database.md`](./ERD_Database.md) — tersedia ERD per domain dan ERD Enterprise gabungan seluruh sistem.
