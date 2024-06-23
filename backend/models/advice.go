package models

import (
	"time"
)

type Advice struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Rating      int	  	   `gorm:"not null" json:"rating"`
	Description string    `json:"description"`
	DonorID     uint      `json:"donor_id"`
	ReceiverID	uint      `json:"receiver_id"`
}
