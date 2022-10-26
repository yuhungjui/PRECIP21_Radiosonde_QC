# PRECIP 2021 Radiosonde QC

**This repo gathers all the files associated with upper-air radiosonde QC processes for PRECIP 2021 field campaign.**

## Status:

1. Handle the QC processes and codes beyond Level 2 (some Matlab codes).
2. Output data saved to ../Data/ on local machine.
3. Store pre-processing codes on raw level (Lraw), Level 0 (L0), and Level 1 (L1) (some Python codes).
4. Store data README, system manual, etc. at ./doc/ directory.

## Ingredients:

### 1. CSU Vaisala RS41 L0–L1 csv (in batch mode)

Convert Level-0 Vaisala RS41 radiosonde at CSU from L0 data (edt) to L1 csv format file for general usage.
The output ascii file can be directly imported to ASPEN for further QC procedures. Note that **the CSU Vaisala MW41 system for RS41 radiosonde exports the edt-format file in its own specific format.**

More information on **ASPEN**, please see: https://www.eol.ucar.edu/software/aspen & https://ncar.github.io/aspendocs/index.html

The scripit is supported by python3. This script uses **pandas** for data management, and **metpy** for calculating meteorological variables.
More information on **metpy**, please see: https://unidata.github.io/MetPy/latest/index.html
