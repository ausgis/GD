# Geographical detectors: factor detector.

Function for calculating power determinant using factor detector of
geographical detectors and visualization.

## Usage

``` r
gd(formula, data = NULL)
# S3 method for class 'gd'
print(x, ...)
# S3 method for class 'gd'
plot(x, sig = TRUE, ...)
```

## Arguments

- formula:

  A formula of response and explanatory variables

- data:

  A data.frame includes response and explanatory variables

- x:

  A list of factor detector results

- sig:

  If TRUE, only spatial associations that are significant at the 0.05
  level will be plotted; If FALSE, all spatial associations will be
  plotted.

- ...:

  Ignore

## Examples

``` r
g1 <- gd(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
g1
#>      variable        qv          sig
#> 1 Climatezone 0.8218335 7.340526e-10
#> 2      Mining 0.1411154 6.734163e-10
plot(g1)

```
