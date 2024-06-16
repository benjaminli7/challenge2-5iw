package db

import (
	"backend/models"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func TestDatabaseInit() {
	fmt.Println("Loading .env.test file")
	err := godotenv.Load(".env.test")
	if err != nil {
		log.Fatalf("Error loading .env.test file: %v", err)
	}

	dsn := os.Getenv("POSTGRES_DSN")
	fmt.Println("DSN:", dsn)
	fmt.Println("Connecting to test database")
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to test database: %v", err)
	} else {
		fmt.Println("Connected to test database successfully")
	}

	fmt.Println("Migrating test database")
	err = DB.AutoMigrate(&models.User{}, &models.Hike{})
	if err != nil {
		log.Fatalf("Failed to migrate test database: %v", err)
	} else {
		fmt.Println("Database migration completed successfully")
	}
}

func TestDatabaseDestroy() {
	fmt.Println("Closing test database connection")
	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatalf("Failed to get sqlDB: %v", err)
	}
	err = sqlDB.Close()
	if err != nil {
		log.Fatalf("Failed to close test database connection: %v", err)
	} else {
		fmt.Println("Test database connection closed successfully")
	}
}
