CREATE DATABASE EXPRESS;

USE EXPRESS;

CREATE TABLE toko (
    id_toko CHAR(5) PRIMARY KEY, -- TE001, TE002
    nama_toko VARCHAR(60) NOT NULL,
    alamat VARCHAR(150) NOT NULL,
    kota VARCHAR(50) NOT NULL,
    telp VARCHAR(20),
    jam_buka TIME NOT NULL DEFAULT '06:00:00',
    jam_tutup TIME NOT NULL DEFAULT '23:00:00',
    is_24_jam ENUM('Ya', 'Tidak') NOT NULL DEFAULT 'Tidak',
    status ENUM('aktif', 'nonaktif') NOT NULL DEFAULT 'aktif'
) ENGINE = InnoDB;

-- 1. TOKO
INSERT INTO
    toko (
        id_toko,
        nama_toko,
        alamat,
        kota,
        telp,
        jam_buka,
        jam_tutup,
        is_24_jam,
        status
    )
VALUES (
        'TE001',
        'Express Darmo',
        'Jl. Darmo No. 10',
        'Surabaya',
        '031-11111111',
        '06:00:00',
        '23:00:00',
        'Tidak',
        'aktif'
    ),
    (
        'TE002',
        'Express Gubeng',
        'Jl. Gubeng No. 5',
        'Surabaya',
        '031-22222222',
        '00:00:00',
        '23:59:59',
        'Ya',
        'aktif'
    );

-- 2. DIVISI / JABATAN
-- Divisi toko express lebih ringkas dibanding reguler — tidak
-- ada Cleaning Service atau Security khusus karena ukuran toko
-- kecil. Kasir dan Pramuniaga sering rangkap tugas (lihat soal
-- poin 2), sehingga Head Store tetap dipertahankan untuk approval.
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

-- 2. DIVISI
INSERT INTO
    divisi (
        id_divisi,
        nama_divisi,
        deskripsi,
        level_jabatan
    )
VALUES (
        'DV0001',
        'Kasir',
        'Melayani transaksi pembayaran',
        'staff'
    ),
    (
        'DV0002',
        'Pramuniaga',
        'Display barang dan pelayanan pelanggan',
        'staff'
    ),
    (
        'DV0003',
        'Staff Gudang',
        'Penerimaan dan pengelolaan stok toko',
        'staff'
    ),
    (
        'DV0004',
        'Supervisor Toko',
        'Mengelola Operasional Harian',
        'supervisor'
    ),
    (
        'DV0005',
        'Head Store',
        'Supervisi operasional dan approval harga',
        'manager'
    );

-- 3. PEGAWAI
-- Tidak ada kolom `section` seperti di toko reguler, karena
-- variasi produk express lebih sempit (rokok, minuman, snack)
-- sehingga tidak perlu pembagian section per kategori.
-- ------------------------------------------------------------
CREATE TABLE pegawai (
    id_pegawai CHAR(6) PRIMARY KEY,
    nama VARCHAR(80) NOT NULL,
    nik VARCHAR(20) UNIQUE,
    no_hp VARCHAR(20),
    alamat VARCHAR(150),
    id_toko CHAR(5) NOT NULL,
    tgl_masuk DATE NOT NULL,
    status ENUM('aktif', 'nonaktif', 'cuti') NOT NULL DEFAULT 'aktif',
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko)
) ENGINE = InnoDB;

-- 3. PEGAWAI
INSERT INTO
    pegawai (
        id_pegawai,
        nama,
        nik,
        no_hp,
        alamat,
        id_toko,
        tgl_masuk,
        status
    )
