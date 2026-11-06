#!/bin/bash
source "$CONFIG_DIR/colors.sh"

BATT="$(pmset -g batt)"
PCT="$(echo "$BATT" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
[ -z "$PCT" ] && exit 0   # desktop Mac: no battery

case "$PCT" in
  9[0-9]|100) ICON="󰁹"; COLOR=$GREEN ;;
  [6-8][0-9]) ICON="󰂀"; COLOR=$GREEN ;;
  [3-5][0-9]) ICON="󰁾"; COLOR=$YELLOW ;;
  [1-2][0-9]) ICON="󰁻"; COLOR=$ORANGE ;;
  *)          ICON="󰂎"; COLOR=$RED ;;
esac

echo "$BATT" | grep -q 'AC Power' && { ICON="󰂄"; COLOR=$GREEN; }

sketchybar --set "$NAME" icon="$ICON" icon.color=$COLOR label="${PCT}%"
