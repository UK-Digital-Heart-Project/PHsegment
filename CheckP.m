function CheckP(folder,patientid,atlas)

if ispc
    seperation = '\';
else
    seperation = '/';
end

cd(folder)

!mkdir dofs
!mkdir tmps
!mkdir vtks
!mkdir segmentations

vtks();

result1 = dir('PHsegmentation_ED.gipl');
[rows1,~]=size(result1);
result2 = dir('PHsegmentation_ES.gipl');
[rows2,~]=size(result2);
if(rows1 == 1 && rows2 == 1)
    
    name = ['ED';'ES'];
    
    for i = 1:2
        delete(['..',seperation,patientid,'_',name(i,:),'_manual.txt'])
        system(['cardiacvolumecount PHsegmentation_',name(i,:),'.gipl 1 -output ..',seperation,patientid,'_',name(i,:),'_manual.txt'])
        system(['cardiacvolumecount PHsegmentation_',name(i,:),'.gipl 2 -output ..',seperation,patientid,'_',name(i,:),'_manual.txt -scale 1.05'])
        system(['cardiacvolumecount PHsegmentation_',name(i,:),'.gipl 4 -output ..',seperation,patientid,'_',name(i,:),'_manual.txt'])
        system(['cardiacvolumecount PHsegmentation_',name(i,:),'.gipl 3 -output ..',seperation,patientid,'_',name(i,:),'_manual.txt -scale 1.05'])
        delete(['..',seperation,patientid,'_',name(i,:),'.txt'])
        system(['cardiacvolumecount segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl 1 -output ..',seperation,patientid,'_',name(i,:),'.txt'])
        system(['cardiacvolumecount segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl 2 -output ..',seperation,patientid,'_',name(i,:),'.txt -scale 1.05'])
        system(['cardiacvolumecount segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl 4 -output ..',seperation,patientid,'_',name(i,:),'.txt'])
        system(['cardiacvolumecount segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl 3 -output ..',seperation,patientid,'_',name(i,:),'.txt -scale 1.05'])
        system(['transformation PHsegmentation_',name(i,:),'.gipl segmentations',seperation,'PHsegmentation_',name(i,:),'_manual.gipl -target segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl -nn'])
        delete(['..',seperation,'atlases_',patientid,'_',name(i,:),'_dicelvendo.txt'])
        delete(['..',seperation,'atlases_',patientid,'_',name(i,:),'_dicelvmyo.txt'])
        delete(['..',seperation,'atlases_',patientid,'_',name(i,:),'_dicelvepi.txt'])
        delete(['..',seperation,'atlases_',patientid,'_',name(i,:),'_dicervendo.txt'])
        delete(['..',seperation,'atlases_',patientid,'_',name(i,:),'_dicervepi.txt'])
        delete(['..',seperation,'atlases_',patientid,'_',name(i,:),'_dicervmyo.txt'])

        system(['dicemetric segmentations',seperation,'PHsegmentation_',name(i,:),'_manual.gipl segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl -minvalue 1 -maxvalue 1 -autoZ -output ..',seperation,'atlases_',patientid,'_',name(i,:),'_dicelvendo.txt'])
        system(['dicemetric segmentations',seperation,'PHsegmentation_',name(i,:),'_manual.gipl segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl -minvalue 2 -maxvalue 2 -autoZ -output ..',seperation,'atlases_',patientid,'_',name(i,:),'_dicelvmyo.txt'])
        system(['dicemetric segmentations',seperation,'PHsegmentation_',name(i,:),'_manual.gipl segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl -minvalue 1 -maxvalue 2 -autoZ -output ..',seperation,'atlases_',patientid,'_',name(i,:),'_dicelvepi.txt'])
        system(['dicemetric segmentations',seperation,'PHsegmentation_',name(i,:),'_manual.gipl segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl -minvalue 4 -maxvalue 4 -autoZ -output ..',seperation,'atlases_',patientid,'_',name(i,:),'_dicervendo.txt'])
        system(['dicemetric segmentations',seperation,'PHsegmentation_',name(i,:),'_manual.gipl segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl -minvalue 3 -maxvalue 3 -autoZ -output ..',seperation,'atlases_',patientid,'_',name(i,:),'_dicervmyo.txt'])
        system(['dicemetric segmentations',seperation,'PHsegmentation_',name(i,:),'_manual.gipl segmentations',seperation,'PHsegmentation_',name(i,:),'.gipl -minvalue 3 -maxvalue 4 -autoZ -output ..',seperation,'atlases_',patientid,'_',name(i,:),'_dicervepi.txt'])

        delete(['..',seperation,'atlases_',patientid,'_',name(i,:),'_surfacedistancervendo.txt'])
        delete(['..',seperation,'atlases_',patientid,'_',name(i,:),'_surfacedistancervepi.txt'])
        system(['sevaluation vtks',seperation,'RV_',name(i,:),'_manual.vtk vtks',seperation,'RV_',name(i,:),'.vtk -output ..',seperation,'atlases_',patientid,'_',name(i,:),'_surfacedistancervendo.txt'])   
        system(['sevaluation vtks',seperation,'RVepi_',name(i,:),'_manual.vtk vtks',seperation,'RVepi_',name(i,:),'.vtk -output ..',seperation,'atlases_',patientid,'_',name(i,:),'_surfacedistancervepi.txt'])
    end
