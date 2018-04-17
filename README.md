Multi-Omics factor analysis - a framework for unsupervised integration of multi-omic data sets
=========

This repository contains the source code to reproduce the figures of the manuscript ***MultiOmics Factor Analysis disentangles heterogeneity in blood cancer*** ([bioRxiv](https://www.biorxiv.org/content/early/2017/11/10/217554)).  
If you want to use MOFA, [here](https://github.com/bioFAM/MOFA) is the github repository.

Abstract
--------
Multi-omic studies promise the improved characterization of biological processes across molecular layers. However, methods for the unsupervised integration of the resulting heterogeneous datasets are lacking. We present Multi-Omics Factor Analysis (MOFA), a computational method for discovering the principal sources of variation in multi-omic datasets. MOFA infers a set of (hidden) factors that capture biological and technical sources of variability. It disentangles axes of heterogeneity that are shared across multiple modalities and those specific to individual data modalities. The learnt factors enable a variety of downstream analyses, including identification of sample subgroups, data imputation, and the detection of outlier samples. We applied MOFA to a cohort of 200 patient samples of chronic lymphocytic leukaemia, profiled for somatic mutations, RNA expression, DNA methylation and ex-vivo drug responses. MOFA identified major dimensions of disease heterogeneity, including immunoglobulin heavy chain variable region status, trisomy of chromosome 12 and previously underappreciated drivers, such as response to oxidative stress. In a second application, we used MOFA to analyse single-cell multiomics data, identifying coordinated transcriptional and epigenetic changes along cell differentiation.

<p align="center"> 
<img src="https://github.com/bioFAM/MOFA/blob/master/images/workflow.png" style="width: 50%; height: 50%"/>
</p>


Content
-------
* `/CLL_Analysis/`: contains all scripts analysing the MOFA model on the CLL data.
    *  vignette_CLL.Rmd [Rmd](CLL_Analysis/vignette_CLL.Rmd)  (contains all relevant analysis step from model training to the figures shown in the manuscript on the CLL data)

* `/scMT_Analysis/`: contains all scripts analysing the MOFA model on the scMT data.
     * mofa_scMT.Rmd  [Rmd](scMT_analysis/mofa_scMT.Rmd) (contains code for Figure 5 and all supplementary figures related to the scMT data)

* `/model_validation/`: simulations for model validation
    * `/learnK/`: estimating the true number of factors under different dimensionality settings
    * `/nongaussian/`: assessing of non-gaussian likelihoods

* `/GFA_iCluster_comparisons/`: comparison of MOFA with GFA and iCluster
    * `/simulations/`: comparison on simulated data
    * `/scalability/`: comparison in terms of scalability
    * `/CLL/`: comparison on the CLL data

Contact
-------
* Ricard Argelaguet (ricard@ebi.ac.uk) or Britta Velten (britta.velten@embl.de)
