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

############################################
# SPRT Threshold: Bayesian and Frequentist #
############################################

##############
# Hypothesis #
##############

# H0: ve = ve.null  vs H1: ve != ve.null (= ve.alt)
# where ve.null and ve.alt are the null and alternative values based on vaccine efficacy(ve)
# Similarly, we can write in terms of relative risk (phi)
# H0: phi = phi0 = 1 - ve.null  vs H1: phi = phi1 = 1 - ve.alt

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

####################################################################
# Function of finding thresholds for Bayesian and Frequentist SPRT #
####################################################################

# This function returns the design specifications and the efficacy and futility
# boundaries based on the optimum interim for frequentist and Bayesian SPRT

SPRTboundary = function(method, n.event, n.start, n.increment = 1,
                        ve.null = 0, ve.alt, type1 = 0.025, power = 0.9, ratio.alloc = 1,
                        optimum.w = TRUE, w = 0.5, a.prior, b.prior = 1){

  if (w<0|w>1){
    stop('Weight should be between 0 to 1')
  }

  if (!method %in% c('Bayes', 'Freq')){
    stop('Method must be one of Bayes/Freq')
  }

  #method: Provide "Freq" for frequentist approach; "Bayes" for Bayesian approch
  #n.event: Total number of events
  #n.start: The event to start the study
  #n.increment: Differences between two interim, by default 1
  #ve.null: Vaccine efficacy under null
  #ve.alt: Vaccine efficacy under alternative
  #type1: Specified Type I error, by default 0.025
  #power: Specified power, by default 0.9
  #ratio.alloc: Treatment vs control randomization = M:1, provide M
  #optimum.w: TRUE if use optimum weight; FALSE if used provide the shape parameter a.prior
  #w: Weight to calculate shape of Beta prior if method = "Bayes" and optimum.w = TRUE
  #a.prior: Shape parameter of Beta prior if method = "Bayes" and optimum.w = FALSE
  #b.prior: Scale parameter of Beta prior if method = "Bayes", by default 1

  #Null and alternative values based on probabilities of binomial success
  p0 = ratio.alloc*(1-ve.null)/(ratio.alloc*(1-ve.null)+1)
  p1 = ratio.alloc*(1-ve.alt)/(ratio.alloc*(1-ve.alt)+1)

  #Calculating shape for Beta prior
  if(optimum.w == TRUE){
    p = w*p0 + (1-w)*p1
    a.prior = p/(1-p)
  }else if(optimum.w == FALSE){
    a.prior = a.prior
  }

  #Threshold values based on SPRT
  a.val = log(((1-power)/(1-type1)), base = exp(1))
  b.val = log(((power)/type1), base = exp(1))

  #Vector of events
  n.val = seq(n.start, n.event, by = n.increment)
  n.count = length(n.val)

  dec = vector("list", n.count)
  r1 = matrix(NA, n.count, 1)
  r2 = matrix(NA, n.count, 1)
  logTest = vector("list", n.count)
  for(k in 1:n.count){

    #Calculation of the Decision for Bayesian SPRT
    test.val = rep(NA, (n.val[k]+1))
    decision = rep(NA, (n.val[k]+1))
    x =  rep(NA, (n.val[k]+1))

    #Initialization for Bayesian
    m_0 = rep(NA, (n.val[k]+1))
    m_1 = rep(NA, (n.val[k]+1))
    a_post = rep(NA, (n.val[k]+1))
    b_post = rep(NA, (n.val[k]+1))

    #Initialization for Frequentist
    ratio =  rep(NA, (n.val[k]+1))

    #Loop for each n
    for(i in 1:(n.val[k]+1)){
      x[i] = i-1

      if(method == "Bayes"){
        #Posterior parameters
        a_post[i] = a.prior + x[i]
        b_post[i] = b.prior + n.val[k] - x[i]

        #Marginal distributions
        m_0[i] = choose(n.val[k],  x[i])*beta(a_post[i], b_post[i])*(1-pbeta(p0, a_post[i], b_post[i]))/(beta(a.prior, b.prior)*(1-pbeta(p0, a.prior, b.prior)))
        m_1[i] = choose(n.val[k],  x[i])*beta(a_post[i], b_post[i])*(pbeta(p1, a_post[i], b_post[i]))/(beta(a.prior, b.prior)*(pbeta(p1, a.prior, b.prior)))

        #Test value based on bayes factor
        test.val[i] = log(m_1[i], base = exp(1)) - log(m_0[i], base = exp(1))
      }else if(method == "Freq"){
        #Likelihood ratio
        ratio[i] = (p1^x[i]*(1-p1)^(n.val[k]-x[i]))/(p0^x[i]*(1-p0)^(n.val[k]-x[i]))
        #Test value based on LR
        test.val[i] = log(ratio[i], base = exp(1))
      }else{
        print("Not available for this function")
      }

      #Decision based on threshold of SPRT
      if(test.val[i] > b.val){
        decision[i] = 1#"Accept H1"
      }else if(test.val[i] < a.val){
        decision[i] = 2#"Accept H0"
      }else{
        decision[i] = 3#"Continue"
      }
    }

    logTest[[k]] = cbind(n.val[k], x, test.val, decision)
    colnames(logTest[[k]]) = c("n", "x", "Test.value", "Decision")

    # Futility bound
    r2[k] = min(logTest[[k]][which(logTest[[k]][,4] == 2),2])

    # Efficacy bound
    r1cond = logTest[[k]][which(logTest[[k]][,4] == 1),2]
    Stop_Eff0 = pbinom(logTest[[k]][,2], n.val[k], p0)

    # Control interim alpha;
    index.cond = x[which(n.val[k] < .6*n.event & Stop_Eff0>(ve.alt-ve.null)*type1)]
    index.del = which(r1cond %in% intersect(index.cond, r1cond))
    r1[k] = ifelse(length(index.del == "TRUE")>0, max(r1cond[-index.del]), max(r1cond))
  }

  boundary = data.frame(n.val, r1, r2)
  colnames(boundary) = c("m", "lower", "upper")

  boundary.list = list(boundary = boundary, method = method, n.event = n.event,
                       n.start = n.start, n.increment = n.increment, ve.null = ve.null,
                       ve.alt = ve.alt, type1 = type1, power = power,
                       ratio.alloc = ratio.alloc, optimum.w = optimum.w, w = w,
                       a.prior = a.prior, b.prior = b.prior)

  return(boundary.list)
}

