# Windows SD Card Auto Start + MXF Foldering

This repository contains a PowerShell watcher script for your requirement:

- Detect when an SD card (removable drive) is connected.
- Automatically start your application.
- Move (`fold`) `.MXF` files into a dedicated folder.

## File

- `windows_sdcard_mxf_watcher.ps1`

## Configure

Edit the defaults in the script (or pass parameters):

- `AppPath`: Full path to your Windows app executable.
- `ArchiveFolderName`: Folder created on SD card where `.MXF` files are moved.

## Run

Open PowerShell as Administrator (optional, recommended) and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows_sdcard_mxf_watcher.ps1 -AppPath "C:\Program Files\MyApp\MyApp.exe" -ArchiveFolderName "MXF_ARCHIVE"
```

## Auto-start with Windows (optional)

Create a shortcut to this command and put it in:

`shell:startup`

So the watcher runs when Windows starts.
