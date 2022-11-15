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