package models

import (
	"time"
)

type Hike struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Name        string    `gorm:"not null" json:"name"`
	Description string    `json:"description"`
	OrganizerID uint      `json:"organizer_id"`
}
