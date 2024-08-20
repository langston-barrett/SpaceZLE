#!/usr/bin/env bash
# The above is for ShellCheck

# ---------------------------------------------------------
# Functions

seds() {
  sed "$(printf 's|%s|%s|g' "${1}" "${2}")"
}

list-history() {
  fc -l 1 | seds '^ *[[:digit:]]*\** *' ''
}

# ---------------------------------------------------------
# Commands

insert-clipboard() {
  spacezle-insert "$(xsel -ob)"
}
spacezle-bind insert-clipboard 'ic' "insert-clipboard" "Insert content of system clipboard"

insert-fzf-directory() {
  spacezle-append-to-buffer "$(fd --type d . | spacezle-fzf)"
}
spacezle-bind insert-fzf-directory 'id' "insert-dir" "Insert directory with FZF"

insert-fzf-exact-history() {
  spacezle-append-to-buffer "$(list-history | spacezle-fzf --tac)"
}
spacezle-bind insert-fzf-exact-history 'ie' "insert-history-exact" "Insert from history with FZF (exact match)"

insert-fzf-file() {
  spacezle-insert "$(fd --type f . | spacezle-fzff)"
}
spacezle-bind insert-fzf-file 'if' "insert-file" "Insert file with FZF"

insert-fzf-history() {
  spacezle-append-to-buffer "$(list-history | spacezle-fzf --tac)"
}
spacezle-bind insert-fzf-history 'ih' "insert-history" "Insert from history with FZF"

insert-fzf-project() {
  spacezle-append-to-buffer "$(fd "${PROJECT_ROOT}" | spacezle-fzf)"
}
spacezle-bind insert-fzf-project 'ip' "insert-project" "Insert file or directory from project root with FZF"

insert-pwd() {
  spacezle-insert "$(pwd)"
}
spacezle-bind insert-pwd 'iw' "insert-working-directory" "Insert current working directory"

insert-show-bindings() {
  spacezle-show-bindings 'i'
}
spacezle-prefix insert-show-bindings 'i' "insert"

