#!/bin/bash

# ==============================================
# SCRIPT DE DÉPLOIEMENT RAPIDE POUR BREV.DEV
# Crée le Dockerfile et lance l'installation
# ==============================================

set -e

echo "╔════════════════════════════════════════╗"
echo "║   DÉPLOIEMENT RAPIDE BREV.DEV         ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Vérifier si nous sommes dans le bon répertoire
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Erreur: docker-compose.yml non trouvé dans ce répertoire"
    echo "   Assurez-vous d'être dans le bon dossier"
    exit 1
fi

# Vérifier si le Dockerfile existe
if [ ! -f "Dockerfile" ]; then
    echo "⚠️  Dockerfile non trouvé dans ce répertoire"
    echo ""
    echo "OPTIONS:"
    echo "1) Télécharger tous les fichiers depuis votre PC"
    echo "2) Créer le Dockerfile manuellement (copiez le contenu depuis votre PC)"
    echo "3) Utiliser ce script pour télécharger depuis une URL (si disponible)"
    echo ""
    echo "Pour l'instant, veuillez uploader le Dockerfile dans ce répertoire."
    echo ""
    echo "Depuis votre PC Windows:"
    echo "  scp Dockerfile ubuntu@<brev-instance>:~/ai-docker/"
    echo ""
    exit 1
fi

echo "✓ Dockerfile trouvé"
echo ""

# Vérifier le GPU
echo "[1/4] Vérification du GPU..."
if nvidia-smi &> /dev/null; then
    echo "✓ GPU NVIDIA détecté"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
else
    echo "⚠️  Avertissement: GPU NVIDIA non détecté"
    echo "   L'installation continuera mais les performances seront limitées"
fi

echo ""

# Vérifier Docker
echo "[2/4] Vérification de Docker..."
if command -v docker &> /dev/null; then
    echo "✓ Docker installé"
else
    echo "❌ Docker n'est pas installé"
    echo "   Installation de Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✓ Docker installé"
fi

# Vérifier NVIDIA Container Toolkit
echo "[3/4] Vérification de NVIDIA Container Toolkit..."
if command -v nvidia-container-toolkit &> /dev/null; then
    echo "✓ NVIDIA Container Toolkit installé"
else
    echo "❌ Installation de NVIDIA Container Toolkit..."
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    sudo systemctl restart docker
    echo "✓ NVIDIA Container Toolkit installé"
fi

echo ""

# Arrêter le service systemd s'il existe
echo "[4/4] Nettoyage des services existants..."
if systemctl is-active --quiet docker-compose.service; then
    echo "⚠️  Service docker-compose.service détecté (créé par Brev)"
    echo "   Arrêt du service..."
    sudo systemctl stop docker-compose.service
    sudo systemctl disable docker-compose.service
    echo "✓ Service arrêté"
fi

# Nettoyer les containers existants
if docker ps -a | grep -q ai-container; then
    echo "⚠️  Container existant détecté, suppression..."
    docker stop ai-container 2>/dev/null || true
    docker rm ai-container 2>/dev/null || true
fi

echo ""
echo "════════════════════════════════════════"
echo "DÉMARRAGE DE LA CONSTRUCTION"
echo "════════════════════════════════════════"
echo ""
echo "⏳ Construction de l'image Docker..."
echo "   Cela peut prendre 15-30 minutes..."
echo ""

# Lancer avec Docker Compose
docker compose down 2>/dev/null || true
docker compose up -d --build

echo ""
echo "════════════════════════════════════════"
echo "✅ DÉPLOIEMENT TERMINÉ !"
echo "════════════════════════════════════════"
echo ""
echo "Le container est en cours de démarrage..."
echo "Premier démarrage : téléchargement des modèles (10-20 min)"
echo ""

# Trouver les URLs Brev
echo "📊 ACCÈS AUX INTERFACES :"
echo ""

# Détection de l'environnement Brev
if [ ! -z "$BREV_ENV_ID" ]; then
    echo "🌍 Environnement Brev détecté: $BREV_ENV_ID"
    echo ""
    echo "Les URLs devraient être accessibles via Brev:"
    echo "  • SD-Forge-Neo : https://$BREV_ENV_ID-7860.brev.dev (ou port forwarding)"
    echo "  • Open WebUI   : https://$BREV_ENV_ID-8080.brev.dev (ou port forwarding)"
    echo ""
    echo "Consultez l'interface Brev pour les URLs exactes."
else
    echo "  • SD-Forge-Neo : http://localhost:7860"
    echo "  • Open WebUI   : http://localhost:8080"
    echo "  • Ollama API   : http://localhost:11434"
fi

echo ""
echo "📋 COMMANDES UTILES :"
echo "  • Voir les logs       : docker logs -f ai-container"
echo "  • Arrêter             : docker compose down"
echo "  • Redémarrer          : docker compose restart"
echo "  • État des services   : docker exec ai-container supervisorctl status"
echo ""
echo "⏳ Suivre le téléchargement des modèles :"
echo "   docker logs -f ai-container"
echo ""
echo "════════════════════════════════════════"
