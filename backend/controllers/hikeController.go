package controllers

import (
	"backend/db"
	"backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// CreateHike godoc
// @Summary Create a new hike
// @Description Create a new hike with the input payload
// @Tags hikes
// @Accept json
// @Produce json
// @Param hike body models.Hike true "Hike Info"
// @Success 200 {object} models.Hike
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes [post]
func CreateHike(c *gin.Context) {
	var hike models.Hike
	if err := c.ShouldBindJSON(&hike); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := db.DB.Create(&hike).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, hike)
}

// GetAllHikes godoc
// @Summary Get all hikes
// @Description Get details of all hikes
// @Tags hikes
// @Accept json
// @Produce json
// @Success 200 {array} models.Hike
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes [get]
func GetAllHikes(c *gin.Context) {
	var hikes []models.Hike
	if err := db.DB.Find(&hikes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, hikes)
}

// GetHike godoc
// @Summary Get a hike by ID
// @Description Get details of a hike by its ID
// @Tags hikes
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Success 200 {object} models.Hike
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes/{id} [get]
func GetHike(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var hike models.Hike
	if err := db.DB.First(&hike, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, hike)
}

// UpdateHike godoc
// @Summary Update a hike by ID
// @Description Update details of a hike by its ID
// @Tags hikes
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Param hike body models.Hike true "Hike Info"
// @Success 200 {object} models.Hike
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes/{id} [put]
func UpdateHike(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var hike models.Hike
	if err := db.DB.First(&hike, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := c.ShouldBindJSON(&hike); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := db.DB.Save(&hike).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, hike)
}

// DeleteHike godoc
// @Summary Delete a hike by ID
// @Description Delete a hike by its ID
// @Tags hikes
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes/{id} [delete]
func DeleteHike(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := db.DB.Delete(&models.Hike{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Hike deleted"})
}

// ValidateHike godoc
// @Summary Validate a hike by ID
// @Description Validate a hike by its ID
// @Tags hikes
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes/{id}/validate [patch]
func ValidateHike(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var hike models.Hike
	if err := db.DB.First(&hike, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	hike.IsApproved = true
	if err := db.DB.Save(&hike).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Hike validated"})
}

// getNoValitedHike godoc
// @Summary Get all hikes not validated
// @Description Get details of all hikes not validated
// @Tags hikes
// @Accept json
// @Produce json
// @Success 200 {array} models.Hike
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes/notValidated [get]
func GetNoValitedHike(c *gin.Context) {
	var hikes []models.Hike
	if err := db.DB.Where("is_approved = ?", false).Find(&hikes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, hikes)
}