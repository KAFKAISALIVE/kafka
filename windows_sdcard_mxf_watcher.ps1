# Watches for removable drives and launches app when an SD card is mounted.
# Then folds (moves) .MXF files into an archive folder on that SD card.

param(
  [string]$AppPath = "C:\\Program Files\\MyApp\\MyApp.exe",
  [string]$ArchiveFolderName = "MXF_ARCHIVE"
)

Write-Host "Starting SD-card watcher..."

$seen = @{}

while ($true) {
  $drives = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }

  foreach ($drive in $drives) {
    $id = $drive.DeviceID
    if (-not $seen.ContainsKey($id)) {
      $seen[$id] = $true
      Write-Host "Detected removable drive: $id"

      if (Test-Path $AppPath) {
        Start-Process -FilePath $AppPath
        Write-Host "Launched app: $AppPath"
      } else {
        Write-Warning "App not found: $AppPath"
      }

      $archivePath = Join-Path "$id\\" $ArchiveFolderName
      if (-not (Test-Path $archivePath)) {
        New-Item -ItemType Directory -Path $archivePath | Out-Null
      }

      Get-ChildItem -Path "$id\\" -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -ieq ".mxf" } |
        ForEach-Object {
          $destination = Join-Path $archivePath $_.Name
          Move-Item -Path $_.FullName -Destination $destination -Force
          Write-Host "Moved MXF file: $($_.FullName) -> $destination"
        }
    }
  }

  # Clean up disconnected drives from cache
  $active = $drives.DeviceID
  foreach ($k in @($seen.Keys)) {
    if ($active -notcontains $k) {
      $seen.Remove($k)
    }
  }

  Start-Sleep -Seconds 2
}
