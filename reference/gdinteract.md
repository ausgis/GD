# Geographical detectors: interaction detector.

Function for interaction detector calculation and visualization. The
types of interactions include "Enhance, nonlinear", "Independent",
"Enhance, bi-", "Weaken, uni-" and "Weaken, nonlinear".

## Usage

``` r
gdinteract(formula, data = NULL)
# S3 method for class 'gdinteract'
print(x, ...)
# S3 method for class 'gdinteract'
plot(x, ...)
```

## Arguments

- formula:

  A formula of response and explanatory variables

- data:

  A data.frame includes response and explanatory variables

- x:

  A list of interaction detector results

- ...:

  Ignore

## Examples

``` r
gi1 <- gdinteract(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
gi1
#> Interaction detector:
#>      variable Climatezone Mining
#> 1 Climatezone          NA     NA
#> 2      Mining      0.8345     NA
# \donttest{
data <- ndvi_40[,1:3]
gi2 <- gdinteract(NDVIchange ~ ., data = data)
gi2
#> Interaction detector:
#>      variable Climatezone Mining
#> 1 Climatezone          NA     NA
#> 2      Mining      0.8345     NA
# }
```
