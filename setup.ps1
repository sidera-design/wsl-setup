<#
.SYNOPSIS
  Windows10/11 両対応 WSL2 インストール準備スクリプト

.DESCRIPTION
  ・OS のビルド番号チェック
    - Windows10: ビルド 18362 未満 → インストール不可エラー
    - Windows10: ビルド 18362 以上、19041 未満 → 手動手順
    - Windows10/11: ビルド 19041 以上または Windows11 → wsl --install を案内
  ・WSL と VMPlatform 機能を DISM で有効化
  ・再起動前に手順を表示 → Enter 押下で自動再起動
#>

# WSLのインストール状態を確認（wsl --status が使えればインストール済み）
try {
    $wslInfo = wsl --status 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "WSL はすでにインストールされています。"
        exit 0
    }
} catch {
    # 無視して続行（wsl --status が使えない＝インストールされていない）
}


# 管理者権限チェック
# 管理者として実行されているかチェック
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Host "管理者権限が必要な操作です。UACダイアログで『はい』をクリックすると管理者として実行します。"
    Read-Host "続行するには Enter キーを押してください。"
    
    # 管理者として再実行（UACダイアログが表示される）
    Start-Process powershell `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}
# If (-not ([Security.Principal.WindowsPrincipal] `
#     [Security.Principal.WindowsIdentity]::GetCurrent()
#   ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
#   Write-Warning "管理者として実行してください。スクリプトを右クリック → 『管理者として実行』 を選択。"
#   Pause
#   Exit 1
# }

# OSバージョン・ビルド取得
$os = Get-CimInstance Win32_OperatingSystem
$version = $os.Version  # 例: "10.0.19044"
$parts = $version.Split('.')
[int]$major = $parts[0]; [int]$minor = $parts[1]; [int]$build = $parts[2]

function Show-Incompatible {
  Write-Host "この PC では WSL2 の要件を満たしていません。" -ForegroundColor Red
  Write-Host "  ・Windows 10 ビルド 18362 以上が必要です。" 
  Write-Host "  ・BIOS/UEFI で仮想化 (VT-x/AMD-V) を有効にしてください。" 
  Pause
  Exit 1
}

function Enable-WSLFeatures {
  Write-Host "WSL と仮想マシンプラットフォーム機能を有効化しています..."
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart   | Out-Null
}

Write-Host "`n== WSL2 インストール準備スクリプト ==" -ForegroundColor Cyan
Write-Host "検出された OS バージョン: $version" -ForegroundColor Green

# ビルド番号チェック
if ($major -eq 10 -and $build -lt 18362) {
  Show-Incompatible
}

# 機能有効化
Enable-WSLFeatures

# 手順案内
Write-Host "`n-- 再起動後の手順案内 --`n" -ForegroundColor Cyan
if ($major -eq 10 -and $build -lt 19041) {
  # Windows10 19041 未満：手動手順
  Write-Host "1. https://aka.ms/wsl2kernel から WSL2 カーネル更新プログラムをダウンロード／インストール"  
  Write-Host "2. Microsoft Store で Ubuntu などの Linux ディストリビューションをインストール"
  Write-Host "3. PowerShell を開き、次を実行:" -NoNewline; Write-Host " wsl --set-default-version 2" -ForegroundColor Yellow
}
else {
  # Windows10 19041 以上 または Windows11
  Write-Host "再起動後に次のコマンドで自動インストールが可能です：" -ForegroundColor Green
  Write-Host "`t wsl --install"
}

Write-Host ""  
Read-Host "準備が完了しました。再起動して続行するには Enter キーを押してください"

# 再起動
Write-Host "システムを再起動しています..." -ForegroundColor Yellow
Restart-Computer -Force
