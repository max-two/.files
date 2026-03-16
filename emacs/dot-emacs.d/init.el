;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; --- Package management ---
;; MELPA has packages not in the default GNU ELPA (e.g. vterm)
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Must be called explicitly so use-package can find installed packages
(package-initialize)

;; --- PATH ---
;; Homebrew binaries aren't on Emacs's default PATH (needed for vterm, git, etc.)
(setenv "PATH" (concat "/opt/homebrew/bin:" (getenv "PATH")))
(add-to-list 'exec-path "/opt/homebrew/bin")

;; --- General settings ---
;; Auto-install packages referenced by use-package
(setq use-package-always-ensure t)
;; Keep customize-generated code out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; --- Theme ---
;; Everforest is not on MELPA, so we clone it directly into .emacs.d
(let ((theme-dir (expand-file-name "everforest-theme" user-emacs-directory)))
  (unless (file-directory-p theme-dir)
    (shell-command (concat "git clone https://github.com/Theory-of-Everything/everforest-emacs.git " theme-dir)))
  (add-to-list 'custom-theme-load-path theme-dir))
(load-theme 'everforest-hard-dark t)

;; --- Terminal ---
;; vterm gives a proper terminal emulator inside Emacs (requires libvterm + cmake)
(use-package vterm
  :config
  (setq vterm-max-scrollback 10000)
  (setq vterm-shell "/bin/zsh"))
