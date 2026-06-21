# Query SQL untuk Database toko_reguler

q_reguler_penjualan_summary <- function() {
  query_db(get_con_reguler, "
    SELECT
      COUNT(*)                                                    AS total_transaksi,
      COALESCE(SUM(total_bayar), 0)                              AS total_pendapatan,
      COALESCE(SUM(total_diskon), 0)                             AS total_diskon,
      SUM(CASE WHEN id_toko = 'TR001' THEN 1 ELSE 0 END)        AS trx_rungkut,
      SUM(CASE WHEN id_toko = 'TR002' THEN 1 ELSE 0 END)        AS trx_dukuh
    FROM transaksi_penjualan
    WHERE status = 'selesai'
  ")
}

q_reguler_penjualan_chart <- function() {
  query_db(get_con_reguler, "
    SELECT
      t.nama_toko,
      COUNT(tp.id_transaksi) AS jumlah_transaksi,
      SUM(tp.total_bayar)    AS total_pendapatan
    FROM transaksi_penjualan tp
    JOIN toko t ON tp.id_toko = t.id_toko
    WHERE status = 'selesai'
    GROUP BY tp.id_toko, t.nama_toko
  ")
}

# Top 5 produk terlaris
q_reguler_top5_produk <- function() {
  query_db(get_con_reguler, "
    SELECT
      b.nama_barang,
      SUM(dt.jumlah) AS total_terjual,
      SUM(dt.subtotal) AS total_revenue
    FROM detail_transaksi dt
    JOIN barang b ON dt.id_barang = b.id_barang
    JOIN transaksi_penjualan tp ON dt.id_transaksi = tp.id_transaksi
    WHERE tp.status = 'selesai'
    GROUP BY b.id_barang, b.nama_barang
    ORDER BY total_terjual DESC
    LIMIT 5
  ")
}

q_reguler_stok_per_section <- function() {
  query_db(get_con_reguler, "
    SELECT
      t.nama_toko,
      k.nama_kategori AS section,
      SUM(s.jumlah)   AS total_stok,
      SUM(CASE WHEN s.jumlah <= s.stok_minimal THEN 1 ELSE 0 END) AS barang_kritis
    FROM stok_toko s
    JOIN barang b ON s.id_barang = b.id_barang
    JOIN kategori_barang k ON b.id_kategori = k.id_kategori
    JOIN toko t ON s.id_toko = t.id_toko
    GROUP BY t.id_toko, k.id_kategori
    ORDER BY t.id_toko, k.nama_kategori
  ")
}

q_reguler_stok_kritis <- function() {
  query_db(get_con_reguler, "
    SELECT
      t.nama_toko,
      b.nama_barang,
      k.nama_kategori,
      s.jumlah,
      s.stok_minimal,
      (s.stok_minimal - s.jumlah) AS kekurangan
    FROM stok_toko s
    JOIN barang b ON s.id_barang = b.id_barang
    JOIN kategori_barang k ON b.id_kategori = k.id_kategori
    JOIN toko t ON s.id_toko = t.id_toko
    WHERE s.jumlah <= s.stok_minimal
    ORDER BY kekurangan DESC
  ")
}

q_reguler_transaksi_terbaru <- function() {
  query_db(get_con_reguler, "
    SELECT
      tp.id_transaksi,
      t.nama_toko,
      COALESCE(c.nama, 'Walk-in') AS nama_customer,
      p.nama                      AS kasir,
      tp.tgl_transaksi,
      tp.total_belanja,
      tp.total_diskon,
      tp.total_bayar,
      tp.status
    FROM transaksi_penjualan tp
    JOIN toko t ON tp.id_toko = t.id_toko
    LEFT JOIN customer c ON tp.id_customer = c.id_customer
    JOIN pegawai p ON tp.id_pegawai = p.id_pegawai
    ORDER BY tp.tgl_transaksi DESC
    LIMIT 10
  ")
}

q_reguler_loyalty_top <- function() {
  query_db(get_con_reguler, "
    SELECT
      nama,
      no_hp,
      email,
      tgl_daftar,
      poin_loyalty
    FROM customer
    ORDER BY poin_loyalty DESC
    LIMIT 10
  ")
}

q_reguler_promo <- function() {
  query_db(get_con_reguler, "
    SELECT
      pr.id_promo,
      pr.nama_promo,
      b.nama_barang,
      pr.jenis_diskon,
      pr.nilai_diskon,
      pr.tgl_mulai,
      pr.tgl_selesai,
      pr.is_aktif,
      DATEDIFF(pr.tgl_selesai, CURDATE()) AS sisa_hari
    FROM promo pr
    JOIN barang b ON pr.id_barang = b.id_barang
    ORDER BY pr.is_aktif DESC, pr.tgl_selesai ASC
  ")
}

q_reguler_hutang <- function() {
  query_db(get_con_reguler, "
    SELECT
      GUDANG.supplier.nama AS nama_supplier,
      t.nama_toko,
      h.jumlah,
      h.tgl_hutang,
      h.tgl_jatuh_tempo,
      h.status_hutang,
      h.tgl_lunas,
      h.keterangan,
      DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) AS sisa_hari
    FROM hutang_supplier h
    JOIN GUDANG.supplier ON h.id_supplier = GUDANG.supplier.id_supplier
    JOIN toko t ON h.id_toko = t.id_toko
    ORDER BY h.status_hutang, sisa_hari ASC
  ")
}

q_reguler_absensi <- function() {
  query_db(get_con_reguler, "
    SELECT
      p.nama,
      t.nama_toko,
      COALESCE(p.section, '-') AS section,
      d.nama_divisi,
      a.tanggal,
      a.jam_masuk,
      a.jam_keluar,
      a.status,
      a.keterangan
    FROM absensi a
    JOIN pegawai p ON a.id_pegawai = p.id_pegawai
    JOIN toko t ON p.id_toko = t.id_toko
    LEFT JOIN pegawai_divisi pd ON p.id_pegawai = pd.id_pegawai AND pd.is_primary = 'Ya'
    LEFT JOIN divisi d ON pd.id_divisi = d.id_divisi
    ORDER BY a.tanggal DESC, t.id_toko, p.nama
    LIMIT 20
  ")
}

q_reguler_absensi_summary <- function() {
  query_db(get_con_reguler, "
    SELECT
      SUM(CASE WHEN status = 'hadir' THEN 1 ELSE 0 END) AS hadir,
      SUM(CASE WHEN status = 'izin'  THEN 1 ELSE 0 END) AS izin,
      SUM(CASE WHEN status = 'sakit' THEN 1 ELSE 0 END) AS sakit,
      SUM(CASE WHEN status = 'alpha' THEN 1 ELSE 0 END) AS alpha
    FROM absensi
    WHERE tanggal = (SELECT MAX(tanggal) FROM absensi)
  ")
}

# INSERT Registrasi Customer
q_reguler_insert_customer <- function(id_cust, nama, no_hp, email) {
  # Sanitasi sederhana: escape quotes
  nama  <- gsub("'", "''", nama)
  email <- gsub("'", "''", email)
  no_hp <- gsub("'", "''", no_hp)
  id_cust <- gsub("'", "''", id_cust)
  
  sql <- sprintf("
    INSERT INTO customer (id_customer, nama, no_hp, email, tgl_daftar, poin_loyalty)
    VALUES ('%s', '%s', '%s', '%s', CURDATE(), 0)
  ", id_cust, nama, no_hp, email)
  
  execute_db(get_con_reguler, sql)
}

# Absensi
q_reguler_get_pegawai <- function() {
  query_db(get_con_reguler, "SELECT id_pegawai, nama FROM pegawai ORDER BY nama")
}

q_reguler_insert_absensi <- function(id_pegawai, tgl, jam_masuk, jam_keluar, status, keterangan) {
  keterangan <- gsub("'", "''", keterangan)
  jam_masuk_val <- if (jam_masuk == "") "NULL" else sprintf("'%s'", jam_masuk)
  jam_keluar_val <- if (jam_keluar == "") "NULL" else sprintf("'%s'", jam_keluar)
  
  sql <- sprintf("
    INSERT INTO absensi (id_pegawai, tanggal, jam_masuk, jam_keluar, status, keterangan)
    VALUES ('%s', '%s', %s, %s, '%s', '%s')
  ", id_pegawai, tgl, jam_masuk_val, jam_keluar_val, status, keterangan)
  
  execute_db(get_con_reguler, sql)
}

# Transaksi POS Sederhana
q_reguler_get_customer <- function() {
  query_db(get_con_reguler, "SELECT id_customer, nama FROM customer ORDER BY nama")
}

q_reguler_get_metode_bayar <- function() {
  query_db(get_con_reguler, "SELECT id_metode, nama_metode FROM metode_pembayaran ORDER BY nama_metode")
}

q_reguler_get_barang_pos <- function() {
  query_db(get_con_reguler, "
    SELECT DISTINCT b.id_barang, b.nama_barang
    FROM barang b
    JOIN stok_toko s ON b.id_barang = s.id_barang
    ORDER BY b.nama_barang
  ")
}

q_reguler_insert_transaksi_simple <- function(id_toko, id_pegawai, id_customer, id_barang, jumlah, id_metode) {
  con <- get_con_reguler()
  on.exit(dbDisconnect(con))
  
  sql_harga <- sprintf("
    SELECT harga_jual FROM harga_barang 
    WHERE id_barang = '%s' AND id_toko = '%s' AND status = 'approved' 
    ORDER BY tgl_berlaku DESC LIMIT 1
  ", id_barang, id_toko)
  
  res_harga <- tryCatch(dbGetQuery(con, sql_harga), error = function(e) NULL)
  
  if (is.null(res_harga) || nrow(res_harga) == 0) {
    stop("Harga barang tidak ditemukan atau belum di-approve untuk toko ini.")
  }
  
  harga_satuan <- as.numeric(res_harga$harga_jual[1])
  subtotal <- harga_satuan * as.integer(jumlah)
  
  tryCatch({
    dbBegin(con)
    
    # 1. Insert Header
    cust_val <- if (id_customer == "") "NULL" else sprintf("'%s'", id_customer)
    
    sql_header <- sprintf("
      INSERT INTO transaksi_penjualan (id_toko, id_customer, id_pegawai, tgl_transaksi, total_belanja, total_diskon, total_bayar, status)
      VALUES ('%s', %s, '%s', NOW(), %f, 0, %f, 'selesai')
    ", id_toko, cust_val, id_pegawai, subtotal, subtotal)
    dbExecute(con, sql_header)
    
    # 2. Ambil ID
    res_id <- dbGetQuery(con, "SELECT LAST_INSERT_ID() AS id")
    new_id <- res_id$id[1]
    
    # 3. Insert Detail
    sql_detail <- sprintf("
      INSERT INTO detail_transaksi (id_transaksi, id_barang, id_promo, jumlah, harga_satuan, diskon, subtotal)
      VALUES (%s, '%s', NULL, %d, %f, 0, %f)
    ", new_id, id_barang, as.integer(jumlah), harga_satuan, subtotal)
    dbExecute(con, sql_detail)
    
    # 4. Insert Pembayaran
    sql_bayar <- sprintf("
      INSERT INTO pembayaran (id_transaksi, id_metode, jumlah_bayar, tgl_bayar)
      VALUES (%s, '%s', %f, NOW())
    ", new_id, id_metode, subtotal)
    dbExecute(con, sql_bayar)
    
    dbCommit(con)
    return(TRUE)
  }, error = function(e) {
    dbRollback(con)
    stop("Transaksi gagal: ", e$message)
  })
}
