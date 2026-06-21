# Server Logic untuk Admin Reguler (Premium)

reguler_server <- function(input, output, session) {

  rv_customer <- reactiveVal(0)
  rv_absensi <- reactiveVal(0)
  rv_trx <- reactiveVal(0)

  penjualan <- reactive({ rv_trx(); q_reguler_penjualan_summary() })

  output$r_clock_display <- renderUI({
    invalidateLater(60000, session); span(format(Sys.time(), "%H:%M WIB"))
  })

  # Value Boxes
  output$r_total_trx <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("0")); span(fmt_num(d$total_transaksi)) })
  output$r_total_revenue <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("Rp 0")); span(fmt_rupiah(d$total_pendapatan)) })
  output$r_stok_kritis <- renderUI({ span(nrow(q_reguler_stok_kritis())) })
  output$r_customer_total <- renderUI({ rv_customer(); span(fmt_num(nrow(q_reguler_loyalty_top()))) })

  # Quick Actions
  output$r_qa_trx_rungkut <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("0")); span(fmt_num(d$trx_rungkut)) })
  output$r_qa_trx_dukuh   <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("0")); span(fmt_num(d$trx_dukuh)) })
  output$r_qa_kritis      <- renderUI({ rv_trx(); span(nrow(q_reguler_stok_kritis())) })
  output$r_qa_top_poin    <- renderUI({
    rv_trx()
    d <- q_reguler_loyalty_top()
    if (nrow(d) == 0) return(span("0"))
    span(fmt_num(d$poin_loyalty[1]))
  })

  # Chart: Stok per section
  output$r_chart_section <- renderPlotly({
    d <- q_reguler_stok_per_section()
    if (nrow(d) == 0) return(plotly_empty())
    cols <- c("#10B981","#6366F1","#F59E0B","#EF4444","#06B6D4")
    plot_ly(d, x=~section, y=~total_stok, color=~nama_toko, type="bar", colors=cols) %>%
      layout(barmode="group",
             paper_bgcolor="transparent", plot_bgcolor="transparent",
             font=list(color="#374151",family="Inter"),
             xaxis=list(title="Section",tickfont=list(size=10)),
             yaxis=list(title="Total Stok",gridcolor="#f3f4f6"),
             legend=list(font=list(color="#374151",size=11)),
             margin=list(t=10,b=30)) %>% config(displayModeBar = FALSE)
  })

  # Chart: Top 5 produk terlaris
  output$r_chart_top5 <- renderPlotly({
    rv_trx()
    d <- q_reguler_top5_produk()
    if (nrow(d) == 0) return(plotly_empty())
    d <- d[order(d$total_terjual),]
    plot_ly(d, y=~reorder(nama_barang,total_terjual), x=~total_terjual, type="bar", orientation="h",
            marker=list(color="#6366F1"), hoverinfo="text",
            text=~paste0(nama_barang,"<br>Terjual: ",total_terjual," unit")) %>%
      layout(paper_bgcolor="transparent", plot_bgcolor="transparent",
             font=list(color="#374151",family="Inter"),
             xaxis=list(title="Unit Terjual",gridcolor="#f3f4f6"),
             yaxis=list(title="",tickfont=list(size=10)),
             margin=list(l=120,t=10,b=30), showlegend=FALSE) %>% config(displayModeBar = FALSE)
  })

  # Tables
  output$r_tbl_transaksi <- renderDT({
    rv_trx()
    d <- q_reguler_transaksi_terbaru()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Belum ada transaksi")))
    d$total_belanja <- sapply(d$total_belanja, fmt_rupiah)
    d$total_diskon  <- sapply(d$total_diskon,  fmt_rupiah)
    d$total_bayar   <- sapply(d$total_bayar,   fmt_rupiah)
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$r_tbl_stok_section <- renderDT({
    rv_trx()
    d <- q_reguler_stok_per_section()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Data tidak tersedia")))
    datatable(d, escape=FALSE, rownames=FALSE, filter="top", options=list(pageLength=15,scrollX=TRUE))
  })

  output$r_tbl_stok_kritis <- renderDT({
    rv_trx()
    d <- q_reguler_stok_kritis()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Tidak ada barang kritis")))
    d$Status <- mapply(badge_stok, d$jumlah, d$stok_minimal)
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$r_tbl_loyalty <- renderDT({
    rv_customer()
    rv_trx()
    d <- q_reguler_loyalty_top()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Belum ada customer")))
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE),
              colnames=c("Nama","No HP","Email","Tgl Daftar","Poin Loyalty"))
  })

  output$r_tbl_promo <- renderDT({
    d <- q_reguler_promo()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Belum ada promo")))
    d$sisa_hari <- sapply(d$sisa_hari, function(x) { if(is.na(x)) return("-"); sisa_hari_promo(Sys.Date()+x) })
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$r_tbl_hutang <- renderDT({
    d <- q_reguler_hutang()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Data tidak tersedia")))
    d$jumlah <- sapply(d$jumlah, fmt_rupiah)
    d$status_hutang <- sapply(d$status_hutang, badge_hutang)
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$r_tbl_absensi <- renderDT({
    rv_absensi()
    d <- q_reguler_absensi()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Data tidak tersedia")))
    d$status <- sapply(d$status, badge_absensi)
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  # MODAL: Registrasi Customer
  observeEvent(input$btn_add_cust_r, {
    showModal(modalDialog(
      title = tagList(icon("user-plus"), " Registrasi Customer Loyalty"),
      textInput("r_cust_id", "ID Customer (CR00xx)*", placeholder = "Contoh: CR0003"),
      textInput("r_cust_nama", "Nama Lengkap*"),
      textInput("r_cust_nohp", "No. HP"),
      textInput("r_cust_email", "Email"),
      footer = tagList(
        modalButton("Batal"),
        actionButton("btn_save_cust_r", "Simpan", class = "btn-success")
      )
    ))
  })

  observeEvent(input$btn_save_cust_r, {
    req(input$r_cust_id, input$r_cust_nama)
    tryCatch({
      q_reguler_insert_customer(input$r_cust_id, input$r_cust_nama, input$r_cust_nohp, input$r_cust_email)
      removeModal()
      showNotification("Customer berhasil didaftarkan!", type = "message", duration = 3)
      rv_customer(rv_customer() + 1)
    }, error = function(e) {
      showNotification("Gagal menambahkan customer. ID mungkin sudah dipakai.", type = "error")
    })
  })

  # MODAL: Input Absensi
  observeEvent(input$btn_add_absensi_r, {
    peg_choices <- q_reguler_get_pegawai()
    peg_list <- setNames(peg_choices$id_pegawai, peg_choices$nama)
    
    showModal(modalDialog(
      title = tagList(icon("user-clock"), " Input Absensi Pegawai Reguler"),
      selectInput("r_abs_pegawai", "Nama Pegawai*", choices = peg_list),
      dateInput("r_abs_tgl", "Tanggal", value = Sys.Date()),
      fluidRow(
        column(6, textInput("r_abs_masuk", "Jam Masuk (HH:MM:SS)", placeholder = "08:00:00")),
        column(6, textInput("r_abs_keluar", "Jam Keluar (HH:MM:SS)", placeholder = "17:00:00"))
      ),
      selectInput("r_abs_status", "Status*", choices = c("hadir", "izin", "sakit", "alpha")),
      textInput("r_abs_ket", "Keterangan", placeholder = "Opsional"),
      footer = tagList(
        modalButton("Batal"),
        actionButton("btn_save_absensi_r", "Simpan Absensi", class = "btn-info")
      )
    ))
  })

  observeEvent(input$btn_save_absensi_r, {
    req(input$r_abs_pegawai, input$r_abs_tgl, input$r_abs_status)
    tryCatch({
      q_reguler_insert_absensi(
        input$r_abs_pegawai, as.character(input$r_abs_tgl), 
        input$r_abs_masuk, input$r_abs_keluar,
        input$r_abs_status, input$r_abs_ket
      )
      removeModal()
      showNotification("Data absensi berhasil disimpan!", type = "message", duration = 3)
      rv_absensi(rv_absensi() + 1)
    }, error = function(e) {
      showNotification("Gagal menyimpan absensi. Pastikan format jam benar (HH:MM:SS).", type = "error")
    })
  })

  # MODAL: Transaksi POS
  observeEvent(input$btn_add_pos_r, {
    cust_choices <- q_reguler_get_customer()
    cust_list <- c("Walk-in (Tanpa Member)" = "")
    if(nrow(cust_choices) > 0) cust_list <- c(cust_list, setNames(cust_choices$id_customer, cust_choices$nama))
    
    peg_choices <- q_reguler_get_pegawai()
    peg_list <- setNames(peg_choices$id_pegawai, peg_choices$nama)
    
    # We can reuse stok_kritis query temporarily or fetch a new list for UI. 
    bar_choices <- q_reguler_get_barang_pos()
    bar_list <- setNames(bar_choices$id_barang, paste0(bar_choices$id_barang, " - ", bar_choices$nama_barang))
    
    met_choices <- q_reguler_get_metode_bayar()
    met_list <- setNames(met_choices$id_metode, met_choices$nama_metode)
    
    showModal(modalDialog(
      title = tagList(icon("cash-register"), " Transaksi Kasir Reguler"),
      fluidRow(
        column(6, selectInput("r_pos_toko", "Toko", choices = c("TR001 - Rungkut" = "TR001", "TR002 - Dukuh Kupang" = "TR002"))),
        column(6, selectInput("r_pos_pegawai", "Kasir*", choices = peg_list))
      ),
      selectInput("r_pos_customer", "Customer", choices = cust_list),
      hr(),
      fluidRow(
        column(8, selectInput("r_pos_barang", "Pilih Barang*", choices = bar_list)),
        column(4, numericInput("r_pos_qty", "Jumlah*", value = 1, min = 1))
      ),
      selectInput("r_pos_metode", "Metode Pembayaran*", choices = met_list),
      footer = tagList(
        modalButton("Batal"),
        actionButton("btn_save_pos_r", "Simpan Transaksi", class = "btn-primary", icon = icon("check-circle"))
      )
    ))
  })

  observeEvent(input$btn_save_pos_r, {
    req(input$r_pos_toko, input$r_pos_pegawai, input$r_pos_barang, input$r_pos_qty, input$r_pos_metode)
    tryCatch({
      q_reguler_insert_transaksi_simple(
        id_toko = input$r_pos_toko,
        id_pegawai = input$r_pos_pegawai,
        id_customer = input$r_pos_customer,
        id_barang = input$r_pos_barang,
        jumlah = input$r_pos_qty,
        id_metode = input$r_pos_metode
      )
      removeModal()
      showNotification("Transaksi berhasil! Stok berkurang & Poin terupdate.", type = "message", duration = 4)
      rv_trx(rv_trx() + 1)
    }, error = function(e) {
      showNotification(paste("Gagal memproses transaksi:", e$message), type = "error", duration = 5)
    })
  })
}
