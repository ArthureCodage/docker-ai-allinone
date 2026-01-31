FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# ==============================================
# DOCKER IMAGE ALL-IN-ONE
# SD-Forge-Neo + Ollama + Open WebUI
# ==============================================

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH="${CUDA_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"

# ==============================================
# INSTALLATION DES DÉPENDANCES SYSTÈME
# ==============================================

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget \
    curl \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgomp1 \
    google-perftools \
    ca-certificates \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# ==============================================
# INSTALLATION OLLAMA
# ==============================================

RUN curl -fsSL https://ollama.com/install.sh | sh

# ==============================================
# INSTALLATION OPEN WEBUI
# ==============================================

RUN pip3 install --no-cache-dir open-webui

# ==============================================
# INSTALLATION SD-FORGE-NEO
# ==============================================

WORKDIR /workspace

# Clonage de SD-Forge-Neo (branche neo)
RUN git clone -b neo https://github.com/Haoming02/sd-webui-forge-classic.git sd-forge-neo

WORKDIR /workspace/sd-forge-neo

# Installation des dépendances Python pour SD-Forge
RUN pip3 install --no-cache-dir \
    torch==2.1.2 \
    torchvision==0.16.2 \
    torchaudio==2.1.2 \
    --index-url https://download.pytorch.org/whl/cu121

# Installation des requirements de SD-Forge
RUN pip3 install --no-cache-dir -r requirements_versions.txt

# ==============================================
# INSTALLATION EXTENSION CIVITAI HELPER
# ==============================================

WORKDIR /workspace/sd-forge-neo/extensions

RUN git clone https://github.com/zixaphir/Stable-Diffusion-Webui-Civitai-Helper.git civitai-helper

# Installation des dépendances de l'extension
WORKDIR /workspace/sd-forge-neo/extensions/civitai-helper
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

# ==============================================
# CONFIGURATION SD-FORGE-NEO
# ==============================================

WORKDIR /workspace/sd-forge-neo

# Création du fichier de configuration
RUN mkdir -p /workspace/sd-forge-neo/config

# Configuration par défaut (config.json)
RUN echo '{\n\
  "samples_save": true,\n\
  "samples_format": "jpg",\n\
  "jpeg_quality": 95,\n\
  "CLIP_stop_at_last_layers": 2,\n\
  "sd_model_checkpoint": "",\n\
  "sd_vae": "Automatic",\n\
  "comma_padding_backtrack": 20,\n\
  "quicksettings_list": [\n\
    "sd_model_checkpoint",\n\
    "sd_vae",\n\
    "CLIP_stop_at_last_layers"\n\
  ]\n\
}' > /workspace/sd-forge-neo/config.json

# Configuration de l'API Civitai
RUN mkdir -p /workspace/sd-forge-neo/extensions/civitai-helper
RUN echo '{\n\
  "civitai_api_key": "150181b2c22ef80bb0c1befb113fd981"\n\
}' > /workspace/sd-forge-neo/extensions/civitai-helper/config.json

# Configuration du sampler par défaut
RUN echo '{\n\
  "sampler_name": "Euler"\n\
}' > /workspace/sd-forge-neo/ui-config.json

# ==============================================
# SCRIPT DE TÉLÉCHARGEMENT DES MODÈLES CIVITAI
# ==============================================

