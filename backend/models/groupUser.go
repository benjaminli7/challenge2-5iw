package models

import (
	"gorm.io/gorm"
)

type GroupUser struct {
	gorm.Model
	UserID   uint `gorm:"primaryKey"`  
	GroupID   uint `gorm:"primaryKey"`  
	Validate bool `json:"validate"`    
	User     User `gorm:"foreignKey:UserID"` 
	Group     Group `gorm:"foreignKey:GroupID"` 
}
