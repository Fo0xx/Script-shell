# Vérifier si Git est installé
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Red "Git n'est pas installé. Veuillez installer Git."
    exit
}

# Analyser les arguments de ligne de commande
param (
    [string]$workspace = ".",
    [int]$refresh_duration = 30,
    [bool]$delete_files = $true
)

# Si le workspace n'est pas défini, utilisez le répertoire de travail actuel (full path)
if ($workspace -eq ".") {
    $workspace = Get-Location
}

# Vérifier si le répertoire spécifié est un dépôt Git
Set-Location -Path $workspace
try {
    git rev-parse --git-dir > $null
} catch {
    Write-Host -ForegroundColor Red "Le répertoire spécifié n'est pas un dépôt Git."
    exit
}

function Check-ModifiedFiles {
    Write-Host -ForegroundColor Yellow "Fichiers modifiés trouvés :"
    $modified_files = git diff --name-only
    $untracked_files = git ls-files --others --exclude-standard
    $all_files = $modified_files + " " + $untracked_files
    if (-not $all_files) {
        Write-Host -ForegroundColor Green "Aucun fichier modifié."
        return
    }
    foreach ($file in $all_files -split ' ') {
        if (-not $file) { continue }
        $modified_lines = git diff --numstat $file | ForEach-Object { ($_ -split '\s+')[0] }
        
        if (-not $modified_lines -match '^\d+$') {
            $modified_lines = 0
        }
        if ($modified_lines -gt 200) {
            Write-Host -ForegroundColor Red "$file ($modified_lines lignes modifiées)"
        } elseif ($modified_lines -gt 50) {
            Write-Host -ForegroundColor Blue "$file ($modified_lines lignes modifiées)"
        } else {
            Write-Host -ForegroundColor Green "$file ($modified_lines lignes modifiées)"
        }
    }
}

# Exécuter le script en boucle toutes les $refresh_duration secondes
$count = $refresh_duration
do {
    if ($count -eq $refresh_duration) {
        Check-ModifiedFiles
    }
    Write-Host -NoNewline -ForegroundColor Red "Compte à rebours : $count`r"
    Start-Sleep -Seconds 1
    $count--
    if ($count -eq 0) {
        $staged_changes = git diff --cached
        if (-not $staged_changes -and $delete_files) {
            Write-Host -ForegroundColor Red "Aucun fichier ajouté à l'index Git. Les fichiers modifiés seront supprimés."
            git clean -fd
        } else {
            Write-Host -ForegroundColor Yellow "Des fichiers ont été ajoutés à l'index Git. Les fichiers modifiés ne seront pas supprimés."
        }
        $count = $refresh_duration
    }
} while ($count -gt 0)
