# SD 카드 연결 시 영상 파일을 자동으로 탐지/리스트업하고
# 지정한 PC 경로(예: D:, E:)로 전체 복사/이동할 수 있는 watcher 스크립트

param(
  [string]$AppPath = "C:\\Program Files\\MyApp\\MyApp.exe",
  [string[]]$VideoExtensions = @(".mxf", ".mp4", ".mov", ".mkv", ".avi"),
  [string[]]$DestinationFolders = @("D:\\SD_IMPORT", "E:\\SD_BACKUP"),
  [ValidateSet("Copy", "Move")]
  [string]$TransferMode = "Move",
  [switch]$LaunchApp,
  [int]$PollSeconds = 2
)

Write-Host "SD watcher 시작... (Mode=$TransferMode)"

$seen = @{}

function Get-VideoFiles {
  param(
    [string]$RootPath,
    [string[]]$Extensions
  )

  $extHash = @{}
  foreach ($ext in $Extensions) {
    $extHash[$ext.ToLowerInvariant()] = $true
  }

  Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $extHash.ContainsKey($_.Extension.ToLowerInvariant()) }
}

function Ensure-Folder {
  param([string]$Path)

  if (-not (Test-Path $Path)) {
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
  }
}

while ($true) {
  $drives = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }

  foreach ($drive in $drives) {
    $id = $drive.DeviceID

    if (-not $seen.ContainsKey($id)) {
      $seen[$id] = $true
      $root = "$id\\"

      Write-Host "감지됨: $id"

      if ($LaunchApp -and (Test-Path $AppPath)) {
        Start-Process -FilePath $AppPath
        Write-Host "앱 실행: $AppPath"
      }

      $videos = @(Get-VideoFiles -RootPath $root -Extensions $VideoExtensions)

      if ($videos.Count -eq 0) {
        Write-Host "영상 파일이 없습니다."
        continue
      }

      Write-Host "영상 파일 리스트 ($($videos.Count)개):"
      $videos | ForEach-Object {
        Write-Host (" - " + $_.FullName)
      }

      foreach ($destRoot in $DestinationFolders) {
        Ensure-Folder -Path $destRoot

        $cardFolderName = "SD_" + $id.Replace(':', '') + "_" + (Get-Date -Format "yyyyMMdd_HHmmss")
        $targetFolder = Join-Path $destRoot $cardFolderName
        Ensure-Folder -Path $targetFolder

        Write-Host "전송 대상: $targetFolder"

        foreach ($file in $videos) {
          $destinationFile = Join-Path $targetFolder $file.Name

          if ($TransferMode -eq "Copy") {
            Copy-Item -Path $file.FullName -Destination $destinationFile -Force
          } else {
            Move-Item -Path $file.FullName -Destination $destinationFile -Force
          }
        }
      }

      Write-Host "전송 완료"
    }
  }

  $active = $drives.DeviceID
  foreach ($k in @($seen.Keys)) {
    if ($active -notcontains $k) {
      $seen.Remove($k)
    }
  }

  Start-Sleep -Seconds $PollSeconds
}
