;;;; bm-api.lisp

(in-package #:bm-api)

(annot:enable-annot-syntax)

;;; "bm-api" goes here. Hacks and glory await!

;; (invoke-rpc "{\"method\":\"stats\",\"params\":[],\"id\":\"my id\"}")

(defun bookmark-to-alist (b)
  (pairlis '(url title description source)
           `(,(bm:bookmark-url b) ,(bm:bookmark-title b)
              ,(bm:bookmark-description b) ,(bm:bookmark-source b))))

(defun all-bookmarks ()
  (concatenate 'list
               (delicious:bookmarks)
               (pocket:bookmarks bm-config:*pocket-user*)))

(defun-json-rpc list-bookmarks :guessing () (mapcar #'bookmark-to-alist (all-bookmarks)))

(defun-json-rpc stats :guessing () `(("total-bookmarks" . ,(length (all-bookmarks)))))

(defun call-rpc (request-body)
  (let ((future (make-future)))
    (finish future (invoke-rpc request-body))))

(load-plugins)

(defroute (:get "/") (req res)
  (send-response res :body "Welcome to bm-api!"))

(defroute (:post "/rpc") (req res)
  (let ((request-body (flexi-streams:octets-to-string (http-parse:http-body (request-http req)))))
    
    (format t "~a~%" request-body)
    (alet ((result (call-rpc request-body)))
          (send-response res :body result))))

@export
(defun start (port)
  (as:with-event-loop (:catch-app-errors t)
    (start-server (make-instance 'listener :port port))))
