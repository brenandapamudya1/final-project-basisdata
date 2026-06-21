# AGENTS.md — Konteks Lengkap Final Project Basis Data

## Identitas Proyek
- **Nama Proyek**: Sistem Manajemen Ritel Multi-Database
- **Mata Kuliah**: Basis Data (Semester 2)
- **Lokasi**: `/home/brenandacaesa/Documents/Perkuliahan/Semester_2/BasDat/FinalProject/`

---

## Struktur Database (3 Database MySQL)

### 1. `GUDANG` — Database Master / Pusat
File: `Gudang.sql`
Peran: Gudang Pusat (Distribution Centre / DC001)
Tabel utama:
- `tipe_toko`, `toko` — master lokasi (DC001, TE001, TE002, TR001, TR002)
- `divisi`, `pegawai` (PD0001–PD0004), `pegawai_divisi`, `absensi` — staff DC
- `kategori_barang` (KT0001–KT0006, KR0001–KR0005), `supplier` (SP0001–SP0004, SR0001–SR0005)
- `barang` (BE000001–BE000009 = Express, BG000001–BG000010 = Reguler)
- `harga_barang`, `display_barang` — master harga & approval
- `stok_dc`, `jadwal_restock`, `hutang_supplier`
- `distribusi_barang`, `detail_distribusi` — pengiriman DC → toko
- `rekap_stok_toko` — sinkronisasi stok dari semua toko (UNIQUE KEY id_toko+id_barang)

### 2. `EXPRESS` — Database Toko Express
File: `TokoExpress.sql`
Toko: TE001 (Express Darmo), TE002 (Express Gubeng)
Pegawai: PE0001–PE0006
Customer: CE0001–CE0004 (CE0001 = 'Umum'/walk-in)
FK lintas DB: `barang.id_supplier` → `GUDANG.supplier`, `hutang_supplier.id_supplier` → `GUDANG.supplier`, `jadwal_restock.id_supplier` → `GUDANG.supplier`
Tabel khusus: `promo` (PR0001–PR0003), `metode_pembayaran` (PY01–PY05), `transaksi_penjualan`, `detail_transaksi`, `pembayaran`

### 3. `toko_reguler` — Database Toko Reguler
File: `TokoReguler.sql`
Toko: TR001 (Swalayan Sentosa Rungkut), TR002 (Swalayan Sentosa Dukuh Kupang)
Pegawai: PR0001–PR0008 (dengan kolom `section`: Sembako/Fresh/Frozen/Household)
Customer: CR0001–CR0002
FK lintas DB: sama dengan EXPRESS
Tabel khusus: `promo` (PG0001–PG0002), `metode_pembayaran` (MR01–MR05)
Kategori tambahan vs GUDANG: KR0006 (Minuman), KR0007 (Snack) — tidak dipakai di data barang

---

## File SQL & Urutan Eksekusi

```
1. Gudang.sql         ← Wajib pertama (sumber FK untuk semua DB)
2. TokoExpress.sql    ← Setelah GUDANG
3. TokoReguler.sql    ← Setelah GUDANG
4. Triggers.sql       ← Setelah ketiga DB di atas; IDEMPOTENT (pakai DROP IF EXISTS)
5. Dashboard_Queries.sql ← Opsional, kumpulan query analitik (Static Pivot, Temp Table)
```

---

## Triggers (Triggers.sql) — 6 Trigger per Database

| Trigger | Event | Database | Fungsi |
|---|---|---|---|
| A `trg_kurangi_stok_setelah_transaksi` | AFTER INSERT detail_transaksi | EXPRESS & reguler | Kurangi stok_toko setelah item terjual |
| B `trg_kembalikan_stok_transaksi_batal` | AFTER UPDATE transaksi_penjualan | EXPRESS & reguler | Kembalikan stok jika transaksi dibatalkan |
| C `trg_tambah_poin_loyalty` | AFTER INSERT transaksi_penjualan | EXPRESS & reguler | Tambah poin customer (1 poin/Rp1.000) |
| D `trg_sync_rekap_stok_ke_gudang` | AFTER UPDATE stok_toko | EXPRESS & reguler | Sync stok toko → GUDANG.rekap_stok_toko |
| E `trg_update_hutang_lunas` | BEFORE UPDATE hutang_supplier | EXPRESS & reguler | Auto-isi tgl_lunas saat status = 'lunas' |
| F `trg_sync_harga_approved_ke_gudang` | AFTER UPDATE harga_barang | EXPRESS & reguler | Push harga approved → GUDANG.harga_barang |

