## Introduction

[`manon.sh`](command:_github.copilot.openSymbolInFile?%5B%22manon.sh%22%2C%22manon.sh%22%5D "manon.sh") et [`manon.ps1`](command:_github.copilot.openSymbolInFile?%5B%22manon.ps1%22%2C%22manon.ps1%22%5D "manon.ps1") sont des scripts qui surveillent les modifications de fichiers dans un dépôt Git. Ils vérifient les modifications toutes les 30 secondes et envoient des notifications à l'utilisateur. Si plus de 500 lignes ont été modifiées ou ajoutées, ils affichent les noms des fichiers en rouge. Si entre 50 et 200 lignes ont été modifiées ou ajoutées, ils affichent les noms des fichiers en bleu. Sinon, ils affichent les noms des fichiers en vert. Si un fichier n'est pas ajoué au dépôt Git après le compte à rebours, il est supprimé.

## Installation

1. Téléchargez les scripts [`manon.sh`](command:_github.copilot.openSymbolInFile?%5B%22manon.sh%22%2C%22manon.sh%22%5D "manon.sh") et [`manon.ps1`](command:_github.copilot.openSymbolInFile?%5B%22manon.ps1%22%2C%22manon.ps1%22%5D "manon.ps1") dans votre dépôt Git local.
2. Rendez les scripts exécutables avec les commandes suivantes :

Pour [`manon.sh`](command:_github.copilot.openRelativePath?%5B%22manon.sh%22%5D "manon.sh") :
```sh
chmod +x manon.sh
```

Pour [`manon.ps1`](command:_github.copilot.openRelativePath?%5B%22manon.ps1%22%5D "manon.ps1") :
```powershell
Set-ExecutionPolicy RemoteSigned
```

## Configuration

Aucune configuration n'est nécessaire. Les scripts utilisent les commandes Git pour surveiller les modifications de fichiers.

## Utilisation

Exécutez les scripts avec les commandes suivantes :

Pour [`manon.sh`](command:_github.copilot.openRelativePath?%5B%22manon.sh%22%5D "manon.sh") :
```sh
./manon.sh
```

Pour [`manon.ps1`](command:_github.copilot.openRelativePath?%5B%22manon.ps1%22%5D "manon.ps1") :
```powershell
./manon.ps1
```

Les scripts commenceront à surveiller les modifications de fichiers et à envoyer des notifications.

## Arguments du script

Les scripts acceptent les arguments suivants :

- `-w` ou `-workspace` : Le chemin vers le répertoire de travail. Par défaut, c'est le répertoire courant.
- `-r` ou `-refresh_duration` : La durée en secondes entre chaque vérification des modifications. Par défaut, c'est 30 secondes.
- `-s` ou `-delete_files` : Un booléen indiquant si les fichiers modifiés doivent être supprimés après trois avertissements. Par défaut, c'est `false`.

## Exemples d'utilisation avec arguments

Pour [`manon.sh`](command:_github.copilot.openRelativePath?%5B%22manon.sh%22%5D "manon.sh") :

```sh
./manon.sh -w /path/to/workspace -r 600 -s true
```

Pour [`manon.ps1`](command:_github.copilot.openRelativePath?%5B%22manon.ps1%22%5D "manon.ps1") :

```powershell
./manon.ps1 -workspace C:\path\to\workspace -refresh_duration 60 -delete_files $true
```

Ces commandes exécuteront les scripts dans le répertoire spécifié, vérifieront les modifications toutes les 10 minutes et supprimeront les fichiers modifiés après trois avertissements.

## FAQ

**Q : Comment arrêter les scripts ?**

R : Vous pouvez arrêter les scripts en appuyant sur `Ctrl+C` dans le terminal où les scripts sont en cours d'exécution.

**Q : Que se passe-t-il si je n'ai pas Git installé sur mon système ?**

R : Les scripts vérifient si Git est installé au début de leur exécution. Si Git n'est pas installé, les scripts affichent un message d'erreur et se terminent.

**Q : Que se passe-t-il si je ne suis pas dans un dépôt Git ?**

R : Les scripts fonctionnent dans le répertoire courant. Si le répertoire courant n'est pas un dépôt Git, les commandes Git échoueront.

## Exemples d'utilisation

Supposons que vous ayez un dépôt Git avec les fichiers suivants :
```
file1.txt
file2.txt
file3.txt
```
Si vous modifiez `file1.txt` et `file2.txt`, les scripts afficheront les noms de ces fichiers en vert, bleu ou rouge, en fonction du nombre de lignes modifiées. Si vous recevez trois avertissements sans commettre vos modifications, `file1.txt` et `file2.txt` seront supprimés.