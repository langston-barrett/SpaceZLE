# SpaceZLE

SpaceZLE is a set of mnemonic, discoverable keybindings for the ZSH Line
Editor, inspired by [Spacemacs][spacemacs].

SpaceZLE creates a new ZLE keymap, and by default binds it to the space key
(`SPC`) in ZLE's "normal mode" keymap (`vicmd`). This keymap consists of
*mnemonic*, *prefixed* keybindings, like `SPC i c` to insert the content of the
system clipboard, or `SPC p f` to open a **f**ile from the current **p**roject
in your `$EDITOR`. `SPC SPC` opens a command palette, which shows all available
commands, their keybindings, and documentation.

These keybindings are also *discoverable*: pressing `SPC` shows a description
of each prefix below the prompt, `SPC i` shows the names and bindings for
`SPC i c`, `SPC i d`, and so on.

SpaceZLE is written in pure ZSH, and there's virtually no performance penalty
for using it.

## Keybindings

- `SPC SPC`: Command palette
- `SPC d`: dir
  - `SPC d d`: Change working directory
  - `SPC d w`: Insert current working directory
  - `SPC d u`: Change working directory to parent
- `SPC g`: git
  - `SPC g a`: Launch forgit::add
  - `SPC g b`: Launch forgit::blame
  - `SPC g c`: Launch forgit::checkout::branch
  - `SPC g D`: Launch forgit::branch::delete
  - `SPC g l`: Launch forgit::log
- `SPC h`: help
  - `SPC h m`: Display manpage (with FZF)
- `SPC i`: insert
  - `SPC i c`: Insert content of system clipboard
  - `SPC i d`: Insert directory with FZF
  - `SPC i e`: Insert from history with FZF (exact match)
  - `SPC i f`: Insert file with FZF
  - `SPC i h`: Insert from history with FZF
  - `SPC i p`: Insert file or directory from project root with FZF
- `SPC p`: project
  - `SPC p c`: Change to directory in project with FZF
  - `SPC p e`: Open EDITOR in project root
  - `SPC p f`: Open file in project in EDITOR with FZF
  - `SPC p M`: Run Make in the project root
- `SPC q`: quit
  - `SPC q q`: Exit zsh
  - `SPC q r`: Reload ZSH (exec zsh)
- `SPC S`: sys
  - `SPC S H`: Halt the computer
  - `SPC S S`: Suspend the computer
  - `SPC S R`: Reboot the computer
- `SPC w`: window
  - `SPC w h`: tmux: Left pane
  - `SPC w j`: tmux: Down pane
  - `SPC w k`: tmux: Up pane
  - `SPC w l`: tmux: Right pane
  - `SPC w H`: tmux: Split window horizontally
  - `SPC w /`: tmux: Split window vertically
  - `SPC w d`: tmux: Delete pane
  - `SPC w L`: tmux: Last window
  - `SPC w n`: tmux: Next window
  - `SPC w w`: tmux: New window
  - `SPC w n`: tmux: Previous window
- `SPC y`: yank
  - `SPC y c`: Copy current working directory to clipboard
  - `SPC y l`: Copy last command to clipboard
  - `SPC y r`: Re-run last command and yank output to clipboard
- `SPC x`: tmux
  - `SPC x y`: Enter copy mode
  - `SPC x r`: Reload
  - `SPC x h`: List keybindings
  - `SPC x s`: Disable status bar
  - `SPC x ↑`: Scroll up in copy mode

## Installation

### Manual

Clone the repo somewhere:
```sh
git clone https://github.com/langston-barrett/SpaceZLE ~/somewhere
```
Then add this line to your `~/.zshrc`:
```sh
source ~/somewhere/src/spacezle.zsh
```

## Optional Dependencies

SpaceZLE does not *require* any external tools, but some of the keybindings
are significantly improved if they're available:

- [fd][fd]
- [FZF][fzf]
- [forgit][forgit]
- tmux
- xsel

A few keybindings won't work properly without these tools, but the goal is
to eventually have a fallback when a tool isn't available.

## Configuration

### Adding a Command

TODO

### Adding a Binding

TODO

[fd]: https://github.com/sharkdp/fd
[forgit]: https://github.com/wfxr/forgit
[fzf]: https://github.com/junegunn/fzf
[spacemacs]: https://www.spacemacs.org/