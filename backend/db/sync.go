package db

import "backend/models"

func SyncDatabase() {
	if err := DB.AutoMigrate(&models.User{}, &models.Message{}, &models.Hike{}, &models.Advice{}, &models.Group{}, &models.GroupUser{}, &models.Review{}, &models.Subscription{}, &models.Options{}); err != nil {
		panic("Failed to migrate database: " + err.Error())
	}
	DB.Model(&models.Hike{}).Association("Groups").Clear()

	fixtures()
}

func fixtures() {
	initialData := []models.Options{
		{GoogleAPI: true, WeatherAPI: false},
	}

	for _, data := range initialData {
		var count int64
		DB.Model(&models.Options{}).Where("google_api = ? AND weather_api = ?", data.GoogleAPI, data.WeatherAPI).Count(&count)
		if count == 0 {
			DB.Create(&data)
		}
	}
}
