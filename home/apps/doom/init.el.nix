''
  ;;; init.el -*- lexical-binding: t; -*-

  (defvar evil-respect-visual-line-mode t)

  (doom!
   :completion
   (corfu +orderless +icons)
   vertico

   :ui
   doom
   dashboard
   doom-quit
   hl-todo
   indent-guides
   modeline
   nav-flash
   ophints
   (popup +defaults)
   (vc-gutter +pretty)
   vi-tilde-fringe
   window-select
   workspaces

   :editor
   (evil +everywhere)
   file-templates
   fold
   (format +onsave)
   multiple-cursors
   snippets
   word-wrap

   :emacs
   (dired +icons)
   electric
   ibuffer
   tramp
   undo
   vc

   :term
   vterm

   :checkers
   syntax

   :tools
   editorconfig
   (eval +overlay)
   lookup
   lsp
   magit
   tree-sitter

   :lang
   emacs-lisp
   (cc +lsp +tree-sitter)
   (json +lsp +tree-sitter)
   (lua +lsp +tree-sitter)
   markdown
   org
   (python +lsp +pyright +tree-sitter +uv)
   (sh +lsp)
   (yaml +lsp +tree-sitter)
   (zig +lsp +tree-sitter)

   :config
   (default +bindings +smartparens))
''
