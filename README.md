# 🧪 Skill Test: Aplikasi Absensi Lokasi + Kamera (Flutter)

## 📝 Deskripsi Aplikasi

Aplikasi absensi sederhana berbasis Flutter yang memenuhi persyaratan skill test dengan dua syarat utama:
1. Pengguna harus berada dalam radius 100 meter dari lokasi kantor (-6.200000, 106.816666)
2. Pengguna harus mengambil foto selfie sebagai bukti kehadiran

## 📱 Fitur Utama

### 1. Login Sederhana
- Login menggunakan email dan password (validasi lokal)
- Penyimpanan nama pengguna menggunakan SharedPreferences

### 2. Halaman Absensi
- Menampilkan:
  - Nama pengguna
  - Tanggal dan waktu saat ini dalam bahasa Indonesia
  - Lokasi pengguna (koordinat)
  - Status absensi hari ini (sudah/belum absen)
- Validasi lokasi:
  - Menghitung jarak menggunakan formula Haversine
  - Hanya aktif jika berada dalam radius 100 meter dari kantor (-6.200000, 106.816666)
- Pengambilan foto selfie:
  - Menggunakan kamera perangkat
  - Preview foto sebelum disimpan
  - Tombol hapus untuk mengganti foto

### 3. Riwayat Absensi
- Menampilkan daftar absensi dengan:
  - Tanggal dan jam dalam bahasa Indonesia
  - Status lokasi (valid/tidak valid)
  - Thumbnail foto selfie
- Fitur filter berdasarkan bulan dan tahun
- Tampilan "empty state" ketika belum ada riwayat

## 📦 Teknologi & Plugin yang Digunakan

| Plugin | Versi | Kegunaan |
|--------|-------|----------|
| `geolocator` | ^12.0.0 | Mendapatkan lokasi pengguna dan menghitung jarak ke kantor |
| `image_picker` | ^1.1.2 | Mengambil foto selfie dari kamera |
| `shared_preferences` | ^2.3.2 | Menyimpan data lokal (nama pengguna dan riwayat absensi) |
| `intl` | ^0.19.0 | Format tanggal dan waktu dalam bahasa Indonesia |
| `path_provider` | ^2.1.4 | Mendapatkan direktori aplikasi untuk menyimpan foto |
| `permission_handler` | ^11.3.1 | Menangani izin lokasi dan kamera |

## ⚙️ Cara Menjalankan Aplikasi

### Persyaratan
- Flutter SDK versi 3.9.0 atau lebih baru
- Android Studio atau VS Code dengan plugin Flutter
- Perangkat Android atau emulator

### Langkah-langkah Instalasi

1. **Clone repository** atau ekstrak file ZIP:
   ```bash
   git clone https://github.com/abhisn15/absensi_app.git
   cd absensi_app
