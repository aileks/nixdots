''
  ;;; +sql.el -*- lexical-binding: t; -*-

  (setq sql-product 'postgres
        sql-server "127.0.0.1"
        sql-port 5432
        sql-user (user-login-name)
        sql-database (user-login-name))

  (add-hook 'sql-mode-local-vars-hook #'lsp! 'append)

  (setq lsp-sql-server-path "sql-language-server")
  (after! lsp-mode
    (add-to-list 'lsp-disabled-clients 'sqls))

  (after! flycheck
    (flycheck-define-checker sql-sqlfluff
      "SQL style and syntax checker using the sqlfluff CLI."
      :command ("sqlfluff" "lint" "--format" "json"
                "--stdin-filename" (eval (or (buffer-file-name) "scratch.sql"))
                "-")
      :standard-input t
      :error-parser
      (lambda (output checker buffer)
        (let (errors)
          (dolist (report (condition-case nil
                              (json-parse-string output :object-type 'plist
                                                 :array-type 'list
                                                 :false-object :json-false)
                            (error nil))
                          (nreverse errors))
            (dolist (violation (plist-get report :violations))
              (let ((warning (plist-get violation :warning)))
                (push (flycheck-error-new-at
                       (plist-get violation :start_line_no)
                       (plist-get violation :start_line_pos)
                       (if (eq warning :json-false) 'error 'warning)
                       (format "%s %s"
                               (plist-get violation :code)
                               (plist-get violation :description))
                       :checker checker
                       :buffer buffer
                       :id (plist-get violation :code))
                      errors))))))
      :modes sql-mode)
    (add-to-list 'flycheck-checkers 'sql-sqlfluff))

  (after! (flycheck lsp-mode)
    (defun +sql--chain-sqlfluff-h ()
      (when (and lsp--buffer-workspaces (derived-mode-p 'sql-mode))
        (flycheck-add-next-checker 'lsp 'sql-sqlfluff)))
    (add-hook 'lsp-managed-mode-hook #'+sql--chain-sqlfluff-h))

  (set-formatter! 'sqlfluff
    '("sqlfluff" "fix" "--quiet" "--stdin-filename" filepath "-")
    :modes '(sql-mode))
  (setq +format-on-save-disabled-modes
        (delq 'sql-mode +format-on-save-disabled-modes))
''
