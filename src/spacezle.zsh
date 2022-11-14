#!/usr/bin/env bash
# The above is for Shellcheck

zlefzf() {
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

zlefzff() {
  zlefzf --preview='preview.sh {}' "${@}"
}

zle_append_to_buffer() {
  BUFFER+="${1}"
  CURSOR="${#BUFFER}"
  zle redisplay
}

zle_write_buffer() {
  BUFFER="${1}"
  CURSOR="${#BUFFER}"
  zle redisplay
}

# Insert at cursor, but insert space if one is needed.
zle_insert() {
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
  show-bindings
}
zle -N spacezle-map
bindkey -M vicmd ' ' spacezle-map

# TODO: Generate print-bindings from this array
SPACEZLE_COMMANDS=()
spacezle-register-command() {
  # NB: The delimiter is a Unicode em-space
  SPACEZLE_COMMANDS+=("${3:-unknown} ${1} ${2} ${4:-no help available}")
}

SPACEZLE_BINDINGS=()
zle_bind() {
  zle -N "${1}"
  SPACEZLE_BINDINGS+=("${2};${1}")
  bindkey -M spacezle "${2}" "${1}"
  spacezle-register-command "${1}" "${2}" "${3}" "${4}"
}

spacezle-print-bindings() {
  for bind in "${SPACEZLE_BINDINGS[@]}"; do
    IFS=';' read -A words <<< "${bind}"
    binding="${words[1]}"
    if [[ -z "${1}" ]] || [[ "${binding#${1}}" != "${binding}" ]]; then
      printf '%s: %s\n' "${words[1]#${1}}" "${words[2]}"
    fi
  done
}

SPACEZLE_PREFIXES=()
zle_prefix() {
  zle -N "${1}"
  bindkey -M spacezle "${2}" "${1}"
  SPACEZLE_PREFIXES+=("${2};${1};${3}")
}

spacezle-print-prefixes() {
  for bind in "${SPACEZLE_PREFIXES[@]}"; do
    IFS=';' read -A words <<< "${bind}"
    prefix="${words[1]}"
    if [[ -z "${1}" ]] || [[ "${prefix#${1}}" != "${prefix}" ]]; then
      printf '%s: %s\n' "${words[1]#${1}}" "${words[3]}"
    fi
  done
}

# https://stackoverflow.com/questions/9901210
path_of_this_file="${(%):-%x}"
for f in "$(dirname "${path_of_this_file}")"/keys/*.zsh; do
  source "${f}"
done

# d ----------------------------------------------------------------------------

dir-cd() {
  cd "$(\find "${PWD}" -type d | zlefzf)" || true
}
zle_bind dir-cd 'dd' "cd" "Change working directory"

dir-pwd() {
  zle_insert "$(pwd)"
}
zle_bind dir-pwd 'dw' "pwd" "Insert current working directory"

dir-show-bindings() {
  zle -M "$(spacezle-print-bindings d)"
  bindkey -M spacezle 'd' dir-cd
  bindkey -M spacezle 'w' dir-pwd
}
zle_prefix dir-show-bindings 'd' "dir"

# g ----------------------------------------------------------------------------

zle_bind forgit::add 'ga' "git-add" "Launch forgit::add"
zle_bind forgit::add 'gb' "git-blame" "Launch forgit::blame"
zle_bind forgit::checkout::branch 'gc' "git-checkout-branch" "Launch forgit::checkout::branch"
zle_bind forgit::branch::delete 'gD' "git-branch-delete" "Launch forgit::branch::delete"
zle_bind forgit::log 'gl' "git-log" "Launch forgit::log"

git-show-bindings() {
  zle -M "$(spacezle-print-bindings g)"
  bindkey -M spacezle 'a' forgit::add
  bindkey -M spacezle 'b' forgit::blame
  bindkey -M spacezle 'c' forgit::checkout::branch
  bindkey -M spacezle 'D' forgit::branch::delete
  bindkey -M spacezle 'l' forgit::log
}
zle_prefix git-show-bindings 'g' "git"

# q ----------------------------------------------------------------------------

quit-quit() {
  zle_append_to_buffer "exit"
  zle vi-accept-line
}
zle_bind quit-quit 'qq' "quit" "Exit zsh"

quit-reload() {
  zle_append_to_buffer "exec zsh"
  zle vi-accept-line
}
zle_bind quit-reload 'qr' "reload" "Reload ZSH (exec zsh)"

quit-show-bindings() {
  zle -M "$(spacezle-print-bindings q)"
  bindkey -M spacezle 'q' quit-quit
  bindkey -M spacezle 'r' quit-reload
}
zle_prefix quit-show-bindings 'q' "quit"

# i ----------------------------------------------------------------------------

insert-clipboard() {
  zle_append_to_buffer "$(xsel -ob)"
}
zle_bind insert-clipboard 'ic' "insert-clipboard" "Insert content of system clipboard"

insert-fzf-directory() {
  zle_append_to_buffer "$(fd --type d . | zlefzf)"
}
zle_bind insert-fzf-directory 'id' "insert-dir" "Insert directory with FZF"

insert-fzf-exact-history() {
  zle_append_to_buffer "$(list-history | zlefzf --tac)"
}
zle_bind insert-fzf-exact-history 'ie' "insert-history-exact" "Insert from history with FZF (exact match)"

insert-fzf-file() {
  zle_insert "$(fd --type f . | zlefzff)"
}
zle_bind insert-fzf-file 'if' "insert-file" "Insert file with FZF"

insert-fzf-history() {
  zle_append_to_buffer "$(list-history | zlefzf --tac)"
}
zle_bind insert-fzf-history 'ih' "insert-history" "Insert from history with FZF"

insert-fzf-project() {
  zle_append_to_buffer "$(fd "${PROJECT_ROOT}" | zlefzf)"
}
zle_bind insert-fzf-project 'ip' "insert-project" "Insert file or directory from project root with FZF"

insert-show-bindings() {
  zle -M "$(spacezle-print-bindings i)"
  bindkey -M spacezle 'c' insert-clipboard
  bindkey -M spacezle 'd' insert-fzf-directory
  bindkey -M spacezle 'f' insert-fzf-file
  bindkey -M spacezle 'h' insert-fzf-history
  bindkey -M spacezle 'p' insert-fzf-project
}
zle_prefix insert-show-bindings 'i' "insert"

# l ----------------------------------------------------------------------------

zle-clear() {
  clear
  zle redisplay
}
zle_bind zle-clear 'l' "clear" "Clear the screen"

# s ----------------------------------------------------------------------------

# ssh

# S ----------------------------------------------------------------------------

sys-suspend() {
  zle_append_to_buffer "systemctl suspend"
  vi-accept-line
}
zle_bind sys-suspend 'SS' "sys-suspend" "Suspend the computer"

sys-show-bindings() {
  zle -M "$(spacezle-print-bindings s)"
  bindkey -M spacezle 'S' sys-suspend
}
zle_prefix sys-show-bindings 'S' "sys"

# y ----------------------------------------------------------------------------

yank-cwd() {
  pwd | xsel -ib
  zle -R "" "copied '$()'"
}
zle_bind yank-cwd 'yc' "yank-cwd" "Copy current working directory to clipboard"


yank-last() {
  copy_last_command
  zle -R "" "copied '$(xsel -ob | head -n 1)'"
}
zle_bind yank-last 'yl' "yank-last" "Copy last command to clipboard"

yank-rerun() {
  zle_append_to_buffer "$history[$((HISTCMD-1))] 2>&1 |& xsel -ib"
}
zle_bind yank-rerun 'yr' "yank-rerun" "Re-run last command and yank output to clipboard"

yank-show-bindings() {
  zle -M "$(spacezle-print-bindings y)"
  bindkey -M spacezle 'c' yank-cwd
  bindkey -M spacezle 'l' yank-last
  bindkey -M spacezle 'r' yank-rerun
}
zle_prefix yank-show-bindings 'y' "yank"

# ------------------------------------------------------------------------------

autoload -U edit-command-line
zle_bind edit-command-line 'e' "edit-command" "Open current command line in EDITOR"

spacezle-print-commands() {
  for cmd in "${SPACEZLE_COMMANDS[@]}"; do
    printf '%s\n' "${cmd}"
  done
}

spacezle-command-palette() {
  cmd=$(spacezle-print-commands | zlefzf --delimiter=' ' --nth=1 --with-nth=1 --preview="echo 'Binding: <SPACE>{3}\n\n{4}'")
  if [[ -n "${cmd}" ]]; then
    IFS=' ' read -A words <<< "${cmd}"
    zle "${words[2]}"
  fi
}

zle -N spacezle-command-palette
zle_bind spacezle-command-palette ' ' "command-palette" "Open command palette"

show-bindings() {
  zle -M "$(spacezle-print-prefixes)"
}
# zle_bind show-bindings ''

# Backup default keybindings, as they get modified when help is shown
bindkey -N spacezle-bak spacezle

