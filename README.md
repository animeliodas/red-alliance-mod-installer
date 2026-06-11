# Red Alliance Mod Installer

Установщик модов для Red Alliance. Скачайте `install.bat` и `install.ps1`, положите рядом, запустите `install.bat`.

## Варианты установки

1. **Red Alliance v1.4** — Speedrun Tools для новой версии игры (таймеры RTA/IGT, LiveSplit, быстрый рестарт, клип-механики, спидран-режим).
2. **Red Alliance v1.3** — Speedrun Tools для старой версии (таймеры, LiveSplit, рестарт по TAB, меню F10) + предложит поставить **Optimization Fix** (настоятельно рекомендуется: без него v1.3 фризит после 20–30 загрузок уровней).
3. **Fix only** — только Optimization Fix для v1.3: лечит фризы и разгружает процессор, никаких спидран-инструментов. Для обычной игры.

## Что делает установщик

- Находит папку игры (стандартные пути Steam) или спрашивает путь.
- Ставит BepInEx 5 (если ещё не стоит), архитектура x86/x64 определяется по exe игры.
- Скачивает выбранные плагины из GitHub-релизов и кладёт в `BepInEx/plugins`.

## Оффлайн-установка

Если рядом со скриптом есть папка `payload` с файлами (`RedAllianceSpeedrun.dll`, `RedAllianceOptimizationFix.dll`, `BepInEx_win_x86_5.4.23.5.zip`) — используются они, без скачивания.

## Удаление

Удалить `BepInEx/plugins/RedAllianceSpeedrun.dll` и/или `RedAllianceOptimizationFix.dll`. Полное удаление модов — удалить папку `BepInEx` и файлы `winhttp.dll`, `doorstop_config.ini` из папки игры.

---

Перед публикацией: заполнить слаги репозиториев в начале `install.ps1` (`$RepoSpeedrunV14`, `$RepoSpeedrunV13`, `$RepoOptimizationFix`) и приложить DLL как ассеты к релизам.
