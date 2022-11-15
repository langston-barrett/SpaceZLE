#!/usr/bin/env bash
# The above is for ShellCheck

# ---------------------------------------------------------
# Functions

list-man-pages() {
  man -k -l '' | cut -d ' ' -f1
}

# ---------------------------------------------------------
# Commands

# TODO: Preview
help-man() {
  man "$(list-man-pages | spacezle-fzff)" || true
  zle redisplay
}
spacezle-bind help-man 'hm' "help-man" "Display manpage (with FZF)"

help-show-bindings() {
  spacezle-show-bindings 'h'
}
spacezle-prefix help-show-bindings 'h' "help"
