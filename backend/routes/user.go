package routes

import (
	"backend/controllers"
	"github.com/gorilla/mux"
)

func SetUserRoutes(r *mux.Router) {
	r.HandleFunc("/users", controllers.CreateUserHandler).Methods("POST")
	r.HandleFunc("/users/{id}", controllers.GetUserHandler).Methods("GET")
}
