#!/usr/bin/env bash
# The above is for Shellcheck

spacezle-fzf() {
  local nbuf="${#BUFFER}"
  local start_col=0
  local preview_window=right
  if [[ "${nbuf}" -lt $((COLUMNS-32)) ]]; then
    start_col="${nbuf}"
  fi

  fzf --margin=0,0,0,"${start_col}" \
      --height=10% \
      --min-height=8 \
      --layout=reverse \
      --preview-window="${preview_window}" \
      --prompt='' \
      --info=hidden \
      --bind="bspace:backward-delete-char/eof" \
      --bind="tab:replace-query" \
      "${@}"
}

spacezle-fzff() {
  spacezle-fzf --preview='preview.sh {}' "${@}"
}

spacezle-append-to-buffer() {
  BUFFER+="${1}"
  CURSOR="${#BUFFER}"
  zle redisplay
}

# Insert at cursor, but insert space if one is needed.
spacezle-insert() {
  if [[ "${LBUFFER% }" == "${LBUFFER}" ]]; then
    LBUFFER+=" "
  fi
  LBUFFER+="${1}"
  zle redisplay
}

# Create a new keymap for spacezle. In vi command mode, space enters the new
# keymap. ESC exits it.
bindkey -N spacezle vicmd
bindkey -M spacezle '^[' vi-cmd-mode
spacezle-map() {
  bindkey -N spacezle spacezle-bak
  zle -K spacezle
  zle -M "$(spacezle-print-prefixes)"
}
zle -N spacezle-map
bindkey -M vicmd ' ' spacezle-map

# TODO: Complain about existing names
SPACEZLE_COMMANDS=()
spacezle-register-command() {
  # NB: The delimiter is a Unicode em-space
  SPACEZLE_COMMANDS+=("${3:-unknown} ${1} ${2} ${4:-no help available}")
}

SPACEZLE_BINDINGS=()
# TODO: Complain about existing bindings
spacezle-bind() {
  zle -N "${1}"
  SPACEZLE_BINDINGS+=("${2};${1}")
  bindkey -M spacezle "${2}" "${1}"
  spacezle-register-command "${1}" "${2}" "${3}" "${4}"
}

spacezle-show-kbd() {
  echo "${1}" | sed 's/\^\[\[A/↑/g'
}