---

## Dokumentasi

- `README.md` — Panduan eksekusi step-by-step + tabel domain + tabel relasi lintas domain
- `ERD_Database.md` — Diagram Mermaid ERD per domain (6 domain) + ERD Enterprise gabungan
- `AGENTS.md` — File ini (konteks lengkap untuk AI assistant)

---

## 6 Domain Fungsional

| # | Domain | Tabel Utama | Database |
|---|---|---|---|
| 1 | Organisasi & Lokasi | tipe_toko, toko | GUDANG |
| 2 | Kepegawaian (HR) | divisi, pegawai, pegawai_divisi, absensi | Semua |
| 3 | Master Barang & Harga | kategori_barang, barang, harga_barang, display_barang | Semua |
| 4 | Pemasok & Pembelian | supplier, jadwal_restock, hutang_supplier | Semua |
| 5 | Inventori & Distribusi | stok_dc, stok_toko, rekap_stok_toko, distribusi_barang, detail_distribusi | Semua |
| 6 | Penjualan & Pelanggan | customer, promo, metode_pembayaran, transaksi_penjualan, detail_transaksi, pembayaran | EXPRESS & reguler |

---

## Dashboard App — Rencana Implementasi

### Lokasi
`/home/brenandacaesa/Documents/Perkuliahan/Semester_2/BasDat/FinalProject/DashboardApp/`

### Tech Stack
- **Framework**: R Shiny (diminta dosen)
- **Bahasa**: R (utama), sedikit HTML/CSS untuk styling
- **Koneksi DB**: Package `RMySQL` atau `DBI` + `RMariaDB`
- **UI Library**: `shinydashboard` atau `bs4Dash` (Bootstrap 4)
- **Grafik**: `ggplot2` + `plotly` (interaktif)
- **Tabel**: `DT` package (DataTables)
- **Deployment**: Docker (image rocker/shiny)

### 3 Role / Akun
| Role | Akses DB | Warna Theme |
|---|---|---|
| `admin_gudang` | GUDANG (full) + rekap dari semua toko | Indigo |
| `admin_express` | EXPRESS + GUDANG.supplier | Amber |
| `admin_reguler` | toko_reguler + GUDANG.supplier | Emerald |

### Fitur Per Role
**Admin Gudang**: Rekap stok DC & semua toko, distribusi barang, approval harga (form), hutang supplier konsolidasi, absensi staff DC
**Admin Express**: Penjualan harian, stok kritis, promo aktif, hutang supplier, jadwal restock, absensi
**Admin Reguler**: Penjualan per toko, stok per section, loyalty customer, promo, hutang supplier, absensi

### Docker Setup (Rencana)
- Base image: `rocker/shiny` atau `rocker/shiny-verse`
- Container 1: R Shiny App
- Container 2: MySQL Server (dengan 3 database di dalamnya)
- Orchestration: `docker-compose.yml`

---

## Konvensi Penamaan ID

| Prefix | Entitas | Database |
|---|---|---|
| DC001 | Gudang Pusat | GUDANG.toko |
| TE00x | Toko Express | GUDANG.toko / EXPRESS.toko |
| TR00x | Toko Reguler | GUDANG.toko / toko_reguler.toko |
| PD00x | Pegawai DC | GUDANG.pegawai |
| PE00x | Pegawai Express | EXPRESS.pegawai |
| PR00x | Pegawai Reguler | toko_reguler.pegawai |
| SP00x | Supplier Express | GUDANG.supplier |
| SR00x | Supplier Reguler | GUDANG.supplier |
| BE00x | Barang Express | GUDANG.barang / EXPRESS.barang |
| BG00x | Barang Reguler | GUDANG.barang / toko_reguler.barang |
| CE00x | Customer Express | EXPRESS.customer |
| CR00x | Customer Reguler | toko_reguler.customer |
| KT00x | Kategori Express | GUDANG & EXPRESS.kategori_barang |
| KR00x | Kategori Reguler | GUDANG & toko_reguler.kategori_barang |
