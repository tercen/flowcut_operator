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

flowcut_QC <- function(flowframe, input.pars){
  flowQC <- flowCut (flowframe,
                     Segment= input.pars$segment,
                     Channels=NULL,
                     Directory=NULL,
                     FileID=NULL,
                     Plot="None",
                     MaxContin= input.pars$maxcontin,
                     MeanOfMeans= input.pars$meanofmeans,
                     MaxOfMeans= input.pars$maxofmeans,
                     MaxValleyHgt= input.pars$maxvalley,
                     MaxPercCut= input.pars$maxpercut,
                     LowDensityRemoval= input.pars$lowdensrem,
                     GateLineForce=NULL,
                     UseOnlyWorstChannels=FALSE,
                     AmountMeanRangeKeep=1,
                     AmountMeanSDKeep=2,
                     PrintToConsole=FALSE,
                     AllowFlaggedRerun=FALSE,
                     UseCairo=FALSE,
                     UnifTimeCheck=0.22,
                     RemoveMultiSD= input.pars$remmultisd,
                     AlwaysClean=FALSE,
                     IgnoreMonotonic=FALSE,
                     MonotonicFix=NULL,
                     Verbose=FALSE
  )
  return(flowQC$ind)
}

ctx <- tercenCtx()

if(ctx$cnames[1] == "filename") {filename <- TRUE
if(ctx$cnames[2] != "Time") stop("Time not detected in the second column.")
}else{filename <- FALSE
if(ctx$cnames[1] != "Time") stop("filename or Time not detected in the top column.")
}

celldf <- ctx %>% dplyr::select(.ri, .ci) 
if(nrow(celldf) != length(table(celldf)))stop("There are multiple values in one of the cells.")


input.pars <- list(
  segment = ifelse(is.null(ctx$op.value('Segment')), 500, as.double(ctx$op.value('Segment'))),
  maxcontin = ifelse(is.null(ctx$op.value('MaxContin')), 0.1, as.double(ctx$op.value('MaxContin'))),
  meanofmeans = ifelse(is.null(ctx$op.value('MeanOfMeans')), 0.13, as.double(ctx$op.value('MeanOfMeans'))),
  maxofmeans = ifelse(is.null(ctx$op.value('MaxOfMeans')), 0.15, as.double(ctx$op.value('MaxOfMeans'))),
  maxvalley = ifelse(is.null(ctx$op.value('MaxValleyHgt')), 0.1, as.double(ctx$op.value('MaxValleyHgt'))),
  maxpercut = ifelse(is.null(ctx$op.value('MaxPercCut')), 0.3, as.double(ctx$op.value('MaxPercCut'))),
  lowdensrem = ifelse(is.null(ctx$op.value('LowDensityRemoval')), 0.1, as.double(ctx$op.value('LowDensityRemoval'))),
  remmultisd = ifelse(is.null(ctx$op.value('RemoveMultiSD')), 7, as.double(ctx$op.value('RemoveMultiSD')))
)

marker_names <- ctx$rselect()
marker_list <- lapply(seq_len(nrow(marker_names)), function(i) marker_names[[i,1]])

if(filename == TRUE){
  data <- ctx$as.matrix() %>% t() 
  colnames(data) <- marker_list
  data <- data %>% cbind((ctx$cselect(ctx$cnames[[2]]))) %>% cbind((ctx$cselect(ctx$cnames[[1]])))
}
if(filename == FALSE){
  data <- ctx$as.matrix() %>% t() 
  colnames(data) <- c(marker_list)
  data <- data %>% cbind((ctx$cselect(ctx$cnames[[1]])))
  data$filename <- "singlefile"
}

filenames <- unique(data$filename)
qc_df <- data.frame(matrix(ncol=0, nrow=nrow(data)))

QC_allfiles <- lapply(filenames, function(x) {
  singlefiledata <- data[data$filename == x,]
  singlefileflowframe <- singlefiledata[1:(ncol(singlefiledata)-1)] %>% as.matrix() %>% matrix2flowFrame()
  QC_indice <- flowcut_QC(singlefileflowframe, input.pars)
  nrowdata <- data.frame(matrix(ncol=0, nrow=nrow(singlefiledata)))
  return(ifelse(rownames(nrowdata) %in% QC_indice, "fail", "pass"))
})

qc_df$QC_flag <- do.call(c, QC_allfiles)
flowcut_QC <- cbind(qc_df, .ci = (0:(nrow(qc_df)-1)))
ctx$addNamespace(flowcut_QC) %>% ctx$save()
