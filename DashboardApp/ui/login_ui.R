# Halaman Login Premium

login_ui <- function() {
  tagList(
    div(class = "login-wrapper",
      div(class = "login-card",
        div(class = "login-header",
          div(class = "login-icon-wrapper",
            icon("store")
          ),
          h2("Retail Dashboard"),
          p(class = "login-subtitle", "Sistem Monitoring Ritel Multi-Database")
        ),
        div(class = "login-body",
          div(class = "form-group",
            tags$label(icon("user"), " Role Akun"),
            selectInput("username", label = NULL,
              choices = c(
                "Admin Gudang"  = "admin_gudang",
                "Admin Express" = "admin_express",
                "Admin Reguler" = "admin_reguler"
              ),
              width = "100%"
            )
          ),
          div(class = "form-group", style = "position: relative;",
            tags$label(icon("lock"), " Password"),
            passwordInput("password", label = NULL,
                          placeholder = "Masukkan password...",
                          width = "100%"),
            tags$span(id = "toggle_password", icon("eye"), 
                      style = "position: absolute; right: 15px; top: 38px; cursor: pointer; color: #6b7280; z-index: 10;")
          ),
          tags$script(HTML("
            document.getElementById('toggle_password').addEventListener('click', function() {
              var pwd = document.getElementById('password');
              var icon = this.querySelector('i');
              if (pwd.type === 'password') {
                pwd.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
              } else {
                pwd.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
              }
            });
          ")),
          actionButton("btn_login", "Masuk ke Dashboard",
            class = "btn btn-primary btn-block btn-login",
            icon  = icon("arrow-right")
          ),
          div(class = "login-hint",
            tags$small(
              icon("info-circle"),
              " Password: gudang123 / express123 / reguler123"
            )
          )
        )
      )
    )
  )
}
