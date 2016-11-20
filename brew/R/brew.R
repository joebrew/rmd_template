# Based on readthedown template from https://raw.githubusercontent.com/juba/rmdformats/master/R/readthedown.R
#' Convert to an HTML document
#'
#' Format for converting from R Markdown to an HTML document.
#'
#' @details
#' CSS adapted from the readtheorg theme of the org-html-themes project :
#' \url{https://github.com/fniessen/org-html-themes}, which is itself inspired by
#' the Read the docs theme : \url{https://readthedocs.org/}.
#'
#' @param fig_width Default width (in inches) for figures
#' @param fig_height Default width (in inches) for figures
#' @param fig_caption \code{TRUE} to render figures with captions
#' @param highlight Syntax highlighting style. Supported styles include
#'   "default", "tango", "pygments", "kate", "monochrome", "espresso",
#'   "zenburn", "haddock", and "textmate". Pass \code{NULL} to prevent syntax
#'   highlighting.
#' @param lightbox if TRUE, add lightbox effect to content images
#' @param thumbnails if TRUE display content images as thumbnails
#' @param gallery if TRUE and lightbox is TRUE, add a gallery navigation between images in lightbox display
#' @param pandoc_args arguments passed to the pandoc_args argument of rmarkdown \code{\link[rmarkdown]{html_document}}
#' @param toc_depth adjust table of contents depth
#' @param use_bookdown if TRUE, uses \code{\link[bookdown]{html_document2}} instead of \code{\link[rmarkdown]{html_document}}, thus providing numbered sections and cross references
#' @param ... Additional function arguments passed to R Markdown \code{\link[rmarkdown]{html_document}}
#' @return R Markdown output format to pass to \code{\link[rmarkdown]{render}}
#' @import rmarkdown
#' @import bookdown
#' @importFrom htmltools htmlDependency
#' @export


brew <- function(fig_width = 8,
                        fig_height = 5,
                        fig_caption = TRUE,
                        highlight = "kate",
                        lightbox = FALSE,
                        thumbnails = FALSE,
                        gallery = FALSE,
                        pandoc_args = NULL,
                        toc_depth = 2,
                        use_bookdown = FALSE,
                        ...) {
  
  # Some functions from here:
  # https://raw.githubusercontent.com/juba/rmdformats/master/R/html_dependencies.R
  
  # create an html dependency for Magnific popup
  html_dependency_magnific_popup <- function() {
    htmltools::htmlDependency(name = "magnific-popup",
                              version = "1.1.0",
                              src = system.file("templates/magnific-popup-1.1.0", package = "rmdformats"),
                              script = "jquery.magnific-popup.min.js",
                              stylesheet = "magnific-popup.css")
  }
  
  # create an html dependency for jquery-stickytableheaders
  html_dependency_jquery_stickytableheaders <- function()  {
    htmltools::htmlDependency(name = "jquery-stickytableheaders",
                              version = "0.1.11",
                              src = system.file("templates/jquery-stickytableheaders-0.1.11", package = "rmdformats"),
                              script = "jquery.stickytableheaders.min.js")
  }
  
  
  # create an html dependency for bootstrap (function copied from rmarkdown)
  html_dependency_bootstrap <- function(theme = "bootstrap") {
    htmltools::htmlDependency(name = "bootstrap",
                              version = "3.3.6",
                              src = system.file("templates/bootstrap-3.3.6", package = "rmdformats"),
                              meta = list(viewport = "width=device-width, initial-scale=1"),
                              script = c(
                                "js/bootstrap.min.js"
                                # These shims are necessary for IE 8 compatibility
                                #"shim/html5shiv.min.js",
                                #"shim/respond.min.js"
                              ),
                              stylesheet = paste("css/", theme, ".min.css", sep = ""))
  }
  
  # create an html dependency for bootstrap js only (function copied from rmarkdown)
  html_dependency_bootstrap_js <- function() {
    htmltools::htmlDependency(name = "bootstrap_js",
                              version = "3.3.6",
                              src = system.file("templates/bootstrap-3.3.6", package = "rmdformats"),
                              meta = list(viewport = "width=device-width, initial-scale=1"),
                              script = c(
                                "js/bootstrap.min.js"
                              ))
  }
  
  # Mathjax (function copied from rmarkdown)
  default_mathjax <- function() {
    "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"
  }
  
  require(rmarkdown)
  ## js and css dependencies
  extra_dependencies <- list(rmarkdown::html_dependency_jquery(),
                             rmarkdown::html_dependency_jqueryui(),
                             rmarkdown::html_dependency_bootstrap(theme = 'default'),
                             html_dependency_magnific_popup(),
                             html_dependency_readthedown())
  
  ## Force mathjax arguments
  pandoc_args <- c(pandoc_args,
                   "--mathjax",
                   "--variable", paste0("mathjax-url:", default_mathjax()))
  if (lightbox) { pandoc_args <- c(pandoc_args, "--variable", "lightbox:true") }
  if (thumbnails) { pandoc_args <- c(pandoc_args, "--variable", "thumbnails:true") }
  if (gallery) {
    pandoc_args <- c(pandoc_args, "--variable", "gallery:true")
  } else {
    pandoc_args <- c(pandoc_args, "--variable", "gallery:false")
  }
  
  ## Merge "extra_dependencies"
  extra_args <- list(...)
  if ("extra_dependencies" %in% names(extra_args)) {
    extra_dependencies <- append(extra_dependencies, extra_args[["extra_dependencies"]])
    extra_args[["extra_dependencies"]] <- NULL
    extra_args[["mathjax"]] <- NULL
  }
  
  ## Call rmarkdown::html_document
  html_document_args <- list(
    template = system.file("templates/readthedown/readthedown.html", package = "rmdformats"),
    extra_dependencies = extra_dependencies,
    fig_width = fig_width,
    fig_height = fig_height,
    fig_caption = fig_caption,
    highlight = highlight,
    pandoc_args = pandoc_args,
    toc = TRUE,
    toc_depth = toc_depth
  )
  html_document_args <- append(html_document_args, extra_args)
  if (use_bookdown) {
    html_document_func <- bookdown::html_document2
  } else {
    html_document_func <- rmarkdown::html_document
  }
  
  do.call(html_document_func, html_document_args)
  
}

# readthedown js and css
html_dependency_readthedown <- function() {
  htmltools::htmlDependency(name = "readthedown",
                            version = "0.1",
                            src = system.file("templates/readthedown", package = "rmdformats"),
                            script = "readthedown.js",
                            stylesheet = c("readthedown.css"))
}