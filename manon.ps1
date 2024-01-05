# Vérifier si Git est installé
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git n'est pas installé. Veuillez installer Git." -ForegroundColor Red
    exit
}

# Analyser les arguments de ligne de commande
param (
    [string]$workspace = ".",
    [int]$refresh_duration = 30,
    [bool]$delete_files = $true
)

# Fonction pour vérifier si des fichiers ont été modifiés
function Check-ModifiedFiles {
    Set-Location -Path $workspace
    $modified_files = git diff --name-only
    if (!$modified_files) {
        Write-Host "Aucun fichier modifié." -ForegroundColor Green
    } else {
        Write-Host "Fichiers modifiés trouvés :" -ForegroundColor Yellow
        foreach ($file in $modified_files) {
            $modified_lines = git diff --numstat $file | ForEach-Object { ($_ -split '\s+')[0] }
            if ($modified_lines -gt 200) {
                Write-Host "$file ($modified_lines lignes modifiées)" -ForegroundColor Red
            } elseif ($modified_lines -gt 50) {
                Write-Host "$file ($modified_lines lignes modifiées)" -ForegroundColor Blue
            } else {
                Write-Host "$file ($modified_lines lignes modifiées)" -ForegroundColor Green
            }
        }
    }
}

# Exécuter le script en boucle toutes les $refresh_duration secondes
$count = $refresh_duration
Write-Host "Espace de travail : $workspace"
Write-Host "Durée de rafraîchissement : $refresh_duration secondes"
Write-Host "Supprimer les fichiers modifiés : $delete_files"

while ($count -gt 0) {
    if ($count -eq $refresh_duration) {
        Check-ModifiedFiles
    }
    Write-Host "Compte à rebours : $count" -NoNewline
    $count--
    if ($count -eq 0 -and $delete_files) {
        # Vérifier si des fichiers ont été ajoutés à l'index Git
        $staged_files = git diff --name-only --cached
        if (!$staged_files) {
            Write-Host "Aucun fichier ajouté à l'index Git. Les fichiers modifiés seront supprimés." -ForegroundColor Red
            git ls-files --modified | ForEach-Object { Remove-Item -Path $_ -Force }
        } else {
            Write-Host "Des fichiers ont été ajoutés à l'index Git. Les fichiers modifiés ne seront pas supprimés." -ForegroundColor Yellow
        }
        $count = $refresh_duration
    }
    Start-Sleep -Seconds 1
}