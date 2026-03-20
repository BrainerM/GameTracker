package main

import (
	"log"
	"net/http"

	"game-tracker-backend/config"
	"game-tracker-backend/handlers"
	"game-tracker-backend/middleware"

	"github.com/gorilla/mux"
)

func main() {
	config.ConnectDB()
	r := mux.NewRouter()

	r.HandleFunc("/api/register", handlers.Register).Methods("POST")
	r.HandleFunc("/api/login", handlers.Login).Methods("POST")

	trackerRoutes := r.PathPrefix("/api/tracker").Subrouter()
	trackerRoutes.Use(middleware.VerifyToken)
	trackerRoutes.HandleFunc("/add", handlers.AddGame).Methods("POST")
	trackerRoutes.HandleFunc("/mygames", handlers.GetMyGames).Methods("GET")

	// --- ROUTE BARU BUAT UPDATE & DELETE ---
	trackerRoutes.HandleFunc("/update/{id}", handlers.UpdateGameStatus).Methods("PUT")
	trackerRoutes.HandleFunc("/delete/{id}", handlers.DeleteGame).Methods("DELETE")

	log.Println("Server jalan di port 8091...")
	log.Fatal(http.ListenAndServe(":8091", r))
}
