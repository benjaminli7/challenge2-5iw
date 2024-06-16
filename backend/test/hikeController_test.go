package test

import (
	"backend/controllers"
	"backend/db"
	"backend/models"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func setupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	router := gin.Default()
	router.POST("/hikes", controllers.CreateHike)
	router.GET("/hikes", controllers.GetAllHikes)
	router.GET("/hikes/:id", controllers.GetHike)
	router.PUT("/hikes/:id", controllers.UpdateHike)
	router.DELETE("/hikes/:id", controllers.DeleteHike)
	return router
}

func TestCreateHike(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := setupRouter()

	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
	}

	jsonValue, _ := json.Marshal(hike)
	req, _ := http.NewRequest("POST", "/hikes", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
	var createdHike models.Hike
	err := json.Unmarshal(resp.Body.Bytes(), &createdHike)
	assert.NoError(t, err, "Error unmarshalling response body")
	assert.Equal(t, hike.Name, createdHike.Name, "Hike names do not match")
	assert.Equal(t, hike.Description, createdHike.Description, "Hike descriptions do not match")

	if !t.Failed() {
		t.Log("TestCreateHike: OK")
	}
}

func TestGetAllHikes(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := setupRouter()

	hike := models.Hike{Name: "Test Hike", Description: "This is a test hike"}
	db.DB.Create(&hike)

	req, _ := http.NewRequest("GET", "/hikes", nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
	var hikes []models.Hike
	err := json.Unmarshal(resp.Body.Bytes(), &hikes)
	assert.NoError(t, err, "Error unmarshalling response body")
	assert.Greater(t, len(hikes), 0, "Expected at least one hike in response")

	if !t.Failed() {
		t.Log("TestGetAllHikes: OK")
	}
}

func TestGetHike(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := setupRouter()

	hike := models.Hike{Name: "Test Hike", Description: "This is a test hike"}
	db.DB.Create(&hike)

	req, _ := http.NewRequest("GET", "/hikes/"+strconv.Itoa(int(hike.ID)), nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
	var retrievedHike models.Hike
	err := json.Unmarshal(resp.Body.Bytes(), &retrievedHike)
	assert.NoError(t, err, "Error unmarshalling response body")
	assert.Equal(t, hike.Name, retrievedHike.Name, "Hike names do not match")
	assert.Equal(t, hike.Description, retrievedHike.Description, "Hike descriptions do not match")

	if !t.Failed() {
		t.Log("TestGetHike: OK")
	}
}

func TestUpdateHike(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := setupRouter()

	hike := models.Hike{Name: "Test Hike", Description: "This is a test hike"}
	db.DB.Create(&hike)

	updatedHike := models.Hike{Name: "Updated Hike", Description: "This is an updated test hike"}
	jsonValue, _ := json.Marshal(updatedHike)
	req, _ := http.NewRequest("PUT", "/hikes/"+strconv.Itoa(int(hike.ID)), bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
	var retrievedHike models.Hike
	err := json.Unmarshal(resp.Body.Bytes(), &retrievedHike)
	assert.NoError(t, err, "Error unmarshalling response body")
	assert.Equal(t, updatedHike.Name, retrievedHike.Name, "Hike names do not match")
	assert.Equal(t, updatedHike.Description, retrievedHike.Description, "Hike descriptions do not match")

	if !t.Failed() {
		t.Log("TestUpdateHike: OK")
	}
}

func TestDeleteHike(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := setupRouter()

	hike := models.Hike{Name: "Test Hike", Description: "This is a test hike"}
	db.DB.Create(&hike)

	req, _ := http.NewRequest("DELETE", "/hikes/"+strconv.Itoa(int(hike.ID)), nil)
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
	assert.NotNil(t, db.DB.First(&models.Hike{}, hike.ID).Error, "Hike should be deleted")

	if !t.Failed() {
		t.Log("TestDeleteHike: OK")
	}
}