VALUES (
        'PE0001',
        'Budi Santoso',
        '3578011234001',
        '08111111111',
        'Jl. A No.1 Surabaya',
        'TE001',
        '2022-01-10',
        'aktif'
    ),
    (
        'PE0002',
        'Siti Rahayu',
        '3578012345002',
        '08222222222',
        'Jl. B No.2 Surabaya',
        'TE001',
        '2022-03-15',
        'aktif'
    ),
    (
        'PE0003',
        'Andi Wijaya',
        '3578013456003',
        '08333333333',
        'Jl. C No.3 Surabaya',
        'TE002',
        '2021-07-01',
        'aktif'
    ),
    (
        'PE0004',
        'Dewi Puspita',
        '3578014567004',
        '08444444444',
        'Jl. D No.4 Surabaya',
        'TE002',
        '2023-01-05',
        'aktif'
    ),
    (
        'PE0005',
        'Rian Hidayat',
        '3578015678005',
        '08555555555',
        'Jl. E No.5 Surabaya',
        'TE001',
        '2023-08-20',
        'aktif'
    ),
    (
        'PE0006',
        'Nina Oktavia',
        '3578016789006',
        '08666666666',
        'Jl. F No.6 Surabaya',
        'TE002',
        '2024-02-11',
        'aktif'
    );

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

-- 4. PEGAWAI_DIVISI (rangkap tugas: kasir jadi pramuniaga, pramuniaga jadi kasir)
INSERT INTO
    pegawai_divisi (
        id_pegawai,
        id_divisi,
        tgl_mulai,
        tgl_selesai,
        is_primary
    )
VALUES (
        'PE0001',
        'DV0001',
        '2022-01-10',
        NULL,
        'Ya'
    ),
    (
        'PE0001',
        'DV0002',
        '2023-06-01',
        NULL,
        'Tidak'
    ), -- kasir rangkap pramuniaga
    (
        'PE0002',
        'DV0004',
        '2022-03-15',
        NULL,
        'Ya'
    ),
    (
        'PE0002',
        'DV0001',
        '2023-09-01',
        NULL,
        'Tidak'
    ), -- pramuniaga rangkap kasir
    (
        'PE0003',
        'DV0001',
        '2021-07-01',
        NULL,
        'Ya'
    ),
    (
        'PE0003',
        'DV0005',
        '2022-07-01',
        NULL,
        'Tidak'
    ), -- kasir senior rangkap head store
    (
        'PE0004',
        'DV0002',
        '2023-01-05',
        NULL,
        'Ya'
    ),
    (
        'PE0005',
        'DV0003',
        '2023-08-20',
        NULL,
        'Ya'
    ),
    (
        'PE0005',
        'DV0002',
        '2024-03-01',
        NULL,
        'Tidak'
    ), -- staff gudang bantu pramu
    (
        'PE0006',
        'DV0001',
        '2024-02-11',
        NULL,
        'Ya'
    );

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

-- 5. ABSENSI
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
        'PE0001',
        '2026-06-01',
        '07:55:00',
        '17:00:00',
        'hadir',
        NULL
    ),
    (
        'PE0002',
        '2026-06-01',
        '08:05:00',
        '17:00:00',
        'hadir',
        NULL
    ),
    (
        'PE0003',
        '2026-06-01',
        '08:00:00',
        '17:00:00',
        'hadir',
        NULL
    ),
    (
        'PE0004',
        '2026-06-01',
        '08:10:00',
        '17:00:00',
        'hadir',
        NULL
    ),
    (
        'PE0005',
        '2026-06-01',
        '07:30:00',
        '16:30:00',
        'hadir',
        NULL
    ),
    (
        'PE0006',
        '2026-06-01',
        '22:00:00',
        '06:00:00',
        'hadir',
        'Shift malam'
    ),
    (
        'PE0001',
        '2026-06-02',
        '08:00:00',
        '17:00:00',
        'hadir',
        NULL
    ),
    (
        'PE0002',
        '2026-06-02',
        NULL,
        NULL,
        'izin',
        'Keperluan keluarga'
    ),
    (
        'PE0003',
        '2026-06-02',
        '08:00:00',
        '17:00:00',
        'hadir',
        NULL
    ),
    (
        'PE0005',
        '2026-06-02',
        '07:30:00',
        '16:30:00',
        'hadir',
        NULL
    ),
    (
        'PE0006',
        '2026-06-02',
        NULL,
        NULL,
        'sakit',
        'Demam'
    );

