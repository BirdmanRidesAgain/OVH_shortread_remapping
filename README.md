# OVH Short read remapping script
This is my script for remapping and variant calling Illumina short-read data on the OVH. It's based mostly on the code found in the Stone Curlew notes. 
It is modular, and consists of 5 scripts and a config file.

The user supplies a file of all individuals included in the script, which is sourced before every stage, along with the config file.

This file ("${PROJECT_NAME}_inds.list") contains all individuals.


Broadly speaking, the workflow is as follows:

0. Prep reference - (You only run this once)
1. Trim raw reads
2. Map and clean (depth stat output here)
3. Variant calling and combining vcfs - THIS IS LONG.
4. R/RStudio post-processing
