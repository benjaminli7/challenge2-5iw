package models

import (
	"time"
)

type Review struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	UserID    uint      `json:"user_id"`
	HikeID    uint      `json:"hike_id"`
	Rating    int       `json:"rating"`
	Comment   string    `json:"comment"`
}
