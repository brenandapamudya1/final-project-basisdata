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
    UNIQUE KEY uq_rekap_toko_barang (id_toko, id_barang),
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
    
    -- ============================================================
--  TRIGGERS.sql
--  Berisi semua trigger untuk database EXPRESS dan toko_reguler
--  Jalankan file ini SETELAH Gudang.sql, TokoExpress.sql,
--  dan TokoReguler.sql berhasil dieksekusi.
--
--  File ini IDEMPOTENT — aman dijalankan ulang karena setiap
--  trigger didahului DROP TRIGGER IF EXISTS.
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
DROP TRIGGER IF EXISTS trg_kurangi_stok_setelah_transaksi;
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
DROP TRIGGER IF EXISTS trg_kembalikan_stok_transaksi_batal;
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
DROP TRIGGER IF EXISTS trg_tambah_poin_loyalty;
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
DROP TRIGGER IF EXISTS trg_sync_rekap_stok_ke_gudang;
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
DROP TRIGGER IF EXISTS trg_update_hutang_lunas;
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

-- ------------------------------------------------------------
-- TRIGGER F — Sinkronisasi harga approved ke GUDANG
-- Event   : AFTER UPDATE on harga_barang
-- Kapan   : saat status berubah menjadi 'approved'
-- Dampak  : INSERT baris baru ke GUDANG.harga_barang sebagai
--           rekap pusat. diinput_oleh & disetujui_oleh di-NULL
--           karena tidak ada staff DC yang terlibat (nullable).
-- Catatan : Menghasilkan row baru (bukan UPDATE) karena
--           GUDANG.harga_barang menyimpan riwayat harga historis.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_sync_harga_approved_ke_gudang;
DELIMITER $$
CREATE TRIGGER trg_sync_harga_approved_ke_gudang
AFTER UPDATE ON harga_barang
FOR EACH ROW
BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        INSERT INTO GUDANG.harga_barang
            (id_barang, id_toko, harga_beli, harga_jual,
             tgl_berlaku, tgl_berakhir, status,
             diinput_oleh, disetujui_oleh, tgl_approval, catatan)
        VALUES
            (NEW.id_barang, NEW.id_toko, NEW.harga_beli, NEW.harga_jual,
             NEW.tgl_berlaku, NEW.tgl_berakhir, 'approved',
             NULL,
             NULL,
             NEW.tgl_approval,
             CONCAT('[Sync dari EXPRESS] ', IFNULL(NEW.catatan, '')));
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
DROP TRIGGER IF EXISTS trg_kurangi_stok_setelah_transaksi;
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
DROP TRIGGER IF EXISTS trg_kembalikan_stok_transaksi_batal;
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
DROP TRIGGER IF EXISTS trg_tambah_poin_loyalty;
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
DROP TRIGGER IF EXISTS trg_sync_rekap_stok_ke_gudang;
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
DROP TRIGGER IF EXISTS trg_update_hutang_lunas;
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

-- ------------------------------------------------------------
-- TRIGGER F (reguler) — Sinkronisasi harga approved ke GUDANG
-- Event   : AFTER UPDATE on harga_barang
-- Kapan   : saat status berubah menjadi 'approved'
-- Dampak  : INSERT baris baru ke GUDANG.harga_barang sebagai
--           rekap pusat. diinput_oleh & disetujui_oleh di-NULL
--           karena tidak ada staff DC yang terlibat (nullable).
-- Catatan : Menghasilkan row baru (bukan UPDATE) karena
--           GUDANG.harga_barang menyimpan riwayat harga historis.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_sync_harga_approved_ke_gudang;
DELIMITER $$
CREATE TRIGGER trg_sync_harga_approved_ke_gudang
AFTER UPDATE ON harga_barang
FOR EACH ROW
BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        INSERT INTO GUDANG.harga_barang
            (id_barang, id_toko, harga_beli, harga_jual,
             tgl_berlaku, tgl_berakhir, status,
             diinput_oleh, disetujui_oleh, tgl_approval, catatan)
        VALUES
            (NEW.id_barang, NEW.id_toko, NEW.harga_beli, NEW.harga_jual,
             NEW.tgl_berlaku, NEW.tgl_berakhir, 'approved',
             NULL,
             NULL,
             NEW.tgl_approval,
             CONCAT('[Sync dari toko_reguler] ', IFNULL(NEW.catatan, '')));
    END IF;
