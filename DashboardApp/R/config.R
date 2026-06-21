# ============================================================
#  config.R — Koneksi ke 3 Database MySQL
#  Host diambil dari environment variable (Docker) atau
#  fallback ke "localhost" untuk development lokal.
# ============================================================

library(DBI)
library(RMariaDB)

DB_HOST <- Sys.getenv("DB_HOST", unset = "localhost")
DB_PORT <- as.integer(Sys.getenv("DB_PORT", unset = "3306"))
DB_PASS <- Sys.getenv("DB_PASSWORD", unset = "Brenanda17")
DB_USER <- "root"

# ── Fungsi koneksi (buat koneksi baru tiap dipanggil) ────────
get_con_gudang <- function() {
  dbConnect(
    RMariaDB::MariaDB(),
    host     = DB_HOST,
    port     = DB_PORT,
    dbname   = "GUDANG",
    user     = DB_USER,
    password = DB_PASS
  )
}

get_con_express <- function() {
  dbConnect(
    RMariaDB::MariaDB(),
    host     = DB_HOST,
    port     = DB_PORT,
    dbname   = "EXPRESS",
    user     = DB_USER,
    password = DB_PASS
  )
}

get_con_reguler <- function() {
  dbConnect(
    RMariaDB::MariaDB(),
    host     = DB_HOST,
    port     = DB_PORT,
    dbname   = "toko_reguler",
    user     = DB_USER,
    password = DB_PASS
  )
}

# ── Helper: jalankan query & auto-disconnect ─────────────────
query_db <- function(con_fn, sql, ...) {
  con <- con_fn()
  on.exit(dbDisconnect(con))
  tryCatch(
    dbGetQuery(con, sql, ...),
    error = function(e) {
      message("DB Error: ", e$message)
      data.frame()
    }
  )
}

execute_db <- function(con_fn, sql) {
  con <- con_fn()
  on.exit(dbDisconnect(con))
  tryCatch(
    dbExecute(con, sql),
    error = function(e) {
      message("DB Execute Error: ", e$message)
      -1L
    }
  )
}
