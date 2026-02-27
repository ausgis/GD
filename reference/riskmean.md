# Geographical detectors: risk means in risk detector.

Function for calculating risk means within intervals and visualization.

## Usage

``` r
riskmean(formula, data = NULL)
# S3 method for class 'riskmean'
print(x, ...)
# S3 method for class 'riskmean'
plot(x, ...)
```

## Arguments

- formula:

  a formula of response and explanatory variables

- data:

  a data.frame includes response and explanatory variables

- x:

  a list of risk mean values

- ...:

  ignore

## Examples

``` r
rm1 <- riskmean(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
rm1
#> Climatezone
#>   itv    meanrisk
#> 1 Bsk 0.143572961
#> 2 Bwk 0.004536505
#> 3 Dwa 0.321735000
#> 4 Dwb 0.343155655
#> 5 Dwc 0.444868361
#> 
#> Mining
#>         itv   meanrisk
#> 1  very low 0.21008297
#> 2       low 0.03294513
#> 3    medium 0.30733460
#> 4      high 0.26695286
#> 5 very high 0.19176875
#> 
plot(rm1)

# \donttest{
data <- ndvi_40[,1:3]
rm2 <- riskmean(NDVIchange ~ ., data = data)
rm2
#> Climatezone
#>   itv    meanrisk
#> 1 Bsk 0.143572961
#> 2 Bwk 0.004536505
#> 3 Dwa 0.321735000
#> 4 Dwb 0.343155655
#> 5 Dwc 0.444868361
#> 
#> Mining
#>         itv   meanrisk
#> 1  very low 0.21008297
#> 2       low 0.03294513
#> 3    medium 0.30733460
#> 4      high 0.26695286
#> 5 very high 0.19176875
#> 
# }
```
