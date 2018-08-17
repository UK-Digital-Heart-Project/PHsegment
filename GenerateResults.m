function GenerateResults(folder,patientid,atlas)

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

result1 = dir('PHsegmentation_ED.gipl');
[rows1,~]=size(result1);
result2 = dir('PHsegmentation_ES.gipl');
[rows2,~]=size(result2);
if(rows1 == 1 && rows2 == 1)
    
    vtks(atlas);
    
    name = ['ED';'ES'];
    
    for i = 1:2
        delete(['..',seperation,patientid,'_',name(i,:),'.txt'])
        system(['cardiacvolumecount PHsegmentation_',name(i,:),'.gipl 1 -output ..',seperation,patientid,'_',name(i,:),'.txt'])
        system(['cardiacvolumecount PHsegmentation_',name(i,:),'.gipl 2 -output ..',seperation,patientid,'_',name(i,:),'.txt -scale 1.05'])
        system(['cardiacvolumecount PHsegmentation_',name(i,:),'.gipl 4 -output ..',seperation,patientid,'_',name(i,:),'.txt'])
        system(['cardiacvolumecount PHsegmentation_',name(i,:),'.gipl 3 -output ..',seperation,patientid,'_',name(i,:),'.txt -scale 1.05'])
    end
end

levels = strfind(folder, seperation);
[~,rows]=size(levels);
for i = 1:rows
    cd ..
end
cd ..
return

function vtks(atlas)

if ispc
    seperation = '\';
else
    seperation = '/';
end

delete(['vtks',seperation,'*.*'])

system(['binarize PHsegmentation_ED.gipl tmps',seperation,'vtk_RV_ED.nii.gz 4 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RV_ED.nii.gz vtks',seperation,'RV_ED.vtk 120 -blur 2']);
system(['binarize PHsegmentation_ES.gipl tmps',seperation,'vtk_RV_ES.nii.gz 4 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RV_ES.nii.gz vtks',seperation,'RV_ES.vtk 120 -blur 2']);
system(['binarize PHsegmentation_ED.gipl tmps',seperation,'vtk_RVepi_ED.nii.gz 3 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RVepi_ED.nii.gz vtks',seperation,'RVepi_ED.vtk 120 -blur 2']);
system(['binarize PHsegmentation_ES.gipl tmps',seperation,'vtk_RVepi_ES.nii.gz 3 4 255 0']);
system(['mcubes tmps',seperation,'vtk_RVepi_ES.nii.gz vtks',seperation,'RVepi_ES.vtk 120 -blur 2']);

system(['padding PHsegmentation_ED.gipl PHsegmentation_ED.gipl tmps',seperation,'vtk_LV_ED.nii.gz 4 0']);
system(['padding PHsegmentation_ES.gipl PHsegmentation_ES.gipl tmps',seperation,'vtk_LV_ES.nii.gz 4 0']);
system(['padding tmps',seperation,'vtk_LV_ED.nii.gz PHsegmentation_ED.gipl tmps',seperation,'vtk_LV_ED.nii.gz 3 0']);
system(['padding tmps',seperation,'vtk_LV_ES.nii.gz PHsegmentation_ES.gipl tmps',seperation,'vtk_LV_ES.nii.gz 3 0']);

system(['binarize PHsegmentation_ED.gipl tmps',seperation,'vtk_LVendo_ED.nii.gz 1 1 255 0']);
system(['mcubes tmps',seperation,'vtk_LVendo_ED.nii.gz vtks',seperation,'LVendo_ED.vtk 120 -blur 2']);
system(['binarize PHsegmentation_ES.gipl tmps',seperation,'vtk_LVendo_ES.nii.gz 1 1 255 0']);
system(['mcubes tmps',seperation,'vtk_LVendo_ES.nii.gz vtks',seperation,'LVendo_ES.vtk 120 -blur 2']);

