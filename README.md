# tintin-mode

Emacs major mode for editing [TinTin++](https://tintin.mudhalla.net/) `.tin` script files.

## Features

- Syntax highlighting for commands, control flow, variables, functions, and comments
- Three comment styles: `/* */` blocks, `//` lines, and `#nop`
- Brace matching (`C-M-f` / `C-M-b`)
- Indentation based on brace nesting (`TAB`)
- Case-insensitive command recognition
- Colors inspired by Charm

## Why this mode?

MELPA already has a [tintin-mode](https://github.com/matthewrsilver/tintin-mode) with broad feature coverage including subcommand option highlighting, configurable prefix characters, ANSI color code highlighting, and capture pattern support.

This mode takes a different approach, focusing on aesthetics: a custom [Charm](https://charm.land)-inspired color scheme with 8 purpose-built faces (dark and light variants), `//` line comment support, number and escape sequence highlighting, and catch-all `#command` coloring so even unknown commands get highlighted.

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