end

levels = strfind(folder, seperation);
[~,rows]=size(levels);
for i = 1:rows
    cd ..
end
cd ..
return

function vtks()

if ispc
    seperation = '\';
else
    seperation = '/';
end

delete(['vtks',seperation,'*.*'])
%auto
system(['binarize segmentations',seperation,'PHsegmentation_ED.gipl tmps',seperation,'vtk_RV_ED.nii.gz 4 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RV_ED.nii.gz vtks',seperation,'RV_ED.vtk 120 -blur 2 -close']);
system(['vtk2txt vtks',seperation,'RV_ED.vtk vtks',seperation,'RV_ED.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ES.gipl tmps',seperation,'vtk_RV_ES.nii.gz 4 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RV_ES.nii.gz vtks',seperation,'RV_ES.vtk 120 -blur 2 -close']);
system(['vtk2txt vtks',seperation,'RV_ES.vtk vtks',seperation,'RV_ES.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ED.gipl tmps',seperation,'vtk_RVepi_ED.nii.gz 3 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RVepi_ED.nii.gz vtks',seperation,'RVepi_ED.vtk 120 -blur 2 -close']);
system(['vtk2txt vtks',seperation,'RVepi_ED.vtk vtks',seperation,'RVepi_ED.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ES.gipl tmps',seperation,'vtk_RVepi_ES.nii.gz 3 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RVepi_ES.nii.gz vtks',seperation,'RVepi_ES.vtk 120 -blur 2 -close']);
system(['vtk2txt vtks',seperation,'RVepi_ES.vtk vtks',seperation,'RVepi_ES.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ED.gipl tmps',seperation,'vtk_LVendo_ED.nii.gz 1 1 255 0']);
system(['mcubes tmps',seperation,'vtk_LVendo_ED.nii.gz vtks',seperation,'LVendo_ED.vtk 120 -blur 2 -close']);
system(['vtk2txt vtks',seperation,'LVendo_ED.vtk vtks',seperation,'LVendo_ED.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ES.gipl tmps',seperation,'vtk_LVendo_ES.nii.gz 1 1 255 0']);
system(['mcubes tmps',seperation,'vtk_LVendo_ES.nii.gz vtks',seperation,'LVendo_ES.vtk 120 -blur 2 -close']);
system(['vtk2txt vtks',seperation,'LVendo_ES.vtk vtks',seperation,'LVendo_ES.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ED.gipl tmps',seperation,'vtk_LVepi_ED.nii.gz 1 2 255 0']);
system(['mcubes tmps',seperation,'vtk_LVepi_ED.nii.gz vtks',seperation,'LVepi_ED.vtk 120 -blur 2 -close']);
system(['vtk2txt vtks',seperation,'LVepi_ED.vtk vtks',seperation,'LVepi_ED.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ES.gipl tmps',seperation,'vtk_LVepi_ES.nii.gz 1 2 255 0']);
system(['mcubes tmps',seperation,'vtk_LVepi_ES.nii.gz vtks',seperation,'LVepi_ES.vtk 120 -blur 2 -close']);
system(['vtk2txt vtks',seperation,'LVepi_ES.vtk vtks',seperation,'LVepi_ES.txt']);