system(['binarize PHsegmentation_ED.gipl tmps',seperation,'vtk_LVepi_ED.nii.gz 1 2 255 0']);
system(['mcubes tmps',seperation,'vtk_LVepi_ED.nii.gz vtks',seperation,'LVepi_ED.vtk 120 -blur 2']);
system(['binarize PHsegmentation_ES.gipl tmps',seperation,'vtk_LVepi_ES.nii.gz 1 2 255 0']);
system(['mcubes tmps',seperation,'vtk_LVepi_ES.nii.gz vtks',seperation,'LVepi_ES.vtk 120 -blur 2']);

system(['binarize PHsegmentation_ED.gipl tmps',seperation,'vtk_LVmyo_ED.nii.gz 2 2 255 0']);
system(['mcubes tmps',seperation,'vtk_LVmyo_ED.nii.gz vtks',seperation,'LVmyo_ED.vtk 110 -blur 2']);
system(['binarize PHsegmentation_ES.gipl tmps',seperation,'vtk_LVmyo_ES.nii.gz 2 2 255 0']);
system(['mcubes tmps',seperation,'vtk_LVmyo_ES.nii.gz vtks',seperation,'LVmyo_ES.vtk 110 -blur 2']);

result = dir('landmarks.vtk');
%%need to be changed
[rows,~]=size(result);

if(rows > 0)
    system(['prreg landmarks.vtk ..',seperation,'..',seperation,atlas,seperation,'landmarks.vtk -dofout dofs',seperation,'landmarks.dof.gz']);
    %rigid align to reference vtk
    cmd = ['msrreg 3 vtks',seperation,'RV_ED.vtk vtks',seperation,'LVendo_ED.vtk vtks',seperation,'LVepi_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ED.vtk -dofin dofs',seperation,'landmarks.dof.gz -dofout tmps',seperation,'ed.dof.gz -symmetric'];
    system(cmd);
    cmd = ['msrreg 2 vtks',seperation,'LVendo_ED.vtk vtks',seperation,'LVepi_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ED.vtk -dofin tmps',seperation,'ed.dof.gz -dofout tmps',seperation,'lv_ed_rreg.dof.gz -symmetric'];
    system(cmd);
    cmd = ['srreg vtks',seperation,'RV_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ED.vtk -dofin tmps',seperation,'ed.dof.gz -dofout tmps',seperation,'rv_ed_rreg.dof.gz -symmetric'];
    system(cmd);
    cmd = ['msrreg 3 vtks',seperation,'RV_ES.vtk vtks',seperation,'LVendo_ES.vtk vtks',seperation,'LVepi_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ES.vtk -dofin dofs',seperation,'landmarks.dof.gz -dofout tmps',seperation,'es.dof.gz -symmetric'];
    system(cmd);
    cmd = ['msrreg 2 vtks',seperation,'LVendo_ES.vtk vtks',seperation,'LVepi_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ES.vtk -dofin tmps',seperation,'es.dof.gz -dofout tmps',seperation,'lv_es_rreg.dof.gz -symmetric'];
    system(cmd);
    cmd = ['srreg vtks',seperation,'RV_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ES.vtk -dofin tmps',seperation,'es.dof.gz -dofout tmps',seperation,'rv_es_rreg.dof.gz -symmetric'];
    system(cmd);
else
    %rigid align to reference
    cmd = ['msrreg 3 vtks',seperation,'RV_ED.vtk vtks',seperation,'LVendo_ED.vtk vtks',seperation,'LVepi_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ED.vtk -dofout tmps',seperation,'ed.dof.gz -symmetric'];
    system(cmd);
    cmd = ['msrreg 2 vtks',seperation,'LVendo_ED.vtk vtks',seperation,'LVepi_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ED.vtk -dofin tmps',seperation,'ed.dof.gz -dofout tmps',seperation,'lv_ed_rreg.dof.gz -symmetric'];
    system(cmd);
    cmd = ['srreg vtks',seperation,'RV_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ED.vtk -dofin tmps',seperation,'ed.dof.gz -dofout tmps',seperation,'rv_ed_rreg.dof.gz -symmetric'];
    system(cmd);
    cmd = ['msrreg 3 vtks',seperation,'RV_ES.vtk vtks',seperation,'LVendo_ES.vtk vtks',seperation,'LVepi_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ES.vtk -dofout tmps',seperation,'es.dof.gz -symmetric'];
    system(cmd);
    cmd = ['msrreg 2 vtks',seperation,'LVendo_ES.vtk vtks',seperation,'LVepi_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ES.vtk -dofin tmps',seperation,'es.dof.gz -dofout tmps',seperation,'lv_es_rreg.dof.gz -symmetric'];
    system(cmd);
    cmd = ['srreg vtks',seperation,'RV_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ES.vtk -dofin tmps',seperation,'es.dof.gz -dofout tmps',seperation,'rv_es_rreg.dof.gz -symmetric'];
    system(cmd);
