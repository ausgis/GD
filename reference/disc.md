# Generates discretization parameters for continuous data.

Function for discretizing continuous data and obtaining the different
outputs, including discretization intervals, numbers of values within
intervals, and visualization of discretization.

## Usage

``` r
disc(var, n, method = "quantile", ManualItv)
```

## Arguments

- var:

  A numeric vector of continuous variable

- n:

  The numeber of intervals

- method:

  A character of discretization method

- ManualItv:

  A numeric vector of manual intervals

## Examples

``` r
## method is default (quantile); number of intervals is 4
ds1 <- disc(ndvi_40$Tempchange, 4)
ds1
#> Intervals:
#>  -0.39277 0.60626 1.23631 1.73837 3.22051
## method is equal; number of intervals is 4
ds2 <- disc(ndvi_40$Tempchange, 4, method = "equal")
## method is manual; number of intervals is 4
manualitv1 <- c(-0.5, 0, 1, 2, 4)
ds3 <- disc(ndvi_40$Tempchange, 4, method = "manual", ManualItv = manualitv1)
```
