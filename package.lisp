;;;; package.lisp

(defpackage #:bm
  (:use #:cl)
  (:export :make-bookmark
           :bookmark-url
           :bookmark-title
           :bookmark-description
           :bookmark-source))

(defpackage #:bm-api
  (:use #:cl #:json-rpc #:wookie #:cl-async-future))

(defpackage #:bm-config
  (:use #:cl )
  (:export :pocket-client-consumer-key
           :pocket-client-redirect-uri
           :pocket-user-access-token
           :make-pocket-client
           :make-pocket-user))

(defpackage #:delicious
  (:use #:cl ))

(defpackage #:pocket
  (:use #:cl)
  (:export :make-pocket-client
           :make-pocket-user))
