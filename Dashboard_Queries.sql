-- ============================================================
--  DASHBOARD_QUERIES.sql
--  Berisi Static Pivot dan Temporary Table untuk keperluan
--  dashboard. Jalankan setelah semua database terisi data.
-- ============================================================


-- ============================================================
--  BAGIAN 1 — STATIC PIVOT
-- ============================================================

-- ------------------------------------------------------------
-- PIVOT 1 — Stok setiap barang di TE001 vs TE002 (EXPRESS)
-- Kegunaan: Tabel monitoring stok per gerai di halaman utama
--           dashboard, sehingga bisa terlihat perbandingan
--           langsung antara dua gerai Express.
-- ------------------------------------------------------------
USE EXPRESS;

SELECT
    b.id_barang,
    b.nama_barang,
    kb.nama_kategori,
    SUM(CASE WHEN s.id_toko = 'TE001' THEN s.jumlah ELSE 0 END) AS stok_TE001,
    SUM(CASE WHEN s.id_toko = 'TE002' THEN s.jumlah ELSE 0 END) AS stok_TE002,
    SUM(CASE WHEN s.id_toko = 'TE001' THEN s.stok_minimal ELSE 0 END) AS minimal_TE001,
    SUM(CASE WHEN s.id_toko = 'TE002' THEN s.stok_minimal ELSE 0 END) AS minimal_TE002
FROM stok_toko s
JOIN barang b          ON s.id_barang    = b.id_barang
JOIN kategori_barang kb ON b.id_kategori = kb.id_kategori
GROUP BY b.id_barang, b.nama_barang, kb.nama_kategori
ORDER BY kb.nama_kategori, b.nama_barang;

-- ------------------------------------------------------------
-- PIVOT 2 — Omzet penjualan per toko per bulan (EXPRESS)
-- Kegunaan: Grafik tren omzet bulanan di dashboard, membandingkan
--           performa gerai TE001 dan TE002 dari waktu ke waktu.
-- ------------------------------------------------------------
USE EXPRESS;

SELECT
    DATE_FORMAT(tgl_transaksi, '%Y-%m')                                         AS bulan,
    SUM(CASE WHEN id_toko = 'TE001' AND status = 'selesai' THEN total_bayar ELSE 0 END) AS omzet_TE001,
    SUM(CASE WHEN id_toko = 'TE002' AND status = 'selesai' THEN total_bayar ELSE 0 END) AS omzet_TE002,
    COUNT(CASE WHEN id_toko = 'TE001' AND status = 'selesai' THEN 1 END)        AS trx_TE001,
    COUNT(CASE WHEN id_toko = 'TE002' AND status = 'selesai' THEN 1 END)        AS trx_TE002
FROM transaksi_penjualan
GROUP BY DATE_FORMAT(tgl_transaksi, '%Y-%m')
ORDER BY bulan;

-- ------------------------------------------------------------
-- PIVOT 3 — Rekap absensi pegawai per status (GUDANG)
-- Kegunaan: Tabel rekap HR di dashboard Kepala Gudang, menampilkan
--           jumlah hari hadir, izin, sakit, alpha per pegawai.
-- ------------------------------------------------------------
USE GUDANG;

SELECT
    p.id_pegawai,
    p.nama,
    d.nama_divisi                                                                AS divisi_utama,
    SUM(CASE WHEN a.status = 'hadir'  THEN 1 ELSE 0 END)                       AS hadir,
    SUM(CASE WHEN a.status = 'izin'   THEN 1 ELSE 0 END)                       AS izin,
    SUM(CASE WHEN a.status = 'sakit'  THEN 1 ELSE 0 END)                       AS sakit,
    SUM(CASE WHEN a.status = 'alpha'  THEN 1 ELSE 0 END)                       AS alpha,
    COUNT(a.id_absensi)                                                          AS total_hari_tercatat
FROM pegawai p
LEFT JOIN absensi a ON p.id_pegawai = a.id_pegawai
LEFT JOIN pegawai_divisi pd ON p.id_pegawai = pd.id_pegawai AND pd.is_primary = 'Ya'
LEFT JOIN divisi d ON pd.id_divisi = d.id_divisi
GROUP BY p.id_pegawai, p.nama, d.nama_divisi
ORDER BY p.id_pegawai;

-- ------------------------------------------------------------
-- PIVOT 4 — Status approval harga barang per toko (GUDANG)
-- Kegunaan: Widget ringkasan di dashboard Kepala Gudang untuk
--           melihat seberapa banyak harga yang masih pending,
--           sudah approved, atau rejected per barang.
-- ------------------------------------------------------------
USE GUDANG;

