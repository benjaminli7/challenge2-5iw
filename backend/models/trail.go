package models

import "gorm.io/gorm"

type Trail struct {
	gorm.Model
	Name       string  `gorm:"size:255;not null"`
	Location   string  `gorm:"size:255;not null"`
	Distance   float64 `gorm:"not null"`
	Difficulty string  `gorm:"size:50;not null"`
}
