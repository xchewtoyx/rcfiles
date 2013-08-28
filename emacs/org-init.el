;;
;; Requires
;;
(require 'org-install)
(require 'org-mobile)


;;
;; Variable Assignments
;;
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(setq org-directory "~/org")
(setq org-agenda-todo-list-sublevels t)
(setq org-agenda-sorting-strategy
      '((agenda habit-down time-up priority-down todo-state-down category-keep)
	(todo priority-down todo-state-down category-keep)
	(tags priority-down todo-state-down category-keep)
	(search category-keep)))
(setq org-archive-location (concat org-directory "/archive/%s_done::"))
(setq org-default-notes-file (concat org-directory "/notes.org"))
(setq org-log-done 'time)
(setq org-mobile-directory "~/Dropbox/data/org-mobile/")
(setq org-refile-targets '((nil :maxlevel . 9)
			   (org-agenda-files :tag . "TASKLIST")
			   (org-agenda-files :tag . "PROJECT")
			   (org-agenda-files :tag . "NOTES")))
(setq org-stuck-projects '("TODO={.+}/-DONE" nil nil "SCHEDULED:\\|DEADLINE:"))
(setq org-tag-alist '(("OFFICE" . ?o) ("HOME" . ?h) 
		      ("MOBILE" . ?m) ("REFILE" . ?r)))
(setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
			  (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" 
				    "CANCELLED(c@/!)" "PHONE")))
(setq org-tags-exclude-from-inheritance (list "TASKLIST" "PROJECT"))


;;
;; Functions
;;
(defvar org-mobile-push-timer nil
  "Timer that `org-mobile-push-timer' used to reschedule itself, or nil.")

(defun org-mobile-push-with-delay (secs)
  (when org-mobile-push-timer
    (cancel-timer org-mobile-push-timer))
  (setq org-mobile-push-timer
        (run-with-idle-timer
         (* 1 secs) nil 'org-mobile-push)))

(defun install-monitor (file secs)
  (run-with-timer
   0 secs
   (lambda (f p)
     (unless (< p (second (time-since (elt (file-attributes f) 5))))
       (org-mobile-pull)))
   file secs))


;;
;; Hooks
;;
(add-hook 'org-mode-hook 'turn-on-font-lock)
(add-hook 'org-mode-hook 'auto-fill-mode)
(add-hook 'remember-mode-hook 'org-remember-apply-template)
(add-hook 'after-save-hook 
 (lambda () 
   (when (eq major-mode 'org-mode)
     (dolist (file (org-mobile-files-alist))
       (if (string= (expand-file-name (car file)) (buffer-file-name))
           (org-mobile-push-with-delay 30)))
   )))

(run-at-time "00:05" 86400 '(lambda () (org-mobile-push-with-delay 1))) ;; refreshes agenda file each day

(install-monitor (file-truename
                  (concat
                   (file-name-as-directory org-mobile-directory)
                          org-mobile-capture-file))
                 5)

;; Do a pull every 5 minutes to circumvent problems with timestamping
;; (ie. dropbox bugs)
(run-with-timer 0 (* 5 60) 'org-mobile-pull)

;;
;; Keybindings
;;
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

;;;;;;;;;;;;;;;;;;;;;
;; Here be dragons ;;
;;;;;;;;;;;;;;;;;;;;;

(org-mobile-pull) ;; run org-mobile-pull at startup

