library(EDIutils)
library(here)
library(stringr)
library(readr)
library(tibble)
library(lubridate)
library(EML)

## Get env vars
if (Sys.getenv("EDI_ENV") %in% c("staging", "production")){
  env <- Sys.getenv("EDI_ENV")
} else {
  throw("Invalid environment set for EDI_ENV.")
}

usern <- Sys.getenv("EDI_USER")
passw <- Sys.getenv("EDI_PASS")

## Get path to generated EML for dataset
eml_path <- here("DwC", "datapackage")

## Read in EML to update DOI
eml_doc <- read_eml(here(eml_path, "eml.xml"))

# Get most recent version of published dataset
identifiers <- read_csv(here("EML", "package_identifiers.csv"))
dataset_id <- identifiers[[paste0("edi_", env)]]

# Get most recent version of published dataset
current_version <- api_list_data_package_revisions(
  scope = "edi",
  identifier = dataset_id,
  environment = env,
  filter = "newest"
)
new_version <- as.numeric(current_version) + 1

new_doi <- paste0("edi.",dataset_id, ".", new_version)

# Update EML with new DOI
eml_doc$packageId <- new_doi

# Rewrite updated EML file with EDI naming convention
eml <- EML::write_eml(eml_doc, here("DwC", "datapackage", paste0(new_doi,".xml")))

## Publish to EDI using EDIutils
tryCatch({
  print(paste("Updating data with doi:", new_doi))
  EDIutils::api_update_data_package(
    path = eml_path,
    package.id = new_doi,
    environment = "staging",
    user.id = usern,
    user.pass = passw,
    affiliation = "EDI"
  )
}, error=function(ex) {
  print(paste("Update to EDI failed with error: ", ex))
})

