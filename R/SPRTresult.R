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

###################################
# Combined results for SPRT on VE #
###################################

###########
# Library #
###########

library(ggplot2)
library(reshape2)
library(gridExtra)
library(lemon)
library(gtable)
library(grid)
library(lattice)
library(xtable)
library(dplyr)


# This function returns the following simulation results based on
# efficacy and futility boundaries:
# (1) boundary: No of events and corresponding efficacy and futility boundaries
# (2) type1.power: Probability of rejecting H0 under H0 (if ve = ve.null) or H1 (if ve = ve.alt)
# (3) cum.prob: Cumulative probabilities (CP) under null and alternative -
#               number of events, efficacy and futility boundaries,
#               total CP, CP for reject H0, CP for accept H0 under H0 (if ve = ve.null)
#               or H1 (if ve = ve.alt)
# (4) prob.all: Probabilities that x <= efficacy and x >= futility boundaries-
#               number of events, efficacy and futility boundaries
#               under H0 (if ve = ve.null) or H1 (if ve = ve.alt)
# (5) ass.percent: Percentage of average sample size for each specified event
#                  under null and alternative
# (6) summary.stat: Summary statistics of events: min, Q1, Q2, mean, Q3, max, sd
#                  under null and alternative
# (7) time.sprt: Time to run the code under null and alternative
# (8) weight.info: Optimum weight  and corresponding shape parameter of beta prior
#                  under null and alternative

