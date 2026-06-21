# Entry Point Aplikasi R Shiny

library(shiny)
library(bs4Dash)
library(plotly)
library(DT)
library(shinyjs)

# 1. Source Semua File
source("R/config.R",  local = TRUE)
source("R/helpers.R", local = TRUE)
source("R/auth.R",    local = TRUE)

source("R/queries_gudang.R",  local = TRUE)
source("R/queries_express.R", local = TRUE)
source("R/queries_reguler.R", local = TRUE)

source("ui/login_ui.R",   local = TRUE)
source("ui/gudang_ui.R",  local = TRUE)
source("ui/express_ui.R", local = TRUE)
source("ui/reguler_ui.R", local = TRUE)

source("server/gudang_server.R",  local = TRUE)
source("server/express_server.R", local = TRUE)
source("server/reguler_server.R", local = TRUE)

# 2. Define UI Master
ui <- bs4DashPage(
  dark  = NULL,
  help  = NULL,
  title = "Dashboard Ritel Multi-DB",
  header = bs4DashNavbar(
    title = uiOutput("nav_brand"),
    rightUi = uiOutput("nav_right"),
    skin = "light",
    status = "white"
  ),
  sidebar = bs4DashSidebar(
    id = "main_sidebar",
    skin = "light",
    status = "primary",
    elevation = 2,
    uiOutput("sidebar_menu")
  ),
  body = bs4DashBody(
    useShinyjs(),
    tags$head(
      tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
      tags$link(rel = "preconnect", href = "https://fonts.gstatic.com", crossorigin = NA),
      tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"),
      tags$link(rel = "stylesheet", href = "custom.css")
    ),
    uiOutput("page_content")
  )
)

