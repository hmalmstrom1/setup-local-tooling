 ;;; package --- .emacs
;;; Commentary:
;; This is my .emacs configuration
;;; Code:
;; (setq max-lisp-eval-depth 1000000)
(setq max-specpdl-size 50000)
(set-charset-priority 'unicode)
;; it's utf-8 bitches!
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))
(set-language-environment "UTF-8")
;; (set-default-coding-system 'utf-8)
;; set garbage collection high so we aren't thrashing all the time
(setq gc-cons-threshold 100000000)
;; 1mb read process output max
(setq read-process-output-max (* 1024 1024))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))


(setq straight-vc-git-default-clone-depth 1)

;; bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
      (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
        "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
        'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))	;

(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))
(package-read-all-archive-contents)
(unless package-archive-contents
  (package-refresh-contents))

(package-install 'corfu-terminal)
(package-activate 'corfu-terminal)

(require 'straight)


;; Look and feel
(tool-bar-mode -1)      ;; disable the tool-bar
(toggle-scroll-bar -1)  ;; disable the scrollbar
(menu-bar-mode -1)      ;; disable the menu
(visual-line-mode 1)    ;; turn on current line number in bottom bar
(column-number-mode 1)  ;; turn on current column index in bottom bar
(set-fringe-mode 20)    ;; give us some empty space on the fringe

;;;;;;;;;;;
;; Fonts ;;
;;;;;;;;;;;
(set-face-attribute 'default nil
		    :font "RobotoMono Nerd Font"
		    :height 140)
(set-face-attribute 'fixed-pitch nil
		    :font "RobotoMono Nerd Font"
		    :height 140)
(set-face-attribute 'variable-pitch nil
		    :font "Fira Sans Condensed"
		    :height 165
		    :weight 'regular)

;; ligature support in every major mode
;; (ligature-set-ligatures 't '("www"))
;; enable ligature support in programming modes


(defun efs/org-font-setup ()
  "Setup our fonts."
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cabin" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch))


;; set initial default window settings
(setq inhibit-splash-screen t
      initial-scratch-message nil
      initial-major-mode 'org-mode)

(global-hl-line-mode +1)


;; Save customize settings
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)


(use-package org
  :straight t
  :after (ob-typescript ob-rust ob-sql-mode)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (require 'ob-sql-mode)
  (require 'ob-shell)
  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
  (setq org-edit-src-content-indentation 0)
  (setq org-ellipsis " ⌄")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
;;  (setq org-agenda-files
;;	'("~/Dropbox/Documents/Orgzly/Tasks.org"))
  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  ;;  (setq orghabit-graph-column 60)
  
  (setq org-todo-keywords
	'((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
	  (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))
  (setq org-refile-targets
	'(("Archive.org" :maxlevel . 1)
	  ("Task.org" :maxlevel . 1)))
  (setq org-tag-alist
	'((:startgroup)
	  (:endgroup)
	  ("@errand" . ?E)
	  ("@home" . ?H)
	  ("@work" . ?W)
	  ("agenda" . ?a)
	  ("planning" . ?p)
	  ("publish" . ?P)
	  ("batch" . ?b)
	  ("note" . ?n)
	  ("idea" . ?i)))
  (setq org-agenda-custom-commands
	'(("d" "Dashboard"
	   ((agenda "" ((org-deadline-warning-days 7)))
	    (todo "NEXT"
		  ((org-agenda-overriding-header "Next Tasks")))
	    (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))
	  ("n" "Next Tasks"
	   ((todo "NEXT"
		  ((org-agenda-overriding-header "Next Tasks")))))
	  ("W" "Work Tasks" tags-todo "+work-email")
	  ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
	   ((org-agenda-overriding-header "Low Effort Tasks")
	    (org-agenda-max-todos 20)
	    (org-agenda-files org-agenda-files)))
	  ("w" "Workflow Status"
	   ((todo "WAIT"
		  ((org-agenda-overriding-header "Waiting on External")
		   (org-agenda-files org-agenda-files)))
	    (todo "REVIEW"
		  ((org-agenda-overriding-header "In Review")
		   (org-agenda-files org-agenda-files)))
	    (todo "PLAN"
		  ((org-agenda-overriding-header "In Planning")
		   (org-agenda-todo-list-sublevels nil)
		   (org-agenda-files org-agenda-files)))
	    (todo "BACKLOG"
		  ((org-agenda-overriding-header "Project Backlog")
		   (org-agenda-todo-list-sublevels nil)
		   (org-agenda-files org-agenda-files)))
	    (todo "READY"
		  ((org-agenda-overriding-header "Ready for Work")
		   (org-agenda-files org-agenda-files)))
	    (todo "ACTIVE"
		  ((org-agenda-overriding-header "Active Projects")
		   (org-agenda-files org-agenda-files)))
	    (todo "COMPLETED"
		  ((org-agenda-overriding-header "Completed Projects")
		   (org-agenda-files org-agenda-files)))
	    (todo "CANC"
		  ((org-agenda-overriding-header "Cancelled Projects")
		   (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
	`(("t" "Tasks / Projects")
	  ("tt" "Task" entry (file+olp "~/Documents/Agenda/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

	  ("j" "Journal Entries")
	  ("jj" "Journal" entry
           (file+olp+datetree "~/Documents/Org/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
	  ("jm" "Meeting" entry
           (file+olp+datetree "~/Documents/Org/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

	  ("w" "Workflows")
	  ("we" "Checking Email" entry (file+olp+datetree "~/Documents/Org/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

	  ("m" "Metrics Capture")
	  ("mw" "Weight" table-line (file+headline "~/Documents/Org/Metrics.org" "Weight")
	   "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))
  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (efs/org-font-setup)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (js . t)
     (typescript . t)
     (sql . t)
     (plantuml . t)
     (rust . t)
     (shell . t)))
  )


(use-package all-the-icons
  :straight t)
(use-package all-the-icons-ibuffer
  :straight t
  :init (all-the-icons-ibuffer-mode 1))




(use-package neotree
  :straight t)

(use-package doom-themes
  :straight t
  :init
  (load "~/.emacs.d/kanagawa-theme.el")
  (load-theme 'kanagawa t)

;;   (load-theme 'doom-moonlight t)
  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
)

(use-package doom-modeline
  :ensure t
  :straight t
  :custom
  (setq doom-modeline-height 18)
  (setq doom-modeline-bar-width 4)
  (setq doom-modeline-bar t)
  (setq doom-modeline-hud t)
  (setq doom-modeline-project-detection 'project)
  (setq doom-modeline-major-mode-color-icon t)
  (setq doom-modeline-major-mode-icon t)
;;  (setq doom-modeline-lsp t)
  :hook
  (after-init . doom-modeline-mode)
)

;; (use-package nano-modeline)
;; (nano-modeline-mode)

(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :straight t
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))


;; spell checking
(setq ispell-dictionary "american")

(defun my-american-dict ()
  "Change dictionary to american."
  (interactive)
  (setq ispell-local-dictionary "american")
  (flyspell-mode 1)
  (flyspell-buffer))

(defalias 'ir #'ispell-region)

;; helper functions and completion
;; (use-package projectile
;;   :straight t
;;   :diminish projectile
;;   )

(use-package flycheck-plantuml
  :straight t)

(use-package flycheck
  :straight t
  :after flycheck-plantuml
  :config
  (require 'flycheck-plantuml)
  (flycheck-plantuml-setup))


(use-package yasnippet
  :straight t
  :config (yas-global-mode))

(use-package olivetti
  :straight t
  :init
  (setq olivetti-body-width 80)
  (setq olivetti-style 'fancy)
  (setq olivetti-minimum-body-width 50))

(use-package solaire-mode
  :straight t
  :config
  (solaire-global-mode +1))

(use-package org-bullets
  ;; :if (not rune/is-termux)
  :straight t
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package ob-rust
  :after (rustic)
  :straight t)

(use-package ob-typescript
  :straight t)


(use-package emojify
  :straight t
  :hook (erc-mode . emojify-mode)
  :commands emojify-mode)

(use-package hydra
  :straight t)


(use-package company
  :straight t
  :ensure t
  :config
  (setq company-idle-delay 0.5  ;; delay to wait for popup call
        company-minimum-prefix-length 1)
  (global-company-mode t)
  :bind
  (:map company-active-map
	("<tab>" . company-complete-selection)
	("C-n" . company-select-next)
	("C-p" . company-select-previous)
	("M-<" . company-select-first)
	("M->" . company-select-last))
;;  (:map lsp-mode-map
  ;;	("<tab>" . company-indent-or-complete-common))
)



(use-package company-box
  :straight t
  :hook (company-mode . company-box-mode))


(use-package rustic
  :straight t
  :ensure
  :init
  (setq rustic-lsp-server 'rust-analyzer)
;;  :bind (:map rustic-mode-map
;;	      ("M-j" . lsp-ui-imenu)
;;	      ("M-?" . lsp-find-references)
;;	      ("C-c C-c l" . flycheck-list-errors)
	      ;; ("C-c C-c a" . lsp-execute-code-action)
	      ;; ("C-c C-c r" . lsp-rename)
	      ;; ("C-c C-c q" . lsp-workspace-restart)
	      ;; ("C-c C-c Q" . lsp-workspace-shutdown)
	      ;; ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(defun rk/rustic-mode-hook ()
  "So that run save works without having to confirm."
  (when buffer-file-name
    (setq-local buffer-save-without-query t)
  ))


(use-package cargo
  :straight t
  :config
  (add-hook 'rustic-mode-hook 'cargo-minor-mode))

;; (use-package flycheck-rust)

;; javascript / typescript / hmtl stuff
(use-package web-mode
  :straight t
  :mode (("\\.tsx" . web-mode)
	 ("\\.jsx" . web-mode))
  :config
  (setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'")))
  (flycheck-add-mode 'typescript-tslint 'web-mode)
  (flycheck-add-mode 'javascript-eslint 'web-mode)
;;   (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
  )

(use-package magit
  :straight t
  :ensure t)

(use-package plantuml-mode
  :straight t
  :config
  (setq plantuml-jar-path "~/plantuml/plantuml.jar")
  (setq org-plantuml-jar-path plantuml-jar-path)
  (setq plantuml-default-exec-mode 'jar)
  (setq plantuml-output-type 'svg)
  (add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode)))

(defun efs/org-mode-setup ()
  "Setup org mode to our liking."
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))


(use-package ob-sql-mode
  :straight t)

(use-package org-fancy-priorities
  :straight t
  :ensure t
  :hook
  (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("⚡" "⬆" "⬇" "☕")))

(use-package markdown-mode
  :straight t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
	 ("\\.md\\'" . markdown-mode)
	 ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package js2-mode
  :straight t
;;  :hook
;;  (js2-mode . (display-line-numbers-mode t))
  :init
  (setq js-basic-indent 2)
  (setq js-indent-level 2)
  (setq js2-strict-missing-semi-warning nil)
  (setq-default js2-basic-indent 2
		js2-auto-indent-p t
		js2-cleanup-whitespace t
		js2-enter-indents-newline t
		js2-indent-on-enter-key t
		js2-global-externs (list "window" "module" "require" "buster" "sinon" "assert" "refute" "setTimeout" "clearTimeout" "setInterval" "clearInterval" "location" "__dirname" "console" "JSON" "jQuery" "$"))
  (add-hook 'js2-mode-hook
            (lambda ()
              (push '("function" . ?ƒ) prettify-symbols-alist)))
  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)))



;; password utility
(defun my-pass (key)
  "Get and decrpyt our password using pass utility.  (KEY) - password label to lookup."
  (string-trim-right
   (shell-command-to-string (concat "pass " key))))


;; enable marginalia
;; Enable richer annotations using the Marginalia package
(use-package marginalia
  :straight t
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))


;; Enable vertico
(use-package vertico
  :straight t
  :init
  (vertico-mode)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

(use-package corfu
  :straight t
  :init
  (global-corfu-mode))



;; Optionally use the `orderless' completion style. See
;; `+orderless-dispatch' in the Consult wiki for an advanced Orderless style
;; dispatcher. Additionally enable `partial-completion' for file path
;; expansion. `partial-completion' is important for wildcard support.
;; Multiple files can be opened at once with `find-file' if you enter a
;; wildcard. You may also give the `initials' completion style a try.
(use-package orderless
  :straight t
  :init

  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(substring orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))))
  
  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  (setq completion-in-region-function
      (lambda (&rest args)
        (apply (if vertico-mode
                   #'consult-completion-in-region
                 #'completion--in-region)
               args)))
  )


;; Example configuration for Consult
(use-package consult
  :straight t
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c b" . consult-bookmark)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s f" . consult-find)
         ("M-s F" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi))           ;; needed by consult-line to detect isearch

  ;; Enable automatic preview at point in the *Completions* buffer.
  ;; This is relevant when you use the default completion UI,
  ;; and not necessary for Vertico, Selectrum, etc.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Optionally replace `completing-read-multiple' with an enhanced version.
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-project-recent-file consult--source-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; Optionally configure a function which returns the project root directory.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (project-roots)  (setq consult-project-root-function
  (setq consult-project-function #'consult--default-project-function)
  ;; (lambda ()
  ;; (when-let (project (project-current))
  ;; (car (project-roots project))))
  ;;;; 2. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-root-function #'projectile-project-root)
  ;;;; 3. vc.el (vc-root-dir)
  ;; (setq consult-project-root-function #'vc-root-dir)
  ;;;; 4. locate-dominating-file
  ;; (setq consult-project-root-function (lambda () (locate-dominating-file "." ".git")))
  )



;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :straight t
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :straight t
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; Alternatively try `consult-completing-read-multiple'.
  (defun crm-indicator (args)
    (cons (concat "[CRM] " (car args)) (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)
  )



(use-package elfeed
  :straight t
  :config
  (global-set-key (kbd "C-x w") 'elfeed))
  
(use-package elfeed-org
  :straight t
  :after elfeed
  :init
  (elfeed-org)
  :config
  (setq rmh-elfeed-org-files (list "~/.emacs.d/elfeed.org"))
  (setq rmh-elfeed-org-tree-id "elfeed"))


(use-package ytdious
  :straight t
  :config
  (setq ytdious-invidious-api-url "https://vid.puffyan.us")
  )

(use-package multi-vterm
  :straight t)


(add-hook 'web-mode #'eglot-ensure)


