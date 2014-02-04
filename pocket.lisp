;;;; pocket.lisp

(in-package #:pocket)

(annot:enable-annot-syntax)

;;; "pocket" goes here. Hacks and glory await!

(defparameter *api-url* "https://getpocket.com")

(defun client-url (path)
  (concatenate 'string *api-url* path))

(defun get-request-token (&optional state)
  (let ((url (client-url "/v3/oauth/request"))
        (params (pairlis
                 '("consumer_key" "redirect_uri")
                 (list
                  (bm-config:pocket-client-consumer-key bm-config:*pocket-client*)
                  (bm-config:pocket-client-redirect-uri bm-config:*pocket-client*)))))
    (format t "url: ~a params: ~a~%" url params)
    (multiple-value-bind (body status-code)
        (drakma:http-request url
                             :method :post
                             :parameters params)
      (if (= status-code 200)
          (second (split-sequence:split-sequence #\= (flexi-streams:octets-to-string body)))))))

(defun authorize-url (request-token)
  (let ((url (client-url "/auth/authorize")))
    (concatenate 'string url
                 "?request_token=" request-token
                 "&redirect_uri=" (bm-config:pocket-client-redirect-uri bm-config:*pocket-client*))))

(defun access-token (request-token)
  (let ((url (client-url "/v3/oauth/authorize"))
        (params (pairlis
                 '("consumer_key" "code")
                 (list (bm-config:pocket-client-consumer-key bm-config:*pocket-client*) request-token))))
    (format t "url: ~a params: ~a~%" url params)
    (multiple-value-bind (body status-code)
        (drakma:http-request url
                             :method :post
                             :parameters params)
      (if (= status-code 200)
          (let* ((params-list (split-sequence:split-sequence #\& (flexi-streams:octets-to-string body)))
                 (params (mapcar #'(lambda (p) (let ((tokens (split-sequence:split-sequence #\= p)))
                                                 (last tokens)))
                                 params-list))
                 (username (car (second params)))
                 (access-token (car (first params))))
            (describe (first params))
            (make-user :username username :access-token access-token))
          body))))


(defun client-request (user path &optional params &key (method :get))
  (let ((url (client-url path)))
    (multiple-value-bind (body status-code)
        (drakma:http-request (concatenate 'string url
                                          "?consumer_key=" (bm-config:pocket-client-consumer-key bm-config:*pocket-client*)
                                          "&access_token=" (bm-config:pocket-user-access-token user))
                             :method method
                             :parameters params)
      (if (= status-code 200)
          (flexi-streams:octets-to-string body)))))

@export
(defun bookmarks (user)
  (let* ((response (client-request user "/v3/get"))
         (parsed (json:decode-json-from-string response))
         (bookmarks '()))
    (loop for b in (cdr (assoc ':list parsed))
       do (let ((url (cdr (assoc ':resolved--url (cdr b))))
                (title (cdr (assoc ':resolved--title (cdr b))))
                (desc (cdr (assoc ':excerpt (cdr b)))))
            (push (bm:make-bookmark :url url :title title :description desc :source ':pocket) bookmarks)))
    bookmarks))

