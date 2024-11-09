;;
;; dgl emacs config
;;

;;
;; GLOBAL SETTINGS
;;

;; Stop Emacs from losing undo information by
;; setting very high limits for undo buffers
(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)

(setq dgl-initials "dgl")

;; Determine the underlying operating system
(setq dgl-win32 (or (eq system-type 'windows-nt) (eq system-type 'ms-dos)))
(setq dgl-linux (not dgl-win32))

(setq dgl-project-file "./.project.el")


(setq compilation-directory-locked nil)
(scroll-bar-mode -1)
(setq shift-select-mode nil)
(setq enable-local-variables nil)
(setq column-number-mode t)
(setq dgl-font "DejaVu Sans Mono-12")
(setq backup-directory-alist `(("." . "./.em_backup")))

(setq default-buffer-file-coding-system 'utf-8-unix)

;; Turn off the toolbar
(tool-bar-mode 0)

(setq x-select-enable-clipboard t)

(when dgl-win32
  (setq dgl-makescript "build.teak")
  (setq dgl-font "Consolas-12")
  (setq backup-directory-alist `(("." . "t:/emacs/backup")))
  ;;(add-to-list 'load-path "t:/emacs/plugins")
  (let ((default-directory  "t:/emacs/plugins"))
    (normal-top-level-add-subdirs-to-load-path))
  (setq package-user-dir "t:/emacs/packages")
  (setq hledger-jfile "w:/vault/finance/journal.ledger")
  (setq todotxt-file "w:/vault/todo.txt")
  (setq org-roam-directory "w:/vault/org/roam")
  )