outputSPRT = function(method, n.sim = 100000, n.event, n.start, n.increment, ve.null, ve.alt,
                      type1 = 0.025, power = 0.9, ratio.alloc = 1,  optimum.w = TRUE,
                      w = 0.5, a.prior, b.prior = 1, seed = 134){

  if (!method %in% c('Bayes', 'Freq')){
    stop('Method must be one of Bayes/Freq')
  }

  #method: Provide "Freq" for Frequentist approach; "Bayes" for Bayesian approach
  #n.sim: Simulation size, by default 100,000
  #n.event: Total number of events
  #n.start: The event to start the study
  #n.increment: Differences between two interim, by default 1
  #ve.null: Vaccine efficacy under null, by default 0
  #ve.alt: Vaccine efficacy under alternative
  #ratio.alloc: Treatment vs control randomization = M:1, provide M; by default 1
  #type1: Specified Type I error, by default 0.025
  #power: Specified power, by default 0.9
  #optimum.w: TRUE if use optimum weight; FALSE if used provide the shape parameter a.prior
  #w: Weight to calculate shape of Beta prior if method = "Bayes" and optimum.w = TRUE
  #a.prior: Shape parameter of Beta prior if method = "Bayes" and optimum.w = FALSE
  #seed: Seed value to simulate data from binomial, by default 134

  boundary.val = SPRTboundary(method = method, n.event = n.event, n.start = n.start,
                              n.increment = n.increment, ve.null = ve.null, ve.alt = ve.alt,
                              type1 = type1, power = power, ratio.alloc = ratio.alloc,
                              optimum.w =  optimum.w, w = w, a.prior = a.prior,
                              b.prior = b.prior)

  name.cases = c("Null", "Alternative")
  ve.val = c(ve.null, ve.alt)
  cases = data.frame(name.cases, ve.val)

  cum.prob.all = vector("list", nrow(cases))
  prob.all =  vector("list", nrow(cases))
  ass.percent.all =  vector("list", nrow(cases))
  summary.stat.all = matrix(NA, 7, nrow(cases))
  prob.rejH0.all = matrix(NA, nrow(cases), 1)
  weight.info = vector("list", nrow(cases))
  time.sprt =  vector("list", nrow(cases))

  for(l in 1:nrow(cases)){
    result = SPRTonVE(n.sim = n.sim, boundary.val = boundary.val$boundary, ve.null = ve.null,
                      ve.alt = ve.alt, ve = cases$ve.val[l], ratio.alloc = ratio.alloc,
                      seed = seed)

    val = result$percent.stop
    ass.val = data.frame(as.integer(rownames(val)), val)
    colnames(ass.val) = c("n_s", "ass")
    ass.val.complete =  data.frame(boundary.val$boundary$m)
    colnames(ass.val.complete) = c("n_s")
    library(dplyr)
    ass.all = left_join(ass.val.complete, ass.val, by = "n_s")
    ass.all[is.na(ass.all)] = 0
    ass.percent.all[[l]] = ass.all


    cum.prob.all[[l]] = data.frame(boundary.val$boundary, result$cum.prob)
    prob.all[[l]] = data.frame(boundary.val$boundary, result$prob.each.n)
    summary.stat.all[,l] = as.matrix(result$summary.stat)
    prob.rejH0.all[l,1] = as.matrix(unlist(result$prob.rejH0))

    time.sprt[[l]] = result$time

  }

  names(cum.prob.all) = cases$name.cases
  names(prob.all) = cases$name.cases
  names(ass.percent.all) = cases$name.cases
  colnames(summary.stat.all) = cases$name.cases
  rownames(summary.stat.all) = rownames(result$summary.stat)
  rownames(prob.rejH0.all) = cases$name.cases
  colnames(prob.rejH0.all) = rownames(as.matrix(unlist(result$prob.rejH0)))
  names(time.sprt) = cases$name.cases

  colnames(boundary.val$boundary) = c("n_s", "r1", "r2")

  indexcumprob0 = c(1:3, 5)
  indexcumprob1 = 5
  cumprob = data.frame(cum.prob.all$Null[,indexcumprob0], cum.prob.all$Alternative[,indexcumprob1])
  colnames(cumprob) = c("n_s", "r1", "r2", "P(RejectH0|H0)", "P(RejectH0|H1)")

  indexprob0 = c(1, 4:5)
  indexprob1 = 4:5
  prob.VE = data.frame(prob.all$Null[,indexprob0], prob.all$Alternative[,indexprob1])
  colnames(prob.VE) = c("n_s", "P(x<=r1|H0)", "P(x>r2|H0)", "P(x<=r1|H1)", "P(x>r2|H1)")

  colnames(summary.stat.all) = c("Under.H0", "Under.H1")

  ass.percent = data.frame(ass.percent.all$Null, ass.percent.all$Alternative[,2])
  colnames(ass.percent) = c("n_s", "Avg(%)|H0", "Avg(%)|H1")

  time = rbind(time.sprt$Null, time.sprt$Alternative)
  colnames(time) = "Time (in seconds)"
  rownames(time) = c("Under.H0", "Under.H1")

  rownames(prob.rejH0.all) =  c("Under.H0", "Under.H1")

  sim_outputF = list(boundary = boundary.val$boundary, cumulative.prob = cumprob,
                    type1.power = prob.rejH0.all, prob.VE = prob.VE,
                    percent.stop = ass.percent, summary.stat = summary.stat.all,
                    time = time, method = boundary.val$method,
                    n.event = boundary.val$n.event, n.start = boundary.val$n.start,
                    n.increment = boundary.val$n.increment, ve.null = boundary.val$ve.null,
                    ve.alt = boundary.val$ve.alt, type1 = boundary.val$type1,
                    power = boundary.val$power,
                    ratio.alloc = boundary.val$ratio.alloc,
                    seed = result$seed)

  sim_outputB = list(boundary = boundary.val$boundary, cumulative.prob = cumprob,
                     type1.power = prob.rejH0.all, prob.VE = prob.VE,
                     percent.stop = ass.percent, summary.stat = summary.stat.all,
                     time = time, method = boundary.val$method,
                     n.event = boundary.val$n.event, n.start = boundary.val$n.start,
                     n.increment = boundary.val$n.increment, ve.null = boundary.val$ve.null,
                     ve.alt = boundary.val$ve.alt, type1 = boundary.val$type1,
                     power = boundary.val$power, ratio.alloc = boundary.val$ratio.alloc,
                     optimum.w = boundary.val$optimum.w, w = boundary.val$w,
                     a.prior = boundary.val$a.prior, b.prior = boundary.val$b.prior,
                     seed = result$seed)

  if(method == "Bayes"){
    sim_output = sim_outputB
  }else if(method == "Freq"){
    sim_output = sim_outputF
  }

  return(sim_output)
}

