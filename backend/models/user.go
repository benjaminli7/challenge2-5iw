package models

import (
	"time"
)

type User struct {
	ID         uint       `gorm:"primaryKey" json:"id"`
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
	DeletedAt  *time.Time `gorm:"index" json:"deleted_at,omitempty"`
	Email      string     `gorm:"unique" json:"email"`
	Password   string     `gorm:"not null" json:"password"`
	Role       string     `gorm:"default:user" json:"role"`
	Token      string     `json:"token"`
	IsVerified bool       `gorm:"default:false" json:"is_verified"`
}
