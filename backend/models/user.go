package models

import "gorm.io/gorm"

type User struct{
	gorm.Model
	Email string	`gorm:"unique"`
	Password string `gorm:"not null"`
	Role string `gorm:"default:user"`
	Token string `gorm:"unique"`
	IsVerified bool `gorm:"default:false"`
}