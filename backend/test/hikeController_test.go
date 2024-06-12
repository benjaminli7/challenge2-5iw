package test

import (
	"backend/controllers"
	"backend/db"
	"backend/models"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strconv"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

var router *gin.Engine

func TestMain(m *testing.M) {
	db.TestDatabaseInit()

	router = gin.Default()
	router.POST("/hikes", controllers.CreateHike)
	router.GET("/hikes", controllers.GetAllHikes)
	router.GET("/hikes/:id", controllers.GetHike)
	router.PUT("/hikes/:id", controllers.UpdateHike)
	router.DELETE("/hikes/:id", controllers.DeleteHike)

	code := m.Run()

	db.TestDatabaseDestroy()

	os.Exit(code)
}

func TestCreateHike(t *testing.T) {
	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		StartDate:   time.Now(),
		EndDate:     time.Now().Add(2 * time.Hour),
		OrganizerID: 1,
	}
	jsonValue, _ := json.Marshal(hike)

	req, _ := http.NewRequest("POST", "/hikes", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
	var createdHike models.Hike
	json.Unmarshal(resp.Body.Bytes(), &createdHike)
	assert.Equal(t, hike.Name, createdHike.Name)
	assert.Equal(t, hike.Description, createdHike.Description)
}

func TestGetHikes(t *testing.T) {
	req, _ := http.NewRequest("GET", "/hikes", nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
	var hikes []models.Hike
	json.Unmarshal(resp.Body.Bytes(), &hikes)
	assert.NotEmpty(t, hikes)
}

func TestGetHike(t *testing.T) {
	// First create an hike
	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		StartDate:   time.Now(),
		EndDate:     time.Now().Add(2 * time.Hour),
		OrganizerID: 1,
	}
	db.TestDB.Create(&hike)

	req, _ := http.NewRequest("GET", "/hikes/"+strconv.Itoa(int(hike.ID)), nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
	var fetchedHike models.Hike
	json.Unmarshal(resp.Body.Bytes(), &fetchedHike)
	assert.Equal(t, hike.Name, fetchedHike.Name)
	assert.Equal(t, hike.Description, fetchedHike.Description)
}

func TestUpdateHike(t *testing.T) {
	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		StartDate:   time.Now(),
		EndDate:     time.Now().Add(2 * time.Hour),
		OrganizerID: 1,
	}
	db.TestDB.Create(&hike)

	hike.Name = "Updated Hike"
	jsonValue, _ := json.Marshal(hike)

	req, _ := http.NewRequest("PUT", "/hikes/"+strconv.Itoa(int(hike.ID)), bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
	var updatedHike models.Hike
	json.Unmarshal(resp.Body.Bytes(), &updatedHike)
	assert.Equal(t, "Updated Hike", updatedHike.Name)
}

func TestDeleteHike(t *testing.T) {
	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		StartDate:   time.Now(),
		EndDate:     time.Now().Add(2 * time.Hour),
		OrganizerID: 1,
	}
	db.TestDB.Create(&hike)

	req, _ := http.NewRequest("DELETE", "/hikes/"+strconv.Itoa(int(hike.ID)), nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
}
