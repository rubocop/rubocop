;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((ruby-mode
  (bug-reference-url-format . "https://github.com/rubocop/rubocop/issues/%s")
  (bug-reference-bug-regexp . "#\\(?2:[[:digit:]]+\\)")
  (indent-tabs-mode . nil)
  (fill-column . 100)
  (whitespace-line-column 100)))

;; To use the bug-reference stuff, do:
;;     (add-hook 'text-mode-hook #'bug-reference-mode)
;;     (add-hook 'prog-mode-hook #'bug-reference-prog-mode)
