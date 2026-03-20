package config

import (
	"database/sql"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

var DB *sql.DB

func ConnectDB() {
	// Format: username:password@tcp(host:port)/dbname
	// Pastikan username "root" dan password "" (kosong) sesuai dengan settingan MySQL/XAMPP kamu.
	dsn := "root:@tcp(127.0.0.1:3306)/game_tracker_db?parseTime=true"

	var err error
	DB, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Fatal("Gagal membuka koneksi ke database:", err)
	}

	if err = DB.Ping(); err != nil {
		log.Fatal("Database tidak merespons:", err)
	}

	log.Println("Koneksi ke MySQL game_tracker_db berhasil!")
}
