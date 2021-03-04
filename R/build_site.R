
library(here)
library(tidyverse)
library(rmarkdown)
library(hugodown)
library(brio)
library(fs)



# read profile data -------------------------------------------------------

profiles <- here("static", "profile_text.csv") %>%
  read_csv() %>%
  mutate(
    dir = img %>%
      str_to_lower() %>%
      str_remove_all(".jpg$") %>%
      str_remove_all(".png$")
  ) %>%
  transpose()



# write .Rmd files --------------------------------------------------------

write_profile_rmd <- function(profile) {

  cat(profile$name, "\n")

  lines <- c(
    '---',
    'output: hugodown::md_document',
    paste0('title: "', profile$name, '"'),
    'date: 2021-03-06',
    'summary: ""',
    paste0('trailer: "/profile_image/', profile$img, '"'),
    'splash:',
    paste0('  image: "/splash/banner.jpg"'),
    paste0('  caption: "', profile$name, '"'),
    '---',
    '',
    paste0('> ', profile$text)
  )

  if(!is.na(profile$quote)) {
    lines <- c(
      lines,
      paste0('<blockquote><p><i>"', profile$quote, '"</i></p></blockquote>')
    )
  }

  folder <- here("content", "profile", profile$dir)
  if(!dir_exists(folder)) {
    dir_create(folder)
  }
  write_lines(
    text = lines,
    path = path(folder, "_index.Rmd")
  )
}

if(dir_exists(here("content", "profile"))){
  dir_delete(here("content", "profile"))
}
dir_create(here("content", "profile"))

profiles %>%
  walk(write_profile_rmd)




# build .md files ---------------------------------------------------------

site_outdated() %>%
  walk(function(x) {
    cat("\n", x, "\n")
    render(x)
  })


