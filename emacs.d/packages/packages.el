;;; use-package example:
;; (use-package foo
;; :init ; Runs before loading the package. WIll always run, even if foo isn't on this system.
;; :config ; Runs after.
;; :bind (("M-s O" . action)
;;       ("" . some-other-action))
;; :commands foo-mode ; Creates autoloads for commands: defers loading until called.
;; )

;; Package installation

(require 'package)
;; Create the package install directory if it doesn't exist
(setq package-user-dir (format "%selpa_%s/"
                               user-emacs-directory emacs-major-version)) ; default = ~/.emacs.d/elpa/
(package-initialize)


(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(setq package-enable-at-startup nil)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))


;;;; Required packages

(use-package diminish
  :ensure t)

(diminish 'visual-line-mode)
(diminish 'abbrev-mode)

(use-package autorevert
  :diminish auto-revert-mode)

(use-package iedit
  :ensure t)

(use-package hydra
  :ensure t)

(use-package engine-mode
  :ensure t)

(use-package evil
  :ensure t
  :config
  (evil-mode t)
  (setq evil-want-C-i-jump nil)
  (setq evil-default-state 'normal)

  ;; Move all elements of evil-emacs-state-modes to evil-motion-state-modes
  (setq evil-motion-state-modes (append evil-emacs-state-modes evil-motion-state-modes)
        evil-emacs-state-modes (list 'magit-popup-mode))
  (delete 'magit-popup-mode evil-motion-state-modes)

  ;; Don't echo evil's states
  (setq evil-insert-state-message nil
        evil-visual-state-message nil)

  ;; Little words (camelCase)
  (evil-define-motion evil-little-word (count)
    :type exclusive
    (let* ((case-fold-search nil)
           (count (if count count 1)))
      (while (> count 0)
        (forward-char)
        (search-forward-regexp "[_A-Z]\\|\\W" nil t)
        (backward-char)
        (decf count))))

  ;; Don't litter registers with whitespace
  (defun destroy-whitespace--evil-delete-around (func beg end type &optional reg yh)
    (let ((clean-string (replace-regexp-in-string "[ \t\n]" "" (buffer-substring beg end))))
      (if (equal "" clean-string)
          (apply func beg end type ?_ yh)
        (apply func beg end type reg yh))))

  (advice-add 'evil-delete :around #'destroy-whitespace--evil-delete-around)

  ;; eval the last sexp while in normal mode (include the character the cursor is currently on)
  (defun evil-eval-last-sexp ()
    (interactive)
    (evil-append 1)
    (eval-last-sexp nil)
    (evil-normal-state))

  ;; select recently pasted text
  ;; from https://emacs.stackexchange.com/a/21093
  (defun my/evil-select-pasted ()
  (interactive)
  (let ((start-marker (evil-get-marker ?[))
        (end-marker (evil-get-marker ?])))
        (evil-visual-select start-marker end-marker)))

  ;; "pull" left and right with zs and ze
  (defun hscroll-cursor-left ()
    (interactive "@")
    (set-window-hscroll (selected-window) (current-column)))

  (defun hscroll-cursor-right ()
    (interactive "@")
    (set-window-hscroll (selected-window) (- (current-column) (window-width) -1)))

  ;; Horizontal scrolling
  (setq auto-hscroll-mode 't)
  (setq hscroll-margin 0
        hscroll-step 1)

  (defhydra hydra-window (global-map "C-w")
    "window layout"
    ("u" winner-undo "undo")
    ("U" winner-redo "redo"))

  ;; Make K select manpage or engine-mode (m for man, g for google?)
  (defengine google
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q=%s")
  (defhydra hydra-lookup-menu ()
    "Choose lookup"
    ("g" engine/search-google "Google" :color blue)
    ("m" evil-lookup "man" :color blue))
  (define-key evil-normal-state-map "K" 'hydra-lookup-menu/body)
  (define-key evil-visual-state-map "K" 'hydra-lookup-menu/body)

  :bind (:map evil-normal-state-map
              ("zs" . hscroll-cursor-left)
              ("ze" . hscroll-cursor-right)
              ("[s" . flyspell-goto-previous-error)
              ("]s" . flyspell-goto-next-error)
              ("\C-x \C-e" . evil-eval-last-sexp)
         :map Info-mode-map
              ("g" . nil)
              ("n" . nil)
              ("p" . nil)
         :map evil-window-map
              ("q" . delete-window)
              ("C-q" . delete-window)
         :map evil-operator-state-map
              ("lw" . evil-little-word)))

(use-package evil-numbers
  :ensure t
  :config
  ;; Increment and decrement (evil-numbers)
  (defhydra hydra-numbers (global-map "C-x")
    "modify numbers"
    ("a" evil-numbers/inc-at-pt "increment")
    ("x" evil-numbers/dec-at-pt "decrement")))

(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode)

(use-package undohist
  :ensure t
  :config
  ;; Save undo history under .emacs.d/undohist
  (setq undohist-directory "~/.emacs.d/undohist")
  (unless (file-exists-p  "~/.emacs.d/undohist")
    (make-directory "~/.emacs.d/undohist"))

  (undohist-initialize))

(use-package powerline-evil
  :ensure t
  :config
  (defun powerline-center-evil-theme ()
    "Setup a mode-line with major, evil, and minor modes centered."
    (interactive)
    (setq-default mode-line-format
		  '("%e"
		    (:eval
		     (let* ((active (powerline-selected-window-active))
			    (mode-line-buffer-id (if active 'mode-line-buffer-id 'mode-line-buffer-id-inactive))
			    (mode-line (if active 'mode-line 'mode-line-inactive))
			    (face1 (if active 'powerline-active1 'powerline-inactive1))
			    (face2 (if active 'powerline-active2 'powerline-inactive2))
			    (separator-left (intern (format "powerline-%s-%s"
							    (powerline-current-separator)
							    (car powerline-default-separator-dir))))
			    (separator-right (intern (format "powerline-%s-%s"
							     (powerline-current-separator)
							     (cdr powerline-default-separator-dir))))
			    (lhs (list (powerline-raw "%*" mode-line 'l)
				       (powerline-buffer-id mode-line-buffer-id 'l)
				       (powerline-raw " ")
				       (funcall separator-left mode-line face1)
				       (powerline-narrow face1 'l)
				       (powerline-vc face1)))
			    (rhs (list (funcall separator-right face1 mode-line)
				       (powerline-raw mode-line-misc-info mode-line 'r)
					;(powerline-raw global-mode-string face1 'r)
				       (powerline-raw "%2l" mode-line 'r)
				       (powerline-raw ":" mode-line)
				       (powerline-raw "%2c" mode-line 'r)
					;(powerline-raw " ")
					;(powerline-raw "%6p" mode-line 'r)
				       (powerline-hud face2 face1)))
			    (center (append (list (powerline-raw " " face1)
						  (funcall separator-left face1 face2)
						  (when (and (boundp 'erc-track-minor-mode) erc-track-minor-mode)
						    (powerline-raw erc-modified-channels-object face2 'l))
						  (powerline-major-mode face2 'l)
						  (powerline-process face2)
						  (powerline-raw " " face2))
					    (if (split-string (format-mode-line minor-mode-alist))
						(append (if evil-mode
							    (list (funcall separator-right face2 face1)
								  (powerline-raw evil-mode-line-tag face1 'l)
								  (powerline-raw " " face1)
								  (funcall separator-left face1 face2)))
							(list (powerline-minor-modes face2 'l)
							      (powerline-raw " " face2)
							      (funcall separator-right face2 face1)))
					      (list (powerline-raw evil-mode-line-tag face2)
						    (funcall separator-right face2 face1))))))
		       (concat (powerline-render lhs)
			       (powerline-fill-center face1 (/ (powerline-width center) 2.0))
			       (powerline-render center)
			       (powerline-fill face1 (powerline-width rhs))
			       (powerline-render rhs)))))))
  (defun powerline-evil-vim-theme ()
    "Powerline's Vim-like mode-line with evil state at the beginning."
    (interactive)
    (setq-default mode-line-format
		  '("%e"
		    (:eval
		     (let* ((active (powerline-selected-window-active))
			    (mode-line (if active 'mode-line 'mode-line-inactive))
			    (face1 (if active 'powerline-active1 'powerline-inactive1))
			    (face2 (if active 'powerline-active2 'powerline-inactive2))
			    (separator-left (intern (format "powerline-%s-%s"
							    (powerline-current-separator)
							    (car powerline-default-separator-dir))))
			    (separator-right (intern (format "powerline-%s-%s"
							     (powerline-current-separator)
							     (cdr powerline-default-separator-dir))))
			    (lhs (list (if evil-mode
					   (powerline-raw (powerline-evil-tag) mode-line))
				       (powerline-buffer-id `(mode-line-buffer-id ,mode-line) 'l)
				       (powerline-raw "[" mode-line 'l)
				       (powerline-major-mode mode-line)
				       (powerline-process mode-line)
				       (powerline-raw "]" mode-line)
				       (when (buffer-modified-p)
					 (powerline-raw "[+]" mode-line))
				       (when buffer-read-only
					 (powerline-raw "[RO]" mode-line))
				       ;; (powerline-raw (concat "[" (mode-line-eol-desc) "]") mode-line)
				       (when (and (boundp 'which-func-mode) which-func-mode)
					 (powerline-raw which-func-format nil 'l))
				       (when (boundp 'erc-modified-channels-object)
					 (powerline-raw erc-modified-channels-object face1 'l))
				       (powerline-raw "[" mode-line 'l)
				       (powerline-minor-modes mode-line) (powerline-raw "%n" mode-line)
				       (powerline-raw "]" mode-line)
				       (when (and vc-mode buffer-file-name)
					 (let ((backend (vc-backend buffer-file-name)))
					   (when backend
					     (concat (powerline-raw "[" mode-line 'l)
						     (powerline-raw (format "%s / %s" backend (vc-working-revision buffer-file-name backend)))
						     (powerline-raw "]" mode-line)))))))
			    (rhs (list (powerline-raw mode-line-misc-info mode-line 'r)
				       (powerline-raw global-mode-string mode-line 'r)
				       (powerline-raw "%l," mode-line 'l)
				       (powerline-raw (format-mode-line '(10 "%c")))
				       (powerline-raw (replace-regexp-in-string  "%" "%%" (format-mode-line '(-3 "%p"))) mode-line 'r))))
		       (concat (powerline-render lhs)
			       (powerline-fill mode-line (powerline-width rhs))
			       (powerline-render rhs)))))))

  (if (or (display-graphic-p) (daemonp))
      (powerline-center-evil-theme)
    (powerline-evil-vim-theme)))

(use-package linum-relative
  :ensure t
  :diminish linum-relative-mode
  :config
  (setq linum-relative-current-symbol "")
  (linum-mode)
  (linum-relative-global-mode)
  (defun linum-update-window-scale-fix (win)
    "fix linum for scaled text"
    (set-window-margins
     win
     (ceiling (* (if (boundp 'text-scale-mode-step)
                     (expt text-scale-mode-step
                           text-scale-mode-amount) 1)
                 (if (car (window-margins))
                     (car (window-margins)) 1)
                 ))))

  (advice-add #'linum-update-window
              :after #'linum-update-window-scale-fix))

(use-package bind-map
  :ensure t
  :after evil
  :config
  (bind-map
   my-base-leader-map
   :keys ("M-m")
   :evil-keys ("SPC")
   :evil-states (normal motion visual)
   :bindings
   ("d" 'diff-buffer-with-file
    "b" 'buffer-menu
    "f" 'treemacs-toggle
    "u" 'undo-tree-visualize
    "l" 'auto-fill-mode
    "s" 'flyspell-toggle-correct-mode
    "a" 'company-mode
    "g" 'magit-status
    "c" 'flycheck-mode
    "w" '(lambda () (interactive)
	   ;; "writing" mode
	   (variable-pitch-mode)
	   (visual-line-mode)
	   (flyspell-toggle-correct-mode))
    "p" 'my/evil-select-pasted
    "/" 'swiper
    "v" 'ivy-switch-buffer
    "1" 'eyebrowse-switch-to-window-config-1
    "2" 'eyebrowse-switch-to-window-config-2
    "3" 'eyebrowse-switch-to-window-config-3
    "4" 'eyebrowse-switch-to-window-config-4
    "5" 'eyebrowse-switch-to-window-config-5))

  (bind-map
   my-org-map
   :keys ("M-m")
   :evil-keys ("SPC")
   :major-modes (org-mode)
   :bindings
   ("t" 'org-toggle-latex-fragment
    "o" 'org-timeline)))

(use-package treemacs
  :ensure t
  :bind (:map treemacs-mode-map
	      ("." . treemacs-toggle-show-dotfiles)))

(use-package treemacs-evil
  :after treemacs
  :ensure t)

(use-package editorconfig
  :ensure t
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))

(use-package ivy
  :ensure t
  :diminish ivy-mode
  :config
  (ivy-mode)
  (setq ivy-use-virtual-buffers t))

(use-package flx
  :ensure t
  :config
  (setq ivy-re-builders-alist '((t . ivy--regex-fuzzy))))

(use-package company
  :ensure t
  :diminish company-mode
  :config
  (add-hook 'prog-mode-hook 'company-mode)
)

(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :config
  (add-hook 'prog-mode-hook 'flycheck-mode)
  (setq flycheck-check-syntax-automatically '(idle-change new-line save mode-enabled))
  (setq flycheck-checkers (delq 'emacs-lisp-checkdoc flycheck-checkers)))

(use-package flycheck-pos-tip
  :ensure t
  :after flycheck
  :config
  (flycheck-pos-tip-mode))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package dtrt-indent
  :ensure t
  :config
  (setq global-mode-string (delq 'dtrt-indent-mode-line-info global-mode-string))
  (dtrt-indent-mode 1))

(use-package org
  :ensure t
  :config
  (setq org-log-done 'time)
  (defun org->odt->pdf ()
    "Someday I'll learn how to properly format the LaTeX to PDF output."
    (interactive)
    (org-odt-export-to-odt)
    (shell-command
     (concat
      "libreoffice --headless --convert-to pdf \"" (file-name-sans-extension (buffer-name)) ".odt\""
      " && echo Done")))
  (setq org-html-table-default-attributes '(:border "2" :cellspacing "0" :cellpadding "6" :rules "all" :frame "border"))

  (setq org-latex-minted-options
    '("breaklines"))

  (add-hook 'calendar-mode-hook (lambda () (setq show-trailing-whitespace nil)))
  )

(use-package evil-org
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
	    (lambda ()
	      (evil-org-set-key-theme '(textobjects insert navigation additional todo))))
  (setq evil-org-special-o/O nil))

(use-package org-agenda
  :after org
  :after evil
  :config
  ;; Rip org-timeline
  (defun org-timeline ()
    (interactive)
      (let ((org-agenda-custom-commands
	'(("z" "" agenda ""
	   ((org-agenda-span 'year)
	    ;; (org-agenda-time-grid nil)
	    (org-agenda-show-all-dates nil)
	    ;; (org-agenda-entry-types '(:deadline)) ;; this entry excludes :scheduled
	    (org-deadline-warning-days 7))))))

	(org-agenda nil "z" 'buffer)))
  ;; Not sure if this can be placed in a :bind statement
  (evil-define-key 'motion org-agenda-mode-map (kbd "RET") '(lambda () (interactive) (org-agenda-switch-to t))))

(use-package org-preview-html
  :after org
  :ensure t)

(use-package evil-ediff
  :ensure t
  :config
  (add-hook 'ediff-load-hook 'evil-ediff-init))

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package rainbow-identifiers
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-identifiers-mode)
  (setq rainbow-identifiers-faces-to-override
        '(
          font-lock-constant-face
          font-lock-type-face
          font-lock-function-name-face
          font-lock-variable-name-face
          font-lock-keyword-face)))

(use-package rainbow-mode
  :ensure t
  :diminish rainbow-mode
  :config
  (add-hook 'prog-mode-hook #'rainbow-mode))

(use-package eyebrowse
  :ensure t
  :config
  (eyebrowse-mode t)
  (eyebrowse-setup-evil-keys)
  (setq eyebrowse-new-workspace t))

(use-package solarized-theme
  :ensure t)

(use-package solaire-mode
  :ensure t
  :config
  ;; highlight the minibuffer when it is activated
  (set-face-attribute 'solaire-minibuffer-face nil :inherit 'solaire-default-face :background "blanched almond")
  (add-hook 'minibuffer-setup-hook #'solaire-mode-in-minibuffer))

(use-package evil-goggles
  :ensure t
  :diminish evil-goggles-mode
  :config
  (evil-goggles-mode)

  ;; optionally use diff-mode's faces; as a result, deleted text
  ;; will be highlighed with `diff-removed` face which is typically
  ;; some red color (as defined by the color theme)
  ;; other faces such as `diff-added` will be used for other actions
  (evil-goggles-use-diff-faces))

;; OS specific
(use-package magit
  :if (not (eq system-type 'windows-nt))
  :ensure t
  :diminish magit-auto-revert-mode)

(use-package evil-magit
  :if (not (eq system-type 'windows-nt))
  :ensure t
  :config
  (evil-magit-init))

(use-package multi-term
  :if (not (eq system-type 'windows-nt))
  :ensure t)

;; global-prettify-symbols doesn't play nice on Windows
(if (not (eq system-type 'windows-nt))
    (global-prettify-symbols-mode))

(require 'prettify-custom-symbols)

;;;; Optional packages

(use-package flymd
  :config
  (setq flymd-close-buffer-delete-temp-files t))

(use-package web-mode
  :config
  ;; 2 spaces for an indent
  (defun my-web-mode-hook ()
    "Hooks for Web mode."
    (setq web-mode-markup-indent-offset 2
          web-mode-enable-auto-closing t
          web-mode-enable-auto-pairing t)
    )
  (add-hook 'web-mode-hook  'my-web-mode-hook)

  ;; Auto-enable web-mode when opening relevent files
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.hbs\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.handlebars\\'" . web-mode)))

(use-package js
  :config
  (setq js-indent-level 2))

(use-package tide
  :config
  (setq typescript-indent-level 2))

(use-package racket-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.scm\\'" . racket-mode))

  ;; C-w prefix in racket-REPL
  (add-hook 'racket-repl-mode-hook 'racket-repl-evil-hook)

  (defun racket-repl-evil-hook ()
    (define-key racket-repl-mode-map "\C-w" 'evil-window-map)
    (global-set-key (kbd "C-w") 'racket-repl-mode-map)))

(use-package intero
  :config
  (add-hook 'haskell-mode-hook 'intero-mode))

; (use-package haskell-mode
;   :config
;   (setq haskell-interactive-popup-errors nil)
;   (define-key haskell-mode-map (kbd "C-c C-c") 'haskell-process-load-file)
;   (define-key haskell-mode-map (kbd "C-c C-p") 'haskell-process-reload)
;
;   (setq haskell-process-type 'stack-ghci))


(use-package emojify
  :config
  (add-hook 'after-init-hook #'global-emojify-mode))

(use-package latex-preview-pane)

(use-package slime
  :config
  (setq inferior-lisp-program "sbcl")
  (slime-setup))
(use-package slime-company)

;; List of optional packages
(defvar optional-packages
      '(
        flymd
        markdown-mode
        latex-preview-pane
        tide
        web-mode
        racket-mode
        intero
        realgud
        emojify
	auctex
	company-auctex
	slime
	slime-company
        ))

(defvar packages-installed-this-session nil)
(defun ensure-package-installed (prompt package)
  "Ensure a package is installed, and (optionally) ask if it isn't."
  (if (not (package-installed-p package))
      (if (or prompt (y-or-n-p (format "Package %s is missing. Install it? " package)))
	  ;; If this is the 1st install this session, update before install
	  (cond ((not packages-installed-this-session)
		 (package-refresh-contents)
		 (setq packages-installed-this-session t)
		 (package-install package))
		(t (package-install package))
		nil)
	package)))

(defun optional-packages-install ()
  "Ask to install any optional packages."
  (interactive)
  (mapcar (lambda (package) (ensure-package-installed nil package)) optional-packages))


;;;; Builtin configs

(defvar gdb-many-windows t)

(global-eldoc-mode -1)

(use-package flyspell
  :config
  ;; move point to previous error
  ;; based on code by hatschipuh at
  ;; http://emacs.stackexchange.com/a/14912/2017
  (defun flyspell-goto-previous-error (arg)
    "Go to arg previous spelling error."
    (interactive "p")
    (while (not (= 0 arg))
      (let ((pos (point))
            (min (point-min)))
        (if (and (eq (current-buffer) flyspell-old-buffer-error)
                 (eq pos flyspell-old-pos-error))
            (progn
              (if (= flyspell-old-pos-error min)
                  ;; goto beginning of buffer
                  (progn
                    (message "Restarting from end of buffer")
                    (goto-char (point-max)))
                (backward-word 1))
              (setq pos (point))))
        ;; seek the next error
        (while (and (> pos min)
                    (let ((ovs (overlays-at pos))
                          (r '()))
                      (while (and (not r) (consp ovs))
                        (if (flyspell-overlay-p (car ovs))
                            (setq r t)
                          (setq ovs (cdr ovs))))
                      (not r)))
          (backward-word 1)
          (setq pos (point)))
        ;; save the current location for next invocation
        (setq arg (1- arg))
        (setq flyspell-old-pos-error pos)
        (setq flyspell-old-buffer-error (current-buffer))
        (goto-char pos)
        (if (= pos min)
            (progn
              (message "No more miss-spelled word!")
              (setq arg 0))))))

  (defun flyspell-toggle-correct-mode ()
    "Decide whether to use flyspell-mode or flyspell-prog-mode, then properly toggle."
    (interactive)
    ;; use flyspell-mode when in text buffers
    ;; otherwise use flyspell-prog-mode
    (let* ((current-mode
            (buffer-local-value 'major-mode (current-buffer)))
           (flyspell-mode-to-call
            (if (or (string= current-mode "text-mode") (string= current-mode "markdown-mode"))
                'flyspell-mode
              'flyspell-prog-mode)))
      ;; toggle the current flyspell mode, and
      ;; eval the buffer if we turned it on
      (if flyspell-mode
          (funcall 'flyspell-mode '0)
        (funcall flyspell-mode-to-call)
        (flyspell-buffer)))))

(use-package hideshow
  :config
  (add-hook 'prog-mode-hook
            'hs-minor-mode)
  (add-hook 'hs-minor-mode-hook
            (lambda ()
              (diminish 'hs-minor-mode))))

(use-package recentf
  :config
  (recentf-mode 1)
  (setq recentf-max-saved-items 200
        recentf-max-menu-items 15)
  (add-to-list 'recentf-exclude ".*.emacs\\.d/elpa.*"))

(provide 'packages)
