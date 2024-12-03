package main

import (
	"fmt"
	"os"
)

func main() {
	secret := os.Getenv("PSWD")

	fmt.Println(secret)
}