spacezle-print-bindings() {
  for bind in "${SPACEZLE_BINDINGS[@]}"; do
    IFS=';' read -rA words <<< "${bind}"
    binding="${words[1]}"
    if [[ -z "${1}" ]] || [[ "${binding#${1}}" != "${binding}" ]]; then
      bind="$(spacezle-show-kbd "${words[1]#${1}}")"
      printf '%s: %s\n' "${bind}" "${words[2]}"
    fi
  done
}

spacezle-show-bindings() {
  zle -M "$(spacezle-print-bindings "${1}")"
  for bind in "${SPACEZLE_BINDINGS[@]}"; do
    IFS=';' read -rA words <<< "${bind}"
    bindkey -M spacezle "${words[1]#${1}}" "${words[2]}"
  done
}

SPACEZLE_PREFIXES=()
spacezle-prefix() {
  zle -N "${1}"
  bindkey -M spacezle "${2}" "${1}"
  SPACEZLE_PREFIXES+=("${2};${1};${3}")
}

spacezle-print-prefixes() {
  for bind in "${SPACEZLE_PREFIXES[@]}"; do
    IFS=';' read -rA words <<< "${bind}"
    prefix="${words[1]}"
    if [[ -z "${1}" ]] || [[ "${prefix#${1}}" != "${prefix}" ]]; then
      printf '%s: %s\n' "${words[1]#${1}}" "${words[3]}"
    fi
  done
}

spacezle-markdown() {
  for pre in "${SPACEZLE_PREFIXES[@]}"; do
    IFS=';' read -rA words <<< "${pre}"
    pfx="${words[1]}"
    printf '- `SPC %s`: %s\n' "${pfx}" "${words[3]}"
    for bind in "${SPACEZLE_BINDINGS[@]}"; do
      IFS=';' read -rA words <<< "${bind}"
      binding="${words[1]}"
      command="${words[2]}"
      if [[ "${binding#${pfx}}" != "${binding}" ]]; then
        for cmd in "${SPACEZLE_COMMANDS[@]}"; do
          IFS=' ' read -rA words <<< "${cmd}"
          if [[ "${words[2]}" == "${command}" ]]; then
            printf '  - `SPC %s %s`: %s\n' "${pfx}" "$(spacezle-show-kbd "${binding#${pfx}}")" "${words[4]}"
          fi
        done
      fi
    done
  done
}

# https://stackoverflow.com/questions/9901210
path_of_this_file="${(%):-%x}"
for f in "$(dirname "${path_of_this_file}")"/keys/*.zsh; do
  source "${f}"
done

# d ----------------------------------------------------------------------------

dir-cd() {
  cd "$(\find "${PWD}" -type d | spacezle-fzf)" || true
}
spacezle-bind dir-cd 'dd' "cd" "Change working directory"

dir-pwd() {
  spacezle-insert "$(pwd)"
}
spacezle-bind dir-pwd 'dw' "pwd" "Insert current working directory"

dir-up() {
  cd .. || true
  zle -M ""
  zle redisplay
}
spacezle-bind dir-up 'du' "cd-up" "Change working directory to parent"

dir-show-bindings() {
  spacezle-show-bindings 'd'
}
spacezle-prefix dir-show-bindings 'd' "dir"

# g ----------------------------------------------------------------------------

spacezle-bind forgit::add 'ga' "git-add" "Launch forgit::add"
spacezle-bind forgit::blame 'gb' "git-blame" "Launch forgit::blame"
spacezle-bind forgit::checkout::branch 'gc' "git-checkout-branch" "Launch forgit::checkout::branch"
spacezle-bind forgit::branch::delete 'gD' "git-branch-delete" "Launch forgit::branch::delete"
spacezle-bind forgit::log 'gl' "git-log" "Launch forgit::log"

git-show-bindings() {
  spacezle-show-bindings 'g'
}
spacezle-prefix git-show-bindings 'g' "git"

# q ----------------------------------------------------------------------------

quit-quit() {
  spacezle-append-to-buffer "exit"
  zle vi-accept-line
}
spacezle-bind quit-quit 'qq' "quit" "Exit zsh"

quit-reload() {
  spacezle-append-to-buffer "exec zsh"
  zle vi-accept-line
}
spacezle-bind quit-reload 'qr' "reload" "Reload ZSH (exec zsh)"

quit-show-bindings() {
  spacezle-show-bindings 'q'
}
spacezle-prefix quit-show-bindings 'q' "quit"

# l ----------------------------------------------------------------------------

zle-clear() {
  clear
  zle redisplay
}
spacezle-bind zle-clear 'l' "clear" "Clear the screen"

# s ----------------------------------------------------------------------------

# ssh

# S ----------------------------------------------------------------------------

sys-halt() {
  spacezle-append-to-buffer "shutdown now"
  vi-accept-line
}
spacezle-bind sys-halt 'SH' "sys-halt" "Halt the computer"

sys-suspend() {
  spacezle-append-to-buffer "systemctl suspend"
  vi-accept-line
}
spacezle-bind sys-suspend 'SS' "sys-suspend" "Suspend the computer"

sys-reboot() {
  spacezle-append-to-buffer "reboot"
  vi-accept-line
}
spacezle-bind sys-reboot 'SR' "sys-reboot" "Reboot the computer"

sys-show-bindings() {
  spacezle-show-bindings 'S'
}
spacezle-prefix sys-show-bindings 'S' "sys"

# w ----------------------------------------------------------------------------

window-left() {
  tmux select-pane -L
}
spacezle-bind window-left 'wh' "window-left" "tmux: Left pane"

window-down() {
  tmux select-pane -D
}
spacezle-bind window-down 'wj' "window-down" "tmux: Down pane"

window-up() {
  tmux select-pane -U
}
spacezle-bind window-up 'wk' "window-up" "tmux: Up pane"

window-right() {
  tmux select-pane -R
}
spacezle-bind window-right 'wl' "window-right" "tmux: Right pane"

# ----

window-hsplit() {
  tmux split-window -v

}
# spacezle-bind window-hsplit 'w-' "window-hsplit" "tmux: Split window horizontally"
spacezle-bind window-hsplit 'wH' "window-hsplit" "tmux: Split window horizontally"

window-vsplit() {
  tmux split-window -h
}
spacezle-bind window-vsplit 'w/' "window-vsplit" "tmux: Split window vertically"

# ----

window-del() {
  tmux kill-pane
}
spacezle-bind window-del 'wd' "window-del" "tmux: Delete pane"

window-last() {
  tmux last-window
}
spacezle-bind window-last 'wL' "window-last" "tmux: Last window"

window-next() {
  tmux next-window
}
spacezle-bind window-next 'wn' "window-next" "tmux: Next window"

window-new() {
  tmux new-window
}
spacezle-bind window-new 'ww' "window-new" "tmux: New window"

window-prev() {
  tmux prev-window
}
spacezle-bind window-prev 'wn' "window-prev" "tmux: Previous window"

window-show-bindings() {
  spacezle-show-bindings 'w'
}
spacezle-prefix window-show-bindings 'w' "window"

# y ----------------------------------------------------------------------------

yank-cwd() {
  pwd | xsel -ib
  zle -R "" "copied '$(pwd)'"
}
spacezle-bind yank-cwd 'yc' "yank-cwd" "Copy current working directory to clipboard"

yank-history() {
  print -rC1 -- "$history[@]" | spacezle-fzf | xsel -ib
  zle -R "" "copied '$(xsel -ob | head -n 1)'"
}
spacezle-bind yank-history 'yh' "yank-history" "Copy command from shell history"

yank-last() {
  printf "%s" "$history[$((HISTCMD-1))]" | xsel -ib
  zle -R "" "copied '$(xsel -ob | head -n 1)'"
}
spacezle-bind yank-last 'yl' "yank-last" "Copy last command to clipboard"

yank-rerun() {
  spacezle-append-to-buffer "$history[$((HISTCMD-1))] 2>&1 |& xsel -ib"
}
spacezle-bind yank-rerun 'yr' "yank-rerun" "Re-run last command and yank output to clipboard"

yank-show-bindings() {
  spacezle-show-bindings 'y'
}
spacezle-prefix yank-show-bindings 'y' "yank"

# x ----------------------------------------------------------------------------

tmux-copy-mode() {
  tmux copy-mode
}
spacezle-bind tmux-copy-mode 'xy' "tmux-copy-mode" "Enter copy mode"

tmux-reload() {
  tmux source-file ~/.tmux.conf
}
spacezle-bind tmux-reload 'xr' "tmux-reload" "Reload"

tmux-list-keys() {
  tmux list-keys
}
spacezle-bind tmux-list-keys 'xh' "tmux-list-keys" "List keybindings"

tmux-status-off() {
  tmux set-option status off
}
spacezle-bind tmux-status-off 'xs' "tmux-status-off" "Disable status bar"

tmux-up() {
  tmux copy-mode
  tmux send -X halfpage-up
}
spacezle-bind tmux-up 'x^[[A' "tmux-up" "Scroll up in copy mode"

tmux-show-bindings() {
  spacezle-show-bindings 'x'
}
spacezle-prefix tmux-show-bindings 'x' "tmux"

# ------------------------------------------------------------------------------

autoload -U edit-command-line
spacezle-bind edit-command-line 'e' "edit-command" "Open current command line in EDITOR"

spacezle-print-commands() {
  for cmd in "${SPACEZLE_COMMANDS[@]}"; do
    printf '%s\n' "${cmd}"
  done
}

spacezle-command-palette() {
  cmd=$(spacezle-print-commands | spacezle-fzf --delimiter=' ' --nth=1 --with-nth=1 --preview="echo 'Binding: <SPACE>{3}\n\n{4}'")
  if [[ -n "${cmd}" ]]; then
    IFS=' ' read -rA words <<< "${cmd}"
    zle "${words[2]}"
  fi
}

zle -N spacezle-command-palette
spacezle-bind spacezle-command-palette ' ' "command-palette" "Open command palette"

# Backup default keybindings, as they get modified when help is shown
bindkey -N spacezle-bak spacezle

