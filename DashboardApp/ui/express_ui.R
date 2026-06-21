# Layout Tab Admin Express (Premium)

express_ui_tabs <- function() {
  bs4TabItems(
    # Tab: Dashboard Overview
    bs4TabItem(tabName = "e_home",

      # Welcome Banner
      div(class = "welcome-banner",
        fluidRow(
          column(8,
            h3(icon("bolt"), " Selamat Datang, Admin Express!"),
            p(icon("calendar-alt"), paste(" ", format(Sys.Date(), "%A, %d %B %Y"),
              " — Toko Express (TE001 & TE002)"))
          ),
          column(4, style = "text-align:right;",
            h3(uiOutput("e_clock_display"), style = "margin:0;opacity:0.9;")
          )
        )
      ),

      # Value Boxes
      fluidRow(
        bs4ValueBox(uiOutput("e_total_trx"),     "Total Transaksi", icon = icon("receipt"),              color = "warning", width = 3),
        bs4ValueBox(uiOutput("e_total_revenue"), "Total Pendapatan", icon = icon("money-bill"),          color = "success", width = 3),
        bs4ValueBox(uiOutput("e_stok_kritis"),   "Barang Kritis",   icon = icon("exclamation-triangle"), color = "danger",  width = 3),
        bs4ValueBox(uiOutput("e_promo_aktif"),   "Promo Aktif",     icon = icon("percent"),              color = "info",    width = 3)
      ),

      # Quick Action Cards
      fluidRow(
        column(6,
          div(class = "quick-action",
            div(class = "quick-action-icon warning", icon("store")),
            div(class = "quick-action-text",
              h6("Transaksi Express Darmo"),
              tags$small("TE001 — Semua waktu")
            ),
            div(class = "quick-action-value", uiOutput("e_qa_trx_darmo"))
          ),
          div(class = "quick-action",
            div(class = "quick-action-icon danger", icon("exclamation-circle")),
            div(class = "quick-action-text",
              h6("Barang Kritis"),
              tags$small("Di bawah stok minimal")
            ),
            div(class = "quick-action-value", uiOutput("e_qa_kritis"))
          )
        ),
        column(6,
          div(class = "quick-action",
            div(class = "quick-action-icon info", icon("store")),
            div(class = "quick-action-text",
              h6("Transaksi Express Gubeng"),
              tags$small("TE002 — Semua waktu")
            ),
            div(class = "quick-action-value", uiOutput("e_qa_trx_gubeng"))
          ),
          div(class = "quick-action",
            div(class = "quick-action-icon success", icon("tags")),
            div(class = "quick-action-text",
              h6("Total Diskon"),
              tags$small("Yang sudah diberikan")
            ),
            div(class = "quick-action-value", style = "font-size:0.95rem;", uiOutput("e_qa_diskon"))
          )
        )
      ),

      br(),

      # Charts Row
      fluidRow(
        bs4Card(title = tagList(icon("chart-pie"), " Metode Pembayaran"), width = 6, status = "warning",
                collapsible = TRUE,
          plotlyOutput("e_chart_metode", height = "300px")
        ),
        bs4Card(title = tagList(icon("trophy"), " Top 5 Produk Terlaris"), width = 6, status = "success",
                collapsible = TRUE,
          plotlyOutput("e_chart_top5", height = "300px")
        )
      )
    ),

    # Tab: Transaksi
    bs4TabItem(tabName = "e_trx",
      fluidRow(
        column(8, h4(class = "section-title", icon("shopping-cart"), " Transaksi Penjualan")),
        column(4, style = "text-align: right;",
          actionButton("btn_add_pos_e", "Transaksi Kasir", class = "btn btn-primary", icon = icon("cash-register"))
        )
      ),
      bs4Card(title = tagList(icon("history"), " 10 Transaksi Terbaru"), width = 12, status = "warning",
        DTOutput("e_tbl_transaksi")
      )
    ),

    # Tab: Stok & Restock
    bs4TabItem(tabName = "e_stok",
      h4(class = "section-title", icon("boxes"), " Stok & Jadwal Restock"),
      bs4Card(title = tagList(icon("exclamation-triangle"), " Barang Kritis"), width = 12,
              status = "danger", collapsible = TRUE,
        DTOutput("e_tbl_stok_kritis")
      ),
      bs4Card(title = tagList(icon("list"), " Semua Stok"), width = 12, status = "warning",
              collapsible = TRUE, collapsed = TRUE,
        DTOutput("e_tbl_stok_all")
      ),
      bs4Card(title = tagList(icon("calendar-alt"), " Jadwal Restock"), width = 12, status = "warning",
              collapsible = TRUE, collapsed = TRUE,
        DTOutput("e_tbl_restock")
      )
    ),

    # Tab: Promo
    bs4TabItem(tabName = "e_promo",
      fluidRow(
        column(8, h4(class = "section-title", icon("percent"), " Promo Toko Express")),
        column(4, style = "text-align: right;",
          actionButton("btn_add_promo_e", "Tambah Promo", class = "btn btn-warning", icon = icon("plus"))
        )
      ),
      bs4Card(title = tagList(icon("tags"), " Daftar Promo"), width = 12, status = "warning",
        DTOutput("e_tbl_promo")
      )
    ),

    # Tab: Hutang
    bs4TabItem(tabName = "e_hutang",
      h4(class = "section-title", icon("file-invoice-dollar"), " Hutang Supplier"),
      bs4Card(title = tagList(icon("list"), " Status Hutang Supplier"), width = 12, status = "warning",
        DTOutput("e_tbl_hutang")
      )
    ),

    # Tab: Absensi
    bs4TabItem(tabName = "e_absensi",
      fluidRow(
        column(8, h4(class = "section-title", icon("user-clock"), " Absensi Pegawai Express")),
        column(4, style = "text-align: right;",
          actionButton("btn_add_absensi_e", "Input Absensi", class = "btn btn-info", icon = icon("calendar-check"))
        )
      ),
      bs4Card(title = tagList(icon("table"), " Data Absensi"), width = 12, status = "warning",
        DTOutput("e_tbl_absensi")
      )
    )
  )
}
