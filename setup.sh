#!/usr/bin/env bash
# yabai + skhd + SketchyBar (+ JankyBorders) in Tokyo Night
# Usage:  bash tokyonight-setup.sh            (full SIP, no scripting addition)
#         USE_SA=1 bash tokyonight-setup.sh   (you installed yabai's scripting addition)
set -euo pipefail

USE_SA="${USE_SA:-0}"
CFG="$HOME/.config"
STAMP="$(date +%s)"

echo "==> Installing packages"
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd
brew tap FelixKratz/formulae
brew install sketchybar borders
brew install --cask font-jetbrains-mono-nerd-font

echo "==> Backing up existing configs"
for d in yabai skhd sketchybar; do
  [ -e "$CFG/$d" ] && mv "$CFG/$d" "$CFG/$d.bak.$STAMP"
done
mkdir -p "$CFG/yabai" "$CFG/skhd" "$CFG/sketchybar/plugins"

# ───────────────────────── yabai ─────────────────────────
cat > "$CFG/yabai/yabairc" <<'EOF'
#!/usr/bin/env sh

# --- scripting addition (only if you disabled SIP partially) ---
# yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
# sudo yabai --load-sa

# --- layout ---
yabai -m config layout                bsp
yabai -m config window_placement      second_child
yabai -m config split_ratio           0.50
yabai -m config auto_balance          off

# --- gaps / bar space (SketchyBar height 32) ---
yabai -m config external_bar          main:32:0
yabai -m config top_padding           10
yabai -m config bottom_padding        10
yabai -m config left_padding          10
yabai -m config right_padding         10
yabai -m config window_gap            10

# --- mouse ---
yabai -m config mouse_follows_focus   off
yabai -m config focus_follows_mouse   off
yabai -m config mouse_modifier        alt
yabai -m config mouse_action1         move
yabai -m config mouse_action2         resize

# --- rules: apps that should float ---
yabai -m rule --add app="^(System Settings|Calculator|Archive Utility|Finder|Activity Monitor|App Store|Preview)$" manage=off
yabai -m rule --add title="^(Settings|Preferences|General|Opening|Copy|Move)$" manage=off

# --- window borders (JankyBorders), Tokyo Night blue / dark grey ---
borders active_color=0xff7aa2f7 inactive_color=0xff414868 width=4.0 style=round &

echo "yabai configuration loaded."
EOF
chmod +x "$CFG/yabai/yabairc"

# ───────────────────────── skhd ─────────────────────────
cat > "$CFG/skhd/skhdrc" <<'EOF'
# ── launch ──
alt - return : open -na "Terminal"
alt - b : open -a "Safari"

# ── focus ──
alt - h : yabai -m window --focus west
alt - j : yabai -m window --focus south
alt - k : yabai -m window --focus north
alt - l : yabai -m window --focus east

# ── move window in the tree ──
shift + alt - h : yabai -m window --warp west
shift + alt - j : yabai -m window --warp south
shift + alt - k : yabai -m window --warp north
shift + alt - l : yabai -m window --warp east

# ── swap windows ──
ctrl + shift + alt - h : yabai -m window --swap west
ctrl + shift + alt - j : yabai -m window --swap south
ctrl + shift + alt - k : yabai -m window --swap north
ctrl + shift + alt - l : yabai -m window --swap east

# ── resize ──
ctrl + alt - h : yabai -m window --resize left:-40:0  || yabai -m window --resize right:-40:0
ctrl + alt - l : yabai -m window --resize right:40:0  || yabai -m window --resize left:40:0
ctrl + alt - j : yabai -m window --resize bottom:0:40 || yabai -m window --resize top:0:40
ctrl + alt - k : yabai -m window --resize top:0:-40   || yabai -m window --resize bottom:0:-40

# ── layout ──
alt - f : yabai -m window --toggle zoom-fullscreen
shift + alt - f : yabai -m window --toggle native-fullscreen
alt - t : yabai -m window --toggle float; yabai -m window --grid 6:6:1:1:4:4
alt - r : yabai -m space --rotate 90
alt - x : yabai -m space --mirror x-axis
alt - y : yabai -m space --mirror y-axis
alt - e : yabai -m space --balance
alt - space : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "stack" else "bsp" end')
alt - tab : yabai -m window --focus recent

# ── displays ──
alt - comma : yabai -m display --focus prev || yabai -m display --focus last
alt - period : yabai -m display --focus next || yabai -m display --focus first

# ── restart everything ──
ctrl + alt + cmd - r : yabai --restart-service; skhd --restart-service; brew services restart sketchybar
EOF

if [ "$USE_SA" = "1" ]; then
cat >> "$CFG/skhd/skhdrc" <<'EOF'

# ── spaces (scripting addition) ──
alt - 1 : yabai -m space --focus 1
alt - 2 : yabai -m space --focus 2
alt - 3 : yabai -m space --focus 3
alt - 4 : yabai -m space --focus 4
alt - 5 : yabai -m space --focus 5
shift + alt - 1 : yabai -m window --space 1 --focus
shift + alt - 2 : yabai -m window --space 2 --focus
shift + alt - 3 : yabai -m window --space 3 --focus
shift + alt - 4 : yabai -m window --space 4 --focus
shift + alt - 5 : yabai -m window --space 5 --focus
EOF
else
cat >> "$CFG/skhd/skhdrc" <<'EOF'

# ── spaces (full SIP: needs "Switch to Desktop N" enabled in
#    System Settings → Keyboard → Keyboard Shortcuts → Mission Control) ──
alt - 1 : skhd -k "ctrl - 1"
alt - 2 : skhd -k "ctrl - 2"
alt - 3 : skhd -k "ctrl - 3"
alt - 4 : skhd -k "ctrl - 4"
alt - 5 : skhd -k "ctrl - 5"
EOF
fi

