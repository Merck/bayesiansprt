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

############################
# SPRT on Vaccine Efficacy #
############################

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
# (1) boundary: specified event size and corresponding efficacy and futility boundaries
# (2) prob.rejH0: probability of rejecting H0 under H0 (if ve = ve.null) or H1 (if ve = ve.alt)
# (3) cum.prob: cumulative probabilities -
#               total, reject H0, accept H0 under H0 (if ve = ve.null) or H1 (if ve = ve.alt)
# (4) prob.each.n: probabilities that x <= efficacy and x >= futility boundaries
#                  under H0 (if ve = ve.null) or H1 (if ve = ve.alt)
# (5) percent.stop: Percentage of average sample size for each specified event
# (6) summay.stat: Summary statistics of events: min, Q1, Q2, mean, Q3, max, sd
# for Frequentist and Bayesian SPRT
# (7) time: time to run the code

SPRTonVE = function(n.sim = 100000, boundary.val, ve.null, ve.alt, ve, ratio.alloc,
                    seed){
  #n.sim: total number of simulation, by default 100,000
  #boundary.val: Boundaries corresponding to required events;
  #              This values can be generated from SPRT.BayesFreq.boundary.R;
  #              We can specify the interim timepoints and get the boundaries
  #              by extracting "Boundary" results, or we can get the optimized
  #              interim time points and get the corresponding boundaries by
  #              extracting "Boundary.interim" results
  #ve.null: vaccine efficacy under null
  #ve.alt: vaccine efficacy under alternative
  #ve: vaccine efficacy based on the model, if under H0, ve = ve.null; if under H1, ve = ve.alt
  #ratio.alloc: Treatment vs placebo ratdomization = K:1, provide K
  #seed.val: seed value to simulate data from binomial, by default 134

  start.time = Sys.time()
  #No of events
  n.count = nrow(boundary.val)

  #Probabilities of binomial success
  p = ratio.alloc*(1-ve)/(ratio.alloc*(1-ve)+1)

  ##################
  # Simulated data #
  ##################
  x =  matrix(NA, n.sim, n.count)

  for(i in 1:n.sim){
    set.seed(seed+3*i)
    x[i, 1] = rbinom(1, boundary.val$m[1], p)
    for(j in 2: n.count){
      set.seed(123*j+i)
      y =  rbinom(1, (boundary.val$m[j] - boundary.val$m[j-1]), p)
      x[i,j] = x[i, j-1] + y
    }
  }

  #####################################
  # Desicion based on SPRT boundaries #
  #####################################
  decision = matrix(NA, n.sim, n.count)
  for(i in 1:n.sim){
    for(j in 1: n.count){
      if(x[i,j]<= boundary.val[j,2]){
        decision[i,j] = 1#"Accept H1"
      }else if(x[i,j]>= boundary.val[j, 3]){
        decision[i,j] = 2#"Accept H0"
      }else{
        decision[i,j] = 3#"Continue"
      }
    }
  }

  ####################################################################################
  # Calculation for  probability of x<=r1 and x >=r2 for each interim under H0 or H1 #
  ####################################################################################
  prob_r12 = matrix(NA, n.count, 2)
  for(j in 1:n.count){
    for(k in 1:2){
      prob_r12[j, k] = length(which(decision[,j]==k))/n.sim
    }
  }

  #################################################################
  #Calculation for cumulative probability and average sample size #
  #################################################################S
  dec_n = rep(NA, n.sim)
  dec = rep(NA, n.sim)
  nval = rep(NA, n.sim)
  min_declist = rep(NA, n.sim)
  for(i in 1:n.sim){
    if(length(unique(decision[i,]))==1){
      if((max(decision[i,]) == 3)&&(min(decision[i,]) == 3)){
        dec_n[i] = 999
        dec[i] =  3
        nval[i] = max(boundary.val$m)+1
      }else{
        #position of decision
        dec_n[i] =  min(which(decision[i,] == min(decision[i,])))# 1
        #decision
        dec[i] = decision[i,dec_n[i]]
        #stopping n
        nval[i] = boundary.val$m[dec_n[i]]
      }
    }else if(length(unique(decision[i,]))==2){
      #if(min(decision[i,])<= 2 && max(decision[i,])==3){
      #position of decision
      dec_n[i] =  min(which(decision[i,] == min(decision[i,])))# 1
      #decision
      dec[i] = decision[i,dec_n[i]]
      #stopping n
      nval[i] = boundary.val$m[dec_n[i]]
      #}
    }else if(length(unique(decision[i,]))==3){
      dec_n[i] = which(decision[i,] <3)[1]
      #decision
      dec[i] = decision[i,dec_n[i]]
      #stopping n
      nval[i] = boundary.val$m[dec_n[i]]
    }
  }

  #Calculation total probability under H0 or H1
  dec_nprob = rep(NA, n.count)
  for(j in 1:n.count){
    dec_nprob[j] = length(which(nval == boundary.val$m[j]))/n.sim
  }

  #Calculation probability of rejecting H0 under H0 or H1
  index1 = which(dec==1)
  dec_nprob1 = rep(NA, n.count)
  for(j in 1:n.count){
    dec_nprob1[j] = length(which(nval[index1] == boundary.val$m[j]))/n.sim
  }

  #Calculation probability of accepting H0 under H0 or H1
  index2 = which(dec==2)
  dec_nprob2 = rep(NA, n.count)
  for(j in 1:n.count){
    dec_nprob2[j] = length(which(nval[index2] == boundary.val$m[j]))/n.sim
  }


  prob_h1 = length(which(dec==1))/n.sim
  prob_h0 = length(which(dec==2))/n.sim
  prob_c = length(which(dec==3))/n.sim

  nval_nmax = nval
  nval_nmax[which(nval_nmax == (max(boundary.val$m)+1))] = max(boundary.val$m)
  Nval_summary = cbind(summary(nval_nmax))
  Nval_sd = sd(nval_nmax)

  #Type I error or power
  prob_dec = prob_h1

  #Average sample size
  percent.val = table(nval_nmax)/sum(table(nval_nmax))

  #Summary of the events
  summary_all = Nval_summary
  sd = round(Nval_sd, 4)

  cum.prob = round(cbind(cumsum(dec_nprob), cumsum(dec_nprob1), cumsum(dec_nprob2)), 4)
  colnames(cum.prob) = c("Total_cp",  "cp_rejectH0", "cp_acceptH0")

  summary.stat = data.frame(rbind(summary_all, sd))
  colnames(summary.stat) = c("Summary")

  prob.each.n = round(cbind(prob_r12), 4)
  colnames(prob.each.n) = c("x_less_r1", "x_greater_r2")

  percent.stop = round(cbind(percent.val), 4)
  colnames(percent.stop) = c("percent.stop")

  time.total = Sys.time() - start.time

  mylist = list(boundary = boundary.val, prob.rejH0 = data.frame(prob_dec),
                cum.prob = cum.prob, prob.each.n = prob.each.n,
                percent.stop = percent.stop, summary.stat = summary.stat,
                time = time.total, seed = seed)

  return(mylist)
}

