;;; amalthea --- -*- lexical-binding: t -*-

(unless (eq emacs-major-version 26)
  (error "Your version of Emacs isn't up-to-date"))

(defconst amalthea--post-init-hook nil
  "Hook that runs after Emacs has loaded.")

(eval-and-compile
  (defconst amalthea--emacs-dir (expand-file-name user-emacs-directory))
  (defconst amalthea--etc-dir (concat amalthea--emacs-dir "etc/"))
  (defconst amalthea--cache-dir (concat amalthea--emacs-dir "cache/"))

  (dolist (dir (list amalthea--emacs-dir amalthea--etc-dir amalthea--cache-dir))
    (unless (file-directory-p dir)
      (make-directory dir t))))

(eval-and-compile
  (setq gc-cons-threshold 402653184
        gc-cons-percentage 0.6)

  (add-hook 'amalthea--post-init-hook #'(lambda ()
                                          (message "Resetting GC values.")
                                          (setq gc-cons-threshold 16777216
                                                gc-cons-percentage 0.1)) t))

(defvar package--init-file-ensured)
(setq max-lisp-eval-depth 50000
      max-specpdl-size 10000
      load-prefer-newer t
      package--init-file-ensured t
      package-enable-at-startup nil
      byte-compile--use-old-handlers nil)

