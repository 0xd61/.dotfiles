;;;  -*- lexical-binding: t; -*-

(setq +todo-file "~/org/inbox.org")

(after! org
  (setq org-agenda-files '("~/org/inbox.org"
                          "~/org/gtd.org"
                          "~/org/tickler.org"))


  (setq org-capture-templates '(("t" "Todo [inbox]" entry
                                (file+headline "~/org/inbox.org" "Tasks")
                                "* TODO %i%? \n %a")
                                ("T" "Tickler" entry
                                (file+headline "~/org/tickler.org" "Tickler")
                                "* %i%? \n %U \n %a")
                                ("n" "Note" entry
                                (file "~/org/notes.org")
                                "* %i%? \n %a")))

  (setq org-refile-targets '(("~/org/gtd.org" :maxlevel . 3)
                            ("~/org/someday.org" :level . 1)
                            ("~/org/notes.org" :maxlevel . 2)
                            ("~/org/tickler.org" :maxlevel . 2)))

  ;; timer
  (setq org-clock-idle-time 5)

  ;; show refile targets simultaneously
  (setq org-outline-path-complete-in-steps nil)
;; use full outline paths for refile targets
  (setq org-refile-use-outline-path 'file)
  ;; allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  (setq org-todo-keywords '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))

  (map! :map evil-org-mode-map
        :localleader
        :desc "Toggle Archive Tag" "a" #'org-toggle-archive-tag
        :desc "Archive Subtree" "A" #'org-archive-subtree-default-with-confirmation
        :desc "Create/Edit Todo" "o" #'org-todo
        :desc "Schedule" "s" #'org-schedule
        :desc "Deadline" "d" #'org-deadline
        :desc "Refile" "r" #'org-refile
        :desc "Filter" "f" #'org-match-sparse-tree
        :desc "Tag heading" "t" #'org-set-tags-command
        (:prefix "c"
          :desc "Create Report about clocked time" "r" #'org-clock-report
          ))



  ;; Normally its only like 3 lines tall, too hard to see anything.
  (set-popup-rule! "^\\*Org Agenda"
    :size 15
    :quit t
    :select t
    :parameters
    '((transient))))

;; org-match-sparse-tree
;; org-set-tags-command
(defun +open-todo-file ()
  (interactive)
  "Opens the todo file"
  (find-file +todo-file))

(map! :leader
        :desc "Open todo file" "O" #'+open-todo-file)
