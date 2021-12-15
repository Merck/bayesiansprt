%- Copyright (C) 2021 Merck Sharp & Dohme Corp. a subsidiary of Merck & Co., Inc., Kenilworth, NJ, USA.
%-
%- This file is part of bayesiansprt.
%-
%-     bayesiansprt is free software: you can redistribute it and/or modify
%-     it under the terms of the GNU General Public License as published by
%-     the Free Software Foundation, either version 3 of the License, or
%-     (at your option) any later version.
%-
%-     bayesiansprt is distributed in the hope that it will be useful,
%-     but WITHOUT ANY WARRANTY; without even the implied warranty of
%-     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%-     GNU General Public License for more details.
%-
%-     You should have received a copy of the GNU General Public License
%-     along with bayesiansprt.  If not, see <https://www.gnu.org/licenses/>.

\name{bayesiansprt}
\alias{outputSPRT}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Bayesian and Frequentist SPRT on Vaccine Efficacy
%%  ~~function to do ... ~~
}
\description{
This function provides the combined results for sequential ratio probability test under null and alternative hypothesis for both the frequentist and Bayesian setup.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
outputSPRT(method, n.sim, n.event, n.start, n.increment, ve.null, ve.alt, type1, power,
           ratio.alloc,  optimum.w, w, a.prior, b.prior, seed)
}

%- maybe also 'usage' for other objects documented here.
\arguments{
\item{method}{
Provide "Freq" for Frequentist approach; "Bayes" for Bayesian approach
}
\item{n.sim}{
Simulation size, by default 100,000
}
\item{n.event}{
Total number of events
}
\item{n.start}{
Starting value of the event
}
\item{n.increment}{
Differences between two interims, by default 1
}
\item{ve.null}{
Vaccine efficacy under null, by default 0
}
\item{ve.alt}{
Vaccine efficacy under alternative
}
\item{type1}{
Specified Type I error, by default 0.025
}
\item{power}{
Specified power, by default 0.9
}
\item{ratio.alloc}{
Treatment vs control randomization = M:1, provide M; by default 1
}
\item{optimum.w}{
TRUE if use optimum weight; FALSE if used provide the shape parameter a.prior
}
\item{w}{
Weight for calculating shape parameter of Beta distibution if method = "Bayes" and optimum.w = TRUE; ranges between 0 and 1; by default 0.5
}
\item{a.prior}{
Shape parameter of Beta prior if method = "Bayes" and optimum.w = FALSE
}
\item{b.prior}{
Scale parameter of Beta prior; by default 1
}
\item{seed}{
Seed value to simulate data from binomial, by default 134
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
\item{boundary}{No of events and corresponding efficacy and futility boundaries}
\item{cumulative.prob}{Cumulative probabilities (CP) under null and alternative - number of events, efficacy and futility boundaries, total CP, CP for reject null, CP for accept null under null (if ve = ve.nul) or alternative (if ve = ve.alt)}
\item{type1.power}{Probability of rejecting null under null (if ve = ve.null) or
alternative (if ve = ve.alt)}
\item{prob.VE}{Probabilities that x <= efficacy and x >= futility boundaries-number of events, efficacy and futility boundaries under null (if ve = ve.null) or alternative (if ve = ve.alt)}
\item{percent.stop}{Percentage of average sample sizes at which decision can be made under null and alternative}
\item{summary.stat}{Summary statistics of events: min, Q1, Q2, mean, Q3, max, sd under null and alternative}
\item{time}{Time to run the code under null and alternative}
\item{method}{Provide "Freq" for Frequentist approach; "Bayes" for Bayesian approach}
\item{n.sim}{Simulation size}
\item{n.event}{Total number of events}
\item{n.start}{Starting value of the event}
\item{n.increment}{Differences between two interims}
\item{ve.null}{Vaccine efficacy under null}
\item{ve.alt}{Vaccine efficacy under alternative}
\item{type1}{Specified Type I error}
\item{power}{Specified power, by default 0.9}
\item{ratio.alloc}{Treatment vs control randomization = M:1, value of M}
\item{optimum.w}{Optimum weight}
\item{w}{Weight for calculating shape parameter of Beta distibution}
\item{a.prior}{Shape parameter of Beta prior}
\item{b.prior}{Scale parameter of Beta prior}
\item{seed}{Seed value to simulate data from the binomial distribution}
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Erina Paul <erina.paul@merck.com>
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
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
                     n.increment = 1, ve.null = ve.null, ve.alt = ve.alt,
                     type1 = type1, power = power, ratio.alloc = ratio.alloc,
                     w = seq(0.1, 0.9, by = 0.1), b.prior = b.prior, seed = seed)

results = outputSPRT(method = method, n.sim = n.sim, n.event = n.event, n.start = n.start,
                    n.increment = n.increment, ve.null = ve.null, ve.alt = ve.alt,
                    type1 = type1, power = power, ratio.alloc = ratio.alloc,
                    optimum.w = optimum.w, w = opt.w$weight, b.prior = b.prior, seed = seed)
results
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
