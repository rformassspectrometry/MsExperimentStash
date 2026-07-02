# Safely Store \`MsExperiment\` Objects in a Portable Stash

## Introduction

Data objects in R can be serialized to disk in R’s *rds* or *RData*
format using the base R [`save()`](https://rdrr.io/r/base/save.html)
function and re-imported using the
[`load()`](https://rdrr.io/r/base/load.html) function. This R-specific
binary data format can however not be used easily in other programming
languages preventing the exchange of R data objects between software.
The *MsStash* package defines basic classes and generic methods to
export and import mass spectrometry (MS) data objects in various storage
formats aiming to facilitate data exchange between software. The
*MsExperimentStash* package implements portable data storage formats
(stashes) for data classes from the
*[MsExperiment](https://bioconductor.org/packages/3.23/MsExperiment)*
package, including the `MsExperiment` object. Supported stash formats
are, next to storage in simple plain text files, also Bioconductor’s
*alabaster* format defined in the
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
and related packages.

## Installation

The package can be installed with the *BiocManager* package. To install
*BiocManager* use `install.packages("BiocManager")` and, after that,
`BiocManager::install("RforMassSpectrometry/MsExperimentStash")` to
install this package.

## A stash for `MsExperiment` objects

MS data objects can be saved and restored through the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions into (or from) MS data stashes. Supported stash formats and
their respective parameter objects are:

- `AlabasterParam`: storage of MS data using Bioconductor’s
  *[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
  framework using files in HDF5 and JSON format. MS stashes in this
  format fully support the functions
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
  and
  [`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
  from *alabaster.base*.
- `PlainTextParam`: storage of data in (a custom) plain text file
  format. Note that this format currently does not support all data
  structures potentially present in an `MsExperiment` and hence the
  alabaster format is preferred.

See also the vignette from the
*[MsStash](https://bioconductor.org/packages/3.23/MsStash)* for details
on the formats and implementation notes.

As an example we create below a `MsExperiment` object with MS data two
example MS data files from the *MsDataHub* package.

``` r

library(MsExperiment)
library(MsExperimentStash)
library(MsDataHub)
fls <- c(X20171016_POOL_POS_1_105.134.mzML(),
         X20171016_POOL_POS_3_105.134.mzML())

#' Define a data.frame providing information on samples
d <- data.frame(name = c("QC 1", "QC 2"),
                sample_type = c("QC POOL", "QC POOL"),
                injection_index = c(1, 8))

#' Read the data as an MsExperiment object
mse <- readMsExperiment(fls, sampleData = d)
mse
```

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (1862) 
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 1862 element(s).

We next create a `SummarizedExperiment` and add that to the
`MsExperiment` object. In a real-world use case this would contain
quantitative feature abundances after e.g. preprocessing the data with
*xcms*. For our example we fill the `SummarizedExperiment` with
arbitrary information and random abundance values.

``` r

#' Define a SummarizedExperiment with quantification data
library(SummarizedExperiment)
se <- SummarizedExperiment(
    list(raw = matrix(rnorm(8), ncol = 2)),
    rowData = data.frame(feature_id = c("F01", "F02", "F03", "F04"),
                         mzmed = c(127.2, 232.1, 321.2, 134.5),
                         rtmed = c(38.5, 127.3, 219.8, 64.3)),
    colData = d)
rownames(se) <- c("F01", "F02", "F03", "F04")
colnames(se) <- c("QC_1", "QC_2")

#' Add the SummarizedExperiment to the MsExperiment
qdata(mse) <- se
mse
```

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (1862) 
    ##  SummarizedExperiment: 4 feature(s)
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 1862 element(s).

We next store this `MsExperiment` object to a *MsExperimentStash* using
the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function. We use an alabaster format and define the location of the
stash with the `path` parameter of `AlabasterParam`. For the present
example we save it to a temporary folder.

``` r

#' Define the location of the stash
d <- file.path(tempfile(), "mse_stash")

#' Configure the format and location
ap <- AlabasterParam(d)

#' Save the `MsExperiment` object to the stash
saveMsObject(mse, ap)
```

The content of the stash folder is:

``` r

library(fs)
dir_tree(d)
```

    ## /tmp/RtmpirqO2C/file12bf665e0799/mse_stash
    ## ├── OBJECT
    ## ├── _environment.json
    ## ├── experiment_files
    ## │   ├── OBJECT
    ## │   └── x
    ## │       ├── OBJECT
    ## │       └── list_contents.json.gz
    ## ├── metadata
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── other_data
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── qdata
    ## │   ├── OBJECT
    ## │   ├── assays
    ## │   │   ├── 0
    ## │   │   │   ├── OBJECT
    ## │   │   │   └── array.h5
    ## │   │   └── names.json
    ## │   ├── column_data
    ## │   │   ├── OBJECT
    ## │   │   └── basic_columns.h5
    ## │   └── row_data
    ## │       ├── OBJECT
    ## │       └── basic_columns.h5
    ## ├── sample_data
    ## │   ├── OBJECT
    ## │   └── basic_columns.h5
    ## ├── sample_data_links
    ## │   ├── OBJECT
    ## │   ├── list_contents.json.gz
    ## │   └── other_contents
    ## │       └── 0
    ## │           ├── OBJECT
    ## │           └── array.h5
    ## ├── sample_data_links_mcols
    ## │   ├── OBJECT
    ## │   └── basic_columns.h5
    ## └── spectra
    ##     ├── OBJECT
    ##     ├── backend
    ##     │   ├── OBJECT
    ##     │   └── spectra_data
    ##     │       ├── OBJECT
    ##     │       └── basic_columns.h5
    ##     ├── metadata
    ##     │   ├── OBJECT
    ##     │   └── list_contents.json.gz
    ##     ├── processing
    ##     │   ├── OBJECT
    ##     │   └── contents.h5
    ##     ├── processing_chunk_size
    ##     │   ├── OBJECT
    ##     │   └── contents.h5
    ##     ├── processing_queue_variables
    ##     │   ├── OBJECT
    ##     │   └── contents.h5
    ##     └── spectra_processing_queue.json

In alabaster format, each slot of the `MsExperiment` object is stored
into its own sub directory. The `Spectra` object representing the
experiment’s MS data is stored for example (as a *SpectraStash*) into a
sub-folder *spectra*. In general, users will not interact directly with
the files in this stash, but will restore the stashed `MsExperiment`
from such a *MsExperimentStash* using the
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function:

``` r

res <- readMsObject(MsExperiment(), ap)
res
```

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (1862) 
    ##  SummarizedExperiment: 4 feature(s)
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 1862 element(s).

For
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html) we
need to specify the type of the object to restore from the stash with
the first parameter of the function - in our case
[`MsExperiment()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html).
*MsExperimentStash* adds full support for *alabaster*-based
serialization formats to `MsExperiment` objects and we can therefore
also use the
[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
from the
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
package to restore the object.

``` r

library(alabaster.base)
res <- readObject(d)
res
```

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (1862) 
    ##  SummarizedExperiment: 4 feature(s)
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 1862 element(s).

Due to the modular structure of the *MsExperimentStash* is we can load
also only a single component of the `MsExperiment`. We can for example
restore the `Spectra` object from the *spectra* sub-folder:

``` r

library(Spectra)
sps <- readMsObject(Spectra(), AlabasterParam(file.path(d, "spectra")))
sps
```

    ## MSn data (Spectra) with 1862 spectra in a MsBackendMzR backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1     0.280         1
    ## 2            1     0.559         2
    ## 3            1     0.838         3
    ## 4            1     1.117         4
    ## 5            1     1.396         5
    ## ...        ...       ...       ...
    ## 1858         1   258.636       927
    ## 1859         1   258.915       928
    ## 1860         1   259.194       929
    ## 1861         1   259.473       930
    ## 1862         1   259.752       931
    ##  ... 25 more variables/columns.
    ## 
    ## file(s):
    ## 108862219686_7859
    ## 10883dc0fa5b_7860

Or only the `SummarizedExperiment` from the *qdata* sub-folder (using
*alabaster.base* functions):

``` r

readObject(file.path(d, "qdata"))
```

    ## class: SummarizedExperiment 
    ## dim: 4 2 
    ## metadata(0):
    ## assays(1): raw
    ## rownames(4): F01 F02 F03 F04
    ## rowData names(3): feature_id mzmed rtmed
    ## colnames(2): QC_1 QC_2
    ## colData names(3): name sample_type injection_index

### Creating self-contained stashes

The MS data from our example `MsExperiment` is represented by a
`Spectra` object using an `MsBackendMzR` backend.

``` r

spectra(mse)
```

    ## MSn data (Spectra) with 1862 spectra in a MsBackendMzR backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1     0.280         1
    ## 2            1     0.559         2
    ## 3            1     0.838         3
    ## 4            1     1.117         4
    ## 5            1     1.396         5
    ## ...        ...       ...       ...
    ## 1858         1   258.636       927
    ## 1859         1   258.915       928
    ## 1860         1   259.194       929
    ## 1861         1   259.473       930
    ## 1862         1   259.752       931
    ##  ... 34 more variables/columns.
    ## 
    ## file(s):
    ## 108862219686_7859
    ## 10883dc0fa5b_7860

This type of backend keeps only the spectra metadata in memory while the
mass peaks data (*m/z* and intensity values) are retrieved on demand
from the original MS data files. By default, when saved to a stash, only
the metadata and the **reference** to the original MS data tiles are
serialized to disk. If the MS data files are moved to another folder, or
if the MsExperimentStash is moved to another computer, the data can not
be fully restored (unless the path to the new location of the MS data
files is provided with parameter `spectraPath` in
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)).
The stash functionality for most `Spectra` backend implementation
supports however a parameter `consolidate` which, if set to `TRUE` will
copy **all** required data **into** the stash generating hence a
self-contained and portable MsExperimentStash:

``` r

#' Save the `MsExperiment` to a stash which includes the full data
d <- file.path(tempdir(), "portable_stash")

saveMsObject(mse, AlabasterParam(d), consolidate = TRUE)
```

The SpectraStash within the MsExperimentStash contains now also the
original MS data files (which have in this case random names without the
expected *mzML* file ending, because the data was provided through the
*MsDataHub* package):

``` r

dir_tree(file.path(d, "spectra", "backend"))
```

    ## /tmp/RtmpirqO2C/portable_stash/spectra/backend
    ## ├── 10883dc0fa5b_7860
    ## ├── 108862219686_7859
    ## ├── OBJECT
    ## └── spectra_data
    ##     ├── OBJECT
    ##     └── basic_columns.h5

While being self-contained, the size of such a stash might become very
large, depending on the number and the size of the original MS data
files.

Alternatively, we could also change the backend of the `Spectra` within
the `MsExperiment` to an *in-memory* backend and create a stash from
that object.

``` r

#' Change the Spectra backend to MsBackendMemory: load all MS data
#' into memory
spectra(mse) <- setBackend(spectra(mse), MsBackendMemory())

#' Save the MsExperiment to a stash
d <- file.path(tempdir(), "memory_stash")
saveMsObject(mse, AlabasterParam(d))
```

The full MS data is now stored in a *peaks.h5* file (in HDF5 file
format) within the stash.

``` r

dir_tree(file.path(d, "spectra", "backend"))
```

    ## /tmp/RtmpirqO2C/memory_stash/spectra/backend
    ## ├── OBJECT
    ## └── backend
    ##     ├── OBJECT
    ##     ├── mod_count
    ##     │   ├── OBJECT
    ##     │   └── contents.h5
    ##     ├── peaks.h5
    ##     └── spectra_data
    ##         ├── OBJECT
    ##         └── basic_columns.h5

## Retrieve MS experiments from MetaboLights

The *MetaboLights* database is one of the main repositories to deposit
metabolomics data sets and experiments. With
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and a `MetaboLightsParam` it is possible to retrieve and load the data
set from a MetaboLights study directly as an `MsExperiment` object.
Sample and protocol/metadata information is loaded into the object’s
[`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
while the MS data files are downloaded and locally cached through the
*[MsBackendMetaboLights](https://bioconductor.org/packages/3.23/MsBackendMetaboLights)*
package. This data is available through the object’s
[`spectra()`](https://rdrr.io/pkg/ProtGenerics/man/protgenerics.html)
data.

Below, we demonstrate how to load the dataset with the ID: *MTBLS575*.
We also use the `assayName` parameter to specify which assay we want to
load, and the `filePattern` parameter to indicate which assay files to
load. Defining the assay name is required for studies that have more
than one *assay* (e.g., data measured in positive and polarity modes or
using different chromatographic setups). The `filePattern` on the other
hand allows to restrict downloading to specific files; for our example
we only load data files with a file ending *cdf*. It is recommended to
adjust these settings according to your specific study.

``` r

library(MsExperiment)
#' Prepare parameter
param <- MetaboLightsParam(
    mtblsId = "MTBLS575",
    assayName = paste0("a_MTBLS575_POS_INFEST_CTRL_mass_spectrometry.txt"),
    filePattern = "cdf$")

#' Load MsExperiment object
mse <- readMsObject(MsExperiment(), param)
```

Next, we examine the
[`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
of our `mse` object:

``` r

sampleData(mse)
```

    ## DataFrame with 6 rows and 30 columns
    ##     Sample Name Protocol REF Protocol REF.1
    ##     <character>  <character>    <character>
    ## 1     PB130_co1   Extraction  Chromatogr...
    ## 2     PB130_co2   Extraction  Chromatogr...
    ## 3     PB130_co3   Extraction  Chromatogr...
    ## 4 PB130_sesa...   Extraction  Chromatogr...
    ## 5 PB130_sesa...   Extraction  Chromatogr...
    ## 6 PB130_sesa...   Extraction  Chromatogr...
    ##   Parameter Value[Chromatography Instrument] Parameter Value[Column model]
    ##                                  <character>                   <character>
    ## 1                              Waters ACQ...                 ACQUITY UP...
    ## 2                              Waters ACQ...                 ACQUITY UP...
    ## 3                              Waters ACQ...                 ACQUITY UP...
    ## 4                              Waters ACQ...                 ACQUITY UP...
    ## 5                              Waters ACQ...                 ACQUITY UP...
    ## 6                              Waters ACQ...                 ACQUITY UP...
    ##   Parameter Value[Column type] Protocol REF.2 Parameter Value[Scan polarity]
    ##                    <character>    <character>                    <character>
    ## 1                reverse ph...  Mass spect...                       positive
    ## 2                reverse ph...  Mass spect...                       positive
    ## 3                reverse ph...  Mass spect...                       positive
    ## 4                reverse ph...  Mass spect...                       positive
    ## 5                reverse ph...  Mass spect...                       positive
    ## 6                reverse ph...  Mass spect...                       positive
    ##   Parameter Value[Instrument] Parameter Value[Ion source] Term Source REF
    ##                   <character>                 <character>     <character>
    ## 1               Waters SYN...               electrospr...              MS
    ## 2               Waters SYN...               electrospr...              MS
    ## 3               Waters SYN...               electrospr...              MS
    ## 4               Waters SYN...               electrospr...              MS
    ## 5               Waters SYN...               electrospr...              MS
    ## 6               Waters SYN...               electrospr...              MS
    ##   Term Accession Number Parameter Value[Mass analyzer] Raw_Spectral_Data_File
    ##             <character>                    <character>            <character>
    ## 1         http://pur...                  quadrupole...          FILES/PB13...
    ## 2         http://pur...                  quadrupole...          FILES/PB13...
    ## 3         http://pur...                  quadrupole...          FILES/PB13...
    ## 4         http://pur...                  quadrupole...          FILES/PB13...
    ## 5         http://pur...                  quadrupole...          FILES/PB13...
    ## 6         http://pur...                  quadrupole...          FILES/PB13...
    ##   Protocol REF.3 Protocol REF.4 Metabolite Assignment File Source Name
    ##      <character>    <character>                <character> <character>
    ## 1  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 2  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 3  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 4  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 5  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 6  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ##   Characteristics[Organism] Term Source REF.1 Term Accession Number.1
    ##                 <character>       <character>             <character>
    ## 1                  Zea mays         NCBITAXON           http://pur...
    ## 2                  Zea mays         NCBITAXON           http://pur...
    ## 3                  Zea mays         NCBITAXON           http://pur...
    ## 4                  Zea mays         NCBITAXON           http://pur...
    ## 5                  Zea mays         NCBITAXON           http://pur...
    ## 6                  Zea mays         NCBITAXON           http://pur...
    ##   Characteristics[Variant] Term Source REF.2 Term Accession Number.2
    ##                <character>       <character>             <character>
    ## 1            Zea mays s...               EFO           http://pur...
    ## 2            Zea mays s...               EFO           http://pur...
    ## 3            Zea mays s...               EFO           http://pur...
    ## 4            Zea mays s...               EFO           http://pur...
    ## 5            Zea mays s...               EFO           http://pur...
    ## 6            Zea mays s...               EFO           http://pur...
    ##   Characteristics[Organism part] Term Accession Number.3 Protocol REF.5
    ##                      <character>             <character>    <character>
    ## 1                  stem inter...           http://pur...  Sample col...
    ## 2                  stem inter...           http://pur...  Sample col...
    ## 3                  stem inter...           http://pur...  Sample col...
    ## 4                  stem inter...           http://pur...  Sample col...
    ## 5                  stem inter...           http://pur...  Sample col...
    ## 6                  stem inter...           http://pur...  Sample col...
    ##   Factor Value[Genotype] Factor Value[Infestation]
    ##              <character>               <character>
    ## 1                  PB130                   Control
    ## 2                  PB130                   Control
    ## 3                  PB130                   Control
    ## 4                  PB130             Sesamia in...
    ## 5                  PB130             Sesamia in...
    ## 6                  PB130             Sesamia in...
    ##   Factor Value[Biological Replicate]
    ##                            <integer>
    ## 1                                  1
    ## 2                                  2
    ## 3                                  3
    ## 4                                  1
    ## 5                                  2
    ## 6                                  3

We observe that a large number of columns are present. Several
parameters are available in the
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function to simplify and restrict the content loaded into the
`sampleData`. Setting `keepOntology = FALSE` will for example remove
columns related to ontology terms, while `keepProtocol = FALSE` will
remove columns related to protocol information. The `simplify = TRUE`
option (the default) removes `NA`s and merges columns with different
names but duplicate contents. You can set `simplify = FALSE` to retain
all columns. Below, we load the object again, this time simplifying the
`sampleData`:

``` r

mse <- readMsObject(MsExperiment(), param, keepOntology = FALSE,
                    keepProtocol = FALSE, simplify = TRUE)
```

Note that the MS data files were loaded from the local cache and not
downloaded again. Now, if we examine the `sampleData` information:

``` r

sampleData(mse)
```

    ## DataFrame with 6 rows and 10 columns
    ##     Sample Name Raw_Spectral_Data_File Metabolite Assignment File Source Name
    ##     <character>            <character>                <character> <character>
    ## 1     PB130_co1          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 2     PB130_co2          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 3     PB130_co3          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 4 PB130_sesa...          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 5 PB130_sesa...          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 6 PB130_sesa...          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ##   Characteristics[Organism] Characteristics[Variant]
    ##                 <character>              <character>
    ## 1                  Zea mays            Zea mays s...
    ## 2                  Zea mays            Zea mays s...
    ## 3                  Zea mays            Zea mays s...
    ## 4                  Zea mays            Zea mays s...
    ## 5                  Zea mays            Zea mays s...
    ## 6                  Zea mays            Zea mays s...
    ##   Characteristics[Organism part] Factor Value[Genotype]
    ##                      <character>            <character>
    ## 1                  stem inter...                  PB130
    ## 2                  stem inter...                  PB130
    ## 3                  stem inter...                  PB130
    ## 4                  stem inter...                  PB130
    ## 5                  stem inter...                  PB130
    ## 6                  stem inter...                  PB130
    ##   Factor Value[Infestation] Factor Value[Biological Replicate]
    ##                 <character>                          <integer>
    ## 1                   Control                                  1
    ## 2                   Control                                  2
    ## 3                   Control                                  3
    ## 4             Sesamia in...                                  1
    ## 5             Sesamia in...                                  2
    ## 6             Sesamia in...                                  3

We can see that it is much simpler.

## Session information

``` r

sessionInfo()
```

    ## R version 4.6.0 (2026-04-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ##  [1] Spectra_1.23.3              BiocParallel_1.47.0        
    ##  [3] alabaster.base_1.13.1       fs_2.1.0                   
    ##  [5] SummarizedExperiment_1.42.0 Biobase_2.73.1             
    ##  [7] GenomicRanges_1.64.0        Seqinfo_1.3.0              
    ##  [9] IRanges_2.47.2              S4Vectors_0.51.5           
    ## [11] BiocGenerics_0.59.8         generics_0.1.4             
    ## [13] MatrixGenerics_1.25.0       matrixStats_1.5.0          
    ## [15] MsDataHub_1.13.0            MsExperimentStash_0.97.3   
    ## [17] MsStash_0.99.0              MsExperiment_1.14.0        
    ## [19] ProtGenerics_1.45.0         BiocStyle_2.40.0           
    ## 
    ## loaded via a namespace (and not attached):
    ##   [1] DBI_1.3.0                   httr2_1.2.2                
    ##   [3] rlang_1.2.0                 magrittr_2.0.5             
    ##   [5] clue_0.3-68                 otel_0.2.0                 
    ##   [7] MsBackendMetaboLights_1.6.1 compiler_4.6.0             
    ##   [9] RSQLite_3.53.2              png_0.1-9                  
    ##  [11] systemfonts_1.3.2           vctrs_0.7.3                
    ##  [13] reshape2_1.4.5              stringr_1.6.0              
    ##  [15] crayon_1.5.3                pkgconfig_2.0.3            
    ##  [17] MetaboCoreUtils_1.21.1      fastmap_1.2.0              
    ##  [19] dbplyr_2.6.0                XVector_0.53.0             
    ##  [21] rmarkdown_2.31              ragg_1.5.2                 
    ##  [23] purrr_1.2.2                 bit_4.6.0                  
    ##  [25] xfun_0.59                   MultiAssayExperiment_1.38.0
    ##  [27] cachem_1.1.0                jsonlite_2.0.0             
    ##  [29] progress_1.2.3              blob_1.3.0                 
    ##  [31] rhdf5filters_1.25.0         DelayedArray_0.39.3        
    ##  [33] Rhdf5lib_2.1.0              prettyunits_1.2.0          
    ##  [35] parallel_4.6.0              cluster_2.1.8.2            
    ##  [37] R6_2.6.1                    bslib_0.11.0               
    ##  [39] stringi_1.8.7               jquerylib_0.1.4            
    ##  [41] Rcpp_1.1.1-1.1              bookdown_0.47              
    ##  [43] knitr_1.51                  Matrix_1.7-5               
    ##  [45] igraph_2.3.2                tidyselect_1.2.1           
    ##  [47] abind_1.4-8                 yaml_2.3.12                
    ##  [49] codetools_0.2-20            curl_7.1.0                 
    ##  [51] lattice_0.22-9              tibble_3.3.1               
    ##  [53] plyr_1.8.9                  withr_3.0.3                
    ##  [55] KEGGREST_1.53.1             evaluate_1.0.5             
    ##  [57] desc_1.4.3                  BiocFileCache_3.3.0        
    ##  [59] alabaster.schemas_1.13.0    Biostrings_2.81.3          
    ##  [61] ExperimentHub_3.3.0         pillar_1.11.1              
    ##  [63] BiocManager_1.30.27         filelock_1.0.3             
    ##  [65] ncdf4_1.24                  SpectraStash_0.97.6        
    ##  [67] hms_1.1.4                   BiocVersion_3.23.1         
    ##  [69] alabaster.ranges_1.12.0     glue_1.8.1                 
    ##  [71] alabaster.matrix_1.12.0     lazyeval_0.2.3             
    ##  [73] tools_4.6.0                 AnnotationHub_4.3.2        
    ##  [75] data.table_1.18.4           mzR_2.46.0                 
    ##  [77] QFeatures_1.22.0            rhdf5_2.57.1               
    ##  [79] grid_4.6.0                  tidyr_1.3.2                
    ##  [81] MsCoreUtils_1.25.4          AnnotationDbi_1.75.0       
    ##  [83] HDF5Array_1.40.0            cli_3.6.6                  
    ##  [85] rappdirs_0.3.4              textshaping_1.0.5          
    ##  [87] S4Arrays_1.13.0             dplyr_1.2.1                
    ##  [89] AnnotationFilter_1.36.0     alabaster.se_1.12.0        
    ##  [91] sass_0.4.10                 digest_0.6.39              
    ##  [93] SparseArray_1.13.2          htmlwidgets_1.6.4          
    ##  [95] memoise_2.0.1               htmltools_0.5.9            
    ##  [97] pkgdown_2.2.0.9000          lifecycle_1.0.5            
    ##  [99] h5mread_1.4.0               httr_1.4.8                 
    ## [101] bit64_4.8.2                 MASS_7.3-65
