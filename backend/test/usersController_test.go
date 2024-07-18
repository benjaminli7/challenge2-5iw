package test

import (
	"backend/db"
	"backend/models"
	"bytes"
	"golang.org/x/crypto/bcrypt"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func clearDatabase() {
	db.DB.Exec("DELETE FROM users")
	db.DB.Exec("DELETE FROM messages")
	db.DB.Exec("DELETE FROM reviews")
	db.DB.Exec("DELETE FROM group_images")
	db.DB.Exec("DELETE FROM material_users")
	db.DB.Exec("DELETE FROM group_users")
	db.DB.Exec("DELETE FROM groups")
}

func TestLogin(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()
	clearDatabase()

	router := SetupRouter()

	password := "password123"
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		t.Fatalf("Failed to hash password: %v", err)
	}

	user := models.User{
		Email:    "testuser@example.com",
		Username: "testuser",
		Password: string(hashedPassword),
	}
	db.DB.Create(&user)

	body := `{"email":"testuser@example.com", "password":"password123", "isGoogle":"false"}`
	req, _ := http.NewRequest("POST", "/login", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
}

func TestValidate(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()
	clearDatabase()

	router := SetupRouter()

	user := models.User{
		Email:    "testuser@example.com",
		Username: "testuser",
		Password: "password123",
		Token:    "validtoken",
	}
	db.DB.Create(&user)

	body := `{"token":"validtoken"}`
	req, _ := http.NewRequest("PATCH", "/validate", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
}

func TestLogout(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()
	clearDatabase()

	router := SetupRouter()

	req, _ := http.NewRequest("GET", "/logout", nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
}

func TestGetUsers(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()
	clearDatabase()

	router := SetupRouter()

	user := models.User{
		Email:    "testuser@example.com",
		Username: "testuser",
	}
	db.DB.Create(&user)

	req, _ := http.NewRequest("GET", "/users", nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
}

func TestUpdateRole(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()
	clearDatabase()

	router := SetupRouter()

	user := models.User{
		Email:    "testuser@example.com",
		Username: "testuser",
		Role:     "user",
	}
	db.DB.Create(&user)

	body := `{"role":"admin"}`
	req, _ := http.NewRequest("PATCH", "/users/"+strconv.Itoa(int(user.ID))+"/role", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
}

func TestDeleteUser(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()
	clearDatabase()

	router := SetupRouter()

	user := models.User{
		Email:    "testuser@example.com",
		Username: "testuser",
	}
	db.DB.Create(&user)

	req, _ := http.NewRequest("DELETE", "/users/"+strconv.Itoa(int(user.ID)), nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
}

func TestGetUserProfile(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()
	clearDatabase()

	router := SetupRouter()

	user := models.User{
		Email:    "testuser@example.com",
		Username: "testuser",
	}
	db.DB.Create(&user)

	router.Use(func(c *gin.Context) {
		c.Set("userID", user.ID)
		c.Next()
	})

	req, _ := http.NewRequest("GET", "/users/me", nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
}

func TestUpdateUser(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()
	clearDatabase()

	router := SetupRouter()

	user := models.User{
		Email:    "testuser@example.com",
		Username: "testuser",
	}
	db.DB.Create(&user)

	body := `{"username":"updateduser"}`
	req, _ := http.NewRequest("PUT", "/users/"+strconv.Itoa(int(user.ID)), bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
}
