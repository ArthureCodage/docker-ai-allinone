# 🚀 GUIDE DE DÉMARRAGE RAPIDE

## Installation Ultra-Rapide (3 commandes)

```bash
chmod +x install.sh     # Rendre le script exécutable
./install.sh            # Installer et démarrer
./manage.sh             # Gérer le container (optionnel)
```

---

## 🌐 URLs d'Accès

| Service | URL | Description |
|---------|-----|-------------|
| **SD-Forge-Neo** | http://localhost:7860 | Génération d'images |
| **Open WebUI** | http://localhost:8080 | Chat avec Ollama |
| **Ollama API** | http://localhost:11434 | API interne |

---

## 📋 Commandes Essentielles

### Container
```bash
docker start ai-container      # Démarrer
docker stop ai-container       # Arrêter
docker restart ai-container    # Redémarrer
docker logs -f ai-container    # Voir les logs
```

### Modèles Ollama
```bash
docker exec ai-container ollama list              # Liste
docker exec ai-container ollama pull mistral      # Télécharger
docker exec ai-container ollama rm mistral        # Supprimer
```

### Services (Supervisor)
```bash
docker exec ai-container supervisorctl status           # État
docker exec ai-container supervisorctl restart ollama   # Redémarrer
```

---

## 🛠️ Script de Gestion Interactif

Pour une gestion facile via menu :
```bash
chmod +x manage.sh
./manage.sh
```

Menu disponible :
- ✅ Voir le statut
- ▶️ Démarrer/Arrêter/Redémarrer
- 📋 Logs en temps réel
- 💻 Utilisation ressources (CPU/GPU)
- 🐚 Shell dans le container
- 📦 Gérer modèles Ollama
- 🔄 Redémarrer services individuels
- 💾 Backup des modèles

---

## 📁 Structure des Fichiers

```
~/ai-docker/
├── models/              # Modèles SD (40+ GB)
│   ├── Stable-diffusion/
│   ├── Lora/
│   └── VAE/
├── outputs/             # Images générées
├── ollama/              # Modèles LLM (5-10 GB/modèle)
└── open-webui/          # Config + Conversations
```

---

## ⚡ Premiers Tests

### Test SD-Forge-Neo
1. Ouvrir http://localhost:7860
2. Entrer un prompt : "a beautiful landscape, photorealistic"
3. Cliquer "Generate"

### Test Ollama
1. Ouvrir http://localhost:8080
2. Créer un compte (premier utilisateur = admin)
3. Demander : "Explique-moi ce qu'est l'IA en une phrase"

---

## 🔧 Dépannage Rapide

### Container ne démarre pas
```bash
docker logs ai-container  # Voir l'erreur
```

### GPU non détecté
```bash
nvidia-smi  # Vérifier le GPU
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### Service ne répond pas
```bash
docker exec ai-container supervisorctl status
docker exec ai-container supervisorctl restart <service-name>
```

---

## 🔒 Accès Distant Sécurisé

### Option 1 : SSH Tunnel (Rapide)
```bash
# Sur votre PC local
ssh -L 7860:localhost:7860 -L 8080:localhost:8080 user@vps-ip

# Accéder à http://localhost:7860 localement
```

### Option 2 : Cloudflare Tunnel (Gratuit)
```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
cloudflared tunnel login
cloudflared tunnel create ai-tunnel
```

---

## 💾 Backup Rapide

```bash
# Backup complet
tar czf backup-$(date +%Y%m%d).tar.gz ~/ai-docker/

# Backup modèles uniquement
tar czf models-backup.tar.gz ~/ai-docker/models/

# Restaurer
tar xzf backup-*.tar.gz -C ~/
```

---

## 📊 Monitoring

```bash
# Ressources en temps réel
docker stats ai-container

# GPU en temps réel
watch -n 1 nvidia-smi

# Logs des services
docker exec ai-container tail -f /var/log/sd-forge.out.log
docker exec ai-container tail -f /var/log/ollama.out.log
```

---

## ⚙️ Configuration Avancée

### Changer le port SD-Forge
```bash
docker stop ai-container
# Modifier le port dans docker run: -p 8860:7860
docker start ai-container
```

### Ajouter un modèle manuellement
```bash
# Copier dans le volume
cp model.safetensors ~/ai-docker/models/Stable-diffusion/
docker restart ai-container
```

---

## 🆘 Support

1. **Logs** : `docker logs -f ai-container`
2. **GitHub** : Voir les issues des projets
3. **Documentation** : Lire README.md complet

---

**Durée d'installation** : ~30-40 minutes (première fois)  
**Espace requis** : ~100 GB  
**VRAM minimale** : 8 GB
