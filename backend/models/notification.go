package models

import (
	"gorm.io/gorm"
)

type Notification struct {
	gorm.Model
	UserID  uint
	Subject string
	Message string
	IsRead  bool `gorm:"default:false" json:"read"`
	User    User `gorm:"foreignKey:UserID "`
}
