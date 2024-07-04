package models

type ErrorResponse struct {
	Error string `json:"error"`
}

type SuccessResponse struct {
	Message string `json:"message"`
}

type UserListResponse struct {
	Users []User `json:"users"`
}

type GroupListResponse struct {
	Groups []Group `json:"groups"`
}