package models

import "time"

type Material struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"not null"`
	GroupID   uint      `gorm:"not null"`
	Group     Group     `gorm:"foreignKey:GroupID"`
	Users  []User    `gorm:"many2many:material_users"`
	CreatedAt time.Time
	UpdatedAt time.Time
}


type MaterialUser struct {
	MaterialID uint `gorm:"primaryKey"`
	UserID     uint `gorm:"primaryKey"`
}

type MaterialRequest struct {
	Materials []string `json:"materials" binding:"required"`
}