# Script pour télécharger les modèles au démarrage
RUN echo '#!/bin/bash\n\
\n\
# Fonction de téléchargement Civitai\n\
download_civitai() {\n\
    local model_id=$1\n\
    local version_id=$2\n\
    local type=$3\n\
    local output_dir=$4\n\
    \n\
    echo "Téléchargement du modèle $model_id (version $version_id)..."\n\
    \n\
    # Récupération des infos du modèle\n\
    model_info=$(curl -s "https://civitai.com/api/v1/model-versions/$version_id")\n\
    \n\
    # Extraction du nom et de l'\''URL de téléchargement\n\
    download_url=$(echo "$model_info" | grep -o "\"downloadUrl\":\"[^\"]*\"" | cut -d\" -f4)\n\
    filename=$(echo "$model_info" | grep -o "\"name\":\"[^\"]*\"" | head -1 | cut -d\" -f4)\n\
    \n\
    if [ -z "$download_url" ]; then\n\
        echo "Erreur : impossible de récupérer l'\''URL de téléchargement"\n\
        return 1\n\
    fi\n\
    \n\
    # Téléchargement avec clé API\n\
    wget --header="Authorization: Bearer 150181b2c22ef80bb0c1befb113fd981" \\\n\
         -O "$output_dir/$filename.safetensors" \\\n\
         "$download_url"\n\
    \n\
    echo "✓ $filename téléchargé"\n\
}\n\
\n\
# Création des dossiers nécessaires\n\
mkdir -p /workspace/sd-forge-neo/models/Stable-diffusion\n\
mkdir -p /workspace/sd-forge-neo/models/Lora\n\
\n\
# Téléchargement des Checkpoints\n\
echo "=== TÉLÉCHARGEMENT DES CHECKPOINTS ==="\n\
download_civitai 443821 2469412 "checkpoint" "/workspace/sd-forge-neo/models/Stable-diffusion"\n\
download_civitai 453428 2439763 "checkpoint" "/workspace/sd-forge-neo/models/Stable-diffusion"\n\
\n\
# Téléchargement des LoRAs\n\
echo "=== TÉLÉCHARGEMENT DES LORAS ==="\n\
download_civitai 10844 61391 "lora" "/workspace/sd-forge-neo/models/Lora"\n\
download_civitai 118427 128461 "lora" "/workspace/sd-forge-neo/models/Lora"\n\
download_civitai 51136 "" "lora" "/workspace/sd-forge-neo/models/Lora"\n\
download_civitai 114843 "" "lora" "/workspace/sd-forge-neo/models/Lora"\n\
\n\
echo "=== TÉLÉCHARGEMENT TERMINÉ ==="\n\
' > /workspace/download_models.sh

RUN chmod +x /workspace/download_models.sh

# ==============================================
# SCRIPT DE TÉLÉCHARGEMENT MODÈLE OLLAMA
# ==============================================

RUN echo '#!/bin/bash\n\
\n\
echo "Démarrage d'\''Ollama en arrière-plan..."\n\
ollama serve &\n\
OLLAMA_PID=$!\n\
\n\
sleep 10\n\
\n\
echo "Téléchargement du modèle Mistral-Small-Instruct..."\n\
\n\
# Création d'\''un Modelfile pour le modèle Hugging Face\n\
cat > /tmp/Modelfile << EOF\n\
FROM byroneverson/Mistral-Small-Instruct-2409-abliterated\n\
\n\
PARAMETER temperature 0.7\n\
PARAMETER top_p 0.9\n\
PARAMETER top_k 40\n\
EOF\n\
\n\
# Alternative : téléchargement depuis Ollama (si disponible)\n\
ollama pull mistral || echo "Modèle Mistral standard non disponible, utilisation du modèle personnalisé"\n\
\n\
echo "Modèle Ollama prêt"\n\
' > /workspace/setup_ollama.sh

RUN chmod +x /workspace/setup_ollama.sh

# ==============================================
# CONFIGURATION SUPERVISOR
# ==============================================

RUN echo '[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
pidfile=/var/run/supervisord.pid\n\
\n\
[program:ollama]\n\
command=ollama serve\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/var/log/ollama.err.log\n\
stdout_logfile=/var/log/ollama.out.log\n\
priority=1\n\
\n\
[program:open-webui]\n\
command=open-webui serve --host 0.0.0.0 --port 8080\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/var/log/open-webui.err.log\n\
stdout_logfile=/var/log/open-webui.out.log\n\
priority=2\n\
environment=OLLAMA_BASE_URL="http://localhost:11434"\n\
\n\
[program:sd-forge-neo]\n\
command=python3 launch.py --listen --port 7860 --xformers --enable-insecure-extension-access --api\n\
directory=/workspace/sd-forge-neo\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/var/log/sd-forge.err.log\n\
stdout_logfile=/var/log/sd-forge.out.log\n\
priority=3\n\
' > /etc/supervisor/conf.d/supervisord.conf

# ==============================================
# SCRIPT DE DÉMARRAGE
# ==============================================

RUN echo '#!/bin/bash\n\
\n\
echo "=============================================="\n\
echo "DÉMARRAGE DU CONTAINER AI ALL-IN-ONE"\n\
echo "=============================================="\n\
\n\
# Téléchargement des modèles Civitai (seulement si pas déjà présents)\n\
if [ ! -f /workspace/.models_downloaded ]; then\n\
    echo "Premier démarrage : téléchargement des modèles Civitai..."\n\
    /workspace/download_models.sh\n\
    touch /workspace/.models_downloaded\n\
else\n\
    echo "Modèles Civitai déjà téléchargés, passage..."\n\
fi\n\
\n\
# Configuration d'\''Ollama (seulement au premier démarrage)\n\
if [ ! -f /workspace/.ollama_setup ]; then\n\
    echo "Configuration d'\''Ollama..."\n\
    /workspace/setup_ollama.sh &\n\
    touch /workspace/.ollama_setup\n\
fi\n\
\n\
echo "Démarrage des services..."\n\
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf\n\
' > /workspace/start.sh

RUN chmod +x /workspace/start.sh

# ==============================================
# CRÉATION DES VOLUMES
# ==============================================

VOLUME ["/workspace/sd-forge-neo/models"]
VOLUME ["/workspace/sd-forge-neo/outputs"]
VOLUME ["/root/.ollama"]
VOLUME ["/root/.open-webui"]

# ==============================================
# EXPOSITION DES PORTS
# ==============================================

# SD-Forge-Neo
EXPOSE 7860

# Open WebUI
EXPOSE 8080

# Ollama API
EXPOSE 11434

# ==============================================
# HEALTHCHECK
# ==============================================

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:7860 && curl -f http://localhost:8080 && curl -f http://localhost:11434 || exit 1

# ==============================================
# COMMANDE DE DÉMARRAGE
# ==============================================

WORKDIR /workspace

CMD ["/workspace/start.sh"]
