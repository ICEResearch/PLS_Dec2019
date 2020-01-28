################# DATE TIME CAMERA RECORDING PROGRAM #################
### Created by Ethan Angerbauer ICE Research Group Mon Jan 13 2020 ###
######################################################################

# Import the time and openCV library
import time
import cv2
import os

# Following code was taken from an online tutorial for recording webcam feed  #
###############################################################################
filename = 'test_video_new.avi'  # Produces a warning when using mp4 but still works
frames_per_second = 28
res = '720p'

# Set resolution for the video capture
# Function adapted from https://kirr.co/0l6qmh
def change_res(cap, width, height):
    cap.set(3, width)
    cap.set(4, height)

# Standard Video Dimensions Sizes
STD_DIMENSIONS =  {
    "480p": (640, 480),
    "720p": (1280, 720),
    "1080p": (1920, 1080),
    "4k": (3840, 2160),
}


# grab resolution dimensions and set video capture to it.
def get_dims(cap, res='1080p'):
    width, height = STD_DIMENSIONS["480p"]
    if res in STD_DIMENSIONS:
        width, height = STD_DIMENSIONS[res]
    # change the current capture device
    # to the resulting resolution
    change_res(cap, width, height)
    return width, height

# Video Encoding, might require additional installs
# Types of Codes: http://www.fourcc.org/codecs.php
VIDEO_TYPE = {
    'avi': cv2.VideoWriter_fourcc(*'XVID'),
    'mp4': cv2.VideoWriter_fourcc(*'XVID'),
}

def get_video_type(filename):
    filename, ext = os.path.splitext(filename)
    if ext in VIDEO_TYPE:
      return VIDEO_TYPE[ext]
    return VIDEO_TYPE['avi']



cap = cv2.VideoCapture(0)
out = cv2.VideoWriter(filename, get_video_type(filename), frames_per_second, get_dims(cap, res))
###############################################################################
print(time.ctime())
while time.ctime() != "Wed Jan 22 07:47:00 2020":
    continue
while cv2.waitKey(1) & (time.ctime() != "Wed Jan 22 07:47:10 2020"):
    ret, frame = cap.read()
    out.write(frame)
    cv2.imshow('frame', frame)
print("Successfully exited")
cap.release()
out.release()
cv2.destroyAllWindows()








