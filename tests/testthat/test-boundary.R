# Copyright (C) 2021 Merck Sharp & Dohme Corp. a subsidiary of Merck & Co., Inc., Kenilworth, NJ, USA.
#
# This file is part of bayesiansprt.
#
#     bayesiansprt is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     bayesiansprt is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with bayesiansprt.  If not, see <https://www.gnu.org/licenses/>.

# Workflow derived from https://github.com/r-lib/actions/tree/master/examples
# Need help debugging build failures? Start at https://github.com/r-lib/actions#where-to-find-help

# setwd("/home/pauleri/bayesiansprt/tests")

test_that("Testing boundary in SPRTboundary", {

 a <- SPRTboundary(method = "Bayes", n.event = 60, n.start = 30, n.increment = 5,
                    ve.null = 0.3, ve.alt = 0.75, type1 = 0.025, power = 0.9,
                    ratio.alloc = 1, optimum.w = TRUE, w = 0.6, a.prior, b.prior = 1)

 b <- SPRTboundary(method = "Bayes", n.event = 60, n.start = 30, n.increment = 5,
                   ve.null = 0.3, ve.alt = 0.75, type1 = 0.025, power = 0.9,
                   ratio.alloc = 1, optimum.w = TRUE, w = 0.6, a.prior, b.prior = 1)

 expect_identical(a, b)
})
