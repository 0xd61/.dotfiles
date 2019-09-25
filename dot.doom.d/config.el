;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

(setq-default evil-shift-width 2 ;; set tabs to 2
      tab-width 2)

(setq user-mail-address "kaitsh@d-git.de"
      user-full-name "Daniel Glinka")

(add-hook 'prog-mode-hook #'goto-address-mode) ;; Linkify links!

;; Load snippets
(after! yasnippet
  (push (expand-file-name "snippets/" doom-private-dir) yas-snippet-dirs))

(setq company-idle-delay 0.1)

(after! web-mode
  (add-hook 'web-mode-hook #'flycheck-mode)

  (setq web-mode-markup-indent-offset 2 ;; Indentation
        web-mode-code-indent-offset 2
        web-mode-enable-auto-quoting nil ;; disbale adding "" after an =
        web-mode-auto-close-style 2))

(map! :leader
     :prefix "c"
     "j" (λ!! #'avy-goto-char-timer t)
     )


(load! "+ui")
(load! "+org")
(load! "+keycast") ;; Keycast module written by our favourite flying meatball
