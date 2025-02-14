##' Make ROC curve from sensitivity and specificity
##'
##' This is a wrapper function that takes output from the `gendist_sensspec_cutoff()` function and constructs values for the
##' Receiver Operating Characteric (ROC) curve
##'
##' @param cutoff the maximum genetic distance at which to consider cases linked
##' @param mut_rate mean number of mutations per generation, assumed to be poisson distributed
##' @param mean_gens_pdf the density distribution of the mean number of generations between cases;
##'       the index of this vector is assumed to be the discrete distance between cases
##' @param max_link_gens the maximium generations of separation for linked pairs
##' @param max_gens the maximum number of generations to consider, if `NULL` (default) value set to the highest
##'        number of generations in mean_gens_pdf with a non-zero probability
##' @param max_dist the maximum distance to calculate, if `NULL` (default) value set to max_gens * 99.9th percentile
##'       of mut_rate poisson distribution
##'
##' @return data frame with cutoff, sensitivity, and 1-specificity
##'
##' @author Shirlee Wohl and Justin Lessler
##'
##' @examples
##' # ebola-like pathogen
##' R <- 1.5
##' mut_rate <- 1
##'
##' # use simulated generation distributions
##' data('genDistSim')
##' mean_gens_pdf <- as.numeric(genDistSim[genDistSim$R == R, -(1:2)])
##'
##' # get theoretical genetic distance dist based on mutation rate and generation parameters
##' dists <- as.data.frame(gendist_distribution(mut_rate = mut_rate,
##'                        mean_gens_pdf = mean_gens_pdf,
##'                        max_link_gens = 1))
##'
##' dists <- reshape2::melt(dists,
##'                         id.vars = 'dist',
##'                         variable.name = 'status',
##'                         value.name = 'prob')
##'
##' # get sensitivity and specificity using the same paramters
##' roc_calc <- gendist_roc_format(cutoff = 1:(max(dists$dist)-1),
##'                                mut_rate = mut_rate,
##'                                mean_gens_pdf = mean_gens_pdf)
##'
##' @family genetic distance functions
##' @family ROC functions
##'
##' @export
##'

gendist_roc_format <- function(cutoff, mut_rate, mean_gens_pdf, max_link_gens = 1,
    max_gens = NULL, max_dist = NULL) {
    if (is.null(max_gens))
        max_gens <- which(mean_gens_pdf != 0)[length(which(mean_gens_pdf != 0))]
    if (is.null(max_dist))
        max_dist <- suppressWarnings(max_gens * stats::qpois(0.999, mut_rate))

    rc <- gendist_sensspec_cutoff(cutoff, mut_rate, mean_gens_pdf, max_link_gens,
        max_gens, max_dist)

    # turn this into a data frame that can be used for plotting ROC curves
    rc <- as.data.frame(rc)

    # calculate 1-specificity for plotting
    rc$specificity <- 1 - rc$specificity

    # add the starting and ending points to make the complete curve
    rc <- rbind(c(-1, 0, 0), rc, c(Inf, 1, 1))

    return(rc)
}