SELECT
    b.id_barang,
    b.nama_barang,
    b.tipe_toko,
    SUM(CASE WHEN h.status = 'approved' THEN 1 ELSE 0 END)                     AS approved,
    SUM(CASE WHEN h.status = 'pending'  THEN 1 ELSE 0 END)                     AS pending,
    SUM(CASE WHEN h.status = 'rejected' THEN 1 ELSE 0 END)                     AS rejected,
    -- Harga jual aktif (approved, berlaku, belum berakhir)
    MAX(CASE WHEN h.status = 'approved' AND (h.tgl_berakhir IS NULL OR h.tgl_berakhir >= CURDATE())
             THEN h.harga_jual END)                                              AS harga_jual_aktif
FROM harga_barang h
JOIN barang b ON h.id_barang = b.id_barang
GROUP BY b.id_barang, b.nama_barang, b.tipe_toko
ORDER BY b.tipe_toko, b.nama_barang;


-- ============================================================
--  BAGIAN 2 — TEMPORARY TABLE
-- ============================================================

-- ------------------------------------------------------------
-- TEMP TABLE A — Stok kritis di bawah minimal (EXPRESS)
-- Kegunaan: Widget alert "Perlu Restock" di dashboard. Tampilkan
--           barang dengan stok di bawah stok minimal beserta
--           info supplier untuk tindak lanjut pemesanan.
-- Scope   : Jalankan di sesi yang sama dengan dashboard query.
-- ------------------------------------------------------------
USE EXPRESS;

DROP TEMPORARY TABLE IF EXISTS tmp_stok_kritis;

CREATE TEMPORARY TABLE tmp_stok_kritis AS
SELECT
    s.id_toko,
    t.nama_toko,
    s.id_barang,
    b.nama_barang,
    kb.nama_kategori,
    s.jumlah                      AS stok_saat_ini,
    s.stok_minimal,
    (s.stok_minimal - s.jumlah)  AS kekurangan,
    sp.nama                       AS nama_supplier,
    sp.no_hp                      AS kontak_supplier,
    jr.jumlah_order               AS qty_restock_biasa
FROM stok_toko s
JOIN barang b          ON s.id_barang    = b.id_barang
JOIN kategori_barang kb ON b.id_kategori = kb.id_kategori
JOIN toko t            ON s.id_toko      = t.id_toko
JOIN GUDANG.supplier sp ON b.id_supplier = sp.id_supplier
LEFT JOIN jadwal_restock jr
       ON jr.id_barang = s.id_barang AND jr.id_toko = s.id_toko AND jr.is_aktif = 'Ya'
WHERE s.jumlah < s.stok_minimal
ORDER BY kekurangan DESC;

-- Preview hasil
SELECT * FROM tmp_stok_kritis;

-- ------------------------------------------------------------
-- TEMP TABLE B — Ringkasan penjualan harian per toko (EXPRESS)
-- Kegunaan: Kartu KPI di bagian atas dashboard — total transaksi,
--           omzet, dan diskon yang diberikan hari ini per gerai.
-- ------------------------------------------------------------
USE EXPRESS;

DROP TEMPORARY TABLE IF EXISTS tmp_ringkasan_penjualan_harian;

CREATE TEMPORARY TABLE tmp_ringkasan_penjualan_harian AS
SELECT
    tp.id_toko,
    t.nama_toko,
    COUNT(tp.id_transaksi)         AS total_transaksi,
    SUM(tp.total_belanja)          AS total_belanja,
    SUM(tp.total_diskon)           AS total_diskon,
    SUM(tp.total_bayar)            AS total_omzet,
    COUNT(DISTINCT tp.id_customer) AS jumlah_customer_unik
FROM transaksi_penjualan tp
JOIN toko t ON tp.id_toko = t.id_toko
WHERE DATE(tp.tgl_transaksi) = CURDATE()
  AND tp.status = 'selesai'
GROUP BY tp.id_toko, t.nama_toko;

-- Preview hasil
SELECT * FROM tmp_ringkasan_penjualan_harian;

-- ------------------------------------------------------------
-- TEMP TABLE C — Harga barang pending approval (GUDANG)
-- Kegunaan: Panel notifikasi di dashboard Kepala Gudang. Berisi
--           daftar harga yang sudah diinput staf tapi belum
--           direview/disetujui, diurutkan dari yang paling lama.
-- ------------------------------------------------------------
USE GUDANG;

