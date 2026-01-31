#!/bin/bash

# ==============================================
# SCRIPT DE TEST DE L'INSTALLATION
# Vérifie que tout fonctionne correctement
# ==============================================

set -e

echo "╔════════════════════════════════════════╗"
echo "║   TEST DE L'INSTALLATION AI DOCKER    ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success=0
failed=0

# Fonction de test
test_step() {
    local name=$1
    local command=$2
    
    echo -n "Testing: $name... "
    
    if eval "$command" &> /dev/null; then
        echo -e "${GREEN}✓ OK${NC}"
        ((success++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((failed++))
        return 1
    fi
}

# Fonction de test avec output
test_step_verbose() {
    local name=$1
    local command=$2
    
    echo "Testing: $name..."
    
    if eval "$command"; then
        echo -e "${GREEN}✓ OK${NC}"
        ((success++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((failed++))
        return 1
    fi
    echo ""
}

echo "═══ TESTS DES PRÉREQUIS ═══"
echo ""

# Test Docker
test_step "Docker installé" "command -v docker"

# Test NVIDIA SMI
test_step "NVIDIA drivers installés" "command -v nvidia-smi"

# Test NVIDIA Container Toolkit
test_step "NVIDIA Container Toolkit" "command -v nvidia-container-toolkit"

# Test GPU accessible
test_step "GPU détectable" "nvidia-smi"

echo ""
echo "═══ TESTS DU CONTAINER ═══"
echo ""

# Test container existe
test_step "Container existe" "docker ps -a | grep -q ai-container"

# Test container running
if docker ps | grep -q ai-container; then
    echo -e "Container running: ${GREEN}✓ OK${NC}"
    ((success++))
    
    echo ""
    echo "═══ TESTS DES SERVICES ═══"
    echo ""
    
    # Attendre un peu pour que les services démarrent
    sleep 5
    
    # Test SD-Forge-Neo (port 7860)
    test_step "SD-Forge-Neo accessible (port 7860)" "curl -f -s http://localhost:7860 > /dev/null"
    
    # Test Open WebUI (port 8080)
    test_step "Open WebUI accessible (port 8080)" "curl -f -s http://localhost:8080 > /dev/null"
    
    # Test Ollama API (port 11434)
    test_step "Ollama API accessible (port 11434)" "curl -f -s http://localhost:11434 > /dev/null"
    
    echo ""
    echo "═══ TESTS DES VOLUMES ═══"
    echo ""
    
    # Test volumes
    test_step "Volume models existe" "[ -d ~/ai-docker/models ]"
    test_step "Volume outputs existe" "[ -d ~/ai-docker/outputs ]"
    test_step "Volume ollama existe" "[ -d ~/ai-docker/ollama ]"
    test_step "Volume open-webui existe" "[ -d ~/ai-docker/open-webui ]"
    
    echo ""
    echo "═══ TESTS DES SERVICES INTERNES ═══"
    echo ""
    
    # Test supervisor
    test_step_verbose "État des services (Supervisor)" "docker exec ai-container supervisorctl status"
    
    echo ""
    echo "═══ TESTS DES MODÈLES ═══"
    echo ""
    
    # Test modèles Civitai téléchargés
    echo "Vérification des modèles Civitai..."
    if docker exec ai-container ls /workspace/sd-forge-neo/models/Stable-diffusion/*.safetensors &> /dev/null; then
        count=$(docker exec ai-container ls /workspace/sd-forge-neo/models/Stable-diffusion/*.safetensors | wc -l)
        echo -e "Checkpoints trouvés: ${GREEN}$count${NC}"
        ((success++))
    else
        echo -e "${YELLOW}⚠ Aucun checkpoint trouvé (peut-être en cours de téléchargement)${NC}"
    fi
    
    if docker exec ai-container ls /workspace/sd-forge-neo/models/Lora/*.safetensors &> /dev/null; then
        count=$(docker exec ai-container ls /workspace/sd-forge-neo/models/Lora/*.safetensors | wc -l)
        echo -e "LoRAs trouvés: ${GREEN}$count${NC}"
        ((success++))
    else
        echo -e "${YELLOW}⚠ Aucun LoRA trouvé (peut-être en cours de téléchargement)${NC}"
    fi
    
    # Test modèles Ollama
    echo ""
    echo "Modèles Ollama installés:"
    if docker exec ai-container ollama list 2>/dev/null | tail -n +2 | grep -v "^$"; then
        ((success++))
    else
        echo -e "${YELLOW}⚠ Aucun modèle Ollama installé${NC}"
    fi
    
    echo ""
    echo "═══ TESTS GPU ═══"
    echo ""
    
    # Test GPU accessible dans le container
    test_step_verbose "GPU accessible dans le container" "docker exec ai-container nvidia-smi"
    
else
    echo -e "Container running: ${RED}✗ FAILED (container arrêté)${NC}"
    ((failed++))
    echo ""
    echo -e "${YELLOW}⚠ Le container n'est pas en cours d'exécution.${NC}"
    echo "   Démarrez-le avec: docker start ai-container"
fi

echo ""
echo "╔════════════════════════════════════════╗"
echo "║           RÉSULTATS DES TESTS          ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo -e "Tests réussis: ${GREEN}$success${NC}"
echo -e "Tests échoués: ${RED}$failed${NC}"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}✓ Tous les tests sont passés avec succès !${NC}"
    echo ""
    echo "Vous pouvez maintenant accéder à :"
    echo "  • SD-Forge-Neo : http://localhost:7860"
    echo "  • Open WebUI   : http://localhost:8080"
    echo "  • Ollama API   : http://localhost:11434"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠ Certains tests ont échoué.${NC}"
    echo ""
    echo "Pour déboguer :"
    echo "  • Voir les logs : docker logs -f ai-container"
    echo "  • Vérifier les services : docker exec ai-container supervisorctl status"
    echo "  • Redémarrer : docker restart ai-container"
    echo ""
    exit 1
fi
