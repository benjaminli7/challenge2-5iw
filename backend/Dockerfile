# Utilisez une image Go officielle comme image de base
FROM golang:1.20

# Définissez le répertoire de travail à /app
WORKDIR /app

# Copiez go.mod et go.sum, puis téléchargez les dépendances
COPY go.mod go.sum ./
RUN go mod download

# Copiez le reste des fichiers de l'application
COPY . .

# Expose le port sur lequel l'application écoute
EXPOSE 5000

# Compile l'application Go
RUN go build -o main .

# Commande pour exécuter l'application
CMD ["./main"]
