# Load Content from a MetaboLights Study

The `MetaboLightsParam` class and the associated `readMsObject()` method
allow users to load an
[MsExperiment::MsExperiment](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
object from a study in the MetaboLights database
(https://www.ebi.ac.uk/metabolights/index) by providing its unique study
identifier (parameter `mtblsId`). This function is particularly useful
for directly importing metabolomics data into an `MsExperiment` object
for further analysis in the R environment.

It is important to note that at present it is only possible to *read*
(import) data from MetaboLights, but not to *save* data to MetaboLights.

If the study contains multiple assays (e.g. measurements performed in
positive or negative polarity or data subsets with different liquid
chromatography setups used), the user will be prompted to select which
assay to load. The resulting `MsExperiment` object will include a
`sampleData` slot populated with data extracted from the selected assay.

Users can define how to filter this `sampleData` table by specifying a
few parameters. The `keepOntology` parameter is set to `TRUE` by
default, meaning that all ontology-related columns are retained. If set
to `FALSE`, they are removed. If ontology columns are kept, some column
names may be duplicated and therefore numbered. The order of these
columns is important, as it reflects the assay and sample information
available in MetaboLights.

The `keepProtocol` parameter is also set to `TRUE` by default, meaning
that all columns related to protocols are kept. If set to `FALSE`, they
are removed. The `simplify` parameter (default `simplify = TRUE`) allows
to define whether duplicated columns or columns containing only missing
values should be removed. In the case of duplicated content, only the
first occurring column will be retained.

Further filtering can be performed using the `filePattern` parameter of
the `MetaboLightsParam` object. The default for this parameter is
`"mzML$|CDF$|cdf$|mzXML$"`, which corresponds to the supported raw data
file types.

## Usage

``` r
MetaboLightsParam(
  mtblsId = character(),
  assayName = character(),
  filePattern = "mzML$|CDF$|cdf$|mzXML$"
)

# S4 method for class 'MsExperiment,MetaboLightsParam'
readMsObject(
  object,
  param,
  keepOntology = TRUE,
  keepProtocol = TRUE,
  simplify = TRUE,
  ...
)
```

## Arguments

- mtblsId:

  `character(1)` The MetaboLights study ID, which should start with
  "MTBL". This identifier uniquely specifies the study within the
  MetaboLights database.

- assayName:

  `character(1)` The name of the assay to load. If the study contains
  multiple assays and this parameter is not specified, the user will be
  prompted to select which assay to load.

- filePattern:

  `character(1)` A regular expression pattern to filter the raw data
  files associated with the selected assay. The default value is
  `"mzML$|CDF$|cdf$|mzXML$"`, corresponding to the supported raw data
  file types.

- object:

  For `readMsObject()`: a `MsExperiment` instance.

- param:

  For `readMsObject()`: a `MetaboLightsParam` object.

- keepOntology:

  `logical(1)` Whether to keep columns related to ontology in the
  object's
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html).
  Default is `TRUE`.

- keepProtocol:

  `logical(1)` Whether to keep columns related to protocols information
  in the object's
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html).
  Default is `TRUE`.

- simplify:

  `logical(1)` Whether to simplify the
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
  table by removing columns filled with NAs or duplicated content.
  Default is `TRUE`.

- ...:

  Currently ignored.

## Value

`readMsObject()` returns an `MsExperiment` object with the
[`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
populated with MetaboLights sample and assay information and the
experiment's MS data loaded as a
[Spectra::Spectra](https://rdrr.io/pkg/Spectra/man/Spectra.html) object.

## See also

- [MsExperiment::MsExperiment](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
  object.

- [MsBackendMetaboLights::MsBackendMetaboLights](https://rdrr.io/pkg/MsBackendMetaboLights/man/MsBackendMetaboLights.html)
  for retrieving MS data files from MetaboLights.

- [MetaboLights](https://www.ebi.ac.uk/metabolights/index) for accessing
  the MetaboLights database.

## Author

Philippine Louail

## Examples

``` r

library(MsExperiment)
#> Loading required package: ProtGenerics
#> 
#> Attaching package: ‘ProtGenerics’
#> The following object is masked from ‘package:stats’:
#> 
#>     smooth
## Load a study with the mtblsId "MTBLS39" and selecting specific file
## pattern as well as removing ontology and protocol information in the
## metadata.
param <- MetaboLightsParam(mtblsId = "MTBLS39", filePattern = "63A.cdf")
ms_experiment <- readMsObject(MsExperiment(), param, keepOntology = FALSE,
                              keepProtocol = FALSE)
#> Only one assay file found: a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
#> Used data files from the assay's column "Raw Spectral Data File" since none were available in column "Derived Spectral Data File".
ms_experiment
#> Object of class MsExperiment 
#>  Spectra: MS1 (1664) 
#>  Experiment data: 3 sample(s)
#>  Sample data links:
#>   - spectra: 3 sample(s) to 1664 element(s).

## The object's sampleData contains information loaded from MetaboLights
sampleData(ms_experiment)
#> DataFrame with 3 rows and 9 columns
#>   Sample Name Raw_Spectral_Data_File Metabolite Assignment File   Source Name
#>   <character>            <character>                <character>   <character>
#> 1      MN063A          FILES/MN06...              m_MTBLS39_... Vineyard M...
#> 2      CS063A          FILES/CS06...              m_MTBLS39_... Vineyard C...
#> 3      AM063A          FILES/AM06...              m_MTBLS39_... Vineyard A...
#>   Characteristics[Organism] Characteristics[Organism part]
#>                 <character>                    <character>
#> 1             Vitis vini...                          berry
#> 2             Vitis vini...                          berry
#> 3             Vitis vini...                          berry
#>   Factor Value[Year of Harvesting] Factor Value[Vineyard]
#>                          <integer>            <character>
#> 1                             2006          Vineyard M...
#> 2                             2006          Vineyard C...
#> 3                             2006          Vineyard A...
#>   Factor Value[Replicate]
#>               <character>
#> 1                       A
#> 2                       A
#> 3                       A

## The MS data files were downloaded and cached; the data is available
## through the object's `Spectra`
spectra(ms_experiment)
#> MSn data (Spectra) with 1664 spectra in a MsBackendMetaboLights backend:
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1  0.296384         1
#> 2            1  6.206912         2
#> 3            1 12.093056         3
#> 4            1 17.942912         4
#> 5            1 23.835072         5
#> ...        ...       ...       ...
#> 1660         1   2678.27       549
#> 1661         1   2683.01       550
#> 1662         1   2687.81       551
#> 1663         1   2692.62       552
#> 1664         1   2697.40       553
#>  ... 37 more variables/columns.
#> 
#> file(s):
#> MN063A.cdf
#> CS063A.cdf
#> AM063A.cdf
```
