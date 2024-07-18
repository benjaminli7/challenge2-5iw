package controllers

import (
	"backend/db"
	"backend/models"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetOptions(c *gin.Context) {
	var options models.Options
	//get the option value in the database
	result := db.DB.First(&options)
	fmt.Println(options)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": result.Error.Error()})
		return
	}
	c.JSON(http.StatusOK, options)
}

func UpdateOptions(c *gin.Context) {
	var options models.Options
	err := c.ShouldBindJSON(&options)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	fmt.Println(options.WeatherAPI, options.GoogleAPI)

	// get tge first option value in the database
	var oldOptions models.Options
	result := db.DB.First(&oldOptions)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": result.Error.Error()})
		return
	}

	fmt.Println(oldOptions.WeatherAPI, oldOptions.GoogleAPI)
	// update the option value in the database with the new value

	// set the new value to the oldOptions
	oldOptions.WeatherAPI = options.WeatherAPI
	oldOptions.GoogleAPI = options.GoogleAPI

	result = db.DB.Save(&oldOptions)

	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(http.StatusOK, options)
}
