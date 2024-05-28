package controllers

import (
	"backend/db"
	"backend/models"
	"net/http"
	"os"
	"time"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"backend/services"

)

func Signup(c *gin.Context){
	// Get the email/pass off req Body
	var body struct{
		Email string
		Password string
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to read body",
		})

		return
	}

	// Hash the password
	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password),10)

	if err != nil {
		c.JSON(http.StatusBadRequest,gin.H{
			"error": "Failed to hash password.",
		})
		return
	}

	emailToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email": body.Email,
		"exp": time.Now().Add(time.Hour * 24).Unix(),
	})



	// Create the user
	user := models.User{Email: body.Email, Password: string(hash), Token: emailToken.Raw}

	result := db.DB.Create(&user)

	if result.Error != nil {
		c.JSON(http.StatusBadRequest,gin.H{
			"error": "Failed to create user.",
		})
		return
	}
	fmt.Println(emailToken.Raw)
	content := "<p>Veuillez cliquer sur le lien ci-dessous pour valider votre compte<p><a href='url/" + emailToken.Raw+ "'> cliquer ici</a>"
	services.SendEmail(body.Email , content , "Validation de compte")
	// Respond
	c.JSON(http.StatusOK, gin.H{})
}

func Login (c *gin.Context){
	// Get email & pass off req body
	var body struct{
		Email string
		Password string
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to read body",
		})

		return
	}

	// Look up for requested user
	var user models.User

	db.DB.First(&user, "email = ?", body.Email)

	if user.ID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid email or password",
		})
		return
	}

	// Compare sent in password with saved users password
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.Password))

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid email or password",
		})
		return
	}

	// Generate a JWT token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": user.ID,
		"exp": time.Now().Add(time.Hour * 24 * 30).Unix(),
	})

	// Sign and get the complete encoded token as a string using the secret
	tokenString, err := token.SignedString([]byte(os.Getenv("SECRET")))

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to create token",
		})
		return
	}

	// Respond
	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie("Authorization", tokenString, 3600 * 24 * 30, "", "", false, true)

	c.JSON(http.StatusOK, gin.H{})
}

func Validate(c *gin.Context){
	var body struct{
		Token string
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to read body",
		})

		return
	}
	var user models.User
	db.DB.First(&user, "token = ?", body.Token)

	if user.ID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid token",
		})
		return
	}

	db.DB.Model(&user).Update("is_verified", true)
	c.JSON(http.StatusOK, gin.H{
		"message": user,
	})
}

func Logout(c *gin.Context){
	c.SetCookie("Authorization", "", -1, "", "", false, true)

	c.JSON(http.StatusOK, gin.H{})
}

func GetUsers(c *gin.Context){
	var users []models.User

	db.DB.Find(&users)


	c.JSON(http.StatusOK, gin.H{
		"users": users,
	})
}