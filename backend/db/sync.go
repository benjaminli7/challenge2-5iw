package db

import "backend/models"

func SyncDatabase() {
	if err := DB.AutoMigrate(&models.User{}, &models.Hike{}, &models.Advice{}); err != nil {
		panic("Failed to migrate database: " + err.Error())
	}
}
