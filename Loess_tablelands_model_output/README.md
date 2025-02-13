## Loess Tablelands Data: Model Output
This directory contains archived code and model output related to the paper:

Mason, J.A., McDowell, T.M., and Vo, T. In review. Evolution of loess tablelands in the Central Great Plains: Relief generation by loess accumulation and the importance of closed depressions.

This directory contains output at 250 model year intervals for the four model scenarios (Flat, Flat-Depressions, Bedrock-Depressions, Bedrock-Drain) along with visualizations and analyses created from that output, also at 250 model year intervals. These data are organizaed into directory by scenario, as well as a "figures" directory with figures comparing results across scenarios. 

In each scenario directory are 105 digital elevation models and 105 maps of erosion/deposition per 250 yr. In both cases these are labeled starting with a number from 100 to 204 (to allow quick sorting). Subtracting 100 from this number, then multiplying by 250 gives the model year represented. The remainder of the label has the format _.0elevation_[stage].tif for the DEMs and _.0erosion_[stage].tif for erosion maps. The stages are Peoria (0-12,000 model years), Brady (12,001 to 16000 model years), and Bignell (16,001 to 26,000 model years). Both DEMs and erosion maps are in geotiff format, converted from the ESRI ascii format exported from the model Python scripts. Elevations are meters and erosion/deposition rates are in meters/250 yr, with deposition rates having negative values. x and y coordinates are in meters with 0, 0 at the southwest (lower right) corner.

Each scenario directory contains a 3D perspective animation produced with the script rayshader_model_animation_2.R. Each also contains an "animation" directory containing images that can be used to produce a map view animation if desired. 

Each scenario directory contains the following subdirectories:

* "erosion mapping": Contains maps of erosion/deposition per year at 250 yr intervals, produced with the R script model_erosion_abalysis_2.R
* "geomorphons": Contains maps of major landform categories identified by the geomorphons analysis at 250 yr intervals, produced with the R script geomorphons_d_density_2.R
* "slope": Contains maps of slope at 250 yr intervals, produced with the R script slope_analysis_new_2.R. Note that these maps are in a different format from the maps of slope at selected time intervals and shown in Figure 9; the latter are produced with a different section of the same script. Also contains maps of 10-m elevation slices for each 250 yr output interval and plots of slope by 10-m elevation slice, neither discussed in the paper.
* "valley_density" contains maps of Valley Density Index (VDI) at 250 yr intervals, produced using the geomorphons_d_density.R script.
* "valleys" includes maps of pixels classified as valleys by the geomorphons analysis, produced using the geomorphons_d_density.R script.

The Figures directory contains four subdirectories with plots of cumulative erosion, elevation, fraction loess remaining, and loess thickness for four sample points, produced using the model_erosion_analysis_2.R script. A text file lists the sample points by x, y coordinates for each scenario. The figures directory also includes plots summarizing domain mean cumulative erosion, domain mean erosion per year, domain fraction loess eroded, and domain sediment yield across all four scenarios. These plots were also produced using model_erosion_analysis_2.R.

