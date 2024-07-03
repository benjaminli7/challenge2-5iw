package routes

import (
	"backend/controllers"
	"github.com/gorilla/mux"
)

func SetTrailRoutes(r *mux.Router) {
	r.HandleFunc("/trails", controllers.CreateTrailHandler).Methods("POST")
	r.HandleFunc("/trails/{id}", controllers.GetTrailHandler).Methods("GET")
}
