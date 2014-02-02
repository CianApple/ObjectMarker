ObjectMarker
============

ObjectMarker is a tool to generate positive.txt files for projects that use OpenCV haar-training.


The story goes like, once upon a time a programmer was working on OpenCV for object detection. Ah!!! lets cut it short. 

I have designed this tool to minimize the work of generating the positive.txt files which are to be used to train the system
using the Haar-training method for detecting objects. Till what i can see is only a C++ (ObjectMarker.cpp), that is 
generally used for the object marking process. This object marking proces could be tedious as it involves 100's & 1000's 
(not the candies) of images to be marked for the object detection process to work fine. So I decided to make this process 
mobile. 

This project is not yet a standalone. It will only run in a simulator of xcode and the images are also to be placed manually
in the documents directory. This is because I only needed this much functionality.

But for serious users I can enhance this tool to capture videos, separate them into images, mark them, after finishing,
email the file to your mailbox etc. Many things still could be done. So if needed I can implement these functionalities,
provided if I have time.

By far, till I know this is the only tool for a mobile device and it could come very handy if you dont want to sit before
the computer for hours and hours to mark the images. Its very easy to use, so there is no need for a guide.

If need anything, contact me : jai.dhorajia@gmail.com

