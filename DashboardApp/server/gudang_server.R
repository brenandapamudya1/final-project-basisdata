# ============================================================
#  gudang_server.R — Server Logic untuk Admin Gudang (Premium)
# ============================================================

gudang_server <- function(input, output, session) {

  rv_gudang_barang <- reactiveVal(0)
  rv_absensi <- reactiveVal(0)

  # ── Reactive Data ─────────────────────────────────────────
  stok_sum   <- reactive({ q_gudang_stok_summary() })
  hutang_sum <- reactive({ q_gudang_hutang_summary() })

  # ── Clock display ─────────────────────────────────────────
  output$g_clock_display <- renderUI({
    invalidateLater(60000, session)
    span(format(Sys.time(), "%H:%M WIB"))
  })

  # ── Value Boxes ───────────────────────────────────────────
  output$g_total_jenis <- renderUI({
    d <- stok_sum()
    if (nrow(d) == 0) return(span("0"))
    span(fmt_num(d$total_jenis_barang))
  })
  output$g_total_unit <- renderUI({
    d <- stok_sum()
    if (nrow(d) == 0) return(span("0"))
    span(fmt_num(d$total_unit))
  })
  output$g_kritis_dc <- renderUI({
    d <- stok_sum()
    if (nrow(d) == 0) return(span("0"))
    span(d$barang_kritis)
  })
  output$g_hutang_count <- renderUI({
    d <- hutang_sum()
    if (nrow(d) == 0) return(span("0"))
    span(d$jml_belum_lunas)
  })

  # ── Quick Action Values ───────────────────────────────────
  output$g_qa_kritis <- renderUI({
    d <- stok_sum()
    if (nrow(d) == 0) return(span("0"))
    span(d$barang_kritis)
  })
  output$g_qa_jatuh_tempo <- renderUI({
    d <- hutang_sum()
    if (nrow(d) == 0) return(span("0"))
    span(d$jatuh_tempo_soon)
  })
  output$g_qa_stok_kritis <- renderUI({
    rv_gudang_barang()
    d <- q_gudang_stok_kritis()
    span(nrow(d))
  })
  output$g_qa_harga_pending <- renderUI({
    d <- q_gudang_harga_pending()
    span(nrow(d))
  })
  output$g_qa_hadir <- renderUI({
    d <- q_gudang_absensi_summary()
    if (nrow(d) == 0) return(span("0"))
    span(d$hadir)
  })
  output$g_qa_toko <- renderUI({
    d <- q_gudang_toko_count()
    if (nrow(d) == 0) return(span("0"))
    span(d$total)
  })
  output$g_qa_total_hutang <- renderUI({
    d <- hutang_sum()
    if (nrow(d) == 0) return(span("Rp 0"))
    span(fmt_rupiah(d$total_belum_lunas))
  })

  # ── Legacy outputs for value box row ──────────────────────
  output$g_harga_pending <- renderUI({ d <- q_gudang_harga_pending(); span(nrow(d)) })
  output$g_hadir_dc      <- renderUI({ d <- q_gudang_absensi_summary(); if(nrow(d)==0) return(span("0")); span(d$hadir) })
  output$g_jatuh_tempo   <- renderUI({ d <- hutang_sum(); if(nrow(d)==0) return(span("0")); span(d$jatuh_tempo_soon) })
  output$g_total_hutang   <- renderUI({ d <- hutang_sum(); if(nrow(d)==0) return(span("Rp 0")); span(fmt_rupiah(d$total_belum_lunas)) })

  # ── Chart: Stok per Toko (light mode) ────────────────────
  output$g_chart_stok_toko <- renderPlotly({
    d <- q_gudang_stok_chart()
    if (nrow(d) == 0) return(plotly_empty())
    plot_ly(d, x = ~id_toko, y = ~total_stok, type = "bar",
            marker = list(color = "#6366F1",
                          line = list(color = "#4F46E5", width = 1)),
            hoverinfo = "text",
            text = ~paste0(id_toko, "<br>Stok: ", format(total_stok, big.mark = "."))) %>%
      layout(
        paper_bgcolor = "transparent", plot_bgcolor = "transparent",
        font = list(color = "#374151", family = "Inter"),
        xaxis = list(title = "", tickfont = list(size = 11)),
        yaxis = list(title = "Total Unit", gridcolor = "#f3f4f6"),
        margin = list(t = 10, b = 30),
        showlegend = FALSE
      ) %>% config(displayModeBar = FALSE)
  })

  # ── Chart: Absensi pie (light mode) ──────────────────────
  output$g_chart_absensi <- renderPlotly({
    rv_absensi()
    d <- q_gudang_absensi_summary()
    if (nrow(d) == 0) return(plotly_empty())
    labels <- c("Hadir", "Izin", "Sakit", "Alpha")
    values <- c(d$hadir, d$izin, d$sakit, d$alpha)
    colors <- c("#10B981", "#6366F1", "#F59E0B", "#EF4444")
    plot_ly(labels = labels, values = values, type = "pie",
            marker = list(colors = colors),
            textinfo = "label+percent",
            hole = 0.4,
            textfont = list(color = "#374151", size = 11)) %>%
      layout(paper_bgcolor = "transparent",
             font = list(color = "#374151", family = "Inter"),
             showlegend = TRUE,
             legend = list(font = list(color = "#374151", size = 11)),
             margin = list(t = 10, b = 10)) %>% config(displayModeBar = FALSE)
  })

  # ── Chart: Top 5 stok terendah (horizontal bar) ─────────
  output$g_chart_top5_stok <- renderPlotly({
    rv_gudang_barang()
    d <- q_gudang_top5_stok_rendah()
    if (nrow(d) == 0) return(plotly_empty())
    d <- d[order(d$jumlah), ]
    plot_ly(d, y = ~reorder(nama_barang, jumlah), x = ~jumlah, type = "bar",
            orientation = "h",
            marker = list(color = ~ifelse(jumlah <= stok_minimal, "#EF4444", "#F59E0B"),
                          line = list(width = 0)),
            hoverinfo = "text",
            text = ~paste0(nama_barang, "<br>Stok: ", jumlah, " / Min: ", stok_minimal)) %>%
      layout(
        paper_bgcolor = "transparent", plot_bgcolor = "transparent",
        font = list(color = "#374151", family = "Inter"),
        xaxis = list(title = "Jumlah Stok", gridcolor = "#f3f4f6"),
        yaxis = list(title = "", tickfont = list(size = 10)),
        margin = list(l = 120, t = 10, b = 30),
        showlegend = FALSE
      ) %>% config(displayModeBar = FALSE)
  })

  # ── Chart: Distribusi per toko ───────────────────────────
  output$g_chart_distribusi <- renderPlotly({
    d <- q_gudang_distribusi_chart()
    if (nrow(d) == 0) return(plotly_empty())
    plot_ly(d, x = ~nama_toko, y = ~total_unit_kirim, type = "bar",
            marker = list(color = "#8B5CF6"),
            hoverinfo = "text",
            text = ~paste0(nama_toko, "<br>", format(total_unit_kirim, big.mark = "."), " unit")) %>%
      layout(
        paper_bgcolor = "transparent", plot_bgcolor = "transparent",
        font = list(color = "#374151", family = "Inter"),
        xaxis = list(title = ""),
        yaxis = list(title = "Unit Dikirim", gridcolor = "#f3f4f6"),
        margin = list(t = 10, b = 30),
        showlegend = FALSE
      ) %>% config(displayModeBar = FALSE)
  })

  # ── Tabel: Stok Kritis DC ─────────────────────────────────
  output$g_tbl_stok_kritis <- renderDT({
    rv_gudang_barang()
    d <- q_gudang_stok_kritis()
    if (nrow(d) == 0) return(datatable(data.frame(Pesan = "Tidak ada barang kritis \U0001F389")))
    d$Status <- mapply(badge_stok, d$jumlah, d$stok_minimal)
    datatable(d, escape = FALSE, rownames = FALSE,
              options = list(pageLength = 10, scrollX = TRUE),
              colnames = c("ID Barang","Nama Barang","Kategori","Stok","Minimal","Kekurangan","Status"))
  })

  # ── Tabel: Rekap Stok Toko ───────────────────────────────
  output$g_tbl_rekap_stok <- renderDT({
    d <- q_gudang_rekap_stok_toko()
    if (nrow(d) == 0) return(datatable(data.frame(Pesan = "Data tidak tersedia")))
    datatable(d, escape = FALSE, rownames = FALSE,
              options = list(pageLength = 15, scrollX = TRUE),
              filter = "top")
  })

  # ── Tabel: Distribusi ─────────────────────────────────────
  output$g_tbl_distribusi <- renderDT({
    d <- q_gudang_distribusi()
    if (nrow(d) == 0) return(datatable(data.frame(Pesan = "Data tidak tersedia")))
    datatable(d, escape = FALSE, rownames = FALSE,
              options = list(pageLength = 10, scrollX = TRUE))
  })

  # ── Tabel: Harga Pending ──────────────────────────────────
  output$g_tbl_harga_pending <- renderDT({
    d <- q_gudang_harga_pending()
    if (nrow(d) == 0) return(datatable(data.frame(Pesan = "Tidak ada harga pending")))
    d$harga_beli <- sapply(d$harga_beli, fmt_rupiah)
    d$harga_jual <- sapply(d$harga_jual, fmt_rupiah)
    datatable(d, escape = FALSE, rownames = FALSE,
              options = list(pageLength = 10, scrollX = TRUE),
              selection = "single")
  })

  # ── Update selectInput approval dari tabel pending ────────
  observe({
    d <- q_gudang_harga_pending()
    if (nrow(d) > 0) {
      choices <- setNames(d$id_harga, paste0("ID ", d$id_harga, " \U2014 ", d$nama_barang, " (", d$nama_toko, ")"))
      updateSelectInput(session, "g_sel_harga_id", choices = choices)
    }
  })

  # ── Aksi Approve/Reject ───────────────────────────────────
  observeEvent(input$g_btn_approve, {
    req(input$g_sel_harga_id, input$g_sel_action)
    result <- q_gudang_approve_harga(input$g_sel_harga_id, input$g_sel_action)
    if (result >= 0) {
      output$g_approval_result <- renderUI({
        div(class = "alert alert-success mt-2",
            icon("check-circle"), sprintf(" Harga ID %s berhasil di-%s!", input$g_sel_harga_id, input$g_sel_action))
      })
    } else {
      output$g_approval_result <- renderUI({
        div(class = "alert alert-danger mt-2", icon("times-circle"), " Gagal mengupdate status harga.")
      })
    }
  })

  # ── Tabel: Semua Harga ────────────────────────────────────
  output$g_tbl_harga_all <- renderDT({
    d <- q_gudang_harga_all()
    if (nrow(d) == 0) return(datatable(data.frame(Pesan = "Data tidak tersedia")))
    d$status <- sapply(d$status, badge_harga)
    datatable(d, escape = FALSE, rownames = FALSE,
              options = list(pageLength = 15, scrollX = TRUE),
              filter = "top")
  })

  # ── Tabel: Hutang ─────────────────────────────────────────
  output$g_tbl_hutang <- renderDT({
    d <- q_gudang_hutang()
    if (nrow(d) == 0) return(datatable(data.frame(Pesan = "Data tidak tersedia")))
    d$jumlah       <- sapply(d$jumlah, fmt_rupiah)
    d$status_hutang <- sapply(d$status_hutang, badge_hutang)
    datatable(d, escape = FALSE, rownames = FALSE,
              options = list(pageLength = 15, scrollX = TRUE),
              filter = "top")
  })

  # ── Tabel: Absensi ────────────────────────────────────────
  output$g_tbl_absensi <- renderDT({
    rv_absensi()
    d <- q_gudang_absensi()
    if (nrow(d) == 0) return(datatable(data.frame(Pesan = "Data tidak tersedia")))
    d$status <- sapply(d$status, badge_absensi)
    datatable(d, escape = FALSE, rownames = FALSE,
              options = list(pageLength = 15, scrollX = TRUE),
              filter = "top")
  })

  # ── MODAL: Tambah Barang Baru ───────────────────────────────
  observeEvent(input$btn_add_barang, {
    cat_choices <- q_gudang_get_kategori()
    cat_list <- setNames(cat_choices$id_kategori, cat_choices$nama_kategori)
    
    sup_choices <- q_gudang_get_supplier()
    sup_list <- setNames(sup_choices$id_supplier, sup_choices$nama)
    
    showModal(modalDialog(
      title = tagList(icon("box-open"), " Tambah Master Barang Baru"),
      textInput("g_bar_id", "ID Barang (BG/BE00xxxx)*", placeholder = "Contoh: BG000011"),
      textInput("g_bar_nama", "Nama Barang*"),
      selectInput("g_bar_kat", "Kategori", choices = cat_list),
      selectInput("g_bar_sup", "Supplier", choices = sup_list),
      fluidRow(
        column(6, textInput("g_bar_sat", "Satuan", value = "Pcs")),
        column(6, numericInput("g_bar_berat", "Berat (Gram)", value = 0, min = 0))
      ),
      selectInput("g_bar_tipe", "Tipe Toko", choices = c("Reguler", "Express", "Semua")),
      footer = tagList(
        modalButton("Batal"),
        actionButton("btn_save_barang", "Simpan Barang", class = "btn-primary")
      )
    ))
  })

  observeEvent(input$btn_save_barang, {
    req(input$g_bar_id, input$g_bar_nama)
    tryCatch({
      q_gudang_insert_barang(
        input$g_bar_id, input$g_bar_nama, input$g_bar_kat,
        input$g_bar_sup, input$g_bar_sat, input$g_bar_berat,
        input$g_bar_tipe
      )
      removeModal()
      showNotification("Barang berhasil ditambahkan ke master!", type = "message", duration = 3)
      rv_gudang_barang(rv_gudang_barang() + 1)
    }, error = function(e) {
      showNotification("Gagal menambahkan barang. Cek kembali data atau ID.", type = "error")
    })
  })

  # ── MODAL: Input Absensi ────────────────────────────────────
  observeEvent(input$btn_add_absensi_g, {
    peg_choices <- q_gudang_get_pegawai()
    peg_list <- setNames(peg_choices$id_pegawai, peg_choices$nama)
    
    showModal(modalDialog(
      title = tagList(icon("user-clock"), " Input Absensi Staff DC"),
      selectInput("g_abs_pegawai", "Nama Pegawai*", choices = peg_list),
      dateInput("g_abs_tgl", "Tanggal", value = Sys.Date()),
      fluidRow(
        column(6, textInput("g_abs_masuk", "Jam Masuk (HH:MM:SS)", placeholder = "08:00:00")),
        column(6, textInput("g_abs_keluar", "Jam Keluar (HH:MM:SS)", placeholder = "17:00:00"))
      ),
      selectInput("g_abs_status", "Status*", choices = c("hadir", "izin", "sakit", "alpha")),
      textInput("g_abs_ket", "Keterangan", placeholder = "Opsional"),
      footer = tagList(
        modalButton("Batal"),
        actionButton("btn_save_absensi_g", "Simpan Absensi", class = "btn-info")
      )
    ))
  })

  observeEvent(input$btn_save_absensi_g, {
    req(input$g_abs_pegawai, input$g_abs_tgl, input$g_abs_status)
    tryCatch({
      q_gudang_insert_absensi(
        input$g_abs_pegawai, as.character(input$g_abs_tgl), 
        input$g_abs_masuk, input$g_abs_keluar,
        input$g_abs_status, input$g_abs_ket
      )
      removeModal()
      showNotification("Data absensi berhasil disimpan!", type = "message", duration = 3)
      rv_absensi(rv_absensi() + 1)
    }, error = function(e) {
      showNotification("Gagal menyimpan absensi. Pastikan format jam benar (HH:MM:SS).", type = "error")
    })
  })
}
