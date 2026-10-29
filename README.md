Lowell's R script for postprocessing LA-ICP-MS data.

Here's the workflow:
1) Read the classic paper by Longerich et al. (1996; JAAS)
2) Collect LA-ICP-MS data, and save it in comma-separated text file format.
3) Use the included R script to select background and peak regions, and generate an output file with net count rates.
4) Open the output net count rates into Excel (or whatever), and calculate the concentrations the way they do in Longerich et al. (1996)

For quality control purposes, be sure to analyze a few (ideally matrix-matched) reference materials with known concentrations so that you can use calibration curves to calculate 95% prediction envelopes about a regression line.
