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

(use-package files
  ;;:hook
  ;;(before-save . delete-trailing-whitespace)
  :config
  (setq dgl/auto-save-dir (concat user-emacs-directory "autosaves"))

  ;; Ensure the directory exists
  (unless (file-exists-p dgl/auto-save-dir)
	(make-directory dgl/auto-save-dir t))

  ;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
  (defun rename-file-and-buffer (new-name)
    "Renames both current buffer and file it's visiting to NEW-NAME."
    (interactive "sNew name: ")
    (let ((name (buffer-name))
          (filename (buffer-file-name)))
      (if (not filename)
          (message "Buffer '%s' is not visiting a file." name)
        (if (get-buffer new-name)
            (message "A buffer named '%s' already exists." new-name)
          (progn
            (rename-file filename new-name 1)
            (rename-buffer new-name)
            (set-visited-file-name new-name)
            (set-buffer-modified-p nil))))))
  :custom
  (require-final-newline t "Automatically add newline at end of file")
  (backup-by-copying t)
  (kill-buffer-delete-auto-save-files t)
  (backup-directory-alist `((".*" . ,(expand-file-name
                                      (concat user-emacs-directory "backups"))))
                          "Keep backups in their own directory")

  (auto-save-file-name-transforms `((".*" ,(concat user-emacs-directory "autosaves/") t)))

  (delete-old-versions t)
  (kept-new-versions 3)
  (kept-old-versions 1)
  (version-control nil))

(setq window-combination-resize t)

(when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
 (setq dgl/linux nil)
 (setq dgl/win32 t))
