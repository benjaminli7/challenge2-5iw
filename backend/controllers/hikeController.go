package controllers

import (
	"backend/db"
	"backend/models"
	"net/http"
	"path/filepath"
	"strconv"

	"github.com/gin-gonic/gin"
)

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

	file, err := c.FormFile("image")
	if err == nil {
		filename := filepath.Base(file.Filename)
		print(filename)
		filePath := filepath.Join("public", "images", filename)
		if err := c.SaveUploadedFile(file, filePath); err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
			return
		}
		hike.Image = "/images/" + filename
	} else if err != http.ErrMissingFile {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
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
	} else if err != http.ErrMissingFile {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
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