(eval-and-compile
  (add-to-list 'load-path (expand-file-name "lib/borg" user-emacs-directory))
  (require  'borg)
  (borg-initialize)
  (require  'use-package)
  (setq use-package-verbose t
        use-package-compute-statistics t
        use-package-always-defer t))

(use-package epkg
  :init (setq epkg-repository
              (expand-file-name "var/epkgs/" user-emacs-directory)))

(use-package dash
  :commands dash-enable-font-lock
  :config (dash-enable-font-lock))

(use-package delight)

(use-package which-key
  :demand t
  :delight
  :commands (which-key-mode)
  :config
  (progn
    (which-key-mode)
    (setq which-key-idle-delay 0.3)))

(use-package general
  :demand t
  :commands (general-define-key general-evil-setup)
  :config
  (progn
    (general-evil-setup)
    (general-create-definer amalthea--leader-key-def
      :prefix "SPC")
    (general-create-definer amalthea--major-leader-key-def
      :prefix ",")))

(use-package evil
  :demand t
  :config (evil-mode))

(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system                   'utf-8)
(set-terminal-coding-system             'utf-8)
(set-keyboard-coding-system             'utf-8)
(set-selection-coding-system            'utf-8)
(setq locale-coding-system              'utf-8)
(setq-default buffer-file-coding-system 'utf-8)

(fset 'yes-or-no-p 'y-or-n-p)

(delete-selection-mode t)

(use-package custom
  :no-require t
  :config
  (progn
    (setq custom-file (expand-file-name (concat user-emacs-directory "custom.el")))
    (when (file-exists-p custom-file)
      (load custom-file t t))))

(setq inhibit-startup-message t
      inhibit-startup-buffer-menu t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message t
      initial-buffer-choice t)

(setq visible-bell nil
      ring-bell-function #'ignore)

(setq backup-directory-alist `(("." . ,(concat amalthea--cache-dir "saves/")))
      auto-save-file-name-transforms `((".*" ,(concat amalthea--cache-dir "auto-save") t))
      auto-save-list-file-name (concat amalthea--cache-dir "autosave")
      abbrev-file-name (concat amalthea--cache-dir "abbrev_defs")
      backup-by-copying t
      version-control t
      delete-old-versions t)

(setq-default indent-tabs-mode nil
              tab-width 2)

(setq-default fill-column 80)

(use-package ws-butler
  :delight
  :commands (ws-butler-global-mode)
  :init (ws-butler-global-mode 1))

(defvar compilation-scroll-output)
(setq-default sentence-end-double-space nil   ;; no
              vc-follow-symlinks t)           ;; yes
(setq help-window-select t                    ;; focus help window when opened
      compilation-scroll-output 'first-error  ;; stop at first error in compilation log
      save-interprogram-paste-before-kill t)  ;; save paste history globally

(use-package autorevert
    :commands (global-auto-revert-mode)
    :init
    (setq global-auto-revert-non-file-buffers t)
    (global-auto-revert-mode))

(use-package recentf
    :commands (recentf-mode recentf-track-opened-file)
    :init
    (progn
    (add-hook 'find-file-hook (lambda () (unless recentf-mode
                                            (recentf-mode)
                                            (recentf-track-opened-file))))
    (setq recentf-save-file (concat amalthea--cache-dir "recentf")
            recentf-max-saved-items 1000
            recentf-auto-cleanup 'never
            recentf-filename-handlers '(abbreviate-file-name))))

(use-package savehist
    :commands (savehist-mode)
    :init
    (progn
    (setq savehist-file (concat amalthea--cache-dir "savehist")
            enable-recursive-minibuffers t
            savehist-save-minibuffer-history t
            history-length 1000
            savehist-autosave-interval 60
            savehist-additional-variables '(mark-ring
                                            global-mark-ring
                                            search-ring
                                            regexp-search-ring
                                            extended-command-history))
    (savehist-mode t)))

(use-package saveplace
    :commands (save-place-mode)
    :init
    (progn
    (setq save-place-file (concat amalthea--cache-dir "places"))
    (save-place-mode)))

(use-package uniquify
    :init
    (progn
    (setq uniquify-buffer-name-style 'forward)))

(use-package async
  :commands (async-start)
  :defines async-bytecomp-allowed-packages
  :config
  (progn
    (async-bytecomp-package-mode t)
    (setq async-bytecomp-allowed-packages '(all))))

(use-package ivy
  :demand t
  :commands (ivy-mode)
  :delight
  :config
  (progn
    (ivy-mode)
    (setq ivy-use-virtual-buffers t
          enable-recursive-minibuffers t
          ivy-count-format "%d/%d ")))

(use-package counsel
  :demand t
  :commands (counsel-mode)
  :delight
  :general
  (general-define-key
   "C-x C-f" 'counsel-find-file
   "C-x C-r" 'counsel-recentf
   "C-h f" 'counsel-describe-function
   "C-h v" 'counsel-describe-variable)
  (amalthea--leader-key-def
    :keymaps 'normal
    "f" '(:ignore t :which-key "files")
    "f f" '(counsel-find-file :which-key "find file")
    "f r" '(counsel-recentf :which-key "recent file"))
  :config (counsel-mode))

(use-package swiper
  :general
  (general-define-key "C-s" 'swiper)
  (general-nmap "/" 'swiper))

(use-package magit
  :delight auto-revert-mode
  :general
  (amalthea--leader-key-def
    :keymaps 'normal
    "g" '(:ignore t :which-key "git")
    "g s" '(magit-status :which-key "git status"))
  :config
  (progn
    (magit-add-section-hook 'magit-status-sections-hook
                            'magit-insert-modules
                            'magit-insert-stashes
                            'append)))

(use-package evil-magit
  :after magit)

(use-package diff-hl
  :commands (diff-hl-magit-post-refresh global-diff-hl-mode)
  :config
  (progn
    (global-diff-hl-mode)
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh t)))

(use-package tao-theme
  :init (load-theme 'tao-yang t))

(set-face-attribute 'default nil
                    :family "Fira Mono"
                    :height 80)
(set-frame-font "Fira Mono" nil t)

(setq-default line-spacing 0.15)

(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(setq-default cursor-type '(bar . 2)
              frame-title-format '("Amalthea :: %b"))

(setq-default display-line-numbers 'visual
              display-line-numbers-current-absolute t
              display-line-numbers-width 4
              display-line-numbers-widen nil)

(use-package hl-line
  :commands (global-hl-line-mode)
  :init (global-hl-line-mode t)
  :config
  (progn
    (setq global-hl-line-sticky-flag nil)))

(add-hook 'text-mode-hook #'auto-fill-mode)

(use-package org
  :delight org-indent-mode
  :defines org-export-with-sub-superscripts
  :config
  (progn
    (setq org-src-fontify-natively t
          org-startup-with-inline-images t
          org-startup-indented t
          org-hide-emphasis-markers t
          org-use-sub-superscripts '{}
          org-export-with-sub-superscripts '{}
          org-pretty-entities t
          org-list-allow-alphabetical t)))

(use-package paren
  :commands (show-paren-mode)
  :init (show-paren-mode t)
  :config
  (progn
    (setq-default show-paren-delay 0
                  show-paren-highlight-openparen t
                  show-paren-when-point-inside-paren t)))

(use-package rainbow-delimiters
  :commands (rainbow-delimiters-mode)
  :init (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package aggressive-indent
  :delight
  :commands (aggressive-indent-mode)
  :init (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode))

(add-hook 'prog-mode-hook #'electric-pair-mode)

(use-package company
  :delight " Ⓒ"
  :hook (prog-mode . company-mode)
  :general
  (:keymaps 'company-mode-map :states 'insert
            [tab] 'company-complete)
  :init
  (progn
    (setq company-idle-delay 0.2
          company-tooltip-limit 20
          company-show-numbers t
          company-tooltip-align-annotations t)))

(use-package company-childframe
  :after company
  :delight
  :commands company-childframe-mode
  :config (company-childframe-mode t))

(use-package flycheck
  :commands global-flycheck-mode
  :init (global-flycheck-mode t))

(use-package flycheck-inline
  :after flycheck
  :commands flycheck-inline-mode
  :init (flycheck-inline-mode))

(add-hook 'amalthea--post-init-hook #'(lambda ()
                                        (message (concat "Booted in: " (emacs-init-time)))) t)
(run-hooks 'amalthea--post-init-hook)
