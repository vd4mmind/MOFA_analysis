MultiOmics Factor Analysis disentangles heterogeneity in blood cancer
=========

Source code of the manuscript ***MultiOmics Factor Analysis disentangles heterogeneity in blood cancer*** ([bioRxiv](https://www.biorxiv.org/content/early/2017/11/10/217554)).

Abstract
--------
Multi-omic studies in large cohorts promise to characterize biological processes across molecular layers including genome, transcriptome, epigenome, proteome and perturbation phenotypes. However, methods for integrating multi-omic datasets are lacking. We present Multi-Omics Factor Analysis (MOFA), an unsupervised dimensionality reduction method for discovering the driving sources of variation in multi-omics data. Our model infers a set of (hidden) factors that capture biological and technical sources of variability across data modalities. We applied MOFA to data from 200 patient samples of chronic lymphocytic leukemia (CLL) profiled for somatic mutations, RNA expression, DNA methylation and ex-vivo responses to a panel of drugs. MOFA automatically discovered the known dimensions of disease heterogeneity, including immunoglobulin heavy chain variable region (IGHV) status and trisomy of chromosome 12, as well as previously underappreciated drivers of variation, such as response to oxidative stress. These factors capture key dimensions of patient heterogeneity, including those linked to clinical outcomes. Finally, MOFA handles missing data modalities in subsets of samples, enabling imputation, and the model can identify outlier samples.


Content
-------
* `/CLL_Analysis/`: contains all scripts analysing the MOFA model on the CLL data [overview](CLL_Analysis/README.md)
1) import_models.Rmd: 
- imports .hdf5 model files produced by mofa in Python
- sets proper names to models
- tests robustness across initializations and old fits with common patients
- picks a model based on ELBO for further analysis
- gets relevant stuff from the model and Metadata from PACE package
- plots correlation of factors
- save to "out_import.RData" used for the other scripts

2) data_overview.Rmd
- generates the overview tile plot on data in the CLL data set used as input data for MOFA

3) MOFAfactors_overview.Rmd
- Code for Figure 2
- imports "out_import.RData" generated in (1)

4) Analysis_Factor1.Rmd
- Code for Figure 3 and S10 (imputation of IGHV label)
- imports "out_import.RData" generated in (1)

5) survival.Rmd
- Code for Figure 4 and S14 (survival prediction)
- imports "out_import.RData" generated in (1)

Utility function are in
- plotting_utils.R

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

Contact
-------
* Ricard Argelaguet (ricard@ebi.ac.uk) or Britta Velten (britta.velten@embl.de)
