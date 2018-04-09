Multi-Omics factor analysis - a framework for unsupervised integration of multi-omic data sets
=========

Source code to reproduce the figures of the manuscript ***MultiOmics Factor Analysis disentangles heterogeneity in blood cancer*** ([bioRxiv](https://www.biorxiv.org/content/early/2017/11/10/217554)).  

If you want to use MOFA, [here](https://github.com/bioFAM/MOFA) is the github repository.

Abstract
--------
Multi-omic studies promise the improved characterization of biological processes across molecular layers. However, methods for the unsupervised integration of the resulting heterogeneous datasets are lacking. We present Multi-Omics Factor Analysis (MOFA), a computational method for discovering the principal sources of variation in multi-omic datasets. MOFA infers a set of (hidden) factors that capture biological and technical sources of variability. It disentangles axes of heterogeneity that are shared across multiple modalities and those specific to individual data modalities. The learnt factors enable a variety of downstream analyses, including identification of sample subgroups, data imputation, and the detection of outlier samples. We applied MOFA to a cohort of 200 patient samples of chronic lymphocytic leukaemia, profiled for somatic mutations, RNA expression, DNA methylation and ex-vivo drug responses. MOFA identified major dimensions of disease heterogeneity, including immunoglobulin heavy chain variable region status, trisomy of chromosome 12 and previously underappreciated drivers, such as response to oxidative stress. In a second application, we used MOFA to analyse single-cell multiomics data, identifying coordinated transcriptional and epigenetic changes along cell differentiation.

<p align="center"> 
<img src="https://github.com/bioFAM/MOFA/blob/master/images/logo.png" style="width: 50%; height: 50%"/>​
</p>


Content
-------
* `/CLL_Analysis/`: contains all scripts analysing the MOFA model on the CLL data.

    * `/pre-processing/`: Scripts to pre-process data for input to MOFA
    * `/imputation/`: Scripts for imputation analysis
    * `/robustness/`: Scripts for robustness analysis
    * `/continuity_Factor1/`: characterisation of the continous IGHV phenotype
    
    1) import_models.Rmd [html](CLL_Analysis/import_models.html)
        * imports .hdf5 model files produced by mofa in Python
        * tests robustness across initializations, picks a model based on ELBO for further analysis and checks the factors' correlation
        * saves relevant model and relevant data from the original study (Dietrich, Oles, Lu et al 2017) to "out_import.RData" used for the other scripts

    2) data_overview.Rmd [html](CLL_Analysis/data_overview.html)
        * generates the overview tile plot on data in the CLL data set used as input data for MOFA (part of Fig. 2)

    3) MOFAfactors_overview.Rmd  [html](CLL_Analysis/MOFAfactors_overview.html)
        * Code for Figure 2 (Factor overview)

    4) Factor1.Rmd  [html](CLL_Analysis/Factor1.html)
        * Code to characterize Factor 1 (Figure 3)
    
    5) IGHVstatus.Rmd  [html](CLL_Analysis/IGHVstatus.html)
        * Code to compare IGHV groups with 2 groups based on Factor 1
        
    6) Factor3.Rmd  [html](CLL_Analysis/Factor3.html)
        * Code to characterize Factor 3
    
    7) Factor4.Rmd  [html](CLL_Analysis/Factor4.html)
        * Code to characterize Factor 4
        
    7) Factor5.Rmd  [html](CLL_Analysis/Factor5.html)
        * Code to characterize Factor 5

    7) Factor7.Rmd  [html](CLL_Analysis/Factor7.html)
        * Code to characterize Factor 7

    8) Factor8.Rmd  [html](CLL_Analysis/Factor8.html)
        * Code to characterize Factor 8
    
    9) survival.Rmd  [html](CLL_Analysis/survival.html)
        * Code for Figure 4 and supplementary figures for survival prediction

* `/scMT_Analysis/`: contains all scripts analysing the MOFA model on the scMT data.
    1) mofa_scMT.Rmd  [html](CLL_Analysis/survival.html)
        * Code for Figure 5 and all supplementary figures related to the scMT data

* `/model_validation/`: simulations for model validation
    * `/learnK/`: estimating the true number of factors under different dimensionality settings
    * `/nongaussian/`: assessing of non-gaussian likelihoods


Contact
-------
* Ricard Argelaguet (ricard@ebi.ac.uk) or Britta Velten (britta.velten@embl.de)
