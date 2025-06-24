#lang racket

(define emacs-path
  (find-executable-path "emacs"))

(system* emacs-path "--init-directory=.")

