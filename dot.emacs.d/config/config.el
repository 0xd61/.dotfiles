:bind (
         ("M-G s" . 'magit-status)
         ("M-G b" . 'magit-blame)
         ("M-G d" . 'magit-diff)
         :map magit-mode-map
         ("C-q" . 'magit-copy-buffer-revision)
         <<emacs-keys-essential>>
         )