END$$
DELIMITER ;

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
    SUM(
        CASE
            WHEN s.id_toko = 'TE001' THEN s.jumlah
            ELSE 0
        END
    ) AS stok_TE001,
    SUM(
        CASE
            WHEN s.id_toko = 'TE002' THEN s.jumlah
            ELSE 0
        END
    ) AS stok_TE002,
    SUM(
        CASE
            WHEN s.id_toko = 'TE001' THEN s.stok_minimal
            ELSE 0
        END
    ) AS minimal_TE001,
    SUM(
        CASE
            WHEN s.id_toko = 'TE002' THEN s.stok_minimal
            ELSE 0
        END
    ) AS minimal_TE002
FROM
    stok_toko s
    JOIN barang b ON s.id_barang = b.id_barang
    JOIN kategori_barang kb ON b.id_kategori = kb.id_kategori
GROUP BY
    b.id_barang,
    b.nama_barang,
    kb.nama_kategori
ORDER BY kb.nama_kategori, b.nama_barang;

-- ------------------------------------------------------------
-- PIVOT 2 — Omzet penjualan per toko per bulan (EXPRESS)
-- Kegunaan: Grafik tren omzet bulanan di dashboard, membandingkan
--           performa gerai TE001 dan TE002 dari waktu ke waktu.
-- ------------------------------------------------------------
USE EXPRESS;

SELECT
    DATE_FORMAT(tgl_transaksi, '%Y-%m') AS bulan,
    SUM(
        CASE
            WHEN id_toko = 'TE001'
            AND status = 'selesai' THEN total_bayar
            ELSE 0
        END
    ) AS omzet_TE001,
    SUM(
        CASE
            WHEN id_toko = 'TE002'
            AND status = 'selesai' THEN total_bayar
            ELSE 0
        END
    ) AS omzet_TE002,
    COUNT(
        CASE
            WHEN id_toko = 'TE001'
            AND status = 'selesai' THEN 1
        END
    ) AS trx_TE001,
    COUNT(
        CASE
            WHEN id_toko = 'TE002'
            AND status = 'selesai' THEN 1
        END
    ) AS trx_TE002
FROM transaksi_penjualan
GROUP BY
    DATE_FORMAT(tgl_transaksi, '%Y-%m')
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
    d.nama_divisi AS divisi_utama,
    SUM(
        CASE
            WHEN a.status = 'hadir' THEN 1
            ELSE 0
        END
    ) AS hadir,
    SUM(
        CASE
            WHEN a.status = 'izin' THEN 1
            ELSE 0
        END
    ) AS izin,
    SUM(
        CASE
            WHEN a.status = 'sakit' THEN 1
            ELSE 0
        END
    ) AS sakit,
    SUM(
        CASE
            WHEN a.status = 'alpha' THEN 1
            ELSE 0
        END
    ) AS alpha,
    COUNT(a.id_absensi) AS total_hari_tercatat
FROM
    pegawai p
    LEFT JOIN absensi a ON p.id_pegawai = a.id_pegawai
    LEFT JOIN pegawai_divisi pd ON p.id_pegawai = pd.id_pegawai
    AND pd.is_primary = 'Ya'
    LEFT JOIN divisi d ON pd.id_divisi = d.id_divisi
GROUP BY
    p.id_pegawai,
    p.nama,
    d.nama_divisi
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
    SUM(
        CASE
            WHEN h.status = 'approved' THEN 1
            ELSE 0
        END
    ) AS approved,
    SUM(
        CASE
            WHEN h.status = 'pending' THEN 1
            ELSE 0
        END
    ) AS pending,
    SUM(
        CASE
            WHEN h.status = 'rejected' THEN 1
            ELSE 0
        END
    ) AS rejected,
    -- Harga jual aktif (approved, berlaku, belum berakhir)
    MAX(
        CASE
            WHEN h.status = 'approved'
            AND (
                h.tgl_berakhir IS NULL
                OR h.tgl_berakhir >= CURDATE()
            ) THEN h.harga_jual
        END
    ) AS harga_jual_aktif
