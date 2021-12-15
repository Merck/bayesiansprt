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
\alias{SPRToptimumW}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Optimum weight for Beta prior in Bayesian SPRT
%%  ~~function to do ... ~~
}
\description{
This function provides the optimum weight for calculating the shape parameter of the Beta prior in Bayesian SPRT.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
SPRToptimumW(n.sim, n.event, n.start, n.increment, ve.null, ve.alt, type1, power, ratio.alloc, w, b.prior, seed)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
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
\item{w}{
Vector of weights for calculating the shape parameter of Beta prior; ranges between 0 and 1
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
\item{weight}{Optimum weight to calculate the shape parameter of the Beta prior}
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
n.sim = 10000
n.event = 60
n.start = 30
n.increment = 5
ve.null =.3
ve.alt = 0.75
type1 = 0.025
power = 0.9
ratio.alloc = 1
w =  seq(0.1, 0.9, by = 0.1)
b.prior = 1
seed = 134

SPRToptimumW(n.sim = n.sim, n.event = n.event, n.start = n.start,
             n.increment = n.increment, ve.null = ve.null, ve.alt = ve.alt,
             type1 = type1, power = power, ratio.alloc = ratio.alloc, w = w,
             b.prior = b.prior, seed = seed)
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
