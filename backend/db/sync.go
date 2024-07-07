package db

import "backend/models"

func SyncDatabase() {
	if err := DB.AutoMigrate(&models.User{}, &models.Hike{}, &models.Advice{}, &models.Group{}, &models.GroupUser{}, &models.Review{}); err != nil {
		panic("Failed to migrate database: " + err.Error())
	}
	DB.Model(&models.Hike{}).Association("Groups").Clear()
}
