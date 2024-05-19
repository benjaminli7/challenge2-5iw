package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
)

func generateRandomToken(length int) (string, error) {
	// Determine the number of bytes needed for the token based on the desired length
	numBytes := length / 2 // Since each byte represents two characters in hexadecimal representation

	// Create a byte slice to hold the random bytes
	tokenBytes := make([]byte, numBytes)

	// Read random bytes from crypto/rand
	_, err := rand.Read(tokenBytes)
	if err != nil {
		return "", err
	}

	// Convert the random bytes to a hexadecimal string
	token := hex.EncodeToString(tokenBytes)

	// Ensure the token has the desired length by truncating or padding with zeros as needed
	if len(token) < length {
		token += "00000000000000000000" // Add zeros to reach the desired length
	}
	return token[:length], nil // Truncate to the desired length
}

func main() {
	// Generate a random verification token with a length of 16 characters
	token, err := generateRandomToken(32)
	if err != nil {
		fmt.Println("Error generating token:", err)
		return
	}
	fmt.Println("Random verification token:", token)
}