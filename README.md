# Windows SD Card Auto Import (영상 자동 리스트 + 전송)

SD카드를 연결하면 자동으로:

1. SD카드 안의 영상 파일을 찾아서 콘솔에 리스트업
2. 지정한 PC 폴더들(D:, E: 등)로 전체 복사/이동
3. (옵션) 앱 자동 실행

## 파일

- `windows_sdcard_mxf_watcher.ps1`

## 주요 기능

- 새로 연결된 **removable drive(SD 카드)** 감지
- 영상 확장자 필터링 (`.mxf`, `.mp4`, `.mov`, `.mkv`, `.avi` 기본)
- 영상 파일 전체 목록 출력
- 대상 폴더 여러 개 지정 가능 (예: `D:\SD_IMPORT`, `E:\SD_BACKUP`)
- `Copy` 또는 `Move` 모드 선택 가능

## 실행 예시

### 1) D/E 드라이브로 복사

```powershell
powershell -ExecutionPolicy Bypass -File .\windows_sdcard_mxf_watcher.ps1 \
  -DestinationFolders "D:\SD_IMPORT","E:\SD_BACKUP" \
  -TransferMode Copy
```

### 2) D/E 드라이브로 이동 + 앱 실행

```powershell
powershell -ExecutionPolicy Bypass -File .\windows_sdcard_mxf_watcher.ps1 \
  -DestinationFolders "D:\SD_IMPORT","E:\SD_BACKUP" \
  -TransferMode Move \
  -LaunchApp \
  -AppPath "C:\Program Files\MyApp\MyApp.exe"
```

## 파라미터

- `AppPath`: 실행할 앱 경로
- `VideoExtensions`: 감지할 영상 확장자 배열
- `DestinationFolders`: 전송할 로컬 폴더 배열
- `TransferMode`: `Copy` 또는 `Move`
- `LaunchApp`: 지정 시 앱 실행
- `PollSeconds`: SD 연결 감지 주기(초)

## 자동 시작

원하면 위 실행 명령으로 바로가기 파일을 만들어 `shell:startup` 폴더에 넣으면 윈도우 로그인 시 자동 실행됩니다.
