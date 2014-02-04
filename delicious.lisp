;;;; delicious.lisp

(in-package #:delicious)

(annot:enable-annot-syntax)

;;; "delicious" goes here. Hacks and glory await!

(defparameter *api* "https://api.delicious.com/v1")

(defun username ()
  (cdr (assoc ':username bm-config:*delicious-user*)))

(defun password ()
  (cdr (assoc ':password bm-config:*delicious-user*)))

(defun api-url (path)
  (concatenate 'string *api* path))

(defun api-request (path)
  (let ((url (api-url path))
        (basic-auth (list (username) (password))))
    (multiple-value-bind (body status-code)
        (drakma:http-request url :basic-authorization basic-auth)
      (if (= status-code 200)
          body))))

(defun post-prop (post key)
  (multiple-value-bind (key val tail)
      (get-properties (rest (first post)) (list key))
    (if tail
        val)))

(defun posts-all ()
  (let ((response (api-request "/posts/all")))
    (s-xml:parse-xml-string response)))

@export
(defun bookmarks ()
  (let ((posts (posts-all))
        (bm '()))
    (if posts
        (loop for post in (cdr posts)
           do (let ((href (post-prop post ':|href|))
                    (desc (post-prop post ':|extended|))
                    (title (post-prop post ':|description|)))
                (push (bm:make-bookmark :url href :title title :description desc :source ':delicious) bm))))
    bm))

