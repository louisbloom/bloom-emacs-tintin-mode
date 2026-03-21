# tintin-mode

Emacs major mode for editing [TinTin++](https://tintin.mudhalla.net/) `.tin` script files.

## Features

- Syntax highlighting for commands, control flow, variables, functions, and comments
- Three comment styles: `/* */` blocks, `//` lines, and `#nop`
- Brace matching (`C-M-f` / `C-M-b`)
- Indentation based on brace nesting (`TAB`)
- Case-insensitive command recognition
- Colors inspired by [Charm](https://charm.land)

## Installation

### MELPA (recommended)

Add MELPA to your package archives if you haven't already:

```elisp
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
```

Then install:

```
M-x package-install RET tintin-mode RET
```

Or with `use-package`:

```elisp
(use-package tintin-mode :ensure t)
```

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

## MELPA Recipe

```elisp
(tintin-mode
 :fetcher codeberg
 :repo "thomasc/emacs-tintin-mode")
```

## License

GPL-3.0-or-later. See [COPYING](COPYING).
