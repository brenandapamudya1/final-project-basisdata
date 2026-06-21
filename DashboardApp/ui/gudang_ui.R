# ============================================================
#  gudang_ui.R — Layout Tab Admin Gudang (Premium)
# ============================================================

gudang_ui_tabs <- function() {
  bs4TabItems(
    # ── Tab: Dashboard Overview ────────────────────────────
    bs4TabItem(tabName = "g_home",

      # Welcome Banner
      div(class = "welcome-banner",
        fluidRow(
          column(8,
            h3(icon("warehouse"), " Selamat Datang, Admin Gudang!"),
            p(icon("calendar-alt"), paste(" ", format(Sys.Date(), "%A, %d %B %Y"),
              " — Gudang Pusat (DC001)"))
          ),
          column(4, style = "text-align:right;",
            h3(uiOutput("g_clock_display"), style = "margin:0;opacity:0.9;")
          )
        )
      ),

      # Value Boxes Row 1
      fluidRow(
        bs4ValueBox(uiOutput("g_total_jenis"),  "Jenis Barang",     icon = icon("cubes"),                color = "indigo",  width = 3),
        bs4ValueBox(uiOutput("g_total_unit"),   "Total Unit DC",    icon = icon("boxes"),                color = "purple",  width = 3),
        bs4ValueBox(uiOutput("g_kritis_dc"),    "Barang Kritis",    icon = icon("exclamation-triangle"), color = "danger",  width = 3),
        bs4ValueBox(uiOutput("g_hutang_count"), "Hutang Aktif",     icon = icon("file-invoice-dollar"),  color = "warning", width = 3)
      ),

      # Quick Action Cards
      fluidRow(
        column(4,
          div(class = "quick-action",
            div(class = "quick-action-icon danger", icon("exclamation-circle")),
            div(class = "quick-action-text",
              h6("Barang Kritis DC"),
              tags$small("Perlu restock segera")
            ),
            div(class = "quick-action-value", uiOutput("g_qa_kritis"))
          ),
          div(class = "quick-action",
            div(class = "quick-action-icon warning", icon("calendar-times")),
            div(class = "quick-action-text",
              h6("Hutang Jatuh Tempo"),
              tags$small("Dalam 7 hari ke depan")
            ),
            div(class = "quick-action-value", uiOutput("g_qa_jatuh_tempo"))
          )
        ),
        column(4,
          div(class = "quick-action",
            div(class = "quick-action-icon info", icon("clock")),
            div(class = "quick-action-text",
              h6("Harga Pending"),
              tags$small("Menunggu approval")
            ),
            div(class = "quick-action-value", uiOutput("g_qa_harga_pending"))
          ),
          div(class = "quick-action",
            div(class = "quick-action-icon success", icon("user-check")),
            div(class = "quick-action-text",
              h6("Staff Hadir"),
              tags$small("Hari ini")
            ),
            div(class = "quick-action-value", uiOutput("g_qa_hadir"))
          )
        ),
        column(4,
          div(class = "quick-action",
            div(class = "quick-action-icon indigo", icon("store")),
            div(class = "quick-action-text",
              h6("Total Toko Aktif"),
              tags$small("Cabang terdaftar")
            ),
            div(class = "quick-action-value", uiOutput("g_qa_toko"))
          ),
          div(class = "quick-action",
            div(class = "quick-action-icon warning", icon("money-bill")),
            div(class = "quick-action-text",
              h6("Total Hutang"),
              tags$small("Belum lunas")
            ),
            div(class = "quick-action-value", style = "font-size:1rem;", uiOutput("g_qa_total_hutang"))
          )
        )
      ),

      br(),

      # Charts Row
      fluidRow(
        bs4Card(title = tagList(icon("chart-bar"), " Stok Per Toko"), width = 4, status = "primary",
                collapsible = TRUE,
          plotlyOutput("g_chart_stok_toko", height = "300px")
        ),
        bs4Card(title = tagList(icon("chart-pie"), " Absensi Hari Ini"), width = 4, status = "primary",
                collapsible = TRUE,
          plotlyOutput("g_chart_absensi", height = "300px")
        ),
        bs4Card(title = tagList(icon("sort-amount-down"), " Top 5 Stok Terendah DC"), width = 4, status = "danger",
                collapsible = TRUE,
          plotlyOutput("g_chart_top5_stok", height = "300px")
        )
      )
    ),

    # ── Tab: Stok DC ──────────────────────────────────────
    bs4TabItem(tabName = "g_stok",
      fluidRow(
        column(8, h4(class = "section-title", icon("boxes"), " Stok Gudang Pusat (DC)")),
        column(4, style = "text-align: right;",
          actionButton("btn_add_barang", "Tambah Master Barang", class = "btn btn-primary", icon = icon("plus"))
        )
      ),
      bs4Card(title = tagList(icon("exclamation-triangle"), " Barang di Bawah Stok Minimal"),
              width = 12, status = "danger", collapsible = TRUE,
        DTOutput("g_tbl_stok_kritis")
      )
    ),

    # ── Tab: Rekap Stok Toko ──────────────────────────────
    bs4TabItem(tabName = "g_rekap",
      h4(class = "section-title", icon("store"), " Rekap Stok Semua Toko"),
      bs4Card(title = tagList(icon("sync-alt"), " Rekap Stok Toko (Real-time Sync)"),
              width = 12, status = "primary",
        DTOutput("g_tbl_rekap_stok")
      )
    ),

    # ── Tab: Distribusi ───────────────────────────────────
    bs4TabItem(tabName = "g_distribusi",
      h4(class = "section-title", icon("truck"), " Distribusi Barang DC → Toko"),
      fluidRow(
        bs4Card(title = tagList(icon("chart-bar"), " Distribusi per Toko"), width = 5, status = "primary",
                collapsible = TRUE,
          plotlyOutput("g_chart_distribusi", height = "280px")
        ),
        bs4Card(title = tagList(icon("history"), " Riwayat Distribusi"), width = 7, status = "primary",
          DTOutput("g_tbl_distribusi")
        )
      )
    ),

    # ── Tab: Harga & Approval ─────────────────────────────
    bs4TabItem(tabName = "g_harga",
      h4(class = "section-title", icon("tags"), " Manajemen Harga & Approval"),
      bs4Card(title = tagList(icon("clock"), " Harga Menunggu Approval"), width = 12,
              status = "warning", collapsible = TRUE,
        DTOutput("g_tbl_harga_pending"),
        br(),
        fluidRow(
          column(4, selectInput("g_sel_harga_id", "Pilih ID Harga:", choices = NULL)),
          column(3, selectInput("g_sel_action",   "Aksi:",
            choices = c("Approve" = "approved", "Reject" = "rejected"))),
          column(3, br(), actionButton("g_btn_approve", "Eksekusi",
            class = "btn btn-warning", icon = icon("check")))
        ),
        uiOutput("g_approval_result")
      ),
      bs4Card(title = tagList(icon("list-alt"), " Semua Riwayat Harga"), width = 12, status = "primary",
              collapsible = TRUE, collapsed = TRUE,
        DTOutput("g_tbl_harga_all")
      )
    ),

    # ── Tab: Hutang Supplier ──────────────────────────────
    bs4TabItem(tabName = "g_hutang",
      h4(class = "section-title", icon("file-invoice-dollar"), " Hutang Supplier Konsolidasi"),
      bs4Card(title = tagList(icon("list"), " Semua Hutang Supplier"), width = 12, status = "primary",
        DTOutput("g_tbl_hutang")
      )
    ),

    # ── Tab: Absensi ──────────────────────────────────────
    bs4TabItem(tabName = "g_absensi",
      fluidRow(
        column(8, h4(class = "section-title", icon("user-clock"), " Absensi Staff DC")),
        column(4, style = "text-align: right;",
          actionButton("btn_add_absensi_g", "Input Absensi", class = "btn btn-info", icon = icon("calendar-check"))
        )
      ),
      bs4Card(title = tagList(icon("table"), " Data Absensi"), width = 12, status = "primary",
        DTOutput("g_tbl_absensi")
      )
    )
  )
}
