# 📊 Retail Dashboard App (R Shiny)

Aplikasi Dashboard interaktif berbasis R Shiny untuk Sistem Manajemen Ritel Multi-Database. Aplikasi ini memiliki arsitektur dinamis yang menampilkan antarmuka berbeda berdasarkan 3 role pengguna (Admin Gudang, Admin Express, dan Admin Reguler) dan mengambil data dari 3 database MySQL yang saling terhubung.

---

## 🚀 Prosedur Memulai Aplikasi (Live Server Lokal)

Aplikasi dan database telah dibungkus menggunakan **Docker** sehingga dapat dijalankan dengan mudah dalam satu perintah tanpa perlu konfigurasi server R dan MySQL secara manual.

### Persyaratan Sistem
* Telah menginstal **Docker** dan **Docker Compose** di komputer Anda.

### Langkah-langkah Eksekusi

1. Buka terminal Anda dan masuk ke direktori `DashboardApp`:
   ```bash
   cd /path/to/FinalProject/DashboardApp/
   ```

2. Bangun dan jalankan container di latar belakang (_detached mode_):
   ```bash
   docker-compose up -d --build
   ```
   *Catatan: Proses ini akan menjalankan 2 container. Container MySQL (`retail_db`) akan secara otomatis mengeksekusi file SQL (`Gudang.sql`, `TokoExpress.sql`, `TokoReguler.sql`, dan `Triggers.sql`) dari direktori induk.*

3. Buka browser dan akses aplikasi melalui:
   **[http://localhost:3838/dashboard/](http://localhost:3838/dashboard/)**

4. Untuk menghentikan server, jalankan:
   ```bash
   docker-compose stop
   ```
   *(Gunakan `docker-compose down -v` jika ingin menghapus container secara permanen).*

---

## 🧠 Overview Algorithm & Code Workflow

Aplikasi ini menggunakan arsitektur modular yang memisahkan logika UI (tampilan), Server (pemrosesan), dan Data (query database). Alur kerja (_workflow_) algoritma utamanya adalah sebagai berikut:

### 1. Entry Point (`app.R`)
File `app.R` merupakan otak utama aplikasi. Saat dijalankan, file ini akan me-_load_ semua script dari subfolder (`R/`, `ui/`, `server/`) dan menginisialisasi **bs4DashPage**. 
Awalnya, aplikasi akan mengatur state `USER_ROLE` menjadi `"login"`, sehingga UI yang ditampilkan hanya halaman login.

### 2. Autentikasi & Role-Based Access Control (`R/auth.R`)
* Pengguna memasukkan *username* dan *password*.
* Sistem akan memvalidasi *credentials* tersebut.
* Jika berhasil, `USER_ROLE` akan diubah menjadi salah satu dari: `gudang`, `express`, atau `reguler`.
* Perubahan `USER_ROLE` bersifat **Reactive**, yang secara otomatis akan memicu re-render pada UI utama (Navbar, Sidebar Menu, dan Body Content) sesuai dengan hak akses pengguna.

### 3. Koneksi Database (`R/config.R`)
Aplikasi membaca kredensial database (host, port, password) dari **Environment Variables** yang disuntikkan oleh `docker-compose.yml`. Terdapat 3 fungsi terpisah untuk membuat koneksi ke masing-masing database:
* `get_con_gudang()`
* `get_con_express()`
* `get_con_reguler()`

Koneksi hanya dibuka sesaat saat query dieksekusi, lalu segera ditutup (menggunakan pola `on.exit(dbDisconnect(con))`) untuk mencegah *resource leak*.

### 4. Pengambilan Data (`R/queries_*.R`)
Masing-masing role memiliki file *queries*-nya sendiri:
* `queries_gudang.R`
* `queries_express.R`
* `queries_reguler.R`

Fungsi di dalam file ini bertugas memanggil query SQL, mengambil data, dan mengembalikannya ke Server dalam bentuk Data Frame. File ini sangat bergantung pada struktur Database serta **Static Pivot** dan **Temporary Tables** yang sudah dirancang pada tahap basis data.

### 5. UI & Server Modular (`ui/` & `server/`)
* **UI Modules:** Mendefinisikan kerangka tampilan (kotak KPI, grafik plotly, dan tabel DT). Tampilan bersifat dinamis dan menggunakan `shinycssloaders` untuk memberikan efek loading saat data sedang ditarik dari database.
* **Server Modules:** Menghubungkan fungsi *queries* dengan *UI*. Data yang berhasil ditarik dari database akan diolah secara reaktif lalu di-*inject* ke UI (misalnya mengubah Data Frame menjadi grafik interaktif menggunakan `renderPlotly` atau tabel menggunakan `renderDT`).
* **Optimasi:** Fungsi server untuk setiap role hanya akan diinisialisasi (`server_init`) maksimal **satu kali** per sesi pengguna untuk menghemat RAM dan memori pemrosesan.
