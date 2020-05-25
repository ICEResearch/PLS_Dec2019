# DataAnalysis README

This folder contains the scripts used to analyze the data and generate the figures
used in the paper (with the exception of data processing, which takes in the 
raw data and outputs data that has been trimmed and PWelched, and is done in 
DataProcessing >> process.m).

## Scripts
A brief overfiew of the various scripts and their functions is provided here.

- **CalculateCapacity.m:** Function used to calculated capacity. Primarily 
used inside of GaussianCapacity.m   
- **CalculateSecrecyCapacity.m:**  Function used to calculate secrecy capacity.
Primarily used inside of GaussianSecrecyCapacity.m    
- **GaussianCapacity.m:** Uses data from process.m (ProcessedResultsFeb2020.mat) to generate
plots of capacity vs time, as well as the associated histograms.    
- **GaussianSecrecyCapacity.m:** Uses data from CalculateCapacity.m to generate
plots of secrecy capacity vs time, as well as the associated histograms   
- **plotHistogram.m:** Generates plots showing histograms of the data in dB
(not capacity). Not really used for anything other than to validate.    
- **RMWeightHier.m:** Copied over from the first paper (Physical-layer Security: 
does it work in a real environment?). Used to calculate the equivocation of 
a Reed-Muller code.  
- **ThresholdCapacity:"** Modified from the V2V magazine paper. Evaluates 
capacity over a number of SNR values, using the threshold method (this is more
like a binary erasure channel: if the signal is not above a certain threshold,
it is "indistinguishable" from the noisefloor and counts as an erasure. 
Otherwise, it has one bit of capacity).
- **ThresholdSecrecyCapacity.m:** Evaluates secrecy capacity over a number of
SNR values, using the threshold method mentioned above.  

