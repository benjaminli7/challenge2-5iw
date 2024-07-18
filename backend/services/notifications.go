package services

import (
	"context"
	"fmt"

	"firebase.google.com/go/messaging"
)

func SendNotification(ctx context.Context, token, title, body, route string) error {
	message := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: map[string]string{
			"route": route, // Pass route to handle navigation
		},
	}

	response, err := fcmClient.Send(ctx, message)
	if err != nil {
		return err
	}

	fmt.Println("Successfully sent message:", response)
	return nil
}
