# 定数定義
[string]$EnvVarName = 'WSLTOOL_DISTRO'

function Resolve-WslDistro {
    [CmdletBinding()]
    param(
        [string]$DistroParam = $null
    )
    # ディストロ名が指定されていればそれを使う
    if ($DistroParam) {
        if ( -not (Test-WslDistroExists $DistroParam)) {
            throw "指定ディストリ '$DistroParam' は存在しません（wsl -l -q で確認を）。"
        }
        return $DistroParam
    }

    # 環境変数が設定されていればそれを使う
    $envVal = (Get-Item "Env:$EnvVarName" -ErrorAction SilentlyContinue).Value
    if ($envVal) {
        if (-not (Test-WslDistroExists $envVal)) {
            throw "環境変数 $EnvVarName='$envVal' は存在しないディストリです。"
        }
        return $envVal        
    }

    # 既定ディストリを取得
    $def = Get-WslDefaultDistroName
    if (-not ($def)) {
        throw "WSLのターゲットが特定できません。"
    }
    return $def    
}
