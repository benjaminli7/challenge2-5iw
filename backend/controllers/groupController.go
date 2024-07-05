package controllers

import (
	"backend/db"
	"backend/models"
	"fmt"
	"net/http"
	"strconv"
	"time"
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
	var groupUser models.GroupUser
	if err := c.ShouldBindJSON(&group); err != nil {
		println("Failed to bind JSON")
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}
	println(c.ShouldBindJSON(group))

	
	if err := db.DB.Create(&group).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	groupUser = models.GroupUser{UserID: group.OrganizerID, GroupID: group.ID, IsValidate: true}
	if err := db.DB.Create(&groupUser).Error; err != nil {
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

// GetGroups godoc
// @Summary Get all groups
// @Description Get all groups
// @Tags groups
// @Accept json
// @Produce json
// @Success 200 {object} models.GroupListResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /groups [get]
func GetGroups(c *gin.Context) {
	var groups []models.Group
	if err := db.DB.Preload("Hike").Preload("Organizer").Order("id desc").Find(&groups).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Réponse JSON avec les groupes récupérés
	c.JSON(http.StatusOK, models.GroupListResponse{Groups: groups})
}

// GetMyGroups godoc
// @Summary Get groups by user ID
// @Description Get groups by user ID
// @Tags groups
// @Accept json
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} models.Group
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/user/{id} [get]
func GetMyGroups(c *gin.Context) {
	userIdParam := c.Param("id")
	userId, err := strconv.Atoi(userIdParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var groups []models.Group
	today := time.Now().Format("2006-01-02")

	err = db.DB.Preload("Hike").Preload("Organizer").Joins("JOIN group_users ON group_users.group_id = groups.id").Order("start_date").Where("group_users.user_id = ?", userId).Where("start_date >= ?", today).Find(&groups).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, groups)
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

	if err := db.DB.Unscoped().Where("group_id = ?", id).Delete(&models.GroupUser{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	if err := db.DB.Delete(&models.Group{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Group deleted"})
}

// JoinGroup godoc
// @Summary Join a group
// @Description Join a group
// @Tags groups
// @Accept json
// @Produce json
// @Param groupUser body models.GroupUser true "Group User Info"
// @Success 200 {object} models.SuccessResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/join [post]

func JoinGroup(c *gin.Context) {
	var body struct {
		UserId uint
		GroupId uint
	}
	if c.Bind(&body) != nil {
		println("Failed to read body")
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	var group models.Group
	db.DB.First(&group, body.GroupId)

	if group.ID == 0 {
		fmt.Println("Group not found")
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Group not found"})
		return
	}
	var accepted bool = false

	groupUser :=  models.GroupUser{UserID: body.UserId, GroupID: body.GroupId, IsValidate: accepted}

	if err := db.DB.Create(&groupUser).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, groupUser)
}

// LeaveGroup godoc
// @Summary Leave a group
// @Description Leave a group
// @Tags groups
// @Accept json
// @Produce json
// @Param groupUser body models.GroupUser true "Group User Info"
// @Success 200 {object} models.SuccessResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/leave [delete]
func LeaveGroup(c *gin.Context) {
	var body struct {
		UserId uint
		GroupId uint
	}
	if c.Bind(&body) != nil {
		println("Failed to read body")
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}
	var groupUser models.GroupUser
	if err := db.DB.Where("user_id = ? AND group_id = ?", body.UserId, body.GroupId).First(&groupUser).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := db.DB.Delete(&groupUser).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "User left group"})
}

// ValidateUserGroup godoc
// @Summary Validate a user in a group
// @Description Validate a user in a group
// @Tags groups
// @Accept json
// @Produce json
// @Param id path int true "GroupUser ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/validate/{id} [patch]
func ValidateUserGroup(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var groupUser models.GroupUser
	if err := db.DB.First(&groupUser, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	groupUser.IsValidate = true
	if err := db.DB.Save(&groupUser).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "User validated"})
}