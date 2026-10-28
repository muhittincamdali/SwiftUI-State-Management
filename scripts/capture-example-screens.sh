#!/usr/bin/env bash
# Captures the README screenshots from the StateDemo example app.
#
# The script builds the app, opens it with `-demo <scenario>` (the app then sends the
# scenario's actions to its real stores: sample todos, a todo opened through a deep link, a
# debounced search, and taps on the observation screen), waits for it to finish and takes a
# screenshot in light and dark appearance.
#
# Usage:
#   scripts/capture-example-screens.sh             # the macOS app (default)
#   scripts/capture-example-screens.sh macos
#   scripts/capture-example-screens.sh ios [simulator name or UDID]
# Output: docs/images/demo-<scenario>-<appearance>.png
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
platform="${1:-macos}"
bundle_id="io.github.muhittincamdali.StateDemo"
# scenario name and the seconds it needs before the screenshot
scenarios=("todos 3" "todo-detail 3" "search 4" "observation 3")
output_dir="$repo_root/docs/images"
build_dir="$repo_root/.build/example-screens"
project="$repo_root/Examples/StateDemo/StateDemo.xcodeproj"
mkdir -p "$output_dir"

capture_macos() {
  echo "Building StateDemo for macOS"
  xcodebuild build -project "$project" -scheme StateDemo -destination 'platform=macOS' \
    -derivedDataPath "$build_dir" -quiet
  local app="$build_dir/Build/Products/Debug/StateDemo.app"
  for appearance in light dark; do
    for entry in "${scenarios[@]}"; do
      read -r scenario wait_seconds <<< "$entry"
      "$app/Contents/MacOS/StateDemo" -demo "$scenario" -appearance "$appearance" \
        -AppleLanguages "(en)" -AppleLocale en_US -ApplePersistenceIgnoreState YES >/dev/null 2>&1 &
      local pid=$!
      sleep "$wait_seconds"
      local window
      window="$(swift "$repo_root/scripts/window-id.swift" "$pid")"
      local file="$output_dir/demo-$scenario-$appearance.png"
      # -o leaves out the window shadow; -l captures only the app's window.
      screencapture -x -o -l"$window" "$file"
      kill "$pid"
      wait "$pid" 2>/dev/null || true
      echo "$file"
    done
  done
}

capture_ios() {
  local device="${1:-}"
  if [[ -z "$device" ]]; then
    device="$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+' | sed 's/ *$//')"
  fi
  if [[ -z "$device" ]]; then
    echo "No available iPhone simulator found." >&2
    exit 1
  fi
  local destination="platform=iOS Simulator,name=$device"
  if [[ "$device" =~ ^[0-9A-F-]{36}$ ]]; then
    destination="platform=iOS Simulator,id=$device"
  fi
  echo "Building StateDemo for '$device'"
  xcodebuild build -project "$project" -scheme StateDemo -destination "$destination" \
    -derivedDataPath "$build_dir" -quiet
  local app
  app="$(find "$build_dir/Build/Products" -maxdepth 2 -name 'StateDemo.app' -path '*iphonesimulator*' | head -1)"

  xcrun simctl boot "$device" 2>/dev/null || true
  xcrun simctl bootstatus "$device" -b >/dev/null
  xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
    --cellularBars 4 --wifiBars 3 --operatorName ""
  xcrun simctl install "$device" "$app"
  for appearance in light dark; do
    xcrun simctl ui "$device" appearance "$appearance"
    for entry in "${scenarios[@]}"; do
      read -r scenario wait_seconds <<< "$entry"
      xcrun simctl launch --terminate-running-process "$device" "$bundle_id" -demo "$scenario" \
        -AppleLanguages "(en)" -AppleLocale en_US >/dev/null
      sleep "$wait_seconds"
      local file="$output_dir/demo-$scenario-$appearance.png"
      xcrun simctl io "$device" screenshot --type=png "$file" >/dev/null 2>&1
      # Half the width of an iPhone screenshot keeps the README light.
      sips --resampleWidth 603 "$file" >/dev/null
      echo "$file"
    done
  done
  xcrun simctl status_bar "$device" clear
  xcrun simctl terminate "$device" "$bundle_id" 2>/dev/null || true
}

case "$platform" in
  macos) capture_macos ;;
  ios) capture_ios "${2:-}" ;;
  *) echo "Unknown platform '$platform': use macos or ios." >&2; exit 2 ;;
esac
