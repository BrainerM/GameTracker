package models

type User struct {
	ID           int    `json:"id"`
	Username     string `json:"username"`
	Email        string `json:"email"`
	PasswordHash string `json:"-"` // "-" artinya password hash nggak akan dikirim balik ke frontend via JSON
}

type UserGame struct {
	ID      int    `json:"id"`
	UserID  int    `json:"user_id"`
	GameID  int    `json:"game_id"` // Dari API Publik
	Status  string `json:"status"`
	AddedAt string `json:"added_at"`
}

// Struct tambahan buat nerima data login
type LoginCredentials struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
