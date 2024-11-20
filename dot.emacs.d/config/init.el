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

(setq user-full-name       "Daniel Glinka"
      user-real-login-name "Daniel Glinka"
      user-login-name      "dgl"

(setq visible-bell t)

(setq x-stretch-cursor t)

(with-eval-after-load 'mule-util
 (setq truncate-string-ellipsis "…"))

(defvar dgl/default-font-size 110
  "Default font size.")

(defvar dgl/default-font-name "InputMono"
  "Default font.")

(defun my/set-font ()
  (when (find-font (font-spec :name dgl/default-font-name))
    (set-face-attribute 'default nil
                        :font dgl/default-font-name
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
