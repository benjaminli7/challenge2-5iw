package models

import "time"

type GroupImage struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	GroupID   uint      `json:"group_id"`
	Group     Group     `json:"group" gorm:"foreignKey:GroupID"`
	UserID    uint      `json:"user_id"`
	User      User      `json:"user" gorm:"foreignKey:UserID"`
	Path      string    `json:"path"`
	CreatedAt time.Time `json:"created_at"`
}
