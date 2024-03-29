# flowCut operator

##### Description

The `flowCut` operator performs quality control on flow cytometry data.

##### Usage

Input projection|.
---|---
`row`   | represents the variables (e.g. channels, markers)
`col`   | represents the observations (Use 'Time' on top of rowid.) 
`y-axis`| measurement value


Output relations|.
---|---
`QC_flag`       | character, quality flag `pass` or `fail`

Input parameters|.
---|---
`Segment`         | An integer value that specifies the number of events in each segment to be analyzed. A single segment is defaulted to contain 500 events.
`MaxContin`         | A numeric value that defines the critical value at which the difference of themean of a given segment to the mean of an adjacent segment divided by the dif-ference of the 98th percentile and the 2nd percentile for the whole file becomes significant, indicating a sudden change in the mean for neighbouring segments. The value is defaulted at 0.1.
`MeanOfMeans`     | A numeric value that defines the critical mean value of percentage differences between the difference of the maximum and minimum mean and the differenceof the 98th and 2nd percentile from all segments together.  If the value exceedsthe defaulted critical value of 0.13, which indicates a large gradual change offluorescence in all channels, then the file is flagged.  Formula:  mean( (max(z)-min(z)) / (98th percentile - 2nd percentile) ) >= MeanOfMeans, where z is allthe means of the segments.
`MaxOfMeans`      | A numeric value that defines the critical maximum value of percentage differ-ences between the difference of the maximum and minimum mean and the dif-ference of the 98th and 2nd percentile from all segments together.  If the value exceeds the defaulted critical value of 0.15, which indicates a very large gradualchange of fluorescence in one channel, then the file is flagged.  Formula:  max((max(z)-min(z)) / (98th percentile - 2nd percentile) ) >= MaxOfMeans, where zis all the means of the segments.
`MaxValleyHgt`    | A numeric value that defines the maximum height of the intersection point of the cutoff line and the density of summed measure plot.  Increasing MaxValleyHgtwill potentially increase the amount of events being cut. The default is 0.1.
`MaxPercCut`      | A numeric value between 0 to 1 that sets the percentage of events that a user is willing to potentially cut. If the file contains a lot of bad events, we suggest increasing this number to potentially cut off more deviates; usually 0.5 is sufficient in this case. The default is 0.3.
`LowDensityRemoval`| A numerical value between 0 and 1.  Any events having a density of less than LowDensityRemoval are removed. The default is 0.1.
`RemoveMultiSD`   | A numeric value used to remove very statistically different segments even whenthe file is nice.  It is the amount of standard deviations away from the mean of all segments of which anything larger will be removed. Default is 7, not advisedto reduce this below 3.

##### Details

FlowCut’s methodology is based on identifying both regions of low density and segments (defaultsize of 500 events) that are significantly different from the rest.  
Eight measures of each segment(mean, median, 5th, 20th, 80th and 95th percentile, second moment (variation) and third moment(skewness)) are calculated.  
The density of the summation of the 8 measures and two parameters(MaxValleyHgt and MaxPercCut) will determine which events are significantly different and these will  be  removed.

The operator is a wrapper of the `flowCut` function from the [flowCut R package](https://bioconductor.org/packages/release/bioc/html/flowCut.html).

##### See Also

[flowAI operator](https://github.com/tercen/flowai_operator),
[flowClean operator](https://github.com/tercen/flowclean_operator)
