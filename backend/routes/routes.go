package routes

import (
	"github.com/gorilla/mux"
)

func SetupRouter() *mux.Router {
	r := mux.NewRouter()
	SetUserRoutes(r)
	SetTrailRoutes(r)
	return r
}
