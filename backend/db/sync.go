package db

import "backend/models"

func SyncDatabase() {
	DB.AutoMigrate(&models.User{}, &models.Hike{}, &models.Advice{})
}
