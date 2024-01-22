#!/bin/bash

# Vérifier si Git est installé
if ! command -v git &> /dev/null; then
    echo "$(tput setaf 1)Git n'est pas installé. Veuillez installer Git.$(tput sgr0)"
    exit 1
fi

# Ajouter le script au .gitignore, si le gitignore n'existe pas, le créer
if [ ! -f .gitignore ]; then
    touch .gitignore
fi

if ! grep -q "manon.sh" .gitignore; then
    echo "manon.sh" >> .gitignore
fi

# Fonction pour afficher les options disponibles
display_options() {
    echo "Options disponibles :"
    echo "-w : Définir le répertoire de travail (par défaut : répertoire actuel)"
    echo "-r : Définir la durée de rafraîchissement en secondes (par défaut : 30)"
    echo "-s : Supprimer les fichiers modifiés (true ou false, par défaut : true)"
    echo "-opt : Afficher ce message d'aide"
}

# Analyser les arguments de ligne de commande
while getopts ":w:r:s:opt" opt; do
    case ${opt} in
        w )
            workspace=$OPTARG
            ;;
        r )
            refresh_duration=$OPTARG
            ;;
        s )
            delete_files=$OPTARG
            ;;
        opt )
            display_options
            exit 0
            ;;
        \? )
            echo "$(tput setaf 1)Option invalide : $OPTARG$(tput sgr0)" 1>&2
            exit 1
            ;;
        : )
            echo "$(tput setaf 1)Option invalide : $OPTARG nécessite un argument$(tput sgr0)" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Valeurs par défaut
workspace=${workspace:-.}
refresh_duration=${refresh_duration:-30}
delete_files=${delete_files:-true}

# Si le workspace n'est pas défini, utilisez le répertoire de travail actuel (full path)
if [ "$workspace" = "." ]; then
    workspace=$(pwd)
fi

cd "$workspace" || exit
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "$(tput setaf 1)Le répertoire spécifié n'est pas un dépôt Git.$(tput sgr0)"
    exit 1
fi

# Fonction pour vérifier si des fichiers ont été modifiés
check_modified_files() {
    echo "$(tput setaf 3)Fichiers modifiés trouvés :$(tput sgr0)"
    modified_files=$(git diff --name-only)
    untracked_files=$(git ls-files --others --exclude-standard)
    all_files="$modified_files $untracked_files"
    if [ -z "$all_files" ]; then
        echo "$(tput setaf 2)Aucun fichier modifié.$(tput sgr0)"
        send_notification "Aucun fichier modifié."
        return
    fi
    for file in $all_files; do
        modified_lines=$(git diff --numstat "$file" | awk '{print $1}')
        if ! [[ "$modified_lines" =~ ^[0-9]+$ ]]; then
            modified_lines=0
        fi
        if [ "$modified_lines" -gt 200 ]; then
            echo -e "$(tput setaf 1)$file ($modified_lines lignes modifiées)$(tput sgr0)"  # Rouge
            send_notification "$file ($modified_lines lignes modifiées)" "high"
        elif [ "$modified_lines" -gt 50 ]; then
            echo -e "$(tput setaf 4)$file ($modified_lines lignes modifiées)$(tput sgr0)"  # Bleu
            send_notification "$file ($modified_lines lignes modifiées)" "medium"
        else
            echo -e "$(tput setaf 2)$file ($modified_lines lignes modifiées)$(tput sgr0)"  # Vert
            send_notification "$file ($modified_lines lignes modifiées)" "low"
        fi
    done
}

# Fonction pour envoyer des notifications système
send_notification() {
    message=$1
    urgency=$2  # low, medium, high
    case $(uname) in
        Linux)
            notify-send "Git Guardian" "$message" -u "$urgency"
            ;;
        Darwin)
            osascript -e "display notification \"$message\" with title \"Git Guardian\""
            ;;
        *)
            echo "Notification : $message"
            ;;
    esac
}

# Boucle principale du script
count=$refresh_duration
while [ $count -gt 0 ]; do
    if [ $count -eq $refresh_duration ]; then
        check_modified_files
    fi
    echo -ne "$(tput setaf 1)Compte à rebours : $count$(tput sgr0)\033[0K\r"
    count=$((count-1))
    sleep 1
done

if [ "$delete_files" = "true" ]; then
    staged_changes=$(git diff --cached)
    if [ -z "$staged_changes" ]; then
        echo "$(tput setaf 1)Aucun fichier ajouté à l'index Git. Les fichiers modifiés seront supprimés.$(tput sgr0)"
        send_notification "Les fichiers modifiés seront supprimés." "high"
        git clean -fd
    else
        echo "$(tput setaf 3)Des fichiers ont été ajoutés à l'index Git. Les fichiers modifiés ne seront pas supprimés.$(tput sgr0)"
        send_notification "Les fichiers modifiés ne seront pas supprimés." "low"
    fi
fi
