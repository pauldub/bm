;;;; Bm.asd

(asdf:defsystem #:bm
  :serial t
  :description "Describe Bm here"
  :author "Paul d'Hubert"
  :license "MIT"
  :depends-on (:cl-annot :drakma  :cl-async :cl-async-future
                         :simple-date-time :s-xml :iterate
                         :split-sequence :cl-json :montezuma
                         :wookie)
  :components ((:file "package")
               (:file "bm-config")
               (:file "delicious")
               (:file "pocket")
               (:file "bm")
               (:file "bm-api")))

