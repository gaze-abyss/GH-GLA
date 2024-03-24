#' givescore
#'
#' @param z
#'
#' @return matrix
#' @export
#'
#' @examples
#' givescore(z)
givescore = function(z){
  tmp.eff1 = tmp.eff$score[z[tmp.dflength]]
  z[which(z == 1 | z == 2)] = tmp.eff1
  z[which(z == -1)] = 0
  z = z[-tmp.dflength]
  z
}
