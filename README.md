# 🧪 Skill Test: Aplikasi Absensi Lokasi + Kamera (Flutter)

Aplikasi absensi sederhana berbasis Flutter yang memenuhi persyaratan skill test dengan dua syarat utama:
1. 📍 Pengguna harus berada dalam radius 100 meter dari lokasi kantor (-6.200000, 106.816666)
2. 📸 Pengguna harus mengambil foto selfie sebagai bukti kehadiran

## 📱 Fitur Utama

### 1. Login Sederhana
- Login menggunakan email dan password (validasi lokal)
- Penyimpanan nama pengguna menggunakan SharedPreferences
- UI dengan animasi halus dan profesional

### 2. Halaman Absensi
- Menampilkan:
  - Nama pengguna
  - Tanggal dan waktu saat ini dalam bahasa Indonesia
  - Lokasi pengguna (koordinat)
  - Status absensi hari ini (sudah/belum absen)
- Validasi lokasi:
  - Menghitung jarak menggunakan formula Haversine
  - Hanya aktif jika berada dalam radius 100 meter dari kantor (-6.200000, 106.816666)
  - Indikator visual warna hijau/merah untuk status lokasi
- Pengambilan foto selfie:
  - Menggunakan kamera perangkat
  - Preview foto sebelum disimpan
  - Tombol hapus untuk mengganti foto
  - Kualitas foto diatur ke 70% untuk optimasi ukuran

### 3. Riwayat Absensi
- Menampilkan daftar absensi dengan:
  - Tanggal dan jam dalam bahasa Indonesia
  - Status lokasi (valid/tidak valid)
  - Thumbnail foto selfie
- Fitur filter berdasarkan bulan dan tahun
- Tampilan "empty state" ketika belum ada riwayat
- Garis pemisah antar item untuk keterbacaan yang baik

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

1. **Clone repository**:
   ```bash
   git clone https://github.com/abhisn15/absensi_app.git
   cd absensi_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```
   
   Atau gunakan tombol "Run" di IDE Anda (VS Code/Android Studio)

4. **Jika menggunakan perangkat fisik**:
   - Pastikan USB debugging diaktifkan di pengaturan developer
   - Sambungkan perangkat ke komputer
   - Pilih perangkat dari daftar perangkat yang tersedia

5. **Login menggunakan akun dummy**:
   - Email: `user@example.com`
   - Password: `password`

## 📱 Cara Menggunakan Aplikasi

### 1. Setelah Login
- Pengguna akan diarahkan ke halaman absensi utama
- Tunggu hingga lokasi terdeteksi (mungkin membutuhkan beberapa detik)
- Status lokasi akan ditampilkan dengan indikator visual

### 2. Melakukan Absensi
- Pastikan lokasi Anda valid (berada dalam radius 100 meter dari kantor)
- Klik tombol "Ambil Selfie" untuk mengambil foto
- Setelah foto diambil, tombol "Absen Sekarang" akan aktif jika lokasi valid
- Klik "Absen Sekarang" untuk menyimpan absensi
- Anda akan melihat notifikasi "Absensi berhasil disimpan!"

### 3. Melihat Riwayat Absensi
- Klik ikon sejarah (jam pasir) di pojok kanan atas
- Gunakan filter bulan/tahun dengan mengklik ikon filter
- Untuk menghapus filter, klik ikon "Clear" atau ikon filter lalu pilih "Semua"
- Untuk kembali ke halaman absensi, klik tombol kembali di app bar

## ⚠️ Catatan Penting Saat Pengujian

### Untuk Emulator Android
- Saat menggunakan emulator, Anda perlu mengatur koordinat lokasi manual
- Di Android Studio, buka "Extended Controls" (ikon ...) > Location
- Masukkan koordinat kantor: Latitude `-6.200000`, Longitude `106.816666`
- Untuk menguji lokasi valid, gunakan koordinat dengan jarak kurang dari 100 meter
  - Contoh koordinat valid: Latitude `-6.200050`, Longitude `106.816700`
  - Contoh koordinat tidak valid: Latitude `-6.190000`, Longitude `106.800000`

### Penanganan Izin
- Aplikasi memerlukan izin lokasi dan kamera
- Jika izin ditolak, aplikasi akan menampilkan panduan untuk mengaktifkannya
- Untuk mengaktifkan izin, buka Pengaturan > Aplikasi > Absensi App > Izin

### Reset Data Absensi
- Untuk menghapus semua data absensi dan kembali ke keadaan awal:
  - Hapus aplikasi dari perangkat
  - Atau jalankan perintah: `flutter clean` lalu `flutter run` ulang

## 📂 Struktur Direktori

```
absensi_app/
├── lib/
│   ├── main.dart                # Entry point aplikasi
│   ├── models/
│   │   └── absensi.dart         # Model data absensi
│   ├── screens/
│   │   ├── login_screen.dart    # Tampilan login dengan animasi
│   │   ├── absensi_screen.dart  # Tampilan absensi utama dengan validasi lokasi
│   │   └── riwayat_screen.dart  # Tampilan riwayat absensi dengan filter
│   └── ...
├── pubspec.yaml                 # Daftar dependencies
└── README.md                    # Dokumentasi ini
```

## ✅ Kriteria Penilaian yang Terpenuhi

- [x] **Fungsionalitas aplikasi berjalan baik**
  - Validasi lokasi dengan formula Haversine yang akurat
  - Pengambilan foto selfie sebagai bukti kehadiran
  - Penyimpanan data absensi ke SharedPreferences

- [x] **Struktur kode rapi, reusable, dan clean**
  - Pemisahan kode ke dalam file yang sesuai dengan fungsinya
  - Penggunaan widget reusable seperti _buildInputField
  - State management yang baik
  - Komentar kode yang jelas

- [x] **Penanganan izin lokasi & kamera**
  - Menangani semua skenario izin (granted, denied, permanently denied)
  - Panduan jelas untuk pengguna jika izin ditolak
  - Dialog yang informatif untuk pengaturan izin

- [x] **Tampilan sederhana tapi fungsional**
  - UI yang profesional dengan animasi halus
  - Responsif untuk berbagai ukuran layar
  - Error messages yang jelas dan tidak mengganggu

- [x] **Validasi lokasi dan foto dilakukan dengan benar**
  - Formula Haversine diimplementasikan dengan benar
  - Tombol absen hanya aktif ketika semua syarat terpenuhi
  - Validasi radius 100 meter bekerja dengan akurat

- [x] **Fitur tambahan yang meningkatkan nilai**
  - Format tanggal dalam bahasa Indonesia
  - Filter riwayat absensi berdasarkan bulan dan tahun
  - UI dengan animasi yang menarik dan profesional
  - 
## 💡 Tips Penggunaan

- Pastikan lokasi diaktifkan di perangkat Anda
- Untuk pengujian di emulator, atur koordinat lokasi secara manual
- Jika tombol absen tidak aktif, pastikan lokasi valid dan foto sudah diambil
- Aplikasi ini menggunakan SharedPreferences untuk penyimpanan lokal, sehingga data akan tetap ada setelah aplikasi ditutup
- Nama pengguna yang ditampilkan adalah "Abhi Surya Nugroho" (bisa disesuaikan di kode)
