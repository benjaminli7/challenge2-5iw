package services

import (
	"fmt"
	"github.com/mailjet/mailjet-apiv3-go/v4"
	"log"
	"os"
)

func SendEmail(email string, content string, subject string) {
	apiKey := os.Getenv("API_MAIL_KEY")
    apiSecret := os.Getenv("API_MAIL_SECRET")

    mailjetClient := mailjet.NewMailjetClient(apiKey, apiSecret)

    messagesInfo := []mailjet.InfoMessagesV31{
        {
            From: &mailjet.RecipientV31{
                Email: "cborra@hotmail.fr",
                Name:  "Camille Borra",
            },
            To: &mailjet.RecipientsV31{
                {
                    Email: email,
                },
            },
            Subject:  subject,
            HTMLPart: content,
        },
    }

	messages := mailjet.MessagesV31{Info: messagesInfo}

    res, err := mailjetClient.SendMailV31(&messages)
    if err != nil {
        log.Fatalf("Erreur lors de l'envoi de l'email : %s", err)
    }

    for _, message := range res.ResultsV31 {
        fmt.Printf("Email envoyé à %s avec l'ID de Message %d et Status %s\n", message.To[0].Email,  message.Status)
    }
}