%manual
system(['binarize segmentations',seperation,'PHsegmentation_ED_manual.gipl tmps',seperation,'vtk_RV_ED_manual.nii.gz 4 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RV_ED_manual.nii.gz vtks',seperation,'RV_ED_manual.vtk 120 -blur 2 -close -open']);
system(['vtk2txt vtks',seperation,'RV_ED_manual.vtk vtks',seperation,'RV_ED_manual.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ES_manual.gipl tmps',seperation,'vtk_RV_ES_manual.nii.gz 4 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RV_ES_manual.nii.gz vtks',seperation,'RV_ES_manual.vtk 120 -blur 2 -close -open']);
system(['vtk2txt vtks',seperation,'RV_ES_manual.vtk vtks',seperation,'RV_ES_manual.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ED_manual.gipl tmps',seperation,'vtk_RVepi_ED_manual.nii.gz 3 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RVepi_ED_manual.nii.gz vtks',seperation,'RVepi_ED_manual.vtk 120 -blur 2 -close -open']);
system(['vtk2txt vtks',seperation,'RVepi_ED_manual.vtk vtks',seperation,'RVepi_ED_manual.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ES_manual.gipl tmps',seperation,'vtk_RVepi_ES_manual.nii.gz 3 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RVepi_ES_manual.nii.gz vtks',seperation,'RVepi_ES_manual.vtk 120 -blur 2 -close -open']);
system(['vtk2txt vtks',seperation,'RVepi_ES_manual.vtk vtks',seperation,'RVepi_ES_manual.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ED_manual.gipl tmps',seperation,'vtk_LVendo_ED_manual.nii.gz 1 1 255 0']);
system(['mcubes tmps',seperation,'vtk_LVendo_ED_manual.nii.gz vtks',seperation,'LVendo_ED_manual.vtk 120 -blur 2 -close -open']);
system(['vtk2txt vtks',seperation,'LVendo_ED_manual.vtk vtks',seperation,'LVendo_ED_manual.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ES_manual.gipl tmps',seperation,'vtk_LVendo_ES_manual.nii.gz 1 1 255 0']);
system(['mcubes tmps',seperation,'vtk_LVendo_ES_manual.nii.gz vtks',seperation,'LVendo_ES_manual.vtk 120 -blur 2 -close -open']);
system(['vtk2txt vtks',seperation,'LVendo_ES_manual.vtk vtks',seperation,'LVendo_ES_manual.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ED_manual.gipl tmps',seperation,'vtk_LVepi_ED_manual.nii.gz 1 2 255 0']);
system(['mcubes tmps',seperation,'vtk_LVepi_ED_manual.nii.gz vtks',seperation,'LVepi_ED_manual.vtk 120 -blur 2 -close -open']);
system(['vtk2txt vtks',seperation,'LVepi_ED_manual.vtk vtks',seperation,'LVepi_ED_manual.txt']);

system(['binarize segmentations',seperation,'PHsegmentation_ES_manual.gipl tmps',seperation,'vtk_LVepi_ES_manual.nii.gz 1 2 255 0']);
system(['mcubes tmps',seperation,'vtk_LVepi_ES_manual.nii.gz vtks',seperation,'LVepi_ES_manual.vtk 120 -blur 2 -close -open']);
system(['vtk2txt vtks',seperation,'LVepi_ES_manual.vtk vtks',seperation,'LVepi_ES_manual.txt']);

return