(when (eq system-type 'gnu/linux)
 (setq dgl/win32 nil)
 (setq dgl/linux t))

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

(defun dgl/load-project-settings ()
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

;; Remember last edited files
(recentf-mode 1)
;; Save what you enter into minibuffer prompts
(setq history-length 25)
(savehist-mode 1)
;; Remember and restore the last cursor location of opened files
(save-place-mode 1)

(setq wdired-allow-to-change-permissions t)

(use-package emacs
  :bind-keymap
  ("M-J" . goto-map)
  ("M-S" . search-map)
  
  :bind
  ("M-f" . 'find-file)
  ("M-F" . 'find-file-other-window)
  ("M-b" . 'consult-buffer)
  ("M-B" . 'consult-buffer-other-window)
  ("M-g" . 'consult-ripgrep)
  
  ("M-w" . 'other-window)
  ("M-s" . 'save-buffer)
  ("M-u" . 'undo)
  ("M-j" . 'consult-imenu)
  ("C-q" . 'copy-region-as-kill)
  ("C-w" . 'kill-region)
  ("M->" . 'mc/mark-next-like-this)
  ("M-<" . 'mc/mark-previous-like-this)
  ("M-m" . 'make-without-asking)
  
  ("TAB" . 'dabbrev-expand)
  ("C-c TAB" . 'indent-region)
  ("C-x C-b" . 'ibuffer))

(when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
(setenv "PATH" (concat (getenv "PATH") ";" "C:\\Program Files\\Git\\usr\\bin")))

(setq visible-bell t)

(setq x-stretch-cursor t)

(setq-default tab-width 4)

(with-eval-after-load 'mule-util
 (setq truncate-string-ellipsis "…"))

(setq show-trailing-whitespace t)

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
                        :height dgl/default-font-size)
    (set-face-attribute 'fixed-pitch nil
                        :font dgl/default-font-name
                        :height dgl/default-font-size)
    (set-face-attribute 'fixed-pitch-serif nil
                        :font dgl/default-font-name
                        :height dgl/default-font-size)
    )

  (when (find-font (font-spec :name dgl/variable-font-name))
    (set-face-attribute 'variable-pitch nil
                        :font dgl/variable-font-name
                        :height dgl/default-font-size)))

(my/set-font)
(add-hook 'server-after-make-frame-hook #'my/set-font)

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

	(set-face-background 'region "#24335E")
	(set-face-foreground 'vertical-border "#625D52")
	(set-face-background 'trailing-whitespace "#013137")
	)
(my/set-colors)
(add-hook 'server-after-make-frame-hook #'my/set-colors)

(require 'package)
(setq load-prefer-newer t)

(when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
 (setq package-user-dir "t:/emacs/packages"))
(when (eq system-type 'gnu/linux)
 (setq package-user-dir "~/.emacs.d/packages"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(package-initialize)

(use-package async
  :ensure t
  :init (dired-async-mode 1)
  :config (setq async-bytecomp-package-mode 1))

(when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
 (let ((default-directory  "t:/emacs/plugins"))
   (normal-top-level-add-subdirs-to-load-path)))
(when (eq system-type 'gnu/linux)
 (let ((default-directory  "~/.emacs.d/plugins"))
   (normal-top-level-add-subdirs-to-load-path)))

(use-package consult
  :ensure t
  :bind (;; C-c bindings in `mode-specific-map'
         :map mode-specific-map
         ("M-x" . consult-mode-command)
         ("h" . consult-history)
         ("k" . consult-kmacro)
         ("m" . consult-man)
         ("i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         :map ctl-x-map
         ("M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         :map global-map
         ;; Custom M-# bindings for fast register access
         ("M-# l" . consult-register-load)
         ("M-# s" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("M-# #" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-J bindings in `goto-map'
         :map goto-map
         ("e" . consult-compile-error)
         ;;        ("M-G f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("g" . consult-goto-line)             ;; orig. goto-line
         ("l" . consult-goto-line)           ;; orig. goto-line
         ("o" . consult-outline)               ;; Alternative: consult-org-heading
         ("m" . consult-mark)
         ("M" . consult-global-mark)
         ("b" . consult-bookmark)
         ("i" . consult-imenu)
         ("I" . consult-imenu-multi)
         ;; M-S bindings in `search-map'
         :map search-map
         ("d" . consult-find)                  ;; Alternative: consult-fd
         ("c" . consult-locate)
         ("f" . consult-fd)
         ("g" . consult-grep)
         ("G" . consult-git-grep)
         ("r" . consult-ripgrep)
         ("l" . consult-line)
         ("L" . consult-line-multi)
         ("k" . consult-keep-lines)
         ("u" . consult-focus-lines)
         ;; Isearch integration
         ;; ("i" . consult-isearch-history)
         ;; :map isearch-mode-map
         ;; ("i" . consult-isearch-history)         ;; orig. isearch-edit-string
         ;; ("e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history)                ;; orig. previous-matching-history-element
         :map consult-narrow-map
         ("?" . consult-narrow-help)
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

(use-package embark
:ensure t
:bind (("C-M-x" . embark-act)
       :map minibuffer-local-map
       ("C-c C-c" . embark-collect)
       ("C-c C-e" . embark-export))

)

(use-package embark-consult
:ensure t)

(use-package wgrep
	:ensure t
	:bind ( :map grep-mode-map
			  ("e" . wgrep-change-to-wgrep-mode)
			  ("C-c C-c" . wgrep-finish-edit)
			  )
	)

(use-package vertico
  :ensure t
  
  ;; :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))
(vertico-multiform-mode)
(vertico-flat-mode)

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

(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-multiform-map
              ("S-TAB" . vertico-multiform-buffer)
              ("S-<tab>" . vertico-multiform-buffer))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package dumb-jump
:ensure t
:custom
(dumb-jump-prefer-searcher 'rg)
;; (xref-show-definitions-function #'xref-show-definitions-completing-read)
(xref-show-definitions-function #'consult-xref))
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

(setq set-mark-command-repeat-pop t)

(use-package multiple-cursors :ensure t)

(use-package cc-mode
  :defer t
  :bind (
    :map c++-mode-map
    ("TAB" . 'dabbrev-expand)
    ("C-c TAB" . 'indent-region)
    )
  :config

  ;; 4-space tabs
  (setq tab-width 4)
  (setq c-basic-offset 4)

  ;; No hungry backspace
  (c-toggle-auto-hungry-state -1)

  ;; Additional style stuff
  (setq c-offsets-alist '(
                          (member-init-intro . ++)
                          (case-label . +)
                          ))
  ;; Newline indents, semi-colon doesn't
  ;; (define-key c++-mode-map "\C-m" 'newline-and-indent)
  (setq c-hanging-semi&comma-criteria '((lambda () 'stop)))

  ;; Handle super-tabbify (TAB completes, shift-TAB actually tabs)
  (setq dabbrev-case-replace t)
  (setq dabbrev-case-fold-search t)
  (setq dabbrev-upcase-means-case-search t)

  ;; Abbrevation expansion
  (abbrev-mode 1)

  ;; if indent-tabs-mode is off, untabify before saving
  (add-hook 'write-file-hooks
            (lambda () (if (not indent-tabs-mode)
                           (untabify (point-min) (point-max)))
              nil ))

  )

(use-package dts-mode
  :ensure t
  :mode (
		 ("\\.dts$" . dts-mode)
		 ("\\.dtsi$" . dts-mode)
		 ("\\.dtso$" . dts-mode)
		 ))

(use-package go-mode
  :ensure t
  :mode ("\\.go$" . go-mode)
  )

(use-package lua-mode
  :ensure t
  :mode ("\\.lua$" . lua-mode)
  )

(use-package yaml-mode
  :ensure t
  :mode (
	   ("\\.yml$" . yaml-mode)
	   ("\\.yaml$" . yaml-mode)
	   )
  )

(use-package markdown-mode
  :ensure t
  :mode ("\\.md$" . markdown-mode))

(setq ispell-program-name "hunspell")
(setq ispell-dictionary "en_US")

(setq ispell-dictionary-alist
      '(("de_DE" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "de_DE") nil utf-8)
        ("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)
        ))

;; new variable `ispell-hunspell-dictionary-alist' is defined in Emacs
;; If it's nil, Emacs tries to automatically set up the dictionaries.
(if (boundp 'ispell-hunspell-dictionary-alist) t
  (setq ispell-hunspell-dictionary-alist ispell-dictionary-alist))

(autoload 'bb-mode            "bb-mode"         "Bitbake mode"                                         t)

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
                ("\\.bb$"       . bb-mode)
                ("\\.inc$"      . bb-mode)
                ("\\.bbappend$" . bb-mode)
                ("\\.bbclass$"  . bb-mode)
                ("\\.conf$"     . bb-mode)
                ("\\.js$"       . javascript-mode)
                ("\\.json$"     . javascript-mode)

                ) auto-mode-alist))

(add-hook 'c++-mode-hook        'dgl/unset-tabs-mode)
(add-hook 'prog-mode-hook       'dgl/set-tabs-mode)
(add-hook 'emacs-lisp-mode-hook 'dgl/set-tabs-mode)
(add-hook 'org-mode-hook        'dgl/set-tabs-mode)

(add-hook 'write-file-hooks 'delete-trailing-whitespace)

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
    (progn
      (dgl/load-project-settings)
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

(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(use-package magit
  :ensure t
  :bind
  ("M-G s" . 'magit-status)
  ("M-G b" . 'magit-blame)
  ("M-G d" . 'magit-diff)
  
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  )

(defvar highlight-codetags-keywords
	'(("\\<\\(TODO\\|FIXME\\|BUG\\)\\>" 1 font-lock-warning-face prepend)
	  ("\\<\\(NOTE\\|HACK\\|@[[:alnum:]]+\\)\\>" 1 font-lock-doc-face prepend)))

(define-minor-mode highlight-codetags-local-mode
	"Highlight codetags like TODO, FIXME, @performance..."
	:global nil
	(if highlight-codetags-local-mode
		(font-lock-add-keywords nil highlight-codetags-keywords)
	  (font-lock-remove-keywords nil highlight-codetags-keywords))

	;; Fontify the current buffer
	(when (bound-and-true-p font-lock-mode)
	  (if (fboundp 'font-lock-flush)
		  (font-lock-flush)
		(with-no-warnings (font-lock-fontify-buffer)))))

(add-hook 'prog-mode-hook #'highlight-codetags-local-mode)

(use-package emacs
  :bind-keymap
  ("M-P" . project-prefix-map)
  :config
  (setq project-mode-line t)
)

(when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
 (setq dgl/org-directory "w:/vault/org")
 (setq dgl/org-denote-directory (concat dgl/org-directory "/roam"))
 (setq dgl/org-roam-directory (concat dgl/org-directory "/roam")))
(when (eq system-type 'gnu/linux)
 (setq dgl/org-directory "~/vault/org")
 (setq dgl/org-denote-directory (concat dgl/org-directory "/roam"))
 (setq dgl/org-roam-directory (concat dgl/org-directory "/roam")))

(use-package org
	:defer t
	:mode ("\\.org$" . org-mode)
	:bind-keymap
	("M-N" . org-mode-map)
	:bind( :map org-mode-map
		   ("M-A" . org-agenda)
		   ("M-X" . org-archive-subtree)
		   ("M-c" . org-capture)
		   ("M-p" . org-priority)
		   ("M-r" . org-refile)
		   ("M-S" . org-schedule)
		   ("M-D" . org-deadline)
		   ("C-c TAB" . 'indent-region)
		   )
	:custom-face
	(org-block ((t (:inherit fixed-pitch))))
	(org-code ((t (:inherit (shadow fixed-pitch)))))
	(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
	(org-document-title ((t (:inherit variable-pitch :weight bold :height 1.2))))
	(org-indent ((t (:inherit (org-hide fixed-pitch)))))
	(org-level-1 ((t (:inherit org-document-title :height 1.0))))
	(org-level-2 ((t (:inherit org-level-1 :height 0.9))))
	(org-level-3 ((t (:inherit org-level-2 :height 0.9))))
	(org-level-4 ((t (:inherit org-level-3 :height 0.9))))
	(org-level-5 ((t (:inherit org-level-4 :height 0.9))))
	(org-level-6 ((t (:inherit org-level-5 :height 0.9))))
	(org-level-7 ((t (:inherit org-level-6 :height 0.9))))
	(org-level-8 ((t (:inherit org-level-7 :height 0.9))))
	(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
	(org-property-value ((t (:inherit fixed-pitch))))
	(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
	(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
	(org-verbatim ((t (:inherit (shadow fixed-pitch)))))
	:config
	(setq org-return-follows-link  t)
	;;(setq org-hide-emphasis-markers t) ;; Hide markers for e.g. *BOLD-TEXT*
	(add-hook 'org-mode-hook 'org-indent-mode)
	(add-hook 'org-mode-hook 'visual-line-mode)
	(add-hook 'org-mode-hook 'variable-pitch-mode)
	)

(use-package org-bullets
  :ensure t
  :after org
  :custom
  (org-bullets-bullet-list '("◉" "○" "●"))
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package denote
	:ensure t
	:bind (
		   ("C-c n n" . denote)
		   ("C-c n r" . denote-rename-file)
		   ("C-c n l" . denote-link)
		   ("C-c n b" . denote-backlinks)
		   ;; ("C-c n c" . denote-region)
		   ;; ("C-c n N" . denote-type)
		   ;; ("C-c n d" . denote-date)
		   ;;  ("C-c n z" . denote-signature)
		   ;;  ("C-c n s" . denote-subdirectory)
		   ;;  ("C-c n t" . denote-template)
		   ;;
		   ;;
		   ;;
		   ;;  ("C-c n f f" . denote-find-link)
		   ;;  ("C-c n f b" . denote-find-backlink)
		   ;;  ("C-c n r" . denote-rename-file)
		   ;;  ("C-c n R" . denote-rename-file-using-front-matter))
		   ;; (:map dired-mode-map
		   ;;  ("C-c C-d C-i" . denote-dired-link-marked-notes)
		   ;;  ("C-c C-d C-r" . denote-dired-rename-files)
		   ;;  ("C-c C-d C-k" . denote-dired-rename-marked-files-with-keywords)
		   ;;  ("C-c C-d C-R" . denote-dired-rename-marked-files-using-front-matter)
		   )
	:custom
	(denote-directory dgl/org-denote-directory)
	;;(denote-save-buffers nil)
	(denote-known-keywords '("personal" "work" "project" "bookmark" "study"))
	(denote-infer-keywords t)
	(denote-sort-keywords t)
	(denote-prompts '(title keywords))
	(denote-excluded-directories-regexp nil)
	(denote-excluded-keywords-regexp nil)
	(denote-rename-confirmations '(rewrite-front-matter modify-file-name))
	(denote-date-prompt-use-org-read-date t)
	;;(denote-date-format nil)
	(denote-backlinks-show-context t)
	(denote-rename-buffer-mode 1)
	;;(denote-org-capture-specifiers "%l\n%i\n%?")
	)

(use-package denote-menu
	:ensure t
	:bind (
		   ("C-c n d" . list-denotes)
		   :map denote-menu-mode-map
		   ("c" . denote-menu-clear-filters)
		   ("f" . denote-menu-filter)
		   ("k" . denote-menu-filter-by-keyword)
		   ("o"  . denote-menu-filter-out-keyword)
		   ("e" . denote-menu-export-to-dired)
		   )
	)

(use-package org
	:config
	(setq org-agenda-files (list dgl/org-directory dgl/org-roam-directory))
	(setq org-refile-targets
		  '(
			(org-agenda-files :maxlevel . 5)
			))
	(setq org-archive-location (concat dgl/org-directory "/archive.org::datetree/* Finished Tasks"))
	(setq org-log-done 'time)
	(setq org-todo-keywords
		  '((sequence "TODO(t)" "WAIT(w)" "NEXT(n)" "|" "DONE(d)" "CANC(c)")))
	(setq org-return-follows-link t)
	(setq org-agenda-custom-commands '(
									   ("t" "TODOs" tags-todo "+TODO=\"TODO\"-PROJECT")
									   ("i" "Inbox TODOs" tags-todo "+INBOX-KEEP")
									   ("w" "Waiting Tasks" tags-todo "+TODO=\"WAIT\"-PROJECT")
									   ("n" "Next Tasks" tags-todo "+TODO=\"NEXT\"-PROJECT")
									   ("s" "Someday" tags-todo "+TODO=\"TODO\"+SOMEDAY")
									   ))
	(setq org-agenda-sorting-strategy
	  '((agenda habit-down time-up priority-down category-keep)
		(todo priority-down todo-state-up category-keep)
		(tags priority-down todo-state-up category-keep)
		(search category-keep)))

	(setq org-capture-templates
	  `(
		("i" "Inbox" entry
		 (file, (concat dgl/org-directory "/inbox.org"))
		 "* TODO %^{Brief Description}\nAdded: %U\nContext: %a\n%?" :empty-lines 1 :prepend t)

		("n" "Next action" entry
		 (file, (concat dgl/org-directory "/gtd.org"))
		 "** NEXT [%^{Prio|#B|#A|#C}] %^{Brief Description}\nAdded: %U\n%?" :empty-lines 1 :prepend t)

		("w" "Waiting" entry
		 (file, (concat dgl/org-directory "/gtd.org"))
		 "** WAIT %^{Brief Description}\nAdded: %U\n%?" :empty-lines 1 :prepend t)

		("s" "Someday" entry
		 (file, (concat dgl/org-directory "/someday.org"))
		 "* TODO %^{Brief Description}\nAdded: %U\n%f\n%?" :empty-lines 1 :prepend t)
		))
	)

(defun dgl/gtd ()
  (interactive)
  (find-file (concat dgl/org-directory "/gtd.org"))
)

(use-package emacs
  :config
  (setq epa-pinentry-mode 'loopback)
)

(use-package tramp
  :defer t
  :custom
  ;; We use ssh controlmaster in our ssh config and in the putty session
  (tramp-use-connection-share nil)
  :config
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "ssh")
   'remote-direct-async-process)

  (connection-local-set-profiles
   '(:application tramp :protocol "sshx")
   'remote-direct-async-process)

  (connection-local-set-profiles
   '(:application tramp :protocol "plink")
   'remote-direct-async-process)

  (connection-local-set-profiles
   '(:application tramp :protocol "plinkx")
   'remote-direct-async-process)

  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process)

  (connection-local-set-profiles
   '(:application tramp :protocol "scpx")
   'remote-direct-async-process)

  (connection-local-set-profiles
   '(:application tramp :protocol "rsync")
   'remote-direct-async-process)

  (setq tramp-default-method "ssh")
  (setq remote-file-name-inhibit-locks t)
  (setq remote-file-name-inhibit-cache 180)
  (setq tramp-completion-reread-directory-timeout 180)
  (setq tramp-directory-cache-expire (* 60 60 24))
  (setq tramp-auto-save-directory nil)
  (setq vc-ignore-dir-regexp (format "%s\\|%s"
									 vc-ignore-dir-regexp
									 tramp-file-name-regexp))
  (setq tramp-ssh-controlmaster-options nil)
  (setq tramp-connection-timeout 10)
  (setq tramp-verbose 1)
  )

(use-package eshell
  :defer t
  :config
  (add-to-list 'eshell-modules-list 'eshell-tramp)
  (add-to-list 'eshell-modules-list 'eshell-smart)
  )

(setq browse-url-browser-function 'eww-browse-url)
(add-hook 'eww-after-render-hook 'eww-readable)

(when (eq system-type 'gnu/linux)
 (require 'exwm)
 ;; Set the initial workspace number.
 (setq exwm-workspace-number 4)

 ;; Automatically move EXWM buffer to current workspace when selected
 (setq exwm-layout-show-all-buffers t)

 ;; Display all EXWM buffers in every workspace buffer list
 (setq exwm-workspace-show-all-buffers t)

 ;; Make class name the buffer name.
 (add-hook 'exwm-update-class-hook
  		   (lambda () (exwm-workspace-rename-buffer exwm-class-name)))
 ;; These keys should always pass through to Emacs
 (setq exwm-input-prefix-keys
  	   '(?\C-x
  		 ?\C-u
  		 ?\C-h
  		 ?\C-q     ;; Prevent from accidently closing firefox
  		 ?\M-J b
  		 ?\M-b     ;; Buffer list
  		 ?\M-P p   ;; Project selection
  		 ?\M-x
  		 ?\M-w     ;; other window
  		 ?\M-`
  		 ?\M-&
  		 ?\M-:
  		 ?\C-\ ))  ;; Ctrl+Space

 ;; Global keybindings.
 (setq exwm-input-global-keys
       `(([?\s-r]   . exwm-reset) ;; s-r: Reset (to line-mode). C-c C-k switches to char-mode
  		 ([?\s-0]   . exwm-workspace-switch) ;; s-w: Switch workspace.
  		 ([?\s-b]   . exwm-workspace-switch-to-buffer)
  		 ([?\s-q]   . exwm-input-send-next-key)
  		 ([?\s-x]   . (lambda (cmd) ;; s-&: Launch application.
    					(interactive (list (read-shell-command "$ ")))
    					(start-process-shell-command cmd nil cmd)))
  		 ;; s-N: Switch to certain workspace.
  		 ,@(mapcar (lambda (i)
  					 `(,(kbd (format "s-%d" i)) .
  					   (lambda ()
  						 (interactive)
  						 (exwm-workspace-switch-create , (- i 1)))))
  				   (number-sequence 1 9))))
 ;; Enable EXWM
 (exwm-enable)
 )

(when (eq system-type 'gnu/linux)
 (defvar efs/polybar-process nil
   "Holds the process of the running Polybar instance, if any")

 (defun efs/kill-panel ()
   (interactive)
   (when efs/polybar-process
     (ignore-errors
       (kill-process efs/polybar-process)))
   (setq efs/polybar-process nil))

 (defun efs/start-panel ()
   (interactive)
   (efs/kill-panel)
   (setq efs/polybar-process (start-process-shell-command "polybar" nil "polybar")))

 (defun efs/send-polybar-hook (module-name hook-index)
   (start-process-shell-command "polybar-msg" nil (format "polybar-msg hook %s %s" module-name hook-index)))

 (defun efs/send-polybar-exwm-workspace ()
   (efs/send-polybar-hook "exwm-workspace" 1))

 ;; Update panel indicator when workspace changes
 (add-hook 'exwm-workspace-switch-hook #'efs/send-polybar-exwm-workspace)

 ;; Run on startup
 (add-hook 'exwm-init-hook #'efs/start-panel)
 )

(defun dgl-maximize-frame ()
  "Maximize the current frame"
  (interactive)
  (when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
   (w32-send-sys-command 61488)))

(defun window-post-load-stuff ()
  (interactive)
  (dgl-maximize-frame))

(add-hook 'window-setup-hook 'window-post-load-stuff t)

(defun post-load-stuff ()
  (interactive)
  (split-window-right)
  (switch-to-buffer-other-window "*scratch*")
  (windmove-left)
  (dgl/load-project-settings))

(post-load-stuff)
(add-hook 'server-after-make-frame-hook 'post-load-stuff t)

(defun dgl/set-tabs-mode ()
  "Enable tabs mode"
  (interactive)
  (setq indent-tabs-mode t)
  (message "Tabs enabled."))

(defun dgl/unset-tabs-mode ()
  "Enable tabs mode"
  (interactive)
  (setq indent-tabs-mode nil)
  (message "Tabs disabled."))
