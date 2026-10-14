#!/usr/bin/env bash
set -euo pipefail
mkdir -p docs/media
adb shell wm size 1080x2400
adb shell wm density 420
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/portfolio_test.dart --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk --keep-app-running -d emulator-5554
adb pull /sdcard/portfolio-demo.mp4 docs/media/demo-android.mp4
# Install the production entrypoint without clearing the same SQLite data.
adb install -r release-under-test.apk
adb shell am force-stop com.example.kalori_hesaplayici
adb shell am start -n com.example.kalori_hesaplayici/.MainActivity
sleep 3
adb shell uiautomator dump /sdcard/portfolio-view.xml
adb pull /sdcard/portfolio-view.xml docs/media/reopened-view.xml
adb exec-out screencap -p > docs/media/reopened-release.png
python3 - <<'CHECK'
import json,os
from pathlib import Path
xml=Path('docs/media/reopened-view.xml').read_text()
assert '1480' in xml,'Persisted demo data not visible after production APK install/relaunch'
Path('docs/media/verification.json').write_text(json.dumps({'app':'Kalori Takip','commit':os.environ['GITHUB_SHA'],'platform':'Android API 35 emulator','data':'fictional portfolio sample records','checks':['integration workflow passed','production APK installed with adb -r','application force-stopped and relaunched','saved data visible after restart']},ensure_ascii=False,indent=2))
CHECK
