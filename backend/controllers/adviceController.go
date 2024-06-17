package controllers

import (
	"backend/db"
	"backend/models"
	"github.com/gin-gonic/gin"
	"net/http"
)

// CreateAdvice godoc
// @Summary Create a new advice
// @Description Create a new advice
// @Tags advice
// @Accept json
// @Produce json
// @Param advice body models.Advice true "Create advice"
// @Success 200 {object} models.Advice
// @Failure 400 {object} models.ErrorResponse
// @Router /advice [post]
func CreateAdvice(c *gin.Context) {

	var body struct {
		Donor_id  uint
		Description string
		Rating int
		Receiver_id uint
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	advice := models.Advice{DonorID: body.Donor_id, Description: body.Description, Rating: body.Rating, ReceiverID: body.Receiver_id}

	result := db.DB.Create(&advice)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest,gin.H{
			"error": "Failed to create advice.",
		})
		return
	}
	

	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Advice created successfully"})

}

// GetAdviceByReceiver godoc
// @Summary Get advice by receiver
// @Description Get advice by receiver
// @Tags advice
// @Accept json
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} models.Advice
// @Failure 400 {object} models.ErrorResponse
// @Router /advice/{id}/receiver [get]
func GetAdviceByReceiver(c *gin.Context) {
	id := c.Param("id")
	var advice []models.Advice
	result := db.DB.Where("receiver_id = ?", id).Find(&advice)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest,gin.H{
			"error": "Failed to get advice.",
		})
		return
	}
	c.JSON(http.StatusOK, advice)
}

// GetAdviceByDonor godoc
// @Summary Get advice by donor
// @Description Get advice by donor
// @Tags advice
// @Accept json
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} models.Advice
// @Failure 400 {object} models.ErrorResponse
// @Router /advice/{id}/donor [get]
func GetAdviceByDonor(c *gin.Context) {
	id := c.Param("id")
	var advice []models.Advice
	result := db.DB.Where("donor_id = ?", id).Find(&advice)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest,gin.H{
			"error": "Failed to get advice.",
		})
		return
	}
	c.JSON(http.StatusOK, advice)
}

// UpdateAdvice godoc
// @Summary Update advice
// @Description Update advice
// @Tags advice
// @Accept json
// @Produce json
// @Param id path int true "Advice ID"
// @Param advice body models.Advice true "Update advice"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /advice/{id} [patch]
func UpdateAdvice(c *gin.Context) {
	id := c.Param("id")
	var body struct {
		Description string
		Rating int
	}
	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}
	var advice models.Advice
	result := db.DB.First(&advice, id)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Advice not found"})
		return
	}
	advice.Description = body.Description
	advice.Rating = body.Rating
	db.DB.Save(&advice)
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Advice updated successfully"})
}

// DeleteAdvice godoc
// @Summary Delete advice
// @Description Delete advice
// @Tags advice
// @Accept json
// @Produce json
// @Param id path int true "Advice ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /advice/{id} [delete]
func DeleteAdvice(c *gin.Context) {
	id := c.Param("id")
	var advice models.Advice
	result := db.DB.First(&advice, id)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Advice not found"})
		return
	}
	db.DB.Delete(&advice)
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Advice deleted successfully"})
}