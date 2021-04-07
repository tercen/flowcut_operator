# flowai operator

#### Description

`flowCut` operator performs quality control on flowcytometry data.

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
`Segment`         | An integer value that specifies the number of events in each segment to be ana-lyzed. A single segment is defaulted to contain 500 events.
`MaxContin`         | A numeric value that defines the critical value at which the difference of themean of a given segment to the mean of an adjacent segment divided by the dif-ference of the 98th percentile and the 2nd percentile for the whole file becomessignificant, indicating a sudden change in the mean for neighbouring segments.The value is defaulted at 0.1.
`MeanOfMeans`     | A numeric value that defines the critical mean value of percentage differencesbetween the difference of the maximum and minimum mean and the differenceof the 98th and 2nd percentile from all segments together.  If the value exceedsthe defaulted critical value of 0.13, which indicates a large gradual change offluorescence in all channels, then the file is flagged.  Formula:  mean( (max(z)-min(z)) / (98th percentile - 2nd percentile) ) >= MeanOfMeans, where z is allthe means of the segments.
`MaxOfMeans`      | A numeric value that defines the critical maximum value of percentage differ-ences between the difference of the maximum and minimum mean and the dif-ference of the 98th and 2nd percentile from all segments together.  If the valueexceeds the defaulted critical value of 0.15, which indicates a very large gradualchange of fluorescence in one channel, then the file is flagged.  Formula:  max((max(z)-min(z)) / (98th percentile - 2nd percentile) ) >= MaxOfMeans, where zis all the means of the segments.
`MaxValleyHgt`    | A numeric value that defines the maximum height of the intersection point of thecutoff line and the density of summed measure plot.  Increasing MaxValleyHgtwill potentially increase the amount of events being cut. The default is 0.1.
`MaxPercCut`      | A numeric value between 0 to 1 that sets the percentage of events that a user iswilling to potentially cut. If the file contains a lot of bad events, we suggest in-creasing this number to potentially cut off more deviates; usually 0.5 is sufficientin this case. The default is 0.3.
`LowDensityRemoval`| A numerical value between 0 and 1.  Any events having a density of less thanLowDensityRemoval are removed. The default is 0.1.
`GateLineForce`   | A numeric value that forces the line in the density distribution plot to a particularvalue.  This will be useful if the user runs a file once and wants to see what thecleaning process would look like if a little more or less was removed. The defaultis NULL.
`UnifTimeCheck`   | A numeric value for the cutoff point when flowCut decides to run or not run itscode. Having too high of a value will increase the chances that flowCut crashes.This issue occurs when the time channel is not uniform.  A simple test is done:If the mean of the time marker is larger than UnifTimeCheck away from themid-point then the file is not run.  Default is set at 0.22.  This is a proportion ofthe range, and hence must be between 0 and 0.5.  Consider only to change thisslightly more positive to allow a few files to have cleaning if they are borderlinecases.
`RemoveMultiSD`   | A numeric value used to remove very statistically different segments even whenthe file is nice.  It is the amount of standard deviations away from the mean ofall segments of which anything larger will be removed. Default is 7, not advisedto reduce this below 3.





##### Details

FlowCut’s methodology is based on identifying both regions of low density and segments (defaultsize of 500 events) that are significantly different from the rest.  
Eight measures of each segment(mean, median, 5th, 20th, 80th and 95th percentile, second moment (variation) and third moment(skewness)) are calculated.  
The density of the summation of the 8 measures and two parameters(MaxValleyHgt and MaxPercCut) will determine which events are significantly different and these will  be  removed.

#### Reference

[flowCut R package]((https://bioconductor.org/packages/release/bioc/html/flowCut.html))

##### See Also

[flowAI R package]((http://bioconductor.org/packages/release/bioc/html/flowAI.html))
[flowClean R package]((http://bioconductor.org/packages/release/bioc/html/flowClean.html))