end

%transform
system(['ptransformation vtks',seperation,'RV_ED.vtk vtks',seperation,'N_RV_ED.vtk -dofin tmps',seperation,'rv_ed_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'RV_ES.vtk vtks',seperation,'N_RV_ES.vtk -dofin tmps',seperation,'rv_es_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'RVepi_ED.vtk vtks',seperation,'N_RVepi_ED.vtk -dofin tmps',seperation,'rv_ed_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'RVepi_ES.vtk vtks',seperation,'N_RVepi_ES.vtk -dofin tmps',seperation,'rv_es_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'LVendo_ED.vtk vtks',seperation,'N_LVendo_ED.vtk -dofin tmps',seperation,'lv_ed_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'LVendo_ES.vtk vtks',seperation,'N_LVendo_ES.vtk -dofin tmps',seperation,'lv_es_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'LVepi_ED.vtk vtks',seperation,'N_LVepi_ED.vtk -dofin tmps',seperation,'lv_ed_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'LVepi_ES.vtk vtks',seperation,'N_LVepi_ES.vtk -dofin tmps',seperation,'lv_es_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'LVmyo_ED.vtk vtks',seperation,'N_LVmyo_ED.vtk -dofin tmps',seperation,'lv_ed_rreg.dof.gz'])
system(['ptransformation vtks',seperation,'LVmyo_ES.vtk vtks',seperation,'N_LVmyo_ES.vtk -dofin tmps',seperation,'lv_es_rreg.dof.gz'])
system(['transformation tmps',seperation,'vtk_RV_ED.nii.gz tmps',seperation,'N_vtk_RV_ED.nii.gz -dofin tmps',seperation,'lv_es_rreg.dof.gz -invert'])
system(['transformation tmps',seperation,'vtk_RV_ES.nii.gz tmps',seperation,'N_vtk_RV_ES.nii.gz -dofin tmps',seperation,'lv_es_rreg.dof.gz -invert'])
system(['transformation tmps',seperation,'vtk_LV_ED.nii.gz tmps',seperation,'N_vtk_LV_ED.nii.gz -dofin tmps',seperation,'lv_es_rreg.dof.gz -invert'])
system(['transformation tmps',seperation,'vtk_LV_ES.nii.gz tmps',seperation,'N_vtk_LV_ES.nii.gz -dofin tmps',seperation,'lv_es_rreg.dof.gz -invert'])

%areg
cmd = ['areg ..',seperation,'..',seperation,atlas,seperation,'vtk_RV_ED.nii.gz tmps',seperation,'N_vtk_RV_ED.nii.gz -dofout tmps',seperation,'rv_ed_areg.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segareg.txt'];
system(cmd);
cmd = ['areg ..',seperation,'..',seperation,atlas,seperation,'vtk_RV_ES.nii.gz tmps',seperation,'N_vtk_RV_ES.nii.gz -dofout tmps',seperation,'rv_es_areg.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segareg.txt'];
system(cmd);
cmd = ['areg ..',seperation,'..',seperation,atlas,seperation,'vtk_LV_ED.nii.gz tmps',seperation,'N_vtk_LV_ED.nii.gz -dofout tmps',seperation,'lv_ed_areg.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segareg.txt'];
system(cmd);
cmd = ['areg ..',seperation,'..',seperation,atlas,seperation,'vtk_LV_ES.nii.gz tmps',seperation,'N_vtk_LV_ES.nii.gz -dofout tmps',seperation,'lv_es_areg.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segareg.txt'];
system(cmd);

