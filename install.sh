#!/bin/bash

# ==============================================
# SCRIPT D'INSTALLATION UNIQUE
# Docker AI All-in-One (SD-Forge-Neo + Ollama + Open WebUI)
# ==============================================

set -e  # Arrêt en cas d'erreur

echo "=============================================="
echo "INSTALLATION DOCKER AI ALL-IN-ONE"
echo "=============================================="

# ==============================================
# VÉRIFICATION DES PRÉREQUIS
# ==============================================

echo ""
echo "[1/5] Vérification des prérequis..."

# Vérification de Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Installation..."
    
    # Installation de Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    
    # Ajout de l'utilisateur au groupe docker
    sudo usermod -aG docker $USER
    
    echo "✓ Docker installé (vous devrez peut-être vous reconnecter pour utiliser Docker sans sudo)"
    rm get-docker.sh
else
    echo "✓ Docker est installé"
fi

# Vérification de NVIDIA Container Toolkit
if ! command -v nvidia-container-toolkit &> /dev/null; then
    echo "❌ NVIDIA Container Toolkit n'est pas installé. Installation..."
    
    # Installation de NVIDIA Container Toolkit
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    sudo systemctl restart docker
    
    echo "✓ NVIDIA Container Toolkit installé"
else
    echo "✓ NVIDIA Container Toolkit est installé"
fi

# Vérification du GPU NVIDIA
if ! nvidia-smi &> /dev/null; then
    echo "⚠️  AVERTISSEMENT : nvidia-smi ne fonctionne pas. Vérifiez que les drivers NVIDIA sont installés."
else
    echo "✓ GPU NVIDIA détecté :"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
fi

# ==============================================
# CRÉATION DES VOLUMES PERSISTANTS
# ==============================================

echo ""
echo "[2/5] Création des volumes persistants..."

# Création des dossiers pour volumes
mkdir -p ~/ai-docker/models
mkdir -p ~/ai-docker/outputs
mkdir -p ~/ai-docker/ollama
mkdir -p ~/ai-docker/open-webui

echo "✓ Volumes créés dans ~/ai-docker/"

# ==============================================
# CONSTRUCTION DE L'IMAGE DOCKER
# ==============================================

echo ""
echo "[3/5] Construction de l'image Docker..."
echo "⏳ Cette étape peut prendre 15-30 minutes selon votre connexion..."

docker build -t ai-allinone:latest .

echo "✓ Image Docker construite avec succès"

# ==============================================
# ARRÊT DU CONTAINER EXISTANT (SI PRÉSENT)
# ==============================================

echo ""
echo "[4/5] Vérification des containers existants..."

if docker ps -a | grep -q ai-container; then
    echo "⚠️  Container existant détecté. Arrêt et suppression..."
    docker stop ai-container || true
    docker rm ai-container || true
fi

# ==============================================
# DÉMARRAGE DU CONTAINER
# ==============================================

echo ""
echo "[5/5] Démarrage du container..."

docker run -d \
  --name ai-container \
  --gpus all \
  --restart unless-stopped \
  -p 7860:7860 \
  -p 8080:8080 \
  -p 11434:11434 \
  -v ~/ai-docker/models:/workspace/sd-forge-neo/models \
  -v ~/ai-docker/outputs:/workspace/sd-forge-neo/outputs \
  -v ~/ai-docker/ollama:/root/.ollama \
  -v ~/ai-docker/open-webui:/root/.open-webui \
  ai-allinone:latest

echo ""
echo "=============================================="
echo "✅ INSTALLATION TERMINÉE !"
echo "=============================================="
echo ""
echo "Le container est en cours de démarrage..."
echo "Premier démarrage : téléchargement des modèles (peut prendre 10-20 min)"
echo ""
echo "📊 ACCÈS AUX INTERFACES :"
echo "  • SD-Forge-Neo (Images) : http://localhost:7860"
echo "  • Open WebUI (Chat)     : http://localhost:8080"
echo "  • Ollama API            : http://localhost:11434"
echo ""
echo "📋 COMMANDES UTILES :"
echo "  • Voir les logs       : docker logs -f ai-container"
echo "  • Arrêter le container: docker stop ai-container"
echo "  • Démarrer le container: docker start ai-container"
echo "  • Redémarrer          : docker restart ai-container"
echo ""
echo "⏳ Progression du téléchargement des modèles :"
echo "   docker logs -f ai-container"
echo ""
echo "=============================================="
