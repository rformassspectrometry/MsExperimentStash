# Stash for `MsExperimentFiles`

The
[MsExperiment::MsExperimentFiles](https://rdrr.io/pkg/MsExperiment/man/MsExperimentFiles.html)
class stores files (or rather file names) that are part of a mass
spectrometry experiment.

The supported stash formats for `MsExperimentFiles` objects are listed
in the sections below.

## Usage

``` r
# S4 method for class 'MsExperimentFiles,PlainTextParam'
saveMsObject(object, param, ...)

# S4 method for class 'MsExperimentFiles,PlainTextParam'
readMsObject(object, param, ...)

# S4 method for class 'MsExperimentFiles'
saveObject(x, path, ...)

# S4 method for class 'MsExperimentFiles,AlabasterParam'
saveMsObject(object, param, ...)

# S4 method for class 'MsExperimentFiles,AlabasterParam'
readMsObject(object, param, ...)
```

## Arguments

- object:

  An `MsExperimentFiles` object.

- param:

  An
  [MsStash::AlabasterParam](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
  or
  [MsStash::PlainTextParam](https://rdrr.io/pkg/MsStash/man/PlainTextParam.html).

- ...:

  Currently ignored.

- x:

  An `MsExperimentFiles` object.

- path:

  For
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html):
  `character(1)` with the path where the object should be stored into.

## Value

`readMsObject()` returns a
[MsExperiment::MsExperimentFiles](https://rdrr.io/pkg/MsExperiment/man/MsExperimentFiles.html)
object.

## *alabaster*-based format, `AlabasterParam`

The `MsExperimentFiles` stash folder contains the alabaster-specific
*OBJECT* file and a sub-folder *x* with the `MsExperimentFiles` content
serialized by *alabaster.base*.

## Text-file format, `PlainTextParam`

The text-file format stash folder for `MsExperimentFile` objects
contains a file *ms_experiment_files.txt* with two tabulator separated
columns *name* and *files*. Each row (except the first) is one element
of the `MsExperimentFile`, the first defining the object's names and the
second its content, which represents a characted vector with the file
name(s), separated by a `"|"` (if more than one).

## Author

Johannes Rainer

## Examples

``` r

library(MsExperiment)

fls <- MsExperimentFiles(list(input = c("file.mzML", "file2.mgf")))

## Define the path to the stash
d <- file.path(tempdir(), "ms_file_stash")

## Stash the object in alabaster format
saveMsObject(fls, AlabasterParam(d))

## The content of the stash: subfolder x contains the *character list*
## saved through the *alabaster.base* package.
library(fs)
dir_tree(d)
#> /tmp/RtmpB00ZqG/ms_file_stash
#> ├── OBJECT
#> ├── _environment.json
#> └── x
#>     ├── OBJECT
#>     └── list_contents.json.gz

## Restore the object from stash
res <- readMsObject(MsExperimentFiles(), AlabasterParam(d))
res
#> MsExperimentFiles of length  1 
#> [["input"]] file.mzML file2.mgf

## In addition, it is possible to read the object also with the
## *alabaster.base* functionality
library(alabaster.base)
res <- readObject(d)
```