-- ------------------------------------------------------------
-- 5. MASTER BARANG (independen dari gudang, fokus fast-moving)
-- perlu_penanganan tetap disediakan untuk konsistensi struktur
-- dengan toko_reguler, meski di express praktiknya minim
-- (mis. minuman dingin yang perlu kulkas, bukan frozen food).
-- ------------------------------------------------------------
CREATE TABLE kategori_barang (
    id_kategori CHAR(6) PRIMARY KEY,
    nama_kategori VARCHAR(50) NOT NULL,
    perlu_penanganan ENUM('Ya', 'Tidak') NOT NULL DEFAULT 'Tidak',
    suhu_min DECIMAL(5, 1),
    suhu_max DECIMAL(5, 1),
    keterangan VARCHAR(100)
) ENGINE = InnoDB;

-- 6. KATEGORI BARANG
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
        'KT0001',
        'Rokok',
        'Tidak',
        NULL,
        NULL,
        NULL
    ),
    (
        'KT0002',
        'Minuman',
        'Tidak',
        NULL,
        NULL,
        NULL
    ),
    (
        'KT0003',
        'Minuman Dingin',
        'Ya',
        2.0,
        8.0,
        'Simpan di kulkas'
    ),
    (
        'KT0004',
        'Snack',
        'Tidak',
        NULL,
        NULL,
        NULL
    ),
    (
        'KT0005',
        'Mie Instan',
        'Tidak',
        NULL,
        NULL,
        NULL
    ),
    (
        'KT0006',
        'Roti & Bakery',
        'Tidak',
        NULL,
        NULL,
        'Cepat kadaluwarsa, cek harian'
    );

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

-- 8. BARANG
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
        'BE000001',
        'Sampoerna Mild 16s',
        'KT0001',
        'SP0001',
        'bungkus',
        22.0,
        'Ya'
    ),
    (
        'BE000002',
        'Gudang Garam 12s',
        'KT0001',
        'SP0001',
        'bungkus',
        18.0,
        'Ya'
    ),
    (
        'BE000003',
        'Aqua Botol 600ml',
        'KT0002',
        'SP0002',
        'botol',
        600.0,
        'Ya'
    ),
    (
        'BE000004',
        'Teh Botol 350ml',
        'KT0003',
        'SP0002',
        'botol',
        350.0,
        'Ya'
    ),
    (
        'BE000005',
        'Pocari Sweat 500ml',
        'KT0003',
        'SP0002',
        'botol',
        500.0,
        'Ya'
    ),
    (
        'BE000006',
        'Chitato 68g',
        'KT0004',
        'SP0003',
        'pcs',
        68.0,
        'Ya'
    ),
    (
        'BE000007',
        'Oreo 137g',
        'KT0004',
        'SP0003',
        'pcs',
        137.0,
        'Ya'
    ),
    (
        'BE000008',
        'Indomie Goreng',
        'KT0005',
        'SP0003',
        'pcs',
        85.0,
        'Ya'
    ),
    (
        'BE000009',
        'Roti Tawar Sari',
        'KT0006',
        'SP0004',
        'pcs',
        400.0,
        'Ya'
    );

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

