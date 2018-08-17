# PHsegment
Scripts for cardiac segmentation and registration applied to pulmonary hypertension.

## Requisities 
Matlab 2016 or later.

Target images in NIfTI format.

3D cardiac atlases.

## Implementation

Run the script with the following arguments:

```RunPAll('targets','3Datlas','PHatlas','3Dshapes',1,0,4)```

Where `targets` are the images to be segmented in NIfTI format; `3Datlas` are the healthy volunteer atlases; and `PHatlas` are the PH patient atlases.

The numerical arguments are: Landmarks (1=yes, 0=no); segment and derive meshes (1) or derive meshes from exisiting segmentations (0); and number of cores for parallel processing.

## Method
The general workflow is decribed below which was developed in a cohort of healthy adults with high-resoltuion cardiac MR imaging. This process was extended to pulmonary hypertension by the annotation of a set of disease specifc atlases with labels that inlcude the right ventricular cavity and freewall.

![diagram](https://github.com/UK-Digital-Heart-Project/PHsegment/blob/master/1-s2.0-S1361841515001346-fx1_lrg.jpg)

## Citation
Detailed methods and validation are described in our paper:

Bai W, Shi W, de Marvao A, Dawes TJ, O'Regan DP, Cook SA, Rueckert D. A bi-ventricular cardiac atlas built from 1000+ high resolution MR images of healthy subjects and an analysis of shape and motion. [Med Image Anal](http://dx.doi.org/10.1016/j.media.2015.08.009). 2015;26:133-145. 

The mean template shape for pulmonary hypertension is available here:

[UK-Digital-Heart-Project/Mean-shape](https://github.com/UK-Digital-Heart-Project/Mean-shape)
