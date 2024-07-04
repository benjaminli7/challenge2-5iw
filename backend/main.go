package main

import (
	"backend/controllers"
	"backend/db"
	_ "backend/docs"
	middleware "backend/middleware"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title Swagger Example API
// @version 1.0
// @description This is a sample server Petstore server.
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.swagger.io/support
// @contact.email support@swagger.io

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080
// @BasePath /

func init() {
	db.ConnectToDb()
	db.SyncDatabase()
}

func main() {
	r := gin.Default()

	r.Static("/images", "./public/images")

	// Swagger route
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Auth route
	r.POST("/signup", controllers.Signup)
	r.POST("/login", middleware.Cors(), controllers.Login)
	r.GET("/logout", controllers.Logout)
	r.PATCH("/validate", controllers.Validate)

	// Users route
	r.GET("/users", middleware.RequireAuth(true), controllers.GetUsers)
	r.PATCH("/users/:id/role", middleware.RequireAuth(true), controllers.UpdateRole)
	r.DELETE("/users/:id", middleware.RequireAuth(true), controllers.DeleteUser)

	// Hike routes
	r.POST("/hikes", controllers.CreateHike)
	r.GET("/hikes", controllers.GetAllHikes)
	r.GET("/hikes/:id", controllers.GetHike)
	r.GET("hikes/notValidated", middleware.RequireAuth(true), controllers.GetNoValitedHike)
	r.PUT("/hikes/:id", controllers.UpdateHike)
	r.PATCH("/hikes/:id/validate", middleware.RequireAuth(true), controllers.ValidateHike)
	r.DELETE("/hikes/:id", controllers.DeleteHike)

	// Advice routes
	r.POST("/advice", middleware.RequireAuth(false), controllers.CreateAdvice)
	r.GET("/advice/:id/receiver", middleware.RequireAuth(false), controllers.GetAdviceByReceiver)
	r.GET("/advice/:id/donor", middleware.RequireAuth(false), controllers.GetAdviceByDonor)
	r.PATCH("/advice/:id", middleware.RequireAuth(false), controllers.UpdateAdvice)
	r.DELETE("/advice/:id", middleware.RequireAuth(false), controllers.DeleteAdvice)

	// Group routes
	r.POST("/groups",middleware.RequireAuth(false), controllers.CreateGroup)
	r.POST("/groups/join", controllers.JoinGroup)
	r.GET("/groups/:id",middleware.RequireAuth(false), controllers.GetGroup)
	r.GET("/groups", middleware.RequireAuth(true), controllers.GetGroups)
	r.GET("/groups/day", controllers.GetGroupsDay)
	r.PATCH("/groups/:id", controllers.UpdateGroup)
	r.PATCH("groups/validate/:id", controllers.ValidateUserGroup)
	r.DELETE("/groups/:id", controllers.DeleteGroup)
	r.DELETE("/groups/leave", controllers.LeaveGroup)

	err := r.Run()
	if err != nil {
		return
	}
}
