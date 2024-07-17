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
	result := db.DB.Save(&options)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}
	c.JSON(http.StatusOK, options)
}
