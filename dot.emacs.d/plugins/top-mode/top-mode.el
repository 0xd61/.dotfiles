(require 'cl-lib)

(defvar top-mode-map (make-sparse-keymap)
  "Keymap for `top-mode`.")

(defvar top-mode--original-map nil
  "Backup of the original `emulation-mode-map-alists` entry for `top-mode`.")

;; Color indicator
(defvar top-mode--prev-modeline-bg nil
  "Stores the previous modeline background color.")

(defvar top-mode--prev-modeline-fg nil
  "Stores the previous modeline foreground color.")

(defvar top-mode--prev-border-color nil
  "Stores the previous GUI border color.")

(defvar top-mode--prev-border-width nil
  "Stores the previous GUI border width.")

(defun top-mode--set-visual-indicator ()
  "Set red visual indicators (modeline and border) for top-mode."
  ;; Save modeline face colors
  (let ((bg (face-background 'mode-line))
        (fg (face-foreground 'mode-line)))
    (unless top-mode--prev-modeline-bg (setq top-mode--prev-modeline-bg bg))
    (unless top-mode--prev-modeline-fg (setq top-mode--prev-modeline-fg fg)))
  (set-face-attribute 'mode-line nil :background "red" :foreground "white")
  (force-mode-line-update t)
  (when (display-graphic-p)
    (setq top-mode--prev-border-color (frame-parameter nil 'internal-border-color))
    (setq top-mode--prev-border-width (frame-parameter nil 'internal-border-width))
    (set-frame-parameter nil 'internal-border-color "red")
    (set-frame-parameter nil 'internal-border-width 5)))

(defun top-mode--unset-visual-indicator ()
  "Restore modeline and GUI border colors after disabling top-mode."
  (when top-mode--prev-modeline-bg
    (set-face-attribute 'mode-line nil
                        :background top-mode--prev-modeline-bg
                        :foreground top-mode--prev-modeline-fg)
    (setq top-mode--prev-modeline-bg nil)
    (setq top-mode--prev-modeline-fg nil))
  (force-mode-line-update t)
  (when (display-graphic-p)
    (when top-mode--prev-border-color
      (set-frame-parameter nil 'internal-border-color top-mode--prev-border-color)
      (setq top-mode--prev-border-color nil))
    (when top-mode--prev-border-width
      (set-frame-parameter nil 'internal-border-width top-mode--prev-border-width)
      (setq top-mode--prev-border-width nil))))

(defcustom top-mode-auto-disable-commands
  '(execute-extended-command
    find-file
    switch-to-buffer
    describe-bindings
    describe-buffer
    describe-categories
    describe-char
    describe-character-set
    describe-command
    describe-coding-system
    describe-copying
    describe-distribution
    describe-face
    describe-file
    describe-fontset
    describe-function
    describe-function-1
    describe-gnu-project
    describe-input-method
    describe-key
    describe-key-briefly
    describe-keymap
    describe-language-environment
    describe-mode
    describe-no-warranty
    describe-package
    describe-prefix-bindings
    describe-repeat-maps
    describe-symbol
    describe-syntax
    describe-text-properties
    describe-theme
    describe-variable
    )
  "List of command symbols that should disable `top-mode` when called."
  :type '(repeat symbol)
  :group 'top-mode)

(defcustom top-mode-auto-exit-commands nil
  "List of command symbols that should exit `top-mode` when called."
  :type '(repeat symbol)
  :group 'top-mode)

(defun top-mode--around-maybe-disable (orig-fun &rest args)
  "Around advice for `call-interactively`.
Disable `top-mode` if command is in `top-mode-auto-disable-commands`,
then re-enable it after the command finishes."
  (if (and (bound-and-true-p top-mode)
           (commandp this-command)
           (memq this-command top-mode-auto-disable-commands))
      (progn
        (top-mode -1)
        (unwind-protect
            (apply orig-fun args)
          (top-mode 1)))
    (apply orig-fun args)))

(defun top-mode--maybe-exit (orig-fun &rest args)
  "Around advice for `call-interactively`.
Disable `top-mode` if command is in `top-mode-auto-exit-commands`."
(when (and (bound-and-true-p top-mode)
             (commandp this-command)
             (memq this-command top-mode-auto-exit-commands))
    (top-mode -1)))

(advice-add 'call-interactively :around #'top-mode--around-maybe-disable)
(advice-add 'call-interactively :before #'top-mode--maybe-exit)

;;;###autoload
(define-minor-mode top-mode
  "A simple custom modal mode. `x` replaces `C-x` and `c` replaces `C-c`. Everything else
can be defined in the top-mode-map."
  :init-value nil
  :global t
  :lighter " T"

  (if top-mode
      (let ((entry (assoc 'top-mode emulation-mode-map-alists)))
        (unless entry
          (add-to-list 'emulation-mode-map-alists
                       `((top-mode . ,top-mode-map))))
        (top-mode--set-visual-indicator))
    (setq emulation-mode-map-alists
          (cl-remove-if (lambda (entry)
                       (eq (car entry) 'top-mode))
                     emulation-mode-map-alists))
    (top-mode--unset-visual-indicator)))

(provide 'top-mode)
