#' @title MassToPPM
#'
#' @description Allow to convert mass to ppm
#'
#' @param tolerance tolerance mass
#' @param target_mass target mass
#'
#' @return integer
#' @export
#'
MassToPPM <- function(tolerance, target_mass) {
    ppm = int( (tolerance / target_mass) * 1e6)
    return(ppm)
}
