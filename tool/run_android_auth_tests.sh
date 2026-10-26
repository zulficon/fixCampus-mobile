#!/usr/bin/env bash
set -euo pipefail

# Yalnızca test hesabı bilgileri içeren, git dışında tutulan JSON dosyasını kullanın.
# Emülatör açık ve uygulama çıkış yapılmış durumda olmalıdır.
if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Kullanım: bash tool/run_android_auth_tests.sh /git-disindaki/config.json [emulator-5554]" >&2
  exit 2
fi
config_path="$1"
device_id="${2:-emulator-5554}"
for phase in auth_profile session_restart logout_restart; do
  flutter test "integration_test/${phase}_test.dart" \
    -d "$device_id" --no-uninstall --reporter expanded \
    --dart-define-from-file="$config_path"
done
