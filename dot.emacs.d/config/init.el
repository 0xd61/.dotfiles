(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)

(defvar better-gc-cons-threshold (* 128 1024 1024) ; 128mb
  "The default value to use for `gc-cons-threshold'.

If you experience freezing, decrease this.  If you experience stuttering, increase this.")

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold better-gc-cons-threshold)
            (setq file-name-handler-alist file-name-handler-alist-original)
            (makunbound 'file-name-handler-alist-original)))

(add-hook 'emacs-startup-hook
          (lambda ()
            (if (boundp 'after-focus-change-function)
                (add-function :after after-focus-change-function
                              (lambda ()
                                (unless (frame-focus-state)
                                  (garbage-collect))))
              (add-hook 'after-focus-change-function 'garbage-collect))
            (defun gc-minibuffer-setup-hook ()
              (setq gc-cons-threshold (* better-gc-cons-threshold 2)))

            (defun gc-minibuffer-exit-hook ()
              (garbage-collect)
              (setq gc-cons-threshold better-gc-cons-threshold))

            (add-hook 'minibuffer-setup-hook #'gc-minibuffer-setup-hook)
            (add-hook 'minibuffer-exit-hook #'gc-minibuffer-exit-hook)))

(setq backup-directory-alist `(("." . ,(expand-file-name ".tmp/backups/"
                                                         user-emacs-directory))))

(if (version<= emacs-version "28")
    (defalias 'yes-or-no-p 'y-or-n-p)
  (setopt use-short-answers t))

(global-auto-revert-mode 1)

(setq auto-save-default t)

(setq window-combination-resize t)

(setq dgl/project-file ".project.el")
(setq dgl/project-directory ".") ;; setting default. Will get overwritten by load-project-settings

(defun find-project-directory-recursive (project-file depth)
  "Recursively search for the file."
  (interactive)
  (if (file-exists-p project-file) t
    (when (>= depth 0)
      (cd "../")
      (find-project-directory-recursive project-file (- depth 1))))
  )

(defun load-project-settings ()
  (interactive)
  (setq find-project-from-directory default-directory)
  (cd find-project-from-directory)
  (find-project-directory-recursive dgl/project-file 5)
  (when (file-exists-p dgl/project-file)
    (load-file dgl/project-file)
    (setq dgl/project-directory default-directory))
  (cd find-project-from-directory)
  )

(setq user-full-name       "Daniel Glinka"
      user-real-login-name "Daniel Glinka"
      user-login-name      "dgl")

(setq visible-bell t)

(setq x-stretch-cursor t)

(with-eval-after-load 'mule-util
 (setq truncate-string-ellipsis "…"))

(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)

;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

(defvar dgl/default-font-size 110
  "Default font size.")

(defvar dgl/default-font-name "InputMono"
  "Default font.")

(defvar dgl/variable-font-name "Inter"
  "Default variable font.")

(defun my/set-font ()
  (when (find-font (font-spec :name dgl/default-font-name))
    (set-face-attribute 'default nil
                        :font dgl/default-font-name
                        :height dgl/default-font-size))

  (when (find-font (font-spec :name dgl/variable-font-name))
    (set-face-attribute 'variable-pitch nil
                        :font dgl/variable-font-name
                        :height dgl/default-font-size)))

(my/set-font)
(add-hook 'server-after-make-frame-hook #'my/set-font)

(setq frame-title-format
      '(""
        "%b"
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p) " ? %s" "  ?  %s - Emacs") project-name))))))

(defun my/set-colors ()
    (set-foreground-color "#D2B48C")
    (set-background-color "#012326")

    (set-face-foreground 'default "#D2B48C")
    (set-face-background 'default "#012326")
    (set-face-background 'cursor "#65D6AD")
    (set-face-foreground 'font-lock-builtin-face "#D2B48C")
    (set-face-foreground 'font-lock-comment-face "#31B72C")
    (set-face-foreground 'font-lock-constant-face "#65D6AD")
    (set-face-foreground 'font-lock-doc-face "#E8E6E1")
    (set-face-foreground 'font-lock-function-name-face "#D2B48C")
    (set-face-foreground 'font-lock-keyword-face "#E8E6E1")
    (set-face-foreground 'font-lock-preprocessor-face "#625D52")
    (set-face-foreground 'font-lock-string-face "#2CB1BC")
    (set-face-foreground 'font-lock-type-face "#D2B48C")
    (set-face-foreground 'font-lock-variable-name-face "#D2B48C")
    (set-face-background 'fringe "#01282D")
    (set-face-foreground 'highlight "#65D6AD")
    ;;(set-face-background 'hl-line "#013137")
    (set-face-foreground 'mode-line "#012326")
    (set-face-background 'mode-line "#D2B48C")

    (set-face-attribute 'mode-line-inactive nil :foreground "#D2B48C" :background "#013137")
    )
(my/set-colors)
(add-hook 'server-after-make-frame-hook #'my/set-colors)

(require 'package)
(setq load-prefer-newer t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(use-package async
  :ensure t
  :config (setq async-bytecomp-package-mode 1))

(use-package consult
  :ensure t
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ;;        ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;;        ;; C-x bindings in `ctl-x-map'
         ;;        ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ;;        ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ;;        ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ;;        ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ;;        ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ;;        ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ;;        ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-# l" . consult-register-load)
         ("M-# s" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("M-# #" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-G bindings in `goto-map'
         ("M-G e" . consult-compile-error)
         ;;        ("M-G f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-G g" . consult-goto-line)             ;; orig. goto-line
         ("M-G l" . consult-goto-line)           ;; orig. goto-line
         ;;        ("M-G o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-G m" . consult-mark)
         ("M-G M" . consult-global-mark)
         ("M-G b" . consult-bookmark)
         ("M-G i" . consult-imenu)
         ("M-G I" . consult-imenu-multi)
         ;; M-S bindings in `search-map'
         ("M-S d" . consult-find)                  ;; Alternative: consult-fd
         ("M-S c" . consult-locate)
         ("M-S g" . consult-grep)
         ("M-S G" . consult-git-grep)
         ("M-S r" . consult-ripgrep)
         ("M-S l" . consult-line)
         ("M-S L" . consult-line-multi)
         ("M-S k" . consult-keep-lines)
         ("M-S u" . consult-focus-lines)
         ;; Isearch integration
         ("M-S e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-S e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-S l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-S L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         ;; :map minibuffer-local-map
         ;; ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ;; ("M-r" . consult-history)                ;; orig. previous-matching-history-element
         )
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )

(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  
  ;; :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))
(vertico-buffer-mode)

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))

(use-package cc-mode
  :defer t
  :bind (
    :map c++-mode-map
    ("TAB" . 'dabbrev-expand)
    ("S-TAB" . 'indent-for-tab-command)
    ("C-TAB" . 'indent-region)
    )
  :config
  ;; 4-space tabs
  (setq tab-width 4 indent-tabs-mode t)
  (setq c-basic-offset 4)

  ;; No hungry backspace
  (c-toggle-auto-hungry-state -1)

  ;; Additional style stuff
  (c-set-offset 'member-init-intro '++)

  ;; Newline indents, semi-colon doesn't
  ;; (define-key c++-mode-map "\C-m" 'newline-and-indent)
  (setq c-hanging-semi&comma-criteria '((lambda () 'stop)))

  ;; Handle super-tabbify (TAB completes, shift-TAB actually tabs)
  (setq dabbrev-case-replace t)
  (setq dabbrev-case-fold-search t)
  (setq dabbrev-upcase-means-case-search t)

  ;; Abbrevation expansion
  (abbrev-mode 1)
  )

(use-package go-mode :ensure t)

(autoload 'bb-mode		"bb-mode"         "Bitbake mode"					 t)

(setq auto-mode-alist
      (append '(
                ("\\workspace.dsl$" . javascript-mode)
                ("\\.teak$"     . c++-mode)
                ("\\.cpp$"      . c++-mode)
                ("\\.hin$"      . c++-mode)
                ("\\.cin$"      . c++-mode)
                ("\\.inl$"      . c++-mode)
                ("\\.rdc$"      . c++-mode)
                ("\\.h$"        . c++-mode)
                ("\\.c$"        . c++-mode)
                ("\\.cc$"       . c++-mode)
                ("\\.c8$"       . c++-mode)
                ("\\.txt$"      . indented-text-mode)
                ("\\.emacs$"    . emacs-lisp-mode)
                ("\\.gen$"      . gen-mode)
                ("\\.ms$"       . fundamental-mode)
                ("\\.m$"        . objc-mode)
                ("\\.mm$"       . objc-mode)
                ("\\.go$"       . go-mode)
                ("\\.bb$"       . bb-mode)
                ("\\.inc$"      . bb-mode)
                ("\\.bbappend$" . bb-mode)
                ("\\.bbclass$"  . bb-mode)
                ("\\.conf$"     . bb-mode)
                ("\\.md$"       . markdown-mode)
                ("\\.js$"       . javascript-mode)
                ("\\.json$"     . javascript-mode)
                ) auto-mode-alist))

(when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
 (setq dgl/makescript "build.teak"))
(when (eq system-type 'gnu/linux)
 (setq dgl/makescript "./build.teak"))

(setq compilation-directory-locked nil)
(setq compilation-context-lines 0)
;;  (setq compilation-error-regexp-alist
;;        (cons '("^\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) : \\(?:fatal error\\|warnin\\(g\\)\\) C[0-9]+:" 2 3 nil (4))
;;              compilation-error-regexp-alist))

(defun lock-compilation-directory ()
  "The compilation process should NOT hunt for a makefile"
  (interactive)
  (setq last-compilation-directory default-directory)
  (setq compilation-directory-locked t)
  (message "Compilation directory is locked."))

(defun unlock-compilation-directory ()
  "The compilation process SHOULD hunt for a makefile"
  (interactive)
  (setq last-compilation-directory nil)
  (setq compilation-directory-locked nil)
  (message "Compilation directory is roaming."))

(defun compile-from-project-directory ()
  (interactive)
  (setq current-directory default-directory)
  (if compilation-directory-locked
      (cd last-compilation-directory)
    ((load-project-settings)
     (cd dgl/project-directory)))
  (lock-compilation-directory)
  (compile dgl/makescript))

(defun make-without-asking ()
  "Make the current build."
  (interactive)
  (switch-to-buffer-other-window "*compilation*")
  (compile-from-project-directory)
  (other-window 1))

(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region (point-min) (point-max))))
