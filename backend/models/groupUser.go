package models

import (
	"gorm.io/gorm"
)

type GroupUser struct {
	gorm.Model
	UserID   	uint `gorm:"primaryKey"`  
	GroupID   	uint `gorm:"primaryKey"`  
	IsValidate 	bool `gorm:"default:false" json:"validate"`    
	User     	User `gorm:"foreignKey:UserID"` 
	Group     	Group `gorm:"foreignKey:GroupID"` 
}
