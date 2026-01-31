# Notes Techniques et Améliorations Futures

## 🔍 Points d'Attention

### Téléchargement des Modèles Civitai
- Le script utilise l'API Civitai pour télécharger les modèles
- Certains modèles peuvent nécessiter une authentification supplémentaire
- Si un téléchargement échoue, vous pouvez télécharger manuellement et placer dans `~/ai-docker/models/`

### Modèle Ollama Personnalisé
- Le modèle Mistral-Small-Instruct-2409-abliterated de Hugging Face peut ne pas être directement compatible avec Ollama
- Alternative : utiliser `mistral` ou `mistral-small` depuis la bibliothèque Ollama officielle
- Pour utiliser le modèle HF, il faut le convertir au format GGUF

### Performances
- Le premier démarrage est long (téléchargement des modèles)
- Pour accélérer : pré-télécharger les modèles et les placer dans les volumes avant le premier démarrage

## 🚀 Améliorations Possibles

### 1. Optimisation de la Taille de l'Image
```dockerfile
# Utiliser une image de base plus légère
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04  # runtime au lieu de devel
```

### 2. Cache des Téléchargements
```bash
# Créer un volume de cache pour accélérer les rebuilds
-v ~/ai-docker/cache:/root/.cache
```

### 3. Configuration Avancée SD-Forge
```json
{
  "sd_model_checkpoint": "CyberRealistic-Pony.safetensors",
  "sd_vae": "Automatic",
  "CLIP_stop_at_last_layers": 2,
  "enable_pnginfo": true,
  "samples_save": true,
  "samples_format": "jpg",
  "jpeg_quality": 95,
  "grid_save": true,
  "return_grid": true,
  "enable_emphasis": true,
  "enable_batch_seeds": true,
  "comma_padding_backtrack": 20,
  "upscaling_max_images_in_cache": 5
}
```

### 4. Authentification Open WebUI
```bash
# Ajouter des variables d'environnement pour sécuriser Open WebUI
-e WEBUI_SECRET_KEY="votre-cle-secrete"
-e WEBUI_AUTH="true"
```

### 5. Multi-Container (Docker Compose)
Pour une architecture plus modulaire, créer un `docker-compose.yml` :

```yaml
version: '3.8'

services:
  ollama:
    image: ollama/ollama:latest
    runtime: nvidia
    volumes:
      - ollama-data:/root/.ollama
    ports:
      - "11434:11434"

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    depends_on:
      - ollama
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    volumes:
      - open-webui-data:/app/backend/data
    ports:
      - "8080:8080"

  sd-forge:
    build: .
    runtime: nvidia
    volumes:
      - sd-models:/workspace/models
      - sd-outputs:/workspace/outputs
    ports:
      - "7860:7860"

volumes:
  ollama-data:
  open-webui-data:
  sd-models:
  sd-outputs:
```

## 📊 Monitoring

### Utilisation des Ressources
```bash
# CPU/RAM/GPU en temps réel
docker stats ai-container

# GPU uniquement
watch -n 1 nvidia-smi
```

### Logs Structurés
```bash
# Logs SD-Forge uniquement
docker exec ai-container tail -f /var/log/sd-forge.out.log

# Logs Ollama uniquement
docker exec ai-container tail -f /var/log/ollama.out.log

# Logs Open WebUI uniquement
docker exec ai-container tail -f /var/log/open-webui.out.log
```

## 🔒 Sécurité Production

### 1. Pare-feu
```bash
# Autoriser uniquement les connexions depuis des IPs spécifiques
sudo ufw allow from 192.168.1.0/24 to any port 7860
sudo ufw allow from 192.168.1.0/24 to any port 8080
```

### 2. Authentification HTTP Basic
```nginx
# Nginx avec authentification
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:7860;
}
```

### 3. Rate Limiting
```nginx
# Limiter les requêtes pour éviter les abus
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/m;
location /api/ {
    limit_req zone=api_limit burst=5;
    proxy_pass http://localhost:7860;
}
```

## 🧪 Tests

### Tester SD-Forge-Neo via API
```bash
curl -X POST http://localhost:7860/sdapi/v1/txt2img \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "a beautiful landscape",
    "steps": 20,
    "width": 512,
    "height": 512
  }'
```

### Tester Ollama
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "mistral",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

## 📝 Variables d'Environnement Utiles

```bash
# SD-Forge
COMMANDLINE_ARGS="--listen --port 7860 --xformers --api --enable-insecure-extension-access"

# Ollama
OLLAMA_HOST=0.0.0.0:11434
OLLAMA_MODELS=/root/.ollama/models

# Open WebUI
WEBUI_AUTH=true
WEBUI_SECRET_KEY=changeme
OLLAMA_BASE_URL=http://localhost:11434
```

## 🎯 Cas d'Usage

### Génération en Batch
```python
import requests

# Générer plusieurs images
prompts = [
    "a cat in space",
    "a dog on the moon",
    "a bird in the ocean"
]

for prompt in prompts:
    response = requests.post(
        "http://localhost:7860/sdapi/v1/txt2img",
        json={
            "prompt": prompt,
            "steps": 30,
            "width": 512,
            "height": 512,
            "sampler_name": "Euler"
        }
    )
    # Traiter la réponse...
```

### Chat Automatisé avec Ollama
```python
import requests

def chat(message):
    response = requests.post(
        "http://localhost:11434/api/chat",
        json={
            "model": "mistral",
            "messages": [{"role": "user", "content": message}],
            "stream": False
        }
    )
    return response.json()["message"]["content"]
```

## 🔄 Backup et Restauration

### Backup
```bash
# Sauvegarder tous les volumes
docker run --rm \
  -v ~/ai-docker:/backup \
  -v backup-data:/data \
  ubuntu tar czf /data/ai-backup-$(date +%Y%m%d).tar.gz /backup

# Sauvegarder uniquement les modèles
tar czf models-backup.tar.gz ~/ai-docker/models/
```

### Restauration
```bash
# Restaurer depuis la sauvegarde
tar xzf models-backup.tar.gz -C ~/ai-docker/
```

---

**Date de création** : 2026-01-30
**Dernière mise à jour** : 2026-01-30
