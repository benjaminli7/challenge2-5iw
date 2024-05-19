package controllers

import (
	"backend/models"
	"encoding/json"
	"github.com/gorilla/mux"
	"net/http"
)

func CreateTrailHandler(w http.ResponseWriter, r *http.Request) {
	var trail models.Trail
	err := json.NewDecoder(r.Body).Decode(&trail)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	result := db.Create(&trail)
	if result.Error != nil {
		http.Error(w, result.Error.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(trail)
}

func GetTrailHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	var trail models.Trail
	result := db.First(&trail, id)
	if result.Error != nil {
		http.Error(w, result.Error.Error(), http.StatusNotFound)
		return
	}
	json.NewEncoder(w).Encode(trail)
}
