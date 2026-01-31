# 🚀 Docker AI All-in-One

Environnement Docker unique combinant **SD-Forge-Neo** (génération d'images) et **Ollama + Open WebUI** (génération de texte) dans un seul container.

## 📦 Contenu

- **SD-Forge-Neo** : Interface de génération d'images Stable Diffusion
- **Civitai Helper** : Extension pour télécharger des modèles depuis Civitai
- **Ollama** : Moteur LLM local
- **Open WebUI** : Interface web moderne pour Ollama

## 🎯 Modèles Pré-Configurés

### Checkpoints
- CyberRealistic Pony
- Nova Reality XL

### LoRAs
- Perfect Pussy
- Perfect Eyes XL
- Multiple Girls Group
- POV Group Sex

### Modèle LLM
- Mistral-Small-Instruct (via Ollama)

## ⚙️ Configuration Minimale Recommandée

- **RAM** : 16 GB (32 GB recommandé)
- **VRAM** : 8 GB minimum (12+ GB pour SDXL)
- **Stockage** : 100 GB minimum (200+ GB recommandé)
- **GPU** : NVIDIA avec support CUDA (GTX 1080 Ti / RTX 3060+)
- **OS** : Ubuntu 20.04+ avec drivers NVIDIA

## 🚀 Installation Rapide

### Option 1 : Installation Automatique (Recommandé)

```bash
# 1. Cloner ou télécharger les fichiers (Dockerfile, install.sh, README.md)
# 2. Rendre le script exécutable et lancer l'installation
chmod +x install.sh
./install.sh
```

**C'est tout !** Le script va :
- Installer Docker (si nécessaire)
- Installer NVIDIA Container Toolkit (si nécessaire)
- Construire l'image Docker
- Démarrer le container
- Télécharger tous les modèles automatiquement

### Option 2 : Installation Manuelle

```bash
# 1. Construire l'image
docker build -t ai-allinone:latest .

# 2. Créer les volumes persistants
mkdir -p ~/ai-docker/{models,outputs,ollama,open-webui}

# 3. Démarrer le container
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
```

## 🌐 Accès aux Interfaces

Une fois le container démarré (attendez 5-10 min pour le premier démarrage) :

| Service | URL | Description |
|---------|-----|-------------|
| **SD-Forge-Neo** | `http://localhost:7860` | Interface de génération d'images |
| **Open WebUI** | `http://localhost:8080` | Interface de chat avec Ollama |
| **Ollama API** | `http://localhost:11434` | API Ollama (usage interne) |

## 📊 Vérifier le Statut

```bash
# Voir les logs en temps réel
docker logs -f ai-container

# Vérifier que tous les services sont actifs
docker exec ai-container supervisorctl status

# Vérifier l'utilisation du GPU
nvidia-smi
```

## 🔧 Gestion du Container

```bash
# Arrêter le container
docker stop ai-container

# Démarrer le container
docker start ai-container

# Redémarrer le container
docker restart ai-container

# Accéder au shell du container
docker exec -it ai-container bash
```

## 📥 Ajouter de Nouveaux Modèles

### Modèles Civitai (Images)

**Option 1 : Via l'interface SD-Forge-Neo**
1. Ouvrir `http://localhost:7860`
2. Aller dans l'onglet **Civitai Helper**
3. Coller l'URL du modèle Civitai
4. Cliquer sur "Download"

**Option 2 : Manuellement**
```bash
# Les modèles sont dans ~/ai-docker/models/
# Copier vos fichiers .safetensors dans les sous-dossiers appropriés :
~/ai-docker/models/Stable-diffusion/  # Pour les checkpoints
~/ai-docker/models/Lora/              # Pour les LoRAs
~/ai-docker/models/VAE/               # Pour les VAE
```

### Modèles Ollama (Texte)

**Option 1 : Via Open WebUI**
1. Ouvrir `http://localhost:8080`
2. Menu → Admin Panel → Settings → Models
3. Télécharger depuis Ollama Library ou Hugging Face

**Option 2 : Via CLI**
```bash
# Liste des modèles disponibles
docker exec ai-container ollama list

# Télécharger un modèle
docker exec ai-container ollama pull llama3.3
docker exec ai-container ollama pull codellama
docker exec ai-container ollama pull mistral

# Supprimer un modèle
docker exec ai-container ollama rm <model-name>
```

## 🔄 Mise à Jour Sans Perte de Données

Les modèles et outputs sont stockés dans des volumes Docker persistants. Pour mettre à jour :

```bash
# 1. Arrêter et supprimer le container (les données restent dans les volumes)
docker stop ai-container
docker rm ai-container

# 2. Reconstruire l'image avec les dernières mises à jour
docker build -t ai-allinone:latest .

# 3. Redémarrer le container (même commande qu'à l'installation)
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
```

**Vos modèles et images générées seront préservés !**

## 🔒 Accès Sécurisé depuis l'Extérieur

> ⚠️ **IMPORTANT** : Ne jamais exposer directement les ports sans authentification !

### Option 1 : Reverse Proxy avec Nginx + SSL

```bash
# Installation de Nginx et Certbot
sudo apt install nginx certbot python3-certbot-nginx

# Configuration Nginx (exemple pour SD-Forge-Neo)
sudo nano /etc/nginx/sites-available/ai-forge

# Contenu :
server {
    listen 80;
    server_name votre-domaine.com;

    location / {
        proxy_pass http://localhost:7860;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Activer le site et obtenir le certificat SSL
sudo ln -s /etc/nginx/sites-available/ai-forge /etc/nginx/sites-enabled/
sudo certbot --nginx -d votre-domaine.com
sudo systemctl restart nginx
```

### Option 2 : Cloudflare Tunnel (Gratuit, Recommandé)

```bash
# Installation de cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Authentification
cloudflared tunnel login

# Création du tunnel
cloudflared tunnel create ai-tunnel

# Configuration (créer ~/.cloudflared/config.yml)
tunnel: <tunnel-id>
credentials-file: /home/<user>/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: forge.votre-domaine.com
    service: http://localhost:7860
  - hostname: chat.votre-domaine.com
    service: http://localhost:8080
  - service: http_status:404

# Démarrer le tunnel
cloudflared tunnel run ai-tunnel
```

### Option 3 : VPN (Accès Privé)

Installer WireGuard ou OpenVPN pour un accès privé sécurisé.

## 🛠️ Configuration SD-Forge-Neo

La configuration par défaut inclut :

- **Format de sauvegarde** : JPEG (qualité 95%)
- **Clip Skip** : 2
- **Sampler par défaut** : Euler
- **Clé API Civitai** : Pré-configurée
- **API activée** : Accès via `http://localhost:7860/docs`

Pour modifier la configuration :
```bash
# Éditer le fichier de config
docker exec -it ai-container nano /workspace/sd-forge-neo/config.json

# Redémarrer SD-Forge-Neo
docker exec ai-container supervisorctl restart sd-forge-neo
```

## 📁 Structure des Volumes

```
~/ai-docker/
├── models/              # Modèles SD-Forge-Neo (checkpoints, LoRAs, VAE)
├── outputs/             # Images générées
├── ollama/              # Modèles Ollama
└── open-webui/          # Données Open WebUI (conversations, paramètres)
```

## ❓ Dépannage

### Le container ne démarre pas
```bash
# Vérifier les logs
docker logs ai-container

# Vérifier l'état des services
docker exec ai-container supervisorctl status
```

### SD-Forge-Neo ne charge pas
```bash
# Redémarrer uniquement SD-Forge
docker exec ai-container supervisorctl restart sd-forge-neo

# Vérifier les logs
docker exec ai-container tail -f /var/log/sd-forge.out.log
```

### Ollama ne répond pas
```bash
# Redémarrer Ollama
docker exec ai-container supervisorctl restart ollama

# Vérifier les modèles installés
docker exec ai-container ollama list
```

### Manque d'espace disque
```bash
# Vérifier l'espace utilisé
du -sh ~/ai-docker/*

# Nettoyer les images Docker inutilisées
docker system prune -a
```

### Erreur GPU / CUDA
```bash
# Vérifier que le GPU est accessible
nvidia-smi

# Vérifier que Docker peut utiliser le GPU
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

## 📝 Notes Importantes

- **Premier démarrage** : Le téléchargement des modèles peut prendre 10-20 minutes
- **Stockage** : Prévoir ~50-70 GB pour les modèles pré-configurés
- **Performances** : Les générations d'images SDXL nécessitent au minimum 8 GB de VRAM

## 📚 Ressources

- [SD-Forge-Neo GitHub](https://github.com/Haoming02/sd-webui-forge-classic/tree/neo)
- [Civitai Helper](https://github.com/zixaphir/Stable-Diffusion-Webui-Civitai-Helper)
- [Ollama Documentation](https://ollama.com)
- [Open WebUI GitHub](https://github.com/open-webui/open-webui)

## 🤝 Support

Pour toute question ou problème :
1. Vérifier les logs : `docker logs -f ai-container`
2. Consulter la section Dépannage ci-dessus
3. Vérifier les issues GitHub des projets respectifs

---

**Bon codage et bonne création ! 🎨🤖**