-- 9. HARGA BARANG (sebagian approved, sebagian pending — sesuai SOP approval)
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
        'BE000001',
        'TE001',
        13000,
        26000,
        '2026-06-01',
        NULL,
        'approved',
        'PE0001',
        'PE0003',
        '2026-06-01 07:30:00',
        NULL
    ),
    (
        'BE000001',
        'TE002',
        13000,
        26000,
        '2026-06-01',
        NULL,
        'approved',
        'PE0003',
        'PE0003',
        '2026-06-01 07:30:00',
        NULL
    ),
    (
        'BE000003',
        'TE001',
        3000,
        5000,
        '2026-06-01',
        NULL,
        'approved',
        'PE0001',
        'PE0003',
        '2026-06-01 07:30:00',
        NULL
    ),
    (
        'BE000004',
        'TE001',
        5500,
        8000,
        '2026-06-01',
        NULL,
        'approved',
        'PE0001',
        'PE0003',
        '2026-06-01 07:30:00',
        NULL
    ),
    (
        'BE000006',
        'TE001',
        8000,
        10000,
        '2026-06-01',
        NULL,
        'approved',
        'PE0001',
        'PE0003',
        '2026-06-01 07:30:00',
        NULL
    ),
    (
        'BE000008',
        'TE001',
        5000,
        13000,
        '2026-06-01',
        NULL,
        'approved',
        'PE0001',
        'PE0003',
        '2026-06-01 07:30:00',
        NULL
    ),
    (
        'BE000003',
        'TE002',
        3000,
        5000,
        '2026-06-01',
        NULL,
        'approved',
        'PE0003',
        'PE0003',
        '2026-06-01 07:30:00',
        NULL
    ),
    (
        'BE000006',
        'TE002',
        8000,
        10000,
        '2026-06-01',
        NULL,
        'approved',
        'PE0003',
        'PE0003',
        '2026-06-01 07:30:00',
        NULL
    ),
    -- barang harga fluktuatif, baru masuk, masih menunggu approval Head Store
    (
        'BE000002',
        'TE002',
        10000,
        20000,
        '2026-06-10',
        NULL,
        'pending',
        'PE0004',
        NULL,
        NULL,
        'Harga naik dari supplier, menunggu approval'
    ),
    (
        'BE000009',
        'TE001',
        7000,
        12000,
        '2026-06-12',
        NULL,
        'pending',
        'PE0005',
        NULL,
        NULL,
        'Produk baru, belum direview Head Store'
    );

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

-- 10. DISPLAY BARANG (hanya yang harganya sudah approved boleh displayed)
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
        'BE000001',
        'TE001',
        1,
        'displayed',
        '2026-06-01',
        NULL,
        'PE0002'
    ),
    (
        'BE000001',
        'TE002',
        2,
        'displayed',
        '2026-06-01',
        NULL,
        'PE0004'
    ),
    (
        'BE000003',
        'TE001',
        3,
        'displayed',
        '2026-06-01',
        NULL,
        'PE0002'
    ),
    (
        'BE000004',
        'TE001',
        4,
        'displayed',
        '2026-06-01',
        NULL,
        'PE0002'
    ),
    (
        'BE000006',
        'TE001',
        5,
        'displayed',
        '2026-06-01',
        NULL,
        'PE0002'
    ),
    (
        'BE000008',
        'TE001',
        6,
        'displayed',
        '2026-06-01',
        NULL,
        'PE0002'
    ),
    (
        'BE000003',
        'TE002',
        7,
        'displayed',
        '2026-06-01',
        NULL,
        'PE0004'
    ),
    (
        'BE000006',
        'TE002',
        8,
        'displayed',
        '2026-06-01',
        NULL,
        'PE0004'
    ),
    -- masih pending karena harga belum di-approve
    (
        'BE000002',
        'TE002',
        9,
        'pending',
        NULL,
        NULL,
        NULL
    ),
    (
        'BE000009',
        'TE001',
        10,
        'pending',
        NULL,
        NULL,
        NULL
    );

-- ------------------------------------------------------------
-- 8. STOK & RESTOCK
-- Restock di express umumnya lebih sering (harian) dibanding
-- reguler, karena ukuran toko kecil dan stok minimal lebih sedikit.
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

-- 11. STOK TOKO
INSERT INTO
    stok_toko (
        id_barang,
        id_toko,
        jumlah,
        stok_minimal
    )
VALUES ('BE000001', 'TE001', 80, 20),
    ('BE000002', 'TE001', 60, 15),
    ('BE000003', 'TE001', 120, 30),
    ('BE000004', 'TE001', 70, 20),
    ('BE000005', 'TE001', 40, 10),
    ('BE000006', 'TE001', 50, 10),
    ('BE000007', 'TE001', 35, 10),
    ('BE000008', 'TE001', 90, 20),
    ('BE000009', 'TE001', 8, 10), -- di bawah stok minimal, contoh untuk query monitoring
    ('BE000001', 'TE002', 70, 20),
    ('BE000003', 'TE002', 100, 30),
    ('BE000004', 'TE002', 55, 15),
    ('BE000006', 'TE002', 45, 10),
    ('BE000007', 'TE002', 28, 10),
    ('BE000008', 'TE002', 65, 20);

