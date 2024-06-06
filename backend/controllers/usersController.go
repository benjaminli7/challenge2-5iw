package controllers

import (
	"backend/db"
	"backend/models"
	"net/http"
	"os"
	"time"
	"fmt"
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

	emailToken,_ := services.GenerateRandomToken(32)
	user := models.User{Email: body.Email, Password: string(hash), Token: emailToken}

	result := db.DB.Create(&user)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest,gin.H{
			"error": "Failed to create user.",
		})
		return
	}
	fmt.Println("token"+emailToken)
	content := "<p>Veuillez cliquer sur le lien ci-dessous pour valider votre compte<p><a href='localhost/validate?token=" + emailToken+ "'> cliquer ici</a>"
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
	println("user",user.ID)
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
// @Router /validate [patch]
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
	fmt.Println("body",body)
	var user models.User
	db.DB.First(&user, "token = ?", body.Token)
	fmt.Println("user",user)
	if user.ID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid token",
		})
		return
	}

	db.DB.Model(&user).Update("IsVerified", true)
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "verify in successfully"})
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
	db.DB.Select("id","email", "role", "is_verified").Find(&users)
	c.JSON(http.StatusOK, models.UserListResponse{Users: users})
}

//UpdateRole godoc
// @Summary Update user role
// @Description Update the role of a user
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Param body body models.User.role true "User role"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /users/{id}/role [patch]
func UpdateRole(c *gin.Context) {
	var body struct {
		Role string
	}
	println("body",body.Role)
	if c.Bind(&body) != nil {
		println("Failed to read body")
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	id := c.Param("id")
	var user models.User
	db.DB.First(&user, id)

	if user.ID == 0 {
		fmt.Println("User not found")
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "User not found"})
		return
	}

	db.DB.Model(&user).Update("role", body.Role)
	fmt.Println("Role updated successfully")
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Role updated successfully"})
}

// DeleteUser godoc
// @Summary Delete user
// @Description Delete a user
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /users/{id} [delete]
func DeleteUser(c *gin.Context) {
	id := c.Param("id")
	var user models.User
	db.DB.First(&user, id)

	if user.ID == 0 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "User not found"})
		return
	}
	db.DB.Delete(&user)
	c.JSON(http.StatusOK, models.SuccessResponse{Message: "User deleted successfully"})
}