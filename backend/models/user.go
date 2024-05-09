package models

import "gorm.io/gorm"

type User struct {
	gorm.Model
	FirstName     	string	`gorm:"size:255;not null"`
	LastName	  	string  `gorm:"size:255;not null"`
	Email    		string	`gorm:"size:255;not null;unique"`
	Password 		string	`gorm:"size:255;not null"`
}
  

// func NewUser(name, email, password string) *User {
// 	return &User{
// 		Name:     name,
// 		Email:    email,
// 		Password: password,
// 	}
// }

func main() {
	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
	  panic("failed to connect database")
	}
  
	// Migrate the schema
	db.AutoMigrate(&User{})
  
	// Create
	// db.Create(&User{Code: "D42", Price: 100})
  
	// // Read
	// var product Product
	// db.First(&product, 1) // find product with integer primary key
	// db.First(&product, "code = ?", "D42") // find product with code D42
  
	// // Update - update product's price to 200
	// db.Model(&product).Update("Price", 200)
	// // Update - update multiple fields
	// db.Model(&product).Updates(Product{Price: 200, Code: "F42"}) // non-zero fields
	// db.Model(&product).Updates(map[string]interface{}{"Price": 200, "Code": "F42"})
  
	// // Delete - delete product
	// db.Delete(&product, 1)
  }
// Add any additional methods or functions related to the User model here