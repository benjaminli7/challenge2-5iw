package main

import (
	"fmt"
	"net/http"
	"gorm.io/gorm"
    "gorm.io/driver/postgres"
	"backend/models"
	// "github.com/gin-gonic/gin"
	//"errors",
)
var db *gorm.DB
// type Form struct {
//     Email string `json:"email"`
// 	FirstName string `json:"first_name"`
// }

// var forms = []Form{
// 	{Email: "toto@gmail.com", FirstName: "toto"},
// 	{Email: "titi@gmail.com", FirstName: "titi"},
// }

// func getForms(c *gin.Context) {
// 	c.JSON(http.StatusOK, forms)
// }

// func getFormsByEmail(c *gin.Context){
// 	email := c.Param("email")
// 	for _, form := range forms {
// 		if form.Email == email {
// 			c.JSON(http.StatusOK, form)
// 			return
// 		}
// 	}
// 	c.JSON(http.StatusNotFound, gin.H{"error": "Form not found"})
// }
// func createForm(c *gin.Context) {
// 	var form Form
// 	if err := c.ShouldBindJSON(&form); err != nil {
// 		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
// 		return
// 	}
// 	forms = append(forms, form)
// 	c.JSON(http.StatusCreated, form)
// }
// func main() {
// 	r := gin.Default()
// 	r.GET("/forms", getForms)
// 	r.POST("/forms", createForm)
// 	r.Run("localhost:8080")
// }



func main() {
	fmt.Println("Hello, World!")
	initDB()
    // Définition des routes
    http.HandleFunc("/", handler)

    // Démarrage du serveur sur le port 8080
    fmt.Println("Serveur démarré sur le port 8080")
    http.ListenAndServe(":5000", nil)
}

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, World!")
}

func initDB() {
    // var err error
    // db, err = gorm.Open(mysql.Open("admin:challenge@tcp(127.0.0.1:8080)/challenge?charset=utf8mb4&parseTime=True&loc=Local"))
    // if err != nil {
    //     fmt.Println("Échec de la connexion à la base de données :", err)
    //     // Gérer l'erreur de connexion à la base de données
    // }

    // Vérifier la connexion à la base de données
    // err = db.DB().Ping()
    // if err != nil {
    //     fmt.Println("Échec de la vérification de la connexion à la base de données :", err)
    //     // Gérer l'erreur de ping à la base de données
    // }
    // Migration automatique des modèles vers la base de données
    // db.AutoMigrate(&User{}, &Article{}) // Exemple de migration automatique des modèles User et Article

	dsn := "host=localhost user=admin password=challenge dbname=challenge port=8080 sslmode=disable TimeZone=Asia/Shanghai"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Println("Failed to connect to database!")
	}
	fmt.Println("Connection to database established.", db)
	db.AutoMigrate(&User{})
}