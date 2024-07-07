package models

import (
	"time"
)

type Review struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	UserID    uint      `json:"user_id" validate:"required"`
	HikeID    uint      `json:"hike_id" validate:"required"`
	Rating    int       `json:"rating" validate:"required,min=1,max=5"`
	Comment   string    `json:"comment" validate:"max=280"`
}
