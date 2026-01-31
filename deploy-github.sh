#!/bin/bash

# ==============================================
# SCRIPT DE DÉPLOIEMENT GITHUB
# Initialise le repo Git et push vers GitHub
# ==============================================

echo "╔════════════════════════════════════════╗"
echo "║   DÉPLOIEMENT GITHUB                  ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Vérifier si Git est installé
if ! command -v git &> /dev/null; then
    echo "❌ Git n'est pas installé"
    echo "   Installez Git depuis: https://git-scm.com/downloads"
    exit 1
fi

echo "✓ Git est installé"
echo ""

# Vérifier si nous sommes déjà dans un repo Git
if [ -d .git ]; then
    echo "⚠️  Ce dossier est déjà un dépôt Git"
    echo ""
    read -p "Voulez-vous réinitialiser le dépôt ? (o/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        rm -rf .git
        echo "✓ Dépôt Git réinitialisé"
    else
        echo "Annulation..."
        exit 0
    fi
fi

# Initialiser le dépôt Git
echo "📦 Initialisation du dépôt Git..."
git init
echo "✓ Dépôt Git initialisé"
echo ""

# Configurer Git (si pas déjà fait globalement)
echo "⚙️  Configuration Git..."
echo ""
echo "Entrez votre nom (pour les commits) :"
read git_name
git config user.name "$git_name"

echo "Entrez votre email (pour les commits) :"
read git_email
git config user.email "$git_email"

echo "✓ Configuration Git enregistrée"
echo ""

# Ajouter tous les fichiers
echo "📄 Ajout des fichiers au dépôt..."
git add .
echo "✓ Fichiers ajoutés"
echo ""

# Créer le premier commit
echo "💾 Création du commit initial..."
git commit -m "Initial commit: Docker AI All-in-One (SD-Forge-Neo + Ollama + Open WebUI)"
echo "✓ Commit créé"
echo ""

# Demander l'URL du dépôt GitHub
echo "════════════════════════════════════════"
echo "CONFIGURATION GITHUB"
echo "════════════════════════════════════════"
echo ""
echo "Avant de continuer, créez un nouveau dépôt sur GitHub :"
echo "  1. Allez sur https://github.com/new"
echo "  2. Nom suggéré: docker-ai-allinone"
echo "  3. Description suggérée: Docker container combining SD-Forge-Neo, Ollama, and Open WebUI"
echo "  4. NE PAS initialiser avec README, .gitignore ou license"
echo "  5. Cliquez sur 'Create repository'"
echo ""
echo "Une fois créé, copiez l'URL du dépôt (format: https://github.com/username/repo.git)"
echo ""
read -p "Collez l'URL du dépôt GitHub: " github_url

if [ -z "$github_url" ]; then
    echo "❌ URL vide, annulation..."
    exit 1
fi

# Ajouter le remote
echo ""
echo "🔗 Ajout du remote GitHub..."
git remote add origin "$github_url"
echo "✓ Remote ajouté"
echo ""

# Renommer la branche en main (convention moderne)
echo "🌿 Renommage de la branche en 'main'..."
git branch -M main
echo "✓ Branche renommée"
echo ""

# Push vers GitHub
echo "🚀 Envoi vers GitHub..."
echo ""
git push -u origin main

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   ✅ DÉPLOIEMENT GITHUB TERMINÉ !     ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🌐 Votre dépôt est maintenant disponible sur GitHub !"
echo "   URL: $github_url"
echo ""
echo "📋 Pour cloner sur une autre machine :"
echo "   git clone $github_url"
echo ""
echo "🔄 Pour mettre à jour après des modifications :"
echo "   git add ."
echo "   git commit -m \"Description des changements\""
echo "   git push"
echo ""
