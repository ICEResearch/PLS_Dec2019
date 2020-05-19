# New Carriers Branch

## Explanation
As you may already know, when we broadcast our 64-subcarrier signal, some of
the edge carriers are attenuated by the hardware. We normally end up throwing
these out. This time, as we were looking at the way we determined which carriers
to throw out, we realized that it required full information of the channel 
characteristics (it was done by averaging all the frames and looking at the 
noise floor to see when things got attenuated).

Dr. Harrison preferred that we just take the center X carriers, as that would 
be more like what we would actually to do were we to not have measured the
whole environment. 

As such, this branch was made to modify the process.m file accordingly.

Interestingly enough, in the end, the old method ended up taking the center 
42 carriers, anyway. 

In the end, we copied over the working changes to the master branch. This 
ReadMe will likely never see the light of day...