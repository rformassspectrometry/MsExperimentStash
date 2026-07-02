# `MsExperiment` Stash

`MsExperiment` objects can be stored to (or read from)
*MsExperimentStash*es using the `saveMsObject()` and `readMsObject()`
functions which take a second argument `parameter` to select and
configure the format of the stash.

The supported stash formats are listed in the sections below.

## Usage

``` r
# S4 method for class 'MsExperiment,PlainTextParam'
saveMsObject(object, param, ...)

# S4 method for class 'MsExperiment,PlainTextParam'
readMsObject(object, param, ...)

# S4 method for class 'MsExperiment'
saveObject(x, path, ...)

# S4 method for class 'MsExperiment,AlabasterParam'
saveMsObject(object, param, ...)

# S4 method for class 'MsExperiment,AlabasterParam'
readMsObject(object, param, ...)
```

## Arguments

- object:

  A `MsExperiment` object.

- param:

  The parameter object to select and configure the stash format. Either
  [MsStash::AlabasterParam](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
  or
  [MsStash::PlainTextParam](https://rdrr.io/pkg/MsStash/man/PlainTextParam.html).

- ...:

  For `saveMsObject()`: optional arguments passed down to the
  `saveMsObject()` function to stash the `Spectra` object (if present),
  such as `consolidate`. For `readMsObject()`: optional arguments for
  the `readMsObject()` call to restore the `Spectra` object (such as
  `spectraPath`). See
  [SpectraStash::SpectraStash](https://rdrr.io/pkg/SpectraStash/man/SpectraStash.html)
  for more information.

- x:

  A `MsExperiment` object.

- path:

  For
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html):

## Note

Overwriting an existing *MsExperimentStash* is not allowed.

Serializing `MsExperiment` objects containing a `QFeatures` object is
currently not supported.

The *plain text file-based* stash is currently not supported.

## *alabaster*-based format, `AlabasterParam`

This stash format is the most complete and reliable way for long-term
(and portable) storage of an `MsExperiment`. Objects can be saved or
read from this stash format either using the `saveMsObject()` and
`readMsObject()` functions or also using the
[`alabaster.base::saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
and
[`alabaster.base::readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
functions. Data from the object's slots are stored to their respective
folders (using alabaster functionality). These folders are:

- *experiment_files*: the content of the `@experimentFiles` slot, stored
  as a
  [MsExperimentFilesStash](https://rformassspectrometry.github.io/MsExperimentStash/reference/MsExperimentFilesStash.md).

- *metadata*: the content of the object's `@metadata` slot.

- *other_data*: the content of the object's `@otherData` slot. Note that
  export fails if object types are stored in this slot without available
  *alabaster* export functionality.

- *qdata*: the content of the object's `@qdata` slot (if present).
  Currently only
  [SummarizedExperiment](https://rdrr.io/pkg/SummarizedExperiment/man/SummarizedExperiment-class.html)
  objects are supported.

- *sample_data*: the object's `sampleData` data frame.

- *sample_data_links*: the content of the object's `@sampleDataLinks`
  slot defining the mapping between rows in `sampleData` and other
  entities in the object, such as e.g. spectra.

- *sample_data_links_mcols*: the metadata content of the
  `@sampleDataLinks`.

- *spectra*: the
  [Spectra::Spectra](https://rdrr.io/pkg/Spectra/man/Spectra.html)
  object with the MS data (if present). The respective
  [SpectraStash::SpectraStash](https://rdrr.io/pkg/SpectraStash/man/SpectraStash.html)
  functionality is used to export this data. Note that not all
  `MsBackend` types might be supported. In that case, the backend should
  be switched to one of the `MsBackend`s from the *Spectra* package
  using the
  [`Spectra::setBackend()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
  function.

## Text-file format, `PlainTextParam`

`MsExperiment` objects can also be saved to plain text files as a
MsExperimentStash in text file format. Note however that currently only
some of the object's content can be saved in that format. Content of
slots `@qdata`, `@metadata` and `@otherData` (if present) are **not**
stored to the stash. The text file-based stash directory contains the
following files:

- *ms_experiment_sample_data.txt*: tabulator delimited text file with
  the content of the `MsExperiment`'s
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html).
  This file is always saved.

- *ms_experiment_sample_data_links\_.txt*: a two column tab-delimited
  text file with the mapping between rows in
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
  and elements in other slots of the `MsExperiment`. The name of the
  respective slot is used as file name suffix. This file is only
  generated when *sample data links* are present.

- *ms_experiment_link_mcols.txt*: tab-delimited text file with the
  metadata content of the `@sampleDataLink` slot. This file is only
  generated when *sample data links* are present.

- *ms_experiment_files.txt*: the object's
  [MsExperiment::MsExperimentFiles](https://rdrr.io/pkg/MsExperiment/man/MsExperimentFiles.html).
  See
  [MsExperimentFilesStash](https://rformassspectrometry.github.io/MsExperimentStash/reference/MsExperimentFilesStash.md)
  for information on the format. This file is only generated if
  [`experimentFiles()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
  are present in the object.

If the `MsExperiment` contained a
[Spectra::Spectra](https://rdrr.io/pkg/Spectra/man/Spectra.html) object,
it is saved to the main *MsExperimentStash* folder. A different set of
files might be stored, depending on the `MsBackend` used. This can also
include raw MS data files if parameter `consolidate = TRUE` is used in
`saveMsObject()`. See
[SpectraStash::SpectraStash](https://rdrr.io/pkg/SpectraStash/man/SpectraStash.html)
for more information.

## Retrieve MS data from *MetaboLights*

In addition to the MsExperimentStash formats for storage of
`MsExperiment` objects, it is possible to load data from a metabolomics
study directly from the
[MetaboLights](https://www.ebi.ac.uk/metabolights/) repository. See
[MetaboLightsParam](https://rformassspectrometry.github.io/MsExperimentStash/reference/MetaboLightsParam.md)
for more information.

## See also

[MetaboLightsParam](https://rformassspectrometry.github.io/MsExperimentStash/reference/MetaboLightsParam.md)
for loading an `MsExperiment` from the MetaboLights public repository.

## Author

Philippine Louail, Johannes Rainer

Philippine Louail

## Examples

``` r

## Example MS data files
library(Spectra)
#> Loading required package: S4Vectors
#> Loading required package: stats4
#> Loading required package: BiocGenerics
#> Loading required package: generics
#> 
#> Attaching package: ‘generics’
#> The following objects are masked from ‘package:base’:
#> 
#>     as.difftime, as.factor, as.ordered, intersect, is.element, setdiff,
#>     setequal, union
#> 
#> Attaching package: ‘BiocGenerics’
#> The following object is masked from ‘package:fs’:
#> 
#>     path
#> The following objects are masked from ‘package:stats’:
#> 
#>     IQR, mad, sd, var, xtabs
#> The following object is masked from ‘package:utils’:
#> 
#>     data
#> The following objects are masked from ‘package:base’:
#> 
#>     Filter, Find, Map, Position, Reduce, anyDuplicated, aperm, append,
#>     as.data.frame, basename, cbind, colnames, dirname, do.call,
#>     duplicated, eval, evalq, get, grep, grepl, is.unsorted, lapply,
#>     mapply, match, mget, order, paste, pmax, pmax.int, pmin, pmin.int,
#>     rank, rbind, rownames, sapply, saveRDS, scale, sequence, table,
#>     tapply, transform, unique, unsplit, which.max, which.min
#> 
#> Attaching package: ‘S4Vectors’
#> The following object is masked from ‘package:utils’:
#> 
#>     findMatches
#> The following objects are masked from ‘package:base’:
#> 
#>     I, expand.grid, unname
#> Loading required package: BiocParallel
library(MsExperiment)
library(MsDataHub)
fls <- c(X20171016_POOL_POS_1_105.134.mzML(),
    X20171016_POOL_POS_3_105.134.mzML())
#> see ?MsDataHub and browseVignettes('MsDataHub') for documentation
#> loading from cache
#> see ?MsDataHub and browseVignettes('MsDataHub') for documentation
#> loading from cache

## Create a MsExperiment for the two example files
mse <- readMsExperiment(fls, data.frame(name = c("A", "B"), index = 1:2))

## Define the path where to create the MsExperimentStash
d <- file.path(tempdir(), "ms_experiment_stash")

## Save the MsExperiment to a stash in alabaster format; Note: with
## `consolidate = TRUE` the MS data files are also copied into the
## stash
saveMsObject(mse, AlabasterParam(d), consolidate = TRUE)

## Show the content of the stash folder
library(fs)
dir_tree(d)
#> /tmp/RtmpB00ZqG/ms_experiment_stash
#> ├── OBJECT
#> ├── _environment.json
#> ├── experiment_files
#> │   ├── OBJECT
#> │   └── x
#> │       ├── OBJECT
#> │       └── list_contents.json.gz
#> ├── metadata
#> │   ├── OBJECT
#> │   └── list_contents.json.gz
#> ├── other_data
#> │   ├── OBJECT
#> │   └── list_contents.json.gz
#> ├── sample_data
#> │   ├── OBJECT
#> │   └── basic_columns.h5
#> ├── sample_data_links
#> │   ├── OBJECT
#> │   ├── list_contents.json.gz
#> │   └── other_contents
#> │       └── 0
#> │           ├── OBJECT
#> │           └── array.h5
#> ├── sample_data_links_mcols
#> │   ├── OBJECT
#> │   └── basic_columns.h5
#> └── spectra
#>     ├── OBJECT
#>     ├── backend
#>     │   ├── 10883dc0fa5b_7860
#>     │   ├── 108862219686_7859
#>     │   ├── OBJECT
#>     │   └── spectra_data
#>     │       ├── OBJECT
#>     │       └── basic_columns.h5
#>     ├── metadata
#>     │   ├── OBJECT
#>     │   └── list_contents.json.gz
#>     ├── processing
#>     │   ├── OBJECT
#>     │   └── contents.h5
#>     ├── processing_chunk_size
#>     │   ├── OBJECT
#>     │   └── contents.h5
#>     ├── processing_queue_variables
#>     │   ├── OBJECT
#>     │   └── contents.h5
#>     └── spectra_processing_queue.json

## Restore the object from the stash
res <- readMsObject(MsExperiment(), AlabasterParam(d))
res
#> Object of class MsExperiment 
#>  Spectra: MS1 (1862) 
#>  Experiment data: 2 sample(s)
#>  Sample data links:
#>   - spectra: 2 sample(s) to 1862 element(s).

sampleData(res)
#> DataFrame with 2 rows and 3 columns
#>                          name     index spectraOrigin
#>                   <character> <integer>   <character>
#> 108862219686_7859           A         1 /github/ho...
#> 10883dc0fa5b_7860           B         2 /github/ho...

spectra(res)
#> MSn data (Spectra) with 1862 spectra in a MsBackendMzR backend:
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.280         1
#> 2            1     0.559         2
#> 3            1     0.838         3
#> 4            1     1.117         4
#> 5            1     1.396         5
#> ...        ...       ...       ...
#> 1858         1   258.636       927
#> 1859         1   258.915       928
#> 1860         1   259.194       929
#> 1861         1   259.473       930
#> 1862         1   259.752       931
#>  ... 25 more variables/columns.
#> 
#> file(s):
#> 108862219686_7859
#> 10883dc0fa5b_7860
```