(when dgl-linux
  (setq dgl-makescript "./build.teak")
  (setq dgl-font "Input Mono Narrow-12")
  (setq backup-directory-alist `(("." . "~/.emacs.d/backup")))
  ;;(add-to-list 'load-path "~/.emacs.d/plugins")
  (let ((default-directory  "~/.emacs.d/plugins"))
    (normal-top-level-add-subdirs-to-load-path))
  (setq package-user-dir "~/.emacs.d/packages")
  ;;(setenv "PATH" (concat (getenv "PATH") ":/home/dgl/.local/bin"))
  (setq org-roam-directory "~/vault/org/roam")
  )

;; Load plugins
;; Upstream Packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(use-package org-roam
  :ensure t
  :bind (("C-c o b" . org-roam-buffer-toggle)
         ("C-c o f" . org-roam-node-find)
         ("C-c o i" . org-roam-node-insert))
  :config
  (org-roam-setup)
  )
(use-package go-mode :ensure t)


					; Local Packages/Plugins
;;(autoload 'ebuild-mode		"ebuild-mode"         "Gentoo ebuild mode"						 t)
;;(autoload 'bb-mode		"bb-mode"         "Bitbake mode"					 t)
(autoload 'fd-dired "fd-dired" "dired-mode interface for fd"  t)
(autoload 'fd-grep-dired "fd-dired" "dired-mode interface for rg"  t)

;; Remember last edited files
(recentf-mode 1)
;; Save what you enter into minibuffer prompts
(setq history-length 25)
(savehist-mode 1)
;; Remember and restore the last cursor location of opened files
(save-place-mode 1)

(global-hl-line-mode 1)
(global-font-lock-mode 1)

					; Startup windowing
(setq next-line-add-newlines nil)
(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)

;;
;; MACROS
;;

(defun dgl-grep ()
  "Run grep recursively from the directory of the current buffer or the default directory"
  (interactive)
  (let ((dir (file-name-directory (or load-file-name buffer-file-name default-directory))))
    (let ((command (read-from-minibuffer "Run grep: "
					 (cons (concat "rg -iS.  " dir) 10))))
      (grep command))))

(defun dgl-find-file ()
  "Find file"
  (interactive)
  (let* ((command (read-from-minibuffer "Run fd: "
					(cons "fd -iS  " 9)))
	 (files (shell-command-to-string  command)))
    (find-file
     (ido-completing-read
      "Find file: "
      (delete "" (split-string files "\n"))))))

(defun dgl-maximize-frame ()
  "Maximize the current frame"
  (interactive)
  (when dgl-win32 (w32-send-sys-command 61488)))


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

;;
;; HOOKS
;;

(defun dgl-c-hook ()
  ;; 4-space tabs
  (setq tab-width 4 indent-tabs-mode nil)

  ;; No hungry backspace
  (c-toggle-auto-hungry-state -1);

  ;; Additional style stuff
  (c-set-offset 'member-init-intro '++)

  ;; Newline indents, semi-colon doesn't
  (define-key c++-mode-map "\C-m" 'newline-and-indent)
  (setq c-hanging-semi&comma-criteria '((lambda () 'stop)))

  ;; Handle super-tabbify (TAB completes, shift-TAB actually tabs)
  (setq dabbrev-case-replace t)
  (setq dabbrev-case-fold-search t)
  (setq dabbrev-upcase-means-case-search t)

  ;; Abbrevation expansion
  (abbrev-mode 1)

  ;; Keybinds
  (define-key c++-mode-map (kbd "TAB") 'dabbrev-expand)
  (define-key c++-mode-map (kbd "S-TAB") 'indent-for-tab-command)
  (define-key c++-mode-map (kbd "C-TAB") 'indent-region)
  )

(defun find-project-directory-recursive (project-file depth)
  "Recursively search for the file."
  (interactive)
  (if (file-exists-p project-file) t
    (cd "../")
    (if (>= depth 0) t
      (find-project-directory-recursive project-file (- depth 1)))))

(defun load-project-settings ()
  (interactive)
  (setq find-project-from-directory default-directory)
  (cd find-project-from-directory)
  (find-project-directory-recursive dgl-project-file 5)
  (if (file-exists-p dgl-project-file)
      (load-file dgl-project-file))
  (cd find-project-from-directory)
  )

(defun window-post-load-stuff ()
  (interactive)
  (menu-bar-mode -1)
  (dgl-maximize-frame)
  )

(defun post-load-stuff ()
  (interactive)
  (split-window-horizontally)
  (load-project-settings)
  )


(add-hook 'window-setup-hook 'window-post-load-stuff t)
(add-hook 'after-init-hook 'post-load-stuff t)
(add-hook 'c-mode-common-hook 'dgl-c-hook)

;;
;; Keybindings
;;
(keymap-global-set "M-f" 'find-file)
(keymap-global-set "M-F" 'find-file-other-window)
(keymap-global-set "M-b" 'ido-switch-buffer)
(keymap-global-set "M-B" 'ido-switch-buffer-other-window)
(keymap-global-set "M-w" 'other-window)
(keymap-global-set "M-s" 'save-buffer)
(keymap-global-set "M-u" 'undo)
(keymap-global-set "M-j" 'imenu)
(keymap-global-set "M-h" 'dgl-find-file)
(keymap-global-set "M-g" 'dgl-grep)
(keymap-global-set "C-q" 'copy-region-as-kill)
(keymap-global-set "C-w" 'kill-region)

;;
;; Highlight
;;


(set-foreground-color "#D2B48C")
(set-background-color "#012326")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes nil)
 '(package-selected-packages '(org-roam)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background "#012326" :foreground "#D2B48C" :height 110 :family 'dgl-font))))
 '(cursor ((t (:background "#65D6AD"))))
 '(font-lock-builtin-face ((t (:foreground "#D2B48C"))))
 '(font-lock-comment-face ((t (:foreground "#31B72C"))))
 '(font-lock-constant-face ((t (:foreground "#65D6AD"))))
 '(font-lock-doc-face ((t (:foreground "#E8E6E1"))))
 '(font-lock-function-name-face ((t (:foreground "#D2B48C"))))
 '(font-lock-keyword-face ((t (:foreground "#E8E6E1"))))
 '(font-lock-preprocessor-face ((t (:foreground "#625D52"))))
 '(font-lock-string-face ((t (:foreground "#2CB1BC"))))
 '(font-lock-type-face ((t (:foreground "#D2B48C"))))
 '(font-lock-variable-name-face ((t (:foreground "#D2B48C"))))
 '(fringe ((t (:background "#01282d"))))
 '(highlight ((t (:foreground "#625D52"))))
 '(hl-line ((t (:background "#013137"))))
 '(mode-line ((t (:background "#D2B48C" :foreground "#012326"))))
 '(mode-line-inactive ((t (:inherit default :background "#013137"))))
 '(region ((t (:background "#24335E"))))
 '(vertical-border ((t (:foreground "#625D52")))))

					;(defun dgl-ediff-setup-windows (buffer-A buffer-B buffer-C control-buffer)
					;  (ediff-setup-windows-plain buffer-A buffer-B buffer-C control-buffer)
					;)
					;(setq ediff-window-setup-function 'dgl-ediff-setup-windows)
					;(setq ediff-split-window-function 'split-window-horizontally)
					;
					; Setup my compilation mode
					;(defun dgl-big-fun-compilation-hook ()
					;  (make-local-variable 'truncate-lines)
					;  (setq truncate-lines nil)
					;)
					;
					;(add-hook 'compilation-mode-hook 'dgl-big-fun-compilation-hook)
					;
					;(defun load-todo ()
					;  (interactive)
					;  (find-file dgl-todo-file)
					;)
					;(define-key global-map "\et" 'dgl-insert-todo)
					;
					;(defun insert-timeofday ()
					;   (interactive "*")
					;   (insert (format-time-string "---------------- %a, %d %b %y: %I:%M%p")))
					;(defun load-log ()
					;  (interactive)
					;  (find-file dgl-log-file)
					;  (if (boundp 'longlines-mode) ()
					;    (longlines-mode 1)
					;    (longlines-show-hard-newlines))
					;  (if (equal longlines-mode t) ()
					;    (longlines-mode 1)
					;    (longlines-show-hard-newlines))
					;  (end-of-buffer)
					;  (newline-and-indent)
					;  (insert-timeofday)
					;  (newline-and-indent)
					;  (newline-and-indent)
					;  (end-of-buffer)
					;)
					;(define-key global-map "\eT" 'dgl-insert-note)
					;
;; no screwing with my middle mouse button
					;(global-unset-key [mouse-2])
					;
;; Bright-red TODOs
					; (setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
					; (make-face 'font-lock-fixme-face)
					; (make-face 'font-lock-study-face)
					; (make-face 'font-lock-important-face)
					; (make-face 'font-lock-note-face)
					; (mapc (lambda (mode)
					;	 (font-lock-add-keywords
					;	  mode
					;	  '(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
					;	    ("\\<\\(STUDY\\)" 1 'font-lock-study-face t)
					;	    ("\\<\\(IMPORTANT\\)" 1 'font-lock-important-face t)
					;	    ("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))
					;	fixme-modes)
					; (modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
					; (modify-face 'font-lock-study-face "Dark Green" nil nil t nil t nil nil)
					; (modify-face 'font-lock-important-face "Red" nil nil t nil t nil nil)
					; (modify-face 'font-lock-note-face "Yellow" nil nil t nil t nil nil)
					;
					;					; Accepted file extensions and their appropriate modes
					;
					;(setq auto-mode-alist
					;      (append
					;       '(("\\workspace.dsl$" . javascript-mode)
					;	 ("\\todo.txt$"  . todotxt-mode)
					;	 ("\\.cpp$"      . c++-mode)
					;	 ("\\.hin$"      . c++-mode)
					;	 ("\\.cin$"      . c++-mode)
					;	 ("\\.inl$"      . c++-mode)
					;	 ("\\.rdc$"      . c++-mode)
					;	 ("\\.h$"        . c++-mode)
					;	 ("\\.c$"        . c++-mode)
					;	 ("\\.cc$"       . c++-mode)
					;	 ("\\.c8$"       . c++-mode)
					;	 ("\\.teak$"     . c++-mode)
					;	 ("\\.txt$"      . indented-text-mode)
					;	 ("\\.emacs$"    . emacs-lisp-mode)
					;	 ("\\.gen$"      . gen-mode)
					;	 ("\\.ms$"       . fundamental-mode)
					;	 ("\\.m$"        . objc-mode)
					;	 ("\\.mm$"       . objc-mode)
					;	 ("\\.go$"       . go-mode)
					;	 ("\\.bb$"       . bb-mode)
					;	 ("\\.inc$"      . bb-mode)
					;	 ("\\.bbappend$" . bb-mode)
					;	 ("\\.bbclass$"  . bb-mode)
					;	 ("\\.conf$"     . bb-mode)
					;	 ("\\.md$"       . markdown-mode)
					;	 ("\\.js$"       . javascript-mode)
					;	 ("\\.json$"     . javascript-mode)
					;	 ("\\.ledger$"   . ledger-mode)
					;	 ("\\.ebuild$"   . ebuild-mode)
					;	 ) auto-mode-alist))
					;
;; C++ indentation style
					;(defconst dgl-big-fun-c-style
					;  '((c-electric-pound-behavior   . nil)
					;    (c-tab-always-indent         . t)
					;    (c-comment-only-line-offset  . 0)
					;    (c-hanging-braces-alist      . ((class-open)
					;				    (class-close)
					;				    (defun-open)
					;				    (defun-close)
					;				    (inline-open)
					;				    (inline-close)
					;				    (brace-list-open)
					;				    (brace-list-close)
					;				    (brace-list-intro)
					;				    (brace-list-entry)
					;				    (block-open)
					;				    (block-close)
					;				    (substatement-open)
					;				    (statement-case-open)
					;				    (class-open)))
					;    (c-hanging-colons-alist      . ((inher-intro)
					;				    (case-label)
					;				    (label)
					;				    (access-label)
					;				    (access-key)
					;				    (member-init-intro)))
					;    (c-cleanup-list              . (scope-operator
					;				    list-close-comma
					;				    defun-close-semi))
					;    (c-offsets-alist             . ((arglist-close         .  c-lineup-arglist)
					;				    (label                 . -4)
					;				    (access-label          . -4)
					;				    (substatement-open     .  0)
					;				    (statement-case-intro  .  4)
					;				    ;(statement-block-intro .  c-lineup-for)
					;				    (case-label            .  4)
					;				    (block-open            .  0)
					;				    (inline-open           .  0)
					;				    (topmost-intro-cont    .  0)
					;				    (knr-argdecl-intro     . -4)
					;				    (brace-list-open       .  0)
					;				    (brace-list-intro      .  4)))
					;    (c-echo-syntactic-information-p . t))
					;    "Casey's Big Fun C++ Style")
					;
					;
;; CC++ mode handling
					;(defun dgl-big-fun-c-hook ()
					;  ; Set my style for the current buffer
					;  (c-add-style "BigFun" dgl-big-fun-c-style t)
					;
					;  ; 4-space tabs
					;  (setq tab-width 4 indent-tabs-mode nil)
					;  ; No hungry backspace
					;  (c-toggle-auto-hungry-state -1);

					;  ; Additional style stuff
					;  (c-set-offset 'member-init-intro '++)
					;

					;
					;  ; Newline indents, semi-colon doesn't
					;  (define-key c++-mode-map "\C-m" 'newline-and-indent)
					;  (setq c-hanging-semi&comma-criteria '((lambda () 'stop)))
					;
					;  ; Handle super-tabbify (TAB completes, shift-TAB actually tabs)
					;  (setq dabbrev-case-replace t)
					;  (setq dabbrev-case-fold-search t)
					;  (setq dabbrev-upcase-means-case-search t)
					;
					;  ; Abbrevation expansion
					;  (abbrev-mode 1)
					;
					;  (defun dgl-header-format ()
					;     "Format the given file as a header file."
					;     (interactive)
					;     (setq BaseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
					;     (insert "#ifndef ")
					;     (push-mark)
					;     (insert BaseFileName)
					;     (upcase-region (mark) (point))
					;     (pop-mark)
					;     (insert "_H\n")
					;     (insert "#define ")
					;     (push-mark)
					;     (insert BaseFileName)
					;     (upcase-region (mark) (point))
					;     (pop-mark)
					;     (insert "_H\n")
					;     (insert "#endif //")
					;     (push-mark)
					;     (insert BaseFileName)
					;     (upcase-region (mark) (point))
					;     (pop-mark)
					;     (insert "_H\n")
					;  )
					;
					;  (defun dgl-source-format ()
					;     "Format the given file as a source file."
					;     (interactive)
					;     (setq BaseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
;;     (insert "/* ========================================================================\n")
;;     (insert "   $File: $\n")
;;     (insert "   $Date: $\n")
;;     (insert "   $Revision: $\n")
;;     (insert "   $Creator: Casey Muratori $\n")
;;     (insert "   $Notice: (C) Copyright 2015 by Molly Rocket, Inc. All Rights Reserved. $\n")
;;     (insert "   ======================================================================== */\n")
					;  )
					;
					;  (cond ((file-exists-p buffer-file-name) t)
					;	((string-match "[.]hin" buffer-file-name) (dgl-source-format))
					;	((string-match "[.]cin" buffer-file-name) (dgl-source-format))
					;	((string-match "[.]h" buffer-file-name) (dgl-header-format))
					;	((string-match "[.]cpp" buffer-file-name) (dgl-source-format))
					;	((string-match "[.]c" buffer-file-name) (dgl-source-format)))
					;
					;  (defun dgl-find-corresponding-file ()
					;    "Find the file that corresponds to this one."
					;    (interactive)
					;    (setq CorrespondingFileName nil)
					;    (setq BaseFileName (file-name-sans-extension buffer-file-name))
					;    (if (string-match "\\.c" buffer-file-name)
					;       (setq CorrespondingFileName (concat BaseFileName ".h")))
					;    (if (string-match "\\.h" buffer-file-name)
					;       (if (file-exists-p (concat BaseFileName ".c")) (setq CorrespondingFileName (concat BaseFileName ".c"))
					;	   (setq CorrespondingFileName (concat BaseFileName ".cpp"))))
					;    (if (string-match "\\.hin" buffer-file-name)
					;       (setq CorrespondingFileName (concat BaseFileName ".cin")))
					;    (if (string-match "\\.cin" buffer-file-name)
					;       (setq CorrespondingFileName (concat BaseFileName ".hin")))
					;    (if (string-match "\\.cpp" buffer-file-name)
					;       (setq CorrespondingFileName (concat BaseFileName ".h")))
					;    (if CorrespondingFileName (find-file CorrespondingFileName)
					;       (error "Unable to find a corresponding file")))
					;  (defun dgl-find-corresponding-file-other-window ()
					;    "Find the file that corresponds to this one."
					;    (interactive)
					;    (find-file-other-window buffer-file-name)
					;    (dgl-find-corresponding-file)
					;    (other-window -1))
					;  (define-key c++-mode-map [f12] 'dgl-find-corresponding-file)
					;  (define-key c++-mode-map [M-f12] 'dgl-find-corresponding-file-other-window)
					;
					;  ; Alternate bindings for F-keyless setups (ie MacOS X terminal)
					;  (define-key c++-mode-map "\ec" 'dgl-find-corresponding-file)
					;  (define-key c++-mode-map "\eC" 'dgl-find-corresponding-file-other-window)
					;
					;  (define-key c++-mode-map "\es" 'dgl-save-buffer)
					;  ; Save buffer without converting tabs to spaces
					;  (define-key c++-mode-map "\eS" 'save-buffer)
					;
					;  (define-key c++-mode-map "\t" 'dabbrev-expand)
					;  (define-key c++-mode-map [S-tab] 'indent-for-tab-command)
					;  (define-key c++-mode-map "\C-y" 'indent-for-tab-command)
					;  (define-key c++-mode-map [C-tab] 'indent-region)
					;  (define-key c++-mode-map "	" 'indent-region)
					;
					;  (define-key c++-mode-map "\ej" 'imenu)
					;
					;  (define-key c++-mode-map "\e." 'c-fill-paragraph)
					;
					;  (define-key c++-mode-map "\e/" 'c-mark-function)
					;
					;  ;(define-key c++-mode-map "\e " 'set-mark-command)
					;  (define-key c++-mode-map "\eq" 'append-as-kill)
					;  (define-key c++-mode-map "\ea" 'yank)
					;  (define-key c++-mode-map "\ez" 'kill-region)
					;
					;  ; devenv.com error parsing
					;  (add-to-list 'compilation-error-regexp-alist 'dgl-devenv)
					;  (add-to-list 'compilation-error-regexp-alist-alist '(dgl-devenv
					;   "*\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) : \\(?:see declaration\\|\\(?:warnin\\(g\\)\\|[a-z ]+\\) C[0-9]+:\\)"
					;    2 3 nil (4)))
					;
					;  ; Turn on line numbers
					;  ;(linum-mode)
					;)
					;
					;(defun dgl-replace-string (FromString ToString)
					;  "Replace a string without moving point."
					;  (interactive "sReplace: \nsReplace: %s  With: ")
					;  (save-excursion
					;    (replace-string FromString ToString)
					;  ))
					;(define-key global-map [f8] 'dgl-replace-string)
					;
					;(add-hook 'c-mode-common-hook 'dgl-big-fun-c-hook)
					;
					;(defun dgl-save-buffer ()
					;  "Save the buffer after untabifying it."
					;  (interactive)
					;  (save-excursion
					;    (save-restriction
					;      (widen)
					;      (untabify (point-min) (point-max))))
					;  (save-buffer))
					;
					;
;; TXT mode handling
					;(defun dgl-big-fun-text-hook ()
					;  ; 4-space tabs
					;  (setq tab-width 4
					;	indent-tabs-mode nil)
					;
					;  ; Newline indents, semi-colon doesn't
					;  (define-key text-mode-map "\C-m" 'newline-and-indent)
					;
					;  ; Prevent overriding of alt-s
					;  (define-key text-mode-map "\es" 'dgl-save-buffer)
					;  ; Save buffer without converting tabs to spaces
					;  (define-key text-mode-map "\eS" 'save-buffer)
					;  )
					;(add-hook 'text-mode-hook 'dgl-big-fun-text-hook)
					;
;; Window Commands
					;(defun w32-restore-frame ()
					;    "Restore a minimized frame"
					;     (interactive)
					;     (w32-send-sys-command 61728))
					;
					;(defun maximize-frame ()
					;    "Maximize the current frame"
					;     (interactive)
					;     (when dgl-aquamacs (aquamacs-toggle-full-frame))
					;     (when dgl-win32 (w32-send-sys-command 61488)))
					;
					;(define-key global-map "\ep" 'quick-calc)
					;(define-key global-map "\ew" 'other-window)
					;
;; Navigation
					;(defun previous-blank-line ()
					;  "Moves to the previous line containing nothing but whitespace."
					;  (interactive)
					;  (search-backward-regexp "^[ \t]*\n")
					;)
					;
					;(defun next-blank-line ()
					;  "Moves to the next line containing nothing but whitespace."
					;  (interactive)
					;  (forward-line)
					;  (search-forward-regexp "^[ \t]*\n")
					;  (forward-line -1)
					;)
					;
					;(define-key global-map [C-right] 'forward-word)
					;(define-key global-map [C-S-right] 'end-of-line)
					;(define-key global-map [C-left] 'backward-word)
					;(define-key global-map [C-S-left] 'beginning-of-line)
					;(define-key global-map [C-up] 'previous-blank-line)
					;(define-key global-map [C-down] 'next-blank-line)
					;(define-key global-map [home] 'beginning-of-line)
					;(define-key global-map [end] 'end-of-line)
					;(define-key global-map [pgup] 'forward-page)
					;(define-key global-map [pgdown] 'backward-page)
					;(define-key global-map [C-next] 'scroll-other-window)
					;(define-key global-map [C-prior] 'scroll-other-window-down)
					;(define-key global-map [C-+] 'text-scale-increase)
					;(define-key global-map [C-_] 'text-scale-decrese)
					;
;; ALT-alternatives
					;(defadvice set-mark-command (after no-bloody-t-m-m activate)
					;  "Prevent consecutive marks activating bloody `transient-mark-mode'."
					;  (if transient-mark-mode (setq transient-mark-mode nil)))
					;
					;(defadvice mouse-set-region-1 (after no-bloody-t-m-m activate)
					;  "Prevent mouse commands activating bloody `transient-mark-mode'."
					;  (if transient-mark-mode (setq transient-mark-mode nil)))
					;
					;(defun append-as-kill ()
					;  "Performs copy-region-as-kill as an append."
					;  (interactive)
					;  (append-next-kill)
					;  (copy-region-as-kill (mark) (point))
					;)
					;(define-key global-map "\e " 'set-mark-command)
					;(define-key global-map "\eq" 'append-as-kill)
					;(define-key global-map "\ea" 'yank)
					;(define-key global-map "\ez" 'kill-region)
					;(define-key global-map [M-up] 'previous-blank-line)
					;(define-key global-map [M-down] 'next-blank-line)
					;(define-key global-map [M-right] 'forward-word)
					;(define-key global-map [M-left] 'backward-word)
					;
					;(define-key global-map "\e:" 'View-back-to-mark)
					;(define-key global-map "\e;" 'exchange-point-and-mark)
					;
					;(define-key global-map [f9] 'first-error)
					;(define-key global-map [f10] 'previous-error)
					;(define-key global-map [f11] 'next-error)
					;
					;(define-key global-map "\en" 'next-error)
					;(define-key global-map "\eN" 'previous-error)
					;
					;(define-key global-map "\eg" 'goto-line)
					;(define-key global-map "\eG" 'dgl-git-find-file)
					;(define-key global-map "\eh" 'dgl-git-grep)
					;(define-key global-map "\eH" 'dgl-grep)
					;(define-key global-map "\ej" 'imenu)
					;
					;(define-key global-map "\e," 'align-regexp)
					;
;; Editting
					;(define-key global-map "" 'copy-region-as-kill)
					;(define-key global-map "" 'yank)
					;(define-key global-map "" 'nil)
					;(define-key global-map "" 'rotate-yank-pointer)
					;(define-key global-map "\eu" 'undo)
					;(define-key global-map "\e6" 'upcase-word)
					;(define-key global-map "\e^" 'captilize-word)
					;(define-key global-map "\e." 'fill-paragraph)
					;
					;(defun dgl-replace-in-region (old-word new-word)
					;  "Perform a replace-string in the current region."
					;  (interactive "sReplace: \nsReplace: %s  With: ")
					;  (save-excursion (save-restriction
					;		    (narrow-to-region (mark) (point))
					;		    (beginning-of-buffer)
					;		    (replace-string old-word new-word)
					;		    ))
					;  )
					;
					;(defun dgl-backward-kill-word ()
					;      "Better backward-kill-word."
					;      (interactive)
					;      (fixup-whitespace)
					;      (backward-delete-char-untabify 1))
					;
					;(define-key global-map "\el" 'dgl-replace-in-region)
					;
					;(define-key global-map "\eo" 'query-replace)
					;(define-key global-map "\eO" 'dgl-replace-string)
					;
;; \377 is alt-backspace
					;(define-key global-map "\377" 'backward-kill-word)
					;(define-key global-map [M-delete] 'kill-word)
					;
					;(define-key global-map "\e[" 'start-kbd-macro)
					;(define-key global-map "\e]" 'end-kbd-macro)
					;(define-key global-map "\e\\" 'call-last-kbd-macro)
					;
;; Buffers
					;(define-key global-map "\er" 'revert-buffer)
					;(define-key global-map "\ek" 'kill-this-buffer)
					;(define-key global-map "\es" 'save-buffer)
					;
;; Compilation
					;(setq compilation-context-lines 0)
					;(setq compilation-error-regexp-alist
					;    (cons '("^\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) : \\(?:fatal error\\|warnin\\(g\\)\\) C[0-9]+:" 2 3 nil (4))
					;     compilation-error-regexp-alist))
					;
					;(defun find-project-directory-recursive (project-file depth)
					;  "Recursively search for the file."
					;  (interactive)
					;  (if (file-exists-p project-file) t
					;      (cd "../")
					;      (if (>= depth 0) t
					;	  (find-project-directory-recursive project-file (- depth 1)))))
					;
					;(defun lock-compilation-directory ()
					;  "The compilation process should NOT hunt for a makefile"
					;  (interactive)
					;  (setq compilation-directory-locked t)
					;  (message "Compilation directory is locked."))
					;
					;(defun unlock-compilation-directory ()
					;  "The compilation process SHOULD hunt for a makefile"
					;  (interactive)
					;  (setq compilation-directory-locked nil)
					;  (message "Compilation directory is roaming."))
					;
					;(defun find-project-directory ()
					;  "Find the project directory of the make script."
					;  (interactive)
					;  (setq find-project-from-directory default-directory)
					;  (switch-to-buffer-other-window "*compilation*")
					;  (if compilation-directory-locked (cd last-compilation-directory)
					;  (cd find-project-from-directory)
					;  (find-project-directory-recursive dgl-makescript 5)
					;  (setq last-compilation-directory default-directory)))
					;
					;(defun make-without-asking ()
					;  "Make the current build."
					;  (interactive)
					;  (if (find-project-directory) (compile dgl-makescript))
					;  (other-window 1))
					;(define-key global-map "\em" 'make-without-asking)
					;
;; Fix colors in compilation window
					;(require 'ansi-color)
					;(defun colorize-compilation-buffer ()
					;  (let ((inhibit-read-only t))
					;    (ansi-color-apply-on-region (point-min) (point-max))))
					;(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)
					;
;;; Minimize garbage collection during startup
					;(setq gc-cons-threshold most-positive-fixnum)
					;
;;; Lower threshold back to 8 MiB (default is 800kB)
					;(add-hook 'emacs-startup-hook
					;	  (lambda ()
					;	    (setq gc-cons-threshold (expt 2 23))))
					;
;; Commands
					;(set-variable 'grep-command "git --no-pager grep -irHn ")
					;(setq grep-use-null-device nil)
					;(when dgl-win32
					;    ; for findstr this has to be set to t
					;    (setq grep-use-null-device nil)
					;    ;(set-variable 'grep-command "findstr -s -n -i -l "))
					;    (set-variable 'grep-command "git --no-pager grep -irHn "))
					;
;; Group digits for calc
					;(setq calc-group-digit t)
					;
;; Smooth scroll
					;(setq scroll-step 3)
					;
;; Clock
					;(display-time)
					;
;; Modal Keymap
					;(defmacro save-column (&rest body)
					;  `(let ((column (current-column)))
					;     (unwind-protect
					;	 (progn ,@body)
					;       (move-to-column column))))
					;(put 'save-column 'lisp-indent-function 0)
					;
					;(defun dgl-move-line-up ()
					;  (interactive)
					;  (save-column
					;    (transpose-lines 1)
					;    (forward-line -2)))
					;
					;(defun dgl-move-line-down ()
					;  (interactive)
					;  (save-column
					;    (forward-line 1)
					;    (transpose-lines 1)
					;    (forward-line -1)))
					;
					;(defun dgl-duplicate-line ()
					;  (interactive)
					;  (save-column
					;    (beginning-of-line)
					;    (kill-line)
					;    (yank)
					;    (newline)
					;    (yank)))
					;
					;(defun dgl-kill-line ()
					;  (interactive)
					;  (save-column
					;    (kill-whole-line)))
					;
					;(defun dgl-git-find-file ()
					;  "Find file with git"
					;  (interactive)
					;  (let* ((command (read-from-minibuffer "Run git ls-files: "
					;				       (cons "git ls-files --recurse-submodules -c --exclude-standard **" 58)))
					;	(files (shell-command-to-string  command)))
					;    (find-file
					;     (ido-completing-read
					;      "Find in git repo: "
					;      (delete "" (split-string files "\n"))))))
					;
					;(defun dgl-git-grep ()
					;  "Run git-grep recursively"
					;  (interactive)
					;  (let ((command (read-from-minibuffer "Run git grep: "
					;				       "git --no-pager grep -irHn ")))
					;    (grep command)))
					;
					;(defun dgl-grep ()
					;  "Run grep recursively from the directory of the current buffer or the default directory"
					;    (interactive)
					;    (let ((dir (file-name-directory (or load-file-name buffer-file-name default-directory))))
					;      (let ((command (read-from-minibuffer "Run grep: "
					;					   (cons (concat "grep -irHn  " dir) 12))))
					;	(grep command))))
					;
					;(defun dgl-insert-todo ()
					;  (interactive)
					;  (insert (concat "// TODO(" dgl-initials "): "))
					;  (end-of-line))
					;
					;(defun dgl-insert-note ()
					;  (interactive)
					;  (insert (concat "// NOTE(" dgl-initials "): "))
					;  (end-of-line))
					;
					;(setq ryo-modal-cursor-color "red")
;; needed to set the cursor color explicit. Otherwise it was black after exiting the modal mode
					;(setq ryo-modal-default-cursor-color "#65D6AD")
					;(define-key global-map [C-return] 'ryo-modal-mode)
					;(define-key global-map [M-return] 'ryo-modal-mode)
					;(ryo-modal-keys
					;   ("SPC" set-mark-command)
					;   ("," ryo-modal-repeat)
					;   ("a" ryo-modal-mode)
					;   ("i" ryo-modal-mode)
					;   ("h" backward-char)
					;   ("j" next-line)
					;   ("k" previous-line)
					;   ("l" forward-char)
					;   ("<C-S-up>" dgl-move-line-up)
					;   ("<C-S-down>" dgl-move-line-down)
					;   ("y" yank)
					;   ("d" dgl-kill-line)
					;   ("f" dgl-duplicate-line)
					;   ("u" undo)
					;   ("c" cua-selection-mode)
					;   ("b" (("b" bookmark-set)
					;	 ("SPC" bookmark-bmenu-list)))
					;   ("g" goto-line)
					;   ("G" dgl-git-find-file)
					;   ("h" dgl-git-grep)
					;   ("H" dgl-grep)
					;   ("t" load-todo)
					;   ("T" load-log)
					;   )
					;
;; Startup windowing
					;(setq next-line-add-newlines nil)
					;(setq-default truncate-lines t)
					;(setq truncate-partial-width-windows nil)
					;
					;(custom-set-variables
					; ;; custom-set-variables was added by Custom.
					; ;; If you edit it by hand, you could mess it up, so be careful.
					; ;; Your init file should contain only one such instance.
					; ;; If there is more than one, they won't work right.
					; '(auto-save-default nil)
					; '(auto-save-list-file-prefix nil)
					; '(auto-save-timeout 0)
					; '(auto-show-mode t t)
					; '(delete-auto-save-files nil)
					; '(delete-old-versions 'other)
					; '(imenu-auto-rescan t)
					; '(imenu-auto-rescan-maxout 500000)
					; '(kept-new-versions 5)
					; '(kept-old-versions 5)
					; '(ledger-reports
					;   '(("test" "ledger balance")
					;     ("bal" "%(binary) -f %(ledger-file) bal")
					;     ("reg" "%(binary) -f %(ledger-file) reg")
					;     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
					;     ("account" "%(binary) -f %(ledger-file) reg %(account)")))
					; '(make-backup-file-name-function 'ignore)
					; '(make-backup-files nil)
					; '(mouse-wheel-follow-mouse nil)
					; '(mouse-wheel-progressive-speed nil)
					; '(mouse-wheel-scroll-amount '(15))
					; '(package-selected-packages
					;   '(ledger-mode todotxt ryo-modal markdown-mode hledger-mode go-mode))
					; '(version-control nil))
					;
					;(define-key global-map "\t" 'dabbrev-expand)
					;(define-key global-map [S-tab] 'indent-for-tab-command)
					;(define-key global-map [backtab] 'indent-for-tab-command)
					;(define-key global-map "\C-y" 'indent-for-tab-command)
					;(define-key global-map [C-tab] 'indent-region)
					;(define-key global-map "	" 'indent-region)
					;
					;(defun dgl-never-split-a-window (window)
					;    "Never, ever split a window. Why would anyone EVER want you to do that??"
					;    nil)
					;(setq split-window-preferred-function 'dgl-never-split-a-window)
					;(split-window-horizontally)
					;
					;(global-hl-line-mode 1)
					;(global-font-lock-mode 1)
					;(set-face-background 'hl-line "#013137")
					;
;;(add-to-list 'default-frame-alist '(font . dgl-font))
					;(set-face-attribute 'font-lock-builtin-face nil :foreground "#D6B58D")
					;(set-face-attribute 'font-lock-comment-face nil :foreground "#31B72C")
					;(set-face-attribute 'font-lock-constant-face nil :foreground "#65D6AD")
					;(set-face-attribute 'font-lock-doc-face nil :foreground "#E8E6E1")
					;(set-face-attribute 'font-lock-function-name-face nil :foreground "#D6B58D")
					;(set-face-attribute 'font-lock-keyword-face nil :foreground "#E8E6E1")
					;(set-face-attribute 'font-lock-string-face nil :foreground "#2CB1BC")
					;(set-face-attribute 'font-lock-type-face nil :foreground "#D6B58D")
					;(set-face-attribute 'font-lock-variable-name-face nil :foreground "#D6B58D")
					;(set-face-attribute 'font-lock-preprocessor-face nil :foreground "#625D52")
					;(set-face-attribute 'region nil :background "#24335E")
					;(set-face-attribute 'highlight nil :background "#01282d")
;;(set-face-attribute 'mode-line nil :background "#93876c")
;;(set-face-attribute 'mode-line-inactive nil :background "#625D52")
					;(set-face-attribute 'fringe nil :background "#01282d")
					;(set-face-attribute 'vertical-border nil :foreground "#625D52")
					;(set-face-attribute 'cursor nil :background "#65D6AD")
					;
					;(defun load-project-settings ()
					;  (interactive)
					;  (setq find-project-from-directory default-directory)
					;  (cd find-project-from-directory)
					;  (find-project-directory-recursive dgl-project-file 5)
					;  (if (file-exists-p dgl-project-file)
					;      (load-file dgl-project-file))
					;  (cd find-project-from-directory)
					;  )
					;
					;(defun post-load-stuff ()
					;  (interactive)
					;  (set-face-attribute 'default nil :font dgl-font)
					;  (menu-bar-mode -1)
					;  (maximize-frame)
					;  ;(set-cursor-color "#65D6AD")
					;  (set-foreground-color "tan")
					;  (set-background-color "#012326")
					;  (load-project-settings)
					;  )
					;
;;(defun daemon-post-load-stuff ()
;;  (interactive)
;;  (split-window-horizontally)
;;  (post-load-stuff)
;;  )
					;
;; Startup hook
					;
;;(if (daemonp)
;;    (add-hook 'server-after-make-frame-hook 'daemon-post-load-stuff t)
					;(add-hook 'window-setup-hook 'post-load-stuff t)
;;)
					;(custom-set-faces
					; ;; custom-set-faces was added by Custom.
					; ;; If you edit it by hand, you could mess it up, so be careful.
					; ;; Your init file should contain only one such instance.
					; ;; If there is more than one, they won't work right.
					; )