# ───────────────────── SketchyBar ─────────────────────
cat > "$CFG/sketchybar/colors.sh" <<'EOF'
#!/bin/bash
# Tokyo Night (night variant)
export BG=0xff1a1b26
export BG_DARK=0xff16161e
export BG_HL=0xff292e42
export FG=0xffc0caf5
export COMMENT=0xff565f89
export GREY=0xff414868
export BLUE=0xff7aa2f7
export CYAN=0xff7dcfff
export PURPLE=0xffbb9af7
export GREEN=0xff9ece6a
export ORANGE=0xffff9e64
export YELLOW=0xffe0af68
export RED=0xfff7768e
export TRANSPARENT=0x00000000
EOF

cat > "$CFG/sketchybar/sketchybarrc" <<'EOF'
#!/bin/bash
source "$CONFIG_DIR/colors.sh"
PLUGIN_DIR="$CONFIG_DIR/plugins"
FONT="JetBrainsMono Nerd Font"

# ── bar ──
sketchybar --bar \
  position=top height=32 color=$BG_DARK \
  padding_left=8 padding_right=8 \
  sticky=on shadow=off

# ── defaults ──
sketchybar --default \
  updates=when_shown \
  icon.font="$FONT:Bold:14.0" \
  icon.color=$FG \
  icon.padding_left=6 icon.padding_right=4 \
  label.font="$FONT:Medium:13.0" \
  label.color=$FG \
  label.padding_left=0 label.padding_right=6 \
  padding_left=3 padding_right=3 \
  background.height=24 background.corner_radius=6

# ── left: spaces ──
for sid in 1 2 3 4 5; do
  sketchybar --add space space.$sid left \
    --set space.$sid \
      associated_space=$sid \
      icon=$sid icon.color=$COMMENT icon.padding_left=10 icon.padding_right=10 \
      label.drawing=off \
      background.color=$BG_HL background.drawing=off \
      script="$PLUGIN_DIR/space.sh" \
      click_script="yabai -m space --focus $sid"
done

# ── left: front app ──
sketchybar --add item front_app left \
  --set front_app \
    icon.drawing=off \
    label.color=$PURPLE label.font="$FONT:Bold:13.0" label.padding_left=10 \
    script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched

# ── right (added right-to-left): clock, battery, volume, cpu ──
sketchybar --add item clock right \
  --set clock \
    update_freq=10 icon=󰥔 icon.color=$BLUE \
    background.color=$BG_HL background.drawing=on \
    script="$PLUGIN_DIR/clock.sh"

sketchybar --add item battery right \
  --set battery \
    update_freq=60 \
    background.color=$BG_HL background.drawing=on \
    script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery system_woke power_source_change

sketchybar --add item volume right \
  --set volume \
    background.color=$BG_HL background.drawing=on \
    script="$PLUGIN_DIR/volume.sh" \
  --subscribe volume volume_change

sketchybar --add item cpu right \
  --set cpu \
    update_freq=5 icon=󰻠 icon.color=$ORANGE \
    background.color=$BG_HL background.drawing=on \
    script="$PLUGIN_DIR/cpu.sh"

sketchybar --update
EOF

cat > "$CFG/sketchybar/plugins/space.sh" <<'EOF'
#!/bin/bash
source "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=on background.color=$BLUE icon.color=$BG_DARK
else
  sketchybar --set "$NAME" background.drawing=off icon.color=$COMMENT
fi
EOF

cat > "$CFG/sketchybar/plugins/front_app.sh" <<'EOF'
#!/bin/bash
[ "$SENDER" = "front_app_switched" ] && sketchybar --set "$NAME" label="$INFO"
EOF

cat > "$CFG/sketchybar/plugins/clock.sh" <<'EOF'
#!/bin/bash
sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M')"
EOF

cat > "$CFG/sketchybar/plugins/battery.sh" <<'EOF'
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
EOF

cat > "$CFG/sketchybar/plugins/volume.sh" <<'EOF'
#!/bin/bash
source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "volume_change" ]; then
  VOL="$INFO"
  case "$VOL" in
    0)                 ICON="󰖁" ;;
    [1-9]|[1-2][0-9])  ICON="󰕿" ;;
    [3-5][0-9])        ICON="󰖀" ;;
    *)                 ICON="󰕾" ;;
  esac
  sketchybar --set "$NAME" icon="$ICON" icon.color=$CYAN label="${VOL}%"
fi
EOF

cat > "$CFG/sketchybar/plugins/cpu.sh" <<'EOF'
#!/bin/bash
CORES="$(sysctl -n hw.ncpu)"
CPU="$(ps -A -o %cpu | awk -v c="$CORES" '{s+=$1} END {printf "%d", s/c}')"
sketchybar --set "$NAME" label="${CPU}%"
EOF

chmod +x "$CFG/sketchybar/sketchybarrc" "$CFG/sketchybar/plugins/"*.sh "$CFG/sketchybar/colors.sh"

# ───────────────────── services ─────────────────────
echo "==> Starting services"
yabai --start-service  || true
skhd --start-service   || true
brew services start sketchybar || true

cat <<'MSG'

Done. Remaining manual steps:
  1. System Settings → Privacy & Security → Accessibility: allow yabai and skhd.
  2. System Settings → Control Center → "Automatically hide and show the menu bar" → Always.
  3. If you did NOT use USE_SA=1: enable "Switch to Desktop 1-5" under
     Keyboard → Keyboard Shortcuts → Mission Control, and create at least 5 spaces.
  4. Restart everything with:  ctrl + alt + cmd - r
MSG
