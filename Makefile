EMACS ?= emacs
prefix ?= $(or $(XDG_DATA_HOME),$(HOME)/.local/share)
DESTDIR ?= $(prefix)/emacs/site-lisp

.PHONY: all install uninstall test format clean

all: tintin-mode.elc

tintin-mode.elc: tintin-mode.el
	$(EMACS) --batch -f batch-byte-compile $<

install: tintin-mode.elc
	install -d $(DESTDIR)
	install -m 644 tintin-mode.el tintin-mode.elc $(DESTDIR)/
	@echo "Installed to $(DESTDIR)/"
	@echo "Add (require 'tintin-mode) to your init.el"

uninstall:
	rm -f $(DESTDIR)/tintin-mode.el $(DESTDIR)/tintin-mode.elc

test: tintin-mode.el tintin-mode-tests.el
	$(EMACS) --batch -l tintin-mode.el -l tintin-mode-tests.el -f ert-run-tests-batch-and-exit

format:
	$(EMACS) --batch \
	  --eval '(require (quote package))' \
	  --eval '(package-initialize)' \
	  --eval '(dolist (f (list "tintin-mode.el" "tintin-mode-tests.el")) (find-file f) (indent-region (point-min) (point-max)) (save-buffer))'

clean:
	rm -f tintin-mode.elc
