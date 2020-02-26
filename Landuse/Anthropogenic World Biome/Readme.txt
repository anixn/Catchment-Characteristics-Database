Date: May 17, 2010

Anthromes v2 (Anthropogenic Biomes version 2) Dataset in GeoTiff format.

+++++++++++++++++++++++++++++++++++
*DESCRIPTION*
This archive contains the Anthromes (version 2) dataset, created by Ellis et al. (2010) for years 1700, 1800, 1900 and 2000.  Additional data, including inputs used for analysis are at:
http://ecotope.org/anthromes/v2/data/

These data should be cited as:
Ellis, E. C., K. Klein Goldewijk, S. Siebert, D. Lightman, and N. Ramankutty. 2010. Anthropogenic transformation of the biomes, 1700 to 2000. Global Ecology and Biogeography xx:xxx-xxx.
DOI: 10.1111/j.1466-8238.2010.00540.x

Please contact Erle Ellis for information on updates and other changes at <ece@umbc.edu>.

+++++++++++++++++++++++++++++++++++
*DATA FORMAT*

1) DATA ARCHIVE (download format)
This zip archive contains global Anthropogenic Biome grids in geographic projection at 5 arc minute resolution in GeoTIFF format (ASCII GRID and ESRI GRID formats also available ). To access the grids, the zipfile must be downloaded and extracted into a single folder.  Four grids are provided, in four separate folders, one per century:

/2000/ (year 2000 data)
GeoTIFF = anthro2_a2000.tif

/1900/ (year 1900 data)
GeoTIFF = anthro2_a1900.tif

/1800/ (year 1800 data)
GeoTIFF = anthro2_a1800.tif

/1700/ (year 2000 data)
GeoTIFF = anthro2_a2000.tif


2) DATA FILES (GeoTIFF file format)
Each GeoTIFF file is a complete global data layer for the given year in geographic projection at 5 arc minute resolution (0.083333333 degrees per cell, varying from 85 km2/cell at the equator, to 11 km2/cell at the poles).  This resolution produces a 4320 x 2160 global grid.


3) DATA VALUES

Anthromes (v2) Legend

GRID Values = Anthrome classes**
-------------------------------
value: Anthrome class
11: Urban
12: Mixed settlements
21: Rice villages
22: Irrigated villages
23: Rainfed villages
24: Pastoral villages
31: Residential irrigated croplands
32: Residential rainfed croplands
33: Populated croplands
34: Remote croplands
41: Residential rangelands
42: Populated rangelands
43: Remote rangelands
51: Residential woodlands
52: Populated woodlands
53: Remote woodlands
54: Inhabited treeless and barren lands
61: Wild woodlands
62: Wild treeless and barren lands
_______________________________
** Note that a "LABEL" field with these definitions is attached as a table.


Anthrome classes may be grouped for analysis into Anthrome levels:
-------------------------------
value	level
11	Dense Settlements
12	Dense Settlements
21	Villages
22	Villages
23	Villages
24	Villages
31	Croplands
32	Croplands
33	Croplands
34	Croplands
41	Rangelands
42	Rangelands
43	Rangelands
51	Seminatural
52	Seminatural
53	Seminatural
54	Seminatural
61	Wildlands
62	Wildlands
_______________________________


4) CARTOGRAPHY
Standard colors for Anthrome 2 classes
-------------------------------
Anthrome 2 classes: LEGEND COLORS
value	R	G	B
11	168	0	0
12	255	0	0
21	0	112	255
22	0	169	230
23	169	0	230
24	255	115	223
31	0	255	197
32	230	230	0
33	255	255	115
34	255	255	190
41	230	152	0
42	255	211	127
43	255	235	175
51	56	168	0
52	165	245	122
53	211	255	178
54	178	178	178
61	218	242	234
62	225	225	225
_______________________________

-------------------------------
Anthrome 2 levels: LEGEND COLORS
value	R	G	B
11	205	102	102
12	205	102	102
21	170	102	205
22	170	102	205
23	170	102	205
24	170	102	205
31	255	255	0
32	255	255	0
33	255	255	0
34	255	255	0
41	255	170	0
42	255	170	0
43	255	170	0
51	211	255	190
52	211	255	190
53	211	255	190
54	211	255	190
61	56	168	0
62	56	168	0
_______________________________

*END OF FILE*
+++++++++++++++++++++++++++++++++++