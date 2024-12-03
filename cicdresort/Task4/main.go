package main

import (
    "encoding/json"
    "log"
    "net/http"
    "os"
)

type Response struct {
    Status  string `json:"status"`
    Message string `json:"message"`
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
    response := Response{
        Status:  "ok",
        Message: "Сервис запущен и работает",
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8081"
    }

    http.HandleFunc("/health", healthCheck)

    log.Printf("Сервер запускается на порте %s", port)
    if err := http.ListenAndServe(":"+port, nil); err != nil {
        log.Fatal(err)
    }
}