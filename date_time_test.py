################# DATE TIME CAMERA RECORDING PROGRAM #################
######################################################################

# Import the time and openCV library
import time
import cv2
import os
from datetime import datetime

######################################################################
fileName = 'Name_Of_Text_File'  # Enter desired name of file here for time stamps
myFile = open(fileName + '.txt', 'w')

startTime = "Mon Feb 10 15:10:00 2020"
endTime = "Mon Feb 10 15:10:10 2020"

filename = 'test_video_new2.avi'  # Choose either avi or mp4
frames_per_second = 30  # Choose frames per second
res = '720p'
######################################################################

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

print(datetime.now().strftime('%H:%M:%S.%f'))
print(time.ctime())

while time.ctime() != startTime:
    continue
while cv2.waitKey(1) & (time.ctime() != endTime):
    ret, frame = cap.read()
    out.write(frame)
    myFile.write(datetime.now().strftime('%H:%M:%S.%f' + '\n'))
    cv2.imshow('frame', frame)
print("Successfully Exited")
myFile.close()
cap.release()
out.release()
cv2.destroyAllWindows()








