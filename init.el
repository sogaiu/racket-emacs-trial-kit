;;; init.el --- emacs configuration

;;; Commentary:

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; elpaca - https://github.com/progfolio/elpaca#installer

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order
  '(elpaca :repo "https://github.com/progfolio/elpaca.git"
           :ref nil :depth 1 :inherit ignore
           :files (:defaults "elpaca-test.el" (:exclude "extensions"))
           :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process
                                 `("git" nil ,buffer t "clone"
                                   ,@(when-let* ((depth
                                                  (plist-get order :depth)))
                                       (list (format "--depth=%d" depth)
                                             "--no-single-branch"))
                                   ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process
                           emacs nil buffer nil "-Q" "-L" "." "--batch"
                           "--eval"
                           "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil))
      (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; If desired, comment out for systems which can create symlinks:
(elpaca-no-symlink-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; https://github.com/progfolio/elpaca#quick-start

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; Block until current queue processed.
(elpaca-wait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; visual perception aids

;;; monokai-theme
(use-package monokai-theme
  :ensure (:host github
           :repo "oneKelvinSmith/monokai-emacs"
           :file ("*.el"))
  :config
  (load-theme 'monokai t))

;;; rainbow-delimiters
(use-package rainbow-delimiters
  :ensure (:host github
           :repo "Fanael/rainbow-delimiters"
           :files ("*.el"))
  :config
  (custom-set-faces
   ;; XXX: doesn't seem too helpful for the unclosed case?
   ;;'(rainbow-delimiters-unmatched-face ((t (:foreground "purple"))))
   '(rainbow-delimiters-depth-1-face ((t (:foreground "dark orange"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "deep pink"))))
   '(rainbow-delimiters-depth-3-face ((t (:foreground "chartreuse"))))
   '(rainbow-delimiters-depth-4-face ((t (:foreground "deep sky blue"))))
   '(rainbow-delimiters-depth-5-face ((t (:foreground "yellow"))))
   '(rainbow-delimiters-depth-6-face ((t (:foreground "orchid"))))
   '(rainbow-delimiters-depth-7-face ((t (:foreground "spring green"))))
   '(rainbow-delimiters-depth-8-face ((t (:foreground "sienna1")))))
  (add-hook 'racket-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'racket-hash-lang-mode-hook 'rainbow-delimiters-mode))

;;; xterm-color

;; XXX: although M-x shell works better, atm don't know how
;;      to get TERM set automatically when M-x shell starts.
;;      doing it manually with `TERM=xterm-256color' (no
;;      `export' in front) does work.
;;
;; XXX: ajrepl-mode was made to work, but atm that's via
;;      changes to ajrepl.el instead of via a hook.
(use-package xterm-color
  :ensure (:host github
           :repo "atomontage/xterm-color"
           :files ("*.el"))
  :init
  (require 'xterm-color))

;; for more readable color in shell-mode
(add-hook 'shell-mode-hook
          (lambda ()
            ;; XXX: tried putting the following forms after :init
            ;;      in the `use-package' form above, but that
            ;;      gave worse results
            ;;
            ;; XXX: this did not work
            ;;(setq comint-terminfo-terminal "xterm-256color")
            ;; XXX: this did not work
            ;;(setenv "TERM" "xterm-256color")
            ;; XXX: atm am doing TERM=xterm-256color manually after
            ;;      starting M-x shell -- seems silly
            ;;
            ;; Disable font-locking in this buffer to improve performance
            (font-lock-mode -1)
            ;; Prevent font-locking from being re-enabled in this buffer
            (make-local-variable 'font-lock-function)
            (setq font-lock-function (lambda (_) nil))
            (add-hook 'comint-preoutput-filter-functions
                      'xterm-color-filter nil t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; racket-specific (mostly) things

;;; racket-mode

;; racket
(use-package racket-mode
  :ensure (:host github
           :repo "greghendershott/racket-mode"
           :file ("*.el"))
  :config
  ;; https://www.racket-mode.com/#racket_002dxp_002dmode and
  ;; https://www.racket-mode.com/#racket_002dxp_002dadd_002dbinding_002dfaces
  ;;
  ;; minor mode that analyzes expanded code to explain and explore
  (require 'racket-xp)
  ;(add-hook 'racket-mode-hook #'racket-xp-mode)
  ;; better highlighting, but a bit slow to show up - probably there's some
  ;; better cleaner way to do the following with hooks and setq-local, but
  ;; what's below works...
  (setq racket-xp-add-binding-faces t)
  ;;
  ;; racket-hash-lang-mode is experimental but has better indentation?
  (require 'racket-hash-lang)
  (add-hook 'racket-hash-lang-mode-hook #'racket-xp-mode)
  ;; XXX: may be there's a better way...hacked together by observing
  ;;      values in auto-mode-alist
  (add-to-list 'auto-mode-alist '("\\.rktl\\'" . racket-hash-lang-mode))
  (add-to-list 'auto-mode-alist '("\\.rktd\\'" . racket-hash-lang-mode))
  (add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-hash-lang-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; basic emacs settings

(setq resize-mini-windows nil)

(setq-default indent-tabs-mode nil)

(setq delete-trailing-lines nil)

;; via:
;;   https://emacsredux.com/blog/2013/04/07/ \
;;           display-visited-files-path-in-the-frame-title/
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

(column-number-mode 1)

(global-display-line-numbers-mode 1)

;; from: https://www.emacswiki.org/emacs/BasicNarrowing
(put 'narrow-to-defun 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'narrow-to-region 'disabled nil)

(show-paren-mode t)

;; don't suddenly scroll multiple lines near the top or bottom of the window
(setq scroll-conservatively 10000)

(setq inhibit-startup-screen t)

(tool-bar-mode -1)

;; prevent using ui dialogs for prompts
(setq use-dialog-box nil)

;; automatically revert buffers for changed files
(global-auto-revert-mode 1)

;; better mouse wheel scrolling
;; https://stackoverflow.com/a/26053341
(setq mouse-wheel-scroll-amount '(0.07))
;; https://stackoverflow.com/a/445881
;; (setq mouse-wheel-scroll-amount
;;       '(1 ((shift) . 1)
;;           ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

;; show point in the mode line
;;
;; thanks to dannyfreeman
(add-to-list 'mode-line-position
             '(:eval (format "[%s|%s] " (point) (position-bytes (point)))))

;; XXX: trying this out for a while
(electric-pair-mode t)

;; to avoid indenting the line one was just on when pressing RET, we
;; do the following.  this works when RET is bound to newline, which
;; checks the value of electric-indent-mode
(setq electric-indent-mode nil)

;; use C-c <LEFT> to invoke winner-undo
;; this switches back to an earlier window configuration which can be
;; used to banish windows that have opened where you don't want them
;; e.g. the *Help* buffer
(require 'winner)
;; enable
(winner-mode 1)

;; dragging file name from mode line to other programs does something
(setq mouse-drag-mode-line-buffer t)

(setq mouse-drag-and-drop-region-cross-program t)

;; scrolling display up or down at pixel resolution
(pixel-scroll-precision-mode)

;; 'overlay and 'child-frame are other alternatives
(setq show-paren-context-when-offscreen t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; satisfying emacs lisp linter

(provide 'init)
;;; init.el ends here
