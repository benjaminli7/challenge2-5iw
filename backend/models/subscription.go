package models

import (
	"time"
)

type Subscription struct {
	ID        uint      `gorm:"primaryKey" json:"id" example:"1"`
	UserID    uint      `json:"user_id" example:"1" validate:"required" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	HikeID    uint      `json:"hike_id" example:"1" validate:"required" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Hike      Hike      `json:"hike" gorm:"foreignKey:HikeID"`
	User      User      `json:"user" gorm:"foreignKey:UserID"`
	CreatedAt time.Time `json:"created_at" example:"2024-05-28T12:54:10.517438+02:00"`
}
