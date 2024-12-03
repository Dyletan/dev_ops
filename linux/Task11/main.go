package main

import (
 "flag"
 "log"
 "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
 log.Println("Hello!!!!")
}

func main() {
 port := flag.String("port", "8080", "Port for the web server")
 flag.Parse()

 http.HandleFunc("/", handler)

 log.Println("Сервер запущен!")

 http.ListenAndServe(":"+*port, nil)
}