package test

import (
	"backend/db"
	"backend/models"
	"bytes"
	"encoding/json"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCreateHike(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := SetupRouter()

	// Create a buffer to write our multipart/form-data request
	body := new(bytes.Buffer)
	writer := multipart.NewWriter(body)
	err := writer.WriteField("name", "Test Hike")
	if err != nil {
		return
	}
	err = writer.WriteField("description", "This is a test hike")
	if err != nil {
		return
	}
	err = writer.WriteField("organizer_id", "1")
	if err != nil {
		return
	}
	err = writer.WriteField("difficulty", "Moderate")
	if err != nil {
		return
	}
	err = writer.WriteField("duration", "3")
	if err != nil {
		return
	}
	err = writer.Close()
	if err != nil {
		return
	}

	req, _ := http.NewRequest("POST", "/hikes", body)
	req.Header.Set("Content-Type", writer.FormDataContentType())
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
	var createdHike models.Hike
	err = json.Unmarshal(resp.Body.Bytes(), &createdHike)
	assert.NoError(t, err, "Error unmarshalling response body")
	assert.Equal(t, "Test Hike", createdHike.Name, "Hike names do not match")
	assert.Equal(t, "This is a test hike", createdHike.Description, "Hike descriptions do not match")
	assert.Equal(t, "Moderate", createdHike.Difficulty, "Hike difficulty levels do not match")
	assert.Equal(t, 3, createdHike.Duration, "Hike durations do not match")

	if !t.Failed() {
		t.Log("TestCreateHike: OK")
	}
}

func TestGetAllHikes(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := SetupRouter()

	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		OrganizerID: 1,
		Difficulty:  "Moderate",
		Duration:    3,
	}
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

	router := SetupRouter()

	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		OrganizerID: 1,
		Difficulty:  "Moderate",
		Duration:    3,
	}
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
	assert.Equal(t, hike.Difficulty, retrievedHike.Difficulty, "Hike difficulty levels do not match")
	assert.Equal(t, hike.Duration, retrievedHike.Duration, "Hike durations do not match")

	if !t.Failed() {
		t.Log("TestGetHike: OK")
	}
}

func TestUpdateHike(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := SetupRouter()

	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		OrganizerID: 1,
		Difficulty:  "Moderate",
		Duration:    3,
	}
	db.DB.Create(&hike)

	// Create a buffer to write our multipart/form-data request
	body := new(bytes.Buffer)
	writer := multipart.NewWriter(body)
	err := writer.WriteField("name", "Updated Hike")
	if err != nil {
		return
	}
	err = writer.WriteField("description", "This is an updated test hike")
	if err != nil {
		return
	}
	err = writer.WriteField("difficulty", "Hard")
	if err != nil {
		return
	}
	err = writer.WriteField("duration", "5")
	if err != nil {
		return
	}
	err = writer.Close()
	if err != nil {
		return
	}

	req, _ := http.NewRequest("PUT", "/hikes/"+strconv.Itoa(int(hike.ID)), body)
	req.Header.Set("Content-Type", writer.FormDataContentType())
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code, "Expected status code 200")
	var retrievedHike models.Hike
	err = json.Unmarshal(resp.Body.Bytes(), &retrievedHike)
	assert.NoError(t, err, "Error unmarshalling response body")
	assert.Equal(t, "Updated Hike", retrievedHike.Name, "Hike names do not match")
	assert.Equal(t, "This is an updated test hike", retrievedHike.Description, "Hike descriptions do not match")
	assert.Equal(t, "Hard", retrievedHike.Difficulty, "Hike difficulty levels do not match")
	assert.Equal(t, 5, retrievedHike.Duration, "Hike durations do not match")

	if !t.Failed() {
		t.Log("TestUpdateHike: OK")
	}
}

func TestDeleteHike(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := SetupRouter()

	hike := models.Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		OrganizerID: 1,
		Difficulty:  "Moderate",
		Duration:    3,
	}
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

func TestCreateHikeInvalidData(t *testing.T) {
	db.TestDatabaseInit()
	defer db.TestDatabaseDestroy()

	router := SetupRouter()

	body := new(bytes.Buffer)
	writer := multipart.NewWriter(body)
	err := writer.WriteField("name", "")
	if err != nil {
		return
	}
	err = writer.WriteField("description", "")
	if err != nil {
		return
	}
	err = writer.WriteField("organizer_id", "")
	if err != nil {
		return
	}
	err = writer.WriteField("difficulty", "")
	if err != nil {
		return
	}
	err = writer.WriteField("duration", "")
	if err != nil {
		return
	}
	err = writer.Close()
	if err != nil {
		return
	}

	req, _ := http.NewRequest("POST", "/hikes", body)
	req.Header.Set("Content-Type", writer.FormDataContentType())
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusBadRequest, resp.Code, "Expected status code 400")

	if !t.Failed() {
		t.Log("TestCreateHikeInvalidData: OK")
	}
}
