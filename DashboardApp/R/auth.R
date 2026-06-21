# ============================================================
#  auth.R — Sistem Login Sederhana (Hardcoded 3 Akun)
# ============================================================

USERS <- list(
  admin_gudang = list(
    password = "gudang123",
    role     = "gudang",
    label    = "Admin Gudang",
    color    = "#6366F1"
  ),
  admin_express = list(
    password = "express123",
    role     = "express",
    label    = "Admin Express",
    color    = "#F59E0B"
  ),
  admin_reguler = list(
    password = "reguler123",
    role     = "reguler",
    label    = "Admin Reguler",
    color    = "#10B981"
  )
)

# Mengembalikan role string jika login valid, NULL jika gagal
check_login <- function(username, password) {
  user <- USERS[[username]]
  if (!is.null(user) && user$password == password) {
    return(user$role)
  }
  return(NULL)
}

# Ambil info user berdasarkan role
get_user_info <- function(role) {
  for (u in USERS) {
    if (u$role == role) return(u)
  }
  return(NULL)
}
