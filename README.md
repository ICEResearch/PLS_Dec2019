MARB Testing:

    Purpose: Determine effects of traffic on secrecy capacity.

    Location: MARB, main floor

    Procedure:
    - We set up a transmitter on the southern wall by the eastern doors,
         93 inches above the ground, and attached the amplifier 
    - We set up 5 receivers on desks approximately 30 inches high, and one
         more receiver was set on the near stair case, ~1 foot above the others
         (See marbRxLocations_labeled.pdf for in image, as well as distances.
            Note that the Rx locations on the map are not exact.)
    - Each receiver was set up in a way that put the antenna directly in between 
        the laptop camera and the transmitter, which let us easily check for 
        line-of-sight obstructions in the video
    - Each laptop ran date_time_test.py (which resulted in a .avi video file
        and a .txt file with timestamps for each video frame) and MarbRx_Feb2020.m
        (which recorded the received signal, and timestamps, in a .mat file)
    - We recorded data two times: The first was while the halls were mostly
        empty, the second during class break when there was more traffic.
        Both scenarios lasted for four minutes.
   
    Processing:
    (IN PROGRESS
       
    Data:
    - Each .mat, .avi, and .txt file can be found on Box at 
        https://byu.app.box.com/folder/103939543408
  
    Other:
    - Two other mini-experiments (Donut Capacity: Distance vs Capacity, and
         MarchControlledTests: Obstacle proximity vs capacity) were also done
        during this experiment, and are located in their respective folders
        with ReadMe.md files explaining them more thoroughly.

