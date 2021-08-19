# HABs data remote repository publishing

This repository pulls HABs data from ERDDAP and transforms it to Darwin Core Archive format for it to be published to remote repositories like EDI, GBIF, and OBIS. There is a scheduled task using GitHub Actions to pull the updated datasets and then publish them- currently into EDI, with plans to integrate GBIF into the process in the future.
