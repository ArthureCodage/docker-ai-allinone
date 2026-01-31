#!/bin/bash

# ==============================================
# UTILITAIRES DE GESTION DOCKER AI
# Scripts rapides pour gérer le container
# ==============================================

show_menu() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   GESTION DOCKER AI ALL-IN-ONE        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "1)  Voir le statut du container"
    echo "2)  Démarrer le container"
    echo "3)  Arrêter le container"
    echo "4)  Redémarrer le container"
    echo "5)  Voir les logs en temps réel"
    echo "6)  Voir l'utilisation des ressources"
    echo "7)  Ouvrir un shell dans le container"
    echo "8)  Liste des modèles Ollama"
    echo "9)  Télécharger un modèle Ollama"
    echo "10) Vérifier l'état des services (supervisor)"
    echo "11) Redémarrer SD-Forge-Neo uniquement"
    echo "12) Redémarrer Ollama uniquement"
    echo "13) Redémarrer Open WebUI uniquement"
    echo "14) Nettoyer les images Docker inutilisées"
    echo "15) Backup des modèles"
    echo "16) Afficher les URLs d'accès"
    echo "0)  Quitter"
    echo ""
    echo -n "Votre choix: "
}

# Vérifier si le container existe
check_container() {
    if ! docker ps -a | grep -q ai-container; then
        echo "❌ Le container 'ai-container' n'existe pas."
        echo "   Lancez d'abord install.sh"
        exit 1
    fi
}

# Fonction pour afficher le statut
show_status() {
    echo ""
    echo "═══ STATUT DU CONTAINER ═══"
    docker ps -a --filter name=ai-container --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
}

# Fonction pour démarrer
start_container() {
    echo "▶ Démarrage du container..."
    docker start ai-container
    echo "✓ Container démarré"
}

# Fonction pour arrêter
stop_container() {
    echo "■ Arrêt du container..."
    docker stop ai-container
    echo "✓ Container arrêté"
}

# Fonction pour redémarrer
restart_container() {
    echo "↻ Redémarrage du container..."
    docker restart ai-container
    echo "✓ Container redémarré"
}

# Fonction pour voir les logs
show_logs() {
    echo "📋 Logs en temps réel (Ctrl+C pour quitter)..."
    echo ""
    docker logs -f ai-container
}

# Fonction pour voir les ressources
show_resources() {
    echo "═══ UTILISATION DES RESSOURCES ═══"
    echo ""
    docker stats ai-container --no-stream
    echo ""
    echo "═══ UTILISATION GPU ═══"
    nvidia-smi
}

# Fonction pour ouvrir un shell
open_shell() {
    echo "🐚 Ouverture du shell dans le container..."
    echo "   Tapez 'exit' pour quitter"
    echo ""
    docker exec -it ai-container /bin/bash
}

# Fonction pour lister les modèles Ollama
list_ollama_models() {
    echo "═══ MODÈLES OLLAMA INSTALLÉS ═══"
    docker exec ai-container ollama list
}

# Fonction pour télécharger un modèle Ollama
download_ollama_model() {
    echo ""
    echo "Modèles populaires:"
    echo "  - mistral"
    echo "  - llama3.3"
    echo "  - codellama"
    echo "  - phi3"
    echo "  - gemma2"
    echo ""
    echo -n "Nom du modèle à télécharger: "
    read model_name
    
    if [ -z "$model_name" ]; then
        echo "❌ Nom de modèle vide"
        return
    fi
    
    echo "⏳ Téléchargement de $model_name..."
    docker exec ai-container ollama pull "$model_name"
    echo "✓ Modèle téléchargé"
}

# Fonction pour vérifier les services
check_services() {
    echo "═══ ÉTAT DES SERVICES (SUPERVISOR) ═══"
    docker exec ai-container supervisorctl status
}

# Fonction pour redémarrer SD-Forge
restart_sdforge() {
    echo "↻ Redémarrage de SD-Forge-Neo..."
    docker exec ai-container supervisorctl restart sd-forge-neo
    echo "✓ SD-Forge-Neo redémarré"
}

# Fonction pour redémarrer Ollama
restart_ollama() {
    echo "↻ Redémarrage d'Ollama..."
    docker exec ai-container supervisorctl restart ollama
    echo "✓ Ollama redémarré"
}

# Fonction pour redémarrer Open WebUI
restart_webui() {
    echo "↻ Redémarrage d'Open WebUI..."
    docker exec ai-container supervisorctl restart open-webui
    echo "✓ Open WebUI redémarré"
}

# Fonction pour nettoyer Docker
cleanup_docker() {
    echo "🧹 Nettoyage des images Docker inutilisées..."
    docker system prune -f
    echo "✓ Nettoyage terminé"
}

# Fonction pour backup
backup_models() {
    backup_name="ai-models-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo "💾 Création du backup: $backup_name"
    tar czf "$backup_name" ~/ai-docker/models/
    echo "✓ Backup créé: $backup_name"
    echo "   Taille: $(du -h $backup_name | cut -f1)"
}

# Fonction pour afficher les URLs
show_urls() {
    echo ""
    echo "═══ URLS D'ACCÈS ═══"
    echo ""
    echo "🖼️  SD-Forge-Neo (Images):"
    echo "   http://localhost:7860"
    echo ""
    echo "💬 Open WebUI (Chat):"
    echo "   http://localhost:8080"
    echo ""
    echo "🔌 Ollama API:"
    echo "   http://localhost:11434"
    echo ""
    
    # Essayer de détecter l'IP publique
    if command -v curl &> /dev/null; then
        public_ip=$(curl -s ifconfig.me)
        if [ ! -z "$public_ip" ]; then
            echo "🌍 Accès depuis l'extérieur (IP publique: $public_ip):"
            echo "   http://$public_ip:7860 (SD-Forge)"
            echo "   http://$public_ip:8080 (Open WebUI)"
            echo ""
            echo "   ⚠️  Assurez-vous que les ports sont ouverts et sécurisés!"
        fi
    fi
}

# Programme principal
main() {
    check_container
    
    while true; do
        show_menu
        read choice
        
        case $choice in
            1) show_status ;;
            2) start_container ;;
            3) stop_container ;;
            4) restart_container ;;
            5) show_logs ;;
            6) show_resources ;;
            7) open_shell ;;
            8) list_ollama_models ;;
            9) download_ollama_model ;;
            10) check_services ;;
            11) restart_sdforge ;;
            12) restart_ollama ;;
            13) restart_webui ;;
            14) cleanup_docker ;;
            15) backup_models ;;
            16) show_urls ;;
            0) 
                echo "Au revoir!"
                exit 0
                ;;
            *)
                echo "❌ Choix invalide"
                ;;
        esac
        
        echo ""
        echo -n "Appuyez sur Entrée pour continuer..."
        read
    done
}

# Lancement
main
