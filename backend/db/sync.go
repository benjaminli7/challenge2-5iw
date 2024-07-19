package db

import (
	"backend/models"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

func SyncDatabase() {
	if err := DB.AutoMigrate(
		&models.User{},
		&models.Material{},
		&models.MaterialUser{},
		&models.Message{},
		&models.Hike{},
		&models.Advice{},
		&models.Group{},
		&models.GroupUser{},
		&models.Review{},
		&models.Options{},
		&models.Subscription{},
		&models.GroupImage{}); err != nil {
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
	//importDataFromJSON("fixtures_data/users.json", &[]models.User{})
	//importDataFromJSON("fixtures_data/hikes.json", &[]models.Hike{})
	//importDataFromJSON("fixtures_data/group.json", &[]models.Group{})
	//importDataFromJSON("fixtures_data/groupUser.json", &[]models.GroupUser{})
	//importDataFromJSON("fixtures_data/review.json", &[]models.Review{})

}

func importDataFromJSON[T any](filePath string, model *[]T) {
	jsonFile, err := os.Open(filePath)
	if err != nil {
		log.Printf("Failed to open JSON file %s: %v\n", filePath, err)
		return
	}
	defer jsonFile.Close()

	byteValue, err := ioutil.ReadAll(jsonFile)
	if err != nil {
		log.Printf("Failed to read JSON file %s: %v\n", filePath, err)
		return
	}

	err = json.Unmarshal(byteValue, model)
	if err != nil {
		log.Printf("Failed to unmarshal JSON data from %s: %v\n", filePath, err)
		return
	}

	for _, data := range *model {
		DB.Create(&data)
	}

	fmt.Printf("Imported data from %s successfully\n", filePath)
}
