;;; core-spacemacs.el --- Spacemacs Core File
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(require 'org)
(require 'ox-publish)
(require 's)
(require 'dash)
(require 'f)
(require 'toc-org)
(require 'org-id)

(defvar spacemacs--category-names
  '(("config-files" . "Configuration files")
    ("email" . "E-mail")
    ("intl" . "International support")
    ("lang" . "Programming and markup languages")
    ("os" . "Operating systems")
    ("spacemacs" . "Spacemacs distribution layers"))
  "Special names for categories. Used to generate the layers list.")

(defun spacemacs//generate-layers-from-path (path level)
  "Add all layers found in PATH to the current buffer, at org level LEVEL."
  (let* ((all-subs (directory-files path t nil nil))
         (layers (-filter (lambda (p)
                            (eq 'layer (configuration-layer//directory-type p)))
                          all-subs))
         (categories (-filter
                      (lambda (p)
                        (eq 'category (configuration-layer//directory-type p)))
                      all-subs)))
    (message "%S" layers)
    (dolist (l layers)
      (let ((layer-name (file-name-nondirectory l))
            (layer-readme (concat l "/README.org")))
        (if (file-exists-p layer-readme)
            (insert (format "- [[file:%s][%s]]\n" (file-relative-name
                                                   layer-readme
                                                   (concat spacemacs-start-directory "layers"))
                            layer-name)))))
    (dolist (c categories)
      (let* ((category-name (substring (file-name-nondirectory c) 1))
             (pretty-name
              (or (cdr (assoc category-name spacemacs--category-names))
                  (s-capitalize (replace-regexp-in-string
                                 "-" " " category-name)))))
        (message "%S" category-name)
        (insert (format "\n%s %s\n" level pretty-name))
        (spacemacs//generate-layers-from-path c (concat level "*"))))))

(defun spacemacs//fetch-docs-from-root (project-plist)
  "Add missing CONTRIBUTING and COMMUNITY files to doc folder for publishing.
   Have been moved out of the doc folder to let github show the documentation.
   See commit 315528c89fd351d559a262bb88bd15ed961e4b4e"
  (copy-file (concat spacemacs-start-directory "CONTRIBUTING.org")
             (concat spacemacs-docs-directory "CONTRIBUTING.org")
             "overwrite-existing-file")
  (copy-file (concat spacemacs-start-directory "COMMUNITY.org")
             (concat spacemacs-docs-directory "COMMUNITY.org")
             "overwrite-existing-file"))

(defun spacemacs//copy-fetched-docs-html-to-pub-root (project-plist)
  "Move CONTRIBUTING.html and COMMUNITY.html to `publish-target'.
See `spacemacs//fetch-docs-from-root'"
  (dolist (file-name '("CONTRIBUTING.html" "COMMUNITY.html"))
    (let ((file-to-move (concat (plist-get project-plist
                                           :publishing-directory)
                                file-name)))
      (with-temp-file file-to-move
        (insert-file-contents file-to-move)
        (goto-char (point-min))
        (while (re-search-forward "^.*href=\"\\(.+\\)css/readtheorg\.css\".*$" nil t)
          (replace-match "" nil t nil 1)))
      (f-move file-to-move
              (concat publish-target file-name)))))

(defun spacemacs/generate-layers-file (project-plist)
  "Generate the layers list file."
  (interactive)
  (with-temp-buffer
    (org-mode)
    (insert "#+TITLE: Configuration layers\n")
    (insert "#+HTML_HEAD_EXTRA: <link rel=\"stylesheet\" type=\"text/css\" href=\"../css/readtheorg.css\" />\n\n")
    (insert "* Table of Contents\n")
    (org-set-tags-to '("TOC_4_org" "noexport"))
    ;; there is no layer at the root level for now
    ;; uncomment this line if any new layer is added at the root level
    ;; (insert "* General layers\n")
    (spacemacs//generate-layers-from-path configuration-layer-directory "*")
    (write-file (concat spacemacs-start-directory "layers/LAYERS.org"))))

(defun spacemacs//format-toc (&rest r)
  (if (not (null (car r)))
      (let* ((toc (car r))
             (heading-pos (s-index-of "Contents</h" toc)))
        (if (not (null heading-pos))
            (let* ((end-of-heading-pos (+ (length "Contents") heading-pos))
                   (beginning-of-heading (substring toc 0 end-of-heading-pos))
                   (rest-of-toc (substring toc end-of-heading-pos)))
              (format "%s<a href=\"#\">Close</a>%s"
                      beginning-of-heading rest-of-toc))
          toc))
    (car r)))

(defun spacemacs//format-content (&rest r)
  (let* ((content (car r))
         (div-string "<div id=\"content\">")
         (toc-string "<div id=\"toggle-sidebar\"><a href=\"#table-of-contents\"><h2>Table of Contents</h2></a></div>")
         (has-toc (s-index-of "Table of Contents" content))
         (beginning-of-content-div-pos (+ (length div-string)
                                          (s-index-of div-string content)))
         (beginning-of-content (substring content
                                          0 beginning-of-content-div-pos))
         (rest-of-content (substring content beginning-of-content-div-pos)))
    (if (not (null has-toc))
        (format "%s\n%s%s" beginning-of-content toc-string rest-of-content)
      content)))

(defun spacemacs//toc-org-unhrefify-toc ()
  "Make TOC classical org-mode TOC."
  (let ((toc-org-hrefify-default "org"))
    (toc-org-insert-toc)))

(defvar-local  spacemacs--org-custom-id-hash nil
  "Stores repetition count for `spacemacs//org-custom-id-uniquify' func")

(defun spacemacs//org-custom-id-uniquify (id)
  "Make ID unique by attaching -<N> postfix if org heading repeats
in the current buffer. N is repetition count.
NOTE: We probably should handle differently the corner cases when
the current buffer already has headlines with -<N> postfixes.
:see_no_evil:"
  (unless spacemacs--org-custom-id-hash
    (setq spacemacs--org-custom-id-hash
          (make-hash-table :test 'equal)))
  (let* ((old-count (gethash
                     id
                     spacemacs--org-custom-id-hash
                     0))
         (new-count (puthash
                     id
                     (1+ old-count)
                     spacemacs--org-custom-id-hash)))
    (if (> new-count 1)
        (concat id "-" (int-to-string old-count))
      id)))

(defun spacemacs//org-heading-annotate-custom-id ()
  "Annotate headings with the indexes that GitHub uses for linking.
`org-html-publish-to-html' will use them instead of the default #orgheadline{N}.
This way the GitHub links and the http://spacemacs.org/ links will be
compatible."
  (let ((heading-regexp "^[\\*]+\s\\(.*\\).*$"))
    (goto-char (point-min))
    (while (re-search-forward heading-regexp nil t)
      (unless (looking-at-p ".*\n\s*:PROPERTIES:")
        (let* ((heading (match-string 1))
               (id (substring (toc-org-hrefify-gh
                               (replace-regexp-in-string
                                toc-org-tags-regexp
                                ""
                                heading))
                              ;; Remove # prefix added by
                              ;; `toc-org-hrefify-gh'.
                              1)))
          (insert (format (concat "\n:PROPERTIES:\n"
                                  ":CUSTOM_ID: %s\n"
                                  ":END:\n")
                          (spacemacs//org-custom-id-uniquify id))))))))

(defun spacemacs//reroot-links ()
  "Find the links that start with https://github.com/syl20bnr/spacemacs/blob/
and end with .org{#an-optional-heading-link} (i.e the links between the local
org files). Change their root to http://spacemacs.org/ so the links will point
at files located on the site. For the file to file links to work properly the
exported org files should be processed with
the `spacemacs//org-heading-annotate-custom-id' function."
  (let ((git-url-root-regexp
         (concat "\\[\\[[\\s]*\\(https\\:\\/\\/github\\.com\\/syl20bnr"
                 "\\/spacemacs\\/blob\\/[^/]+\\/\\)[^]]+\\(\\.org\\).*$"))
        (site-url "http://spacemacs.org/")
        (site-doc-postf ".html"))
    (progn (goto-char (point-min))
           (while (re-search-forward git-url-root-regexp nil t)
             (progn (replace-match site-url nil t nil 1)
                    (replace-match site-doc-postf nil t nil 2))))))

(defun spacemacs//add-org-meta-readtheorg-css (filename)
  (let* ((head-css-extra-readtheorg-head (concat
                                          "#+HTML_HEAD_EXTRA:"
                                          "<link rel=\"stylesheet\" "
                                          "type=\"text/css\" "
                                          "href=\""))
         (head-css-extra-readtheorg-tail "css/readtheorg.css\" />\n"))
    (progn (goto-char (point-min))
           (delete-matching-lines
            "\\+HTML_HEAD_EXTRA\\:.*\\/css\\/readtheorg\\.css")
           (goto-char (point-min))
           (if (search-forward "#+TITLE:" nil t nil)
               (beginning-of-line 2)
             (error (format "Can't find #+TITLE: in %s"
                            (buffer-file-name))))
           (insert (concat head-css-extra-readtheorg-head
                           (f-relative spacemacs-start-directory
                                       (file-name-directory filename))
                           head-css-extra-readtheorg-tail)))))

(defun spacemacs//pub-doc-html-advice (origfunc &rest args)
  "Wrapper for `org-html-publish-to-html' use it to insert
preprocessors for the exported .org files."
  (save-current-buffer
    (save-excursion
      (let* ((filename (car (nthcdr 1 args)))
             (visitingp (find-buffer-visiting filename)))
        ;; Temporary "unvisit" the visited org files.
        (when visitingp (with-current-buffer visitingp
                          (setq buffer-file-name nil)))
        (with-temp-buffer
          (save-match-data
            (insert-file-contents filename t)
            ;; ===========Add preprocessors here===============
            (spacemacs//org-heading-annotate-custom-id)
            (spacemacs//add-org-meta-readtheorg-css filename)
            (spacemacs//toc-org-unhrefify-toc)
            (spacemacs//reroot-links)
            (apply origfunc args)
            (set-buffer-modified-p nil)))
        ;; Restore `buffer-file-name' for the buffers that previously visited
        ;; the org files.
        (when visitingp (with-current-buffer visitingp
                          (setq buffer-file-name filename)))))))

(defun spacemacs/publish-doc ()
  "Publish the documentation to doc/export/."
  (interactive)
  (advice-add 'org-html-toc :filter-return #'spacemacs//format-toc)
  (advice-add 'org-html-template :filter-return #'spacemacs//format-content)
  (advice-add 'org-html-publish-to-html :around #'spacemacs//pub-doc-html-advice)
  (let* ((header
          "<link rel=\"stylesheet\" type=\"text/css\"
                 href=\"http://www.pirilampo.org/styles/readtheorg/css/htmlize.css\"/>
          <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>
          <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js\"></script>
          <script src=\"http://www.pirilampo.org/styles/readtheorg/js/readtheorg.js\"></script>
          <script src=\"http://spacemacs.org/js/permalinks.js\"></script>
          <script>
           (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
               (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new
               Date();a=s.createElement(o),
               m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
               })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

           ga('create', 'UA-28326243-2', 'auto'); ga('send', 'pageview');
          </script>")
         (publish-target (concat spacemacs-start-directory "export/"))
         (org-html-htmlize-output-type 'css)
         (org-publish-project-alist
          `(("spacemacs"
             :components ("spacemacs-news"
                          "spacemacs-doc"
                          "spacemacs-doc-static"
                          "layers-doc"
                          "layers-doc-static"))
            ("spacemacs-news"
             :base-directory ,spacemacs-news-directory
             :base-extension "org"
             :publishing-directory ,(concat publish-target "news/")
             :publishing-function org-html-publish-to-html
             :headline-levels 4
             :html-head ,header)
            ("spacemacs-doc"
             :base-directory ,spacemacs-docs-directory
             :base-extension "org"
             :publishing-directory ,(concat publish-target "doc/")
             :publishing-function org-html-publish-to-html
             :preparation-function spacemacs//fetch-docs-from-root
             :completion-function spacemacs//copy-fetched-docs-html-to-pub-root
             :headline-levels 4
             :html-head ,header)
            ("layers-doc"
             :base-directory ,(concat spacemacs-start-directory "layers/")
             :base-extension "org"
             :recursive t
             :publishing-directory ,(concat publish-target "layers/")
             :publishing-function org-html-publish-to-html
             :preparation-function spacemacs/generate-layers-file
             :exclude "local\\|dockerfiles"
             :html-head ,header)
            ("spacemacs-doc-static"
             :base-directory ,spacemacs-docs-directory
             :base-extension "png"
             :recursive t
             :publishing-directory ,(concat publish-target "doc/")
             :publishing-function org-publish-attachment)
            ("layers-doc-static"
             :base-directory ,(concat spacemacs-start-directory "layers/")
             :base-extension "jpg\\|png\\|gif"
             :recursive t
             :publishing-directory ,(concat publish-target "layers/")
             :publishing-function org-publish-attachment))))
    (org-publish-project "spacemacs"))
  (advice-remove 'org-html-toc #'spacemacs//format-toc)
  (advice-remove 'org-html-template #'spacemacs//format-content)
  (advice-remove 'org-html-publish-to-html #'spacemacs//pub-doc-html-advice))

(provide 'core-documentation)
