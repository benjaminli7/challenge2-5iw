package controllers

import (
	"backend/db"
	"backend/models"
	"backend/services"
	"context"
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

	if err := db.DB.Create(&group).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	groupUser = models.GroupUser{UserID: group.OrganizerID, GroupID: group.ID, IsValidate: true}
	if err := db.DB.Create(&groupUser).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	// get fcm token of the user that subscribed to the hike
	var token string
	var title string
	var body string
	var route string

	var subscribedUsers []models.Subscription

	if err := db.DB.Preload("User").Preload("Hike").Where("hike_id = ?", group.HikeID).Find(&subscribedUsers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// for _, sub := range subscribedUsers {
	// 	users = append(users, sub.User)
	// }

	for _, sub := range subscribedUsers {
		if sub.UserID == group.OrganizerID {
			continue
		}
		token = sub.User.FcmToken
		title = group.Organizer.Username + " created a new group for the hike " + sub.Hike.Name + "! try to join it"
		body = "Join the group to meet new people and share your experience"
		route = "/hike/" + strconv.Itoa(int(group.HikeID))
		if token != "" {
			err := services.SendNotification(context.Background(), token, title, body, route)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send notification"})
				return
			}
		}
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
	if err := db.DB.Preload("Materials.Users").Preload("Users").Preload("Hike").Preload("Organizer").Preload("GroupImages").First(&group, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	println()
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
	if err := db.DB.Preload("Hike").Preload("Users").Preload("Organizer").Preload("GroupImages").Order("id desc").Find(&groups).Error; err != nil {
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

	err = db.DB.Preload("Hike").Preload("Users").Preload("Organizer").Preload("GroupImages").Joins("JOIN group_users ON group_users.group_id = groups.id").Order("start_date").Where("group_users.user_id = ?", userId).Where("start_date >= ?", today).Find(&groups).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, groups)
}

// GetGroupsByHike godoc
// @Summary Get groups by hike ID
// @Description Get groups by hike ID
// @Tags groups
// @Accept json
// @Produce json
// @Param id path int true "Hike ID"
// @Success 200 {object} models.Group
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/hike/{id}/{userId} [get]

func GetGroupsByHike(c *gin.Context) {
	hikeIdParam := c.Param("id")
	hikeId, err := strconv.Atoi(hikeIdParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid hike ID"})
		return
	}

	userId := c.Param("userId")

	var groups []models.Group

	subQuery := db.DB.Model(&models.GroupUser{}).
		Select("group_id").
		Where("user_id = ?", userId)

	today := time.Now().Format("2006-01-02")
	err = db.DB.Preload("Hike").Preload("Users").Preload("Organizer").Preload("GroupImages").
		Order("start_date").
		Where("hike_id = ?", hikeId).
		Where("start_date >= ?", today).
		Not("id IN (?)", subQuery).
		Find(&groups).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, groups)
}

// GetMyGroupsHistory godoc
// @Summary Get groups by user ID
// @Description Get groups by user ID
// @Tags groups
// @Accept json
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} models.Group
// @Failure 500 {object} models.ErrorResponse
// @Router /groups/user/{id} [get]
func GetMyGroupsHistory(c *gin.Context) {
	userIdParam := c.Param("id")
	userId, err := strconv.Atoi(userIdParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var groups []models.Group
	today := time.Now().Format("2006-01-02")

	err = db.DB.Preload("Hike").Preload("Users").Preload("Organizer").Preload("GroupImages").Joins("JOIN group_users ON group_users.group_id = groups.id").Order("start_date").Where("group_users.user_id = ?", userId).Where("start_date < ?", today).Find(&groups).Error
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
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid group ID"})
		return
	}

	tx := db.DB.Begin()

	if err := tx.Unscoped().Where("group_id = ?", id).Delete(&models.GroupUser{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := tx.Unscoped().Where("group_id = ?", id).Delete(&models.GroupImage{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	if err := tx.Unscoped().Where("group_id = ?", id).Delete(&models.Material{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := tx.Unscoped().Where("group_id = ?", id).Delete(&models.Message{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	if err := tx.Delete(&models.Group{}, id).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Group and associated data deleted successfully"})
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
		UserId  uint
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

	groupUser := models.GroupUser{UserID: body.UserId, GroupID: body.GroupId, IsValidate: accepted}

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
		UserId  uint
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

func GetGroupMessages(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var messages []models.Message
	if err := db.DB.Preload("User").Where("group_id = ?", id).Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, messages)
}

func GetParticipants(c *gin.Context) {
	groupIdParam := c.Param("id")

	groupId, err := strconv.Atoi(groupIdParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	var group models.Group

	err = db.DB.Preload("Users").Where("id = ?", groupId).First(&group).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch participants"})
		return
	}

	c.JSON(http.StatusOK, group)
}

func DeleteUserGroup(c *gin.Context) {
	groupIdParam := c.Param("groupId")
	userIdParam := c.Param("userId")

	groupId, err := strconv.Atoi(groupIdParam)
	if err != nil {
		println("Failed to convert group ID")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	userId, err := strconv.Atoi(userIdParam)
	if err != nil {
		println("Failed to convert user ID")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return

	}

	if err := db.DB.Unscoped().Where("group_id = ?", groupId).Where("user_id = ?", userId).Delete(&models.GroupUser{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	var material models.Material
	if err := db.DB.Preload("Users").Where("group_id = ?", groupId).First(&material).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Material not found"})
		return
	}
	var user models.User
	if err := db.DB.First(&user, userId).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	db.DB.Model(&material).Association("Users").Delete(&user)
	c.JSON(http.StatusOK, gin.H{"message": "User removed as bringer"})

}
