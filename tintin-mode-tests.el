;;; tintin-mode-tests.el --- Tests for tintin-mode  -*- lexical-binding: t; -*-

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;;; Commentary:

;; ERT test suite for tintin-mode.

;;; Code:

(require 'ert)
(require 'tintin-mode)

;; ============================================================================
;; Helpers
;; ============================================================================

(defun tintin-test-face-at (text pos)
  "Insert TEXT into a temp buffer in `tintin-mode', return face at POS."
  (with-temp-buffer
    (tintin-mode)
    (insert text)
    (font-lock-ensure)
    (get-text-property pos 'face)))

(defun tintin-test-indent (text)
  "Insert TEXT, run `indent-region', return the indented result."
  (with-temp-buffer
    (tintin-mode)
    (insert text)
    (indent-region (point-min) (point-max))
    (buffer-string)))

;; ============================================================================
;; Mode activation
;; ============================================================================

(ert-deftest tintin-test-mode-name ()
  "Mode name should be TinTin++."
  (with-temp-buffer
    (tintin-mode)
    (should (equal mode-name "TinTin++"))))

(ert-deftest tintin-test-derived-from-prog-mode ()
  "Should derive from prog-mode."
  (with-temp-buffer
    (tintin-mode)
    (should (derived-mode-p 'prog-mode))))

(ert-deftest tintin-test-auto-mode-alist ()
  "The .tin extension should be in auto-mode-alist."
  (should (assoc "\\.tin\\'" auto-mode-alist)))

;; ============================================================================
;; Font-lock: commands
;; ============================================================================

(ert-deftest tintin-test-face-action ()
  "#action should get tintin-command-face."
  (should (eq (tintin-test-face-at "#action {pattern} {cmd}" 1)
              'tintin-command-face)))

(ert-deftest tintin-test-face-alias ()
  "#alias should get tintin-command-face."
  (should (eq (tintin-test-face-at "#alias {k} {kill}" 1)
              'tintin-command-face)))

(ert-deftest tintin-test-face-case-insensitive ()
  "#ACTION should highlight the same as #action."
  (should (eq (tintin-test-face-at "#ACTION {pattern} {cmd}" 1)
              'tintin-command-face)))

(ert-deftest tintin-test-face-catch-all ()
  "Unknown #command should get tintin-command-face."
  (should (eq (tintin-test-face-at "#foobar something" 1)
              'tintin-command-face)))

;; ============================================================================
;; Font-lock: control flow
;; ============================================================================

(ert-deftest tintin-test-face-if ()
  "#if should get tintin-control-face."
  (should (eq (tintin-test-face-at "#if {$hp < 50} {drink potion}" 1)
              'tintin-control-face)))

(ert-deftest tintin-test-face-else ()
  "#else should get tintin-control-face."
  (should (eq (tintin-test-face-at "#else {run}" 1)
              'tintin-control-face)))

(ert-deftest tintin-test-face-while ()
  "#while should get tintin-control-face."
  (should (eq (tintin-test-face-at "#while {$i < 10} {#math i {$i + 1}}" 1)
              'tintin-control-face)))

(ert-deftest tintin-test-face-loop ()
  "#loop should get tintin-control-face."
  (should (eq (tintin-test-face-at "#loop {1} {5} {i} {get $i}" 1)
              'tintin-control-face)))

(ert-deftest tintin-test-face-foreach ()
  "#foreach should get tintin-control-face."
  (should (eq (tintin-test-face-at "#foreach {a;b;c} {x} {say $x}" 1)
              'tintin-control-face)))

;; ============================================================================
;; Font-lock: functions/classes
;; ============================================================================

(ert-deftest tintin-test-face-function ()
  "#function should get tintin-function-face."
  (should (eq (tintin-test-face-at "#function {greet} {#return hello}" 1)
              'tintin-function-face)))

(ert-deftest tintin-test-face-class ()
  "#class should get tintin-function-face."
  (should (eq (tintin-test-face-at "#class {combat} {open}" 1)
              'tintin-function-face)))

(ert-deftest tintin-test-face-function-call ()
  "@funcname should get tintin-function-face."
  (let ((face (tintin-test-face-at "say @greet{world}" 6)))
    (should (eq face 'tintin-function-face))))

;; ============================================================================
;; Font-lock: variables
;; ============================================================================

(ert-deftest tintin-test-face-dollar-variable ()
  "$variable should get tintin-variable-face."
  (should (eq (tintin-test-face-at "say $name" 5)
              'tintin-variable-face)))

(ert-deftest tintin-test-face-ampersand-variable ()
  "&variable should get tintin-variable-face."
  (should (eq (tintin-test-face-at "say &targets" 5)
              'tintin-variable-face)))

(ert-deftest tintin-test-face-star-variable ()
  "*variable should get tintin-variable-face."
  (should (eq (tintin-test-face-at "say *items" 5)
              'tintin-variable-face)))

(ert-deftest tintin-test-face-capture-arg ()
  "%1 should get tintin-variable-face."
  (should (eq (tintin-test-face-at "tell %1 hello" 6)
              'tintin-variable-face)))

;; ============================================================================
;; Font-lock: numbers
;; ============================================================================

(ert-deftest tintin-test-face-number ()
  "Numeric literal should get tintin-number-face."
  (should (eq (tintin-test-face-at "#loop {1} {5} {i} {get}" 8)
              'tintin-number-face)))

;; ============================================================================
;; Font-lock: comments
;; ============================================================================

(ert-deftest tintin-test-face-nop-comment ()
  "#nop should get tintin-comment-face."
  (should (eq (tintin-test-face-at "#nop this is a comment" 1)
              'tintin-comment-face)))

(ert-deftest tintin-test-face-nop-comment-body ()
  "Text after #nop should also get tintin-comment-face."
  (should (eq (tintin-test-face-at "#nop this is a comment" 10)
              'tintin-comment-face)))

;; ============================================================================
;; Syntax table: comments
;; ============================================================================

(ert-deftest tintin-test-block-comment ()
  "/* ... */ should be recognized as a comment."
  (with-temp-buffer
    (tintin-mode)
    (insert "/* block comment */")
    (font-lock-ensure)
    (let ((ppss (syntax-ppss 10)))
      (should (nth 4 ppss)))))

(ert-deftest tintin-test-line-comment ()
  "// should be recognized as a line comment."
  (with-temp-buffer
    (tintin-mode)
    (insert "// line comment")
    (font-lock-ensure)
    (let ((ppss (syntax-ppss 5)))
      (should (nth 4 ppss)))))

;; ============================================================================
;; Brace matching
;; ============================================================================

(ert-deftest tintin-test-brace-syntax-class ()
  "{ and } should be paired delimiters."
  (with-temp-buffer
    (tintin-mode)
    (should (eq (char-syntax ?{) ?\())
    (should (eq (char-syntax ?}) ?\)))))

;; ============================================================================
;; Indentation
;; ============================================================================

(ert-deftest tintin-test-indent-top-level ()
  "Top-level line should have zero indentation."
  (let ((result (tintin-test-indent "#alias {k} {kill}")))
    (should (equal result "#alias {k} {kill}"))))

(ert-deftest tintin-test-indent-one-level ()
  "Line inside braces should be indented one level."
  (let ((result (tintin-test-indent "#action {pattern}\n{\ncommand\n}")))
    (should (equal result "#action {pattern}\n{\n  command\n}"))))

(ert-deftest tintin-test-indent-two-levels ()
  "Line inside two levels of braces should be indented twice."
  (let ((result (tintin-test-indent "{\n{\ndeep\n}\n}")))
    (should (equal result "{\n  {\n    deep\n  }\n}"))))

(ert-deftest tintin-test-indent-closing-brace ()
  "Closing brace should dedent to match opening level."
  (let ((result (tintin-test-indent "{\ninner\n}")))
    (should (equal result "{\n  inner\n}"))))

(ert-deftest tintin-test-indent-custom-offset ()
  "Should respect tintin-indent-offset."
  (let ((tintin-indent-offset 4))
    (let ((result (tintin-test-indent "{\ninner\n}")))
      (should (equal result "{\n    inner\n}")))))

;;; tintin-mode-tests.el ends here
