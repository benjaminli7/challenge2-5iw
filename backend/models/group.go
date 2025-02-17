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
	Name        string    `json:"name"`
	Users       []*User   `gorm:"many2many:group_users;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	HikeID      uint      `json:"hike_id" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Hike        Hike      `json:"hike" gorm:"foreignKey:HikeID "`
	OrganizerID uint      `json:"organizer_id" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Organizer   User      `json:"organizer" gorm:"foreignKey:OrganizerID; constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Materials []Material `gorm:"foreignKey:GroupID; constraint:OnUpdate:CASCADE,OnDelete:CASCADE`
	Messages    []Message `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
  	GroupImages []GroupImage `json:"group_images" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	MaxUsers    int       `json:"max_users"`
}
