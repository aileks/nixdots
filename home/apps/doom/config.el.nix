''
  ;;; config.el -*- lexical-binding: t; -*-

  (add-to-list 'default-frame-alist '(alpha-background . 95))

  (setq org-directory "~/org")

  (setq doom-theme 'cinder-grove
        cg-transparent t
        doom-font (font-spec :family "Iosevka Nerd Font" :size 20))

  (when-let* ((theme-file (locate-library "cinder-grove-theme.el")))
    (add-to-list 'custom-theme-load-path (file-name-directory theme-file)))

  (after! solaire-mode (solaire-global-mode -1))

  (setq display-line-numbers-type 'relative
        scroll-margin 8
        make-backup-files t
        confirm-kill-emacs #'y-or-n-p)

  (setq-default truncate-lines nil)

  (setq lsp-enable-suggest-server-download nil
        treesit-auto-install-grammar nil)

  (after! corfu
    (setq corfu-count 10))

  (after! evil-escape
    (setq evil-escape-key-sequence "jk"
          evil-escape-delay 0.15))

  (load! "+bindings")
  (load! "+org")
  (load! "+sql")
  (load! "+dbt")
  (load! "+lang-extras")
  (load! "+tasks")
''
