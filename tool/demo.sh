#!/usr/bin/env bash
# Roda o teste de ponta a ponta no emulador, gravando a tela.
# Saídas: docs/screenshots/*.png (prints) e demo/fast_location_demo.mp4 (vídeo).
set -u

APP_ID="com.fastdelivery.fast_location"
mkdir -p docs/screenshots demo

adb shell settings put global window_animation_scale 1 || true
adb shell settings put global transition_animation_scale 1 || true
# Localização do emulador em Florianópolis (a rota parte daqui).
adb emu geo fix -48.5482 -27.5954 || true

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  > drive.log 2>&1 &
DRIVE_PID=$!

# A gravação só começa quando o app abre (antes disso é só a compilação).
for _ in $(seq 1 900); do
  if [ -n "$(adb shell pidof "$APP_ID" 2>/dev/null | tr -d '\r')" ]; then
    break
  fi
  if ! kill -0 "$DRIVE_PID" 2>/dev/null; then
    break
  fi
  sleep 1
done

adb shell screenrecord --bit-rate 6000000 --time-limit 175 /sdcard/demo.mp4 &
REC_PID=$!

wait "$DRIVE_PID"
STATUS=$?

sleep 2
adb shell pkill -INT screenrecord || true
wait "$REC_PID" 2>/dev/null || true
sleep 3
adb pull /sdcard/demo.mp4 demo/fast_location_demo.mp4 || true

cat drive.log
exit "$STATUS"
