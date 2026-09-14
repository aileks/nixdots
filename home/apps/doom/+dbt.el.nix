''
  ;;; +dbt.el -*- lexical-binding: t; -*-

  (defun +dbt-project-root (&optional dir)
    "Nearest directory above DIR containing dbt_project.yml, or nil."
    (locate-dominating-file (or dir default-directory) "dbt_project.yml"))

  (defconst +dbt--jinja-functions
    (regexp-opt '("config" "env_var" "ref" "source" "var") 'words))
  (defconst +dbt--jinja-keywords
    (regexp-opt '("as" "else" "endfor" "endif" "endmacro" "for" "if" "in"
                  "macro" "set")
                'words))

  (defconst +dbt--font-lock-keywords
    `(("\\(?:{{\\|{%\\)[^}%]*?\\(\"[^\"]*\"\\|'[^']*'\\)" 1 font-lock-string-face t)
      (,(concat "{{\\s-*" +dbt--jinja-functions) 0 font-lock-function-name-face t)
      (,(concat "{%\\s-*" +dbt--jinja-keywords) 0 font-lock-keyword-face t)
      ("{#\\(?:.\\|\n\\)*?#}" 0 font-lock-comment-face t)
      ("{{\\|}}\\|{%\\|%}\\|{#\\|#}" 0 font-lock-preprocessor-face t)))

  (define-minor-mode dbt-jinja-mode
    "Minor mode for dbt SQL files: Jinja highlighting over sql-mode.
  Enabled automatically for .sql files inside a dbt project."
    :lighter " dbt"
    (if dbt-jinja-mode
        (font-lock-add-keywords nil +dbt--font-lock-keywords)
      (font-lock-remove-keywords nil +dbt--font-lock-keywords))
    (when (fboundp 'font-lock-flush)
      (font-lock-flush)))

  (defun +dbt-maybe-enable-h ()
    "Enable `dbt-jinja-mode' in .sql files inside a dbt project."
    (when (and (buffer-file-name)
               (string-match-p "\\.sql\\'" (buffer-file-name))
               (+dbt-project-root (file-name-directory (buffer-file-name))))
      (dbt-jinja-mode 1)))

  (add-hook 'sql-mode-hook #'+dbt-maybe-enable-h)
''
