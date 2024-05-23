package main

import (
	"backend/models"
	"backend/routes"
	"fmt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"log"
	"net/http"
)

var db *gorm.DB
var err error

func main() {
	initDB()
	r := routes.SetupRouter()

	// Servir le fichier swagger.yaml
	r.HandleFunc("/swagger.yaml", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "swagger.yaml")
	})

	// Servir Swagger UI
	r.PathPrefix("/swagger/").Handler(http.StripPrefix("/swagger/", http.FileServer(http.Dir("./swagger-ui/"))))

	log.Println("Server started on: http://localhost:5000")
	http.ListenAndServe(":5000", r)
}

func initDB() {
	dsn := "host=db user=admin password=challenge dbname=challenge port=5432 sslmode=disable"
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	fmt.Println("Connection to database established.")
	db.AutoMigrate(&models.User{}, &models.Trail{})
}
