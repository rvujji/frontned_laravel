# app/summarize_folder.ps1

# --- CONFIGURATION: Target Folders (Hardcoded) ---
# Folders to process (must be subdirectories of where this script is run)
$targetSubFolders = @(
    "lib"
)
$outputFile = "sourcecode_flutter.md" # Hardcoded output file name
# -------------------------------------------------

# --- CONFIGURATION: Folders to Exclude ---
$excludedFolders = @(
    ".git",
    "venv",
    "node_modules",
    "build",
    "dist",
    "logs",
    "__pycache__",
    "tests",
    "abc"
)
# ------------------------------------------

# --- CONFIGURATION: File Names to Exclude (New) ---
# This list is matched against the file's BASE NAME (e.g., 'foo.py' or '__init__.py').
# Use wildcards (*) for partial matches if needed.
$excludedFileNames = @(
    "__init__.py",
    "README.md",
    "LICENSE",
    "setup.py"
)
# ------------------------------------------

# 1. Clear the output file before starting
Clear-Content -Path $outputFile -ErrorAction SilentlyContinue

Write-Host "Starting aggregation for selected folders: $($targetSubFolders -join ', ')"
Write-Host "Output file will be: $outputFile"
Write-Host "Excluded Folders: $($excludedFolders -join ', ')"
Write-Host "Excluded Files: $($excludedFileNames -join ', ')"
Write-Host "------------------------------"

# 2. Use Get-ChildItem to recursively find files in specified folders
$allFiles = @()
$basePathLength = (Get-Location).Path.Length + 1

foreach ($folder in $targetSubFolders) {
    # Check if the folder exists
    if (-not (Test-Path -Path $folder -PathType Container)) {
        Write-Host "WARNING: Target folder '$folder' not found. Skipping."
        continue
    }

    # Recurse within the current target folder and apply exclusion filters
    $files = Get-ChildItem -Path $folder -Recurse -File | Where-Object {
        
        $directoryPath = $_.DirectoryName
        $fileName = $_.Name
        $normalizedPath = $directoryPath -replace '\\', '/'
        
        # --- File Name Exclusion Check ---
        $isFileNameExcluded = $false
        foreach ($excludeName in $excludedFileNames) {
            # -ieq for case-insensitive exact match
            if ($fileName -ieq $excludeName) {
                $isFileNameExcluded = $true
                break
            }
        }
        if ($isFileNameExcluded) {
            return $false # Skip this file
        }

        # --- Folder Exclusion Check ---
        $isFolderExcluded = $false
        foreach ($excludeFolder in $excludedFolders) {
            # Check for a directory segment match: */excludeFolder/* or */excludeFolder
            if ($normalizedPath -like "*/*$excludeFolder/*" -or $normalizedPath -like "*/$excludeFolder") {
                $isFolderExcluded = $true
                break
            }
        }
        
        # Return true only if NOT folder excluded
        -not $isFolderExcluded
    }
    
    $allFiles += $files
}

if ($allFiles.Count -eq 0) {
    Write-Host "No files found (or all files were in excluded directories/filenames)."
    exit
}

# 3. Process the filtered files
foreach ($file in $allFiles) {
    # Calculate relative path from the current working directory
    $relativePath = $file.FullName.Substring($basePathLength)
    
    Add-Content -Path $outputFile -Value "## File: $relativePath"
#    Add-Content -Path $outputFile -Value '```text'
    
    # Use Out-String to handle potentially large files efficiently before adding content
    (Get-Content -Path $file.FullName | Out-String) | Add-Content -Path $outputFile
    
#    Add-Content -Path $outputFile -Value '```'
    Add-Content -Path $outputFile -Value '---'
#    Add-Content -Path $outputFile -Value ''
}

Write-Host "------------------------------"
Write-Host "SUCCESS: Contents written to $outputFile"