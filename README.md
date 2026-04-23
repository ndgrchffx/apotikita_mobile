# 💊 Apotikita Mobile - Pharmacy Inventory System

Apotikita Mobile adalah aplikasi manajemen inventaris obat yang dibangun menggunakan **Flutter** untuk sisi mobile dan **Laravel 11** sebagai REST API backend. Aplikasi ini merupakan pengembangan dari sistem berbasis web sebelumnya dengan tambahan fitur informasi obat dari **OpenFDA**.

## 🚀 Fitur Utama
- **Autentikasi JWT**: Login aman untuk mendapatkan token akses.
- **Inventory Management**: CRUD (Create, Read, Update, Delete) data obat secara real-time.
- **Role-Based Access Control (RBAC)**: 
  - **Admin**: Akses penuh untuk mengelola stok (Tambah, Edit, Hapus).
  - **User**: Akses terbatas hanya untuk melihat daftar dan detail informasi obat.
- **OpenFDA Integration**: Pencarian informasi medis obat langsung dari database FDA.
- **Cloud Database**: Sinkronisasi data menggunakan MySQL yang dihosting di Railway.

## 👥 Akun Demo (Testing)
Gunakan akun berikut untuk mencoba fitur Role-Based Access Control:

### 🔐 Akun Admin (Full Access)
- **Email**: `naila@gmail.com`
- **Password**: `password123`
- **Role**: Admin (Bisa tambah/edit/hapus obat)

### 🔓 Akun User (Read Only)
- **Email**: `miksu@gmail.com`
- **Password**: `password123`
- **Role**: User (Hanya bisa melihat daftar obat)

## 🛠️ Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Laravel 11 (PHP)
- **Database**: MySQL (Railway Cloud)
- **API External**: OpenFDA API

## 🏁 Cara Menjalankan Project
1. Clone repository ini.
2. Pastikan Flutter SDK sudah terpasang.
3. Jalankan `flutter pub get` untuk mengunduh dependency.
4. Hubungkan perangkat fisik atau emulator.
5. Jalankan `flutter run`.

---
*Proyek ini dikembangkan untuk memenuhi tugas mata kuliah Pengembangan Aplikasi Berbasis Platform.*