%same number of points
cmd = ['nreg ..',seperation,'..',seperation,atlas,seperation,'vtk_RV_ED.nii.gz tmps',seperation,'N_vtk_RV_ED.nii.gz -dofin tmps',seperation,'rv_ed_areg.dof.gz -dofout tmps',seperation,'rv_ed_nreg.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segreg.txt'];
system(cmd);
cmd = ['snreg ..',seperation,'..',seperation,atlas,seperation,'RV_ED.vtk vtks',seperation,'N_RV_ED.vtk -dofin tmps',seperation,'rv_ed_nreg.dof.gz -dofout tmps',seperation,'rvedds8.dof.gz -ds 8 -symmetric'];
system(cmd);
cmd = ['nreg ..',seperation,'..',seperation,atlas,seperation,'vtk_LV_ED.nii.gz tmps',seperation,'N_vtk_LV_ED.nii.gz -dofin tmps',seperation,'lv_ed_areg.dof.gz -dofout tmps',seperation,'lv_ed_nreg.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segreg.txt'];
system(cmd);
cmd = ['msnreg 2 ..',seperation,'..',seperation,atlas,seperation,'LVendo_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ED.vtk vtks',seperation,'N_LVendo_ED.vtk vtks',seperation,'N_LVepi_ED.vtk -dofin tmps',seperation,'lv_ed_nreg.dof.gz -dofout tmps',seperation,'lvedfinal.dof.gz -ds 4 -symmetric'];
system(cmd);
cmd = ['cardiacsurfacemap ..',seperation,'..',seperation,atlas,seperation,'LVendo_ED.vtk vtks',seperation,'N_LVendo_ED.vtk tmps',seperation,'lvedfinal.dof.gz vtks',seperation,'F_LVendo_ED.vtk'];
system(cmd);
cmd = ['cardiacsurfacemap ..',seperation,'..',seperation,atlas,seperation,'LVepi_ED.vtk vtks',seperation,'N_LVepi_ED.vtk tmps',seperation,'lvedfinal.dof.gz vtks',seperation,'F_LVepi_ED.vtk'];
system(cmd);
cmd = ['ptransformation ..',seperation,'..',seperation,atlas,seperation,'LVmyo_ED.vtk vtks',seperation,'F_LVmyo_ED.vtk -dofin tmps',seperation,'lvedfinal.dof.gz'];
system(cmd);
cmd = ['cardiacsurfacemap ..',seperation,'..',seperation,atlas,seperation,'RV_ED.vtk vtks',seperation,'N_RV_ED.vtk tmps',seperation,'rvedds8.dof.gz vtks',seperation,'C_RV_ED.vtk'];
system(cmd);

%rv es
cmd = ['nreg ..',seperation,'..',seperation,atlas,seperation,'vtk_RV_ES.nii.gz tmps',seperation,'N_vtk_RV_ES.nii.gz -dofin tmps',seperation,'rv_es_areg.dof.gz -dofout tmps',seperation,'rv_es_nreg.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segreg.txt'];
system(cmd);
cmd = ['snreg ..',seperation,'..',seperation,atlas,seperation,'RV_ES.vtk vtks',seperation,'N_RV_ES.vtk -dofin tmps',seperation,'rv_es_nreg.dof.gz -dofout tmps',seperation,'rvesds8.dof.gz -ds 8 -symmetric'];
system(cmd);
cmd = ['nreg ..',seperation,'..',seperation,atlas,seperation,'vtk_LV_ES.nii.gz tmps',seperation,'N_vtk_LV_ES.nii.gz -dofin tmps',seperation,'lv_es_areg.dof.gz -dofout tmps',seperation,'lv_es_nreg.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segreg.txt'];
system(cmd);
cmd = ['msnreg 2 ..',seperation,'..',seperation,atlas,seperation,'LVendo_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ES.vtk vtks',seperation,'N_LVendo_ES.vtk vtks',seperation,'N_LVepi_ES.vtk -dofin tmps',seperation,'lv_es_nreg.dof.gz -dofout tmps',seperation,'lvesfinal.dof.gz -ds 4 -symmetric'];
system(cmd);
cmd = ['cardiacsurfacemap ..',seperation,'..',seperation,atlas,seperation,'LVendo_ES.vtk vtks',seperation,'N_LVendo_ES.vtk tmps',seperation,'lvesfinal.dof.gz vtks',seperation,'F_LVendo_ES.vtk'];
system(cmd);
cmd = ['cardiacsurfacemap ..',seperation,'..',seperation,atlas,seperation,'LVepi_ES.vtk vtks',seperation,'N_LVepi_ES.vtk tmps',seperation,'lvesfinal.dof.gz vtks',seperation,'F_LVepi_ES.vtk'];
system(cmd);
cmd = ['ptransformation ..',seperation,'..',seperation,atlas,seperation,'LVmyo_ES.vtk vtks',seperation,'F_LVmyo_ES.vtk -dofin tmps',seperation,'lvesfinal.dof.gz'];
system(cmd);
cmd = ['cardiacsurfacemap ..',seperation,'..',seperation,atlas,seperation,'RV_ES.vtk vtks',seperation,'N_RV_ES.vtk tmps',seperation,'rvesds8.dof.gz vtks',seperation,'C_RV_ES.vtk'];
system(cmd);

