#!/usr/bin/env bash
# The above is for ShellCheck

# ---------------------------------------------------------
# Functions

find_project_root() {
  local root
  root=$(realpath "${1:-${PWD}}")
  while true; do
    if [[ ${root} == "." ]]; then
      printf "%s" "${root}"
      break
    fi
    if [[ ${root} == / ]] || \
       [[ -d ${root}/.git  ]] || \
       [[ -d ${root}/cabal.project  ]]; then
      break
    fi
    root=$(dirname "${root}")
  done
  printf "%s" "${root}"
}

# Set PROJECT_ROOT whenever the current working directory changes
autoload -Uz add-zsh-hook
add-zsh-hook chpwd set_project_root

set_project_root() {
  export PROJECT_ROOT=$(find_project_root)
}

# Set the initial value
set_project_root

# ---------------------------------------------------------
# Commands

project-cd() {
  local dir
  dir="$(realpath --relative-to="${PWD}" ${PROJECT_ROOT})"
  cd "$(fd . --type d "${dir}" | zlefzff)" || true
  zle redisplay
}
zle_bind project-cd 'pc' "project-cd" "Change to directory in project with FZF"

project-editor() {
  cd "${PROJECT_ROOT}" || return
  "${EDITOR}"
}
zle_bind project-editor 'pe' "project-edit" "Open EDITOR in project root"

project-file() {
  cd "${PROJECT_ROOT}" || return
  ee "$(fd --type f . | zlefzf)"
}
zle_bind project-file 'pf' "project-file" "Open file in project in EDITOR with FZF"

project-make() {
  zle_append_to_buffer "make -C ${PROJECT_ROOT} "
}
zle_bind project-make 'pM' "project-make" "Run Make in the project root"

project-show-bindings() {
  spacezle-show-bindings 'p'
}
zle_prefix project-show-bindings 'p' "project"

