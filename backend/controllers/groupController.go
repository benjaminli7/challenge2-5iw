package controllers

import (
	"backend/db"
	"backend/models"
	"net/http"
	"strconv"
	"github.com/gin-gonic/gin"
)

// CreateGroup godoc
// @Summary Create a new group
// @Description Create a new group with the input payload
// @Tags groups
// @Accept json
// @Produce json
// @Param group body models.Group true "Group Info"
// @Success 200 {object} models.Group
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /groups [post]
func CreateGroup(c *gin.Context) {
	var group models.Group
	if err := c.ShouldBindJSON(&group); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := db.DB.Create(&group).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, group)
}


// GetGroup godoc
// @Summary Get a group by ID
// @Description Get details of a group by its ID
// @Tags groups
// @Accept json
// @Produce json
// @Param id path int true "Group ID"
// @Success 200 {object} models.Group
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/{id} [get]
func GetGroup(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var group models.Group
	if err := db.DB.First(&group, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, group)
}

// UpdateGroup godoc
// @Summary Update a group by ID
// @Description Update details of a group by its ID
// @Tags groups
// @Accept json
// @Produce json
// @Param id path int true "Group ID"
// @Param group body models.Group true "Group Info"
// @Success 200 {object} models.Group
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/{id} [patch]
func UpdateGroup(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var group models.Group
	if err := db.DB.First(&group, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := c.ShouldBindJSON(&group); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := db.DB.Save(&group).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, group)
}

// DeleteGroup godoc
// @Summary Delete a group by ID
// @Description Delete a group by its ID
// @Tags groups
// @Accept json
// @Produce json
// @Param id path int true "Group ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/{id} [delete]
func DeleteGroup(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := db.DB.Delete(&models.Group{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Group deleted"})
}