FROM harga_barang h
    JOIN barang b ON h.id_barang = b.id_barang
GROUP BY
    b.id_barang,
    b.nama_barang,
    b.tipe_toko
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
    s.jumlah AS stok_saat_ini,
    s.stok_minimal,
    (s.stok_minimal - s.jumlah) AS kekurangan,
    sp.nama AS nama_supplier,
    sp.no_hp AS kontak_supplier,
    jr.jumlah_order AS qty_restock_biasa
FROM
    stok_toko s
    JOIN barang b ON s.id_barang = b.id_barang
    JOIN kategori_barang kb ON b.id_kategori = kb.id_kategori
    JOIN toko t ON s.id_toko = t.id_toko
    JOIN GUDANG.supplier sp ON b.id_supplier = sp.id_supplier
    LEFT JOIN jadwal_restock jr ON jr.id_barang = s.id_barang
    AND jr.id_toko = s.id_toko
    AND jr.is_aktif = 'Ya'
WHERE
    s.jumlah < s.stok_minimal
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
    COUNT(tp.id_transaksi) AS total_transaksi,
    SUM(tp.total_belanja) AS total_belanja,
    SUM(tp.total_diskon) AS total_diskon,
    SUM(tp.total_bayar) AS total_omzet,
    COUNT(DISTINCT tp.id_customer) AS jumlah_customer_unik
FROM
    transaksi_penjualan tp
    JOIN toko t ON tp.id_toko = t.id_toko
WHERE
    DATE(tp.tgl_transaksi) = CURDATE()
    AND tp.status = 'selesai'
GROUP BY
    tp.id_toko,
    t.nama_toko;

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
    p.nama AS diinput_oleh,
    DATEDIFF(CURDATE(), h.tgl_berlaku) AS hari_menunggu
FROM
    harga_barang h
    JOIN barang b ON h.id_barang = b.id_barang
    JOIN toko t ON h.id_toko = t.id_toko
    JOIN pegawai p ON h.diinput_oleh = p.id_pegawai
WHERE
    h.status = 'pending'
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
    pe.nama AS diterima_oleh,
    COUNT(dd.id_detail) AS jumlah_jenis_barang,
    SUM(dd.jumlah_kirim) AS total_unit_kirim,
    SUM(dd.jumlah_terima) AS total_unit_diterima,
    ROUND(
        SUM(dd.jumlah_terima) / SUM(dd.jumlah_kirim) * 100,
        1
    ) AS persen_diterima,
    DATEDIFF(CURDATE(), d.tgl_kirim) AS hari_sejak_kirim
FROM
    distribusi_barang d
    JOIN toko t ON d.id_toko = t.id_toko
    LEFT JOIN pegawai pe ON d.diterima_oleh = pe.id_pegawai
    JOIN detail_distribusi dd ON d.id_distribusi = dd.id_distribusi
GROUP BY
    d.id_distribusi,
    t.nama_toko,
    d.tgl_kirim,
    d.tgl_terima,
    d.status_dist,
    pe.nama
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
    s.nama AS nama_supplier,
    s.kontak_pic,
    s.no_hp AS hp_supplier,
    t.nama_toko,
    h.jumlah,
    h.tgl_hutang,
    h.tgl_jatuh_tempo,
    DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) AS sisa_hari,
    h.status_hutang,
    h.keterangan,
    CASE
        WHEN DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) < 0 THEN 'LEWAT JATUH TEMPO'
        WHEN DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) <= 3 THEN 'SANGAT MENDESAK'
        WHEN DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) <= 7 THEN 'MENDESAK'
        ELSE 'NORMAL'
    END AS prioritas
FROM
    hutang_supplier h
    JOIN supplier s ON h.id_supplier = s.id_supplier
    JOIN toko t ON h.id_toko = t.id_toko
WHERE
    h.status_hutang != 'lunas'
    AND h.tgl_jatuh_tempo <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY sisa_hari ASC;