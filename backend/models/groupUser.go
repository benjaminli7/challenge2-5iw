package models

import (
	"gorm.io/gorm"
)

type GroupUser struct {
	gorm.Model
 	UserID  uint
    GroupID uint
	IsValidate 	bool `gorm:"default:false" json:"validate"`    
	User     	User `gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"` 
	Group     	Group `gorm:"foreignKey:GroupID; constraint:OnUpdate:CASCADE,OnDelete:CASCADE"` 

}
