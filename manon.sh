#!/bin/bash

# Vérifier si Git est installé
if ! command -v git &> /dev/null; then
        echo "Git n'est pas installé. Veuillez installer Git."
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
            echo "Option invalide : $OPTARG" 1>&2
            exit 1
            ;;
        : )
            echo "Option invalide : $OPTARG nécessite un argument" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Valeurs par défaut
workspace=${workspace:-.}
refresh_duration=${refresh_duration:-300}
delete_files=${delete_files:-false}

# Fonction pour vérifier si des fichiers ont été modifiés
check_modified_files() {
        cd $workspace
        modified_files=$(git diff --name-only)
        if [ -z "$modified_files" ]; then
                echo "Aucun fichier modifié."
        else
                echo "Fichiers modifiés trouvés :"
                for file in $modified_files; do
                        modified_lines=$(git diff --numstat $file | awk '{print $1}')
                        if [ "$modified_lines" -gt 500 ]; then
                                echo -e "\e[31m$file ($modified_lines lignes modifiées)\e[0m"  # Rouge
                        elif [ "$modified_lines" -gt 100 ]; then
                                echo -e "\e[34m$file ($modified_lines lignes modifiées)\e[0m"  # Bleu
                        else
                                echo -e "\e[32m$file ($modified_lines lignes modifiées)\e[0m"  # Vert
                        fi
                done
        fi
}

# Exécuter le script en boucle toutes les $refresh_duration secondes
warnings=0
while true; do
        check_modified_files
        warnings=$((warnings+1))
        if [ "$warnings" -ge 3 ] && [ "$delete_files" = true ]; then
                # Supprimer tous les fichiers modifiés
                git ls-files --modified | xargs -d '\n' rm -f
                warnings=0
        fi
        sleep $refresh_duration
done