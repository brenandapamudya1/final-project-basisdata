-- ============================================================
--  TRIGGERS.sql
--  Berisi semua trigger untuk database EXPRESS dan toko_reguler
--  Jalankan file ini SETELAH Gudang.sql, TokoExpress.sql,
--  dan TokoReguler.sql berhasil dieksekusi.
-- ============================================================


-- ============================================================
--  DATABASE: EXPRESS
-- ============================================================
USE EXPRESS;

-- ------------------------------------------------------------
-- TRIGGER A — Kurangi stok otomatis setelah item terjual
-- Event   : AFTER INSERT on detail_transaksi
-- Dampak  : jumlah di stok_toko berkurang sesuai qty terjual
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_kurangi_stok_setelah_transaksi
AFTER INSERT ON detail_transaksi
FOR EACH ROW
BEGIN
    DECLARE v_id_toko CHAR(5);

    -- Ambil id_toko dari header transaksi
    SELECT id_toko INTO v_id_toko
    FROM transaksi_penjualan
    WHERE id_transaksi = NEW.id_transaksi;

    -- Kurangi stok toko
    UPDATE stok_toko
    SET jumlah = jumlah - NEW.jumlah
    WHERE id_barang = NEW.id_barang
      AND id_toko   = v_id_toko;
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER B — Kembalikan stok saat transaksi dibatalkan
-- Event   : AFTER UPDATE on transaksi_penjualan
-- Dampak  : stok dikembalikan jika status berubah ke 'batal'
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_kembalikan_stok_transaksi_batal
AFTER UPDATE ON transaksi_penjualan
FOR EACH ROW
BEGIN
    IF NEW.status = 'batal' AND OLD.status = 'selesai' THEN
        UPDATE stok_toko st
        JOIN detail_transaksi dt ON dt.id_transaksi = NEW.id_transaksi
        SET st.jumlah = st.jumlah + dt.jumlah
        WHERE st.id_barang = dt.id_barang
          AND st.id_toko   = NEW.id_toko;
    END IF;
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER C — Tambah poin loyalty customer setelah transaksi
-- Event   : AFTER INSERT on transaksi_penjualan
-- Aturan  : 1 poin per Rp 1.000 yang dibayarkan
-- Dampak  : poin_loyalty di tabel customer bertambah
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_tambah_poin_loyalty
AFTER INSERT ON transaksi_penjualan
FOR EACH ROW
BEGIN
    IF NEW.status = 'selesai' AND NEW.id_customer IS NOT NULL THEN
        UPDATE customer
        SET poin_loyalty = poin_loyalty + FLOOR(NEW.total_bayar / 1000)
        WHERE id_customer = NEW.id_customer;
    END IF;
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER D — Sinkronisasi stok toko ke rekap di GUDANG
-- Event   : AFTER UPDATE on stok_toko
-- Dampak  : rekap_stok_toko di GUDANG selalu ter-update real-time
-- Note    : Membutuhkan UNIQUE KEY (id_toko, id_barang) yang
--           sudah ditambahkan ke tabel GUDANG.rekap_stok_toko
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_sync_rekap_stok_ke_gudang
AFTER UPDATE ON stok_toko
FOR EACH ROW
BEGIN
    INSERT INTO GUDANG.rekap_stok_toko
        (id_toko, id_barang, jumlah_stok, stok_minimal, tgl_sync)
    VALUES
        (NEW.id_toko, NEW.id_barang, NEW.jumlah, NEW.stok_minimal, NOW())
    ON DUPLICATE KEY UPDATE
        jumlah_stok  = NEW.jumlah,
        stok_minimal = NEW.stok_minimal,
        tgl_sync     = NOW();
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER E — Auto-isi tgl_lunas saat status hutang jadi 'lunas'
-- Event   : BEFORE UPDATE on hutang_supplier
-- Dampak  : tgl_lunas terisi otomatis tanpa perlu diinput manual
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_update_hutang_lunas
BEFORE UPDATE ON hutang_supplier
FOR EACH ROW
BEGIN
    IF NEW.status_hutang = 'lunas' AND OLD.status_hutang != 'lunas' THEN
        SET NEW.tgl_lunas = CURDATE();
    END IF;
END$$
DELIMITER ;


-- ============================================================
--  DATABASE: toko_reguler
-- ============================================================
USE toko_reguler;

-- ------------------------------------------------------------
-- TRIGGER A (reguler) — Kurangi stok otomatis setelah transaksi
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_kurangi_stok_setelah_transaksi
AFTER INSERT ON detail_transaksi
FOR EACH ROW
BEGIN
    DECLARE v_id_toko CHAR(5);

    SELECT id_toko INTO v_id_toko
    FROM transaksi_penjualan
    WHERE id_transaksi = NEW.id_transaksi;

    UPDATE stok_toko
    SET jumlah = jumlah - NEW.jumlah
    WHERE id_barang = NEW.id_barang
      AND id_toko   = v_id_toko;
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER B (reguler) — Kembalikan stok saat transaksi batal
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_kembalikan_stok_transaksi_batal
AFTER UPDATE ON transaksi_penjualan
FOR EACH ROW
BEGIN
    IF NEW.status = 'batal' AND OLD.status = 'selesai' THEN
        UPDATE stok_toko st
        JOIN detail_transaksi dt ON dt.id_transaksi = NEW.id_transaksi
        SET st.jumlah = st.jumlah + dt.jumlah
        WHERE st.id_barang = dt.id_barang
          AND st.id_toko   = NEW.id_toko;
    END IF;
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER C (reguler) — Tambah poin loyalty customer
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_tambah_poin_loyalty
AFTER INSERT ON transaksi_penjualan
FOR EACH ROW
BEGIN
    IF NEW.status = 'selesai' AND NEW.id_customer IS NOT NULL THEN
        UPDATE customer
        SET poin_loyalty = poin_loyalty + FLOOR(NEW.total_bayar / 1000)
        WHERE id_customer = NEW.id_customer;
    END IF;
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER D (reguler) — Sinkronisasi stok ke GUDANG
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_sync_rekap_stok_ke_gudang
AFTER UPDATE ON stok_toko
FOR EACH ROW
BEGIN
    INSERT INTO GUDANG.rekap_stok_toko
        (id_toko, id_barang, jumlah_stok, stok_minimal, tgl_sync)
    VALUES
        (NEW.id_toko, NEW.id_barang, NEW.jumlah, NEW.stok_minimal, NOW())
    ON DUPLICATE KEY UPDATE
        jumlah_stok  = NEW.jumlah,
        stok_minimal = NEW.stok_minimal,
        tgl_sync     = NOW();
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER E (reguler) — Auto-isi tgl_lunas hutang supplier
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_update_hutang_lunas
BEFORE UPDATE ON hutang_supplier
FOR EACH ROW
BEGIN
    IF NEW.status_hutang = 'lunas' AND OLD.status_hutang != 'lunas' THEN
        SET NEW.tgl_lunas = CURDATE();
    END IF;
END$$
DELIMITER ;
