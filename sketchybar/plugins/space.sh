#!/bin/bash
source "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=on background.color=$BLUE icon.color=$BG_DARK
else
  sketchybar --set "$NAME" background.drawing=off icon.color=$COMMENT
fi
