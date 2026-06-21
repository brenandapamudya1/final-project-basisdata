# Semua Query SQL untuk Database GUDANG

# Ringkasan Stok DC
q_gudang_stok_summary <- function() {
  query_db(get_con_gudang, "
    SELECT
      COUNT(*)        AS total_jenis_barang,
      SUM(jumlah)     AS total_unit,
      SUM(CASE WHEN jumlah <= stok_minimal THEN 1 ELSE 0 END) AS barang_kritis
    FROM stok_dc
  ")
}

# Barang kritis di DC
q_gudang_stok_kritis <- function() {
  query_db(get_con_gudang, "
    SELECT
      b.id_barang,
      b.nama_barang,
      k.nama_kategori,
      s.jumlah,
      s.stok_minimal,
      (s.stok_minimal - s.jumlah) AS kekurangan
    FROM stok_dc s
    JOIN barang b ON s.id_barang = b.id_barang
    JOIN kategori_barang k ON b.id_kategori = k.id_kategori
    WHERE s.jumlah <= s.stok_minimal
    ORDER BY kekurangan DESC
  ")
}

# Top 5 barang stok terendah di DC
q_gudang_top5_stok_rendah <- function() {
  query_db(get_con_gudang, "
    SELECT
      b.nama_barang,
      s.jumlah,
      s.stok_minimal
    FROM stok_dc s
    JOIN barang b ON s.id_barang = b.id_barang
    ORDER BY s.jumlah ASC
    LIMIT 5
  ")
}

# Rekap stok semua toko
q_gudang_rekap_stok_toko <- function() {
  query_db(get_con_gudang, "
    SELECT
      r.id_toko,
      t.nama_toko,
      b.nama_barang,
      k.nama_kategori,
      r.jumlah_stok,
      r.stok_minimal,
      r.tgl_sync,
      CASE WHEN r.jumlah_stok <= r.stok_minimal THEN 'Kritis' ELSE 'Normal' END AS status_stok
    FROM rekap_stok_toko r
    JOIN toko t ON r.id_toko = t.id_toko
    JOIN barang b ON r.id_barang = b.id_barang
    JOIN kategori_barang k ON b.id_kategori = k.id_kategori
    ORDER BY r.id_toko, status_stok DESC
  ")
}

# Data untuk bar chart stok per toko
q_gudang_stok_chart <- function() {
  query_db(get_con_gudang, "
    SELECT
      id_toko,
      SUM(jumlah_stok) AS total_stok
    FROM rekap_stok_toko
    GROUP BY id_toko
    ORDER BY id_toko
  ")
}

# Jumlah toko aktif
q_gudang_toko_count <- function() {
  query_db(get_con_gudang, "
    SELECT COUNT(*) AS total FROM toko WHERE status = 'aktif'
  ")
}

# Distribusi terbaru (15 data)
q_gudang_distribusi <- function() {
  query_db(get_con_gudang, "
    SELECT
      d.id_distribusi,
      t.nama_toko,
      d.tgl_kirim,
      d.tgl_terima,
      d.status_dist,
      d.catatan,
      COUNT(dd.id_detail) AS jumlah_item,
      SUM(dd.jumlah_kirim) AS total_unit
    FROM distribusi_barang d
    JOIN toko t ON d.id_toko = t.id_toko
    LEFT JOIN detail_distribusi dd ON d.id_distribusi = dd.id_distribusi
    GROUP BY d.id_distribusi
    ORDER BY d.tgl_kirim DESC
    LIMIT 15
  ")
}

# Distribusi chart: total per toko
q_gudang_distribusi_chart <- function() {
  query_db(get_con_gudang, "
    SELECT
      t.nama_toko,
      COUNT(d.id_distribusi) AS jumlah_pengiriman,
      COALESCE(SUM(dd.jumlah_kirim), 0) AS total_unit_kirim
    FROM distribusi_barang d
    JOIN toko t ON d.id_toko = t.id_toko
    LEFT JOIN detail_distribusi dd ON d.id_distribusi = dd.id_distribusi
    GROUP BY t.nama_toko
  ")
}

# Harga pending approval
q_gudang_harga_pending <- function() {
  query_db(get_con_gudang, "
    SELECT
      h.id_harga,
      b.nama_barang,
      t.nama_toko,
      h.harga_beli,
      h.harga_jual,
      h.tgl_berlaku,
      h.status,
      h.catatan
    FROM harga_barang h
    JOIN barang b ON h.id_barang = b.id_barang
    JOIN toko t ON h.id_toko = t.id_toko
    WHERE h.status = 'pending'
    ORDER BY h.tgl_berlaku DESC
  ")
}

# Semua data harga
q_gudang_harga_all <- function() {
  query_db(get_con_gudang, "
    SELECT
      h.id_harga,
      b.nama_barang,
      t.nama_toko,
      h.harga_beli,
      h.harga_jual,
      h.tgl_berlaku,
      h.tgl_berakhir,
      h.status,
      COALESCE(pi.nama, '-') AS diinput_oleh,
      COALESCE(pa.nama, '-') AS disetujui_oleh,
      h.tgl_approval,
      h.catatan
    FROM harga_barang h
    JOIN barang b ON h.id_barang = b.id_barang
    JOIN toko t ON h.id_toko = t.id_toko
    LEFT JOIN pegawai pi ON h.diinput_oleh = pi.id_pegawai
    LEFT JOIN pegawai pa ON h.disetujui_oleh = pa.id_pegawai
    ORDER BY h.status DESC, h.tgl_berlaku DESC
  ")
}

# Hutang supplier konsolidasi
q_gudang_hutang <- function() {
  query_db(get_con_gudang, "
    SELECT
      s.nama        AS nama_supplier,
      t.nama_toko,
      h.jumlah,
      h.tgl_hutang,
      h.tgl_jatuh_tempo,
      h.status_hutang,
      h.tgl_lunas,
      h.keterangan,
      DATEDIFF(h.tgl_jatuh_tempo, CURDATE()) AS sisa_hari
    FROM hutang_supplier h
    JOIN supplier s ON h.id_supplier = s.id_supplier
    JOIN toko t ON h.id_toko = t.id_toko
    ORDER BY h.status_hutang, sisa_hari ASC
  ")
}

# Total hutang belum lunas
q_gudang_hutang_summary <- function() {
  query_db(get_con_gudang, "
    SELECT
      SUM(CASE WHEN status_hutang != 'lunas' THEN jumlah ELSE 0 END) AS total_belum_lunas,
      COUNT(CASE WHEN status_hutang = 'belum_lunas' THEN 1 END)       AS jml_belum_lunas,
      COUNT(CASE WHEN DATEDIFF(tgl_jatuh_tempo, CURDATE()) <= 7 AND status_hutang != 'lunas' THEN 1 END) AS jatuh_tempo_soon
    FROM hutang_supplier
  ")
}

# Absensi staff DC
q_gudang_absensi <- function() {
  query_db(get_con_gudang, "
    SELECT
      p.nama,
      d.nama_divisi,
      a.tanggal,
      a.jam_masuk,
      a.jam_keluar,
      a.status,
      a.keterangan
    FROM absensi a
    JOIN pegawai p ON a.id_pegawai = p.id_pegawai
    LEFT JOIN pegawai_divisi pd ON p.id_pegawai = pd.id_pegawai AND pd.is_primary = 'Ya'
    LEFT JOIN divisi d ON pd.id_divisi = d.id_divisi
    ORDER BY a.tanggal DESC, p.nama
    LIMIT 20
  ")
}

# Summary absensi
q_gudang_absensi_summary <- function() {
  query_db(get_con_gudang, "
    SELECT
      SUM(CASE WHEN status = 'hadir' THEN 1 ELSE 0 END) AS hadir,
      SUM(CASE WHEN status = 'izin'  THEN 1 ELSE 0 END) AS izin,
      SUM(CASE WHEN status = 'sakit' THEN 1 ELSE 0 END) AS sakit,
      SUM(CASE WHEN status = 'alpha' THEN 1 ELSE 0 END) AS alpha
    FROM absensi
    WHERE tanggal = (SELECT MAX(tanggal) FROM absensi)
  ")
}

# Approve / Reject harga
q_gudang_approve_harga <- function(id_harga, new_status) {
  sql <- sprintf("
    UPDATE harga_barang
    SET status = '%s', tgl_approval = NOW()
    WHERE id_harga = %d
  ", new_status, as.integer(id_harga))
  execute_db(get_con_gudang, sql)
}

# DROP DOWN DATA
q_gudang_get_kategori <- function() {
  query_db(get_con_gudang, "SELECT id_kategori, nama_kategori FROM kategori_barang ORDER BY nama_kategori")
}

q_gudang_get_supplier <- function() {
  query_db(get_con_gudang, "SELECT id_supplier, nama FROM supplier ORDER BY nama")
}

# INSERT Barang Baru
q_gudang_insert_barang <- function(id_barang, nama_barang, id_kategori, id_supplier, satuan, berat_gram, tipe_toko) {
  nama_barang <- gsub("'", "''", nama_barang)
  id_barang   <- gsub("'", "''", id_barang)
  
  sql <- sprintf("
    INSERT INTO barang (id_barang, nama_barang, id_kategori, id_supplier, satuan, berat_gram, tipe_toko, is_aktif)
    VALUES ('%s', '%s', '%s', '%s', '%s', %f, '%s', 'Ya')
  ", id_barang, nama_barang, id_kategori, id_supplier, satuan, as.numeric(berat_gram), tipe_toko)
  
  execute_db(get_con_gudang, sql)
}

# Absensi
q_gudang_get_pegawai <- function() {
  query_db(get_con_gudang, "SELECT id_pegawai, nama FROM pegawai ORDER BY nama")
}

q_gudang_insert_absensi <- function(id_pegawai, tgl, jam_masuk, jam_keluar, status, keterangan) {
  keterangan <- gsub("'", "''", keterangan)
  
  # Format jam bisa kosong jika status bukan hadir
  jam_masuk_val <- if (jam_masuk == "") "NULL" else sprintf("'%s'", jam_masuk)
  jam_keluar_val <- if (jam_keluar == "") "NULL" else sprintf("'%s'", jam_keluar)
  
  sql <- sprintf("
    INSERT INTO absensi (id_pegawai, tanggal, jam_masuk, jam_keluar, status, keterangan)
    VALUES ('%s', '%s', %s, %s, '%s', '%s')
  ", id_pegawai, tgl, jam_masuk_val, jam_keluar_val, status, keterangan)
  
  execute_db(get_con_gudang, sql)
}
