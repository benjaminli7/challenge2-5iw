package test

import (
	"backend/controllers"
	"github.com/gin-gonic/gin"
)

func SetupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	router := gin.Default()

	router.POST("/hikes", controllers.CreateHike)
	router.GET("/hikes", controllers.GetAllHikes)
	router.GET("/hikes/:id", controllers.GetHike)
	router.PUT("/hikes/:id", controllers.UpdateHike)
	router.DELETE("/hikes/:id", controllers.DeleteHike)

	router.POST("/signup", controllers.Signup)
	router.POST("/login", controllers.Login)
	router.PATCH("/validate", controllers.Validate)
	router.GET("/logout", controllers.Logout)
	router.GET("/users", controllers.GetUsers)
	router.PATCH("/users/:id/role", controllers.UpdateRole)
	router.DELETE("/users/:id", controllers.DeleteUser)
	router.GET("/users/me", controllers.GetUserProfile)
	router.PUT("/users/:id", controllers.UpdateUser)
	router.PATCH("/users/:id/password", controllers.UpdatePassword)
	router.PATCH("/users/:id/fcmToken", controllers.UpdateFcmToken)
	return router
}
