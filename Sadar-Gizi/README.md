# SadarGizi - Sistem labeling kadar gula dan Tracking nutrisi 

## Prasyarat
Sebelum menjalankan aplikasi ini, pastikan Anda telah menginstal:

Flutter SDK (versi minimal yang diperlukan, contoh: 3.0.0 atau lebih baru)
Dart SDK
Android Studio / VS Code
Android SDK / Xcode (untuk iOS)

### 1. Clone Repository

```bash
git clone https://github.com/username/nama-repository.git
cd nama-repository
```

### 2. Install Dependencies

```bash
flutter pub get
flutter pub add tflite_flutter
flutter pub add image
flutter pub add google_mlkit_text_recognition
```

### 3. Jalankan Aplikasi

Bukan VSCode menjalankan di emulator/simulator:

```bash
flutter run
```

### 4. Build APK (Android)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK per ABI (ukuran lebih kecil)
flutter build apk --split-per-abi
```

File APK akan tersedia di: `build/app/outputs/flutter-apk/`

### 5. Build App Bundle (Android - untuk Play Store)

```bash
flutter build appbundle --release
```

### 6. Build iOS

```bash
flutter build ios --release
```

Untuk menjalankan di device spesifik:

```bash
flutter devices  # Lihat daftar device yang tersedia
flutter run -d <device_id>
```
### 7. Cara Mencoba Aplikasi

Setelah mekalakukan jalankan aplikasi via device android

### Pertama Kali Membuka Aplikasi

1. **Splash Screen / Onboarding**
   - Anda akan disambut dengan splash screen aplikasi
   - Lalu disambut dibagian home

2. **Login / Registrasi**
   - Pilih "Daftar" untuk membuat akun baru dengan memasukkan beberapa kriteria yang dibutuhkan untuk pembuatan akun
   - Atau "Masuk" jika sudah memiliki akun dengan email password atau "Masuk" lewat akun google
   - 

### Fitur Utama

#### 1. Scan Nutrisionfact
- **Cara Mengakses**: Tap icon Scan pada widget ditengah bawah di menu utama / navigation bar
- **Fungsi**: Untuk melakukan scan nutrifact pada makanan dan minuman lalu muncul hasil nutrisinya 
- **Langkah Penggunaan**:
  1. Pilih gambar dari galery atau bisa foto langsung
  2. Setelah itu bisa melakukan pencet tombol Nutrisi untuk mengekstrak hasil foto
  3. Lalu anda mendapatkan hasil scan makanan minuman kalian
- **Tips**: Pilih gambar yg bagus tidak blus dan jelas

#### 2. Tracking Nutrisi yang Dikonsumsi
- **Cara Mengakses**: Kemenu bagian list product lalu muncul hasil scan kalian sebelumnya
- **Fungsi**: Untuk mengetahui hasil scan yg dikonsumsi atau tidak
- **Langkah Penggunaan**:
  1. Setalah melakukan scan dan menekan tombol add selanjutnya pencet tombol navigation product list
  2. Setalah itu muncul produk kalian yg sudah discan disitu ada dua pilihan untuk membuah atau menambahkan untuk tracking nutisi harian

#### 3. Fun Fact Fitur
- **Cara Mengakses**: Kebagian navigasi pencet tombol Fun Fact
- **Fungsi**: Sebuah halaman untuk membaca fun fact tentang dunia kesehatan
- **Langkah Penggunaan**:
  1. Kebagian navigasi pencet tombol Fun Fact
  2. Lalu kalian tinggal slide untuk membaca

### Navigasi Aplikasi

- **Home**: Berisi tentang tracking harian anda berupa dashboard
- **Product List**: Berisi tentang produk yang sudah anda tambahkan
- **Scan**: Untuk scaning nutrisionfact untuk mengetahui nutrisinya
- **FunFact**: Halaman untuk membaca funfact dunia kesehatan
- **Profile/Settings**: Halaman untuk mengubah data diri anda dan logout
