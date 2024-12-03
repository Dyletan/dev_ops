// main.go
package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

type Config struct {
	DB     *sql.DB
	JWTKey []byte
}

type TokenRequest struct {
	ClientID     string `json:"client_id"`
	ClientSecret string `json:"client_secret"`
	GrantType    string `json:"grant_type"`
	Scope        string `json:"scope"`
}

type TokenResponse struct {
	AccessToken   string `json:"access_token"`
	ExpiresIn     int    `json:"expires_in"`
	RefreshToken  string `json:"refresh_token"`
	Scope         string `json:"scope"`
	SecurityLevel string `json:"security_level"`
	TokenType     string `json:"token_type"`
}

type CheckResponse struct {
	ClientID string `json:"ClientID"`
	Scope    string `json:"Scope"`
}

type Claims struct {
	ClientID string `json:"client_id"`
	Scope    string `json:"scope"`
	jwt.StandardClaims
}

func main() {
	// Load .env file
	// err := godotenv.Load("/app/.env")
	// if err != nil {
	// 	log.Fatalf("Error loading .env file: %v", err)
	// }

	dbHost := "db"
	dbPort := os.Getenv("POSTGRES_PORT")
	dbUser := os.Getenv("POSTGRES_USER")
	dbName := os.Getenv("POSTGRES_DB")
	// dbPassword := os.Getenv("POSTGRES_PASSWORD")

	// Create connection string
	// dbURI := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
    // dbUser, dbPassword, dbHost, dbPort, dbName)
	dbURI := fmt.Sprintf("postgres://%s@%s:%s/%s?sslmode=disable",
    dbUser, dbHost, dbPort, dbName)

	// Initialize DB connection
	db, err := sql.Open("postgres", dbURI)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatal("Could not connect to database:", err)
	}
	log.Println("Successfully connected to database")

	createTables(db)

	config := &Config{
		DB:     db,
		JWTKey: []byte(os.Getenv("JWT_SECRET_KEY")),
	}

	r := mux.NewRouter()
	log.Println("Starting server...")
	r.HandleFunc("/token", config.handleToken).Methods("POST")
	r.HandleFunc("/check", config.handleCheck).Methods("GET")

	log.Fatal(http.ListenAndServe(":8080", r))
}

func createTables(db *sql.DB) {
	// Create tokens table
	_, err := db.Exec(`
        CREATE TABLE IF NOT EXISTS tokens (
            id SERIAL PRIMARY KEY,
            client_id VARCHAR(255) NOT NULL,
            access_token TEXT NOT NULL,
            scope VARCHAR(255) NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP NOT NULL
        )
    `)
	if err != nil {
		log.Fatal(err)
	}
}

func (c *Config) handleToken(w http.ResponseWriter, r *http.Request) {
	var req TokenRequest

	// Check Content-Type header
	contentType := r.Header.Get("Content-Type")

	if strings.Contains(contentType, "application/json") {
		// Handle JSON request
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid JSON request body", http.StatusBadRequest)
			return
		}
	} else if strings.Contains(contentType, "application/x-www-form-urlencoded") {
		// Handle form data
		if err := r.ParseForm(); err != nil {
			http.Error(w, "Invalid form data", http.StatusBadRequest)
			return
		}

		req = TokenRequest{
			ClientID:     r.FormValue("client_id"),
			ClientSecret: r.FormValue("client_secret"),
			GrantType:    r.FormValue("grant_type"),
			Scope:        r.FormValue("scope"),
		}
	} else {
		http.Error(w, "Unsupported Content-Type. Use application/json or application/x-www-form-urlencoded", http.StatusBadRequest)
		return
	}

	// Create token
	expirationTime := time.Now().Add(2 * time.Hour)
	claims := &Claims{
		ClientID: req.ClientID,
		Scope:    req.Scope,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(c.JWTKey)
	if err != nil {
		http.Error(w, "Could not generate token", http.StatusInternalServerError)
		return
	}

	// Store token in database
	_, err = c.DB.Exec(`
        INSERT INTO tokens (client_id, access_token, scope, expires_at)
        VALUES ($1, $2, $3, $4)
    `, req.ClientID, tokenString, req.Scope, expirationTime)
	if err != nil {
		http.Error(w, "Could not store token", http.StatusInternalServerError)
		return
	}

	response := TokenResponse{
		AccessToken:   tokenString,
		ExpiresIn:     7200, // 2 hours in seconds
		RefreshToken:  "",   // Static value
		Scope:         req.Scope,
		SecurityLevel: "normal", // Static value
		TokenType:     "Bearer", // Static value
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (c *Config) handleCheck(w http.ResponseWriter, r *http.Request) {
	// Get token from Authorization header
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		http.Error(w, "Authorization header required", http.StatusUnauthorized)
		return
	}

	// Remove "Bearer " prefix
	tokenStr := strings.TrimPrefix(authHeader, "Bearer ")

	// Parse and validate token
	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return c.JWTKey, nil
	})

	if err != nil || !token.Valid {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	// Check if token exists in database and is not expired
	var exists bool
	err = c.DB.QueryRow(`
        SELECT EXISTS(
            SELECT 1 FROM tokens 
            WHERE access_token = $1 
            AND expires_at > CURRENT_TIMESTAMP
        )
    `, tokenStr).Scan(&exists)

	if err != nil || !exists {
		http.Error(w, "Token not found or expired", http.StatusUnauthorized)
		return
	}

	response := CheckResponse{
		ClientID: claims.ClientID,
		Scope:    claims.Scope,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
