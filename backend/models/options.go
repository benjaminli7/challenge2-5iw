package models

import "gorm.io/gorm"

type Options struct {
	gorm.Model
	GoogleAPI  bool `json:"google_api"`
	WeatherAPI bool `json:"weather_api"`
}
