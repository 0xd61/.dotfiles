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
  ("M-m" . 'make-without-asking))

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
      (load-project-settings)
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
      (setq org-agenda-files (list dgl/org-directory dgl/org-roam-directory))
      (setq org-refile-targets
		'(
		      (org-agenda-files :maxlevel . 5)
		      ))
      (setq org-archive-location (concat dgl/org-directory "/archive.org::datetree/* Finished Tasks"))
      (setq org-log-done 'time)
      (setq org-return-follows-link  t)
      (setq org-todo-keywords
	'((sequence "TODO" "WAIT" "NEXT" "|" "DONE" "DELEGATED" "CANCELLED")))
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

(use-package org-roam
  :ensure t
  :defer t
  :bind (
         ("C-c o b" . org-roam-buffer-toggle)
         ("C-c o f" . org-roam-node-find)
         ("C-c o i" . org-roam-node-insert)
         )
  :custom
  (org-roam-directory dgl/org-roam-directory)
  (org-roam-capture-templates
   '(("d" "default" plain
      "\n%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("w" "work log" plain
      "\n* Log for\n- Company: - Company: \n- Ticket: \n- Goal: \n\n* %?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :work:")
      :unnarrowed t)
     ("p" "project" plain
      "\n* Goals\n\n%?\n\n* Tasks\n** TODO Add initial tasks\n\n* Ideas"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :project:")
      :unnarrowed t)
     ("n" "notes" plain
      "\n* Source\n- URL: \n- Author: \n- Title: \n- Year: \n\n* Summary\n%?\n\n"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("m" "meeting" plain
      "\n* [[id:9b83da73-2238-4254-86a5-47559b13014a][samuu]] log for\n- Company: \n- With: \n- Topic: \n- Date: %T\n\n* Preparations\n** %?\n\n* Notes\n**\n\n* ToDos\n** TODO\n"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :work: :meeting:")
      :unnarrowed t)
     ))
  :config
  (run-with-idle-timer 8 nil 'org-roam-db-sync)
  (run-with-idle-timer 9 nil 'org-roam-db-autosync-mode)
  (org-roam-setup)
  )

(use-package denote
      :ensure t
      :bind (
       ("C-c n n" . denote)
       ("C-c n r" . denote-rename-file)
       ("C-c n l" . denote-link)
       ("C-c n b" . denote-backlinks)
       ("C-c n d" . denote-sort-dired)
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
  (load-project-settings))

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
