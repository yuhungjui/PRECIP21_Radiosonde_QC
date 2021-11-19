GC_PTU_YEAR_DX.mat:

Ground Check correction table based on co-launches Storm Tracker and Vaisala RS41-SGP.

YEAR: 	Year(s) of co-launches. (e.g., 18_20 indicates co-launches during TASSE 2018 - 2020)
DX: 	The ST surface measurements for the intercomparison are averaged over X seconds before launch time. (e.g., D10 means the averages from 10 sec to 1 sec before launch)

Contains 1 structure called 'GC_PTU'.

The structure contains:
TIME: 	Times of launches for the ST included.
ST_no: 	Serial numbers of the ST included.
P_bias (structure) 	
T_bias (structure)
RH_bias (structure)

P_, T_, RH_bias (structure) contain:
data: 	The data for the biases including outliers.	
mean: 	The mean for the biases except outliers.
std: 	The std. for the biases except outliers.
num:	The number of STs except outliers.

The GC correction tables herein are mainly for surface P measurements. Since the fact that T and RH are easily affected by solar radiation, which requires a more sophisticated correction method.