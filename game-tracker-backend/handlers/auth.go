package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"time"

	"game-tracker-backend/config"
	"game-tracker-backend/models"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// Secret key buat JWT (ideal-nya simpan di file .env, tapi untuk sekarang kita hardcode dulu)
var jwtKey = []byte("rahasia_twin_123")

// REGISTER
func Register(w http.ResponseWriter, r *http.Request) {
	var user struct {
		Username string `json:"username"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	json.NewDecoder(r.Body).Decode(&user)

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Gagal mengamankan password", http.StatusInternalServerError)
		return
	}

	// Insert ke database
	_, err = config.DB.Exec("INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)", user.Username, user.Email, string(hashedPassword))
	if err != nil {
		http.Error(w, "Email atau Username sudah terdaftar", http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"message": "Register berhasil!"})
}

// LOGIN
func Login(w http.ResponseWriter, r *http.Request) {
	var creds models.LoginCredentials
	json.NewDecoder(r.Body).Decode(&creds)

	var storedUser models.User
	err := config.DB.QueryRow("SELECT id, username, password_hash FROM users WHERE email = ?", creds.Email).Scan(&storedUser.ID, &storedUser.Username, &storedUser.PasswordHash)

	if err == sql.ErrNoRows {
		http.Error(w, "User tidak ditemukan", http.StatusUnauthorized)
		return
	}

	// Cek kecocokan password
	err = bcrypt.CompareHashAndPassword([]byte(storedUser.PasswordHash), []byte(creds.Password))
	if err != nil {
		http.Error(w, "Password salah", http.StatusUnauthorized)
		return
	}

	// Generate JWT Token
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &jwt.RegisteredClaims{
		Subject:   storedUser.Username,
		ExpiresAt: jwt.NewNumericDate(expirationTime),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		http.Error(w, "Gagal membuat token", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{"token": tokenString})
}
