library(tercen)
library(dplyr)
library(tibble)
library(flowCore)
library(flowCut)

matrix2flowFrame <- function(a_matrix){ 
  
  minRange <- matrixStats::colMins(a_matrix)
  maxRange <- matrixStats::colMaxs(a_matrix)
  rnge <- maxRange - minRange
  
  df_params <- data.frame(
    name = colnames(a_matrix),
    desc = colnames(a_matrix),
    range = rnge,
    minRange = minRange,
    maxRange = maxRange
  )
  
  params <- Biobase::AnnotatedDataFrame()
  Biobase::pData(params) <- df_params
  Biobase::varMetadata(params) <- data.frame(
    labelDescription = c("Name of Parameter",
                         "Description of Parameter",
                         "Range of Parameter",
                         "Minimum Parameter Value after Transformation",
                         "Maximum Parameter Value after Transformation")
  )
  flowFrame <- flowCore::flowFrame(a_matrix, params)
  
  return(flowFrame)
}
ctx <- tercenCtx()

time <- ctx$cselect(ctx$cnames[[1]])
marker_names <- ctx$rselect()
marker_list <- lapply(seq_len(nrow(marker_names)), function(i) marker_names[[i,1]])

data <- ctx$as.matrix() %>% t()
colnames(data) <- marker_list
data <- as.matrix(cbind(data, time))

flowFrame <- matrix2flowFrame(data)

flowCut_QC <- flowCut (flowFrame,
                       Segment=500,
                       Channels=NULL,
                       Directory=NULL,
                       FileID=NULL,
                       Plot="None",
                       MaxContin=0.1,
                       MeanOfMeans=0.13,
                       MaxOfMeans=0.15,
                       MaxValleyHgt=0.1,
                       MaxPercCut=0.3,
                       LowDensityRemoval=0.1,
                       GateLineForce=NULL,
                       UseOnlyWorstChannels=FALSE,
                       AmountMeanRangeKeep=1,
                       AmountMeanSDKeep=2,
                       PrintToConsole=FALSE,
                       AllowFlaggedRerun=FALSE,
                       UseCairo=FALSE,
                       UnifTimeCheck=0.22,
                       RemoveMultiSD=7,
                       AlwaysClean=FALSE,
                       IgnoreMonotonic=FALSE,
                       MonotonicFix=NULL,
                       Verbose=FALSE
)
failed_events <- flowCut_QC$ind
qc_df <- data.frame(matrix(ncol=0, nrow=nrow(data)))
qc_df$QC_flag <- ifelse(rownames(qc_df) %in% failed_events, "fail", "pass")
flowCut_QC <- cbind(qc_df, .ci = (0:(nrow(qc_df)-1)))

result <- ctx$addNamespace(flowCut_QC)
ctx$save(result)
