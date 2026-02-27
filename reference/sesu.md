# Comparison of size effects of spatial units.

Function for comparison of size effects of spatial units in spatial
heterogeneity analysis.

## Usage

``` r
sesu(gdlist, su)
```

## Arguments

- gdlist:

  A list of `gdm` result or `gd` result

- su:

  A vector of sizes of spatial units

## Examples

``` r
ndvilist <- list(ndvi_30, ndvi_40, ndvi_50)
su <- c(30, 40, 50) ## sizes of spatial units
## "gdm" function
gdlist <- lapply(ndvilist, function(x){
  gdm(NDVIchange ~ Climatezone + Mining, data = x)
})
sesu(gdlist, su) ## size effects of spatial units

```
