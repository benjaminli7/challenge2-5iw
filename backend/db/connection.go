package db

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func ConnectToDb() {
	if os.Getenv("TEST_MODE") != "true" {
		err := godotenv.Load(".env")
		if err != nil {
			log.Println("Error loading .env file")
		}
	} else {
		err := godotenv.Load(".env.test")
		if err != nil {
			log.Fatalf("Error loading .env.test file: %v", err)
		}
	}

	dsn := os.Getenv("POSTGRES_DSN")
	if dsn == "" {
		log.Fatal("POSTGRES_DSN is not set")
	}
	fmt.Println("DSN:", dsn)
	var err error
	newLogger := logger.New(
		log.New(os.Stdout, "\r\n", log.LstdFlags),
		logger.Config{
		  SlowThreshold:              time.Second,   
		  LogLevel:                   logger.Silent, 
		  IgnoreRecordNotFoundError: true,           
		  ParameterizedQueries:      true,           
		  Colorful:                  false,         
		},
	  )
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: newLogger,
	})
	if err != nil {
		log.Fatal("Failed to connect to DB:", err)
	} else {
		fmt.Println("Connected to DB : ", DB)
	}
	
}
