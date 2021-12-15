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

####################################
# Optimum weight for Bayesian SPRT #
####################################

#################
# Load packages #
#################

library(ggplot2)
library(reshape2)
library(gridExtra)
library(lemon)
library(gtable)
library(grid)
library(lattice)
library(xtable)
library(dplyr)

###############################################################################
# Function for shape parameter (a) of beta prior corresponding to all weights #
###############################################################################

all_weighted_prior = function(ve.null, ve.alt, w, ratio.alloc){

  ##############
  # Parameters #
  ##############

  # ve.null: vaccine efficacy under null
  # ve.alt: vaccine efficacy under alternative
  # w: vector of weights to explore, ranges between 0 and 1
  # ratio.alloc: Treatment vs placebo ratdomization = K:1, provide K

  ##########################
  # Output of the function #
  ##########################

  # This function returns the following values corresponding to
  # each weight based on weighted prioportion of H0 and H1
  # w: Vector of specified weights
  # Allocation: Treatment vs placebo ratdomization = K:1
  # RR0: Relative risk under H0, 1-ve.null
  # RR1: Relative risk under H1, 1-ve.alt
  # p0: Binomial proportion under H0
  # p1: Binomial proportion under H1
  # p: Weighted proportion
  # a.prior: Shape parameters of Beta prior corresponding to weights
  # b.prior: Shape parameters of Beta prior, fixed as 1

  ##########################################################################
  # Null and alternative values based on probabilities of binomial success #
  ##########################################################################

  p0 = ratio.alloc*(1-ve.null)/(ratio.alloc*(1-ve.null)+1)
  p1 = ratio.alloc*(1-ve.alt)/(ratio.alloc*(1-ve.alt)+1)

  #######################
  # Weighted proportion #
  #######################
  p.val = w*p0 + (1-w)*p1

  ##############################
  # Shape and scale parameters #
  ##############################

  a_p = p.val/(1-p.val)
  b_p = 1

  ##########
  # Output #
  ##########

  weighted.prior = data.frame(w, ratio.alloc, 1-ve.null, 1-ve.alt, round(p0, 4),
                              round(p1, 4) , round(p.val, 4), round(a_p, 4),
                              round(b_p, 4))
  colnames(weighted.prior) = c("w", "Allocation", "RR0", "RR1", "p0", "p1", "p", "a.prior",
                               "b.prior")
  return(weighted.prior)
}

############################################################
# Function of finding the optimum weight for Bayesian SPRT #
############################################################

SPRToptimumW = function(n.sim, n.event, n.start, n.increment, ve.null, ve.alt,
                        type1, power, ratio.alloc, w, b.prior, seed){

  ###############################################
  # Calculate the optimum weight for beta prior #
  ###############################################

  ##########################################################################
  # Null and alternative values based on probabilities of binomial success #
  ##########################################################################

  p0 = ratio.alloc*(1-ve.null)/(ratio.alloc*(1-ve.null)+1)
  p1 = ratio.alloc*(1-ve.alt)/(ratio.alloc*(1-ve.alt)+1)

  ##################################
  # Threshold values based on SPRT #
  ##################################

  a.val = log(((1-power)/(1-type1)), base = exp(1))
  b.val = log(((power)/type1), base = exp(1))

  ########################################################
  # Extract shape parameter corresponding to each weight #
  ########################################################

  a.prior = all_weighted_prior(ve.null, ve.alt, w, ratio.alloc)$a.prior

  boundary.all = vector("list", length(a.prior))
  for(i in 1:length(a.prior)){
    boundary.val = SPRTboundary(method = "Bayes", n.event = n.event, n.start = n.start,
                                n.increment = 1, ve.null = ve.null, ve.alt = ve.alt,
                                type1 = type1, power = power, ratio.alloc = ratio.alloc,
                                optimum.w =  FALSE, a.prior = a.prior[i],
                                b.prior = b.prior)$boundary
    boundary.all[[i]]  = cbind(w[i], boundary.val[,-3])
    colnames(boundary.all[[i]]) = c("w", "m", "r")
  }

  all.data1 = do.call(Map, c(rbind, boundary.all))
  all.data = data.frame(c(all.data1$w), c(all.data1$m), c(all.data1$r))
  colnames(all.data) = c("w", "m", "r")

  # Find optimum weights
  out = unique(all.data$w[c(1,1+which(diff(all.data$r)!=0))-1])

  ##########
  # Output #
  ##########

  result.w = out[order(out)]

  w.optim = matrix(NA, length(result.w), 3)

  for(i in 1:length(result.w)){
    results = outputSPRT(method = "Bayes", n.sim = n.sim,  n.event = n.event, n.start = n.start,
                         n.increment = n.increment, ve.null = ve.null, ve.alt = ve.alt,
                         type1 = type1, power = power, ratio.alloc = ratio.alloc,
                         optimum.w =  TRUE, w =  result.w[i], b.prior = b.prior, seed = seed)
    TypeIerror = results$type1.power[1]
    Power = results$type1.power[2]

    w.optim[i,] = unlist(c(result.w[i], TypeIerror, Power))
    #print(paste("Weight = ", result.w[i]))
  }

  colnames(w.optim) = c("w", "TypeIerror", "Power")

  w.mat = data.frame(w.optim)
  index = which(w.mat$TypeIerror < type1)
  w.optimum = min(w.mat$w[which(w.mat$TypeIerror[index] == max(w.mat$TypeIerror[index]))])
  #print(paste("Optimum weight is", w.optimum))
  return(list(weight = w.optimum, all.weight = result.w))
}

