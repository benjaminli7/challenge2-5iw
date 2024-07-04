package models

import (
	"gorm.io/gorm"
)

type GroupUser struct {
	gorm.Model
 	UserID  uint
    GroupID uint
	IsValidate 	bool `gorm:"default:false" json:"validate"`    
	User     	User `gorm:"foreignKey:UserID "` 
	Group     	Group `gorm:"foreignKey:GroupID"` 
}
