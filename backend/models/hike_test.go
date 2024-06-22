package models

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestHikeCreation(t *testing.T) {
	hike := Hike{
		Name:        "Test Hike",
		Description: "This is a test hike",
		OrganizerID: 1,
	}

	assert.Equal(t, "Test Hike", hike.Name)
	assert.Equal(t, "This is a test hike", hike.Description)
	assert.Equal(t, uint(1), hike.OrganizerID)
}
