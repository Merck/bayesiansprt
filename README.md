
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- Copyright (C) 2021 Merck Sharp & Dohme Corp. a subsidiary of Merck & Co., Inc., Kenilworth, NJ, USA.

 This file is part of bayesiansprt.

     bayesiansprt is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     (at your option) any later version.

     bayesiansprt is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with bayesiansprt.  If not, see <https://www.gnu.org/licenses/>. -->

# bayesiansprt

<!-- badges: start -->
<!-- badges: end -->

The goal of `bayesiansprt` (under GPL-3 licence) is to provide the
results for sequential probability ratio test under frequentist and
Bayesian setup.

## Installation

You can install the released version of `bayesiansprt` from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("bayesiansprt")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(bayesiansprt)
## basic example code
method = "Bayes"
n.sim = 10000
n.event = 60
n.start = 30
n.increment = 5
ve.null = 0.3
ve.alt = 0.75
type1 = 0.025
power = 0.9
ratio.alloc = 1
optimum.w = TRUE
b.prior = 1
seed = 134

opt.w = SPRToptimumW(n.sim = n.sim, n.event = n.event, n.start = n.start,
                     n.increment = 5, ve.null = ve.null, ve.alt = ve.alt,
                     type1 = type1, power = power, ratio.alloc = ratio.alloc,
                     w = seq(0.8, 0.9, by = 0.1), b.prior = b.prior, seed = seed)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

results = outputSPRT(method = method, n.sim = n.sim, n.event = n.event, n.start = n.start,
                    n.increment = n.increment, ve.null = ve.null, ve.alt = ve.alt,
                    type1 = type1, power = power, ratio.alloc = ratio.alloc,
                    optimum.w = optimum.w, w = opt.w$weight, b.prior = b.prior, seed = seed)
results
#> $boundary
#>   n_s r1 r2
#> 1  30  5 11
#> 2  35  7 13
#> 3  40  9 14
#> 4  45 10 16
#> 5  50 12 17
#> 6  55 13 19
#> 7  60 15 20
#> 
#> $cumulative.prob
#>   n_s r1 r2 P(RejectH0|H0) P(RejectH0|H1)
#> 1  30  5 11         0.0042         0.4246
#> 2  35  7 13         0.0084         0.6080
#> 3  40  9 14         0.0134         0.7438
#> 4  45 10 16         0.0141         0.7748
#> 5  50 12 17         0.0165         0.8425
#> 6  55 13 19         0.0166         0.8587
#> 7  60 15 20         0.0174         0.8928
#> 
#> $type1.power
#>          prob_dec
#> Under.H0   0.0174
#> Under.H1   0.8928
#> 
#> $prob.VE
#>   n_s P(x<=r1|H0) P(x>r2|H0) P(x<=r1|H1) P(x>r2|H1)
#> 1  30      0.0042     0.7576      0.4246     0.0273
#> 2  35      0.0080     0.7500      0.5976     0.0152
#> 3  40      0.0107     0.8377      0.7298     0.0217
#> 4  45      0.0058     0.8244      0.7148     0.0123
#> 5  50      0.0085     0.8867      0.8140     0.0144
#> 6  55      0.0045     0.8819      0.8019     0.0091
#> 7  60      0.0054     0.9223      0.8687     0.0116
#> 
#> $percent.stop
#>   n_s Avg(%)|H0 Avg(%)|H1
#> 1  30    0.7618    0.4519
#> 2  35    0.0461    0.1855
#> 3  40    0.0688    0.1428
#> 4  45    0.0217    0.0321
#> 5  50    0.0342    0.0699
#> 6  55    0.0114    0.0168
#> 7  60    0.0560    0.1010
#> 
#> $summary.stat
#>         Under.H0 Under.H1
#> Min.     30.0000  30.0000
#> 1st Qu.  30.0000  30.0000
#> Median   30.0000  35.0000
#> Mean     33.8930  37.6850
#> 3rd Qu.  30.0000  40.0000
#> Max.     60.0000  60.0000
#> sd        8.3049   9.8209
#> 
#> $time
#>          Time (in seconds)
#> Under.H0          8.895806
#> Under.H1          6.748705
#> 
#> $method
#> [1] "Bayes"
#> 
#> $n.event
#> [1] 60
#> 
#> $n.start
#> [1] 30
#> 
#> $n.increment
#> [1] 5
#> 
#> $ve.null
#> [1] 0.3
#> 
#> $ve.alt
#> [1] 0.75
#> 
#> $type1
#> [1] 0.025
#> 
#> $power
#> [1] 0.9
#> 
#> $ratio.alloc
#> [1] 1
#> 
#> $optimum.w
#> [1] TRUE
#> 
#> $w
#> [1] 0.8
#> 
#> $a.prior
#> [1] 0.5858209
#> 
#> $b.prior
#> [1] 1
#> 
#> $seed
#> [1] 134
```

<!-- What is special about using `README.Rmd` instead of just `README.md`? You can include R chunks like so: -->
<!-- ```{r cars} -->
<!-- summary(cars) -->
<!-- ``` -->
<!-- You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. -->
<!-- You can also embed plots, for example: -->
<!-- ```{r pressure, echo = FALSE} -->
<!-- plot(pressure) -->
<!-- ``` -->
<!-- In that case, don't forget to commit and push the resulting figure files, so they display on GitHub! -->
