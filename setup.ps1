# FastLocation - prepara o projeto no Windows (PowerShell)
# Uso: na pasta do projeto, rode  .\setup.ps1

$ErrorActionPreference = "Stop"

Write-Host "1/3 Gerando as pastas nativas (somente Android e iOS)..."
flutter create --platforms=android,ios --org com.fastdelivery --project-name fast_location .

Write-Host "2/3 Instalando dependências..."
flutter pub get

Write-Host "3/3 Gerando código do MobX e do Hive..."
dart run build_runner build --delete-conflicting-outputs

Write-Host "Pronto. Rode: flutter run"
