# 🚀 Guide de Déploiement sur Brev.dev

## ❌ Problème Rencontré

Erreur: `failed to read dockerfile: open Dockerfile: no such file or directory`

**Cause:** Le fichier `docker-compose.yml` a été uploadé seul, sans le `Dockerfile` nécessaire.

---

## ✅ Solution 1 : Transférer Tous les Fichiers (RECOMMANDÉ)

### Étape 1 : Télécharger tous les fichiers sur Brev

Sur votre instance Brev, créez un dossier et transférez TOUS les fichiers :

```bash
# Se connecter à Brev
ssh ubuntu@<votre-instance-brev>

# Créer le dossier de travail
mkdir -p ~/ai-docker
cd ~/ai-docker
```

Puis depuis votre PC Windows, transférez les fichiers :

```powershell
# Depuis PowerShell (dans c:\DEV\DEV 9\)
scp Dockerfile docker-compose.yml .dockerignore install.sh manage.sh test.sh README.md ubuntu@<instance-brev>:~/ai-docker/
```

### Étape 2 : Utiliser install.sh (Plus Simple)

```bash
cd ~/ai-docker
chmod +x install.sh
./install.sh
```

**OU** utiliser docker-compose :

```bash
cd ~/ai-docker
docker-compose up -d
```

---

## ✅ Solution 2 : Utiliser l'Interface Brev

### Via l'Interface Web Brev

1. Aller dans votre instance Brev
2. Ouvrir le File Explorer / Terminal
3. Créer un dossier `ai-docker`
4. **Uploader tous les fichiers** dans ce dossier :
   - ✅ Dockerfile
   - ✅ docker-compose.yml
   - ✅ .dockerignore
   - ✅ install.sh
   - ✅ manage.sh
   - ✅ test.sh

5. Ouvrir un terminal et exécuter :

```bash
cd ~/ai-docker
chmod +x install.sh
./install.sh
```

---

## ✅ Solution 3 : Créer le Dockerfile Directement sur Brev

Si vous ne pouvez pas transférer les fichiers, créez le Dockerfile directement :

```bash
# Sur Brev
cd ~/ai-docker  # ou le dossier où se trouve docker-compose.yml
nano Dockerfile
```

Puis copiez-collez le contenu complet du Dockerfile (depuis le fichier local).

Ensuite :

```bash
docker-compose up -d
```

---

## 🎯 Vérification Rapide

Avant de lancer docker-compose, vérifiez que tous les fichiers sont présents :

```bash
cd ~/ai-docker
ls -la

# Vous devriez voir :
# - Dockerfile
# - docker-compose.yml
# - .dockerignore (optionnel mais recommandé)
```

---

## 🔧 Commandes Brev Spécifiques

### Vérifier l'État du Déploiement

```bash
# Voir les logs systemd
journalctl -xeu docker-compose.service

# Voir l'état du service
systemctl status docker-compose.service

# Redémarrer le service
sudo systemctl restart docker-compose.service
```

### Méthode Manuelle (Sans systemd)

Si le service systemd pose problème, lancez directement :

```bash
cd ~/ai-docker
docker-compose down  # Arrêter si déjà lancé
docker-compose up -d --build  # Construire et lancer
```

---

## 📊 Vérifier le GPU sur Brev

Avant de lancer, vérifiez que le GPU est accessible :

```bash
nvidia-smi

# Vérifier que Docker peut utiliser le GPU
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

---

## 🌐 Accès aux Services

Sur Brev, les ports sont généralement exposés automatiquement. Vérifiez dans l'interface Brev :

- **SD-Forge-Neo** : Port 7860
- **Open WebUI** : Port 8080
- **Ollama API** : Port 11434

Brev devrait vous fournir des URLs publiques pour accéder à ces ports.

---

## ⚡ Checklist de Déploiement Brev

- [ ] Tous les fichiers uploadés (Dockerfile, docker-compose.yml, scripts)
- [ ] GPU NVIDIA vérifié avec `nvidia-smi`
- [ ] NVIDIA Container Toolkit installé
- [ ] Au moins 100 GB d'espace disque libre
- [ ] Fichiers dans le même répertoire
- [ ] Permissions d'exécution sur les scripts (.sh)

---

## 🐛 Dépannage Brev

### Erreur : "Dockerfile not found"

```bash
# Vérifier le chemin actuel
pwd

# Lister les fichiers
ls -la

# S'assurer d'être dans le bon dossier
cd ~/ai-docker
```

### Erreur : "docker-compose: command not found"

```bash
# Installer docker-compose
sudo apt update
sudo apt install docker-compose-plugin

# OU utiliser la nouvelle syntaxe
docker compose up -d  # Avec espace, pas de tiret
```

### Erreur : Service failed to start

```bash
# Voir les logs détaillés
docker-compose logs -f

# OU
docker logs ai-container
```

---

## 📝 Note Importante pour Brev

Brev utilise parfois des configurations systemd personnalisées. Si vous rencontrez des problèmes :

1. **Désactiver le service systemd automatique** :
```bash
sudo systemctl stop docker-compose.service
sudo systemctl disable docker-compose.service
```

2. **Lancer manuellement** :
```bash
cd ~/ai-docker
docker-compose up -d
```

3. **Ou utiliser install.sh** qui gère tout automatiquement :
```bash
chmod +x install.sh
./install.sh
```

---

## 🎉 Après l'Installation

Une fois démarré, attendez 5-10 minutes pour le premier démarrage (téléchargement des modèles).

Vérifier l'état :
```bash
docker ps  # Voir le container en cours
docker logs -f ai-container  # Suivre les logs
```

Tester :
```bash
chmod +x test.sh
./test.sh
```

Gérer :
```bash
chmod +x manage.sh
./manage.sh
```

---

**Résumé :** Le problème vient du fait que seul le `docker-compose.yml` a été uploadé. Il faut **tous les fichiers dans le même répertoire**, en particulier le **Dockerfile**.
