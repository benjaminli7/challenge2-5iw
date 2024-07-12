package models

import (
	"time"
)

type Hike struct {
	ID            uint      `gorm:"primaryKey" json:"id" example:"1"`
	CreatedAt     time.Time `json:"created_at" example:"2024-05-28T12:54:10.517438+02:00"`
	UpdatedAt     time.Time `json:"updated_at" example:"2024-05-28T12:54:10.517438+02:00"`
	Name          string    `gorm:"not null" json:"name" example:"Montagne du destin" validate:"required,max=100"`
	Description   string    `json:"description" example:"La rando de zinzin" validate:"required,max=500"`
	OrganizerID   uint      `json:"organizer_id" example:"1" validate:"required"`
	Difficulty    string    `json:"difficulty" example:"Intermediate" validate:"required,oneof=Easy Moderate Hard"`
	Duration      string    `json:"duration" example:"3 hours" validate:"required"`
	IsApproved    bool      `json:"is_approved" default:"false" example:"false"`
	Groups        []Group   `json:"groups"`
	Image         string    `json:"image" example:"hike_image.jpg"`
	GpxFile       string    `json:"gpx_file" example:"hike.gpx"`
	AverageRating float64   `json:"average_rating" gorm:"-"`
}
