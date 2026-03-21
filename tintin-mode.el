;;; tintin-mode.el --- Major mode for editing TinTin++ scripts  -*- lexical-binding: t; -*-

;; Author: Thomas Christensen
;; URL: https://codeberg.org/thomasc/emacs-tintin-mode
;; Version: 0.1.0
;; Keywords: languages, mud, tintin
;; Package-Requires: ((emacs "25.1"))

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;;; Commentary:

;; Provides syntax highlighting and basic editing support for TinTin++
;; MUD client script files (.tin).  Colors inspired by Charm.land.

;;; Code:

;; ============================================================================
;; Customization
;; ============================================================================

(defgroup tintin nil
  "Major mode for editing TinTin++ scripts."
  :prefix "tintin-"
  :group 'languages
  :link '(url-link "https://tintin.mudhalla.net/"))

(defcustom tintin-indent-offset 2
  "Number of spaces for each indentation level in `tintin-mode'."
  :type 'integer
  :safe #'integerp
  :group 'tintin)

;; ============================================================================
;; Faces (Charm.land palette)
;; ============================================================================

(defface tintin-command-face
  '((((class color) (min-colors 256) (background dark))
     (:foreground "#00AAFF"))
    (((class color) (min-colors 256) (background light))
     (:foreground "#0066BB"))
    (t (:inherit font-lock-keyword-face)))
  "Face for TinTin++ commands."
  :group 'tintin)

(defface tintin-control-face
  '((((class color) (min-colors 256) (background dark))
     (:foreground "#FF5FD2"))
    (((class color) (min-colors 256) (background light))
     (:foreground "#CC00AA"))
    (t (:inherit font-lock-builtin-face)))
  "Face for TinTin++ control flow."
  :group 'tintin)

(defface tintin-function-face
  '((((class color) (min-colors 256) (background dark))
     (:foreground "#00D787"))
    (((class color) (min-colors 256) (background light))
     (:foreground "#009960"))
    (t (:inherit font-lock-function-name-face)))
  "Face for TinTin++ functions and class definitions."
  :group 'tintin)

(defface tintin-variable-face
  '((((class color) (min-colors 256) (background dark))
     (:foreground "#FF875F"))
    (((class color) (min-colors 256) (background light))
     (:foreground "#CC5500"))
    (t (:inherit font-lock-variable-name-face)))
  "Face for TinTin++ variables."
  :group 'tintin)

(defface tintin-string-face
  '((((class color) (min-colors 256) (background dark))
     (:foreground "#B083EA"))
    (((class color) (min-colors 256) (background light))
     (:foreground "#7049C2"))
    (t (:inherit font-lock-string-face)))
  "Face for TinTin++ string-like constructs."
  :group 'tintin)

(defface tintin-number-face
  '((((class color) (min-colors 256) (background dark))
     (:foreground "#6EEFC0"))
    (((class color) (min-colors 256) (background light))
     (:foreground "#008866"))
    (t (:inherit font-lock-constant-face)))
  "Face for numeric literals."
  :group 'tintin)

(defface tintin-comment-face
  '((((class color) (min-colors 256) (background dark))
     (:foreground "#6C6C6C"))
    (((class color) (min-colors 256) (background light))
     (:foreground "#8C8C8C"))
    (t (:inherit font-lock-comment-face)))
  "Face for TinTin++ comments."
  :group 'tintin)

(defface tintin-special-face
  '((((class color) (min-colors 256) (background dark))
     (:foreground "#FFFF87"))
    (((class color) (min-colors 256) (background light))
     (:foreground "#887700"))
    (t (:inherit font-lock-preprocessor-face)))
  "Face for special TinTin++ syntax."
  :group 'tintin)

;; ============================================================================
;; Syntax table
;; ============================================================================

(defvar tintin-mode-syntax-table
  (let ((st (make-syntax-table)))
    ;; C-style block comments /* ... */ (style a)
    ;; and // line comments (style b)
    ;; / is: punctuation, 1st of comment-start-a, 2nd of comment-end-a,
    ;;       1st of comment-start-b, 2nd of comment-start-b
    (modify-syntax-entry ?/ ". 124b" st)
    ;; * is: punctuation, 2nd of comment-start-a, 1st of comment-end-a
    (modify-syntax-entry ?* ". 23" st)
    ;; newline ends style-b comments
    (modify-syntax-entry ?\n "> b" st)
    ;; Braces as paired delimiters
    (modify-syntax-entry ?{ "(}" st)
    (modify-syntax-entry ?} "){" st)
    ;; # is punctuation (command prefix, NOT comment)
    (modify-syntax-entry ?# "." st)
    ;; Variable prefixes as expression prefix
    (modify-syntax-entry ?$ "'" st)
    (modify-syntax-entry ?@ "'" st)
    (modify-syntax-entry ?& "'" st)
    ;; Semicolons as punctuation
    (modify-syntax-entry ?\; "." st)
    ;; Backslash as escape
    (modify-syntax-entry ?\\ "\\" st)
    ;; Word constituents
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?- "w" st)
    st)
  "Syntax table for `tintin-mode'.")