# 3. Define Server Master
server <- function(input, output, session) {

  USER_ROLE    <- reactiveVal("login")
  server_init  <- reactiveValues(gudang = FALSE, express = FALSE, reguler = FALSE)

  # Inject data-role ke <body> untuk CSS theming
  observe({
    role <- USER_ROLE()
    runjs(sprintf("document.body.setAttribute('data-role', '%s');", role))
  })

  # Navbar Brand (logo + title berubah per role)
  output$nav_brand <- renderUI({
    role <- USER_ROLE()
    if (role == "login") return(tags$span(class = "brand-text font-weight-bold", icon("store"), " Retail Dashboard"))
    if (role == "gudang")  return(tags$span(class = "brand-text font-weight-bold", icon("warehouse"), " Admin Gudang"))
    if (role == "express") return(tags$span(class = "brand-text font-weight-bold", icon("bolt"),      " Admin Express"))
    if (role == "reguler") return(tags$span(class = "brand-text font-weight-bold", icon("shopping-basket"), " Admin Reguler"))
  })

  # Tombol Logout di navbar kanan
  output$nav_right <- renderUI({
    if (USER_ROLE() != "login") {
      tags$li(class = "nav-item",
        actionLink("btn_logout",
          label = tagList(icon("sign-out-alt"), " Logout"),
          class = "nav-link text-danger")
      )
    }
  })

  # Sidebar Menu (berubah per role)
  output$sidebar_menu <- renderUI({
    role <- USER_ROLE()
    if (role == "login") return(NULL)

    if (role == "gudang") {
      bs4SidebarMenu(
        id = "tabs",
        bs4SidebarMenuItem("Dashboard",        tabName = "g_home",       icon = icon("tachometer-alt")),
        bs4SidebarMenuItem("Stok DC",          tabName = "g_stok",       icon = icon("boxes")),
        bs4SidebarMenuItem("Rekap Stok Toko",  tabName = "g_rekap",      icon = icon("store")),
        bs4SidebarMenuItem("Distribusi",       tabName = "g_distribusi",  icon = icon("truck")),
        bs4SidebarMenuItem("Harga & Approval", tabName = "g_harga",      icon = icon("tags")),
        bs4SidebarMenuItem("Hutang Supplier",  tabName = "g_hutang",     icon = icon("file-invoice-dollar")),
        bs4SidebarMenuItem("Absensi Staff",    tabName = "g_absensi",    icon = icon("user-clock"))
      )
    } else if (role == "express") {
      bs4SidebarMenu(
        id = "tabs",
        bs4SidebarMenuItem("Dashboard",        tabName = "e_home",    icon = icon("tachometer-alt")),
        bs4SidebarMenuItem("Transaksi",        tabName = "e_trx",     icon = icon("shopping-cart")),
        bs4SidebarMenuItem("Stok & Restock",   tabName = "e_stok",    icon = icon("boxes")),
        bs4SidebarMenuItem("Promo",            tabName = "e_promo",   icon = icon("percent")),
        bs4SidebarMenuItem("Hutang Supplier",  tabName = "e_hutang",  icon = icon("file-invoice-dollar")),
        bs4SidebarMenuItem("Absensi",          tabName = "e_absensi", icon = icon("user-clock"))
      )
    } else if (role == "reguler") {
      bs4SidebarMenu(
        id = "tabs",
        bs4SidebarMenuItem("Dashboard",         tabName = "r_home",    icon = icon("tachometer-alt")),
        bs4SidebarMenuItem("Transaksi",         tabName = "r_trx",     icon = icon("shopping-cart")),
        bs4SidebarMenuItem("Stok per Section",  tabName = "r_stok",    icon = icon("layer-group")),
        bs4SidebarMenuItem("Customer & Loyalty",tabName = "r_cust",    icon = icon("crown")),
        bs4SidebarMenuItem("Promo",             tabName = "r_promo",   icon = icon("percent")),
        bs4SidebarMenuItem("Hutang Supplier",   tabName = "r_hutang",  icon = icon("file-invoice-dollar")),
        bs4SidebarMenuItem("Absensi",           tabName = "r_absensi", icon = icon("user-clock"))
      )
    }
  })

  # Render Body Content
  output$page_content <- renderUI({
    role <- USER_ROLE()
    if (role == "login") {
      login_ui()
    } else if (role == "gudang") {
      gudang_ui_tabs()
    } else if (role == "express") {
      express_ui_tabs()
    } else if (role == "reguler") {
      reguler_ui_tabs()
    }
  })

  # Inisialisasi server modules (hanya sekali per role)
  observe({
    role <- USER_ROLE()
    if (role == "gudang"  && !server_init$gudang)  { gudang_server(input, output, session);  server_init$gudang  <- TRUE }
    if (role == "express" && !server_init$express)  { express_server(input, output, session); server_init$express <- TRUE }
    if (role == "reguler" && !server_init$reguler)  { reguler_server(input, output, session); server_init$reguler <- TRUE }
  })

  # Fix navigasi: klik tab pertama setelah sidebar ter-render
  observe({
    role <- USER_ROLE()
    if (role != "login") {
      tab_name <- switch(role,
        "gudang"  = "g_home",
        "express" = "e_home",
        "reguler" = "r_home"
      )
      # Delay agar sidebar sudah ter-render di DOM, lalu paksa aktifkan tab
      shinyjs::delay(300, {
        updateTabItems(session, "tabs", selected = tab_name)
      })
    }
  })

  # Handle tombol Login
  observeEvent(input$btn_login, {
    req(input$username, input$password)
    role <- check_login(input$username, input$password)

    if (!is.null(role)) {
      USER_ROLE(role)
    } else {
      showModal(modalDialog(
        title = tags$span(icon("exclamation-triangle"), " Login Gagal"),
        tags$p("Username atau password salah. Silakan coba lagi."),
        easyClose = TRUE,
        footer = modalButton("Tutup")
      ))
    }
  })

  # Handle tombol Logout
  observeEvent(input$btn_logout, {
    USER_ROLE("login")
    # Reset server init agar bisa re-initialize jika login ulang
    server_init$gudang  <- FALSE
    server_init$express <- FALSE
    server_init$reguler <- FALSE
    # Hide sidebar saat kembali ke login
    runjs("document.body.classList.add('sidebar-collapse');")
  })

  # Hide sidebar saat di login page
  observe({
    if (USER_ROLE() == "login") {
      runjs("document.body.classList.add('sidebar-collapse');")
    } else {
      runjs("document.body.classList.remove('sidebar-collapse');")
    }
  })
}

shinyApp(ui = ui, server = server)
