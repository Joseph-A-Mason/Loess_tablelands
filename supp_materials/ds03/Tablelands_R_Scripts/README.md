## Loess Tablelands Data: R Scripts
This directory contains archived R scripts used to analyze and visualize data for the paper:

Mason, J.A., McDowell, T.M., and Vo, T. In review. Evolution of loess tablelands in the Central Great Plains: Relief generation by loess accumulation and the importance of closed depressions.

All scripts have been run successfully in R 4.2.2

**convert_to_tif_2.R** and **convert+to_txt_2.R** can be used to convert between the ESRI ascii text DEMs that are output from the landscape evolution model and the more compact tiff format in which these DEMs are archived.

**drainage_net_analysis_2.R** identifies closed depressions and generates a drainage network in a real or simulated landscape, using GRASS GIS and Whitebox tools within QGIS, via the qgisprocess R package, plots results, and saves them as raster or vector files. Used for Figure 4.

**geomorphons_d_density_2.R** carries out a geomorphons analysis on all output DEMs from a landscape evolution model run, individual output DEMs, or DEMs of real tablelands. The geomorphons analysis is followed by calculation and mapping of the Valley Density Index as described in the paper text. Used for Figure 10.

**model_erosion_analysis_2.R** Uses erosion rate maps output every 250 model years to calculate and plot cumulative erosion/deposition and fraction of deposited loess remaining as domain means or point values, over the 26,000 yr modeled or for one output time. Used for Figure 8.

**rayshader_model_animation_2.R** creates a 3D perspective view of the modeled landscape at each 250 model yr output time, then combines these as frames in an animation, and **rayshader_model_single_stage_2.R** creates a 3D perspective view for a single output time. Used for Figures 6 and 7.

**slope_analysis_new_2.R** uses DEMs output every 250 model years by the landscape evolution model, DEMs for individual output DEMs, or individual DEMs of real landscapes to produce slope maps. Also analyzes slopes by 10 m elevations slice but these results are not used in this paper. Used for Figure 9.

**strength_plots.R** is used to plot strength measurements and perform statistical tests on them. Used for Figure 5.