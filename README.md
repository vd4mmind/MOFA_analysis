MultiOmics Factor Analysis disentangles heterogeneity in blood cancer
=========

Source code of the manuscript ***MultiOmics Factor Analysis disentangles heterogeneity in blood cancer*** ([bioRxiv](XX)).

Abstract
--------
Multi-omics technologies allow biological systems to be probed across molecular layers using transcriptomics, epigenetics, proteomics and perturbation assays. However, there is a lack of generalizable methods for integrating these data modalities. Here, we present MultiOmics Factor Analysis (MOFA), an unsupervised approach that can discover the driving sources of variation in multi-omics data. Our model jointly infers (hidden) factors that capture both biological and technical sources of variability across data modalities. We applied MOFA to data derived from 200 patients with chronic lymphocytic leukemia (CLL), where somatic mutations, RNA expression, DNA methylation and ex-vivo drug response profiles were measured. MOFA automatically identified previously known sources of disease heterogeneity, including immunoglobulin heavy chain variable region (IGHV) status and trisomy of chromosome 12, as well as previously underappreciated drivers of variation, such as oxidative stress and reactive oxygen species. Finally, we demonstrate that the MOFA factors enable missing values to be filled-in, the detection of mislabeled samples, and enhanced prediction accuracy of clinical outcomes.


Content
-------
* `/IGHV_factor/`: characterisation of Factor 1 (IGHV-associated factor)
* `/OverviewFigure/`: plots for the vverview of the data
* `/continuity/`: characterisation of the continous IGHV phenotype
* `/downsampling/`: downsampling analysis
* `/iCluster/`: comparison with iCluster
* `/imputation/`: imputation of drug response
* `/pretreatment_factor/`: characterisation of Factor 7 (associated to preatreatment)
* `/robustness/`: analysis of the robustness of the mode
* `/run_mofa/`: template scripts to run MOFA
* `/scalability/`: scalability analysis of MOFA
* `/simulations/`: assessment of technical capabilities of MOFA on simulated data
* `/sparsity/`: assessment of sparsity priors
* `/stress_factor/`: characterisation of Factor 5 (associated to oxidative stress response)
* `/survival/`: survival analysis 

Data
-------

Contact
-------
* Ricard Argelaguet (ricard@ebi.ac.uk) or Britta Velten (britta.velten@embl.de)
