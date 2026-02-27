# Converts a vector to a lower triangular matrix.

The function `v2m` is used in the functions `gdrisk`, `gdinteract` and
`gdeco` for converting a vector is from the results of the risk detector
result, interaction detector result or ecological detector to a lower
triangular matrix.

## Usage

``` r
v2m(vec, diag = FALSE)
```

## Arguments

- vec:

  A data.frame of risk/interaction/ecological detector result of a
  strata variable

- diag:

  TRUE/FALSE, indicating if the output matrix is a diagonal matrix.
