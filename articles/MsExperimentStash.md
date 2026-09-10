# Safely Store \`MsExperiment\` Objects in a Portable Stash

## Introduction

Data objects in R can be serialized to disk in R’s *rds* or *RData*
format using the base R [`save()`](https://rdrr.io/r/base/save.html)
function and re-imported using the
[`load()`](https://rdrr.io/r/base/load.html) function. This R-specific
binary data format can however not be used easily in other programming
languages preventing the exchange of R data objects between software.
The *[MsStash](https://bioconductor.org/packages/3.23/MsStash)* package
defines basic classes and generic methods to export and import mass
spectrometry (MS) data objects in various storage formats aiming to
facilitate data exchange between software. The *MsExperimentStash*
package implements portable data storage formats (stashes) for data
classes from the
*[MsExperiment](https://bioconductor.org/packages/3.23/MsExperiment)*
package, including the `MsExperiment` object. Supported stash formats
are, next to storage in simple plain text files, also Bioconductor’s
*alabaster* format defined in the
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
and related packages.

## Installation

The package can be installed with the *BiocManager* package. To install
*BiocManager* use `install.packages("BiocManager")` and, after that,
install *MsExperimentStash* including all dependencies with:

`BiocManager``::`[`install`](https://bioconductor.github.io/BiocManager/reference/install.html)`(``"MsExperimentStash"``)`

## A stash for `MsExperiment` objects

MS data objects can be saved and restored through the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions to (or from) MS data stashes. Supported stash formats and
their respective parameter objects are:

- `AlabasterParam`: storage of MS data using Bioconductor’s
  *[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
  framework using files in HDF5 and JSON format. MS stashes in this
  format also fully support the
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
  and
  [`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
  functions from *alabaster.base*.
- `PlainTextParam`: storage of data in (a custom) plain text file
  format. Note that this format currently does not support all data
  structures potentially present in an `MsExperiment` and hence the
  alabaster format is preferred.

See also the vignette from the
*[MsStash](https://bioconductor.org/packages/3.23/MsStash)* for details
on the formats and implementation notes.

As an example we create below a `MsExperiment` object with MS data two
example MS data files from the *MsDataHub* package.

[`library`](https://rdrr.io/r/base/library.html)`(`[`MsExperiment`](https://github.com/RforMassSpectrometry/MsExperiment)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`MsExperimentStash`](https://github.com/RforMassSpectrometry/MsExperimentStash)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`MsDataHub`](https://rformassspectrometry.github.io/MsDataHub)`)`` `` ``#' Define the MS data files (provided by MsDataHub)`` ``fls`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`[`X20171016_POOL_POS_1_105.134.mzML`](https://rformassspectrometry.github.io/MsDataHub/reference/sciex.html)`(``)``,`` `` `[`X20171016_POOL_POS_3_105.134.mzML`](https://rformassspectrometry.github.io/MsDataHub/reference/sciex.html)`(``)``)`` `` ``#' Define a data.frame providing information on samples`` ``d`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``name ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"QC 1"``, ``"QC 2"``)``,`` `` sample_type ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"QC POOL"``, ``"QC POOL"``)``,`` `` injection_index ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``8``)``)`` `` ``#' Read the data as an MsExperiment object`` ``mse`` ``<-`` `[`readMsExperiment`](https://rdrr.io/pkg/MsExperiment/man/readMsExperiment.html)`(``fls``, sampleData ``=`` ``d``)`` ``mse`

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (1862) 
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 1862 element(s).

We next create a `SummarizedExperiment` and add that to the
`MsExperiment` object. In a real-world use case this would contain
quantitative feature abundances after e.g. preprocessing the data with
the *[xcms](https://bioconductor.org/packages/3.23/xcms)* package. For
our example we fill the `SummarizedExperiment` with random abundance
values.

`#' Define a SummarizedExperiment with quantification data`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`SummarizedExperiment`](https://bioconductor.org/packages/SummarizedExperiment)`)`` ``se`` ``<-`` `[`SummarizedExperiment`](https://rdrr.io/pkg/SummarizedExperiment/man/SummarizedExperiment-class.html)`(`` `` `[`list`](https://rdrr.io/r/base/list.html)`(``raw ``=`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``8``)``, ncol ``=`` ``2``)``)``,`` `` rowData ``=`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``feature_id ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"F01"``, ``"F02"``, ``"F03"``, ``"F04"``)``,`` `` mzmed ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``127.2``, ``232.1``, ``321.2``, ``134.5``)``,`` `` rtmed ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``38.5``, ``127.3``, ``219.8``, ``64.3``)``)``,`` `` colData ``=`` ``d``)`` `[`rownames`](https://rdrr.io/r/base/colnames.html)`(``se``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"F01"``, ``"F02"``, ``"F03"``, ``"F04"``)`` `[`colnames`](https://rdrr.io/r/base/colnames.html)`(``se``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"QC_1"``, ``"QC_2"``)`` `` ``#' Add the SummarizedExperiment to the MsExperiment`` `[`qdata`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)`(``mse``)`` ``<-`` ``se`` ``mse`

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

`#' Define the location of the stash`` ``d`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempfile`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"mse_stash"``)`` `` ``#' Configure the format and location`` ``ap`` ``<-`` `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(``d``)`` `` ``` #' Save the `MsExperiment` object to the stash ``` `[`saveMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(``mse``, ``ap``)`

The content of the stash folder is:

[`library`](https://rdrr.io/r/base/library.html)`(`[`fs`](https://fs.r-lib.org)`)`` `[`dir_tree`](https://fs.r-lib.org/reference/dir_tree.html)`(``d``)`

    ## /tmp/Rtmpl5F05O/file1c35714e0e94/mse_stash
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

`` #' Load the `MsExperiment` from the stash ``` ``res`` ``<-`` `[`readMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(`[`MsExperiment`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)`(``)``, ``ap``)`` ``res`

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
*MsExperimentStash* provides full support for *alabaster*-based
serialization formats to `MsExperiment` objects and we can therefore
also use the
[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
from the
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
package to restore the object.

[`library`](https://rdrr.io/r/base/library.html)`(`[`alabaster.base`](https://github.com/ArtifactDB/alabaster.base)`)`` ``res`` ``<-`` `[`readObject`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)`(``d``)`` ``res`

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (1862) 
    ##  SummarizedExperiment: 4 feature(s)
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 1862 element(s).

Due to the modular structure of the *MsExperimentStash* we can load also
only a single component of the `MsExperiment`. We can for example
restore the `Spectra` object from the *spectra* sub-folder:

`` #' Read the `Spectra` object with the MS data from the stash ``` `[`library`](https://rdrr.io/r/base/library.html)`(`[`Spectra`](https://github.com/RforMassSpectrometry/Spectra)`)`` ``sps`` ``<-`` `[`readMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(`[`Spectra`](https://rdrr.io/pkg/Spectra/man/Spectra.html)`(``)``, `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``d``, ``"spectra"``)``)``)`` ``sps`

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
    ## 19fb327a92e6_7859
    ## 19fb63be6e97_7860

Or only the `SummarizedExperiment` from the *qdata* sub-folder (using
*alabaster.base* functions):

`` #' Read the `SummarizedExperiment` from the stash ``` `[`readObject`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``d``, ``"qdata"``)``)`

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

[`spectra`](https://rdrr.io/pkg/ProtGenerics/man/protgenerics.html)`(``mse``)`

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
    ## 19fb327a92e6_7859
    ## 19fb63be6e97_7860

This type of backend keeps only the spectra metadata in memory while the
mass peaks data (*m/z* and intensity values) are retrieved on demand
from the original MS data files. By default, when saved to a stash, only
the metadata and the **reference** to the original MS data tiles are
serialized to disk. If the MS data files are moved to another folder, or
if the MsExperimentStash is moved to another computer, the data can not
be fully restored (unless the path to the new location of the MS data
files is provided with parameter `spectraPath` in the
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
call). The stash functionality for most `Spectra` backend implementation
supports however a parameter `consolidate` which, if set to `TRUE` will
copy **all** data **into** the stash hence generating a self-contained
and portable MsExperimentStash:

`` #' Save the `MsExperiment` to a stash which includes the full data ``` ``d`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"portable_stash"``)`` `` `[`saveMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(``mse``, `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(``d``)``, consolidate ``=`` ``TRUE``)`

The SpectraStash within the MsExperimentStash contains now also the
original MS data files (which have in this case random names without the
expected *mzML* file ending, because the data was provided through the
*MsDataHub* package):

`#' Directory content of the spectra subfolder`` `[`dir_tree`](https://fs.r-lib.org/reference/dir_tree.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``d``, ``"spectra"``, ``"backend"``)``)`

    ## /tmp/Rtmpl5F05O/portable_stash/spectra/backend
    ## ├── 19fb327a92e6_7859
    ## ├── 19fb63be6e97_7860
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

`#' Change the Spectra backend to MsBackendMemory: load all MS data`` ``#' into memory`` `[`spectra`](https://rdrr.io/pkg/ProtGenerics/man/protgenerics.html)`(``mse``)`` ``<-`` `[`setBackend`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)`(`[`spectra`](https://rdrr.io/pkg/ProtGenerics/man/protgenerics.html)`(``mse``)``, `[`MsBackendMemory`](https://rdrr.io/pkg/Spectra/man/MsBackend.html)`(``)``)`` `` ``#' Save the MsExperiment to a stash`` ``d`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"memory_stash"``)`` `[`saveMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(``mse``, `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(``d``)``)`

The full MS data is now stored in a *peaks.h5* file (in HDF5 file
format) within the stash.

[`dir_tree`](https://fs.r-lib.org/reference/dir_tree.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``d``, ``"spectra"``, ``"backend"``)``)`

    ## /tmp/Rtmpl5F05O/memory_stash/spectra/backend
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

Again, because the full MS data is included in the stash, the size of
the folder might be large.

## Retrieve MS experiments from MetaboLights

*MetaboLights* is one of the main repositories to deposit metabolomics
data sets and experiments. With
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and a `MetaboLightsParam` it is possible to retrieve and load the data
set from a MetaboLights study directly as an `MsExperiment` object from
the repository into R. Sample and protocol/metadata information is
loaded into the object’s
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
than one *assay* (e.g., data measured in positive and negative polarity
modes or using different chromatographic setups). The `filePattern` on
the other hand allows to restrict downloading only selected files; for
our example we load only data files with a file ending *cdf*. It is
recommended to adjust these settings according to your specific study.

[`library`](https://rdrr.io/r/base/library.html)`(`[`MsExperiment`](https://github.com/RforMassSpectrometry/MsExperiment)`)`` ``#' Prepare parameter`` ``param`` ``<-`` `[`MetaboLightsParam`](https://rformassspectrometry.github.io/MsExperimentStash/reference/MetaboLightsParam.md)`(`` `` mtblsId ``=`` ``"MTBLS575"``,`` `` assayName ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"a_MTBLS575_POS_INFEST_CTRL_mass_spectrometry.txt"``)``,`` `` filePattern ``=`` ``"cdf$"``)`` `` ``#' Load MsExperiment object`` ``mse`` ``<-`` `[`readMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(`[`MsExperiment`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)`(``)``, ``param``)`

Next, we examine the
[`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
of our `mse` object:

[`sampleData`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)`(``mse``)`

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

A large number of columns were loaded. Several parameters are available
in the
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function to simplify and restrict the content loaded into the
`sampleData`. Setting `keepOntology = FALSE` will for example remove
columns related to ontology terms, while `keepProtocol = FALSE` will
remove columns related to protocol information. The `simplify = TRUE`
option (the default) removes columns containing only missing values
(`NA`) and merges columns with different names but duplicate contents.
Set to `simplify = FALSE` to retain all columns. Below, we load the
object again, this time simplifying the `sampleData`:

`mse`` ``<-`` `[`readMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(`[`MsExperiment`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)`(``)``, ``param``, keepOntology ``=`` ``FALSE``,`` `` keepProtocol ``=`` ``FALSE``, simplify ``=`` ``TRUE``)`

Note that the MS data files were loaded from the local cache and not
downloaded again. Now, if we examine the `sampleData` information:

[`sampleData`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)`(``mse``)`

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

[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`

    ## R version 4.6.1 (2026-06-24)
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
    ##  [1] Spectra_1.23.4              BiocParallel_1.47.0        
    ##  [3] alabaster.base_1.13.4       fs_2.1.0                   
    ##  [5] SummarizedExperiment_1.42.0 Biobase_2.73.2             
    ##  [7] GenomicRanges_1.64.0        Seqinfo_1.3.2              
    ##  [9] IRanges_2.47.5              S4Vectors_0.51.9           
    ## [11] BiocGenerics_0.59.12        generics_0.1.4             
    ## [13] MatrixGenerics_1.25.0       matrixStats_1.5.0          
    ## [15] MsDataHub_1.13.1            MsExperimentStash_0.99.0   
    ## [17] MsStash_0.99.0              MsExperiment_1.14.0        
    ## [19] ProtGenerics_1.45.0         BiocStyle_2.40.0           
    ## 
    ## loaded via a namespace (and not attached):
    ##   [1] DBI_1.3.0                   httr2_1.3.0                
    ##   [3] rlang_1.3.0                 magrittr_2.0.5             
    ##   [5] clue_0.3-68                 otel_0.2.0                 
    ##   [7] MsBackendMetaboLights_1.6.1 compiler_4.6.1             
    ##   [9] RSQLite_3.53.3              png_0.1-9                  
    ##  [11] systemfonts_1.3.2           vctrs_0.7.3                
    ##  [13] reshape2_1.4.5              stringr_1.6.0              
    ##  [15] crayon_1.5.3                pkgconfig_2.0.3            
    ##  [17] MetaboCoreUtils_1.21.1      fastmap_1.2.0              
    ##  [19] dbplyr_2.6.0                XVector_0.53.0             
    ##  [21] rmarkdown_2.32              ragg_1.5.2                 
    ##  [23] purrr_1.2.2                 bit_4.6.0                  
    ##  [25] xfun_0.60                   MultiAssayExperiment_1.38.0
    ##  [27] cachem_1.1.0                jsonlite_2.0.0             
    ##  [29] progress_1.2.3              blob_1.3.0                 
    ##  [31] rhdf5filters_1.25.4         DelayedArray_0.39.6        
    ##  [33] Rhdf5lib_2.1.0              prettyunits_1.2.0          
    ##  [35] parallel_4.6.1              cluster_2.1.8.3            
    ##  [37] R6_2.6.1                    bslib_0.12.0               
    ##  [39] stringi_1.8.9               jquerylib_0.1.4            
    ##  [41] Rcpp_1.1.2                  bookdown_0.48              
    ##  [43] knitr_1.52                  BiocBaseUtils_1.15.1       
    ##  [45] Matrix_1.7-6                igraph_2.3.3               
    ##  [47] tidyselect_1.2.1            abind_1.4-8                
    ##  [49] yaml_2.3.12                 codetools_0.2-20           
    ##  [51] curl_8.0.0                  lattice_0.23-1             
    ##  [53] tibble_3.3.1                plyr_1.8.9                 
    ##  [55] withr_3.0.3                 KEGGREST_1.53.6            
    ##  [57] evaluate_1.0.5              desc_1.4.3                 
    ##  [59] BiocFileCache_3.3.0         alabaster.schemas_1.13.0   
    ##  [61] Biostrings_2.81.9           ExperimentHub_3.3.2        
    ##  [63] pillar_1.11.1               BiocManager_1.30.27        
    ##  [65] filelock_1.0.3              ncdf4_1.24                 
    ##  [67] SpectraStash_0.99.2         hms_1.1.4                  
    ##  [69] BiocVersion_3.23.1          alabaster.ranges_1.12.0    
    ##  [71] glue_1.8.1                  alabaster.matrix_1.12.0    
    ##  [73] lazyeval_0.2.3              tools_4.6.1                
    ##  [75] AnnotationHub_4.3.2         data.table_1.18.6.1        
    ##  [77] mzR_2.46.0                  QFeatures_1.22.0           
    ##  [79] rhdf5_2.57.12               grid_4.6.1                 
    ##  [81] tidyr_1.3.2                 MsCoreUtils_1.25.4         
    ##  [83] AnnotationDbi_1.75.2        HDF5Array_1.40.0           
    ##  [85] cli_3.6.6                   rappdirs_0.3.4             
    ##  [87] textshaping_1.0.5           S4Arrays_1.13.0            
    ##  [89] dplyr_1.2.1                 AnnotationFilter_1.36.0    
    ##  [91] alabaster.se_1.12.0         sass_0.4.10                
    ##  [93] digest_0.6.39               SparseArray_1.13.2         
    ##  [95] htmlwidgets_1.6.4           memoise_2.0.1              
    ##  [97] htmltools_0.5.9             pkgdown_2.2.1.9000         
    ##  [99] lifecycle_1.0.5             h5mread_1.4.1              
    ## [101] httr_1.4.9                  bit64_4.8.6                
    ## [103] MASS_7.3-66