DROP TEMPORARY TABLE IF EXISTS tmp_barang_pending_approval;

CREATE TEMPORARY TABLE tmp_barang_pending_approval AS
SELECT
    h.id_harga,
    h.id_barang,
    b.nama_barang,
    b.tipe_toko,
    h.id_toko,
    t.nama_toko,
    h.harga_beli,
    h.harga_jual,
    h.tgl_berlaku,
    h.catatan,
    p.nama                                          AS diinput_oleh,
    DATEDIFF(CURDATE(), h.tgl_berlaku)              AS hari_menunggu
FROM harga_barang h
JOIN barang b   ON h.id_barang    = b.id_barang
JOIN toko t     ON h.id_toko      = t.id_toko
JOIN pegawai p  ON h.diinput_oleh = p.id_pegawai
WHERE h.status = 'pending'
ORDER BY h.tgl_berlaku ASC;

-- Preview hasil
SELECT * FROM tmp_barang_pending_approval;

-- ------------------------------------------------------------
-- TEMP TABLE D — Rekap pengiriman distribusi barang (GUDANG)
-- Kegunaan: Tabel tracking di halaman Distribusi pada dashboard
--           Kepala Gudang — melihat status pengiriman per toko,
--           termasuk apakah sudah diterima atau masih dalam
--           perjalanan, serta persentase penerimaan barang.
-- ------------------------------------------------------------
USE GUDANG;

DROP TEMPORARY TABLE IF EXISTS tmp_rekap_distribusi;

CREATE TEMPORARY TABLE tmp_rekap_distribusi AS
SELECT
    d.id_distribusi,
    t.nama_toko,
    d.tgl_kirim,
    d.tgl_terima,
    d.status_dist,
    pe.nama                                                                    AS diterima_oleh,
    COUNT(dd.id_detail)                                                        AS jumlah_jenis_barang,
    SUM(dd.jumlah_kirim)                                                       AS total_unit_kirim,
    SUM(dd.jumlah_terima)                                                      AS total_unit_diterima,
    ROUND(SUM(dd.jumlah_terima) / SUM(dd.jumlah_kirim) * 100, 1)              AS persen_diterima,
    DATEDIFF(CURDATE(), d.tgl_kirim)                                           AS hari_sejak_kirim
FROM distribusi_barang d
JOIN toko t               ON d.id_toko       = t.id_toko
LEFT JOIN pegawai pe      ON d.diterima_oleh  = pe.id_pegawai
JOIN detail_distribusi dd ON d.id_distribusi  = dd.id_distribusi
GROUP BY d.id_distribusi, t.nama_toko, d.tgl_kirim, d.tgl_terima,
         d.status_dist, pe.nama
ORDER BY d.tgl_kirim DESC;

-- Preview hasil
SELECT * FROM tmp_rekap_distribusi;

-- ------------------------------------------------------------
-- TEMP TABLE E — Hutang supplier yang akan jatuh tempo (GUDANG)
-- Kegunaan: Widget peringatan finansial di dashboard — menampilkan
--           hutang yang belum lunas dan jatuh tempo dalam 7 hari
--           ke depan, diurutkan dari yang paling mendesak.
-- ------------------------------------------------------------
USE GUDANG;

DROP TEMPORARY TABLE IF EXISTS tmp_hutang_jatuh_tempo;

CREATE TEMPORARY TABLE tmp_hutang_jatuh_tempo AS
SELECT
    h.id_hutang,
    s.nama                                                                     AS nama_supplier,
    s.kontak_pic,
    s.no_hp                                                                    AS hp_supplier,
    t.nama_toko,
    h.jumlah,
    h.tgl_hutang,
    h.tgl_jatuh_tempo,
    DATEDIFF(h.tgl_jatuh_tempo, CURDATE())                                     AS sisa_hari,
    h.status_hutang,
    h.keterangan,
    CASE
        WHEN DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) < 0    THEN 'LEWAT JATUH TEMPO'
        WHEN DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) <= 3   THEN 'SANGAT MENDESAK'
        WHEN DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) <= 7   THEN 'MENDESAK'
        ELSE 'NORMAL'
    END                                                                        AS prioritas
FROM hutang_supplier h
JOIN supplier s ON h.id_supplier = s.id_supplier
JOIN toko t     ON h.id_toko     = t.id_toko
WHERE h.status_hutang != 'lunas'
  AND h.tgl_jatuh_tempo <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY sisa_hari ASC;

-- Preview hasil
SELECT * FROM tmp_hutang_jatuh_tempo;
