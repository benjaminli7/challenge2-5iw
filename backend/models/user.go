package models

import (
	"time"
)

type User struct {
	ID           uint       `gorm:"primaryKey" json:"id"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
	DeletedAt    *time.Time `gorm:"index" json:"deleted_at,omitempty"`
	Email        string     `gorm:"unique" json:"email"`
	Username     string     `gorm:"unique" json:"username"`
	Password     string     `gorm:"not null" json:"password"`
	Role         string     `gorm:"default:user" json:"role"`
	Token        string     `json:"token"`
	IsVerified   bool       `gorm:"default:false" json:"is_verified"`
	Donor        Advice     `gorm:"foreignKey:DonorID" json:"advice_donor" constraint:OnUpdate:CASCADE,OnDelete:CASCADE;`
	Receiver     Advice     `gorm:"foreignKey:ReceiverID" json:"advice_receiver" constraint:OnUpdate:CASCADE,OnDelete:CASCADE`
	Groups       []*Group   `gorm:"many2many:group_users; constraint:OnUpdate:CASCADE,OnDelete:CASCADE" `
	Materials    []Material `gorm:"many2many:material_users"; constraint:OnUpdate:CASCADE,OnDelete:CASCADE`
	ProfileImage string     `json:"profile_image,omitempty"`
	FcmToken     string     `json:"fcm_token,omitempty"`

}

type PasswordUpdate struct {
	OldPassword string `json:"old_password"`
	NewPassword string `json:"new_password"`
}
