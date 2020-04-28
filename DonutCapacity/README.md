# DONUT CAPACITY TESTS:
**Purpose:** Determine effect of distance on capacity.    
**Location:** Garden Terrace in the Wilkenson Center.  

## Procedure:
- We set up a Tx in the center of the room and cleared out the tables/chairs
- Next, we taped an 'X' on the ground, centered at the receiver, with each leg
extending about 24 feet.
- We marked every four inches along the tape as reference points
- Four receivers were set up on wheeled-desks, and started approximately 
two feet from the transmitter
- For 90 seconds, each desk moved backward along the tape at an ~constant rate,
recording data as they went (donutRx.m)
- The process was repeated after attaching an amplifier to the transmitter

Note that this experiment was done twice, as the first time we used an 
amplifier for both sets and did not get good data.

## Processing:
- Processing and plotting was done with processDonut.m
- Data was loaded, trailing zeros trimmed, and then was Pwelched and FFTShifted
- The log of result was taken, and averaged over a time period, which should 
translate to a specific location (this was done to account for the 
differences in computer speed and make a more consistent plot)
- These results were mapped to distances, and then averaged over the four arrays
- Final results were plotted
(Note that processDonut.m also saved the processed data into the ProcessedData folder)

donutProcess.m and donutCapacity.m followed a slightly different processing
format but did similar things

##vData:
- Data can be found on Box at https://byu.app.box.com/folder/100466204226


