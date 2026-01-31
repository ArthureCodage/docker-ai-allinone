# 🐳 Docker AI All-in-One

> Container Docker unique combinant **SD-Forge-Neo** (génération d'images) et **Ollama + Open WebUI** (génération de texte avec LLM) pour un déploiement simplifié sur VPS Ubuntu avec GPU NVIDIA.

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![NVIDIA](https://img.shields.io/badge/NVIDIA-GPU-76B900?style=flat&logo=nvidia&logoColor=white)](https://www.nvidia.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 📋 Table des Matières

- [Aperçu](#-aperçu)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation Rapide](#-installation-rapide)
- [Documentation](#-documentation)
- [Modèles Inclus](#-modèles-inclus)
- [Accès aux Interfaces](#-accès-aux-interfaces)
- [Gestion](#-gestion)
- [Dépannage](#-dépannage)
- [Contribution](#-contribution)
- [License](#-license)

---

## 🎯 Aperçu

Ce projet fournit un environnement Docker **tout-en-un** pour :
- **Génération d'images** avec Stable Diffusion (SD-Forge-Neo)
- **Génération de texte** avec des LLM locaux (Ollama + Open WebUI)

Tout dans un **seul container Docker**, déployable en **une commande**.

### Technologies Incluses

- **[SD-Forge-Neo](https://github.com/Haoming02/sd-webui-forge-classic/tree/neo)** - Interface Stable Diffusion optimisée
- **[Civitai Helper](https://github.com/zixaphir/Stable-Diffusion-Webui-Civitai-Helper)** - Extension pour télécharger des modèles
- **[Ollama](https://ollama.com)** - Moteur LLM local
- **[Open WebUI](https://github.com/open-webui/open-webui)** - Interface web moderne pour Ollama

---

## ✨ Fonctionnalités

✅ **Installation en une commande**  
✅ **Container unique** avec tous les services  
✅ **GPU NVIDIA** optimisé (CUDA 12.1)  
✅ **Téléchargement automatique** des modèles Civitai  
✅ **Volumes persistants** pour modèles et outputs  
✅ **Configuration pré-paramétrée** (Euler sampler, Clip Skip 2, JPEG)  
✅ **Scripts de gestion** interactifs  
✅ **Support Brev.dev** pour déploiement cloud  

---

## 💻 Prérequis

### Configuration Minimale

| Composant | Minimum | Recommandé |
|-----------|---------|------------|
| **RAM** | 16 GB | 32 GB |
| **VRAM** | 8 GB | 12+ GB |
| **Stockage** | 100 GB | 200+ GB |
| **GPU** | NVIDIA GTX 1080 Ti | RTX 3060+ |
| **OS** | Ubuntu 20.04+ | Ubuntu 22.04 |

### Logiciels Requis

- Docker (installé automatiquement par le script)
- NVIDIA Drivers (version récente)
- NVIDIA Container Toolkit (installé automatiquement)

---

## 🚀 Installation Rapide

### Option 1 : Script Automatique (Recommandé)

```bash
# Cloner le dépôt
git clone https://github.com/VOTRE-USERNAME/docker-ai-allinone.git
cd docker-ai-allinone

# Lancer l'installation
chmod +x install.sh
./install.sh
```

**C'est tout !** Le script va :
1. Installer Docker et NVIDIA Container Toolkit (si nécessaire)
2. Construire l'image Docker
3. Démarrer le container avec tous les services
4. Télécharger automatiquement les modèles

### Option 2 : Docker Compose

```bash
git clone https://github.com/VOTRE-USERNAME/docker-ai-allinone.git
cd docker-ai-allinone

docker-compose up -d --build
```

### Option 3 : Déploiement sur Brev.dev

```bash
# Transférer les fichiers sur Brev
scp -r * ubuntu@<brev-instance>:~/ai-docker/

# Sur Brev
cd ~/ai-docker
chmod +x deploy-brev.sh
./deploy-brev.sh
```

Voir **[GUIDE_BREV.md](GUIDE_BREV.md)** pour plus de détails.

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[README.md](README.md)** | Documentation complète et détaillée |
| **[QUICKSTART.md](QUICKSTART.md)** | Guide de démarrage rapide |
| **[GUIDE_BREV.md](GUIDE_BREV.md)** | Déploiement sur Brev.dev |
| **[NOTES_TECHNIQUES.md](NOTES_TECHNIQUES.md)** | Configurations avancées |
| **[FICHIERS.md](FICHIERS.md)** | Index de tous les fichiers |

---

## 🎨 Modèles Inclus

### Checkpoints (Stable Diffusion)
- **CyberRealistic Pony** - Génération réaliste et stylisée
- **Nova Reality XL** - Images photoréalistes

### LoRAs
- **Perfect Pussy** - Amélioration des détails anatomiques
- **Perfect Eyes XL** - Amélioration des yeux
- **Multiple Girls Group** - Scènes avec plusieurs personnages
- **POV Group Sex** - Perspectives POV

### Modèles LLM
- **Mistral** (via Ollama) - Modèle de langage polyvalent

> **Note :** Les modèles sont téléchargés automatiquement au premier démarrage (~50-70 GB). Vous pouvez ajouter vos propres modèles via l'interface Civitai Helper.

---

## 🌐 Accès aux Interfaces

Une fois le container démarré :

| Service | URL | Description |
|---------|-----|-------------|
| **SD-Forge-Neo** | http://localhost:7860 | Génération d'images |
| **Open WebUI** | http://localhost:8080 | Chat avec Ollama |
| **Ollama API** | http://localhost:11434 | API Ollama (interne) |

### Accès Distant Sécurisé

Pour un accès depuis l'extérieur, voir la section **[Accès Sécurisé](README.md#-accès-sécurisé-depuis-lextérieur)** dans le README principal.

---

## 🛠️ Gestion

### Script de Gestion Interactif

```bash
chmod +x manage.sh
./manage.sh
```

Menu avec 16 options :
- ✅ Voir le statut du container
- ▶️ Démarrer/Arrêter/Redémarrer
- 📋 Logs en temps réel
- 💻 Monitoring CPU/GPU
- 📦 Gérer les modèles Ollama
- 💾 Backup automatique
- Et plus...

### Commandes Essentielles

```bash
# Voir les logs
docker logs -f ai-container

# Redémarrer le container
docker restart ai-container

# État des services internes
docker exec ai-container supervisorctl status

# Télécharger un modèle Ollama
docker exec ai-container ollama pull llama3.3
```

---

## 🐛 Dépannage

### Container ne démarre pas
```bash
docker logs ai-container
```

### GPU non détecté
```bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### Service ne répond pas
```bash
docker exec ai-container supervisorctl status
docker exec ai-container supervisorctl restart <service-name>
```

### Tests de Validation
```bash
chmod +x test.sh
./test.sh
```

Pour plus de dépannage, consultez **[README.md - Section Dépannage](README.md#-dépannage)**.

---

## 📦 Structure du Projet

```
docker-ai-allinone/
├── Dockerfile                    # Image Docker principale
├── docker-compose.yml            # Configuration Docker Compose
├── .dockerignore                 # Optimisation du build
├── .gitignore                    # Fichiers Git exclus
│
├── install.sh                    # Installation automatique
├── manage.sh                     # Gestion interactive
├── test.sh                       # Tests de validation
├── deploy-brev.sh                # Déploiement Brev.dev
├── deploy-github.sh              # Déploiement GitHub
│
├── README.md                     # Documentation principale
├── QUICKSTART.md                 # Guide rapide
├── GUIDE_BREV.md                 # Guide Brev.dev
├── NOTES_TECHNIQUES.md           # Configurations avancées
└── FICHIERS.md                   # Index des fichiers
```

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. **Fork** le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une **Pull Request**

### Idées de Contribution

- Support pour d'autres modèles Stable Diffusion
- Intégration de nouveaux LLM
- Amélioration des performances
- Scripts de déploiement pour d'autres plateformes cloud
- Documentation dans d'autres langues

---

## 📄 License

Ce projet est sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🙏 Remerciements

- [SD-Forge-Neo](https://github.com/Haoming02/sd-webui-forge-classic) - Interface Stable Diffusion
- [Civitai](https://civitai.com) - Hébergement des modèles
- [Ollama](https://ollama.com) - Moteur LLM local
- [Open WebUI](https://github.com/open-webui/open-webui) - Interface web moderne

---

## 📞 Support

- **Issues** : [GitHub Issues](https://github.com/VOTRE-USERNAME/docker-ai-allinone/issues)
- **Discussions** : [GitHub Discussions](https://github.com/VOTRE-USERNAME/docker-ai-allinone/discussions)
- **Documentation** : Voir les fichiers `.md` dans le repo

---

## ⭐ Star History

Si ce projet vous a aidé, n'hésitez pas à lui donner une ⭐ sur GitHub !

---

**Créé avec ❤️ pour la communauté AI/ML**
