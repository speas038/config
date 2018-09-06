(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(c-comment-only-line-offset (quote set-from-style))
 '(c-default-style
   (quote
    ((c-mode . "linux")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu"))))
 '(column-number-mode t)
 '(custom-enabled-themes (quote (tango-dark)))
 '(fortran-minimum-statement-indent-tab 8)
 '(global-ede-mode t)
 '(indent-tabs-mode nil)
 '(show-paren-mode t)
 '(tab-width 4))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq-default indent-tabs-mode nil)
(setq tab-width 4) ; or any other preferred value
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)


(setq tags-table-list
      '("/home/alex/magicwand-commsbackbone/TAGS" "/usr/src/linux-headers-4.4.0-81-generic/TAGS"))

;;Prevents large file warning every time I try to
;;Open TAGS file
(setq large-file-warning-threshold nil)

;;Default show line numbers in margin
(global-linum-mode 1)

;;turn off version control handling
;;I'll do it myself thank you very much
(setq vc-handled-backends nil)

;;shows the name of the function that contains the
;;cursor
(setq which-function-mode 1)

;;Speaks for itself annoying as heck getting the
;;startup screen every time
(setq inhibit-startup-screen t)

;; start speedbar if we're using a window system
;;(require 'speedbar)
;;(when window-system (speedbar 1))
;;(speedbar 1)
(speedbar)

;; (defun sb-expand-curren-file ()
;;"Expand current file in speedbar buffer"  
;; (interactive) 
;;  (setq current-file (buffer-file-name))
;;  (speedbar-refresh)
;;  (speedbar-find-selected-file current-file)
;;  (speedbar-expand-line))

;;(add-hook 'focus-in-hook 'sb-expand-curren-file)

;;TODO worth messing with, just not now
;(add-to-list 'load-path "~/.emacs.d/lisp/")
;(require 'sr-speedbar)
;(sr-speedbar-open)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

(setq scroll-conservatively 101)

(desktop-save-mode 1)

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.emacs.d/.
(custom-set-variables
   '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
     '(backup-directory-alist '((".*" . "~/.emacs.d/backups/"))))

;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.emacs.d/autosaves/" t)

(which-function-mode 1)

(setq tramp-default-method "ssh")
