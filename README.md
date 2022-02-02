# Bash_Scripts_For_Brain_MRI
 
## Development of an automatized method to evaluate the projections between the entorhinal cortex and the hippocampus 

### Cláudia Alves, Victor Alves and Tiago Gil Oliveira
- University of Minho, Braga, Portugal.

This project is the result of Cláudia Alves (a80790@alunos.uminho.com), Victor Alves (valves@di.uminho.pt) and Tiago Gil Oliveira (tiago@med.uminho.pt) work, having been developed as part of Cláudia Alves' Master Thesis in Biomedical Engineering, Medical Informatics Branch from University of Minho.

## Abstract

   The purpose of this dissertation was to develop a method that automatically evaluated the 
connections between the hippocampus and the entorhinal cortex (EC) with the possibility of later using 
that evaluation to determine diseases that affect those structures, such as AD. This could potentially help 
detect illnesses at an early stage, which in turn could allow for better management of the lives of patients
with an untreatable disease as well as provide the basis forselection of patients for more effective planning 
of clinical trials.
    For that goal, a dataset containing data from three groups, healthy controls (CN), mild cognitive 
impairment (MCI), and Alzheimer’s disease (AD) patients, was obtained from Alzheimer’s Disease 
Neuroimaging Initiative (ADNI) database. To process the magnetic resonance images, FSL and FreeSurfer
tools were used and, to make the process automatic, the necessary commands were written in bash 
scripts. There was a preprocessing of the images, processing of the structural MRI, processing of the 
diffusion MRI and, tractography was also performed. 
    Upon segmentation of hippocampal-EC connecting fibers, the analyzed diffusion metrics that were 
able to discriminate more accurately between the three groups were: mean diffusivity (MD), axial diffusivity 
(AxD) and, radial diffusivity (RD). Fractional anisotropy (FA) also provided promising results; however, it 
did not discriminate diseased cases as well upon statistical analysis. Volume, on the other hand, did not 
show a correlation with the presence of the disease. Regarding the obtained results in this study, it 
appears that a decrease in FA values and an increase in MD, AxD, and RD are correlated with the presence 
of dementia. Moreover, smaller differences in the average values compared to values from CN subjects 
appear to be associated with MCI, while higher variances are characteristic of AD cases, which suggests 
that various other factors could be contributing to AD pathology.
    In summary, we successfully optimized an automatized method to segment hippocampal-EC
connections, which is a novel approach, further complementing other past studies that focused 
predominantly on separate assessments of either the hippocampus or the EC.

_**Keywords**_: Medical imaging, MRI, Medical informatics, Neuroimaging, Entorhinal Cortex, 
Hippocampus, Alzheimer’s Disease, ADNI

