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
    )
  "List of command symbols that should disable `top-mode` when called."
  :type '(repeat symbol)
  :group 'top-mode)

(defcustom top-mode-auto-exit-commands nil
  "List of command symbols that should exit `top-mode` when called."
  :type '(repeat symbol)
  :group 'top-mode)

(defcustom top-mode-auto-disable-prefixes
  '("C-h")
  "List of key prefix strings that should disable `top-mode` when pressed."
  :type '(repeat string)
  :group 'top-mode)

(defun top-mode--prefix-match-p ()
  "Return t if the current key sequence matches any of the disable prefixes."
  (let ((keys (this-command-keys-vector)))
    (cl-some (lambda (prefix)
               (let ((prefix-keys (vconcat (kbd prefix))))
                 (and (<= (length prefix-keys) (length keys))
                      (equal prefix-keys
                             (seq-subseq keys 0 (length prefix-keys))))))
             top-mode-auto-disable-prefixes)))

(defun top-mode--around-maybe-disable (orig-fun command &rest args)
  "Around advice for `command-execute`.
Disable `top-mode` temporarily if the command is in `top-mode-auto-disable-commands`
or if the key prefix matches `top-mode-auto-disable-prefixes`.
Then re-enable after execution."
  (cond
   ;; Auto-exit: don't re-enable
   ((and (bound-and-true-p top-mode)
         (commandp command)
         (memq command top-mode-auto-exit-commands))
    (top-mode -1)
    (apply orig-fun command args))

   ;; Auto-disable + re-enable
   ((and (bound-and-true-p top-mode)
         (or (memq command top-mode-auto-disable-commands)
             (top-mode--prefix-match-p)))
    (top-mode -1)
    (unwind-protect
        (apply orig-fun command args)
      (top-mode 1)))

   ;; Normal case
   (t
    (apply orig-fun command args))))


(advice-add 'command-execute :around #'top-mode--around-maybe-disable)

(defun top-mode--enable-key-translations ()
  "Enable translations: `c` ? `C-c`, `x` ? `C-x`."
  (define-key key-translation-map (kbd "c") (kbd "C-c"))
  (define-key key-translation-map (kbd "x") (kbd "C-x")))

(defun top-mode--disable-key-translations ()
  "Disable translations set by top-mode."
  (define-key key-translation-map (kbd "c") nil)
  (define-key key-translation-map (kbd "x") nil))

;; Hooks
(defvar top-mode-enable-hook nil)
(defvar top-mode-disable-hook nil)

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
        (top-mode--enable-key-translations)
        (run-hooks 'top-mode-enable-hook))
    (setq emulation-mode-map-alists
          (cl-remove-if (lambda (entry)
                       (eq (car entry) 'top-mode))
                     emulation-mode-map-alists))
    (top-mode--unset-visual-indicator)
    (top-mode--disable-key-translations)
    (run-hooks 'top-mode-disable-hook)))

(provide 'top-mode)