CREATE TABLE jadwal_restock (
    id_jadwal INT PRIMARY KEY AUTO_INCREMENT,
    id_barang CHAR(8) NOT NULL,
    id_toko CHAR(5) NOT NULL,
    id_supplier CHAR(6) NOT NULL,
    frekuensi ENUM(
        'harian',
        'mingguan',
        'bulanan'
    ) NOT NULL DEFAULT 'harian',
    hari_restock VARCHAR(50),
    jumlah_order INT NOT NULL DEFAULT 0,
    is_aktif ENUM('Ya', 'Tidak') NOT NULL DEFAULT 'Ya',
    FOREIGN KEY (id_barang) REFERENCES barang (id_barang),
    FOREIGN KEY (id_toko) REFERENCES toko (id_toko),
    FOREIGN KEY (id_supplier) REFERENCES GUDANG.supplier (id_supplier)
) ENGINE = InnoDB;

-- 12. JADWAL RESTOCK
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
        'BE000003',
        'TE001',
        'SP0002',
        'harian',
        NULL,
        200,
        'Ya'
    ),
    (
        'BE000003',
        'TE002',
        'SP0002',
        'harian',
        NULL,
        150,
        'Ya'
    ),
    (
        'BE000009',
        'TE001',
        'SP0004',
        'harian',
        NULL,
        30,
        'Ya'
    ),
    (
        'BE000001',
        'TE001',
        'SP0001',
        'mingguan',
        'Senin,Kamis',
        50,
        'Ya'
    ),
    (
        'BE000002',
        'TE002',
        'SP0001',
        'mingguan',
        'Senin,Kamis',
        40,
        'Ya'
    ),
    (
        'BE000006',
        'TE001',
        'SP0003',
        'mingguan',
        'Selasa,Jumat',
        60,
        'Ya'
    ),
    (
        'BE000008',
        'TE002',
        'SP0003',
        'mingguan',
        'Selasa,Jumat',
        50,
        'Ya'
    );

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

-- 13. HUTANG SUPPLIER (transaksi asli di level toko, bukan sekadar referensi)
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
        'SP0001',
        'TE001',
        1150000,
        '2026-06-01',
        '2026-07-01',
        'belum_lunas',
        NULL,
        'Restock rokok bulanan'
    ),
    (
        'SP0003',
        'TE002',
        780000,
        '2026-06-02',
        '2026-06-16',
        'belum_lunas',
        NULL,
        'Restock snack & mie'
    ),
    (
        'SP0002',
        'TE001',
        600000,
        '2026-05-20',
        '2026-06-03',
        'lunas',
        '2026-06-01',
        'Restock minuman, sudah dibayar'
    ),
    (
        'SP0004',
        'TE001',
        210000,
        '2026-06-05',
        '2026-06-12',
        'sebagian',
        NULL,
        'Sudah dibayar separuh, sisa menyusul'
    );

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

-- 14. CUSTOMER
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
        'CE0001',
        'Umum',
        NULL,
        NULL,
        '2026-01-01',
        0
    ),
    (
        'CE0002',
        'Budi Hartono',
        '081200001001',
        'budi@example.com',
        '2026-01-10',
        150
    ),
    (
        'CE0003',
        'Sari Dewi',
        '081200001002',
        'sari@example.com',
        '2026-03-22',
        320
    ),
    (
        'CE0004',
        'Rudi Saputra',
        '081200001003',
        'rudi@example.com',
        '2026-05-02',
        45
    );

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

