MultiOmics Factor Analysis disentangles heterogeneity in blood cancer
=========

Source code of the manuscript ***MultiOmics Factor Analysis disentangles heterogeneity in blood cancer*** ([bioRxiv](https://www.biorxiv.org/content/early/2017/11/10/217554)).

Abstract
--------
Multi-omic studies in large cohorts promise to characterize biological processes across molecular layers including genome, transcriptome, epigenome, proteome and perturbation phenotypes. However, methods for integrating multi-omic datasets are lacking. We present Multi-Omics Factor Analysis (MOFA), an unsupervised dimensionality reduction method for discovering the driving sources of variation in multi-omics data. Our model infers a set of (hidden) factors that capture biological and technical sources of variability across data modalities. We applied MOFA to data from 200 patient samples of chronic lymphocytic leukemia (CLL) profiled for somatic mutations, RNA expression, DNA methylation and ex-vivo responses to a panel of drugs. MOFA automatically discovered the known dimensions of disease heterogeneity, including immunoglobulin heavy chain variable region (IGHV) status and trisomy of chromosome 12, as well as previously underappreciated drivers of variation, such as response to oxidative stress. These factors capture key dimensions of patient heterogeneity, including those linked to clinical outcomes. Finally, MOFA handles missing data modalities in subsets of samples, enabling imputation, and the model can identify outlier samples.


Content
-------
* `/CLL_Analysis/`: contains all scripts analysing the MOFA model on the CLL data.

    * `/pre-processing/`: Script to pre-process data for input to MOFA
    
    1) import_models.Rmd [html](CLL_Analysis/import_models.html)
        * imports .hdf5 model files produced by mofa in Python
        * tests robustness across initializations, picks a model based on ELBO for further analysis and checks the factors' correlation
        * saves relevant model and relevant data from the original study (Dietrich, Oles, Lu et al 2017) to "out_import.RData" used for the other scripts

    2) data_overview.Rmd [html](CLL_Analysis/data_overview.html)
        * generates the overview tile plot on data in the CLL data set used as input data for MOFA (part of Fig. 2)

    3) MOFAfactors_overview.Rmd  [html](CLL_Analysis/MOFAfactors_overview.html)
        * Code for Figure 2 (Factor overview)

    4) Factor1.Rmd  [html](CLL_Analysis/Factor1.html)
        * Code to charatcerize Factor 1 (Figure 3)
    
    5) IGHVstatus.Rmd  [html](CLL_Analysis/IGHVstatus.html)
        * Code to compare IGHV groups with 2 groups based on Factor 1
        
    6) Factor3.Rmd  [html](CLL_Analysis/Factor3.html)
        * Code to charatcerize Factor 3
    
    7) Factor4.Rmd  [html](CLL_Analysis/Factor4.html)
        * Code to charatcerize Factor 4
        
    8) Factor8.Rmd  [html](CLL_Analysis/Factor8.html)
        * Code to charatcerize Factor 8
    
    9) survival.Rmd  [html](CLL_Analysis/survival.html)
        * Code for Figure 4 and supplementary figres for survival prediction


* `/continuity/`: characterisation of the continous IGHV phenotype
* `/downsampling/`: downsampling analysis
* `/iCluster/`: comparison with iCluster
* `/imputation/`: assessment of imputation (on the drug response data of the CLL study)
* `/pretreatment_factor/`: characterisation of Factor 7 (associated to preatreatment)
* `/robustness/`: analysis of the robustness of the mode
* `/run_mofa/`: template scripts to run MOFA
* `/scalability/`: scalability analysis of MOFA
* `/simulations/`: assessment of technical capabilities of MOFA on simulated data
* `/sparsity/`: assessment of sparsity priors
* `/stress_factor/`: characterisation of Factor 5 (associated to oxidative stress response)

Data
-------
 The data directory contains annotations used from ENSEMLBE for the gene expression data as well as the fitted MOFA models used for the main analysis.

Contact
-------
* Ricard Argelaguet (ricard@ebi.ac.uk) or Britta Velten (britta.velten@embl.de)
