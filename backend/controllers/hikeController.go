package controllers

import (
	"backend/db"
	"backend/models"
	"github.com/gin-gonic/gin"
	"net/http"
)

// CreateHike godoc
// @Summary Create a new hike
// @Description Create a new hike
// @Tags hikes
// @Accept json
// @Produce json
// @Param hike body models.Hike true "Create hike"
// @Success 200 {object} models.Hike
// @Failure 400 {object} models.ErrorResponse
// @Router /hikes [post]
func CreateHike(c *gin.Context) {
	var hike models.Hike
	if err := c.ShouldBindJSON(&hike); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid request"})
		return
	}
	if err := db.DB.Create(&hike).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to create hike"})
		return
	}
	c.JSON(http.StatusOK, hike)
}

// GetAllHikes godoc
// @Summary Get all hikes
// @Description Get all hikes
// @Tags hikes
// @Accept json
// @Produce json
// @Success 200 {array} models.Hike
// @Router /hikes [get]
func GetAllHikes(c *gin.Context) {
	var hikes []models.Hike
	if err := db.DB.Find(&hikes).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to get hikes"})
		return
	}
	c.JSON(http.StatusOK, hikes)
}

// GetHike godoc
// @Summary Get a single hike
// @Description Get a single hike by ID
// @Tags hikes
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Success 200 {object} models.Hike
// @Failure 400 {object} models.ErrorResponse
// @Router /hikes/{id} [get]
func GetHike(c *gin.Context) {
	id := c.Param("id")
	var hike models.Hike
	if err := db.DB.First(&hike, id).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Hike not found"})
		return
	}
	c.JSON(http.StatusOK, hike)
}

// UpdateHike godoc
// @Summary Update an hike
// @Description Update an hike by ID
// @Tags hikes
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Param hike body models.Hike true "Update hike"
// @Success 200 {object} models.Hike
// @Failure 400 {object} models.ErrorResponse
// @Router /hikes/{id} [put]
func UpdateHike(c *gin.Context) {
	id := c.Param("id")
	var hike models.Hike
	if err := db.DB.First(&hike, id).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Hike not found"})
		return
	}
	if err := c.ShouldBindJSON(&hike); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid request"})
		return
	}
	if err := db.DB.Save(&hike).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to update hike"})
		return
	}
	c.JSON(http.StatusOK, hike)
}

// DeleteHike godoc
// @Summary Delete an hike
// @Description Delete an hike by ID
// @Tags hikes
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /hikes/{id} [delete]
func DeleteHike(c *gin.Context) {
	id := c.Param("id")
	if err := db.DB.Delete(&models.Hike{}, id).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to delete hike"})
		return
	}
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Hike deleted successfully"})
}
