package models

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestHikeCreation(t *testing.T) {
	hike := Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		Difficulty:  3,
		StartDate:   time.Now(),
		EndDate:     time.Now().Add(2 * time.Hour),
		OrganizerID: 1,
	}

	assert.Equal(t, "Test Hike", hike.Name)
	assert.Equal(t, "This is a test hike", hike.Description)
	assert.False(t, hike.StartDate.IsZero())
	assert.False(t, hike.EndDate.IsZero())
	assert.Equal(t, 3, hike.Difficulty)
	assert.Equal(t, uint(1), hike.OrganizerID)
}
