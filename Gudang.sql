create database GUDANG;
use GUDANG;

-- ------------------------------------------------------------
-- 1. TIPE TOKO
-- ------------------------------------------------------------
CREATE TABLE tipe_toko (
    id_tipe       VARCHAR(4)  PRIMARY KEY,
    nama_tipe     VARCHAR(10) NOT NULL,
    deskripsi     VARCHAR(100)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 2. TOKO
-- id_toko disamain persis sama yang dipakai di toko_express
-- (TE001, TE002) dan toko_reguler (TR001, TR002), ditambah DC001
-- untuk gudang pusat itu sendiri.
-- ------------------------------------------------------------
CREATE TABLE toko (
    id_toko       CHAR(5) PRIMARY KEY,
    nama_toko     VARCHAR(60) NOT NULL,
    id_tipe       CHAR(4) NOT NULL,
    alamat        VARCHAR(150) NOT NULL,
    kota          VARCHAR(50) NOT NULL,
    telp          VARCHAR(20),
    status        ENUM('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
    FOREIGN KEY (id_tipe) REFERENCES tipe_toko(id_tipe)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 3. DIVISI
-- Hanya divisi yang bekerja di DC 
-- ------------------------------------------------------------
CREATE TABLE divisi (
    id_divisi     CHAR(6) PRIMARY KEY,
    nama_divisi   VARCHAR(50) NOT NULL,
    deskripsi     VARCHAR(100)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 4. PEGAWAI
-- Hanya staff yang bertugas di DC (id_toko = 'DC001'). Data
-- pegawai toko_express dan toko_reguler tetap menjadi milik
-- database tokonya masing-masing, tidak ditulis lagi di sini.
-- ------------------------------------------------------------
CREATE TABLE pegawai (
    id_pegawai    CHAR(6) PRIMARY KEY,
    nama          VARCHAR(80) NOT NULL,
    nik           VARCHAR(20) UNIQUE,
    no_hp         VARCHAR(20),
    alamat        VARCHAR(150),
    id_toko       CHAR(5) NOT NULL,
    tgl_masuk     DATE NOT NULL,
    status        ENUM('aktif','nonaktif','cuti') NOT NULL DEFAULT 'aktif',
    FOREIGN KEY (id_toko) REFERENCES toko(id_toko)
) ENGINE=InnoDB;
 
CREATE TABLE pegawai_divisi (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    id_pegawai    CHAR(6) NOT NULL,
    id_divisi     CHAR(6) NOT NULL,
    tgl_mulai     DATE NOT NULL,
    tgl_selesai   DATE,
    is_primary    ENUM('Ya','Tidak') NOT NULL DEFAULT 'Tidak',
    FOREIGN KEY (id_pegawai) REFERENCES pegawai(id_pegawai),
    FOREIGN KEY (id_divisi)  REFERENCES divisi(id_divisi)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 5. ABSENSI
-- ------------------------------------------------------------
CREATE TABLE absensi (
    id_absensi    INT PRIMARY KEY AUTO_INCREMENT,
    id_pegawai    CHAR(6) NOT NULL,
    tanggal       DATE NOT NULL,
    jam_masuk     TIME,
    jam_keluar    TIME,
    status        ENUM('hadir','izin','sakit','alpha') NOT NULL DEFAULT 'hadir',
    keterangan    VARCHAR(150),
    FOREIGN KEY (id_pegawai) REFERENCES pegawai(id_pegawai)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 6. KATEGORI BARANG
-- Gabungan kategori dari toko_express dan toko_reguler, karena
-- gudang adalah master tunggal untuk semua toko.
-- ------------------------------------------------------------
CREATE TABLE kategori_barang (
    id_kategori         CHAR(6) PRIMARY KEY,
    nama_kategori       VARCHAR(50) NOT NULL,
    perlu_penanganan    ENUM('Ya','Tidak') NOT NULL DEFAULT 'Tidak',
    suhu_min            DECIMAL(5,1),
    suhu_max            DECIMAL(5,1),
    keterangan          VARCHAR(100)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 7. SUPPLIER
-- Tabel ini menjadi SUMBER FK antar database untuk toko_express
-- dan toko_reguler. Wajib ENGINE=InnoDB dan harus sudah ada/terisi
-- sebelum database toko dibuat.
-- ------------------------------------------------------------
CREATE TABLE supplier (
    id_supplier   CHAR(6) PRIMARY KEY,
    nama          VARCHAR(80) NOT NULL,
    kontak_pic    VARCHAR(60),
    no_hp         VARCHAR(20),
    alamat        VARCHAR(150),
    kota          VARCHAR(50),
    jadwal_kirim  VARCHAR(100),
    top_hari      TINYINT UNSIGNED DEFAULT 30,
    is_aktif      ENUM('Ya','Tidak') NOT NULL DEFAULT 'Ya'
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 8. BARANG
-- Master barang gabungan dari toko_express dan toko_reguler,
-- ditandai tipe_toko sesuai mana yang menjual produk tersebut.
-- ------------------------------------------------------------
CREATE TABLE barang (
    id_barang     CHAR(8) PRIMARY KEY,
    nama_barang   VARCHAR(100) NOT NULL,
    id_kategori   CHAR(6) NOT NULL,
    id_supplier   CHAR(6) NOT NULL,
    satuan        VARCHAR(20) NOT NULL,
    berat_gram    DECIMAL(8,2),
    tipe_toko     ENUM('DC','Reguler','Express') NOT NULL,
    is_aktif      ENUM('Ya','Tidak') NOT NULL DEFAULT 'Ya',
    FOREIGN KEY (id_kategori) REFERENCES kategori_barang(id_kategori),
    FOREIGN KEY (id_supplier) REFERENCES supplier(id_supplier)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 9. HARGA BARANG
-- diinput_oleh dan disetujui_oleh diisi staff DC (tabel pegawai
-- di database ini hanya berisi staff DC).
-- ------------------------------------------------------------
CREATE TABLE harga_barang (
    id_harga       INT PRIMARY KEY AUTO_INCREMENT,
    id_barang      CHAR(8) NOT NULL,
    id_toko        CHAR(5) NOT NULL,
    harga_beli     DECIMAL(12,2) NOT NULL,
    harga_jual     DECIMAL(12,2) NOT NULL,
    tgl_berlaku    DATE NOT NULL,
    tgl_berakhir   DATE,
    status         ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    diinput_oleh   CHAR(6),
    disetujui_oleh CHAR(6),
    tgl_approval   DATETIME,
    catatan        VARCHAR(150),
    FOREIGN KEY (id_barang)      REFERENCES barang(id_barang),
    FOREIGN KEY (id_toko)        REFERENCES toko(id_toko),
    FOREIGN KEY (diinput_oleh)   REFERENCES pegawai(id_pegawai),
    FOREIGN KEY (disetujui_oleh) REFERENCES pegawai(id_pegawai)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 10. DISPLAY BARANG
-- ------------------------------------------------------------
CREATE TABLE display_barang (
    id_display    INT PRIMARY KEY AUTO_INCREMENT,
    id_barang     CHAR(8) NOT NULL,
    id_toko       CHAR(5) NOT NULL,
    id_harga      INT NOT NULL,
    status_barang ENUM('pending','displayed','ditarik') NOT NULL DEFAULT 'pending',
    tgl_display   DATE,
    tgl_tarik     DATE,
    diupdate_oleh CHAR(6),
    FOREIGN KEY (id_barang)     REFERENCES barang(id_barang),
    FOREIGN KEY (id_toko)       REFERENCES toko(id_toko),
    FOREIGN KEY (id_harga)      REFERENCES harga_barang(id_harga),
    FOREIGN KEY (diupdate_oleh) REFERENCES pegawai(id_pegawai)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 11. STOK DC
-- ------------------------------------------------------------
CREATE TABLE stok_dc (
    id_stok_dc    INT PRIMARY KEY AUTO_INCREMENT,
    id_barang     CHAR(8) NOT NULL,
    jumlah        INT NOT NULL DEFAULT 0,
    stok_minimal  INT NOT NULL DEFAULT 0,
    last_updated  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                           ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_barang) REFERENCES barang(id_barang)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 12. JADWAL RESTOCK
-- ------------------------------------------------------------
CREATE TABLE jadwal_restock (
    id_jadwal     INT PRIMARY KEY AUTO_INCREMENT,
    id_barang     CHAR(8) NOT NULL,
    id_toko       CHAR(5) NOT NULL,
    id_supplier   CHAR(6) NOT NULL,
    frekuensi     ENUM('harian','mingguan','bulanan') NOT NULL DEFAULT 'mingguan',
    hari_restock  VARCHAR(50),
    jumlah_order  INT NOT NULL DEFAULT 0,
    is_aktif      ENUM('Ya','Tidak') NOT NULL DEFAULT 'Ya',
    FOREIGN KEY (id_barang)   REFERENCES barang(id_barang),
    FOREIGN KEY (id_toko)     REFERENCES toko(id_toko),
    FOREIGN KEY (id_supplier) REFERENCES supplier(id_supplier)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 13. HUTANG SUPPLIER
-- Berperan sebagai rekap konsolidasi pusat dari hutang yang
-- sesungguhnya tercatat di masing-masing database toko.
-- ------------------------------------------------------------
CREATE TABLE hutang_supplier (
    id_hutang       INT PRIMARY KEY AUTO_INCREMENT,
    id_supplier     CHAR(6) NOT NULL,
    id_toko         CHAR(5) NOT NULL,
    jumlah          DECIMAL(14,2) NOT NULL,
    tgl_hutang      DATE NOT NULL,
    tgl_jatuh_tempo DATE NOT NULL,
    status_hutang   ENUM('belum_lunas','lunas','sebagian') NOT NULL DEFAULT 'belum_lunas',
    tgl_lunas       DATE,
    keterangan      VARCHAR(150),
    FOREIGN KEY (id_supplier) REFERENCES supplier(id_supplier),
    FOREIGN KEY (id_toko)     REFERENCES toko(id_toko)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 14. DISTRIBUSI BARANG (DC -> Toko)
-- diterima_oleh diisi staff DC yang menangani pengiriman dari
-- sisi gudang (lihat catatan pada bagian data dummy).
-- ------------------------------------------------------------
CREATE TABLE distribusi_barang (
    id_distribusi INT PRIMARY KEY AUTO_INCREMENT,
    id_toko       CHAR(5) NOT NULL,
    tgl_kirim     DATE NOT NULL,
    tgl_terima    DATE,
    status_dist   ENUM('dikirim','diterima','sebagian') NOT NULL DEFAULT 'dikirim',
    diterima_oleh CHAR(6),
    catatan       VARCHAR(150),
    FOREIGN KEY (id_toko)       REFERENCES toko(id_toko),
    FOREIGN KEY (diterima_oleh) REFERENCES pegawai(id_pegawai)
) ENGINE=InnoDB;
 
CREATE TABLE detail_distribusi (
    id_detail     INT PRIMARY KEY AUTO_INCREMENT,
    id_distribusi INT NOT NULL,
    id_barang     CHAR(8) NOT NULL,
    jumlah_kirim  INT NOT NULL,
    jumlah_terima INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_distribusi) REFERENCES distribusi_barang(id_distribusi),
    FOREIGN KEY (id_barang)     REFERENCES barang(id_barang)
) ENGINE=InnoDB;
 
-- ------------------------------------------------------------
-- 15. REKAP STOK TOKO
-- Hasil sinkronisasi dari masing-masing database toko ke gudang.
-- ------------------------------------------------------------
CREATE TABLE rekap_stok_toko (
    id_rekap      INT PRIMARY KEY AUTO_INCREMENT,
    id_toko       CHAR(5) NOT NULL,
    id_barang     CHAR(8) NOT NULL,
    jumlah_stok   INT NOT NULL DEFAULT 0,
    stok_minimal  INT NOT NULL DEFAULT 0,
    tgl_sync      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_toko)   REFERENCES toko(id_toko),
    FOREIGN KEY (id_barang) REFERENCES barang(id_barang)
) ENGINE=InnoDB;
 
 
-- ============================================================
--  DATA DUMMY — gudang
-- ============================================================
 
-- 1. TIPE TOKO
INSERT INTO tipe_toko (id_tipe, nama_tipe, deskripsi) VALUES
  ('TT01','Express', 'Toko layanan cepat, produk fast-moving'),
  ('TT02','Reguler', 'Toko lengkap, variasi produk lebih luas'),
  ('TT03','DC',      'Distribution Centre / Gudang Pusat');
 
-- 2. TOKO
INSERT INTO toko (id_toko, nama_toko, id_tipe, alamat, kota, telp, status) VALUES
  ('TE001','Express Darmo',                'TT01','Jl. Darmo No. 10',          'Surabaya','031-11111111','aktif'),
  ('TE002','Express Gubeng',               'TT01','Jl. Gubeng No. 5',          'Surabaya','031-22222222','aktif'),
  ('TR001','Swalayan Sentosa Rungkut',     'TT02','Jl. Rungkut Industri No.8', 'Surabaya','031-5913001', 'aktif'),
  ('TR002','Swalayan Sentosa Dukuh Kupang','TT02','Jl. Dukuh Kupang No.20',    'Surabaya','031-5913002', 'aktif'),
  ('DC001','Gudang Pusat ITS',             'TT03','Jl. Industri No. 1',        'Surabaya','031-55555555','aktif');
 
-- 3. DIVISI (khusus DC)
INSERT INTO divisi (id_divisi, nama_divisi, deskripsi) VALUES
  ('DG0001','Staff Penerimaan', 'Mengecek kualitas dan jumlah barang masuk dari supplier'),
  ('DG0002','Staff Penyimpanan','Mengatur penempatan barang di rak gudang'),
  ('DG0003','Staff Packing',   'Menyiapkan dan mengemas barang untuk distribusi ke toko'),
  ('DG0004','Admin Stok DC',   'Mengelola data stok_dc dan rekap_stok_toko'),
  ('DG0005','Kepala Gudang',   'Supervisi operasional DC dan approval harga barang');
 
-- 4. PEGAWAI (hanya staff DC)
INSERT INTO pegawai (id_pegawai, nama, nik, no_hp, alamat, id_toko, tgl_masuk, status) VALUES
  ('PD0001','Doni Pratama',    '3578019012009','08999999999','Jl. I No.9 Surabaya', 'DC001','2019-03-01','aktif'),
  ('PD0002','Fitri Handayani', '3578010123010','08100000000','Jl. J No.10 Surabaya','DC001','2020-11-11','aktif'),
  ('PD0003','Agung Wibisono',  '3578019034011','08177777777','Jl. K No.11 Surabaya','DC001','2021-05-15','aktif'),
  ('PD0004','Melati Putri',    '3578019045012','08188888888','Jl. L No.12 Surabaya','DC001','2022-09-01','aktif');
 
-- 5. PEGAWAI_DIVISI
INSERT INTO pegawai_divisi (id_pegawai, id_divisi, tgl_mulai, tgl_selesai, is_primary) VALUES
  ('PD0001','DG0005','2019-03-01', NULL,'Ya'),
  ('PD0002','DG0004','2020-11-11', NULL,'Ya'),
  ('PD0002','DG0001','2021-06-01', NULL,'Tidak'),
  ('PD0003','DG0002','2021-05-15', NULL,'Ya'),
  ('PD0004','DG0003','2022-09-01', NULL,'Ya');
 
-- 6. ABSENSI
INSERT INTO absensi (id_pegawai, tanggal, jam_masuk, jam_keluar, status, keterangan) VALUES
  ('PD0001','2026-06-01','07:30:00','16:30:00','hadir', NULL),
  ('PD0002','2026-06-01','07:30:00','16:30:00','hadir', NULL),
  ('PD0003','2026-06-01','07:00:00','16:00:00','hadir', NULL),
  ('PD0004','2026-06-01','07:00:00','16:00:00','hadir', NULL),
  ('PD0003','2026-06-02','07:00:00','16:00:00','hadir', NULL),
  ('PD0004','2026-06-02', NULL,      NULL,      'izin',  'Keperluan keluarga');
 
-- 7. KATEGORI BARANG (gabungan express + reguler)
INSERT INTO kategori_barang (id_kategori, nama_kategori, perlu_penanganan, suhu_min, suhu_max, keterangan) VALUES
  ('KT0001','Rokok',          'Tidak', NULL,  NULL, NULL),
  ('KT0002','Minuman',        'Tidak', NULL,  NULL, NULL),
  ('KT0003','Minuman Dingin', 'Ya',    2.0,   8.0,  'Simpan di kulkas'),
  ('KT0004','Snack',          'Tidak', NULL,  NULL, NULL),
  ('KT0005','Mie Instan',     'Tidak', NULL,  NULL, NULL),
  ('KT0006','Roti & Bakery',  'Tidak', NULL,  NULL, 'Cepat kadaluwarsa, cek harian'),
  ('KR0001','Sembako',        'Tidak', NULL,  NULL, 'Beras, minyak, gula, dll'),
  ('KR0002','Fresh Produce',  'Tidak', NULL,  NULL, 'Sayur & buah segar'),
  ('KR0003','Frozen Food',    'Ya',    -18.0,-12.0, 'Wajib freezer'),
  ('KR0004','Dairy',          'Ya',    2.0,   8.0,  'Susu, keju, yogurt - perlu chiller'),
  ('KR0005','Household',      'Tidak', NULL,  NULL, 'Sabun, deterjen, perlengkapan rumah');
 
-- 8. SUPPLIER (sumber FK lintas database)
INSERT INTO supplier (id_supplier, nama, kontak_pic, no_hp, alamat, kota, jadwal_kirim, top_hari, is_aktif) VALUES
  ('SP0001','PT Sampoerna Tbk',   'Andi Wirawan', '08112345001','Jl. Rungkut Industri Surabaya','Surabaya','Senin,Kamis',  30,'Ya'),
  ('SP0002','PT Tirta Investama', 'Budi Setiawan','08112345002','Jl. Darmo Permai Surabaya',    'Surabaya','Setiap hari',  14,'Ya'),
  ('SP0003','PT Indofood CBP',    'Citra Lestari','08112345003','Jl. Raya Bypass Jakarta',      'Jakarta', 'Selasa,Jumat', 14,'Ya'),
  ('SP0004','PT Sari Roti',       'Deni Pratama', '08112345004','Jl. Industri Sidoarjo',        'Sidoarjo','Setiap hari',  7, 'Ya'),
  ('SR0001','PT Sembako Makmur',  'Rudi',         '081298770001','Jl. Industri 5','Surabaya','Senin, Kamis',        30,'Ya'),
  ('SR0002','CV Sayur Segar Tani','Siti',         '081298770002','Jl. Industri 6','Surabaya','Setiap hari',          7,'Ya'),
  ('SR0003','PT Beku Sejahtera',  'Lina',         '081298770003','Jl. Industri 7','Surabaya','Senin, Rabu, Jumat',  21,'Ya'),
  ('SR0004','UD Dairy Prima',     'Bayu',         '081298770004','Jl. Industri 8','Surabaya','Selasa, Jumat',       14,'Ya'),
  ('SR0005','PT Household Indo',  'Fitri',        '081298770005','Jl. Industri 9','Surabaya','Rabu',                45,'Ya');
 
-- 9. BARANG (gabungan express BE... + reguler BG...)
INSERT INTO barang (id_barang, nama_barang, id_kategori, id_supplier, satuan, berat_gram, tipe_toko, is_aktif) VALUES
  ('BE000001','Sampoerna Mild 16s', 'KT0001','SP0001','bungkus', 22.0, 'Express','Ya'),
  ('BE000002','Gudang Garam 12s',   'KT0001','SP0001','bungkus', 18.0, 'Express','Ya'),
  ('BE000003','Aqua Botol 600ml',   'KT0002','SP0002','botol',  600.0, 'Express','Ya'),
  ('BE000004','Teh Botol 350ml',    'KT0003','SP0002','botol',  350.0, 'Express','Ya'),
  ('BE000005','Pocari Sweat 500ml', 'KT0003','SP0002','botol',  500.0, 'Express','Ya'),
  ('BE000006','Chitato 68g',        'KT0004','SP0003','pcs',     68.0, 'Express','Ya'),
  ('BE000007','Oreo 137g',          'KT0004','SP0003','pcs',    137.0, 'Express','Ya'),
  ('BE000008','Indomie Goreng',     'KT0005','SP0003','pcs',     85.0, 'Express','Ya'),
  ('BE000009','Roti Tawar Sari',    'KT0006','SP0004','pcs',    400.0, 'Express','Ya'),
  ('BG000001','Beras Premium 5kg',     'KR0001','SR0001','karung',5000.0,'Reguler','Ya'),
  ('BG000002','Minyak Goreng 1L',      'KR0001','SR0001','botol', 1000.0,'Reguler','Ya'),
  ('BG000003','Bayam Segar',           'KR0002','SR0002','ikat',   250.0,'Reguler','Ya'),
  ('BG000004','Tomat Segar',           'KR0002','SR0002','kg',    1000.0,'Reguler','Ya'),
  ('BG000005','Nugget Ayam Frozen',    'KR0003','SR0003','pack',   500.0,'Reguler','Ya'),
  ('BG000006','Es Krim Cup',           'KR0003','SR0003','pcs',    100.0,'Reguler','Ya'),
  ('BG000007','Susu UHT 1L',           'KR0004','SR0004','karton',1030.0,'Reguler','Ya'),
  ('BG000008','Keju Slice',            'KR0004','SR0004','pack',   200.0,'Reguler','Ya'),
  ('BG000009','Deterjen Bubuk 1kg',    'KR0005','SR0005','pack',  1000.0,'Reguler','Ya'),
  ('BG000010','Sabun Mandi Batang',    'KR0005','SR0005','pcs',     90.0,'Reguler','Ya');
 
-- 10. HARGA BARANG
INSERT INTO harga_barang (id_barang, id_toko, harga_beli, harga_jual, tgl_berlaku, tgl_berakhir, status, diinput_oleh, disetujui_oleh, tgl_approval, catatan) VALUES
  ('BE000001','TE001',13000,26000,'2026-06-01',NULL,'approved','PD0002','PD0001','2026-06-01 07:30:00', NULL),
  ('BE000001','TE002',13000,26000,'2026-06-01',NULL,'approved','PD0002','PD0001','2026-06-01 07:30:00', NULL),
  ('BE000003','TE001', 3000, 5000,'2026-06-01',NULL,'approved','PD0002','PD0001','2026-06-01 07:30:00', NULL),
  ('BE000004','TE001', 5500, 8000,'2026-06-01',NULL,'approved','PD0002','PD0001','2026-06-01 07:30:00', NULL),
  ('BE000006','TE001', 8000,10000,'2026-06-01',NULL,'approved','PD0002','PD0001','2026-06-01 07:30:00', NULL),
  ('BE000008','TE001', 5000,13000,'2026-06-01',NULL,'approved','PD0002','PD0001','2026-06-01 07:30:00', NULL),
  ('BE000003','TE002', 3000, 5000,'2026-06-01',NULL,'approved','PD0002','PD0001','2026-06-01 07:30:00', NULL),
  ('BE000006','TE002', 8000,10000,'2026-06-01',NULL,'approved','PD0002','PD0001','2026-06-01 07:30:00', NULL),
  ('BE000002','TE002',10000,20000,'2026-06-10',NULL,'pending', 'PD0002',NULL,    NULL,'Harga naik dari supplier, menunggu approval'),
  ('BE000009','TE001', 7000,12000,'2026-06-12',NULL,'pending', 'PD0002',NULL,    NULL,'Produk baru, belum direview Kepala Gudang'),
  ('BG000001','TR001',58000,65000,'2026-01-01',NULL,'approved','PD0002','PD0001','2026-01-01 09:00:00',NULL),
  ('BG000002','TR001',16000,19500,'2026-01-01',NULL,'approved','PD0002','PD0001','2026-01-01 09:05:00',NULL),
  ('BG000003','TR001', 3000, 5000,'2026-01-01',NULL,'approved','PD0002','PD0001','2026-01-01 09:10:00',NULL),
  ('BG000005','TR001',18000,25000,'2026-06-01',NULL,'pending', 'PD0002',NULL,    NULL,'Menunggu approval Kepala Gudang'),
  ('BG000007','TR002',13000,16500,'2026-01-01',NULL,'approved','PD0002','PD0001','2026-01-01 09:15:00',NULL),
  ('BG000009','TR002',20000,27000,'2026-01-01',NULL,'approved','PD0002','PD0001','2026-01-01 09:20:00',NULL);
 
-- 11. DISPLAY BARANG
INSERT INTO display_barang (id_barang, id_toko, id_harga, status_barang, tgl_display, tgl_tarik, diupdate_oleh) VALUES
  ('BE000001','TE001',1,'displayed','2026-06-01',NULL,'PD0002'),
  ('BE000001','TE002',2,'displayed','2026-06-01',NULL,'PD0002'),
  ('BE000003','TE001',3,'displayed','2026-06-01',NULL,'PD0002'),
  ('BE000004','TE001',4,'displayed','2026-06-01',NULL,'PD0002'),
  ('BE000006','TE001',5,'displayed','2026-06-01',NULL,'PD0002'),
  ('BE000008','TE001',6,'displayed','2026-06-01',NULL,'PD0002'),
  ('BE000003','TE002',7,'displayed','2026-06-01',NULL,'PD0002'),
  ('BE000006','TE002',8,'displayed','2026-06-01',NULL,'PD0002'),
  ('BE000002','TE002',9, 'pending', NULL,        NULL,NULL),
  ('BE000009','TE001',10,'pending', NULL,        NULL,NULL),
  ('BG000001','TR001',11,'displayed','2026-01-02',NULL,'PD0002'),
  ('BG000002','TR001',12,'displayed','2026-01-02',NULL,'PD0002'),
  ('BG000003','TR001',13,'displayed','2026-01-02',NULL,'PD0002'),
  ('BG000007','TR002',14,'displayed','2026-01-02',NULL,'PD0002'),
  ('BG000009','TR002',15,'displayed','2026-01-02',NULL,'PD0002');
 
-- 12. STOK DC
INSERT INTO stok_dc (id_barang, jumlah, stok_minimal, last_updated) VALUES
  ('BE000001',500,100,'2026-06-01 08:00:00'),
  ('BE000002',400,80, '2026-06-01 08:00:00'),
  ('BE000003',1000,200,'2026-06-01 08:00:00'),
  ('BE000004',300,60, '2026-06-01 08:00:00'),
  ('BE000005',250,50, '2026-06-01 08:00:00'),
  ('BE000006',400,80, '2026-06-01 08:00:00'),
  ('BE000007',300,60, '2026-06-01 08:00:00'),
  ('BE000008',500,100,'2026-06-01 08:00:00'),
  ('BE000009',100,30, '2026-06-01 08:00:00'),
  ('BG000001',300,60, '2026-06-01 08:00:00'),
  ('BG000002',250,50, '2026-06-01 08:00:00'),
  ('BG000003',150,40, '2026-06-01 08:00:00'),
  ('BG000004',150,40, '2026-06-01 08:00:00'),
  ('BG000005',120,30, '2026-06-01 08:00:00'),
  ('BG000006',120,30, '2026-06-01 08:00:00'),
  ('BG000007',200,50, '2026-06-01 08:00:00'),
  ('BG000008',200,50, '2026-06-01 08:00:00'),
  ('BG000009',180,40, '2026-06-01 08:00:00'),
  ('BG000010',180,40, '2026-06-01 08:00:00');
 
-- 13. JADWAL RESTOCK
INSERT INTO jadwal_restock (id_barang, id_toko, id_supplier, frekuensi, hari_restock, jumlah_order, is_aktif) VALUES
  ('BE000003','TE001','SP0002','harian',  NULL,          200,'Ya'),
  ('BE000003','TE002','SP0002','harian',  NULL,          150,'Ya'),
  ('BE000009','TE001','SP0004','harian',  NULL,           30,'Ya'),
  ('BE000001','TE001','SP0001','mingguan','Senin,Kamis',  50,'Ya'),
  ('BE000002','TE002','SP0001','mingguan','Senin,Kamis',  40,'Ya'),
  ('BE000006','TE001','SP0003','mingguan','Selasa,Jumat', 60,'Ya'),
  ('BE000008','TE002','SP0003','mingguan','Selasa,Jumat', 50,'Ya'),
  ('BG000003','TR001','SR0002','harian',  'Setiap hari',  30,'Ya'),
  ('BG000002','TR001','SR0001','mingguan','Senin, Kamis', 40,'Ya'),
  ('BG000005','TR001','SR0003','mingguan','Senin, Rabu, Jumat',20,'Ya'),
  ('BG000007','TR002','SR0004','mingguan','Selasa, Jumat',30,'Ya');
 
-- 14. HUTANG SUPPLIER (rekap konsolidasi)
INSERT INTO hutang_supplier (id_supplier, id_toko, jumlah, tgl_hutang, tgl_jatuh_tempo, status_hutang, tgl_lunas, keterangan) VALUES
  ('SP0001','TE001',1150000,'2026-06-01','2026-07-01','belum_lunas',NULL,       'Restock rokok bulanan'),
  ('SP0003','TE002', 780000,'2026-06-02','2026-06-16','belum_lunas',NULL,       'Restock snack & mie'),
  ('SP0002','TE001', 600000,'2026-05-20','2026-06-03','lunas',      '2026-06-01','Restock minuman, sudah dibayar'),
  ('SP0004','TE001', 210000,'2026-06-05','2026-06-12','sebagian',   NULL,       'Sudah dibayar separuh, sisa menyusul'),
  ('SR0001','TR001',5800000,'2026-06-01','2026-07-01','belum_lunas',NULL,       'Pembelian beras & minyak batch Juni'),
  ('SR0004','TR002',2000000,'2026-06-03','2026-06-17','sebagian',   '2026-06-10','Pembayaran sebagian dairy');
 
-- 15. DISTRIBUSI BARANG
-- diterima_oleh diisi staff DC (Staff Packing) yang menangani sisi
-- pengiriman dari gudang. Konfirmasi penerimaan fisik oleh pegawai
-- toko dicatat di tabel stok_toko/transaksi_beli pada database
-- toko masing-masing.
INSERT INTO distribusi_barang (id_toko, tgl_kirim, tgl_terima, status_dist, diterima_oleh, catatan) VALUES
  ('TE001','2026-05-28','2026-05-28','diterima','PD0004','Pengiriman rutin mingguan, dikemas oleh staff packing'),
  ('TE002','2026-05-28','2026-05-28','diterima','PD0004','Pengiriman rutin mingguan'),
  ('TR001','2026-05-28','2026-05-28','diterima','PD0004','Termasuk frozen food'),
  ('TR002','2026-05-28','2026-05-28','diterima','PD0004','Pengiriman rutin mingguan');
 
INSERT INTO detail_distribusi (id_distribusi, id_barang, jumlah_kirim, jumlah_terima) VALUES
  (1,'BE000001',100,100),(1,'BE000003',200,200),(1,'BE000006',100,100),
  (2,'BE000001', 80, 80),(2,'BE000003',150,150),(2,'BE000006', 80, 80),
  (3,'BG000001', 50, 50),(3,'BG000005', 30, 30),(3,'BG000003', 30, 30),
  (4,'BG000007', 40, 40),(4,'BG000009', 25, 25);
 
-- 16. REKAP STOK TOKO
INSERT INTO rekap_stok_toko (id_toko, id_barang, jumlah_stok, stok_minimal, tgl_sync) VALUES
  ('TE001','BE000001', 80, 20,'2026-06-02 08:00:00'),
  ('TE001','BE000002', 60, 15,'2026-06-02 08:00:00'),
  ('TE001','BE000003',120, 30,'2026-06-02 08:00:00'),
  ('TE001','BE000004', 70, 20,'2026-06-02 08:00:00'),
  ('TE001','BE000005', 40, 10,'2026-06-02 08:00:00'),
  ('TE001','BE000006', 50, 10,'2026-06-02 08:00:00'),
  ('TE001','BE000007', 35, 10,'2026-06-02 08:00:00'),
  ('TE001','BE000008', 90, 20,'2026-06-02 08:00:00'),
  ('TE001','BE000009',  8, 10,'2026-06-02 08:00:00'),
  ('TE002','BE000001', 70, 20,'2026-06-02 08:00:00'),
  ('TE002','BE000003',100, 30,'2026-06-02 08:00:00'),
  ('TE002','BE000004', 55, 15,'2026-06-02 08:00:00'),
  ('TE002','BE000006', 45, 10,'2026-06-02 08:00:00'),
  ('TE002','BE000007', 28, 10,'2026-06-02 08:00:00'),
  ('TE002','BE000008', 65, 20,'2026-06-02 08:00:00'),
  ('TR001','BG000001',100, 30,'2026-06-15 08:00:00'),
  ('TR001','BG000002', 12, 25,'2026-06-15 08:00:00'),
  ('TR001','BG000003',  8, 15,'2026-06-15 08:00:00'),
  ('TR001','BG000005',  6, 10,'2026-06-15 08:00:00'),
  ('TR002','BG000007', 40, 20,'2026-06-15 08:00:00'),
  ('TR002','BG000009', 55, 20,'2026-06-15 08:00:00');