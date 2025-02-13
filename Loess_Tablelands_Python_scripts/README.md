## Loess Tablelands Python Scripes
This directory contains archived code and data related to the paper:

Mason, J.A., McDowell, T.M., and Vo, T. In review. Evolution of loess tablelands in the Central Great Plains: Relief generation by loess accumulation and the importance of closed depressions.

The two Python scripts represent the landscape evolution model used in this study, built from components of the Landlab toolkit and additional code.

**Loess_Tablelands_v1.py** reads one of two DEMs of bedrock tableland surfaces (og_surf4.txt for the Bedrock-Depressions scenario, og_surf6.txt for the Bedrock-Drain scenario) and uses it for the initial land surface. 

**Loess_Tablelands_v2.py** generates a flat surface (Flat scenario) and optionally adds four closed depressions to it (Flat-Depressions scenario. Random roughness is added in either case. The initial flat surface used by v2 is set at the average elevation of the two bedrock tableland surfaces (1187.9 m); this was done to simplify visualization and has no real impact on model results.

Both scripts are organized to be run in three stages: 0-12,000, 12,000-16,000, and 16,000-26,000 model years. As described in the paper, these represent in simplified form the sequence of Peoria Loess deposition, Brady Soil formation during ongoing but much slower loess deposition, and Bignell Loess deposition at an intermediate rate (deposition here, as in the paper, means initial deposition prior to any erosion or deposition of reworked loess by hillslope and fluvial processes; accumulation is the net build-up of loess). For each stage, the script sets initial parameters and then loops through the appropriate number of 0.2 yr timesteps, also tallying erosion and deposition independent of loess deposition. Every 1250 timesteps (250 model yr), rasters of elevation and average erosion/deposition along with images of elevation and erosion are written.

Model parameters Ksp, D, ωc, and “uplift rate” (=loess deposition rate) are ramped up gradually from first stage values starting 1200 years before the end of that stage, then ramped down again starting 1000 years before the end of the second stage. For v2, ωc is 0 for the first 1200 yr of the first stage, then ramped up to its full value over the next 2400 yr. This was found to be necessary for drainage network initiation in the Flat and Flat-Depressions scenarios. 

**og_surf4.txt** and **og_surf6.txt** are DEMs in ESRI ascii format used to initiate Loess_Tablelands_v1.py for the Bedrock-Depressions and Bedrock-Drain scenarios, respectively. Both were clipped from a 10 m DEM of the Cheyenne Tableland where bedrock is at a shallow depth west of Ogallala, Nebraska. The x and y coordinates have been changed to start at 0,0 in the lowe left (southwest) corner. 