(require 'cl-lib)

(defvar top-mode-map (make-sparse-keymap)
  "Keymap for `top-mode`.")

(defvar top-mode--original-map nil
  "Backup of the original `emulation-mode-map-alists` entry for `top-mode`.")

;; Color indicator
(defcustom top-mode-modline-background "red"
  "Modline background color when `top-mode` is active."
  :type 'color
  :group 'top-mode)

(defcustom top-mode-modline-foreground "white"
  "Modline foreground color when `top-mode` is active."
  :type 'color
  :group 'top-mode)

(defvar top-mode--prev-modeline-bg nil
  "Stores the previous modeline background color.")

(defvar top-mode--prev-modeline-fg nil
  "Stores the previous modeline foreground color.")

(defun top-mode--set-visual-indicator ()
  "Set red visual indicators (modeline and border) for top-mode."
  ;; Save modeline face colors
  (let ((bg (face-background 'mode-line))
        (fg (face-foreground 'mode-line)))
    (unless top-mode--prev-modeline-bg (setq top-mode--prev-modeline-bg bg))
    (unless top-mode--prev-modeline-fg (setq top-mode--prev-modeline-fg fg)))
  (set-face-attribute 'mode-line nil :background top-mode-modline-background :foreground top-mode-modline-foreground))

(defun top-mode--unset-visual-indicator ()
  "Restore modeline and GUI border colors after disabling top-mode."
  (when top-mode--prev-modeline-bg
    (set-face-attribute 'mode-line nil
                        :background top-mode--prev-modeline-bg
                        :foreground top-mode--prev-modeline-fg)
    (setq top-mode--prev-modeline-bg nil)
    (setq top-mode--prev-modeline-fg nil)))

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

(defun top-mode--around-maybe-disable (orig-fun command &rest args)
  "Around advice for `call-interactively`.
Disable `top-mode` if command is in `top-mode-auto-disable-commands`,
then re-enable it after the command finishes."
  (if (and (bound-and-true-p top-mode)
           (memq command top-mode-auto-disable-commands))
      (progn
        (top-mode -1)
        (unwind-protect
            (apply orig-fun command args)
          (top-mode 1)))
    (apply orig-fun command args)))

(defun top-mode--maybe-exit (command &rest args)
  "Around advice for `call-interactively`.
Disable `top-mode` if command is in `top-mode-auto-exit-commands`."
(when (and (bound-and-true-p top-mode)
             (memq command top-mode-auto-exit-commands))
    (top-mode -1)))

(advice-add 'command-execute :around #'top-mode--around-maybe-disable)
(advice-add 'command-execute :before #'top-mode--maybe-exit)

(defun top-mode--enable-key-translations ()
  "Enable translations: `c` ? `C-c`, `x` ? `C-x`."
  (define-key key-translation-map (kbd "c") (kbd "C-c"))
  (define-key key-translation-map (kbd "x") (kbd "C-x")))

(defun top-mode--disable-key-translations ()
  "Disable translations set by top-mode."
  (define-key key-translation-map (kbd "c") nil)
  (define-key key-translation-map (kbd "x") nil))

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
        (top-mode--set-visual-indicator)
        (top-mode--enable-key-translations))
    (setq emulation-mode-map-alists
          (cl-remove-if (lambda (entry)
                       (eq (car entry) 'top-mode))
                     emulation-mode-map-alists))
    (top-mode--unset-visual-indicator)
    (top-mode--disable-key-translations)))

(provide 'top-mode)
