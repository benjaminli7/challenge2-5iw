package controllers

import (
	"backend/db"
	"backend/services"
	"net/http"

	"github.com/gorilla/websocket"

	"backend/models"
	"log"
	"strconv"
	"sync"

	"github.com/gin-gonic/gin"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type ConnectionManager struct {
	connections map[uint][]*websocket.Conn
	mutex       sync.Mutex
}

var manager = ConnectionManager{
	connections: make(map[uint][]*websocket.Conn),
}

func broadcastMessage(groupID uint, message models.Message) {
	manager.mutex.Lock()
	defer manager.mutex.Unlock()

	for _, conn := range manager.connections[groupID] {
		if err := conn.WriteJSON(message); err != nil {
			log.Printf("Error broadcasting message: %v", err)
		}
	}
}

func HandleWebSocket(c *gin.Context) {
	groupIDStr := c.Param("groupID")
	ws, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("Failed to upgrade connection: %v", err)
		return
	}

	// Convert groupID from string to uint
	groupIDUint, err := strconv.ParseUint(groupIDStr, 10, 32)
	if err != nil {
		log.Printf("Invalid group ID: %v", err)
		ws.Close()
		return
	}
	groupID := uint(groupIDUint)

	log.Printf("WebSocket connection established for group %d", groupID)

	// Add connection to the manager
	manager.mutex.Lock()
	manager.connections[groupID] = append(manager.connections[groupID], ws)
	manager.mutex.Unlock()

	defer func() {
		manager.mutex.Lock()
		for i, conn := range manager.connections[groupID] {
			if conn == ws {
				manager.connections[groupID] = append(manager.connections[groupID][:i], manager.connections[groupID][i+1:]...)
				break
			}
		}
		manager.mutex.Unlock()
		ws.Close()
	}()

	for {
		var message models.Message
		err := ws.ReadJSON(&message)
		if err != nil {
			log.Printf("Error reading JSON: %v", err)
			break
		}

		message.GroupID = groupID
		log.Printf("Received message: %s", message.Content)

		if err := db.DB.Create(&message).Error; err != nil {
			log.Printf("Error saving message to database: %v", err)
			break
		}

		// get the group users
		var group models.Group
		if err := db.DB.Preload("Users").First(&group, groupID).Error; err != nil {
			log.Printf("Error loading group data: %v", err)
			break
		}

		for _, user := range group.Users {
			if user.ID == message.UserID {
				continue
			}

			services.SendNotification(c, user.FcmToken, "New message on the group "+group.Name, message.Content, "/group-chat/"+strconv.Itoa(int(groupID)))
		}

		//send notification to all users in the group except the sender

		if err := db.DB.Preload("User").First(&message, message.ID).Error; err != nil {
			log.Printf("Error loading user data: %v", err)
			break
		}

		broadcastMessage(groupID, message)
		log.Printf("Message broadcasted: %s", message)
	}
}
