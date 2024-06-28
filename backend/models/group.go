package models

import (
	"time"
)

type Group struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Description string    `json:"description"`
	StartDate   time.Time `json:"start_date"`
	Users		[]User    `gorm:"many2many:group_users" json:"users"`
	HikeID		uint      `json:"hike_id"`
	OrganizerID uint      `json:"organizer_id"`
}
