;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
(projectile-add-known-project "/home/kaitsh/Code/src/gitlab.com/samuu.dev/piari")


(setq-default evil-shift-width 2 ;; set tabs to 2
      tab-width 2)

(add-hook 'prog-mode-hook #'goto-address-mode) ;; Linkify links!

(after! web-mode
  (add-hook 'web-mode-hook #'flycheck-mode)

  (setq web-mode-markup-indent-offset 2 ;; Indentation
        web-mode-code-indent-offset 2
        web-mode-enable-auto-quoting nil ;; disbale adding "" after an =
        web-mode-auto-close-style 2))

(load! "+ui")
(load! "+org")