;; ============================================================================
;; Command word lists
;; ============================================================================

(defconst tintin-control-flow-commands
  '("if" "else" "elseif" "switch" "case" "default" "return"
    "loop" "foreach" "while" "repeat" "break" "continue" "parse")
  "TinTin++ control flow and loop commands.")

(defconst tintin-function-commands
  '("function" "class" "event" "button" "macro")
  "TinTin++ function and organization commands.")

(defconst tintin-action-commands
  '("action" "alias" "substitute" "gag" "highlight"
    "unaction" "unalias" "ungag" "unsub" "unhighlight")
  "TinTin++ action and trigger commands.")

(defconst tintin-variable-commands
  '("variable" "local" "math" "format" "cat" "replace" "unvariable" "var")
  "TinTin++ variable commands.")

(defconst tintin-other-commands
  '("delay" "tick" "ticker" "untick" "undelay"
    "session" "send" "read" "write" "log" "textin" "port"
    "show" "showme" "echo" "prompt" "bell" "draw"
    "system" "script" "run" "scan" "buffer"
    "config" "pathdir" "path" "map" "line" "list"
    "nop" "killall" "kill" "help" "info" "debug"
    "message" "end" "zap" "cr" "color" "uncolor")
  "TinTin++ other commands.")

;; ============================================================================
;; Font-lock keywords
;; ============================================================================

(defconst tintin-font-lock-keywords
  (let ((control-re (concat "#" (regexp-opt tintin-control-flow-commands t) "\\>"))
        (function-re (concat "#" (regexp-opt tintin-function-commands t) "\\>"))
        (action-re (concat "#" (regexp-opt tintin-action-commands t) "\\>"))
        (variable-cmd-re (concat "#" (regexp-opt tintin-variable-commands t) "\\>"))
        (other-re (concat "#" (regexp-opt tintin-other-commands t) "\\>")))
    `(
      ;; #nop to end of line (comment)
      ("#nop\\b.*$" 0 'tintin-comment-face t)
      ;; Control flow
      (,control-re 0 'tintin-control-face)
      ;; Function/class definitions
      (,function-re 0 'tintin-function-face)
      ;; Action/trigger commands
      (,action-re 0 'tintin-command-face)
      ;; Variable commands
      (,variable-cmd-re 0 'tintin-command-face)
      ;; Other known commands
      (,other-re 0 'tintin-command-face)
      ;; Catch-all: any #command
      ("#[a-zA-Z]+" 0 'tintin-command-face)
      ;; Function calls: @name
      ("@\\([a-zA-Z_][a-zA-Z0-9_-]*\\)" 1 'tintin-function-face)
      ;; Variables: $name, &name, *name (with optional [key] subscripts)
      ("[$&*][a-zA-Z_][a-zA-Z0-9_-]*" 0 'tintin-variable-face)
      ;; Capture arguments: %0 through %99
      ("%[0-9]\\{1,2\\}" 0 'tintin-variable-face)
      ;; Numeric constants
      ("\\_<[0-9]+\\(?:\\.[0-9]+\\)?\\_>" 0 'tintin-number-face)
      ;; Escape sequences
      ("\\\\." 0 'tintin-special-face prepend)
      ;; Semicolons as command separators
      (";" 0 'tintin-special-face)))
  "Font-lock keywords for `tintin-mode'.")

;; ============================================================================
;; Indentation
;; ============================================================================

(defun tintin-indent-line ()
  "Indent the current line according to TinTin++ brace nesting."
  (interactive)
  (let ((target (tintin-calculate-indentation))
        (savep (> (current-column) (current-indentation))))
    (if savep
        (save-excursion (indent-line-to target))
      (indent-line-to target))))

(defun tintin-calculate-indentation ()
  "Calculate indentation for the current line based on brace nesting."
  (save-excursion
    (back-to-indentation)
    (let* ((ppss (syntax-ppss))
           (depth (nth 0 ppss)))
      (when (eq (char-after) ?})
        (setq depth (max 0 (1- depth))))
      (* depth tintin-indent-offset))))

;; ============================================================================
;; Mode definition
;; ============================================================================

;;;###autoload
(define-derived-mode tintin-mode prog-mode "TinTin++"
  "Major mode for editing TinTin++ MUD client scripts.

Provides syntax highlighting for TinTin++ commands, variables,
function calls, and comments.  Supports brace matching and
basic indentation.

\\{tintin-mode-map}"
  :syntax-table tintin-mode-syntax-table
  :group 'tintin
  ;; Font lock (case-insensitive)
  (setq-local font-lock-defaults
              '(tintin-font-lock-keywords nil t))
  ;; Comments (use // for M-; since it's simplest)
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "\\(?://+\\|/\\*+\\)\\s-*")
  (setq-local comment-end-skip "\\s-*\\*+/")
  ;; Indentation
  (setq-local indent-tabs-mode nil)
  (setq-local indent-line-function #'tintin-indent-line))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.tin\\'" . tintin-mode))

(provide 'tintin-mode)

;;; tintin-mode.el ends here
