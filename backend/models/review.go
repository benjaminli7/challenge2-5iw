package models

import (
	"time"
)

type Review struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at" time_format:"2006-01-02T15:04:05Z07:00"`
	UpdatedAt time.Time `json:"updated_at" time_format:"2006-01-02T15:04:05Z07:00"`
	UserID    uint      `json:"user_id" validate:"required"`
	User      User      `json:"user" gorm:"foreignKey:UserID"`
	HikeID    uint      `json:"hike_id" validate:"required"`
	Rating    int       `json:"rating" validate:"required,min=1,max=5"`
	Comment   string    `json:"comment" validate:"max=280"`
}
