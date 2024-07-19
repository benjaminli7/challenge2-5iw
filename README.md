# 🌿 LeafMeet API

Bienvenue dans LeafMeet, votre compagnon idéal pour documenter vos aventures en randonnée. Cette application vous permet de créer un carnet de bord numérique complet, capturant les moments inoubliables de vos expéditions en plein air.

## 🚀 Démarrage rapide

### Prérequis

- 🐳 [Docker](https://www.docker.com/get-started)
- 🐹 [Go](https://golang.org/dl/) (version 1.20 ou supérieure)

### 📦 Installation

1. **Build&lancer le docker**

   ```bash
    docker-compose up --build

   ```

2. **Build&lancer go**

   ```bash
    go mod tidy
    go run main.go
   ```

a.**Accédez à Swagger UI**

- Ouvrez votre navigateur et accédez à http://localhost:8080/swagger/index.html/

b.**Accédez au BO**
- Lancer la version web avec : flutter run -d chrome --web-browser-flag "--disable-web-security"

### 🛠️ Lancement des tests

- Vérifiez que le docker est bien lancé avec le conteneur postgres_test

**Dans le repertoire /backend/test**

```bash
 go test ./test -v
```


## Membres du Projet

| Nom    | Prénom    | Compte GitHub          |
|--------|-----------|------------------------|
| BORRA  | Camille   | [CamilleBorra](https://github.com/CamilleBorra) |
| LI     | Benjamin  | [benjaminli7](https://github.com/benjaminli7) |
| SAMSON | Alexandre | [Agraval](https://github.com/Agraval) |
| YALICHEFF| Sébastien   | [syalicheff](https://github.com/syalicheff) |


## Fonctionnalités du Projet

Alexandre = A,
Benjamin = B,
Camille = C,
Sébastien = S

- **Page explorer** ->A, C, S
- **Création hike** -> A, B, C, S
- **Détails hike** -> A, B, C, S
- **Groupe** -> B, C, S
- **Materiel**-> B, S
- **Photo**->B, S
- **Météo**-> S
- **Avis** -> A
- **Chat** -> B
- **Profil**->A
- **Admin**->C, B, S
- **Feature flipping**->B, S

