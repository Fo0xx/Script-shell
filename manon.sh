#!/bin/bash

# Vérifier si Git est installé
if ! command -v git &> /dev/null; then
    echo "$(tput setaf 1)Git n'est pas installé. Veuillez installer Git.$(tput sgr0)"
    exit 1
fi

# Analyser les arguments de ligne de commande
while getopts ":w:r:s:" opt; do
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

# Fonction pour vérifier si des fichiers ont été modifiés
check_modified_files() {
    cd $workspace
    modified_files=$(git diff --name-only)
    if [ -z "$modified_files" ]; then
        echo "$(tput setaf 2)Aucun fichier modifié.$(tput sgr0)"
    else
        echo "$(tput setaf 3)Fichiers modifiés trouvés :$(tput sgr0)"
        for file in $modified_files; do
            modified_lines=$(git diff --numstat $file | awk '{print $1}')
            if [ "$modified_lines" -gt 200 ]; then
                echo -e "$(tput setaf 1)$file ($modified_lines lignes modifiées)$(tput sgr0)"  # Rouge
            elif [ "$modified_lines" -gt 50 ]; then
                echo -e "$(tput setaf 4)$file ($modified_lines lignes modifiées)$(tput sgr0)"  # Bleu
            else
                echo -e "$(tput setaf 2)$file ($modified_lines lignes modifiées)$(tput sgr0)"  # Vert
            fi
        done
    fi
}

# Exécuter le script en boucle toutes les $refresh_duration secondes
count=$refresh_duration
echo "+--------------------------------------------------------+"
echo "|                                                        |"
echo "  $(tput setaf 6)Récapitulatif des arguments choisis :$(tput sgr0)"
echo "  $(tput setaf 6)Workspace : $workspace$(tput sgr0)"
echo "  $(tput setaf 6)Durée de rafraîchissement : $refresh_duration secondes$(tput sgr0)"
echo "  $(tput setaf 6)Supprimer les fichiers modifiés : $delete_files$(tput sgr0)"
echo "|                                                        |"
echo "+--------------------------------------------------------+"
echo ""

while [ $count -gt 0 ]; do
    if [ $count -eq $refresh_duration ]; then
        check_modified_files
    fi
    echo -ne "$(tput setaf 1)Compte à rebours : $count$(tput sgr0)\033[0K\r"
    count=$((count-1))
    if [ "$count" -eq 0 ] && [ "$delete_files" = true ]; then
        # Vérifier si des fichiers ont été ajoutés à l'index Git
        staged_files=$(git diff --name-only --cached)
        if [ -z "$staged_files" ]; then
            echo "$(tput setaf 1)Aucun fichier ajouté à l'index Git. Les fichiers modifiés seront supprimés.$(tput sgr0)"
            git ls-files --modified | xargs -d '\n' rm -f
        else
            echo "$(tput setaf 3)Des fichiers ont été ajoutés à l'index Git. Les fichiers modifiés ne seront pas supprimés.$(tput sgr0)"
        fi
        count=$refresh_duration
    fi
    sleep 1
done
