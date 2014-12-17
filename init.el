;;; init.el --- Fragor Maximus -*- lexical-binding: t; -*-
;;; Commentary:
;;;   'battlemidgets modified Emacs'
;;; Code:

(mapc
 (lambda (mode)
   (when (fboundp mode)
     (funcall mode -1)))
 '(tool-bar-mode scroll-bar-mode))

(require 'cask "~/.cask/cask.el")
(cask-initialize)
(require 'pallet)

(require 's)
(require 'f)
(require 'ht)
(require 'git)
(require 'ert)
(require 'use-package)

(setq default-directory (f-full (getenv "HOME")))

(defun load-local (file)
  (load (f-expand file user-emacs-directory)))

(load-local "defuns")
(load-local "misc")

(load-theme 'badger :no-confirm)

(add-hook 'emacs-startup-hook
          (lambda ()
            (when (string= (buffer-name) "*scratch*")
              (animate-string ";; i punch HAMSTARS!" (/ (frame-height) 2)))))


;;;; Packages
(use-package autopair
  :init (autopair-global-mode 1)
  :ensure t)

(use-package py-autopep8
  :config
  (add-hook 'before-save-hook 'py-autopep8-before-save))

(use-package hl-line
  :config (progn
;            (set-face-background 'hl-line "#073642")
            (global-hl-line-mode t))
  :ensure t)

(use-package markdown-mode
  :defer t
  :ensure t)

(use-package git-gutter
  :defer t
  :config
    (dolist (face '(git-gutter:added
                    git-gutter:deleted
                    git-gutter:modified
                    git-gutter:separator
                    git-gutter:unchanged))
      (set-face-background face (face-foreground face)))
  :ensure t)

(use-package dash
  :config (dash-enable-font-lock))

(use-package dired-x)

(use-package ido
  :init (ido-mode 1)
  :config
  (progn
    (setq ido-case-fold t)
    (setq ido-everywhere t)
    (setq ido-enable-prefix nil)
    (setq ido-enable-flex-matching t)
    (setq ido-create-new-buffer 'always)
    (setq ido-max-prospects 10)
    (setq ido-file-extensions-order '(".rb" ".el" ".coffee" ".js"))
    (add-to-list 'ido-ignore-files "\\.DS_Store")))

(use-package nyan-mode
  :init (nyan-mode 1))

;; (use-package smex
;;   :init (smex-initialize)
;;   :bind ("M-x" . smex))
(use-package neotree
  :config
  (progn
    (global-set-key [f8] 'neotree-toggle)))

(use-package helm
  :config
  (progn
    (setq helm-command-prefix-key "C-c h")

    (require 'helm-config)
    (require 'helm-eshell)
    (require 'helm-files)
    (require 'helm-grep)
    (global-set-key (kbd "M-x") 'helm-M-x)
    (global-set-key (kbd "M-y") 'helm-show-kill-ring)
    (global-set-key (kbd "C-x b") 'helm-mini)
    (global-set-key (kbd "C-x C-f") 'helm-find-files)
    (global-set-key (kbd "C-c h o") 'helm-occur)
    (global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)
    (global-set-key (kbd "C-c h g") 'helm-google-suggest)

    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebihnd tab to do persistent action
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
    (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

    (define-key helm-grep-mode-map (kbd "<return>")  'helm-grep-mode-jump-other-window)
    (define-key helm-grep-mode-map (kbd "n")  'helm-grep-mode-jump-other-window-forward)
    (define-key helm-grep-mode-map (kbd "p")  'helm-grep-mode-jump-other-window-backward)

    (setq
     helm-google-suggest-use-curl-p t
     helm-scroll-amount 4 ; scroll 4 lines other window using M-<next>/M-<prior>
     helm-quick-update t ; do not display invisible candidates
     helm-idle-delay 0.01 ; be idle for this many seconds, before updating in delayed sources.
     helm-input-idle-delay 0.01 ; be idle for this many seconds, before updating candidate buffer
     helm-ff-search-library-in-sexp t ; search for library in `require' and `declare-function' sexp.

     helm-split-window-default-side 'other ;; open helm buffer in another window
     helm-split-window-in-side-p t ;; open helm buffer inside current window, not occupy whole other window
     helm-buffers-favorite-modes (append helm-buffers-favorite-modes
                                         '(picture-mode artist-mode))
     helm-candidate-number-limit 200 ; limit the number of displayed canidates
     helm-M-x-requires-pattern 0     ; show all candidates when set to 0
     helm-ff-file-name-history-use-recentf t
     helm-move-to-line-cycle-in-source t ; move to end or beginning of source
                                        ; when reaching top or bottom of source.
     ido-use-virtual-buffers t      ; Needed in helm-buffers-list
     helm-buffers-fuzzy-matching t          ; fuzzy matching buffer names when non--nil
                                        ; useful in helm-mini that lists buffers
     )
    ;; Save current position to mark ring when jumping to a different place
    (add-hook 'helm-goto-line-before-hook 'helm-save-current-pos-to-mark-ring)
    (helm-mode 1)))

(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)))

(use-package popwin
  :init (popwin-mode 1))

(use-package projectile
  :init (projectile-global-mode 1)
  :config
  (progn
    (setq projectile-enable-caching t)
    (setq projectile-require-project-root nil)
    (setq projectile-completion-system 'ido)
    (add-to-list 'projectile-globally-ignored-files ".DS_Store")))

(use-package drag-stuff
  :init (drag-stuff-global-mode 1)
  :bind (("M-N" . drag-stuff-down)
         ("M-P" . drag-stuff-up)))

(use-package misc
  :bind ("M-z" . zap-up-to-char))

(defvar magit-default-tracking-name-function)
(use-package magit
  :init
  (progn
    (use-package magit-blame)
    (bind-key "C-c C-a" 'magit-just-amend magit-mode-map))
  :config
  (progn
    ;(setq magit-emacsclient-executable (emacsclient))
    (setq magit-default-tracking-name-function 'magit-default-tracking-name-branch-only)
    (setq magit-set-upstream-on-push t)
    (setq magit-completing-read-function 'magit-ido-completing-read)
    (setq magit-stage-all-confirm nil)
    (setq magit-unstage-all-confirm nil)
    (setq magit-restore-window-configuration t)
    (add-hook 'magit-mode-hook 'rinari-launch))
  :bind ("C-x g" . magit-status))

(use-package ace-jump-mode
  :bind ("C-c SPC" . ace-jump-mode))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package cua-base
  :init (cua-mode 1)
  :config
  (progn
    (setq cua-enable-cua-keys nil)
    (setq cua-toggle-set-mark nil)))

(use-package uniquify
  :config (setq uniquify-buffer-name-style 'forward))

(use-package saveplace
  :config (setq-default save-place t))

(use-package diff-hl
  :init (global-diff-hl-mode)
  :config (add-hook 'vc-checkin-hook 'diff-hl-update))

(use-package windmove
  :config (windmove-default-keybindings 'shift))

(use-package ruby-mode
  :init
  (progn
    (use-package ruby-tools)
    (use-package rhtml-mode
      :mode (("\\.rhtml$" . rhtml-mode)
             ("\\.html\\.erb$" . rhtml-mode)))
    (use-package rinari
      :init (global-rinari-mode 1)
      :config (setq ruby-insert-encoding-magic-comment nil))
    (use-package rspec-mode
      :config
      (progn
        (setq rspec-use-rvm t)
        (setq rspec-use-rake-when-possible nil)
        (defadvice rspec-compile (around rspec-compile-around activate)
          "Use BASH shell for running the specs because of ZSH issues."
          (let ((shell-file-name "/bin/bash"))
            ad-do-it)))))
  :config
  (progn
    (add-hook 'ruby-mode-hook 'rvm-activate-corresponding-ruby)
    (setq ruby-deep-indent-paren nil))
  :bind (("C-M-h" . backward-kill-word)
         ("C-M-n" . scroll-up-five)
         ("C-M-p" . scroll-down-five))
  :mode (("\\.rake$" . ruby-mode)
         ("\\.gemspec$" . ruby-mode)
         ("\\.ru$" . ruby-mode)
         ("Rakefile$" . ruby-mode)
         ("Gemfile$" . ruby-mode)
         ("Capfile$" . ruby-mode)
         ("Guardfile$" . ruby-mode)))

(use-package markdown-mode
  :config
  (progn
    (bind-key "M-n" 'open-line-below markdown-mode-map)
    (bind-key "M-p" 'open-line-above markdown-mode-map))
  :mode (("\\.markdown$" . markdown-mode)
         ("\\.md$" . markdown-mode)))

;; (use-package smartparens
;;   :init
;;   (progn
;;     (use-package smartparens-config)
;;     (use-package smartparens-ruby)
;;     (use-package smartparens-html)
;;     (smartparens-global-mode 1)
;;     (show-smartparens-global-mode 1))
;;   :config
;;   (progn
;;     (setq smartparens-strict-mode t)
;;     (setq sp-autoescape-string-quote nil)
;;     (setq sp-autoinsert-if-followed-by-word t)
;;     (sp-local-pair 'emacs-lisp-mode "`" nil :when '(sp-in-string-p)))
;;   :bind
;;   (("C-M-k" . sp-kill-sexp-with-a-twist-of-lime)
;;    ("C-M-f" . sp-forward-sexp)
;;    ("C-M-b" . sp-backward-sexp)
;;    ("C-M-n" . sp-up-sexp)
;;    ("C-M-d" . sp-down-sexp)
;;    ("C-M-u" . sp-backward-up-sexp)
;;    ("C-M-p" . sp-backward-down-sexp)
;;    ("C-M-w" . sp-copy-sexp)
;;    ("M-s" . sp-splice-sexp)
;;    ("M-r" . sp-splice-sexp-killing-around)
;;    ("C-)" . sp-forward-slurp-sexp)
;;    ("C-}" . sp-forward-barf-sexp)
;;    ("C-(" . sp-backward-slurp-sexp)
;;    ("C-{" . sp-backward-barf-sexp)
;;    ("M-S" . sp-split-sexp)
;;    ("M-J" . sp-join-sexp)
;;    ("C-M-t" . sp-transpose-sexp)))

(use-package auto-complete
  :init (global-auto-complete-mode t)
  :defer t
  :config (progn
            (require 'auto-complete-config)
            (ac-config-default))
  :ensure t)

(use-package rainbow-delimiters
  :config (progn (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))
  :ensure t)

(use-package flymake
  :commands flymake-mode)

(use-package flycheck
  :config
  (progn
    (setq flycheck-display-errors-function nil)
    (add-hook 'after-init-hook 'global-flycheck-mode)
    (add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode)))

(use-package flycheck-cask
  :init (add-hook 'flycheck-mode-hook 'flycheck-cask-setup))

(use-package yasnippet
  :init
  (progn
    (let ((snippets-dir (f-expand "snippets" user-emacs-directory)))
      (yas-load-directory snippets-dir)
      (setq yas-snippet-dirs snippets-dir))
    (yas-global-mode 1)
    (setq-default yas-load-directory '(yas/ido-prompt))))

(use-package yaml-mode
  :mode ("\\.yml$" . yaml-mode))

(use-package feature-mode
  :mode ("\\.feature$" . feature-mode)
  :config
  (add-hook 'feature-mode-hook
            (lambda ()
              (electric-indent-mode -1))))

(use-package cc-mode
  :config
  (progn
    (add-hook 'c-mode-hook (lambda () (c-set-style "bsd")))
    (add-hook 'java-mode-hook (lambda () (c-set-style "bsd")))
    (setq tab-width 2)
    (setq c-basic-offset 2)))

(use-package css-mode
  :config (setq css-indent-offset 2))

(defvar js-indent-level)
(use-package js-mode
  :mode ("\\.json$" . js-mode)
  :init
  (progn
    (add-hook 'js-mode-hook (lambda () (setq js-indent-level 2)))))

(defvar join-line-or-lines-in-region)
(use-package js2-mode
  :mode (("\\.js$" . js2-mode)
         ("Jakefile$" . js2-mode))
  :interpreter ("node" . js2-mode)
  :bind (("C-a" . back-to-indentation-or-beginning-of-line)
         ("C-M-h" . backward-kill-word))
  :config
  (progn
    (add-hook 'js2-mode-hook (lambda () (setq js2-basic-offset 2)))
    (add-hook 'js2-mode-hook (lambda ()
                               (bind-key "M-j" join-line-or-lines-in-region)))))

(defvar coffee-cleanup-whitespace)
(use-package coffee-mode
  :config
  (progn
    (add-hook 'coffee-mode-hook
              (lambda ()
                (bind-key "C-j" 'coffee-newline-and-indent coffee-mode-map)
                (bind-key "C-M-h" 'backward-kill-word coffee-mode-map)
                (setq coffee-tab-width 2)
                (setq coffee-cleanup-whitespace nil)))))

(use-package nvm)

(use-package sh-script
  :config (setq sh-basic-offset 2))

(use-package emacs-lisp-mode
  :init
  (progn
    (use-package eldoc
      :init (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode))
    (use-package macrostep
      :bind ("C-c e" . macrostep-expand))
    (use-package ert
      :config (add-to-list 'emacs-lisp-mode-hook 'ert--activate-font-lock-keywords)))
  :bind (("M-&" . lisp-complete-symbol)
         ("M-." . find-function-at-point))
  :interpreter (("emacs" . emacs-lisp-mode))
  :mode ("Cask" . emacs-lisp-mode))

(use-package html-script-src)

(use-package haml-mode)
(use-package sass-mode)

(defvar eshell-visual-commands)
(defvar eshell-history-size)
(defvar eshell-save-history-on-exit)
(use-package eshell
  :bind ("M-e" . eshell)
  :init
  (add-hook 'eshell-first-time-mode-hook
            (lambda ()
              (add-to-list 'eshell-visual-commands "htop")))
  :config
  (progn
    (setq eshell-history-size 5000)
    (setq eshell-save-history-on-exit t)))

(defvar ido-use-face)
(use-package flx-ido
  :init (flx-ido-mode 1)
  :config (setq ido-use-face nil))

(use-package ido-vertical-mode
  :init (ido-vertical-mode 1))

(use-package web-mode
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode)))
  :config (progn
            (add-hook 'web-mode-hook
                      (lambda ()
                        (setq web-mode-style-padding 2)
                        (setq web-mode-script-padding 2)))))

(use-package prodigy
  :init (progn
          (add-hook 'prodigy-mode-hook
                    (lambda ()
                      (setq-local show-trailing-whitespace nil))))
  :demand t
  :bind ("C-x p" . prodigy))

(use-package discover
  :init (global-discover-mode 1))

(use-package ert-async
  :config (add-to-list 'emacs-lisp-mode-hook 'ert-async-activate-font-lock-keywords))

(use-package ibuffer
  :config (setq ibuffer-expert t)
  :bind ("C-x C-b" . ibuffer))

(use-package cl-lib-highlight
  :init (cl-lib-highlight-initialize))

(use-package idomenu
  :bind ("M-i" . idomenu))

(use-package httprepl)

(use-package ack-and-a-half)

(use-package swoop
  :bind ("C-o" . swoop))

(use-package web-beautify
  :bind ("C-c t" . web-beautify-js))

(use-package mmm-mako)

;;;; Bindings

(bind-key "C-a" 'back-to-indentation-or-beginning-of-line)
(bind-key "C-7" 'comment-or-uncomment-current-line-or-region)
(bind-key "C-6" 'linum-mode)
(bind-key "C-v" 'scroll-up-five)
(bind-key "C-j" 'newline-and-indent)

(bind-key "M-g" 'goto-line)
(bind-key "M-n" 'open-line-below)
(bind-key "M-p" 'open-line-above)
(bind-key "M-+" 'text-scale-increase)
(bind-key "M-_" 'text-scale-decrease)
(bind-key "M-j" 'join-line-or-lines-in-region)
(bind-key "M-v" 'scroll-down-five)
(bind-key "M-k" 'kill-this-buffer)
(bind-key "M-o" 'other-window)
(bind-key "M-1" 'delete-other-windows)
(bind-key "M-2" 'split-window-below)
(bind-key "M-3" 'split-window-right)
(bind-key "M-0" 'delete-window)
(bind-key "M-}" 'next-buffer)
(bind-key "M-{" 'previous-buffer)
(bind-key "M-`" 'other-frame)
(bind-key "M-w" 'kill-region-or-thing-at-point)

(bind-key "C-c g" 'google)
(bind-key "C-c d" 'duplicate-current-line-or-region)
(bind-key "C-c n" 'clean-up-buffer-or-region)
(bind-key "C-c s" 'swap-windows)
(bind-key "C-c r" 'rename-this-buffer-and-file)
(bind-key "C-c k" 'delete-this-buffer-and-file)

(bind-key "C-M-h" 'backward-kill-word)
(bind-key "C-c C-n" 'todo)
(bind-key "C-c l" 'perltidy)

(bind-key
 "C-x C-c"
 (lambda ()
   (interactive)
   (if (y-or-n-p "Quit Emacs? ")
       (save-buffers-kill-emacs))))

(bind-key
 "C-8"
 (lambda ()
   (interactive)
   (find-file (f-expand "init.el" user-emacs-directory))))
