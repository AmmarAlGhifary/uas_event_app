<div align="center">
  <img src="https://path.to/your/logo.png" alt="AcaraKita Logo" width="120">
  <h1>
    <br>
    AcaraKita
  </h1>
  <p>
    Sebuah aplikasi mobile berbasis Flutter untuk menemukan, mendaftar, dan mengelola event. Proyek ini dibuat sebagai bagian dari Ujian Akhir Semester (UAS).
  </p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter" alt="Flutter Version">
    <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  </p>
</div>

---

## ✨ **Fitur Utama**

Aplikasi ini dilengkapi dengan serangkaian fitur yang kuat untuk pengguna dan penyelenggara event.

| Fitur                 | Status      | Deskripsi                                                               |
| --------------------- | ----------- | ----------------------------------------------------------------------- |
| 👤 **Autentikasi** | ✅ Selesai  | Registrasi & Login pengguna dengan manajemen sesi (token).              |
| 🏠 **Dashboard** | ✅ Selesai  | Menampilkan semua event dengan fitur pencarian dan filter (status event). |
| 🎫 **Pendaftaran Event** | ✅ Selesai  | Pengguna dapat mendaftar untuk event yang tersedia.                     |
| ➕ **Buat Event** | ✅ Selesai  | Fungsionalitas CRUD untuk membuat event baru oleh pengguna.             |
| 📝 **Edit & Hapus Event** | ✅ Selesai  | Pengguna dapat mengelola event yang telah mereka buat.                  |
| 👤 **Halaman Profil** | ✅ Selesai  | Menampilkan data pengguna, event yang diikuti, dan event yang dibuat.     |
| 👋 **Logout** | ✅ Selesai  | Mengakhiri sesi pengguna dan menghapus data lokal.                      |

---

##  **Cara Menjalankan Proyek**

Ikuti langkah-langkah berikut untuk menjalankan proyek ini di lingkungan lokal Anda.

### **1. <font color="#A3EBB1">Prasyarat</font>**
Pastikan Anda sudah menginstal **Flutter SDK** (versi 3.x atau lebih tinggi) di komputer Anda.

### **2. <font color="#A3EBB1">Kloning Repository</font>**
```bash
git clone [https://github.com/yourusername/uas_event_app.git](https://github.com/yourusername/uas_event_app.git)
cd uas_event_app
```

### **3. <font color="#A3EBB1">Instal Dependensi</font>**
Jalankan perintah berikut untuk mengunduh semua package yang dibutuhkan.
```bash
flutter pub get
```

### **4. <font color="#A3EBB1">Jalankan Aplikasi</font>**
Hubungkan perangkat atau jalankan emulator, lalu jalankan perintah:
```bash
flutter run
```

---

## 🛠️ **Teknologi & Package yang Digunakan**

* **`flutter`**: Framework utama.
* **`http`**: Untuk melakukan panggilan ke REST API.
* **`shared_preferences`**: Untuk menyimpan token otentikasi dan data sesi.
* **`intl`**: Untuk memformat tanggal agar lebih mudah dibaca.
* **`google_fonts`**: Untuk kustomisasi font agar UI lebih menarik.

<br>

<div align="center">
  <p>Dibuat dengan ❤️ untuk Ujian Akhir Semester Al Azhar</p>
</div>
