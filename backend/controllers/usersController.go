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

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"backend/services"

)

// Signup godoc
// @Summary Sign up a new user
// @Description Create a new user account
// @Tags auth
// @Accept json
// @Produce json
// @Param body body models.User true "Sign up user"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /signup [post]
func Signup(c *gin.Context) {
	var body struct {
		Email    string
		Password string
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to hash password"})
		return
	}

	emailToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email": body.Email,
		"exp":   time.Now().Add(time.Hour * 24).Unix(),
	})

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

	c.JSON(http.StatusOK, models.SuccessResponse{Message: "User created successfully"})

}

// Login godoc
// @Summary Log in a user
// @Description Log in a user with email and password
// @Tags auth
// @Accept json
// @Produce json
// @Param body body models.User true "Log in user"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /login [post]
func Login(c *gin.Context) {
	var body struct {
		Email    string
		Password string
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	var user models.User
	db.DB.First(&user, "email = ?", body.Email)

	if user.ID == 0 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid email or password"})
		return
	}

	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.Password))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid email or password"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":      user.ID,
		"exp":      time.Now().Add(time.Hour * 24 * 30).Unix(),
		"email":    user.Email,
		"roles":    user.Role,
		"verified": user.IsVerified,
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("SECRET")))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to create token"})
		return
	}

	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie("Authorization", tokenString, 3600*24*30, "", "", false, true)

	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Logged in successfully"})
}

// Validate godoc
// @Summary Validate user token
// @Description Validate the current user token
// @Tags auth
// @Accept json
// @Produce json
// @Success 200 {object} models.SuccessResponse
// @Router /validate [get]
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

// Logout godoc
// @Summary Log out a user
// @Description Log out the current user
// @Tags auth
// @Accept json
// @Produce json
// @Success 200 {object} models.SuccessResponse
// @Router /logout [get]
func Logout(c *gin.Context) {
	c.SetCookie("Authorization", "", -1, "", "", false, true)
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Logged out successfully"})
}

// GetUsers godoc
// @Summary Get users
// @Description Get the list of users
// @Tags users
// @Accept json
// @Produce json
// @Success 200 {object} models.UserListResponse
// @Router /users [get]
func GetUsers(c *gin.Context) {
	var users []models.User
	db.DB.Find(&users)

	c.JSON(http.StatusOK, models.UserListResponse{Users: users})
}
