package handlers

import (
	"encoding/json"
	"net/http"

	"game-tracker-backend/config"
	"game-tracker-backend/models"

	"github.com/gorilla/mux"
)

func AddGame(w http.ResponseWriter, r *http.Request) {
	username := r.Context().Value("username").(string)
	var userID int
	err := config.DB.QueryRow("SELECT id FROM users WHERE username = ?", username).Scan(&userID)
	if err != nil {
		http.Error(w, "User tidak ditemukan", http.StatusUnauthorized)
		return
	}

	var game models.UserGame
	json.NewDecoder(r.Body).Decode(&game)

	if game.Status == "" {
		game.Status = "wishlist"
	}

	_, err = config.DB.Exec("INSERT INTO user_games (user_id, game_id, status) VALUES (?, ?, ?)", userID, game.GameID, game.Status)
	if err != nil {
		http.Error(w, "Gagal menambahkan game", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"message": "Game berhasil ditambahkan ke tracker!"})
}

func GetMyGames(w http.ResponseWriter, r *http.Request) {
	username := r.Context().Value("username").(string)
	var userID int
	config.DB.QueryRow("SELECT id FROM users WHERE username = ?", username).Scan(&userID)

	rows, err := config.DB.Query("SELECT id, game_id, status, added_at FROM user_games WHERE user_id = ?", userID)
	if err != nil {
		http.Error(w, "Gagal mengambil data", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var games []models.UserGame
	for rows.Next() {
		var g models.UserGame
		rows.Scan(&g.ID, &g.GameID, &g.Status, &g.AddedAt)
		g.UserID = userID
		games = append(games, g)
	}

	if games == nil {
		games = []models.UserGame{}
	}
	json.NewEncoder(w).Encode(games)
}

// --- FUNGSI BARU: UPDATE STATUS ---
func UpdateGameStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"] // Mengambil ID dari URL
	username := r.Context().Value("username").(string)

	var userID int
	config.DB.QueryRow("SELECT id FROM users WHERE username = ?", username).Scan(&userID)

	var reqBody struct {
		Status string `json:"status"`
	}
	json.NewDecoder(r.Body).Decode(&reqBody)

	// Update status di MySQL
	_, err := config.DB.Exec("UPDATE user_games SET status = ? WHERE id = ? AND user_id = ?", reqBody.Status, id, userID)
	if err != nil {
		http.Error(w, "Gagal update status", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Status berhasil diupdate!"})
}

// --- FUNGSI BARU: HAPUS GAME ---
func DeleteGame(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"] // Mengambil ID dari URL
	username := r.Context().Value("username").(string)

	var userID int
	config.DB.QueryRow("SELECT id FROM users WHERE username = ?", username).Scan(&userID)

	// Hapus dari MySQL
	_, err := config.DB.Exec("DELETE FROM user_games WHERE id = ? AND user_id = ?", id, userID)
	if err != nil {
		http.Error(w, "Gagal menghapus game", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Game berhasil dihapus!"})
}
