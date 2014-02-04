;;;; Bm.lisp

(in-package #:bm)

(annot:enable-annot-syntax)

;;; "Bm" goes here. Hacks and glory await!

@export
(defstruct bookmark url title description source hash)

(defparameter *index-path* (merge-pathnames ".bm-index" (user-homedir-pathname)))
(defparameter *bm-index* nil)
(defparameter *bm-url-index* '())

(defun hash-bookmark (bookmark)
  (bookmark-url bookmark))

(defun bm-exists? (bookmark)
  (find (hash-bookmark bookmark) *bm-url-index* :test #'string=))

(defun insert-url-index (bookmark)
  (push (hash-bookmark bookmark) *bm-url-index*))

@export
(defun load-index ()
  (setf *bm-index*  (make-instance 'montezuma:index
                                   :path *index-path*
                                   :create-p nil
                                   :create-if-missing-p nil
                                   :default-field "*"
                                   :fields '("title" "url" "description" "source"))))

@export
(defun index-bookmarks ()
  (let ((index (make-instance 'montezuma:index
                              :path *index-path*
                              :create-p t
                              :min-merge-docs 5000))
        (bookmarks (concatenate 'list
                                (pocket:bookmarks bm-config:*pocket-user*)
                                (delicious:bookmarks))))
    (format t "~a bookmarks.~%" (length bookmarks))
    (loop for b in bookmarks
          do (if (bm-exists? b)
                 nil
               (progn
                 (insert-url-index b)
                 (montezuma:add-document-to-index index `(("url" . ,(bookmark-url b))
                                                          ("title" . ,(bookmark-title b))
                                                          ("source" . ,(bookmark-source b))
                                                          ("description" . ,(bookmark-description b)))))))
    (montezuma:close index)))

@export
(defun test-search (query)
  (montezuma:search-each *bm-index* query
                         #'(lambda (doc score)
                             (format t "~&doc ~S found with score ~S.~%" doc score))))

@export
(defun doc-title (doc)
  (montezuma:document-value (montezuma:get-document *bm-index* doc) "title"))

@export
(defun doc-url (doc)
  (montezuma:document-value (montezuma:get-document *bm-index* doc) "url"))

@export
(defun doc-source (doc)
  (montezuma:document-value (montezuma:get-document *bm-index* doc) "source"))

@export
(defun basic-log (doc score)
  (format t "~&Title: ~a: ~%Url: ~a~%Source: ~a~%~%"
          (doc-title doc) (doc-url doc) (doc-source doc)))

@export
(defun bm-search (query callback)
  (unless *bm-index*
    (load-index))
  (montezuma:search-each *bm-index* query
                         #'(lambda (doc score)
                             (format t "~&doc ~S found with score ~S.~%~%" doc score)
                             (funcall callback doc score))))
