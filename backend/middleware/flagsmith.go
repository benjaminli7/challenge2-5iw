package middleware

import (
	"github.com/gin-gonic/gin"
	flagsmith "github.com/Flagsmith/flagsmith-go-client/v2"
)

// FlagsmithMiddleware is a middleware to inject Flagsmith client into context
func FlagsmithMiddleware(client *flagsmith.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Set("flagsmithClient", client)
		c.Next()
	}
}