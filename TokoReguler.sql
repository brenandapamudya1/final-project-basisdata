CREATE DATABASE IF NOT EXISTS toko_reguler;

USE toko_reguler;

-- ------------------------------------------------------------
-- 1. MASTER TOKO (gerai reguler)
-- ------------------------------------------------------------
CREATE TABLE toko (
    id_toko CHAR(5) PRIMARY KEY, -- TR001, TR002
    nama_toko VARCHAR(60) NOT NULL,
    alamat VARCHAR(150) NOT NULL,
    kota VARCHAR(50) NOT NULL,
    telp VARCHAR(20),
    jam_buka TIME NOT NULL DEFAULT '08:00:00',
    jam_tutup TIME NOT NULL DEFAULT '21:00:00',
    status ENUM('aktif', 'nonaktif') NOT NULL DEFAULT 'aktif'
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 2. DIVISI / JABATAN
-- Divisi khusus toko reguler: Kasir, Cleaning Service,
-- Pengendali Stok, Security, Pegawai Section, Store Supervisor,
-- Head Store (manager gerai, disamakan dgn struktur ekspress
-- agar tetap ada penyelia per gerai)
-- ------------------------------------------------------------
CREATE TABLE divisi (
    id_divisi CHAR(6) PRIMARY KEY,
    nama_divisi VARCHAR(50) NOT NULL,
    deskripsi VARCHAR(150),
    level_jabatan ENUM(
        'staff',
        'supervisor',
        'manager'
    ) NOT NULL DEFAULT 'staff'
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 3. PEGAWAI
-- Kolom `section` khusus untuk Pegawai Section (mis. Sembako,
-- Fresh, Frozen, Household). NULL jika divisi bukan section.
-- ------------------------------------------------------------
CREATE TABLE pegawai (
    id_pegawai CHAR(6) PRIMARY KEY,
    nama VARCHAR(80) NOT NULL,
    nik VARCHAR(20) UNIQUE,
    no_hp VARCHAR(20),
    alamat VARCHAR(150),
    id_toko CHAR(5) NOT NULL,
    section VARCHAR(30), -- mis. 'Sembako','Fresh','Frozen','Household'
    tgl_masuk DATE NOT NULL,
    status ENUM('aktif', 'nonaktif', 'cuti') NOT NULL DEFAULT 'aktif',
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko)
) ENGINE = InnoDB;

CREATE TABLE pegawai_divisi (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_pegawai CHAR(6) NOT NULL,
    id_divisi CHAR(6) NOT NULL,
    tgl_mulai DATE NOT NULL,
    tgl_selesai DATE,
    is_primary ENUM('Ya', 'Tidak') NOT NULL DEFAULT 'Tidak',
    FOREIGN KEY (id_pegawai) REFERENCES pegawai (id_pegawai),
    FOREIGN KEY (id_divisi) REFERENCES divisi (id_divisi)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 4. ABSENSI PEGAWAI
-- ------------------------------------------------------------
CREATE TABLE absensi (
    id_absensi INT PRIMARY KEY AUTO_INCREMENT,
    id_pegawai CHAR(6) NOT NULL,
    tanggal DATE NOT NULL,
    jam_masuk TIME,
    jam_keluar TIME,
    status ENUM(
        'hadir',
        'izin',
        'sakit',
        'alpha'
    ) NOT NULL DEFAULT 'hadir',
    keterangan VARCHAR(150),
    FOREIGN KEY (id_pegawai) REFERENCES pegawai (id_pegawai)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 5. MASTER BARANG (independen dari gudang, variasi lebih luas)
-- ------------------------------------------------------------
CREATE TABLE kategori_barang (
    id_kategori CHAR(6) PRIMARY KEY,
    nama_kategori VARCHAR(50) NOT NULL,
    perlu_penanganan ENUM('Ya', 'Tidak') NOT NULL DEFAULT 'Tidak',
    suhu_min DECIMAL(5, 1),
    suhu_max DECIMAL(5, 1),
    keterangan VARCHAR(100)
) ENGINE = InnoDB;

CREATE TABLE barang (
    id_barang CHAR(8) PRIMARY KEY,
    nama_barang VARCHAR(100) NOT NULL,
    id_kategori CHAR(6) NOT NULL,
    id_supplier CHAR(6) NOT NULL,
    satuan VARCHAR(20) NOT NULL,
    berat_gram DECIMAL(8, 2),
    is_aktif ENUM('Ya', 'Tidak') NOT NULL DEFAULT 'Ya',
    FOREIGN KEY (id_kategori) REFERENCES kategori_barang (id_kategori),
    FOREIGN KEY (id_supplier) REFERENCES GUDANG.supplier (id_supplier)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 6. HARGA & APPROVAL
-- ------------------------------------------------------------
CREATE TABLE harga_barang (
    id_harga INT PRIMARY KEY AUTO_INCREMENT,
    id_barang CHAR(8) NOT NULL,
    id_toko CHAR(5) NOT NULL,
    harga_beli DECIMAL(12, 2) NOT NULL,
    harga_jual DECIMAL(12, 2) NOT NULL,
    tgl_berlaku DATE NOT NULL,
    tgl_berakhir DATE,
    status ENUM(
        'pending',
        'approved',
        'rejected'
    ) NOT NULL DEFAULT 'pending',
    diinput_oleh CHAR(6),
    disetujui_oleh CHAR(6),
    tgl_approval DATETIME,
    catatan VARCHAR(150),
    FOREIGN KEY (id_barang) REFERENCES barang (id_barang),
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko),
    FOREIGN KEY (diinput_oleh) REFERENCES pegawai (id_pegawai),
    FOREIGN KEY (disetujui_oleh) REFERENCES pegawai (id_pegawai)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 7. DISPLAY BARANG
-- ------------------------------------------------------------
CREATE TABLE display_barang (
    id_display INT PRIMARY KEY AUTO_INCREMENT,
    id_barang CHAR(8) NOT NULL,
    id_toko CHAR(5) NOT NULL,
    id_harga INT NOT NULL,
    status_barang ENUM(
        'pending',
        'displayed',
        'ditarik'
    ) NOT NULL DEFAULT 'pending',
    tgl_display DATE,
    tgl_tarik DATE,
    diupdate_oleh CHAR(6),
    FOREIGN KEY (id_barang) REFERENCES barang (id_barang),
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko),
    FOREIGN KEY (id_harga) REFERENCES harga_barang (id_harga),
    FOREIGN KEY (diupdate_oleh) REFERENCES pegawai (id_pegawai)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 8. STOK & RESTOCK
-- ------------------------------------------------------------
CREATE TABLE stok_toko (
    id_stok INT PRIMARY KEY AUTO_INCREMENT,
    id_barang CHAR(8) NOT NULL,
    id_toko CHAR(5) NOT NULL,
    jumlah INT NOT NULL DEFAULT 0,
    stok_minimal INT NOT NULL DEFAULT 0,
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_barang) REFERENCES barang (id_barang),
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko)
) ENGINE = InnoDB;

CREATE TABLE jadwal_restock (
    id_jadwal INT PRIMARY KEY AUTO_INCREMENT,
    id_barang CHAR(8) NOT NULL,
    id_toko CHAR(5) NOT NULL,
    id_supplier CHAR(6) NOT NULL,
    frekuensi ENUM(
        'harian',
        'mingguan',
        'bulanan'
    ) NOT NULL DEFAULT 'mingguan',
    hari_restock VARCHAR(50),
    jumlah_order INT NOT NULL DEFAULT 0,
    is_aktif ENUM('Ya', 'Tidak') NOT NULL DEFAULT 'Ya',
    FOREIGN KEY (id_barang) REFERENCES barang (id_barang),
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko),
    FOREIGN KEY (id_supplier) REFERENCES GUDANG.supplier (id_supplier)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 9. HUTANG SUPPLIER
-- ------------------------------------------------------------
CREATE TABLE hutang_supplier (
    id_hutang INT PRIMARY KEY AUTO_INCREMENT,
    id_supplier CHAR(6) NOT NULL,
    id_toko CHAR(5) NOT NULL,
    jumlah DECIMAL(14, 2) NOT NULL,
    tgl_hutang DATE NOT NULL,
    tgl_jatuh_tempo DATE NOT NULL,
    status_hutang ENUM(
        'belum_lunas',
        'lunas',
        'sebagian'
    ) NOT NULL DEFAULT 'belum_lunas',
    tgl_lunas DATE,
    keterangan VARCHAR(150),
    FOREIGN KEY (id_supplier) REFERENCES GUDANG.supplier (id_supplier),
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 10. CUSTOMER
-- ------------------------------------------------------------
CREATE TABLE customer (
    id_customer CHAR(6) PRIMARY KEY,
    nama VARCHAR(80) NOT NULL,
    no_hp VARCHAR(20) UNIQUE,
    email VARCHAR(80),
    tgl_daftar DATE NOT NULL,
    poin_loyalty INT NOT NULL DEFAULT 0
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 11. PROMO (per item: diskon % atau nominal)
-- ------------------------------------------------------------
CREATE TABLE promo (
    id_promo CHAR(6) PRIMARY KEY,
    nama_promo VARCHAR(80) NOT NULL,
    id_barang CHAR(8) NOT NULL,
    jenis_diskon ENUM('persen', 'nominal') NOT NULL,
    nilai_diskon DECIMAL(10, 2) NOT NULL,
    tgl_mulai DATE NOT NULL,
    tgl_selesai DATE NOT NULL,
    is_aktif ENUM('Ya', 'Tidak') NOT NULL DEFAULT 'Ya',
    FOREIGN KEY (id_barang) REFERENCES barang (id_barang)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 12. METODE PEMBAYARAN (master)
-- ------------------------------------------------------------
CREATE TABLE metode_pembayaran (
    id_metode CHAR(4) PRIMARY KEY,
    nama_metode ENUM(
        'tunai',
        'debit',
        'qris',
        'transfer',
        'tarik_tunai'
    ) NOT NULL,
    keterangan VARCHAR(100)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 13. TRANSAKSI PENJUALAN
-- ------------------------------------------------------------
CREATE TABLE transaksi_penjualan (
    id_transaksi INT PRIMARY KEY AUTO_INCREMENT,
    id_toko CHAR(5) NOT NULL,
    id_customer CHAR(6),
    id_pegawai CHAR(6) NOT NULL,
    tgl_transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_belanja DECIMAL(14, 2) NOT NULL DEFAULT 0,
    total_diskon DECIMAL(14, 2) NOT NULL DEFAULT 0,
    total_bayar DECIMAL(14, 2) NOT NULL DEFAULT 0,
    status ENUM('selesai', 'batal') NOT NULL DEFAULT 'selesai',
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko),
    FOREIGN KEY (id_customer) REFERENCES customer (id_customer),
    FOREIGN KEY (id_pegawai) REFERENCES pegawai (id_pegawai)
) ENGINE = InnoDB;

CREATE TABLE detail_transaksi (
    id_detail INT PRIMARY KEY AUTO_INCREMENT,
    id_transaksi INT NOT NULL,
    id_barang CHAR(8) NOT NULL,
    id_promo CHAR(6),
    jumlah INT NOT NULL,
    harga_satuan DECIMAL(12, 2) NOT NULL,
    diskon DECIMAL(12, 2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(14, 2) NOT NULL,
    FOREIGN KEY (id_transaksi) REFERENCES transaksi_penjualan (id_transaksi),
    FOREIGN KEY (id_barang) REFERENCES barang (id_barang),
    FOREIGN KEY (id_promo) REFERENCES promo (id_promo)
) ENGINE = InnoDB;

CREATE TABLE pembayaran (
    id_pembayaran INT PRIMARY KEY AUTO_INCREMENT,
    id_transaksi INT NOT NULL,
    id_metode CHAR(4) NOT NULL,
    jumlah_bayar DECIMAL(14, 2) NOT NULL,
    no_referensi VARCHAR(50),
    tgl_bayar DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_transaksi) REFERENCES transaksi_penjualan (id_transaksi),
    FOREIGN KEY (id_metode) REFERENCES metode_pembayaran (id_metode)
) ENGINE = InnoDB;

-- ============================================================
-- DATA DUMMY
-- ============================================================

INSERT INTO
    toko (
        id_toko,
        nama_toko,
        alamat,
        kota,
        telp,
        jam_buka,
        jam_tutup,
        status
    )
VALUES (
        'TR001',
        'Swalayan Sentosa Rungkut',
        'Jl. Rungkut Industri No.8',
        'Surabaya',
        '031-5913001',
        '08:00:00',
        '21:00:00',
        'aktif'
    ),
    (
        'TR002',
        'Swalayan Sentosa Dukuh Kupang',
        'Jl. Dukuh Kupang No.20',
        'Surabaya',
        '031-5913002',
        '08:00:00',
        '21:00:00',
        'aktif'
    );

INSERT INTO
    divisi (
        id_divisi,
        nama_divisi,
        deskripsi,
        level_jabatan
    )
VALUES (
        'DR0001',
        'Kasir',
        'Melayani transaksi pembayaran pelanggan',
        'staff'
    ),
    (
        'DR0002',
        'Cleaning Service',
        'Menjaga kebersihan area toko',
        'staff'
    ),
    (
        'DR0003',
        'Pengendali Stok',
        'Mengelola & mengontrol stok barang gudang toko',
        'staff'
    ),
    (
        'DR0004',
        'Security',
        'Menjaga keamanan toko',
        'staff'
    ),
    (
        'DR0005',
        'Pegawai Section',
        'Bertugas pada section tertentu (Sembako/Fresh/Frozen/Household)',
        'staff'
    ),
    (
        'DR0006',
        'Store Supervisor',
        'Mengawasi operasional harian gerai',
        'supervisor'
    ),
    (
        'DR0007',
        'Head Store',
        'Manager/kepala toko per gerai',
        'manager'
    );

INSERT INTO
    pegawai (
        id_pegawai,
        nama,
        nik,
        no_hp,
        alamat,
        id_toko,
        section,
        tgl_masuk,
        status
    )
VALUES (
        'PR0001',
        'Surya Hartono',
        '3578020001',
        '081234570001',
        'Jl. Kenanga 1, Surabaya',
        'TR001',
        NULL,
        '2022-05-01',
        'aktif'
    ),
    (
        'PR0002',
        'Maya Anggraini',
        '3578020002',
        '081234570002',
        'Jl. Kenanga 2, Surabaya',
        'TR001',
        NULL,
        '2023-01-12',
        'aktif'
    ),
    (
        'PR0003',
        'Tono Hermawan',
        '3578020003',
        '081234570003',
        'Jl. Kenanga 3, Surabaya',
        'TR001',
        'Sembako',
        '2023-02-20',
        'aktif'
    ),
    (
        'PR0004',
        'Wulan Sari',
        '3578020004',
        '081234570004',
        'Jl. Kenanga 4, Surabaya',
        'TR001',
        'Frozen',
        '2023-03-15',
        'aktif'
    ),
    (
        'PR0005',
        'Joko Prasetyo',
        '3578020005',
        '081234570005',
        'Jl. Kenanga 5, Surabaya',
        'TR001',
        NULL,
        '2022-08-08',
        'aktif'
    ),
    (
        'PR0006',
        'Indah Permata',
        '3578020006',
        '081234570006',
        'Jl. Kenanga 6, Surabaya',
        'TR002',
        NULL,
        '2022-06-01',
        'aktif'
    ),
    (
        'PR0007',
        'Agus Salim',
        '3578020007',
        '081234570007',
        'Jl. Kenanga 7, Surabaya',
        'TR002',
        'Fresh',
        '2023-04-01',
        'aktif'
    ),
    (
        'PR0008',
        'Nita Kusuma',
        '3578020008',
        '081234570008',
        'Jl. Kenanga 8, Surabaya',
        'TR002',
        'Household',
        '2023-05-10',
        'aktif'
    );

INSERT INTO
    pegawai_divisi (
        id_pegawai,
        id_divisi,
        tgl_mulai,
        tgl_selesai,
        is_primary
    )
VALUES (
        'PR0001',
        'DR0007',
        '2022-05-01',
        NULL,
        'Ya'
    ), -- Head Store TR001
    (
        'PR0002',
        'DR0001',
        '2023-01-12',
        NULL,
        'Ya'
    ), -- Kasir
    (
        'PR0003',
        'DR0005',
        '2023-02-20',
        NULL,
        'Ya'
    ), -- Pegawai Section Sembako
    (
        'PR0003',
        'DR0001',
        '2024-02-01',
        NULL,
        'Tidak'
    ), -- rangkap bantu kasir saat ramai
    (
        'PR0004',
        'DR0005',
        '2023-03-15',
        NULL,
        'Ya'
    ), -- Pegawai Section Frozen
    (
        'PR0005',
        'DR0003',
        '2022-08-08',
        NULL,
        'Ya'
    ), -- Pengendali Stok
    (
        'PR0005',
        'DR0005',
        '2024-05-01',
        NULL,
        'Tidak'
    ), -- bantu Pegawai Section saat stok longgar
    (
        'PR0006',
        'DR0007',
        '2022-06-01',
        NULL,
        'Ya'
    ), -- Head Store TR002
    (
        'PR0007',
        'DR0005',
        '2023-04-01',
        NULL,
        'Ya'
    ), -- Pegawai Section Fresh
    (
        'PR0008',
        'DR0005',
        '2023-05-10',
        NULL,
        'Ya'
    );
-- Pegawai Section Household

INSERT INTO
    absensi (
        id_pegawai,
        tanggal,
        jam_masuk,
        jam_keluar,
        status,
        keterangan
    )
VALUES (
        'PR0002',
        '2026-06-15',
        '07:55:00',
        '17:00:00',
        'hadir',
        NULL
    ),
    (
        'PR0003',
        '2026-06-15',
        '08:00:00',
        '17:00:00',
        'hadir',
        NULL
    ),
    (
        'PR0004',
        '2026-06-15',
        NULL,
        NULL,
        'sakit',
        'Demam'
    ),
    (
        'PR0007',
        '2026-06-15',
        '07:58:00',
        '17:05:00',
        'hadir',
        NULL
    );

INSERT INTO
    kategori_barang (
        id_kategori,
        nama_kategori,
        perlu_penanganan,
        suhu_min,
        suhu_max,
        keterangan
    )
VALUES (
        'KR0001',
        'Sembako',
        'Tidak',
        NULL,
        NULL,
        'Beras, minyak, gula, dll'
    ),
    (
        'KR0002',
        'Fresh Produce',
        'Tidak',
        NULL,
        NULL,
        'Sayur & buah segar'
    ),
    (
        'KR0003',
        'Frozen Food',
        'Ya',
        -18.0,
        -12.0,
        'Wajib freezer'
    ),
    (
        'KR0004',
        'Dairy',
        'Ya',
        2.0,
        8.0,
        'Susu, keju, yogurt - perlu chiller'
    ),
    (
        'KR0005',
        'Household',
        'Tidak',
        NULL,
        NULL,
        'Sabun, deterjen, perlengkapan rumah'
    ),
    (
        'KR0006',
        'Minuman',
        'Tidak',
        NULL,
        NULL,
        'Minuman kemasan'
    ),
    (
        'KR0007',
        'Snack',
        'Tidak',
        NULL,
        NULL,
        'Makanan ringan'
    );

INSERT INTO
    barang (
        id_barang,
        nama_barang,
        id_kategori,
        id_supplier,
        satuan,
        berat_gram,
        is_aktif
    )
VALUES (
        'BG000001',
        'Beras Premium 5kg',
        'KR0001',
        'SR0001',
        'karung',
        5000.00,
        'Ya'
    ),
    (
        'BG000002',
        'Minyak Goreng 1L',
        'KR0001',
        'SR0001',
        'botol',
        1000.00,
        'Ya'
    ),
    (
        'BG000003',
        'Bayam Segar',
        'KR0002',
        'SR0002',
        'ikat',
        250.00,
        'Ya'
    ),
    (
        'BG000004',
        'Tomat Segar',
        'KR0002',
        'SR0002',
        'kg',
        1000.00,
        'Ya'
    ),
    (
        'BG000005',
        'Nugget Ayam Frozen',
        'KR0003',
        'SR0003',
        'pack',
        500.00,
        'Ya'
    ),
    (
        'BG000006',
        'Es Krim Cup',
        'KR0003',
        'SR0003',
        'pcs',
        100.00,
        'Ya'
    ),
    (
        'BG000007',
        'Susu UHT 1L',
        'KR0004',
        'SR0004',
        'karton',
        1030.00,
        'Ya'
    ),
    (
        'BG000008',
        'Keju Slice',
        'KR0004',
        'SR0004',
        'pack',
        200.00,
        'Ya'
    ),
    (
        'BG000009',
        'Deterjen Bubuk 1kg',
        'KR0005',
        'SR0005',
        'pack',
        1000.00,
        'Ya'
    ),
    (
        'BG000010',
        'Sabun Mandi Batang',
        'KR0005',
        'SR0005',
        'pcs',
        90.00,
        'Ya'
    );

INSERT INTO
    harga_barang (
        id_barang,
        id_toko,
        harga_beli,
        harga_jual,
        tgl_berlaku,
        tgl_berakhir,
        status,
        diinput_oleh,
        disetujui_oleh,
        tgl_approval,
        catatan
    )
VALUES (
        'BG000001',
        'TR001',
        58000,
        65000,
        '2026-01-01',
        NULL,
        'approved',
        'PR0003',
        'PR0001',
        '2026-01-01 09:00:00',
        NULL
    ),
    (
        'BG000002',
        'TR001',
        16000,
        19500,
        '2026-01-01',
        NULL,
        'approved',
        'PR0003',
        'PR0001',
        '2026-01-01 09:05:00',
        NULL
    ),
    (
        'BG000003',
        'TR001',
        3000,
        5000,
        '2026-01-01',
        NULL,
        'approved',
        'PR0007',
        'PR0001',
        '2026-01-01 09:10:00',
        NULL
    ),
    (
        'BG000005',
        'TR001',
        18000,
        25000,
        '2026-06-01',
        NULL,
        'pending',
        'PR0004',
        NULL,
        NULL,
        'Menunggu approval Head Store'
    ),
    (
        'BG000007',
        'TR002',
        13000,
        16500,
        '2026-01-01',
        NULL,
        'approved',
        'PR0007',
        'PR0006',
        '2026-01-01 09:15:00',
        NULL
    ),
    (
        'BG000009',
        'TR002',
        20000,
        27000,
        '2026-01-01',
        NULL,
        'approved',
        'PR0008',
        'PR0006',
        '2026-01-01 09:20:00',
        NULL
    );

INSERT INTO
    display_barang (
        id_barang,
        id_toko,
        id_harga,
        status_barang,
        tgl_display,
        tgl_tarik,
        diupdate_oleh
    )
VALUES (
        'BG000001',
        'TR001',
        1,
        'displayed',
        '2026-01-02',
        NULL,
        'PR0003'
    ),
    (
        'BG000002',
        'TR001',
        2,
        'displayed',
        '2026-01-02',
        NULL,
        'PR0003'
    ),
    (
        'BG000003',
        'TR001',
        3,
        'displayed',
        '2026-01-02',
        NULL,
        'PR0007'
    ),
    (
        'BG000007',
        'TR002',
        5,
        'displayed',
        '2026-01-02',
        NULL,
        'PR0007'
    ),
    (
        'BG000009',
        'TR002',
        6,
        'displayed',
        '2026-01-02',
        NULL,
        'PR0008'
    );
-- BG000005 di TR001 belum displayed karena harga masih pending

INSERT INTO
    stok_toko (
        id_barang,
        id_toko,
        jumlah,
        stok_minimal
    )
VALUES ('BG000001', 'TR001', 100, 30),
    ('BG000002', 'TR001', 12, 25), -- di bawah stok minimal -> perlu restock
    ('BG000003', 'TR001', 8, 15), -- di bawah stok minimal (fresh produce, cepat habis)
    ('BG000005', 'TR001', 6, 10), -- di bawah stok minimal
    ('BG000007', 'TR002', 40, 20),
    ('BG000009', 'TR002', 55, 20);

INSERT INTO
    jadwal_restock (
        id_barang,
        id_toko,
        id_supplier,
        frekuensi,
        hari_restock,
        jumlah_order,
        is_aktif
    )
VALUES (
        'BG000003',
        'TR001',
        'SR0002',
        'harian',
        'Setiap hari',
        30,
        'Ya'
    ),
    (
        'BG000002',
        'TR001',
        'SR0001',
        'mingguan',
        'Senin, Kamis',
        40,
        'Ya'
    ),
    (
        'BG000005',
        'TR001',
        'SR0003',
        'mingguan',
        'Senin, Rabu, Jumat',
        20,
        'Ya'
    ),
    (
        'BG000007',
        'TR002',
        'SR0004',
        'mingguan',
        'Selasa, Jumat',
        30,
        'Ya'
    );

INSERT INTO
    hutang_supplier (
        id_supplier,
        id_toko,
        jumlah,
        tgl_hutang,
        tgl_jatuh_tempo,
        status_hutang,
        tgl_lunas,
        keterangan
    )
VALUES (
        'SR0001',
        'TR001',
        5800000,
        '2026-06-01',
        '2026-07-01',
        'belum_lunas',
        NULL,
        'Pembelian beras & minyak batch Juni'
    ),
    (
        'SR0004',
        'TR002',
        2000000,
        '2026-06-03',
        '2026-06-17',
        'sebagian',
        '2026-06-10',
        'Pembayaran sebagian dairy'
    );

INSERT INTO
    customer (
        id_customer,
        nama,
        no_hp,
        email,
        tgl_daftar,
        poin_loyalty
    )
VALUES (
        'CR0001',
        'Siti Aminah',
        '081322220001',
        'siti.a@example.com',
        '2025-08-01',
        300
    ),
    (
        'CR0002',
        'Hendro Wibowo',
        '081322220002',
        'hendro@example.com',
        '2025-11-20',
        75
    );

INSERT INTO
    promo (
        id_promo,
        nama_promo,
        id_barang,
        jenis_diskon,
        nilai_diskon,
        tgl_mulai,
        tgl_selesai,
        is_aktif
    )
VALUES (
        'PG0001',
        'Diskon Minyak Goreng',
        'BG000002',
        'persen',
        8.00,
        '2026-06-01',
        '2026-06-30',
        'Ya'
    ),
    (
        'PG0002',
        'Hemat Susu UHT',
        'BG000007',
        'nominal',
        1500.00,
        '2026-06-05',
        '2026-06-25',
        'Ya'
    );

INSERT INTO
    metode_pembayaran (
        id_metode,
        nama_metode,
        keterangan
    )
VALUES (
        'MR01',
        'tunai',
        'Pembayaran cash'
    ),
    (
        'MR02',
        'debit',
        'Kartu debit via EDC'
    ),
    ('MR03', 'qris', 'Scan QRIS'),
    (
        'MR04',
        'transfer',
        'Transfer bank'
    ),
    (
        'MR05',
        'tarik_tunai',
        'Tarik tunai via EDC (cashback)'
    );

INSERT INTO
    transaksi_penjualan (
        id_toko,
        id_customer,
        id_pegawai,
        tgl_transaksi,
        total_belanja,
        total_diskon,
        total_bayar,
        status
    )
VALUES (
        'TR001',
        'CR0001',
        'PR0002',
        '2026-06-15 09:30:00',
        89500,
        1560,
        87940,
        'selesai'
    ),
    (
        'TR002',
        NULL,
        'PR0006',
        '2026-06-15 14:00:00',
        16500,
        1500,
        15000,
        'selesai'
    );

INSERT INTO
    detail_transaksi (
        id_transaksi,
        id_barang,
        id_promo,
        jumlah,
        harga_satuan,
        diskon,
        subtotal
    )
VALUES (
        1,
        'BG000001',
        NULL,
        1,
        65000,
        0,
        65000
    ),
    (
        1,
        'BG000002',
        'PG0001',
        1,
        19500,
        1560,
        17940
    ),
    (
        1,
        'BG000003',
        NULL,
        1,
        5000,
        0,
        5000
    ),
    (
        2,
        'BG000007',
        'PG0002',
        1,
        16500,
        1500,
        15000
    );

INSERT INTO
    pembayaran (
        id_transaksi,
        id_metode,
        jumlah_bayar,
        no_referensi,
        tgl_bayar
    )
VALUES (
        1,
        'MR02',
        87940,
        'EDC-TR001-000456',
        '2026-06-15 09:31:00'
    ),
    (
        2,
        'MR01',
        15000,
        NULL,
        '2026-06-15 14:01:00'
    );