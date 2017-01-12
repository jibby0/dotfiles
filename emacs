;; Disable beep & flash
 (setq ring-bell-function 'ignore)
 
;; All yes or no prompts are y or n
(defalias 'yes-or-no-p 'y-or-n-p)

;; Never follow symlinks
(setq vc-follow-symlinks nil)

;; Leave the OS clipboard alone (use evil's "+ and "* instead)
; Don't copy and paste to the clipboard
(setq select-enable-clipboard nil)
; Don't save to the clipboard on exit
(setq x-select-enable-clipboard-manager nil)

;; Text and Notes
(setq sentence-end-double-space nil)

;; Save minibar history
(savehist-mode 1)
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

;; Auto-enable elisp when opening .emacs in dotfiles (without the .)
(add-to-list 'auto-mode-alist '("emacs" . emacs-lisp-mode))

;;;; Packages

;; Package installation
(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
(package-initialize)

;; Function to ensure every package in installed, and ask if it isn't.
(defun ensure-package-installed (&rest packages)
  (mapcar
   (lambda (package)
	 (if (package-installed-p package)
		 nil
	   (if (y-or-n-p (format "Package %s is missing. Install it? " package))
		   (package-install package)
		 package)))
   packages))

;; Make sure to have downloaded archive description.
(or (file-exists-p package-user-dir)
	(package-refresh-contents))

;; Activate installed packages
(package-initialize)

;; Check that all packages are installed
(ensure-package-installed
 'iedit
 'magit
 'evil-magit
 'undo-tree
 'evil
 'evil-leader
 'evil-tabs
 'powerline-evil
 'zenburn-theme
 'auto-complete
 'ac-html
 'fuzzy
 'general
 'linum-relative
 'web-mode
 )


;;;; Evil

(setq evil-want-C-i-jump nil)

;; Evil tabs
(global-evil-tabs-mode t)

;; Default to evil mode
(evil-mode t)

;; Move all elements of evil-emacs-state-modes to evil-motion-state-modes
(setq evil-motion-state-modes (append evil-emacs-state-modes evil-motion-state-modes))
(setq evil-emacs-state-modes nil)

;; Delete info bindings for evil to take over
(define-key Info-mode-map "g" nil)
(define-key Info-mode-map "n" nil)
(define-key Info-mode-map "p" nil)

(define-key evil-window-map (kbd "q") 'delete-window)
(define-key evil-window-map (kbd "C-q") 'delete-window)

;;;; Files

;; move file backups
(setq backup-directory-alist
      `((".*" . ,(concat user-emacs-directory "backups"))))
(setq auto-save-file-name-transforms
      `((".*" ,(concat user-emacs-directory "backups") t)))

;; Instead save undo history under .emacs.d/undo
(setq undo-tree-auto-save-history t
         undo-tree-history-directory-alist
         `(("." . ,(concat user-emacs-directory "undo"))))
   (unless (file-exists-p (concat user-emacs-directory "undo"))
(make-directory (concat user-emacs-directory "undo")))

;; Powerline
(require 'powerline)
(powerline-vim-theme)

;; Recent Files
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)

;; Web mode
(require 'web-mode)

;; 2 spaces for an indent
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)

;; Auto-enable web-mode when opening relevent files
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.hbs\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.handlebars\\'" . web-mode))

;; Autocomplete
(require 'auto-complete)
(eval-and-compile
  (require 'auto-complete nil 'noerror))
(ac-config-default)
(setq ac-auto-start t)
;;(define-key ac-mode-map (kbd "TAB") 'auto-complete)
;;;;;(setq ac-auto-start nil)
(global-set-key (kbd "<backtab>") 'ac-previous)
;;;;;(ac-set-trigger-key "TAB")
(require 'ac-html)
(setq web-mode-ac-sources-alist
  '(("css" . (ac-source-css-property))
    ("html" . (ac-source-words-in-buffer ac-source-abbrev))))
(ac-linum-workaround)

;; Spelling
;; TODO Mess with how I want spelling to be done. Maybe enable spelling on auto-fill mode?

;; map ]s and [s to next and previously wrong word
(require 'general)
(general-evil-setup)
(general-nmap "]"
	      (general-key-dispatch 'evil-change
				    "s" 'flyspell-goto-next-error
				    ))
(general-vmap "]" 'evil-change)

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
            (setq arg 0))
        (forward-word)))))

(general-nmap "["
	      (general-key-dispatch 'evil-change
				    "s" 'flyspell-goto-previous-error
				    ))
(general-vmap "[" 'evil-change)

;; Relative line numbers
(require 'linum-relative)
(setq linum-relative-current-symbol "")
(linum-mode)
(linum-relative-global-mode)

;; Evil leader is Space
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")

;; Leader keybinds
(evil-leader/set-key
 "d" 'diff-buffer-with-file
 "b" 'buffer-menu
 "f" '(lambda ()  (interactive) (dired '"./"))
 "u" 'undo-tree-visualize
 "m" 'recentf-open-files
 "l" 'auto-fill-mode
 "s" 'flyspell-mode
 "a" 'auto-complete-mode
 "g" 'magit-status
 "M-g" 'magit-dispatch-popup)


;; System-specific configs
(defun win-setup ()
    (add-to-list 'exec-path "C:/Program Files (x86)/Aspell/bin/")
    (setq ispell-program-name "aspell"))

(defun linux-setup ()
    ;; Magit
    (require 'magit)
    (setq evil-magit-state 'normal)
    (require 'evil-magit)
    (global-magit-file-mode))

(cond ((eq system-type 'windows-nt) (win-setup))
      ((eq system-type 'gnu/linux) (linux-setup))
      (t (message "")))


;; TODO:
;; Go through the tutorials, skim the manuals
;; learning elisp
;; Fuzzy
;; Evil leader mode
;; Hotkey for undo tree
;; autocomplete
;; recent files
;; magit bindings


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-auto-show-menu t)
 '(custom-enabled-themes (quote (wombat)))
 '(custom-safe-themes
   (quote
    ("14f0fbf6f7851bfa60bf1f30347003e2348bf7a1005570fd758133c87dafe08f" "4e753673a37c71b07e3026be75dc6af3efbac5ce335f3707b7d6a110ecb636a3" default)))
 '(inhibit-default-init t)
 '(inhibit-startup-buffer-menu nil)
 '(inhibit-startup-echo-area-message "josh")
 '(initial-buffer-choice t)
 '(initial-scratch-message "")
 '(package-selected-packages
   (quote
    (ac-html web-mode evil-magit linum-relative general fuzzy auto-complete evil-tabs powerline-evil zenburn-theme magit iedit evil-leader))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
