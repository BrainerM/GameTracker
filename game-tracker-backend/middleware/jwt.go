package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

// Samakan key ini dengan yang ada di auth.go
var jwtKey = []byte("rahasia_twin_123")

func VerifyToken(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if !strings.Contains(authHeader, "Bearer") {
			http.Error(w, "Token tidak valid atau tidak ada", http.StatusUnauthorized)
			return
		}

		// Ambil tokennya saja tanpa kata "Bearer "
		tokenString := strings.Replace(authHeader, "Bearer ", "", 1)
		claims := &jwt.RegisteredClaims{}

		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})

		if err != nil || !token.Valid {
			http.Error(w, "Token ditolak", http.StatusUnauthorized)
			return
		}

		// Simpan username dari token ke dalam context request
		ctx := context.WithValue(r.Context(), "username", claims.Subject)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
