## Loess Tablelands Data: Bedrock Surface Interpolation
This directory contains archived shapefiles of registered wells (or registered wells + geologic testholes) used to interpolate the upper surface of the Ogallala Group or the Broadwater Formation (if present) in this paper:

Mason, J.A., McDowell, T.M., and Vo, T. In review. Evolution of loess tablelands in the Central Great Plains: Relief generation by loess accumulation and the importance of closed depressions.

See the paper text for methods used in the selection and interpretation of these drill hole logs. The three study areas analyzed are referred to as Enders Table, Wauneta Table, and Ogallala W in the paper.

The shapefiles, and details of each, are:

**Enders_wells3.shp**, For Enders Table area. Most relevant fields: RASTERVALU: Surface elevation in meters, DepOg_ft= interpreted depth to top of Ogallala or Broadwater in feet, TopOgm = elevation in meters of the top of the Ogallala or Broadwater, TopOgmI = rounded integer value, for plotting purposes only, x, y = coordinates in UTM zone 14 (not used). Other fields are from registered well shapefile acquired from NE DNR.

**wauneta_wells3.shp**. For Wauneta Table area. Most relevant fields: RASTERVALU = Surface elevation in meters, DepOg_ft= interpreted depth to top of Ogallala or Broadwater in feet, TopOgm = elevation in meters of the top of the Ogallala or Broadwater, TopOgmI = rounded integer value, for plotting purposes only, x, y = coordinates in UTM zone 14 (not used). Other fields are from registered well shapefile acquired from NE DNR.

**Dankorth_TH_RW.shp**. For Ogallala W area. Created by joining two shapefiles representing registered wells and geologic test holes from the Conservation and Survey Division, UNL, after calculation of elevation at the top of bedrock from depth and surface elevation. Only a few directly relevant fields were included in the join: RASTERVALU: Surface elevation in meters, Depg_ft2= interpreted depth to top of Ogallala or Broadwater in feet for registered wells, DepthOg = top (not depth) of Ogallala or Broadwater in feet, TopOg2 = elevation in meters of the top of the Ogallala or Broadwater, TopOgI2 = rounded integer value, for plotting purposes only.

This directory also contains the interpolated top of bedrock surfaces for each area, with surface elevation in meters. All have been clipped to remove areas where the interpolated bedrock surface elevation is above the modern land surface, mainly along dissected tableland margins.

**Idw_Enders_w4_cl.tif** is the Enders Table area

**Idw_wauneta1_cl.tif** is the Wauneta Table area

**Idw_dankwort1_cl.tif** is the Ogallala W area



