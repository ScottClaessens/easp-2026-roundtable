# EASP 2026 Roundtable

Slides, abstract, and R code for roundtable discussion at EASP 2026.

To run the code, you will need to [install R](https://www.r-project.org/) and 
the following R packages:

```r
install.packages(c("brms", "countrycode", "haven", 
                   "readxl", "targets", "tidyverse"))
```

You will then need to download the individual-level Global Preferences Survey
data file `individual_new.dta` from 
[here](https://gps.econ.uni-bonn.de/downloads) and add it to the directory
`data/gps`.

You can then run the code by running `targets::tar_make()` in your R console.

## Authors

Scott Claessens, scott.claessens@gmail.com
