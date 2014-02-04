;;;; bm-config.lisp

(in-package #:bm-config)

(annot:enable-annot-syntax)

;;; "bm-config" goes here. Hacks and glory await!

;; Delicious configuration
@export
(defvar *delicious-user* '())

@export
(defun set-delicious-credentials (username password)
  (setq *delicious-user* (pairlis '(:username :password)
                         (list username password))))

;; Pocket configuration.
@export
(defstruct pocket-client consumer-key redirect-uri access-token)

@export
(defstruct pocket-user username access-token)

@export
(defvar *pocket-client* nil)

@export
(defvar *pocket-user* nil)
