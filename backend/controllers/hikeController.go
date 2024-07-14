package controllers

import (
	"backend/db"
	"backend/models"
	"log"
	"net/http"
	"path/filepath"
	"strconv"

	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

// CreateHike godoc
// @Summary Create a new hike
// @Description Create a new hike with the input payload and optional image upload
// @Tags hikes
// @Accept multipart/form-data
// @Produce json
// @Param name formData string true "Hike Name"
// @Param description formData string true "Hike Description"
// @Param organizer_id formData uint true "Organizer ID"
// @Param difficulty formData string true "Difficulty"
// @Param duration formData string true "Duration"
// @Param is_approved formData bool false "Is Approved"
// @Param image formData file false "Hike Image"
// @Success 200 {object} models.Hike
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes [post]
func CreateHike(c *gin.Context) {
	var hike models.Hike

	hike.Name = c.PostForm("name")
	hike.Description = c.PostForm("description")
	organizerID, err := strconv.ParseUint(c.PostForm("organizer_id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid organizer ID"})
		return
	}
	hike.OrganizerID = uint(organizerID)
	hike.Difficulty = c.PostForm("difficulty")
	hike.Duration = c.PostForm("duration")
	isApproved, err := strconv.ParseBool(c.PostForm("is_approved"))
	if err != nil {
		hike.IsApproved = false
	} else {
		hike.IsApproved = isApproved
	}

	// Handle image upload or set default image
	file, err := c.FormFile("image")
	if err == nil {
		filename := filepath.Base(file.Filename)
		filePath := filepath.Join("public", "images", filename)
		if err := c.SaveUploadedFile(file, filePath); err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
			return
		}
		hike.Image = "/images/" + filename
	} else if err == http.ErrMissingFile {
		hike.Image = "/images/default_hikePicture.png"
	} else {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	//Add GPX file upload
	file, err = c.FormFile("gpx_file")
	if err == nil {
		filename := filepath.Base(file.Filename)
		filePath := filepath.Join("public", "gpx", filename)
		if err := c.SaveUploadedFile(file, filePath); err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
			return
		}
		hike.GpxFile = "/gpx/" + filename
	} else if err != http.ErrMissingFile {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	// Validate the hike struct
	if err := validate.Struct(hike); err != nil {
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
	if err := db.DB.Preload("Subcriptions").Find(&hikes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})

		return
	}

	// Calculate average rating for each hike
	for i, hike := range hikes {
		var avgRating float64
		db.DB.Model(&models.Review{}).Where("hike_id = ?", hike.ID).Select("avg(rating)").Row().Scan(&avgRating)
		hikes[i].AverageRating = avgRating
		log.Printf("Hike ID: %d, Name: %s, Average Rating: %.2f\n", hike.ID, hike.Name, avgRating)
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

	//Calcule avgRating
	var avgRating float64
	db.DB.Model(&models.Review{}).Where("hike_id = ?", hike.ID).Select("avg(rating)").Row().Scan(&avgRating)
	hike.AverageRating = avgRating
	log.Printf("Hike ID: %d, Name: %s, Average Rating: %.2f\n", hike.ID, hike.Name, avgRating)

	c.JSON(http.StatusOK, hike)
}

// UpdateHike godoc
// @Summary Update a hike by ID
// @Description Update details of a hike by its ID and optional image upload
// @Tags hikes
// @Accept multipart/form-data
// @Produce json
// @Param id path int true "Hike ID"
// @Param name formData string true "Hike Name"
// @Param description formData string true "Hike Description"
// @Param organizer_id formData uint true "Organizer ID"
// @Param difficulty formData string true "Difficulty"
// @Param duration formData string true "Duration"
// @Param is_approved formData bool false "Is Approved"
// @Param image formData file false "Hike Image"
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

	if name := c.PostForm("name"); name != "" {
		hike.Name = name
	}
	if description := c.PostForm("description"); description != "" {
		hike.Description = description
	}
	if organizerID := c.PostForm("organizer_id"); organizerID != "" {
		id, err := strconv.ParseUint(organizerID, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid organizer ID"})
			return
		}
		hike.OrganizerID = uint(id)
	}
	if difficulty := c.PostForm("difficulty"); difficulty != "" {
		hike.Difficulty = difficulty
	}
	if duration := c.PostForm("duration"); duration != "" {
		hike.Duration = duration
	}
	if isApproved := c.PostForm("is_approved"); isApproved != "" {
		approved, err := strconv.ParseBool(isApproved)
		if err != nil {
			c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid is_approved value"})
			return
		}
		hike.IsApproved = approved
	}

	file, err := c.FormFile("image")
	if err == nil {
		filename := filepath.Base(file.Filename)
		filePath := filepath.Join("public", "images", filename)
		if err := c.SaveUploadedFile(file, filePath); err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
			return
		}
		hike.Image = "/images/" + filename
	} else if err == http.ErrMissingFile {
		if hike.Image == "" {
			hike.Image = "/images/default_hikePicture.png"
		}
	} else {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	// Validate the hike struct
	if err := validate.Struct(hike); err != nil {
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
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	if err := db.DB.Where("hike_id = ?", id).Delete(&models.Group{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if err := db.DB.Delete(&models.Hike{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}



	c.JSON(http.StatusOK, gin.H{"message": "Hike and associated groups deleted"})
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

// UserSubscribtionHikes godoc
// @Summary Post a subscription to a hike
// @Description Post a subscription to a hike
// @Tags hikes
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Param user_id formData int true "User ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /hikes/subscribe [post]
func UserSubscribtionHikes(c *gin.Context) {
	var json struct {
		HikeID int `json:"hike_id"`
		UserID int `json:"user_id"`
	}

	if err := c.ShouldBindJSON(&json); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid input"})
		return
	}

	hikeID := json.HikeID
	userID := json.UserID

	// fmt.Println("userID is a", userID)
	// fmt.Println("hikeID is a", hikeID)

	var hike models.Hike
	if err := db.DB.First(&hike, hikeID).Error; err != nil {
		fmt.Println("Hike not found")
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Hike not found"})
		return
	}
	var user models.User
	if err := db.DB.First(&user, userID).Error; err != nil {
		fmt.Println("User not found")
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "User not found"})
		return
	}

	var subscription models.Subscription
	if err := db.DB.Where("hike_id = ? AND user_id = ?", hikeID, userID).First(&subscription).Error; err != nil {
		subscription.HikeID = uint(hikeID)
		subscription.UserID = uint(userID)

		fmt.Println(subscription)
		if err := db.DB.Create(&subscription).Error; err != nil {
			fmt.Println("Failed to create subscription")
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Failed to create subscription"})
			return
		}
		c.JSON(http.StatusOK, models.SuccessResponse{Message: "Subscription added"})
	} else {
		fmt.Println("Subscription already exists")
		if err := db.DB.Delete(&subscription).Error; err != nil {
			fmt.Println("Failed to delete subscription")
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Failed to delete subscription"})
			return
		}
		c.JSON(http.StatusOK, models.SuccessResponse{Message: "Subscription removed"})
	}
}
