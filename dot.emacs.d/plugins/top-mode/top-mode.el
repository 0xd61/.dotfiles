;;; top-mode.el --- A simple modal mode with restricted input  -*- lexical-binding: t; -*-

(require 'cl-lib)

(defvar top-mode-map (make-sparse-keymap)
  "Keymap for `top-mode`.")

;; Visuals
(defcustom top-mode-modline-background "red"
  "Modeline background when `top-mode` is active."
  :type 'color :group 'top-mode)

(defcustom top-mode-modline-foreground "white"
  "Modeline foreground when `top-mode` is active."
  :type 'color :group 'top-mode)

(defvar top-mode--prev-modeline-bg nil)
(defvar top-mode--prev-modeline-fg nil)

(defun top-mode--set-visual-indicator ()
  (let ((bg (face-background 'mode-line))
        (fg (face-foreground 'mode-line)))
    (unless top-mode--prev-modeline-bg (setq top-mode--prev-modeline-bg bg))
    (unless top-mode--prev-modeline-fg (setq top-mode--prev-modeline-fg fg)))
  (set-face-attribute 'mode-line nil :background top-mode-modline-background :foreground top-mode-modline-foreground))

(defun top-mode--unset-visual-indicator ()
  (when top-mode--prev-modeline-bg
    (set-face-attribute 'mode-line nil
                        :background top-mode--prev-modeline-bg
                        :foreground top-mode--prev-modeline-fg)
    (setq top-mode--prev-modeline-bg nil)
    (setq top-mode--prev-modeline-fg nil)))

;; Behavior Controls
(defcustom top-mode-keep-enabled-commands '(top-mode)
  "Commands that should NOT disable `top-mode`."
  :type '(repeat symbol)
  :group 'top-mode)

(defcustom top-mode-auto-exit-commands nil
  "Commands that permanently disable `top-mode`."
  :type '(repeat symbol)
  :group 'top-mode)

(defun top-mode--normalize-command (command)
  "Return the symbol representing COMMAND if recognizable.
This is needed to match against `top-mode-keep-enabled-commands` and
`top-mode-auto-exit-commands`."
  (cond
   ;; If it's already a symbol like 'find-file
   ((symbolp command)
    command)

   ;; If it's a cons cell like (lambda ...) or (top-mode . t), try to extract the symbol
   ((and (consp command)
         (symbolp (car command)))
    (car command))

   (t nil)))

(defun top-mode--around-command-execute (orig-fun command &rest args)
  "Advice around `command-execute` to manage `top-mode`."
  (let* ((cmd (top-mode--normalize-command command)))
    (cond
     ((and (bound-and-true-p top-mode)
           (memq cmd top-mode-auto-exit-commands))
      (top-mode -1)
      (apply orig-fun command args))

     ((and (bound-and-true-p top-mode)
           (not (memq cmd top-mode-keep-enabled-commands)))
      (top-mode -1)
      (unwind-protect
          (apply orig-fun command args)
        (top-mode 1)))

     (t
      (apply orig-fun command args)))))

(advice-add 'command-execute :around #'top-mode--around-command-execute)

;; Main Input Translations for x and c. Those do always exist.
(defun top-mode--enable-key-translations ()
  (define-key key-translation-map (kbd "c") (kbd "C-c"))
  (define-key key-translation-map (kbd "x") (kbd "C-x")))

(defun top-mode--disable-key-translations ()
  (define-key key-translation-map (kbd "c") nil)
  (define-key key-translation-map (kbd "x") nil))

;; Blocking all input when top-mode is active
(defvar top-mode--last-blocked-time 0)

(defun top-mode--block-typing ()
  "Block self-insert in `top-mode` with throttled warning."
  (interactive)
  (when (bound-and-true-p top-mode)
    (let ((now (float-time)))
      (when (> (- now top-mode--last-blocked-time) 1)
        (message "Typing is disabled in top-mode.")
        (setq top-mode--last-blocked-time now)))))

;; Hooks
(defvar top-mode-enable-hook nil)
(defvar top-mode-disable-hook nil)

;;;###autoload
(define-minor-mode top-mode
  "Simple modal mode: `x` becomes `C-x`, `c` becomes `C-c`. Blocks normal typing."
  :init-value nil
  :global t
  :lighter " T"

  (if top-mode
      (progn
        ;; Ensure singleton entry
        (setq emulation-mode-map-alists
              (cl-remove-if (lambda (entry)
                              (eq (car entry) 'top-mode))
                            emulation-mode-map-alists))
        (add-to-list 'emulation-mode-map-alists `((top-mode . ,top-mode-map)))

        (define-key top-mode-map [remap self-insert-command] #'top-mode--block-typing)
        (top-mode--set-visual-indicator)
        (top-mode--enable-key-translations)
        (run-hooks 'top-mode-enable-hook))

    (setq emulation-mode-map-alists
          (cl-remove-if (lambda (entry)
                          (eq (car entry) 'top-mode))
                        emulation-mode-map-alists))
    (define-key top-mode-map [remap self-insert-command] nil)
    (top-mode--unset-visual-indicator)
    (top-mode--disable-key-translations)
    (run-hooks 'top-mode-disable-hook)))

(provide 'top-mode)
