package models

import "gorm.io/gorm"

type Message struct {
    gorm.Model
    UserID  uint
    GroupID uint
    Content string
    User    User
}