#!/bin/bash
#
# Update Starship colors from wallust without changing the config structure
#

WALLUST_COLORS="$HOME/.config/kitty/colors-wallust.conf"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

if [ ! -f "$WALLUST_COLORS" ]; then
  echo "Wallust colors file not found: $WALLUST_COLORS"
  exit 1
fi

if [ ! -f "$STARSHIP_CONFIG" ]; then
  echo "Starship config not found: $STARSHIP_CONFIG"
  exit 1
fi

# Extract colors from wallust config
declare -A colors
while IFS= read -r line; do
  if [[ $line =~ ^color([0-9]+)[[:space:]]+(.+)$ ]]; then
    num="${BASH_REMATCH[1]}"
    hex="${BASH_REMATCH[2]}"
    colors[$num]="$hex"
  fi
done <"$WALLUST_COLORS"

# Create a backup
cp "$STARSHIP_CONFIG" "$STARSHIP_CONFIG.backup"

# Use awk to update only the catppuccin_mocha palette
awk -v red="${colors[5]}" -v peach="${colors[6]}" -v yellow="${colors[7]}" -v green="${colors[4]}" -v sapphire="${colors[2]}" -v lavender="${colors[3]}" -v crust="${colors[0]}" -v text="${colors[15]}" '
/^\[palettes\.catppuccin_mocha\]/ { in_mocha = 1 }
/^\[palettes\./ && !/^\[palettes\.catppuccin_mocha\]/ { in_mocha = 0 }
/^$/ { in_mocha = 0 }
in_mocha && /^red = / { print "red = \"" red "\""; next }
in_mocha && /^peach = / { print "peach = \"" peach "\""; next }
in_mocha && /^yellow = / { print "yellow = \"" yellow "\""; next }
in_mocha && /^green = / { print "green = \"" green "\""; next }
in_mocha && /^sapphire = / { print "sapphire = \"" sapphire "\""; next }
in_mocha && /^lavender = / { print "lavender = \"" lavender "\""; next }
in_mocha && /^crust = / { print "crust = \"" crust "\""; next }
in_mocha && /^base = / { print "base = \"" crust "\""; next }
in_mocha && /^text = / { print "text = \"" text "\""; next }
{ print }
' "$STARSHIP_CONFIG" >"$STARSHIP_CONFIG.tmp" && mv "$STARSHIP_CONFIG.tmp" "$STARSHIP_CONFIG"

echo "Updated starship colors with wallust palette"

