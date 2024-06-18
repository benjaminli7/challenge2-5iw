package middleware

import (
	"fmt"
	"backend/db"
	"backend/models"
	"net/http"
	"os"
	"time"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func RequireAuth(adminOnly bool) gin.HandlerFunc {
    return func(c *gin.Context) {
        // Get the cookie off the request
        println("RequireAuth middleware")
        tokenString, err := c.Cookie("Authorization")

        if err != nil {
            println("No token found")
            c.AbortWithStatus(http.StatusUnauthorized)
            return
        }

        // Decode/validate it
        token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
            // Validate the alg is what you expect:
            if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
                return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
            }

            // hmacSampleSecret is a []byte containing your secret, e.g. []byte("my_secret_key")
            return []byte(os.Getenv("SECRET")), nil
        })

        if err != nil || token == nil || !token.Valid {
            c.AbortWithStatus(http.StatusUnauthorized)
            return
        }

        // Check claims and validate expiration
        claims, ok := token.Claims.(jwt.MapClaims)
        if !ok || !token.Valid {
            c.AbortWithStatus(http.StatusUnauthorized)
            return
        }

        // Check if the token is expired
        if exp, ok := claims["exp"].(float64); ok {
            if float64(time.Now().Unix()) > exp {
                c.AbortWithStatus(http.StatusUnauthorized)
                return
            }
        }

		if float64(time.Now().Unix()) > claims["exp"].(float64) {
			c.AbortWithStatus(http.StatusUnauthorized)
		}

		// Find the user with token Subject
		var user models.User
		db.DB.First(&user,claims["sub"])

        fmt.Println("User found")
		fmt.Println(user.ID)
		fmt.Println(user.Email)
		fmt.Println(token)

        if user.ID == 0 {
            c.AbortWithStatus(http.StatusUnauthorized)
            return
        }

        // If adminOnly is true, check if the user is an admin
        if adminOnly && user.Role != "admin" {
            c.AbortWithStatus(http.StatusUnauthorized)
            return
        }

        // Attach the user to the request context
        c.Set("user", user)

        // Continue
        c.Next()
    }
}
