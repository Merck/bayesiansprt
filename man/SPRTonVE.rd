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
\alias{SPRTonVE}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{SPRT on Vaccine Efficacy
%%  ~~function to do ... ~~
}
\description{
This function provides the results for sequential ratio probability test under frequentist and Bayesian setup.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
SPRTonVE(n.sim, boundary.val, ve.null, ve.alt, ve, ratio.alloc, seed)
}

%- maybe also 'usage' for other objects documented here.
\arguments{
\item{n.sim}{
Simulation size, by default 100,000
}
\item{boundary.val}{
The total number of events, efficacy, and futility boundaries based on the interim for SPRT
}
\item{ve.null}{
Vaccine efficacy under null, by default 0
}
\item{ve.alt}{
Vaccine efficacy under alternative
}
\item{ve}{
Vaccine efficacy based on the model, if under null, ve = ve.null; if under alternative, ve = ve.alt
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
ve.null =.3
ve.alt = 0.75
type1 = 0.025
power = 0.9
ratio.alloc = 1
optimum.w = TRUE
b.prior = 1
seed = 134

boundary.result = SPRTboundary(method = method, n.event = n.event,
                               n.start = n.start, n.increment = n.increment,
                               ve.null = ve.null, ve.alt = ve.alt, type1 = type1,
                               power = power, ratio.alloc = ratio.alloc,
                               optimum.w = optimum.w, w = 0.5, b.prior = b.prior)

# Under null hypothesis
SPRTonVE(n.sim = n.sim, boundary.val = boundary.result$boundary,
         ve.null = boundary.result$ve.null, ve.alt = boundary.result$ve.alt,
         ve = boundary.result$ve.null, ratio.alloc = boundary.result$ratio.alloc,
         seed = seed)

}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
