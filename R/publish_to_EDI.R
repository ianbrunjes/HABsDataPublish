library(EDIutils)
library(here)
library(stringr)
library(readr)
library(tibble)
library(lubridate)

## Get path to generated EML for dataset
eml_path <- here("DwC", "datapackage")

## Read in EML to update DOI
eml_doc <- read_eml(eml_path, "eml.xml")
versions <- read_csv(here("EML", "version_history_EDI.csv"), col_types = "cc")

# Get most recent version
current_doi <- tail(versions, 1)[["doi"]]
base_doi <- sub(".[^.]+$", "", current_doi)
current_version <- sub('.*\\.', '', current_doi)
new_version <- as.numeric(current_version) + 1

new_doi <- paste0(base_doi, ".", new_version)

# Update EML with new DOI
eml_doc$packageId <- new_doi
eml <- EML::write_eml(eml_doc, here("DwC", "datapackage", paste0(new_doi,".xml")))

# Update version history (doi, publish_date)
versions <- add_row(versions, doi = new_doi, publish_date = as.character(today()))
write.csv(
  versions,
  file = here("EML", "version_history_EDI.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8",
  quote = TRUE
)


## Publish to EDI with EDIutils
EDIutils::api_create_data_package(
  path = eml_path,
  package.id = new_doi,
  environment = "staging",
  user.id = "ibrunjes",
  user.pass = "",
  affiliation = "EDI"
)
