package main

import (
	"backend/controllers"
	"backend/db"
	"context"
	"fmt"
	"net/http"

	// import the firebase service
	_ "backend/docs"
	middleware "backend/middleware"
	"backend/services"
	"log"
	"net"
	"os"

	flagsmith "github.com/Flagsmith/flagsmith-go-client/v2"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
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
var logger *logrus.Logger
var client *flagsmith.Client

func init() {
	logger = logrus.New()
	conn, err := net.Dial("tcp", "localhost:5005")
	if err != nil {
		// Fallback to standard logger
		log.Println("Could not connect to log server, using default stdout logger:", err)
		// Set logger to output to stdout
		logger.SetOutput(os.Stdout)
	} else {
		logger.SetOutput(conn)
		logger.SetFormatter(&logrus.JSONFormatter{})
	}

	db.ConnectToDb()
	db.SyncDatabase()

	services.InitFirebase()

}

func main() {
	FLAGSMITH_KEY := os.Getenv("FLAGSMITH_KEY")
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Initialise the Flagsmith client
	client := flagsmith.NewClient(FLAGSMITH_KEY, flagsmith.WithContext(ctx))
	fmt.Println(client.GetEnvironmentFlags())

	r := gin.Default()

	r.Use(middleware.FlagsmithMiddleware(client))
	r.Use(func(c *gin.Context) {
		c.Next()
		logger.WithFields(logrus.Fields{
			"method": c.Request.Method,
			"path":   c.Request.URL.Path,
			"status": c.Writer.Status(),
		}).Info("request handled")
	})

	r.Static("/images", "./public/images")
	r.Static("/public/groups", "./public/groups")
	r.Static("/gpx", "./public/gpx")
	r.Static("/avatar", "./public/avatar")

	// Swagger route
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	r.GET("/flags", func(c *gin.Context) {
		flags, err := client.GetEnvironmentFlags()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		allFlags := flags.AllFlags()
		c.JSON(http.StatusOK, allFlags)
	})
	// Auth route
	r.POST("/signup", controllers.Signup)
	r.POST("/login", middleware.Cors(), controllers.Login)
	r.GET("/logout", controllers.Logout)
	r.PATCH("/validate", controllers.Validate)

	// Users route
	r.GET("/users", middleware.RequireAuth(true), controllers.GetUsers)
	r.PATCH("/users/:id/role", middleware.RequireAuth(true), controllers.UpdateRole)
	r.DELETE("/users/:id", middleware.RequireAuth(true), controllers.DeleteUser)
	r.PUT("/users/:id", controllers.UpdateUser)
	r.GET("/users/me", middleware.RequireAuth(false), controllers.GetUserProfile)

	r.PATCH("/users/:id/fcmToken", middleware.RequireAuth(false), controllers.UpdateFcmToken)
	r.PATCH("/users/:id/password", middleware.RequireAuth(false), controllers.UpdatePassword)
	// Hike routes
	r.POST("/hikes", middleware.RequireAuth(false), controllers.CreateHike)
	r.GET("/hikes", controllers.GetAllHikes)
	r.GET("/hikes/:id", controllers.GetHike)
	r.GET("hikes/notValidated", middleware.RequireAuth(true), controllers.GetNoValitedHike)
	r.PUT("/hikes/:id", controllers.UpdateHike)
	r.PATCH("/hikes/:id/validate", middleware.RequireAuth(true), controllers.ValidateHike)
	r.DELETE("/hikes/:id", middleware.RequireAuth(false), controllers.DeleteHike)
	r.POST("/hikes/subscribe", middleware.RequireAuth(false), controllers.UserSubscribtionHikes)

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
	r.GET("/groups/user/:id/history", middleware.RequireAuth(false), controllers.GetMyGroupsHistory)
	r.GET("/groups/:id", middleware.RequireAuth(false), controllers.GetGroup)
	r.GET("/groups", middleware.RequireAuth(true), controllers.GetGroups)
	r.GET("/groups/hike/:id/:userId", middleware.RequireAuth(false), controllers.GetGroupsByHike)
	r.GET("/groups/:id/messages", middleware.RequireAuth(false), controllers.GetGroupMessages)
	r.GET("groups/participants/:id", middleware.RequireAuth(false), controllers.GetParticipants)
	r.PATCH("/groups/:id", controllers.UpdateGroup)
	r.PATCH("groups/validate/:id", controllers.ValidateUserGroup)
	r.DELETE("/groups/user/:userId/:groupId", middleware.RequireAuth(false), controllers.DeleteUserGroup)
	r.DELETE("/groups/:id", controllers.DeleteGroup)
	r.DELETE("/groups/leave", controllers.LeaveGroup)
	r.POST("/groups/albums", middleware.RequireAuth(false), controllers.CreateGroupImage)
	r.DELETE("/albums/:image_id", middleware.RequireAuth(false), controllers.DeleteGroupImage)
	r.GET("/groups/:id/photos", middleware.RequireAuth(false), controllers.GetGroupPhotos)
	// r.GET("/groups/:id/albums", controllers.GetGroupImages)

	// Review routes
	r.POST("/reviews", middleware.RequireAuth(false), controllers.CreateReview)
	r.PUT("/reviews/:id", middleware.RequireAuth(false), controllers.UpdateReview)
	r.GET("/reviews/hike/:hike_id", controllers.GetReviewsByHike)
	r.GET("/reviews/user/:user_id/hike/:hike_id", controllers.GetReviewByUser)

	// Material routes
	r.POST("/groups/:id/materials", controllers.GroupAddMaterials)
	r.POST("/materials/:materialId/bring/:userId", controllers.MemberAddMaterial)
	r.DELETE("/materials/:materialId/bring/:userId", controllers.MemberRemoveMaterial)
	r.GET("/groups/:id/materials", controllers.GetGroupMaterials)
	// Message routes
	r.GET("/ws/:groupID", controllers.HandleWebSocket)

	//Options route
	r.GET("/options", controllers.GetOptions)
	r.PATCH("/options", middleware.RequireAuth(true), controllers.UpdateOptions)

	// Test notification
	r.POST("/test-notif", func(c *gin.Context) {
		var body map[string]string
		if err := c.BindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		fcmToken := body["fcmToken"]
		title := body["title"]
		bodyMessage := body["body"]
		route := body["route"]
		fmt.Println(fcmToken, title, bodyMessage, route)
		// Send notification and handle errors
		err := services.SendNotification(c, fcmToken, title, bodyMessage, route)
		if err != nil {
			log.Printf("Error sending notification: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send notification"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Notification sent"})
	})

	err := r.Run()
	if err != nil {
		logger.Fatal(err)
	}
	// send test notification
	// services.SendNotification(context.Background(), "fcmToken", "title", "body", "route")
}
