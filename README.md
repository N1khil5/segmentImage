# segmentImage
MATLAB program that takes an image I and segments it. The process is done by convolving the image with multiple Gabor masks. The result is then segmented with the k-means clustering. Following that, the image goes through edge detection to find boundaries. Then the image goes through Gaussian filtering to remove some of the noise. Finally, the resulting image is binarized.
