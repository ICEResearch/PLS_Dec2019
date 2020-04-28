# MARB Testing:
*Purpose*: Determine effects of traffic on secrecy capacity.
*Location*: MARB, main floor

## Procedure:
- A transmitter (ADALM-Pluto) was set up on the southern wall of the eastern 
doors on the ground floor of the MARB, approximately 93 inches off the ground
- An amplifier was attached to the transmitter (will check type when campus opens)
- 6 Receivers were set up on desks approximately 30 inches high at varying 
distances from the transmitter. See marbRxLocations_labeled.pdf for image
(Note that 2 more were set up on stairs, but the data was unused)
- A laptop for each receiver was set up in a way that put the receiving antenna
directly between the laptop camera and the transmitter, which allowed for clear
identification of line-of-sigh obstructions in the recorded video
- Each laptop ran date_time_test.py (which generated a .avi video file and a 
.txt file with timestamps for each video frame) and MarbRx_Feb2020.m (which recorded
the received signal, and timestamps, in a .mat file)
- Data was recorded two times: the first when the halls were mostly empty, 
the second during a class break when there was more traffic. Both scenarios
lasted for four minutes.
   
## Processing:
(IN PROGRESS
       
## Data:
- Each .mat, .avi, and .txt file can be found on Box at 
https://byu.app.box.com/folder/103939543408
  
## Other:
- Two other mini-experiments (Donut Capacity: Distance vs Capacity, and
 MarchControlledTests: Obstacle proximity vs capacity) were also done
during this experiment, and are located in their respective folders
with ReadMe.md files explaining them more thoroughly.

