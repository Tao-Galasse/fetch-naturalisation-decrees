# Naturalisation - Récupération des décrets du JORF

Script Ruby pour récupérer les décrets de naturalisation publiés au Journal Officiel de la République Française via l'API Légifrance (PISTE).

## Installation

### Prérequis
- Ruby 3.4.8
- Bundler

### Installer les dépendances

```bash
bundle install
```

## Configuration

### 1. Créer un compte API Légifrance

1. Créer un compte sur [PISTE](https://piste.gouv.fr)
2. S'abonner à l'API Légifrance
3. Créer une application pour obtenir ses credentials (client_id et client_secret)

### 2. Configurer un bot Discord (optionnel)

Pour recevoir des notifications Discord lorsque de nouveaux décrets sont trouvés :

1. Créer un bot Discord sur le [Discord Developer Portal](https://discord.com/developers/applications)
2. Récupérer le token du bot
3. Inviter le bot sur votre serveur
4. Récupérer l'ID du salon où vous souhaitez recevoir les notifications

### 3. Configurer les variables d'environnement

```bash
export LEGIFRANCE_CLIENT_ID='votre_client_id'
export LEGIFRANCE_CLIENT_SECRET='votre_client_secret'
export DISCORD_TOKEN='votre_token_discord'
export DISCORD_CHANNEL_ID='id_du_salon'
```

Ou créer un fichier `.env` :
```
LEGIFRANCE_CLIENT_ID=votre_client_id
LEGIFRANCE_CLIENT_SECRET=votre_client_secret
DISCORD_TOKEN=votre_token_discord
DISCORD_CHANNEL_ID=id_du_salon
```

## Usage

```bash
ruby fetch_naturalisation_decrees.rb
```

Le script va :
1. S'authentifier auprès de l'API Légifrance
2. Rechercher les décrets de naturalisation récents
3. Récupérer les URLs des PDFs disponibles
4. Envoyer une notification Discord avec les URLs trouvées (si configuré)

## Automatisation avec GitHub Actions

Le projet inclut un workflow GitHub Actions qui exécute automatiquement le script quotidiennement à 8h UTC (10h en été / 9h en hiver en France métropolitaine).

### Configuration des secrets GitHub

Pour activer l'automatisation :

1. Aller dans les paramètres du repository : **Settings** → **Secrets and variables** → **Actions**
2. Ajouter les secrets suivants :
   - `LEGIFRANCE_CLIENT_ID` : votre client ID Légifrance
   - `LEGIFRANCE_CLIENT_SECRET` : votre client secret Légifrance
   - `DISCORD_TOKEN` : votre token Discord (optionnel)
   - `DISCORD_CHANNEL_ID` : l'ID du salon Discord (optionnel)

### Exécution manuelle

Il est également possible de déclencher le workflow manuellement :
1. Aller dans l'onglet **Actions** du repository
2. Sélectionner le workflow "Fetch naturalisation decrees"
3. Cliquer sur **Run workflow**

## Limitations

Les décrets de naturalisation sont protégés par la loi (article L. 221-14). Le contenu détaillé nécessite un accès protégé sur Légifrance et ne peut pas être récupéré directement via l'API standard.

## Gems utilisées

- `discordrb` - Client Discord pour l'envoi de notifications
- `rest-client` - Client HTTP pour les appels API
