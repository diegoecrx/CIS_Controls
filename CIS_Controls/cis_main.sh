# ====== Colors & Glyphs ======
color_enabled() {
  [[ -t 1 && -z "${NO_COLOR:-}" ]]
}

C_RESET=$'\e[0m'
C_GREEN=$'\e[32m'
C_RED=$'\e[31m'
GLYPH_OK=$'\xE2\x9C\x93'   # ✓
GLYPH_FAIL=$'\xE2\x9C\x97' # ✗

paint_green() { color_enabled && printf "%s%s%s" "$C_GREEN" "$1" "$C_RESET" || printf "%s" "$1"; }
paint_red()   { color_enabled && printf "%s%s%s" "$C_RED"   "$1" "$C_RESET" || printf "%s" "$1"; }

status_glyph_colored() {
  # Arg: control_id
  local st
  st="$(last_execute_status "$1")"
  if [[ "$st" == "complete" ]]; then
    printf "%s %s" "$(paint_green "$GLYPH_OK")" "$(paint_green "complete")"
  else
    printf "%s %s" "$(paint_red "$GLYPH_FAIL")" "$(paint_red "pending")"
  fi
}

# ====== Table Utilities ======
draw_rule() {
  # Args: widths...  (e.g., draw_rule 6 55 11)
  local parts=() w
  for w in "$@"; do
    parts+=("+$(printf '%-*s' "$w" '' | tr ' ' '-')")
  done
  printf "%s+\n" "${parts[*]}"
}

print_row() {
  # Args: width value ; width value ; width value ...
  local out="|"
  while (( "$#" )); do
    local w="$1"; shift
    local v="$1"; shift
    printf -v out "%s %-${w}s |" "$out" "${v:0:$w}"
  done
  printf "%s\n" "$out"
}

print_controls_table() {
  # Args: bash array name with "ID|TITLE"
  # Column widths tuned for 80–100 col terminals
  local -n arr="$1"
  local W_ID=6 W_TITLE=55 W_STATUS=11

  draw_rule  "$W_ID" "$W_TITLE" "$W_STATUS"
  print_row  "$W_ID" "ID" "$W_TITLE" "Title" "$W_STATUS" "Status"
  draw_rule  "$W_ID" "$W_TITLE" "$W_STATUS"

  local row id title
  for row in "${arr[@]}"; do
    IFS='|' read -r id title <<<"$row"
    local status
    status="$(status_glyph_colored "$id")"
    print_row "$W_ID" "$id" "$W_TITLE" "$title" "$W_STATUS" "$status"
  done
  draw_rule "$W_ID" "$W_TITLE" "$W_STATUS"
}

print_sections_table() {
  # Renders main menu sections as a table with status glyphs.
  local rows=()
  rows+=("1|${SECTION_TITLES[1]}")
  rows+=("2|${SECTION_TITLES[2]}")
  rows+=("3|${SECTION_TITLES[3]}")
  rows+=("4|${SECTION_TITLES[4]}")
  rows+=("5|${SECTION_TITLES[5]}")
  rows+=("6|${SECTION_TITLES[6]}")

  local W_ID=4 W_TITLE=60 W_STATUS=11
  draw_rule "$W_ID" "$W_TITLE" "$W_STATUS"
  print_row "$W_ID" "No." "$W_TITLE" "Section" "$W_STATUS" "Status"
  draw_rule "$W_ID" "$W_TITLE" "$W_STATUS"

  local i row id title status
  for row in "${rows[@]}"; do
    IFS='|' read -r id title <<<"$row"
    # compute section status: complete if all controls complete
    local var="SECTION_${id}_ITEMS"
    local -n list="$var"
    local all_ok=1 item id2 name
    for item in "${list[@]}"; do
      IFS='|' read -r id2 name <<<"$item"
      [[ "$(last_execute_status "$id2")" == "complete" ]] || { all_ok=0; break; }
    done
    if (( all_ok )); then
      status="$(paint_green "$GLYPH_OK") $(paint_green "complete")"
    else
      status="$(paint_red "$GLYPH_FAIL") $(paint_red "pending")"
    fi
    print_row "$W_ID" "$id" "$W_TITLE" "$title" "$W_STATUS" "$status"
  done
  draw_rule "$W_ID" "$W_TITLE" "$W_STATUS"
}
