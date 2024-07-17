package controllers

import (
	"backend/db"
	"backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func GroupAddMaterials(c *gin.Context) {
	var req models.MaterialRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var group models.Group
	if err := db.DB.Preload("Materials").First(&group, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Group not found"})
		return
	}

	for _, materialName := range req.Materials {
		material := models.Material{Name: materialName, GroupID: group.ID}
		db.DB.Create(&material)
	}

	c.JSON(http.StatusOK, gin.H{"message": "Materials added successfully"})
}

func MemberAddMaterial(c *gin.Context) {
	var material models.Material
	if err := db.DB.Preload("Users").First(&material, c.Param("materialId")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Material not found"})
		return
	}

	var user models.User
	if err := db.DB.First(&user, c.Param("userId")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	db.DB.Model(&material).Association("Users").Append(&user)
	c.JSON(http.StatusOK, gin.H{"message": "User added as bringer"})
}

func MemberRemoveMaterial (c *gin.Context) {
	var material models.Material
	if err := db.DB.Preload("Users").First(&material, c.Param("materialId")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Material not found"})
		return
	}

	var user models.User
	if err := db.DB.First(&user, c.Param("userId")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	db.DB.Model(&material).Association("Users").Delete(&user)
	c.JSON(http.StatusOK, gin.H{"message": "User removed as bringer"})
}

func GetGroupMaterials(c *gin.Context) {
	var group models.Group

	// Fetch the group including materials and users, ordered by material ID
	if err := db.DB.Preload("Materials", func(db *gorm.DB) *gorm.DB {
		return db.Order("materials.id")
	}).Preload("Materials.Users").First(&group, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Group not found"})
		return
	}

	c.JSON(http.StatusOK, group.Materials)
}