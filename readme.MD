# README.md

## Introduction

[`manon.sh`](command:_github.copilot.openRelativePath?%5B%22manon.sh%22%5D "manon.sh") est un script shell qui surveille les modifications de fichiers dans un dépôt Git. Il vérifie les modifications toutes les 5 minutes et envoie des notifications à l'utilisateur. Si plus de 500 lignes ont été modifiées ou ajoutées, il affiche les noms des fichiers en rouge. Si entre 100 et 500 lignes ont été modifiées ou ajoutées, il affiche les noms des fichiers en bleu. Sinon, il affiche les noms des fichiers en vert. Si trois avertissements ont été émis, tous les fichiers modifiés sont supprimés définitivement.

## Installation

1. Téléchargez le script [`manon.sh`](command:_github.copilot.openRelativePath?%5B%22manon.sh%22%5D "manon.sh") dans votre dépôt Git local.
2. Rendez le script exécutable avec la commande suivante :

```sh
chmod +x manon.sh
```

## Configuration

Aucune configuration n'est nécessaire. Le script utilise les commandes Git pour surveiller les modifications de fichiers.

## Utilisation

Exécutez le script avec la commande suivante :

```sh
./manon.sh
```

Le script commencera à surveiller les modifications de fichiers et à envoyer des notifications.

## FAQ 

**Q : Comment arrêter le script ?**

R : Vous pouvez arrêter le script en appuyant sur `Ctrl+C` dans le terminal où le script est en cours d'exécution.

**Q : Que se passe-t-il si je n'ai pas Git installé sur mon système ?**

R : Le script vérifie si Git est installé au début de son exécution. Si Git n'est pas installé, le script affiche un message d'erreur et se termine.

**Q : Que se passe-t-il si je ne suis pas dans un dépôt Git ?**

R : Le script fonctionne dans le répertoire courant. Si le répertoire courant n'est pas un dépôt Git, les commandes Git échoueront.

## Exemples d'utilisation

Supposons que vous ayez un dépôt Git avec les fichiers suivants :

```
file1.txt
file2.txt
file3.txt
```

Si vous modifiez `file1.txt` et `file2.txt`, le script affichera les noms de ces fichiers en vert, bleu ou rouge, en fonction du nombre de lignes modifiées. Si vous recevez trois avertissements sans commettre vos modifications, `file1.txt` et `file2.txt` seront supprimés.