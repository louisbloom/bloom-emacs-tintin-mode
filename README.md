# tintin-mode

Emacs major mode for editing [TinTin++](https://tintin.mudhalla.net/) `.tin` script files.

## Features

- Syntax highlighting for commands, control flow, variables, functions, and comments
- Pattern matching (`%0`–`%99`, `%*`), speedwalk (`3n2e4sw`), and direction (`w`, `3e`) highlighting
- Three comment styles: `/* */` blocks, `//` lines, and `#nop`
- Brace matching (`C-M-f` / `C-M-b`) and brace highlighting
- Indentation based on brace nesting (`TAB`)
- Case-insensitive command recognition
- [Charm](https://charm.land)-inspired color palette with 8 faces (dark and light variants)

## Why this mode?

MELPA already has a [tintin-mode](https://github.com/matthewrsilver/tintin-mode) with broad feature coverage including subcommand option highlighting, configurable prefix characters, and ANSI color code highlighting.

This mode takes a different approach, focusing on aesthetics and readability:

| Feature                              | MELPA                   | This mode                                                                    |
| ------------------------------------ | ----------------------- | ---------------------------------------------------------------------------- |
| Color scheme                         | Inherits theme defaults | Custom [Charm](https://charm.land) palette, 8 faces with dark/light variants |
| Command categories                   | Single keyword face     | Separate faces for control flow, functions, actions, variables               |
| `//` line comments                   | No                      | Yes                                                                          |
| Catch-all `#command`                 | No                      | Yes — unknown commands still get highlighted                                 |
| Pattern captures (`%0`–`%99`, `%*`)  | Yes                     | Yes                                                                          |
| Speedwalk and direction highlighting | Yes                     | Yes — context-aware, only inside braces as standalone commands               |
| Number and escape highlighting       | No                      | Yes                                                                          |
| Brace and semicolon highlighting     | No                      | Yes                                                                          |
| Subcommand option highlighting       | Yes                     | No                                                                           |
| Configurable prefix character        | Yes                     | No                                                                           |
| ANSI color code highlighting         | Yes                     | No                                                                           |

Install this one if you prefer how it looks.

## Installation

### Manual

```bash
git clone https://codeberg.org/thomasc/emacs-tintin-mode.git
```

Add to your init file:

```elisp
(add-to-list 'load-path "/path/to/emacs-tintin-mode")
(require 'tintin-mode)
```

### make install

```bash
git clone https://codeberg.org/thomasc/emacs-tintin-mode.git
cd emacs-tintin-mode
make install
```

Installs to `$XDG_DATA_HOME/emacs/site-lisp/` (defaults to `~/.local/share/emacs/site-lisp/`). Add to your init file:

```elisp
(add-to-list 'load-path
  (expand-file-name "emacs/site-lisp"
    (or (getenv "XDG_DATA_HOME") "~/.local/share")))
(require 'tintin-mode)
```

## Usage

Opening any `.tin` file activates the mode automatically. To activate manually:

```
M-x tintin-mode
```

### Customization

```elisp
;; Change indentation width (default 2)
(setq tintin-indent-offset 4)
```

All faces are customizable via `M-x customize-group RET tintin RET`.

## Development

```bash
make          # byte-compile
make test     # run test suite
make format   # indent elisp files
make clean    # remove build artifacts
```

## License

GPL-3.0-or-later. See [COPYING](COPYING).
