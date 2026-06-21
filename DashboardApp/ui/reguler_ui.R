# ============================================================
#  reguler_ui.R — Layout Tab Admin Reguler (Premium)
# ============================================================

reguler_ui_tabs <- function() {
  bs4TabItems(
    # ── Tab: Dashboard Overview ────────────────────────────
    bs4TabItem(tabName = "r_home",

      # Welcome Banner
      div(class = "welcome-banner",
        fluidRow(
          column(8,
            h3(icon("shopping-basket"), " Selamat Datang, Admin Reguler!"),
            p(icon("calendar-alt"), paste(" ", format(Sys.Date(), "%A, %d %B %Y"),
              " — Swalayan Sentosa (TR001 & TR002)"))
          ),
          column(4, style = "text-align:right;",
            h3(uiOutput("r_clock_display"), style = "margin:0;opacity:0.9;")
          )
        )
      ),

      # Value Boxes
      fluidRow(
        bs4ValueBox(uiOutput("r_total_trx"),      "Total Transaksi", icon = icon("receipt"),              color = "success", width = 3),
        bs4ValueBox(uiOutput("r_total_revenue"),  "Total Pendapatan", icon = icon("money-bill"),          color = "teal",    width = 3),
        bs4ValueBox(uiOutput("r_stok_kritis"),    "Barang Kritis",   icon = icon("exclamation-triangle"), color = "danger",  width = 3),
        bs4ValueBox(uiOutput("r_customer_total"), "Total Customer",  icon = icon("users"),                color = "info",    width = 3)
      ),

      # Quick Action Cards
      fluidRow(
        column(6,
          div(class = "quick-action",
            div(class = "quick-action-icon success", icon("store")),
            div(class = "quick-action-text",
              h6("Transaksi Sentosa Rungkut"),
              tags$small("TR001 — Semua waktu")
            ),
            div(class = "quick-action-value", uiOutput("r_qa_trx_rungkut"))
          ),
          div(class = "quick-action",
            div(class = "quick-action-icon danger", icon("exclamation-circle")),
            div(class = "quick-action-text",
              h6("Barang Kritis"),
              tags$small("Di bawah stok minimal")
            ),
            div(class = "quick-action-value", uiOutput("r_qa_kritis"))
          )
        ),
        column(6,
          div(class = "quick-action",
            div(class = "quick-action-icon info", icon("store")),
            div(class = "quick-action-text",
              h6("Transaksi Sentosa Dukuh Kupang"),
              tags$small("TR002 — Semua waktu")
            ),
            div(class = "quick-action-value", uiOutput("r_qa_trx_dukuh"))
          ),
          div(class = "quick-action",
            div(class = "quick-action-icon warning", icon("crown")),
            div(class = "quick-action-text",
              h6("Top Loyalty Customer"),
              tags$small("Poin tertinggi")
            ),
            div(class = "quick-action-value", uiOutput("r_qa_top_poin"))
          )
        )
      ),

      br(),

      # Charts Row
      fluidRow(
        bs4Card(title = tagList(icon("layer-group"), " Stok per Section"), width = 6, status = "success",
                collapsible = TRUE,
          plotlyOutput("r_chart_section", height = "300px")
        ),
        bs4Card(title = tagList(icon("trophy"), " Top 5 Produk Terlaris"), width = 6, status = "teal",
                collapsible = TRUE,
          plotlyOutput("r_chart_top5", height = "300px")
        )
      )
    ),

    # ── Tab: Transaksi ────────────────────────────────────
    bs4TabItem(tabName = "r_trx",
      fluidRow(
        column(8, h4(class = "section-title", icon("shopping-cart"), " Transaksi Penjualan")),
        column(4, style = "text-align: right;",
          actionButton("btn_add_pos_r", "Transaksi Kasir", class = "btn btn-teal", icon = icon("cash-register"))
        )
      ),
      bs4Card(title = tagList(icon("history"), " 10 Transaksi Terbaru"), width = 12, status = "success",
        DTOutput("r_tbl_transaksi")
      )
    ),

    # ── Tab: Stok per Section ─────────────────────────────
    bs4TabItem(tabName = "r_stok",
      h4(class = "section-title", icon("layer-group"), " Stok per Section"),
      bs4Card(title = tagList(icon("th-list"), " Ringkasan Stok per Section & Toko"), width = 12, status = "success",
        DTOutput("r_tbl_stok_section")
      ),
      bs4Card(title = tagList(icon("exclamation-triangle"), " Barang Kritis"), width = 12, status = "danger",
              collapsible = TRUE,
        DTOutput("r_tbl_stok_kritis")
      )
    ),

    # ── Tab: Customer & Loyalty ───────────────────────────
    bs4TabItem(tabName = "r_cust",
      fluidRow(
        column(8, h4(class = "section-title", icon("crown"), " Customer & Program Loyalty")),
        column(4, style = "text-align: right;",
          actionButton("btn_add_cust_r", "Registrasi Customer", class = "btn btn-info", icon = icon("user-plus"))
        )
      ),
      bs4Card(title = tagList(icon("medal"), " Top Customer by Poin Loyalty"), width = 12, status = "success",
        DTOutput("r_tbl_loyalty")
      )
    ),

    # ── Tab: Promo ────────────────────────────────────────
    bs4TabItem(tabName = "r_promo",
      h4(class = "section-title", icon("percent"), " Promo Toko Reguler"),
      bs4Card(title = tagList(icon("tags"), " Daftar Promo"), width = 12, status = "success",
        DTOutput("r_tbl_promo")
      )
    ),

    # ── Tab: Hutang ───────────────────────────────────────
    bs4TabItem(tabName = "r_hutang",
      h4(class = "section-title", icon("file-invoice-dollar"), " Hutang Supplier"),
      bs4Card(title = tagList(icon("list"), " Status Hutang Supplier"), width = 12, status = "success",
        DTOutput("r_tbl_hutang")
      )
    ),

    # ── Tab: Absensi ──────────────────────────────────────
    bs4TabItem(tabName = "r_absensi",
      fluidRow(
        column(8, h4(class = "section-title", icon("user-clock"), " Absensi Pegawai Reguler")),
        column(4, style = "text-align: right;",
          actionButton("btn_add_absensi_r", "Input Absensi", class = "btn btn-info", icon = icon("calendar-check"))
        )
      ),
      bs4Card(title = tagList(icon("table"), " Data Absensi"), width = 12, status = "success",
        DTOutput("r_tbl_absensi")
      )
    )
  )
}
