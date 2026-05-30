# NEXTHREAT_tools
This repository contains a template for a bioinformatic pipeline developed in collaboration with BU-ISCIII.The pipeline is a viral taxonomy classificator, designed for clinical and enviromental paired end samples with short reads. 

This github contains five main folders: 
- ANALYSIS: this folder contains other 9 folders one per pipeline step, for further information and how to run the pipeline, you can look at the wiki. There are two scripts within the ANALYSIS folder the lablog, which will create the 00-reads folder and the create_assembly.R which once the pipeline has finished will create a summary of the assembly, reads, mapped reads, host reads, etc.
- DOC: the information and documentation regarding this pipeline
- RAW: this folder contains the short raw reads for the service
- REFERENCES: this folder contains the databases needed for the sequence aligment and taxonomy assigment
- RESULTS: once the pipeline is finished, the results will be saved in this folder

Within ANALYSIS you can find an extra non-numbered folder named auxiliar scripts inside are the scripts used for developing the statistical analysis for the TFM (during which this pipeline was developed), however, they are not needed for the pipeline itself

## SOFTWARES AND DEPENDENCIES

<img width="3496" height="2423" alt="Plantilla de flujo de procesos de negocio" src="https://github.com/user-attachments/assets/1ad0bd06-447a-450c-9282-d605dce7869a" />

The image above shows the pipeline workflow, which employs the following software versions:
- FASTQC v0.11.9
- FASTP v0.20.0
- MultiQC v1.30
- Kraken2 v2.0.8
- SPAdes v4.0.0
- QUAST v5.2.0
- DIAMOND v2.1.12
- Krona v2.8.1
