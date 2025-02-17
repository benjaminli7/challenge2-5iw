package controllers

import (
	"backend/db"
	"backend/models"
	"fmt"
	"net/http"
	"path/filepath"
	"strconv"

	flagsmith "github.com/Flagsmith/flagsmith-go-client/v2"

	"github.com/gin-gonic/gin"
)

// GetGroupimage godoc
// @Summary Get one group image
// @Description Get all images in a group image
// @Tags groups
// @Accept json
// @Produce json
// @Param group_id path int true "Group ID"
// @Success 200 {object} models.GroupImage
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/{group_id}/images/{image_id} [get]
func GetGroupImage(c *gin.Context) {
	groupID, err := strconv.Atoi(c.Param("group_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid group ID"})
		return
	}

	imageID, err := strconv.Atoi(c.Param("image_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid image ID"})
		return
	}

	var groupImage models.GroupImage
	if err := db.DB.Where("id = ? AND group_id = ?", imageID, groupID).First(&groupImage).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Image not found"})
		return
	}

	c.JSON(http.StatusOK, groupImage)
}

// CreateGroupImage godoc
// @Summary Create a new group image with multiple images
// @Description Create a new group image for a group with multiple images
// @Tags groups
// @Accept multipart/form-data
// @Produce json
// @Param group_id formData uint true "Group ID"
// @Param user_id formData uint true "User ID"
// @Param images formData file true "Images to upload"
// @Success 200 {object} []models.GroupImage
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/images [post]
func CreateGroupImage(c *gin.Context) {

	flagsmithClient, exists := c.MustGet("flagsmithClient").(*flagsmith.Client)
	if !exists {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Flagsmith client not found"})
		return
	}

	flags, err := flagsmithClient.GetEnvironmentFlags()
	if err != nil {
		return
	}
	isEnabled, err := flags.IsFeatureEnabled("enable_new_photos")
	if err != nil {
		return
	}

	if !isEnabled {
		c.JSON(http.StatusMethodNotAllowed, gin.H{
			"code":    http.StatusMethodNotAllowed,
			"message": "Sorry, please come back later",
		})
		return
	}

	groupID, err := strconv.Atoi(c.PostForm("group_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid group ID"})
		return
	}

	userID, err := strconv.Atoi(c.PostForm("user_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid user ID"})
		return
	}

	var user models.User
	if err := db.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "User not found"})
		return
	}
	fmt.Println("User Found", userID)

	if err := db.DB.Where("group_id = ? AND user_id = ?", groupID, userID).First(&models.GroupUser{}).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Group not found or user not a member"})
		return
	}
	fmt.Println("Group Found", groupID)

	form, err := c.MultipartForm()
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	files := form.File["images"]
	var groupImages []models.GroupImage

	for _, file := range files {
		if ext := filepath.Ext(file.Filename); ext != ".jpg" && ext != ".jpeg" && ext != ".png" {
			c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Only images are allowed"})
			return
		}

		path := fmt.Sprintf("public/groups/%d/%s", groupID, file.Filename)
		if err := c.SaveUploadedFile(file, path); err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
			return
		}
		fmt.Println("Path", path)

		groupImages = append(groupImages, models.GroupImage{
			GroupID: uint(groupID),
			UserID:  uint(userID),
			Path:    "/" + path,
		})
	}

	if err := db.DB.Create(&groupImages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	fmt.Println("Group Images", groupImages)

	c.JSON(http.StatusOK, groupImages)
}

// DeleteGroupImages godoc
// @Summary Delete an image from group image
// @Description Delete an image from group image by ID
// @Tags groups
// @Accept json
// @Produce json
// @Param image_id path int true "Album ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /image/{image_id} [delete]
func DeleteGroupImage(c *gin.Context) {
	imageID, err := strconv.Atoi(c.Param("image_id"))
	user := c.MustGet("user").(models.User)

	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid group ID"})
		return
	}

	var groupAlbum models.GroupImage
	if err := db.DB.Where("id = ? AND user_id = ?", imageID, user.ID).First(&groupAlbum).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Image not found"})
		return
	}

	if err := db.DB.Delete(&groupAlbum).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Failed to delete image"})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Image deleted from the group"})
}

func GetGroupPhotos(c *gin.Context) {
	groupIDStr := c.Param("id")
	groupID, err := strconv.Atoi(groupIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid group ID"})
		return
	}

	var groupImages []models.GroupImage
	if err := db.DB.Where("group_id = ?", groupID).Find(&groupImages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Could not retrieve group images"})
		return
	}

	c.JSON(http.StatusOK, groupImages)
}