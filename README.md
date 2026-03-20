# 🎮 Game Tracker Mobile

Aplikasi mobile berbasis Flutter untuk eksplorasi data game menggunakan **RAWG API** dan manajemen daftar putar pribadi melalui **Custom Backend (Golang)**.

---

## 🛠️ Tech Stack

| Komponen | Teknologi |
|---|---|
| **Frontend** | Flutter (Dart) |
| **Backend** | Go / Golang (Fiber/Gin) |
| **Database** | MySQL |
| **Authentication** | JWT (JSON Web Token) |
| **Local Storage** | Shared Preferences |

---

## ⚙️ Environment Setup (Penting!)

Proyek ini menggunakan variabel environment untuk menjaga keamanan API Key. **File `.env` tidak disertakan dalam repository ini.**

1. Buat file bernama `.env` di root project (sejajar dengan `pubspec.yaml`).
2. Masukkan API Key RAWG lu dengan format:
   ```env
   RAWG_API_KEY=your_alphanumeric_key_here
3. Pastikan flutter_dotenv sudah terdaftar di pubspec.yaml bagian assets.

🔌 API Integration
Aplikasi ini mengintegrasikan dua sumber data berbeda:

1. Public API (RAWG.io)
Digunakan untuk fetch data game secara global:

GET /games (Daftar game populer)

GET /games/{id} (Detail spesifik game)

2. Private API (Golang Backend)
Digunakan untuk fitur user dan tracker:

POST /api/register & POST /api/login

GET /api/tracker/mygames (Membutuhkan Bearer Token JWT)

POST /api/tracker/add (Menambah game ke database MySQL)

🚀 Instalasi & Cara Menjalankan

# 1. Clone repository
git clone [https://github.com/username_lu/nama_repo_lu.git](https://github.com/username_lu/nama_repo_lu.git)

# 2. Masuk ke direktori
cd nama_folder_project

# 3. Install dependencies
flutter pub get

# 4. Pastikan file .env sudah dikonfigurasi

# 5. Jalankan aplikasi
flutter run


🔒 Security & Best Practices
[x] Secure API Key: Menggunakan .env agar kredensial tidak bocor ke GitHub.

[x] JWT Auth: Token disimpan di local storage untuk sesi login yang aman.

[x] Clean Git: Folder build/, .dart_tool/, dan file .env sudah masuk dalam .gitignore.