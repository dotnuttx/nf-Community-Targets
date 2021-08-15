#!/usr/bin/pwsh-preview

function outputReport {
    $ret = $args[0]
    $name = $args[1]

    # error
    if (-not ($ret -eq 0)) {
        Write-Host -NoNewline " 💩 "
        Write-Host "$name" `
            -ForegroundColor Black `
            -BackgroundColor Red
    } else {
        Write-Host -NoNewline " 😁 "
        Write-Host "$name" `
            -ForegroundColor Black `
            -BackgroundColor Green
    }
}

./build.sh wsl release
$wslRet = $LASTEXITCODE

./build.sh wsl debug
$wslDebugRet = $LASTEXITCODE

./build.sh pi-zero container
$piZeroRet = $LASTEXITCODE

./build.sh jh7100 container
$jh7100Ret = $LASTEXITCODE

./build.sh pi-pico release
$piPicoRet = $LASTEXITCODE

./build.sh esp32c3 release
$esp32C3Ret = $LASTEXITCODE

# reports
Write-Host -NoNewline " ⚠️ "
Write-Host "Build Report ::" `
    -ForegroundColor Black `
    -BackgroundColor DarkYellow

outputReport $wslRet        " WSL 2              -   Linux x86_64    -   Release "
outputReport $wslDebugRet   " WSL 2              -   Linux x86_64    -   Debug   "
outputReport $piZeroRet     " Raspberry Pi Zero  -   arm32v6         -   Release "
outputReport $jh7100Ret     " StarFive JH7100    -   rcv64           -   Release "
outputReport $piPicoRet     " Raspberry Pi Pico  -   arm M0+         -   Release "
outputReport $esp32C3Ret    " ESP32 C3           -   rcv32           -   Release "
