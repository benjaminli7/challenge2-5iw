package models

import (
	"time"
)

type Subscription struct {
	ID        uint      `gorm:"primaryKey" json:"id" example:"1"`
	UserID    uint      `json:"user_id" example:"1" validate:"required"`
	HikeID    uint      `json:"hike_id" example:"1" validate:"required"`
	CreatedAt time.Time `json:"created_at" example:"2024-05-28T12:54:10.517438+02:00"`
}
