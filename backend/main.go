package main

import (
	"backend/controllers"
	"backend/db"
	middleware "backend/milddleware"

	"github.com/gin-gonic/gin"
)

func init(){
 db.LoadEnvVariables()
 db.ConnectToDb()
 db.SyncDatabase()
}

func main(){
 r := gin.Default()
 r.POST("/signup", controllers.Signup)
 r.POST("/login", controllers.Login)
 r.GET("/logout", controllers.Logout)
 r.GET("/validate", middleware.RequireAuth(false) ,controllers.Validate)

 r.GET("/users", middleware.RequireAuth(true), controllers.GetUsers)

 r.Run()
}