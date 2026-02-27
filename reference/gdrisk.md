# Geographical detectors: risk detector.

Function for risk detector calculation, risk matrix and visualization.

## Usage

``` r
gdrisk(formula, data = NULL)
# S3 method for class 'gdrisk'
print(x, ...)
# S3 method for class 'gdrisk'
plot(x, ...)
```

## Arguments

- formula:

  A formula of response and explanatory variables

- data:

  A data.frame includes response and explanatory variables

- x:

  A list of risk detector results

- ...:

  Ignore

## Examples

``` r
gr1 <- gdrisk(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
gr1
#> Climatezone
#>   interval  Bsk  Bwk  Dwa  Dwb  Dwc
#> 1      Bsk <NA> <NA> <NA> <NA> <NA>
#> 2      Bwk    Y <NA> <NA> <NA> <NA>
#> 3      Dwa    Y    Y <NA> <NA> <NA>
#> 4      Dwb    Y    Y    N <NA> <NA>
#> 5      Dwc    Y    Y    Y    Y <NA>
#> 
#> Mining
#>    interval very low  low medium high very high
#> 1  very low     <NA> <NA>   <NA> <NA>      <NA>
#> 2       low        Y <NA>   <NA> <NA>      <NA>
#> 3    medium        Y    Y   <NA> <NA>      <NA>
#> 4      high        Y    Y      N <NA>      <NA>
#> 5 very high        N    Y      Y    Y      <NA>
#> 
plot(gr1)

# \donttest{
data <- ndvi_40[,1:3]
gr2 <- gdrisk(NDVIchange ~ ., data = data)
gr2
#> Climatezone
#>   interval  Bsk  Bwk  Dwa  Dwb  Dwc
#> 1      Bsk <NA> <NA> <NA> <NA> <NA>
#> 2      Bwk    Y <NA> <NA> <NA> <NA>
#> 3      Dwa    Y    Y <NA> <NA> <NA>
#> 4      Dwb    Y    Y    N <NA> <NA>
#> 5      Dwc    Y    Y    Y    Y <NA>
#> 
#> Mining
#>    interval very low  low medium high very high
#> 1  very low     <NA> <NA>   <NA> <NA>      <NA>
#> 2       low        Y <NA>   <NA> <NA>      <NA>
#> 3    medium        Y    Y   <NA> <NA>      <NA>
#> 4      high        Y    Y      N <NA>      <NA>
#> 5 very high        N    Y      Y    Y      <NA>
#> 
# }
```
