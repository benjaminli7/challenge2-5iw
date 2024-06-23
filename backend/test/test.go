package test

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
)

func generateRandomToken(length int) (string, error) {
	numBytes := length / 2

	tokenBytes := make([]byte, numBytes)

	_, err := rand.Read(tokenBytes)
	if err != nil {
		return "", err
	}

	token := hex.EncodeToString(tokenBytes)

	if len(token) < length {
		token += "00000000000000000000"
	}
	return token[:length], nil
}

func main() {
	token, err := generateRandomToken(32)
	if err != nil {
		fmt.Println("Error generating token:", err)
		return
	}
	fmt.Println("Random verification token:", token)
}
