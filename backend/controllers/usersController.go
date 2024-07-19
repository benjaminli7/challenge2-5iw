package controllers

import (
	"backend/db"
	"backend/models"
	"backend/services"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
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
	email := c.PostForm("email")
	username := c.PostForm("username")
	password := c.PostForm("password")
	fmt.Println("email", email, "username", username, "password", password)
	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to hash password"})
		return
	}
	if email == "" || username == "" || password == "" {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Please fill in all fields"})
		return
	}

	emailToken, _ := services.GenerateRandomToken(32)
	user := models.User{Email: email, Username: username, Password: string(hash), Token: emailToken}
	db.DB.First(&user, "username = ?", username)
	if user.ID != 0 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{"Username already in use"})
		return
	}
	db.DB.First(&user, "email = ?", email)
	if user.ID != 0 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{"Email already in use"})
		return
	}
	file, err := c.FormFile("image")
	// println("err",err.Error())
	if err == nil {
		println("file", file)
		filename := filepath.Base(file.Filename)
		filePath := filepath.Join("public", "avatar", filename)
		if err := c.SaveUploadedFile(file, filePath); err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
			return
		}
		user.ProfileImage = "/avatar/" + filename
	} else if err == http.ErrMissingFile {
		user.ProfileImage = "";
	} else {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
		return
	}
	result := db.DB.Create(&user)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to create user.",
		})
		return
	}
	fmt.Println("token" + emailToken)
	content := "<p>Veuillez cliquer sur le lien ci-dessous pour valider votre compte<p><a href='https://api.autoequip.dev/web/#/validate/" + emailToken + "'> cliquer ici</a>"
	services.SendEmail(email, content, "Validation de compte")
	// Respond
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
		IsGoogle string
	}
	fmt.Println("Email", body.Email, "Password", body.Password, "IsGoogle", body.IsGoogle)
	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	var user models.User
	db.DB.First(&user, "email = ?", body.Email)

	if user.ID == 0 {
		if body.IsGoogle == "true" {
			// create user
			//generate a random secured password
			randomString, _ := services.GenerateRandomToken(16)
			hash, err := bcrypt.GenerateFromPassword([]byte(randomString), 10)
			if err != nil {
				c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to hash password"})
				return
			}

			atIndex := strings.Index(body.Email, "@")
			localPart := body.Email[:atIndex]
			rand.Seed(time.Now().UnixNano())
			randomNumber := rand.Intn(9000) + 1000 // Generate a random number between 1000 and 9999

			username := fmt.Sprintf("%s%d", localPart, randomNumber)

			user = models.User{Email: body.Email,Password: string(hash), Username: username, Role: "user", IsVerified: true}
			result := db.DB.Create(&user)
			if result.Error != nil {
				c.JSON(http.StatusBadRequest, gin.H{
					"error": "Failed to create user.",
				})
				return
			}
			token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
				"sub":       user.ID,
				"exp":       time.Now().Add(time.Hour * 24 * 30).Unix(),
				"email":     user.Email,
				"roles":     user.Role,
				"verified":  user.IsVerified,
				"fcm_token": user.FcmToken,
				"profile_image": user.ProfileImage,
				"username": user.Username,
			})

			secret := os.Getenv("SECRET")
			if secret == "" {
				c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Server configuration error"})
				return
			}

			tokenString, err := token.SignedString([]byte(secret))
			if err != nil {
				c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to create token"})
				return
			}

			c.SetSameSite(http.SameSiteStrictMode)
			c.SetCookie("Authorization", tokenString, 3600*24*30, "/", "", false, true)

			//send email with generated password to the user
			content := "<p>Votre mot de passe est : " + randomString + "<p>"
			services.SendEmail(body.Email, content, "Votre mot de passe temporaire a Hike Mate")

			c.JSON(http.StatusOK, models.SuccessResponse{Message: tokenString})
			return
		}

		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid email or password"})
		return
	}
	if body.IsGoogle == "false" {
		err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.Password))
		if err != nil {
			c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Invalid email or password"})
			return
		}
	}
	println("user", user.ID)
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":      user.ID,
		"exp":      time.Now().Add(time.Hour * 24 * 30).Unix(),
		"email":    user.Email,
		"roles":    user.Role,
		"verified": user.IsVerified,
		"username": user.Username,
		"profile_image": user.ProfileImage,

	})

	secret := os.Getenv("SECRET")
	if secret == "" {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Server configuration error"})
		return
	}

	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to create token"})
		return
	}

	c.SetSameSite(http.SameSiteStrictMode)
	c.SetCookie("Authorization", tokenString, 3600*24*30, "/", "", false, true)

	c.JSON(http.StatusOK, models.SuccessResponse{Message: tokenString})
}

// Validate godoc
// @Summary Validate user token
// @Description Validate the current user token
// @Tags auth
// @Accept json
// @Produce json
// @Success 200 {object} models.SuccessResponse
// @Router /validate [patch]
func Validate(c *gin.Context) {
	var body struct {
		Token string
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to read body",
		})
		return
	}
	fmt.Println("body", body)
	var user models.User
	db.DB.First(&user, "token = ?", body.Token)
	fmt.Println("user", user)
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
	db.DB.Select("id", "email", "username", "role", "is_verified").Find(&users)
	c.JSON(http.StatusOK, models.UserListResponse{Users: users})
}

