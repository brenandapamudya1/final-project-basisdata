# ============================================================
#  helpers.R — Fungsi Utilitas Umum
# ============================================================

library(scales)

# ── Format angka rupiah ──────────────────────────────────────
fmt_rupiah <- function(x) {
  paste0("Rp ", format(round(x, 0), big.mark = ".", scientific = FALSE))
}

# ── Format angka biasa dengan titik ribuan ───────────────────
fmt_num <- function(x) {
  format(round(x, 0), big.mark = ".", scientific = FALSE)
}

# ── Badge HTML status hutang ─────────────────────────────────
badge_hutang <- function(status) {
  color <- switch(status,
    "belum_lunas" = "danger",
    "sebagian"    = "warning",
    "lunas"       = "success",
    "secondary"
  )
  label <- switch(status,
    "belum_lunas" = "Belum Lunas",
    "sebagian"    = "Sebagian",
    "lunas"       = "Lunas",
    status
  )
  sprintf('<span class="badge badge-%s">%s</span>', color, label)
}

# ── Badge HTML status harga ──────────────────────────────────
badge_harga <- function(status) {
  color <- switch(status,
    "pending"  = "warning",
    "approved" = "success",
    "rejected" = "danger",
    "secondary"
  )
  sprintf('<span class="badge badge-%s">%s</span>', color, toupper(status))
}

# ── Badge HTML status absensi ────────────────────────────────
badge_absensi <- function(status) {
  color <- switch(status,
    "hadir" = "success",
    "izin"  = "info",
    "sakit" = "warning",
    "alpha" = "danger",
    "secondary"
  )
  sprintf('<span class="badge badge-%s">%s</span>', color, toupper(status))
}

# ── Badge stok kritis ────────────────────────────────────────
badge_stok <- function(jumlah, minimal) {
  if (jumlah <= 0) {
    '<span class="badge badge-danger">HABIS</span>'
  } else if (jumlah <= minimal) {
    '<span class="badge badge-warning">KRITIS</span>'
  } else {
    '<span class="badge badge-success">OK</span>'
  }
}

# ── Sisa hari promo ──────────────────────────────────────────
sisa_hari_promo <- function(tgl_selesai) {
  if (is.na(tgl_selesai)) return("-")
  sisa <- as.numeric(as.Date(tgl_selesai) - Sys.Date())
  if (is.na(sisa)) return("-")
  if (sisa < 0) return("Sudah berakhir")
  if (sisa == 0) return("Berakhir hari ini")
  paste0(sisa, " hari lagi")
}

# ── Warna tema per role ──────────────────────────────────────
role_color <- function(role) {
  switch(role,
    "gudang"  = "#6366F1",
    "express" = "#F59E0B",
    "reguler" = "#10B981",
    "#6c757d"
  )
}

role_label <- function(role) {
  switch(role,
    "gudang"  = "Admin Gudang",
    "express" = "Admin Express",
    "reguler" = "Admin Reguler",
    "Unknown"
  )
}
