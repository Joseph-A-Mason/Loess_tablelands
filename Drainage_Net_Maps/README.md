## Results of Closed Depression and Drainage Net Analysis of Loess and Bedrock Tablelands

This directory includes results of closed depression identification and drainage network analysis for ten loess or bedrock tablelands in western Nebraska. To save space, the original 1- or 2-meter DEMs used are not included. They can be retrieved using the extent of the output depression maps (_depr.tif), from the [USGS National Map Download app](https://www.usgs.gov/tools/download-data-maps-national-map) or [Open Topography](https://opentopography.org/).


The R script "Drainage_Net_Analysis.R" was used to produce these maps, with parameters set as in the copy of that script in the directory Tabelelands_R_Scripts. For each tableland, the included datasets are:

__depr.tif: Depression map produced by StochasticDepressionMapper, Whitebox Tools, run as QGIS extension through the R script using the qgisprocess R package.
__rwshd.shp: Flowpaths with > 1000 cell drainage area, produced by r.watershed, GRASS GIS 7.0, run as QGIS extension through the R script using the qgisprocess R package.
__wbt.shp: Flowpaths with > 1000 cell drainage area, produced using BreachDepressions, DinfFlowAccumulation, and ExtractStreams, all in Whitebox Tools run as QGIS extension through the R script using the qgisprocess R package.

(note there are multiple files for each dataset)

List of tablelands analyzed:

Ash_Hollow_W: Bedrock tableland west of Ogallala, Nebraska, part of the Cheyenne Tableland

bartek: Loess tableland, part of West Table (labeled as such on maps), between Merna and Arnold, Nebraska

Bignell_Hill: Loess tableland south of Bignell, Nebraska

e_table_clp2: Loess tableland, East Table (labeled as such on maps), northeast of Broken Bow, Nebraska

enders_2m: Loess tableland, south of Enders Reservoir on Frenchman Creek, Nebraska

Imperial_NE: Bedrock tableland, northeast of Imperial, Nebraska

og_surf_W: Bedrock tableland west of Ogallala, Nebraska, part of the Cheyenne Tableland

og_surf_area_2m: Bedrock tableland west of Ogallala, Nebraska, part of the Cheyenne Tableland

sm_table1_clp2: Loess tableland, Boggs Table (labeled as such on maps), NE of Broken Bow, western Nebraska

tallinn: Loess tableland, Tallinn Table (labeled as such on maps), between Arnold and Gothenburg, Nebraska

wauneta1: Loess tableland, northwest of Wauneta, Nebraska, between Frenchman and Spring creeks

The R script "Drainage_Net_Analysis.R" was used to produce these maps, with parameters set as in the copy of that script in the directory Tabelelands_R_Scripts