-- 15. PROMO
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
        'PR0001',
        'Diskon Aqua 10%',
        'BE000003',
        'persen',
        10,
        '2026-06-01',
        '2026-06-30',
        'Ya'
    ),
    (
        'PR0002',
        'Diskon Chitato 5rb',
        'BE000006',
        'nominal',
        5000,
        '2026-06-01',
        '2026-06-15',
        'Ya'
    ),
    (
        'PR0003',
        'Promo Teh Botol',
        'BE000004',
        'persen',
        5,
        '2026-05-01',
        '2026-05-31',
        'Tidak'
    );
-- promo lama, sudah nonaktif

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

-- 16. METODE PEMBAYARAN
INSERT INTO
    metode_pembayaran (
        id_metode,
        nama_metode,
        keterangan
    )
VALUES (
        'PY01',
        'tunai',
        'Pembayaran tunai di kasir'
    ),
    (
        'PY02',
        'qris',
        'Pembayaran QRIS'
    ),
    (
        'PY03',
        'debit',
        'Pembayaran kartu debit'
    ),
    (
        'PY04',
        'transfer',
        'Transfer bank, biasa untuk reseller'
    ),
    (
        'PY05',
        'tarik_tunai',
        'Tarik tunai di kasir, biaya admin berlaku'
    );

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

-- 17. TRANSAKSI PENJUALAN
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
        'TE001',
        'CE0001',
        'PE0001',
        '2026-06-01 09:15:00',
        31000,
        0,
        31000,
        'selesai'
    ),
    (
        'TE001',
        'CE0002',
        'PE0001',
        '2026-06-01 10:30:00',
        31000,
        2600,
        28400,
        'selesai'
    ),
    (
        'TE001',
        'CE0001',
        'PE0002',
        '2026-06-01 14:00:00',
        13000,
        0,
        13000,
        'selesai'
    ),
    (
        'TE002',
        'CE0003',
        'PE0003',
        '2026-06-02 08:45:00',
        36000,
        5000,
        31000,
        'selesai'
    ),
    (
        'TE002',
        'CE0004',
        'PE0006',
        '2026-06-02 23:10:00',
        26000,
        0,
        26000,
        'selesai'
    ),
    (
        'TE001',
        'CE0001',
        'PE0001',
        '2026-06-02 17:30:00',
        8000,
        0,
        8000,
        'batal'
    );
-- contoh transaksi batal

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

-- 18. DETAIL TRANSAKSI
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
        'BE000001',
        NULL,
        1,
        26000,
        0,
        26000
    ),
    (
        1,
        'BE000003',
        NULL,
        1,
        5000,
        0,
        5000
    ),
    (
        2,
        'BE000003',
        'PR0001',
        2,
        5000,
        2600,
        7400
    ),
    (
        2,
        'BE000001',
        NULL,
        1,
        26000,
        0,
        26000
    ),
    (
        3,
        'BE000004',
        NULL,
        1,
        8000,
        0,
        8000
    ),
    (
        3,
        'BE000003',
        NULL,
        1,
        5000,
        0,
        5000
    ),
    (
        4,
        'BE000006',
        'PR0002',
        2,
        10000,
        5000,
        15000
    ),
    (
        4,
        'BE000001',
        NULL,
        1,
        26000,
        0,
        26000
    ),
    (
        5,
        'BE000001',
        NULL,
        1,
        26000,
        0,
        26000
    ),
    (
        6,
        'BE000004',
        NULL,
        1,
        8000,
        0,
        8000
    );

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

-- 19. PEMBAYARAN
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
        'PY01',
        31000,
        NULL,
        '2026-06-01 09:15:00'
    ),
    (
        2,
        'PY02',
        28400,
        'QR20260601001',
        '2026-06-01 10:30:00'
    ),
    (
        3,
        'PY03',
        13000,
        'DB20260601007',
        '2026-06-01 14:00:00'
    ),
    (
        4,
        'PY01',
        31000,
        NULL,
        '2026-06-02 08:45:00'
    ),
    (
        5,
        'PY02',
        26000,
        'QR20260602014',
        '2026-06-02 23:10:00'
    );
-- nambah