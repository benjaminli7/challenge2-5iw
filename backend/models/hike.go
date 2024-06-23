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
	Image       string    `json:"image"`
	Location    string    `json:"location"`
	Difficulty  int       `gorm:"check:(difficulty IS NULL) OR (difficulty >= 1 AND difficulty <= 5)"`
	StartDate   time.Time `json:"start_date"`
	EndDate     time.Time `json:"end_date"`
	OrganizerID uint      `json:"organizer_id"`
}