%continue from here TODO wenzhe
if ispc
    cmd = ['copy vtks',seperation,'F_LVendo_ED.vtk vtks',seperation,'S_LVendo_ED.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVepi_ED.vtk vtks',seperation,'S_LVepi_ED.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVmyo_ED.vtk vtks',seperation,'S_LVmyo_ED.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVmyo_ED.vtk vtks',seperation,'C_LVmyo_ED.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVmyo_ED.vtk vtks',seperation,'W_LVmyo_ED.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVendo_ES.vtk vtks',seperation,'S_LVendo_ES.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVepi_ES.vtk vtks',seperation,'S_LVepi_ES.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVmyo_ES.vtk vtks',seperation,'S_LVmyo_ES.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVmyo_ES.vtk vtks',seperation,'C_LVmyo_ES.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'F_LVmyo_ES.vtk vtks',seperation,'W_LVmyo_ES.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'C_RV_ED.vtk vtks',seperation,'S_RV_ED.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'C_RV_ES.vtk vtks',seperation,'S_RV_ES.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'C_RV_ED.vtk vtks',seperation,'W_RV_ED.vtk'];
    system(cmd);
    cmd = ['copy vtks',seperation,'C_RV_ES.vtk vtks',seperation,'W_RV_ES.vtk'];
    system(cmd);
else
    cmd = ['cp vtks',seperation,'F_LVendo_ED.vtk vtks',seperation,'S_LVendo_ED.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVepi_ED.vtk vtks',seperation,'S_LVepi_ED.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVmyo_ED.vtk vtks',seperation,'S_LVmyo_ED.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVmyo_ED.vtk vtks',seperation,'C_LVmyo_ED.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVmyo_ED.vtk vtks',seperation,'W_LVmyo_ED.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVendo_ES.vtk vtks',seperation,'S_LVendo_ES.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVepi_ES.vtk vtks',seperation,'S_LVepi_ES.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVmyo_ES.vtk vtks',seperation,'S_LVmyo_ES.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVmyo_ES.vtk vtks',seperation,'C_LVmyo_ES.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'F_LVmyo_ES.vtk vtks',seperation,'W_LVmyo_ES.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'C_RV_ED.vtk vtks',seperation,'S_RV_ED.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'C_RV_ES.vtk vtks',seperation,'S_RV_ES.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'C_RV_ED.vtk vtks',seperation,'W_RV_ED.vtk'];
    system(cmd);
    cmd = ['cp vtks',seperation,'C_RV_ES.vtk vtks',seperation,'W_RV_ES.vtk'];
    system(cmd);
end

system(['cardiacwallthickness vtks',seperation,'F_LVendo_ED.vtk vtks',seperation,'F_LVepi_ED.vtk -myocardium vtks',seperation,'W_LVmyo_ED.vtk'])
system(['cardiacwallthickness vtks',seperation,'F_LVendo_ES.vtk vtks',seperation,'F_LVepi_ES.vtk -myocardium vtks',seperation,'W_LVmyo_ES.vtk'])

