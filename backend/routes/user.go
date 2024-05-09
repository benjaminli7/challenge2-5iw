package routes

import (
    "net/http"

    "backend/controllers"
)

// SetUserRoutes définit les routes liées aux utilisateurs
func SetUserRoutes(mux *http.ServeMux) {
    mux.HandleFunc("/users", controllers.CreateUserHandler).Methods("POST")
    mux.HandleFunc("/users/{id}", controllers.GetUserHandler).Methods("GET")
    // Ajoutez d'autres routes utilisateur selon les besoins de votre application
}
