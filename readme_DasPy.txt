### DasPy 1.0 ###
The objective of DasPy development is for the multisources and multivariate land data assimilation applications, such as soil moisture, soil temperature and joint state and parameter estimation. DasPy includes following components:
 (QQ Group:470154780)
 
### Model Operator: ###
  * CLM - Interface to Community Land Model 4.5

### Assimilation Algorithm: ###
  * Local Ensemble Transform Kalman Filter (https://code.google.com/p/miyoshi/)
  * Parallel Data Assimilation Framework (EnKF, ETKF, LETKF, ESTKF, LESTKF) -- Only for test
 
### Perturbation Method: ###
  * Initial Condition
  * Soil Properties (Sand fraction, Clay fration and Organic matter desntiy)
  * Vegetation Properties (Leaf area index)
  * Atmospheric Forcing
 
### Observation Operator: ###
  1. CMEM - Interface to Community Microwave Emission Modelling Platform 4.1 (https://software.ecmwf.int/wiki/display/LDAS/CMEM)
  2. COSMIC - COsmic-ray Soil Moisture Interaction Code (http://cosmos.hwr.arizona.edu/)
  3. TSF - Two-Source Formulation

### Parallel Computing: ###
  1. mpi4py - Message Passing Interface (MPI)
  2. parallelpython - Open Multi-Processing (OpenMP)
  3. SciPy-Weave - C++ && OpenMP

### Run Platform: ###
  1. JUROPA (http://www.fz-juelich.de/ias/jsc/EN/Expertise/Supercomputers/JUROPA/JUROPA_node.html)
  2. Linux
  3. GCC (tested for 4.7.3, 4.8.2, 4.9.2)
  4. Python 2.7

### References: ###
 10. Han, X., Hendricks Franssen, H.-J., Jim��nez Bello, M. ��., Rosolem, R., Bogena, H., Alzamora, F. M., Chanzy, A., and Vereecken, H.: Simultaneous soil moisture and properties estimation for a drip irrigated field by assimilating cosmic-ray neutron intensity, Journal of Hydrology, 539, 611-624, 2016.
  9. Han, X., Li, X., He, G., Kumbhar, P., Montzka, C., Kollet, S., Miyoshi, T., Rosolem, R., Zhang, Y., Vereecken, H., and Franssen, H. J. H.: DasPy 1.0 &ndash; the Open Source Multivariate Land Data Assimilation Framework in combination with the Community Land Model 4.5, Geosci. Model Dev. Discuss., 8, 7395-7444, 2015. 
  8. Han, X., Franssen, H. J. H., Rosolem, R., Jin, R., Li, X., and Vereecken, H.: Correction of systematic model forcing bias of CLM using assimilation of cosmic-ray Neutrons and land surface temperature: a study in the Heihe Catchment, China, Hydrology and Earth System Sciences, 19, 615-629, 2015a.
  7. Han, X., Li, X., Rigon, R., Jin, R., and Endrizzi, S.: Soil moisture estimation by assimilating L-band microwave brightness temperature with geostatistics and observation localization, Plos One, 10, e0116435, 2015b.
  6. Han, X. J., Franssen, H. J. H., Montzka, C., and Vereecken, H.: Soil moisture and soil properties estimation in the Community Land Model with synthetic brightness temperature observations, Water Resour Res, 50, 6081-6105, 2014a.
  5. Han, X. J., Jin, R., Li, X., and Wang, S. G.: Soil Moisture Estimation Using Cosmic-Ray Soil Moisture Sensing at Heterogeneous Farmland, Ieee Geoscience and Remote Sensing Letters, 11, 1659-1663, 2014b.
  4. Han, X. J., Franssen, H. J. H., Li, X., Zhang, Y. L., Montzka, C., and Vereecken, H.: Joint Assimilation of Surface Temperature and L-Band Microwave Brightness Temperature in Land Data Assimilation, Vadose Zone J, 12, 0, 2013.
  3. Han, X., Li, X., Franssen, H. J. H., Vereecken, H., and Montzka, C.: Spatial horizontal correlation characteristics in the land data assimilation of soil moisture, Hydrology and Earth System Sciences, 16, 1349-1363, 2012.
  2. Montzka, C., Pauwels, V. R., Franssen, H. J., Han, X., and Vereecken, H.: Multivariate and multiscale data assimilation in terrestrial systems: a review, Sensors (Basel), 12, 16291-16333, 2012.
  1. Han, X. and Li, X.: An evaluation of the nonlinear/non-Gaussian filters for the sequential data assimilation, Remote Sens Environ, 112, 1434-1449, 2008.

### Acknowledgements: ###
The study of this work was supported by:
  1. NSFC (National Science Foundation of China) project (grant number: 41271357, 91125001)
  2. DFG (Deutsche Forschungsgemeinschaft) Forschergruppe 2131 "Data Assimilation for Improved Characterization of Fluxes across Compartmental Interfaces"
  3. Transregional Collaborative Research Centre 32, financed by the German Science foundation
  4. Supercomputing facilities of Forschungszentrum Julich (JUROPA)