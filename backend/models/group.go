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
	Users 		[]*User `gorm:"many2many:group_users;"`
	HikeID      uint      `json:"hike_id"`
	Hike        Hike      `json:"hike" gorm:"foreignKey:HikeID"`
	OrganizerID uint      `json:"organizer_id"`
	Organizer   User      `json:"organizer" gorm:"foreignKey:OrganizerID"`
	Messages []Message
}
