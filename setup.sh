#!/usr/bin/env bash
# FastLocation - prepara o projeto (macOS/Linux)
# Uso: na pasta do projeto, rode  ./setup.sh
set -e

echo "1/3 Gerando as pastas nativas (somente Android e iOS)..."
flutter create --platforms=android,ios --org com.fastdelivery --project-name fast_location .

echo "2/3 Instalando dependências..."
flutter pub get

echo "3/3 Gerando código do MobX e do Hive..."
dart run build_runner build --delete-conflicting-outputs

echo "Pronto. Rode: flutter run"
