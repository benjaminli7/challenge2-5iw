package db

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

func LoadEnvVariables() {
	if os.Getenv("TEST_MODE") == "true" {
		err := godotenv.Load(".env.test")
		if err != nil {
			log.Fatalf("Error loading .env.test file: %v", err)
		}
	} else {
		err := godotenv.Load(".env")
		if err != nil {
			log.Fatal("Error loading .env file")
		}
	}
}
