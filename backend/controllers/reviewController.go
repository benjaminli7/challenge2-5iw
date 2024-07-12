package controllers

import (
	"backend/db"
	"backend/models"
	"errors"
	"fmt"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
	"strconv"
)

// CreateReview godoc
// @Summary Create a new review
// @Description Create a new review for a hike
// @Tags reviews
// @Accept json
// @Produce json
// @Param review body models.Review true "Review"
// @Success 200 {object} models.Review
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /reviews [post]
func CreateReview(c *gin.Context) {
	var review models.Review
	if err := c.ShouldBindJSON(&review); err != nil {
		fmt.Println("Bind JSON Error:", err)
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	fmt.Printf("Received review: %+v\n", review)

	if err := validate.Struct(&review); err != nil {
		fmt.Println("Validation Error:", err)
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	if err := db.DB.Where("user_id = ? AND hike_id = ?", review.UserID, review.HikeID).FirstOrCreate(&review).Error; err != nil {
		fmt.Println("Database Error:", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, review)
}

// UpdateReview godoc
// @Summary Update a review by ID
// @Description Update details of a review by its ID
// @Tags reviews
// @Accept json
// @Produce json
// @Param id path int true "Review ID"
// @Param review body models.Review true "Review"
// @Success 200 {object} models.Review
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /reviews/{id} [put]
func UpdateReview(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var review models.Review
	if err := db.DB.First(&review, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	if err := c.ShouldBindJSON(&review); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	if err := validate.Struct(&review); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	if err := db.DB.Save(&review).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, review)
}

// GetReviewByUser godoc
// @Summary Get a review by user and hike
// @Description Get the review by a specific user for a specific hike
// @Tags reviews
// @Accept json
// @Produce json
// @Param user_id path int true "User ID"
// @Param hike_id path int true "Hike ID"
// @Success 200 {object} models.Review
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /reviews/user/{user_id}/hike/{hike_id} [get]
func GetReviewByUser(c *gin.Context) {
	userID, _ := strconv.Atoi(c.Param("user_id"))
	hikeID, _ := strconv.Atoi(c.Param("hike_id"))
	var review models.Review
	if err := db.DB.Where("user_id = ? AND hike_id = ?", userID, hikeID).First(&review).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Review not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, review)
}

// GetReviewsByHike godoc
// @Summary Get reviews for a hike
// @Description Get all reviews for a specific hike
// @Tags reviews
// @Accept json
// @Produce json
// @Param hike_id path int true "Hike ID"
// @Success 200 {array} models.Review
// @Failure 500 {object} models.ErrorResponse
// @Router /reviews/hike/{hike_id} [get]
func GetReviewsByHike(c *gin.Context) {
	hikeID, _ := strconv.Atoi(c.Param("hike_id"))
	var reviews []models.Review
	if err := db.DB.Where("hike_id = ?", hikeID).Preload("User").Find(&reviews).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, reviews)
}
