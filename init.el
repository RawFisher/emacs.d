;; emacs custom config
(setq custom-file "~/.emacs.d/emacs.custom.el")

;; disable bar mode
(if (functionp 'tool-bar-mode) (tool-bar-mode -1))
(if (functionp 'scroll-bar-mode) (scroll-bar-mode -1))
(menu-bar-mode -1)

;; do not show startup screen
(setq inhibit-splash-screen t)

;; change scratch message
(setq initial-scratch-message ";; hack for fun\n")

;; no bell
(setq ring-bell-function 'ignore)

;; line number
(global-display-line-numbers-mode)

;; tab size
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; c/c++ mode newline offset size
(setq c-basic-offset 4)

;; y or n
(defalias 'yes-or-no-p 'y-or-n-p)

;; ido
(ido-mode 1)
(ido-everywhere 1)
(setq ido-enable-flex-matching t)

;; open xterm mouse mode default because work in terminal
(xterm-mouse-mode t)

;; package
(setq package-archives '(("myelpa" . "~/.emacs.d/myelpa/")
                         ("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize)
(eval-and-compile
  (require 'use-package)
  (setq use-package-always-ensure t)
  (setq use-package-expand-minimally t))

;; hungry delete
(use-package smart-hungry-delete
  :ensure t
  :bind (("<backspace>" . smart-hungry-delete-backward-char))
  :init
  (eval-when-compile
    ;; silence missing function warnings
    (declare-function
     smart-hungry-delete-add-default-hooks "smart-hungry-delete.el"))
  :config
  (smart-hungry-delete-add-default-hooks))
(use-package hungry-delete
  :ensure t
  :diminish hungry-delete-mode
  :init
  (eval-when-compile
    ;; silence missing function warnings
    (declare-function global-hungry-delete-mode "hungry-delete.el"))
  :config
  (global-hungry-delete-mode t))

;; show whitespace except newline chars
(defvar my:ws-enable-modes '(prog-mode))
(use-package whitespace
  :ensure t
  :diminish global-whitespace-mode
  :diminish whitespace-mode
  :init
  (eval-when-compile
      ;; silence missing function warnings
      (declare-function global-whitespace-mode "whitespace.el"))
  :config
  (setq whitespace-style '(face lines-tail trailing tabs tab-mark)))

;; turn on whitespace mode globally in my:ws-enable-modes
(define-global-minor-mode my-global-whitespace-mode whitespace-mode
  (lambda ()
    (let* ((allow-ws-mode nil))
      (progn
        (dolist (element my:ws-enable-modes)
          (when (derived-mode-p element)
            (setq allow-ws-mode t)))
        (when allow-ws-mode
          (whitespace-mode t))))
    ))
(my-global-whitespace-mode t)

;; window numbering
(use-package winum
  :ensure t
  :init
  (defvar winum-keymap
        (let ((map (make-sparse-keymap)))
          (define-key map (kbd "M-0") 'winum-select-window-0-or-10)
          (define-key map (kbd "M-1") 'winum-select-window-1)
          (define-key map (kbd "M-2") 'winum-select-window-2)
          (define-key map (kbd "M-3") 'winum-select-window-3)
          (define-key map (kbd "M-4") 'winum-select-window-4)
          (define-key map (kbd "M-5") 'winum-select-window-5)
          (define-key map (kbd "M-6") 'winum-select-window-6)
          (define-key map (kbd "M-7") 'winum-select-window-7)
          (define-key map (kbd "M-8") 'winum-select-window-8)
          map))
  :config
  (eval-when-compile
    ;; silence missing function warnings
    (declare-function winum-mode "winum.el"))
  (setq winum-scope 'frame-local)
  (winum-mode t))

;; evil
(defvar my:evil-disable-modes
  '(minibuffer-inactive-mode
    grep-mode
    Info-mode
    term-mode
    magit-log-edit-mode
    diff-mode
    gud-mode
    help-mode
    eshell-mode
    shell-mode
    vterm-mode
    xref--xref-buffer-mode
    woman-mode
    dired-mode
    compilation-mode
    messages-buffer-mode))
(use-package evil
  :init
  (eval-when-compile
    ;; silence missing function warnings
    (declare-function evil-mode "evil.el"))
  :config
  (evil-mode t)
  (dolist (m my:evil-disable-modes) (evil-set-initial-state m 'emacs)))

;; multi cursors
(use-package multiple-cursors
  :ensure t
  :bind (("M-n" . mc/mark-next-like-this)
         ("M-p" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m e" . mc/edit-lines)))

;; magit
(use-package magit
  :commands (magit-checkout)
  :bind
  (("M-g M-s" . magit-status)
   ("M-g M-c" . 'magit-checkout))
  :init
  (use-package dash)
  (use-package forge
    :after magit))

;; show git diff
(use-package diff-hl
  :ensure t
  :hook ((prog-mode . diff-hl-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :commands (diff-hl-mode)
  :config
  (diff-hl-margin-mode t))

;; M-x list
(use-package smex
  :config
  (smex-initialize)
  :bind
  (("M-x" . 'smex)
   ("M-X" . 'smex-major-mode-commands)
   ("C-c C-c M-x" . 'execute-extended-command)))

;; code complete
(use-package company
  :ensure t
  :diminish company-mode
  :hook (prog-mode . global-company-mode)
  :commands (company-mode company-indent-or-complete-common)
  :init
  (setq company-minimum-prefix-length 2
        company-tooltip-limit 14
        company-tooltip-align-annotations t
        company-require-match 'never
        company-global-modes '(not erc-mode message-mode help-mode gud-mode)

        ;; These auto-complete the current selection when
        ;; `company-auto-complete-chars' is typed. This is too magical. We
        ;; already have the much more explicit RET and TAB.
        company-auto-complete nil
        company-auto-complete-chars nil

        ;; Only search the current buffer for `company-dabbrev' (a backend that
        ;; suggests text your open buffers). This prevents Company from causing
        ;; lag once you have a lot of buffers open.
        company-dabbrev-other-buffers nil

        ;; Make `company-dabbrev' fully case-sensitive, to improve UX with
        ;; domain-specific words with particular casing.
        company-dabbrev-ignore-case nil
        company-dabbrev-downcase nil)

  :config
  (defvar my:company-explicit-load-files '(company company-capf))
  ;; Zero delay when pressing tab
  (setq company-idle-delay 0)
  ;; remove backends for packages that are dead
  (setq company-backends (delete 'company-eclim company-backends))
  (setq company-backends (delete 'company-xcode company-backends)))

;; tags for code navigating
(use-package counsel-etags
    :init
    (eval-when-compile
      ;; silence missing function warnings
      (declare-function counsel-etags-virtual-update-tags "counsel-etags.el")
      (declare-function counsel-etags-guess-program "counsel-etags.el")
      (declare-function counsel-etags-locate-tags-file "counsel-etags.el"))
    :config
    ;; ignore files above 800kb
    (setq counsel-etags-max-file-size 800)
    ;; ignore build directories for tagging
    (add-to-list 'counsel-etags-ignore-directories '"build*")
    (add-to-list 'counsel-etags-ignore-directories '".vscode")
    (add-to-list 'counsel-etags-ignore-filenames '".clang-format")
    ;; don't ask before rereading the TAGS files if they have changed
    (setq tags-revert-without-query t)
    ;; don't warn when TAGS files are large
    (setq large-file-warning-threshold nil)
    ;; how many seconds to wait before rerunning tags for auto-update
    (setq counsel-etags-update-interval 180)
    ;; set up auto-update
    (add-hook
     'prog-mode-hook
     (lambda () (add-hook 'after-save-hook
                          (lambda ()
                            (counsel-etags-virtual-update-tags))))))

;; avy: always fast jump to char inside the current view buffer
(use-package avy
  :ensure t
  :bind (("M-c" . avy-goto-char-2)
         ("M-s" . avy-goto-word-1)))

;; zzz-to-char: replaces the built-in zap-to-char with avy-like
;;              replacement options
(use-package zzz-to-char
  :ensure t
  :bind ("M-z" . zzz-up-to-char))

(load-file custom-file)
