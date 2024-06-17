package test

import (
	"backend/db"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/joho/godotenv"
)

func TestMain(m *testing.M) {
	_, filename, _, _ := runtime.Caller(0)
	dir := filepath.Join(filepath.Dir(filename), "../")
	err := os.Chdir(dir)
	if err != nil {
		log.Fatalf("Failed to change working directory: %v", err)
	}

	wd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Current working directory in TestMain:", wd)

	envPath := filepath.Join(wd, ".env.test")
	fmt.Println("Loading .env.test from:", envPath)
	err = godotenv.Load(envPath)
	if err != nil {
		log.Fatalf("Error loading .env.test file: %v", err)
	}

	db.TestDatabaseInit()

	// Run tests
	code := m.Run()

	db.TestDatabaseDestroy()
	os.Exit(code)
}
