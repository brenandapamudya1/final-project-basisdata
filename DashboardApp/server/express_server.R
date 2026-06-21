# Server Logic untuk Admin Express (Premium)

express_server <- function(input, output, session) {

  rv_promo <- reactiveVal(0)
  rv_absensi <- reactiveVal(0)
  rv_trx <- reactiveVal(0)

  penjualan <- reactive({ rv_trx(); q_express_penjualan_summary() })

  output$e_clock_display <- renderUI({
    invalidateLater(60000, session); span(format(Sys.time(), "%H:%M WIB"))
  })

  # Value Boxes
  output$e_total_trx <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("0")); span(fmt_num(d$total_transaksi)) })
  output$e_total_revenue <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("Rp 0")); span(fmt_rupiah(d$total_pendapatan)) })
  output$e_stok_kritis <- renderUI({ span(nrow(q_express_stok_kritis())) })
  output$e_promo_aktif <- renderUI({
    rv_promo()
    d <- q_express_promo()
    aktif <- sum(d$is_aktif == "Ya" & !is.na(d$sisa_hari) & d$sisa_hari >= 0, na.rm = TRUE)
    span(aktif)
  })

  # Quick Actions
  output$e_qa_trx_darmo  <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("0")); span(fmt_num(d$trx_darmo)) })
  output$e_qa_trx_gubeng <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("0")); span(fmt_num(d$trx_gubeng)) })
  output$e_qa_kritis     <- renderUI({ rv_trx(); span(nrow(q_express_stok_kritis())) })
  output$e_qa_diskon     <- renderUI({ d <- penjualan(); if(nrow(d)==0) return(span("Rp 0")); span(fmt_rupiah(d$total_diskon)) })

  # Chart: Metode pembayaran donut
  output$e_chart_metode <- renderPlotly({
    d <- q_express_metode_bayar_chart()
    if (nrow(d) == 0) return(plotly_empty())
    cols <- c("#F59E0B","#6366F1","#10B981","#EF4444","#06B6D4")
    plot_ly(d, labels=~nama_metode, values=~jumlah, type="pie",
            marker=list(colors=cols[1:nrow(d)]), textinfo="label+percent", hole=0.4,
            textfont=list(color="#374151",size=11)) %>%
      layout(paper_bgcolor="transparent", font=list(color="#374151",family="Inter"),
             showlegend=TRUE, legend=list(font=list(color="#374151",size=11)), margin=list(t=10,b=10)) %>% config(displayModeBar = FALSE)
  })

  # Chart: Top 5 produk terlaris
  output$e_chart_top5 <- renderPlotly({
    rv_trx()
    d <- q_express_top5_produk()
    if (nrow(d) == 0) return(plotly_empty())
    d <- d[order(d$total_terjual),]
    plot_ly(d, y=~reorder(nama_barang,total_terjual), x=~total_terjual, type="bar", orientation="h",
            marker=list(color="#10B981"), hoverinfo="text",
            text=~paste0(nama_barang,"<br>Terjual: ",total_terjual," unit")) %>%
      layout(paper_bgcolor="transparent", plot_bgcolor="transparent",
             font=list(color="#374151",family="Inter"),
             xaxis=list(title="Unit Terjual",gridcolor="#f3f4f6"),
             yaxis=list(title="",tickfont=list(size=10)),
             margin=list(l=120,t=10,b=30), showlegend=FALSE) %>% config(displayModeBar = FALSE)
  })

  # Tables
  output$e_tbl_transaksi <- renderDT({
    rv_trx()
    d <- q_express_transaksi_terbaru()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Belum ada transaksi")))
    d$total_belanja <- sapply(d$total_belanja, fmt_rupiah)
    d$total_diskon  <- sapply(d$total_diskon,  fmt_rupiah)
    d$total_bayar   <- sapply(d$total_bayar,   fmt_rupiah)
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$e_tbl_stok_kritis <- renderDT({
    rv_trx()
    d <- q_express_stok_kritis()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Tidak ada barang kritis")))
    d$Status <- mapply(badge_stok, d$jumlah, d$stok_minimal)
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$e_tbl_stok_all <- renderDT({
    rv_trx()
    d <- q_express_stok_all()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Data tidak tersedia")))
    datatable(d, escape=FALSE, rownames=FALSE, filter="top", options=list(pageLength=15,scrollX=TRUE))
  })

  output$e_tbl_restock <- renderDT({
    d <- q_express_restock()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Data tidak tersedia")))
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$e_tbl_promo <- renderDT({
    rv_promo()
    d <- q_express_promo()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Belum ada promo")))
    d$sisa_hari <- sapply(d$sisa_hari, function(x) { if(is.na(x)) return("-"); sisa_hari_promo(Sys.Date()+x) })
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$e_tbl_hutang <- renderDT({
    d <- q_express_hutang()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Data tidak tersedia")))
    d$jumlah <- sapply(d$jumlah, fmt_rupiah)
    d$status_hutang <- sapply(d$status_hutang, badge_hutang)
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  output$e_tbl_absensi <- renderDT({
    rv_absensi()
    d <- q_express_absensi()
    if (nrow(d)==0) return(datatable(data.frame(Pesan="Data tidak tersedia")))
    d$status <- sapply(d$status, badge_absensi)
    datatable(d, escape=FALSE, rownames=FALSE, options=list(pageLength=10,scrollX=TRUE))
  })

  # MODAL: Tambah Promo
  observeEvent(input$btn_add_promo_e, {
    barang_choices <- q_express_get_barang_promo()
    choices_list <- setNames(barang_choices$id_barang, paste0(barang_choices$id_barang, " - ", barang_choices$nama_barang))
    
    showModal(modalDialog(
      title = tagList(icon("tags"), " Buat Promo Baru"),
      textInput("e_promo_id", "ID Promo (PR00xx)*", placeholder = "Contoh: PR0004"),
      textInput("e_promo_nama", "Nama Promo*"),
      selectInput("e_promo_barang", "Pilih Barang*", choices = choices_list),
      fluidRow(
        column(6, selectInput("e_promo_jenis", "Jenis Diskon", choices = c("persentase", "nominal"))),
        column(6, numericInput("e_promo_nilai", "Nilai Diskon", value = 0, min = 0))
      ),
      fluidRow(
        column(6, dateInput("e_promo_mulai", "Tgl Mulai")),
        column(6, dateInput("e_promo_selesai", "Tgl Selesai"))
      ),
      selectInput("e_promo_aktif", "Status", choices = c("Ya", "Tidak")),
      footer = tagList(
        modalButton("Batal"),
        actionButton("btn_save_promo_e", "Simpan Promo", class = "btn-warning")
      )
    ))
  })

  observeEvent(input$btn_save_promo_e, {
    req(input$e_promo_id, input$e_promo_nama, input$e_promo_barang)
    tryCatch({
      q_express_insert_promo(
        input$e_promo_id, input$e_promo_nama, input$e_promo_barang,
        input$e_promo_jenis, input$e_promo_nilai, 
        as.character(input$e_promo_mulai), as.character(input$e_promo_selesai),
        input$e_promo_aktif
      )
      removeModal()
      showNotification("Promo berhasil ditambahkan!", type = "message", duration = 3)
      rv_promo(rv_promo() + 1)
    }, error = function(e) {
      showNotification("Gagal menambahkan promo. Cek kembali data atau ID.", type = "error")
    })
  })

  # MODAL: Input Absensi
  observeEvent(input$btn_add_absensi_e, {
    peg_choices <- q_express_get_pegawai()
    peg_list <- setNames(peg_choices$id_pegawai, peg_choices$nama)
    
    showModal(modalDialog(
      title = tagList(icon("user-clock"), " Input Absensi Pegawai Express"),
      selectInput("e_abs_pegawai", "Nama Pegawai*", choices = peg_list),
      dateInput("e_abs_tgl", "Tanggal", value = Sys.Date()),
      fluidRow(
        column(6, textInput("e_abs_masuk", "Jam Masuk (HH:MM:SS)", placeholder = "08:00:00")),
        column(6, textInput("e_abs_keluar", "Jam Keluar (HH:MM:SS)", placeholder = "17:00:00"))
      ),
      selectInput("e_abs_status", "Status*", choices = c("hadir", "izin", "sakit", "alpha")),
      textInput("e_abs_ket", "Keterangan", placeholder = "Opsional"),
      footer = tagList(
        modalButton("Batal"),
        actionButton("btn_save_absensi_e", "Simpan Absensi", class = "btn-info")
      )
    ))
  })

  observeEvent(input$btn_save_absensi_e, {
    req(input$e_abs_pegawai, input$e_abs_tgl, input$e_abs_status)
    tryCatch({
      q_express_insert_absensi(
        input$e_abs_pegawai, as.character(input$e_abs_tgl), 
        input$e_abs_masuk, input$e_abs_keluar,
        input$e_abs_status, input$e_abs_ket
      )
      removeModal()
      showNotification("Data absensi berhasil disimpan!", type = "message", duration = 3)
      rv_absensi(rv_absensi() + 1)
    }, error = function(e) {
      showNotification("Gagal menyimpan absensi. Pastikan format jam benar (HH:MM:SS).", type = "error")
    })
  })

  # MODAL: Transaksi POS
  observeEvent(input$btn_add_pos_e, {
    cust_choices <- q_express_get_customer()
    cust_list <- c("Walk-in (Tanpa Member)" = "")
    if(nrow(cust_choices) > 0) cust_list <- c(cust_list, setNames(cust_choices$id_customer, cust_choices$nama))
    
    peg_choices <- q_express_get_pegawai()
    peg_list <- setNames(peg_choices$id_pegawai, peg_choices$nama)
    
    bar_choices <- q_express_get_barang_promo()
    bar_list <- setNames(bar_choices$id_barang, paste0(bar_choices$id_barang, " - ", bar_choices$nama_barang))
    
    met_choices <- q_express_get_metode_bayar()
    met_list <- setNames(met_choices$id_metode, met_choices$nama_metode)
    
    showModal(modalDialog(
      title = tagList(icon("cash-register"), " Transaksi Kasir Express"),
      fluidRow(
        column(6, selectInput("e_pos_toko", "Toko", choices = c("TE001 - Express Darmo" = "TE001", "TE002 - Express Gubeng" = "TE002"))),
        column(6, selectInput("e_pos_pegawai", "Kasir*", choices = peg_list))
      ),
      selectInput("e_pos_customer", "Customer", choices = cust_list),
      hr(),
      fluidRow(
        column(8, selectInput("e_pos_barang", "Pilih Barang*", choices = bar_list)),
        column(4, numericInput("e_pos_qty", "Jumlah*", value = 1, min = 1))
      ),
      selectInput("e_pos_metode", "Metode Pembayaran*", choices = met_list),
      footer = tagList(
        modalButton("Batal"),
        actionButton("btn_save_pos_e", "Simpan Transaksi", class = "btn-primary", icon = icon("check-circle"))
      )
    ))
  })

  observeEvent(input$btn_save_pos_e, {
    req(input$e_pos_toko, input$e_pos_pegawai, input$e_pos_barang, input$e_pos_qty, input$e_pos_metode)
    tryCatch({
      q_express_insert_transaksi_simple(
        id_toko = input$e_pos_toko,
        id_pegawai = input$e_pos_pegawai,
        id_customer = input$e_pos_customer,
        id_barang = input$e_pos_barang,
        jumlah = input$e_pos_qty,
        id_metode = input$e_pos_metode
      )
      removeModal()
      showNotification("Transaksi berhasil! Stok berkurang & Poin terupdate.", type = "message", duration = 4)
      rv_trx(rv_trx() + 1)
    }, error = function(e) {
      showNotification(paste("Gagal memproses transaksi:", e$message), type = "error", duration = 5)
    })
  })
}
