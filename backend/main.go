package main

import (
	"backend/controllers"
	"backend/db"
	_ "backend/docs"
	middleware "backend/middleware"
	"net"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

var logger *logrus.Logger

func init() {
	// Set up the logger
	logger = logrus.New()
	conn, err := net.Dial("tcp", "localhost:5005")
	if err != nil {
		logger.Fatal(err)
	}
	logger.SetOutput(conn)
	logger.SetFormatter(&logrus.JSONFormatter{})

	// Connect to the database
	db.ConnectToDb()
	db.SyncDatabase()
}

func main() {
	r := gin.Default()

	// Middleware to log each request
	r.Use(func(c *gin.Context) {
		c.Next()
		logger.WithFields(logrus.Fields{
			"method": c.Request.Method,
			"path":   c.Request.URL.Path,
			"status": c.Writer.Status(),
		}).Info("request handled")
	})

	r.Static("/images", "./public/images")
	r.Static("/gpx", "./public/gpx")

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
	r.POST("/groups", middleware.RequireAuth(false), controllers.CreateGroup)
	r.POST("/groups/join", middleware.RequireAuth(false), controllers.JoinGroup)
	r.GET("/groups/user/:id", middleware.RequireAuth(false), controllers.GetMyGroups)
	r.GET("/groups/:id", middleware.RequireAuth(false), controllers.GetGroup)

	r.GET("/groups", middleware.RequireAuth(true), controllers.GetGroups)
	r.GET("/groups/hike/:id/:userId", middleware.RequireAuth(false), controllers.GetGroupsByHike)
	r.PATCH("/groups/:id", controllers.UpdateGroup)
	r.PATCH("groups/validate/:id", controllers.ValidateUserGroup)
	r.DELETE("/groups/:id", controllers.DeleteGroup)
	r.DELETE("/groups/leave", controllers.LeaveGroup)

	// Review routes
	r.POST("/reviews", controllers.CreateReview)
	r.PUT("/reviews/:id", controllers.UpdateReview)
	r.GET("/reviews/hike/:hike_id", controllers.GetReviewsByHike)
	r.GET("/reviews/user/:user_id/hike/:hike_id", controllers.GetReviewByUser)
	err := r.Run()
	if err != nil {
		logger.Fatal(err)
	}
}
