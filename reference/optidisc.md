# Optimal discretization for continuous variables and visualization.

Optimal discretization for continuous variables and visualization.

## Usage

``` r
optidisc(formula, data,
        discmethod = discmethod, discitv = discitv)
# S3 method for class 'optidisc'
print(x, ...)
# S3 method for class 'optidisc'
plot(x, ...)
```

## Arguments

- formula:

  A formula of response and explanatory variables, where the explanatory
  variables must be continuous variables to be discretized.

- data:

  A data.frame includes response and explanatory variables

- discmethod:

  A character vector of discretization methods

- discitv:

  A numeric vector of numbers of intervals

- x:

  A list of `optidisc` result

- ...:

  Ignore

## Examples

``` r
## set optional discretization methods and numbers of intervals
# optional methods: equal, natural, quantile, geometric, sd and manual
discmethod <- c("equal","quantile")
discitv <- c(4:5)
## optimal discretization
odc1 <- optidisc(NDVIchange ~ Tempchange, ndvi_40, discmethod, discitv)
odc1
#> optimal discretization result of Tempchange
#> method             :  quantile
#> number of intervals:  5
#> intervals:
#>  -0.39277 0.471748 1.041764 1.363464 1.855572 3.22051
#> numbers of data within intervals:
#>  143 142 143 142 143
#> 
plot(odc1)
#> Optimal discretization process ...
#> 

#> Optimal discretization result ...
#> 

```
