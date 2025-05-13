This repository contains a MATLAB script designed for processing videos of LCD displays and extracting numerical readings using image processing and optical character recognition (OCR). The tool is especially useful in laboratory scenarios where direct electronic interfacing with measurement devices (e.g., pressure gauges) is not feasible—such as during long exposure experiments, where sensor readout is visible only via recorded video.

The script takes a video file and customizable processing parameters as input, isolates the display region, performs image enhancement and segmentation, and applies OCR to extract frame-by-frame values. It then aggregates and outputs a time-series list of all detected readings.

Features:

LCD region isolation and stabilization

Pre-processing for noise reduction and contrast enhancement

Frame-wise digit detection using MATLAB’s built-in OCR functions

Export to .xlsx for downstream analysis

Tunable parameters for digit size, thresholding, frame range, etc.

Applications:

Analog or digital pressure gauge readouts

Long-duration monitoring of display-based instruments

Lab setups without data-logging ports

Accuracy:

Preliminary testing shows accuracy up to 95% and changes significantly depending on the quality of the video

