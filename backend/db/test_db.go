package db

import (
	"backend/models"
	"database/sql"
	"log"
	"os"

	_ "github.com/lib/pq"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var TestDB *gorm.DB

func TestDatabaseInit() {
	var err error

	dsn := os.Getenv("POSTGRES_DSN")
	conn, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	_, err = conn.Exec("CREATE DATABASE test_db")
	if err != nil {
		log.Fatal(err)
	}

	testDSN := dsn + " dbname=test_db"
	TestDB, err = gorm.Open(postgres.Open(testDSN), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}

	TestDB.AutoMigrate(&models.User{}, &models.Hike{})
}

func TestDatabaseDestroy() {
	var err error

	sqlDB, err := TestDB.DB()
	if err != nil {
		log.Fatal(err)
	}
	sqlDB.Close()

	dsn := os.Getenv("POSTGRES_DSN")
	conn, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	_, err = conn.Exec("DROP DATABASE test_db")
	if err != nil {
		log.Fatal(err)
	}
}