// UpdateRole godoc
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
	println("body", body.Role)
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
    userIdParam := c.Param("id")
	println("userIdParam", userIdParam)
    userId, err := strconv.Atoi(userIdParam)
    if err != nil {
		println("err", err)
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
        return
    }
	println("userId", userId)
    // Début de la transaction
    tx := db.DB.Begin()

    // Supprimer les messages de l'utilisateur
    if err := tx.Unscoped().Where("user_id = ?", userId).Delete(&models.Message{}).Error; err != nil {
		println("err1", err.Error())
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
        return
    }
	if err := tx.Unscoped().Where("user_id = ?", userId).Delete(&models.Review{}).Error; err != nil {
		println("err1", err.Error())
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
        return
    }

	if err := tx.Unscoped().Where("user_id = ?", userId).Delete(&models.GroupImage{}).Error; err != nil {
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
        return
    }

    if err := tx.Where("user_id = ?", userId).Delete(&models.MaterialUser{}).Error; err != nil {
		println("err2", err.Error())
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
        return
    }


    if err := tx.Unscoped().Where("user_id = ?", userId).Delete(&models.GroupUser{}).Error; err != nil {
		println("err3", err.Error())
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
        return
    }


    var groups []models.Group
    if err := tx.Where("organizer_id = ?", userId).Find(&groups).Error; err != nil {
		println("err4", err.Error())
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
        return
    }
    for _, group := range groups {

        if err := tx.Where("group_id = ?", group.ID).Delete(&models.Material{}).Error; err != nil {
			println("err5", err.Error())
            tx.Rollback()
            c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
            return
        }
		if err := tx.Unscoped().Where("group_id = ?", group.ID).Delete(&models.GroupUser{}).Error; err != nil {
			println("err3", err.Error())
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
			return
		}
		if err := tx.Unscoped().Where("group_id = ?", group.ID).Delete(&models.Message{}).Error; err != nil {
			println("err1", err.Error())
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
			return
		}

        if err := tx.Delete(&group).Error; err != nil {
			println("err6", err.Error())
            tx.Rollback()
            c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
            return
        }
    }


    if err := tx.Delete(&models.User{}, userId).Error; err != nil {
		println("err7", err.Error())
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
        return
    }

    // Commit de la transaction
    if err := tx.Commit().Error; err != nil {
        tx.Rollback()
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: err.Error()})
        return
    }

    c.JSON(http.StatusOK, models.SuccessResponse{Message: "User and associated data deleted successfully"})
}

// Get user profile
// @Summary Get user profile
// @Description Get the profile of the logged-in user
// @Tags users
// @Accept json
// @Produce json
// @Success 200 {object} models.User
// @Router /users/me [get]
func GetUserProfile(c *gin.Context) {
	userID, _ := c.Get("userID")
	var user models.User
	if err := db.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "User not found"})
		return
	}
	c.JSON(http.StatusOK, user)
}

// UpdateUser godoc
// @Summary Update user profile
// @Description Update the profile of a user
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Param body body models.User true "User profile"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /users/{id} [put]
func UpdateUser(c *gin.Context) {
	var user models.User
	id := c.Param("id")
	if err := db.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "User not found"})
		return
	}

	var body models.User
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	if body.Username != "" {
		user.Username = body.Username
	}

	if body.ProfileImage != "" {
		user.ProfileImage = body.ProfileImage
	}

	if err := db.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Failed to update user"})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{Message: "User updated successfully"})
}


// UpdatePassword godoc
// @Summary Update user password
// @Description Update the password of a user
// @Param body body models.PasswordUpdate true "User password update"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /users/{id}/password [patch]
func UpdatePassword(c *gin.Context) {
	var body struct {
		OldPassword string `json:"old_password"`
		NewPassword string `json:"new_password"`
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	id := c.Param("id")
	var user models.User
	if err := db.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "User not found"})
		return
	}
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.OldPassword))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Old password is incorrect"})
		return
	}

	newPasswordHash, err := bcrypt.GenerateFromPassword([]byte(body.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Failed to hash new password"})
		return
	}

	user.Password = string(newPasswordHash)
	if err := db.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Failed to update password"})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{Message: "Password updated successfully"})

}


// UpdateFcmToken godoc
// @Summary Update user FCM token
// @Description Update the FCM token of a user
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Param body body models.User.fcmToken true "User FCM token"
// @Success 200 {object} models.SuccessResponse
// @Failure 400 {object} models.ErrorResponse
// @Router /users/{id}/fcmToken [patch]
func UpdateFcmToken(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var user models.User
	if err := db.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "User not found"})
		return
	}

	// get fcm token from request body
	var body struct {
		FcmToken string `json:"fcm_token"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Failed to read body"})
		return
	}

	// update user's fcm token
	user.FcmToken = body.FcmToken
	if err := db.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Failed to update user"})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{Message: "FCM token updated successfully"})

}
