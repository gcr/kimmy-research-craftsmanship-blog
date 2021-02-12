(require 'package)

(package-initialize)

(require 'ox-publish)
(require 'ox-html)
(require 'htmlize)
(require 'org-roam)
(require 's)

;; Don't create backup files (those ending with ~) during the publish process.
(setq make-backup-files nil)

;; standard stuff here.
(setq kimmy/project-dir (file-name-directory load-file-name))
(setq kimmy/publish-dir (concat kimmy/project-dir "/export"))
;; Use org-id for links
(setq org-id-link-to-org-use-id t)

(setq kimmy/head-extra "
<link href='https://fonts.googleapis.com/css?family=Nunito:400,700&display=swap' rel='stylesheet'>
<link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'>
<link href='https://fonts.googleapis.com/css?family=Eczar|Kalam|Merriweather' rel='stylesheet'>
<script defer src='https://use.fontawesome.com/releases/v5.0.10/js/all.js' integrity='sha384-slN8GvtUJGnv6ca26v8EzVaR9DC58QEwsIk9q1QXdCU8Yu8ck/tL/5szYlBbqmS+' crossorigin='anonymous'></script>
<link rel='stylesheet' type='text/css' href='/css/stylesheet.css'/>
<script src='js/URI.js'></script>
<script src='js/page.js'></script>")


(setq org-publish-project-alist
      `(("kimmy"
         :components ("kimmy-notes" "kimmy-static"))
        ("kimmy-notes"
         :base-directory ,kimmy/project-dir
         :base-extension "org"
         :publishing-directory ,kimmy/publish-dir
         :publishing-function org-html-publish-to-html
         :recursive t
         :headline-levels 4
         :with-toc nil
         :section-numbers nil
         :html-doctype "html5"
         :html-html5-fancy t
         ;; :html-preamble ,kimmy/preamble
         :html-postamble nil
         :html-head-include-scripts nil
         :html-head-include-default-style nil
         :html-head-extra ,kimmy/head-extra
         :with-broken-links 'mark
         :html-container "section"
         :htmlized-source nil
         ;;:auto-sitemap t
         :exclude "export"
         ;;:sitemap-title "Recent changes"
         ;;:sitemap-sort-files anti-chronologically
         ;;:sitemap-format-entry kimmy/sitemap-format-entry
         ;;:sitemap-filename "recentchanges.org"
         )
        ("kimmy-static"
         :base-directory ,kimmy/project-dir
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|svg\\|svg\\|json\\|pdf"
         :publishing-directory ,kimmy/publish-dir
         :exclude "export"
         :recursive t
         :publishing-function org-publish-attachment)))


(setq org-roam-directory kimmy/project-dir)
(setq org-roam-db-location (concat kimmy/project-dir "/org-roam.db"))

(defun kimmy/org-roam--backlinks-list (file)
  (if (org-roam--org-roam-file-p file)
      (--reduce-from
       (concat acc (format "- [[file:%s][%s]]\n"
                           (file-relative-name (car it) org-roam-directory)
                           (org-roam-db--get-title (car it))))
       "" (org-roam-db-query [:select [source] :from links :where (= dest $s1)] file))
    ""))

(defun kimmy/org-export-preprocessor (backend)
  (let ((links (kimmy/org-roam--backlinks-list (buffer-file-name))))
    (unless (string= links "")
      (save-excursion
        (goto-char (point-max))
        (insert (concat "\n* Backlinks\n") links)))))
(add-hook 'org-export-before-processing-hook 'kimmy/org-export-preprocessor)

(defun kimmy/publish ()
  (call-interactively 'org-publish-all))

(defun kimmy/republish ()
  (org-roam-db-build-cache)
  (let ((current-prefix-arg 4))
    (call-interactively 'org-publish-all)))
