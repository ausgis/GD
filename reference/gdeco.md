# Geographical detectors: ecological detector.

Function for ecological detector calculation, ecological matrix and
visulization.

## Usage

``` r
gdeco(formula, data = NULL)
# S3 method for class 'gdeco'
print(x, ...)
# S3 method for class 'gdeco'
plot(x, ...)
```

## Arguments

- formula:

  A formula of response and explanatory variables

- data:

  A data.frame includes response and explanatory variables

- x:

  A list of ecological detector results

- ...:

  Ignore

## Examples

``` r
ge1 <- gdeco(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
ge1
#> Ecological detector:
#>      variable Climatezone Mining
#> 1 Climatezone        <NA>   <NA>
#> 2      Mining           Y   <NA>
# \donttest{
data <- ndvi_40[,1:3]
ge2 <- gdeco(NDVIchange ~ ., data = data)
ge2
#> Ecological detector:
#>      variable Climatezone Mining
#> 1 Climatezone        <NA>   <NA>
#> 2      Mining           Y   <NA>
# }
```
