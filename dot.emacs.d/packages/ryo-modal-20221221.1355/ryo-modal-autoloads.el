;;; ryo-modal-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "ryo-modal" "ryo-modal.el" (0 0 0 0))
;;; Generated autoloads from ryo-modal.el

(autoload 'ryo-modal-key "ryo-modal" "\
Bind KEY to TARGET in `ryo-modal-mode'.

TARGET can be one of:

kbd-string   Pressing KEY will simulate TARGET as a keypress.
command      Calls TARGET interactively.
list         Each element of TARGET is sent to `ryo-modal-key' again, with
             KEY as a prefix key.  ARGS are copied, except for :name.
             :name will be used by `which-key' (if installed) to name
             the prefix key.
keymap       Similarly to list, each keybinding of provided keymap
             is sent to `ryo-modal-key' again with all keyword arguments applied.
             It also works with keymap that bind other keymaps like `ctl-x-map'.
:hydra       If you have hydra installed, a new hydra will be created and
             bound to KEY.  The first element of ARGS should be a list
             containing the arguments sent to `defhydra'.
:hydra+      If you have hydra installed, this will add heads to a preexisting hydra.
             As with the `:hydra' keyword, the first element of ARGS should be a list
             containing the arguments sent to `defhydra+'.

ARGS should be of the form [:keyword option]... if TARGET is a kbd-string
or a command.  The following keywords exist:

:name        A string, naming the binding.  If ommited get name from TARGET.
:exit        If t then exit `ryo-modal-mode' after the command.
:read        If t then prompt for a string to insert after the command.
:mode        If set to a major or minor mode symbol (e.g. 'org-mode) the key will
             only be bound in that mode.
:norepeat    If t then do not become a target of `ryo-modal-repeat'.
:then        Can be a quoted list of additional commands that will be run after
             the TARGET.  These will not be shown in the name of the binding.
             (use :name to give it a nickname).
:first       Similar to :then, but is run before the TARGET.
:mc-all      If t the binding's command will be added to `mc/cmds-to-run-for-all'.
             If 0 the binding's command will be added to `mc/cmds-to-run-once'.
:properties  Take list of pairs (PROPNAME . VALUE) describing properties of TARGET symbol.

If any ARGS other han :mode, :norepeat or :mc-all are given, a
new command named ryo:<hash>:<name> will be created. This is to
make sure the name of the created command is unique.

\(fn KEY TARGET &rest ARGS)" nil nil)

(autoload 'ryo-modal-keys "ryo-modal" "\
Bind several keys in `ryo-modal-mode'.
Typically each element in ARGS should be of the form (key target [keywords]).
The target should not be quoted.
The first argument may be a list of keywords; they're applied to all keys:

  (:exit t :then '(kill-region)).

See `ryo-modal-key' for more information.

\(fn &rest ARGS)" nil t)

(autoload 'ryo-modal-major-mode-keys "ryo-modal" "\
Bind several keys in `ryo-modal-mode', but only if major mode is MODE.
ARGS is the same as `ryo-modal-keys'.

\(fn MODE &rest ARGS)" nil t)

(autoload 'ryo-modal-command-then-ryo "ryo-modal" "\
Define key BINDING to COMMAND in KEYMAP. Then activate `ryo-modal-mode'.
If COMMAND is excluded, use what is bound to right now in KEYMAP.
If KEYMAP is excluded, use `current-global-map'.

\(fn BINDING &optional COMMAND KEYMAP)" nil nil)

(autoload 'ryo-modal-set-key "ryo-modal" "\
Give KEY a binding as COMMAND in `ryo-modal-mode-map'.

This function is meant to be used interactively, if you want to
temporarily bind a key in ryo.

See `global-set-key' for more info.

\(fn KEY COMMAND)" t nil)

(autoload 'ryo-modal-unset-key "ryo-modal" "\
Remove `ryo-modal-mode-map' binding of KEY.
KEY is a string or vector representing a sequence of keystrokes.

This function is meant to unbind keys set with `ryo-modal-set-key'.

\(fn KEY)" t nil)

(autoload 'ryo-modal-bindings "ryo-modal" "\
Display a buffer of all bindings in `ryo-modal-mode'." t nil)

(autoload 'ryo-modal-mode "ryo-modal" "\
Toggle `ryo-modal-mode'.

This is a minor mode.  If called interactively, toggle the
`ryo-Modal mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `ryo-modal-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\(fn &optional ARG)" t nil)

(register-definition-prefixes "ryo-modal" '("mc/cmds-to-run-" "ryo-modal-"))

;;;***

;;;### (autoloads nil nil ("ryo-modal-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; ryo-modal-autoloads.el ends here
