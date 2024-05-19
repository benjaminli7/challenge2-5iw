package models

import "gorm.io/gorm"

type User struct {
	gorm.Model
	FirstName string `gorm:"size:255;not null"`
	LastName  string `gorm:"size:255;not null"`
	Email     string `gorm:"size:255;not null;unique"`
	Password  string `gorm:"size:255;not null"`
	Role      string `gorm:"size:50;not null"` // admin, moderator, user
}