cmd = ['cardiacenlargedistance vtks',seperation,'S_LVendo_ED.vtk vtks',seperation,'S_LVepi_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ED.vtk -myocardium vtks',seperation,'S_LVmyo_ED.vtk'];
system(cmd);
cmd = ['cardiacenlargedistance vtks',seperation,'S_LVendo_ES.vtk vtks',seperation,'S_LVepi_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVendo_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'LVepi_ES.vtk -myocardium vtks',seperation,'S_LVmyo_ES.vtk'];
system(cmd);

system(['DiscreteCurvatureEstimator vtks',seperation,'C_LVmyo_ED.vtk vtks',seperation,'FC_LVmyo_ED.vtk'])
system(['cardiaccurvature vtks',seperation,'FC_LVmyo_ED.vtk vtks',seperation,'C_LVmyo_ED.vtk -smooth 64'])

system(['DiscreteCurvatureEstimator vtks',seperation,'C_RV_ED.vtk vtks',seperation,'FC_RV_ED.vtk'])
system(['cardiaccurvature vtks',seperation,'FC_RV_ED.vtk vtks',seperation,'C_RV_ED.vtk -smooth 64'])

cmd = ['sevaluation vtks',seperation,'S_RV_ED.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ED.vtk -scalar -signed'];
system(cmd);

system(['DiscreteCurvatureEstimator vtks',seperation,'C_LVmyo_ES.vtk vtks',seperation,'FC_LVmyo_ES.vtk'])
system(['cardiaccurvature vtks',seperation,'FC_LVmyo_ES.vtk vtks',seperation,'C_LVmyo_ES.vtk -smooth 64'])

system(['DiscreteCurvatureEstimator vtks',seperation,'C_RV_ES.vtk vtks',seperation,'FC_RV_ES.vtk'])
system(['cardiaccurvature vtks',seperation,'FC_RV_ES.vtk vtks',seperation,'C_RV_ES.vtk -smooth 64'])

cmd = ['sevaluation vtks',seperation,'S_RV_ES.vtk ..',seperation,'..',seperation,atlas,seperation,'RV_ES.vtk -scalar -signed'];
system(cmd);

system(['cardiacwallthickness vtks',seperation,'W_RV_ED.vtk vtks',seperation,'N_RVepi_ED.vtk'])
system(['cardiacwallthickness vtks',seperation,'W_RV_ES.vtk vtks',seperation,'N_RVepi_ES.vtk'])

%output to txt files
delete('*.txt')
system(['vtk2txt vtks',seperation,'C_RV_ED.vtk rv_ed_curvature.txt'])
system(['vtk2txt vtks',seperation,'W_RV_ED.vtk rv_ed_wallthickness.txt'])
system(['vtk2txt vtks',seperation,'S_RV_ED.vtk rv_ed_signeddistances.txt'])
system(['vtk2txt vtks',seperation,'C_RV_ES.vtk rv_es_curvature.txt'])
system(['vtk2txt vtks',seperation,'W_RV_ES.vtk rv_es_wallthickness.txt'])
system(['vtk2txt vtks',seperation,'S_RV_ES.vtk rv_es_signeddistances.txt'])
system(['vtk2txt vtks',seperation,'W_LVmyo_ED.vtk lv_myoed_wallthickness.txt'])
system(['vtk2txt vtks',seperation,'C_LVmyo_ED.vtk lv_myoed_curvature.txt'])
system(['vtk2txt vtks',seperation,'S_LVmyo_ED.vtk lv_myoed_signeddistances.txt'])
system(['vtk2txt vtks',seperation,'W_LVmyo_ES.vtk lv_myoes_wallthickness.txt'])
system(['vtk2txt vtks',seperation,'C_LVmyo_ES.vtk lv_myoes_curvature.txt'])
system(['vtk2txt vtks',seperation,'S_LVmyo_ES.vtk lv_myoes_signeddistances.txt'])

delete(['tmps',seperation,'*.*'])

return