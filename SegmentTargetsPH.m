function [  ] = SegmentTargetsPH(folder,atlas,numberofatlases,atlasresult,shapeatlas,numberofshapeatlases,shapeatlasresult,unseenname)

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

result = dir('lvsa_ED.gipl');
[rows,~]=size(result);
if(rows == 1)
    
    [numberofatlases,atlasresult] = atlaspreselection(atlas,numberofatlases,atlasresult,unseenname);
    [numberofshapeatlases,shapeatlasresult] = atlaspreselection(shapeatlas,numberofshapeatlases,shapeatlasresult,unseenname);
    %check if detection success
    result_detection = dir('lvsa_ED_cropped.nii.gz');
    [detections,~] = size(result_detection);
    if(detections == 1)
        %detected already
        palign(atlas,numberofatlases,atlasresult,32)
        [numberofatlases, atlasresult] = atlaspostselection(atlas,numberofatlases,atlasresult,32);
        segmentation(atlas,numberofatlases,atlasresult)
        refineresults(shapeatlas,numberofshapeatlases,shapeatlasresult)
    else
        %haven't detected
        detection(atlas,numberofatlases,atlasresult,32)
        result_detection = dir('lvsa_ED_cropped.nii.gz');
        [real_detections,~] = size(result_detection);
        if(real_detections == 1)
            [numberofatlases, atlasresult] = atlaspostselection(atlas,numberofatlases,atlasresult,32);
            segmentation(atlas,numberofatlases,atlasresult)
            refineresults(shapeatlas,numberofshapeatlases,shapeatlasresult)
        end
    end 
end

levels = strfind(folder, seperation);
[~,rows]=size(levels);
for i = 1:rows
    cd ..
end
cd ..
return


function refine(input,output)

if ispc
    seperation = '\';
else
    seperation = '/';
end

eval(['!binarize ',input,' tmps',seperation,'rvepi.nii.gz 1 4 255 0'])
eval(['!blur tmps',seperation,'rvepi.nii.gz tmps',seperation,'rvepi.nii.gz 2'])
eval(['!threshold tmps',seperation,'rvepi.nii.gz tmps',seperation,'rvepi.nii.gz 130'])

eval(['!binarize ',input,' tmps',seperation,'rvendo.nii.gz 4 4 255 0'])
eval(['!blur tmps',seperation,'rvendo.nii.gz tmps',seperation,'rvendo.nii.gz 2'])
eval(['!threshold tmps',seperation,'rvendo.nii.gz tmps',seperation,'rvendo.nii.gz 130'])

eval(['!binarize ',input,' tmps',seperation,'epi.nii.gz 1 2 255 0'])
eval(['!blur tmps',seperation,'epi.nii.gz tmps',seperation,'epi.nii.gz 2'])
eval(['!threshold tmps',seperation,'epi.nii.gz tmps',seperation,'epi.nii.gz 115'])

eval(['!binarize ',input,' tmps',seperation,'endo.nii.gz 1 1 255 0'])
eval(['!blur tmps',seperation,'endo.nii.gz tmps',seperation,'endo.nii.gz 2'])
eval(['!threshold tmps',seperation,'endo.nii.gz tmps',seperation,'endo.nii.gz 130'])

eval(['!padding tmps',seperation,'rvepi.nii.gz tmps',seperation,'rvepi.nii.gz ',output,' 1 3'])
eval(['!padding ',output,' tmps',seperation,'rvendo.nii.gz ',output,' 1 4'])
eval(['!padding ',output,' tmps',seperation,'epi.nii.gz ',output,' 1 2'])
eval(['!padding ',output,' tmps',seperation,'endo.nii.gz ',output,' 1 1'])

return

function refineresults(atlas,numberofatlases,atlasresult)


if ispc
    seperation = '\';
else
    seperation = '/';
end

[ednumberofatlases,edatlasresult] = shapeselection(atlas,['segmentations',seperation,'label_segmentation_'],'PHsegmentation_ED.gipl',numberofatlases,atlasresult,5,'ED');
topology3D(['segmentations',seperation,'label_segmentation_'],['segmentations',seperation,'3D_label_segmentation_'],atlas,ednumberofatlases,edatlasresult,'ED');

[esnumberofatlases,esatlasresult] = shapeselection(atlas,['segmentations',seperation,'label_segmentation_'],'PHsegmentation_ES.gipl',numberofatlases,atlasresult,5,'ES');
topology3D(['segmentations',seperation,'label_segmentation_'],['segmentations',seperation,'3D_label_segmentation_'],atlas,esnumberofatlases,esatlasresult,'ES');

refine(['segmentations',seperation,'3D_label_segmentation_ED.gipl'],'PHsegmentation_ED.gipl');
refine(['segmentations',seperation,'3D_label_segmentation_ES.gipl'],'PHsegmentation_ES.gipl');

system('padding PHsegmentation_ED.gipl PHsegmentation_ED.gipl segmentation_ED.gipl 3 0');
system('padding PHsegmentation_ES.gipl PHsegmentation_ES.gipl segmentation_ES.gipl 3 0');

return

function [outnumberofatlases,outatlasresult] = shapeselection(atlas,target,source,numberofatlases,atlasresult,number,name)


if ispc
    seperation = '\';
else
    seperation = '/';
end

% if there's need to select the atlas
delete(['tmps',seperation,'shapenmi*.txt']);
if(number < numberofatlases)
    for i = 1:numberofatlases
        system(['pareg landmarks.vtk ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'landmarks.vtk -dofout dofs',seperation,'shapelandmarks',atlasresult(i).name,'.dof.gz -s1']);
        system(['cardiacimageevaluation ',target,name,'.gipl ..',seperation,'..',seperation,atlas,seperation,atlasresult(i).name,seperation,source,' -nbins_x 64 -nbins_y 64 -output tmps',seperation,'shapenmi',atlasresult(i).name,'.txt -dofin dofs',seperation,'shapelandmarks',atlasresult(i).name,'.dof.gz']);
        similaritys = load(['tmps',seperation,'shapenmi',atlasresult(i).name,'.txt']);
        % 3 is NMI
        nmi(i) = similaritys(4);
    end
    
    [~,sortedIndexes] = sort(nmi,'descend');
    
    for i = 1:number
        newselectedatlas(i) = atlasresult(sortedIndexes(i));
    end
    
    outatlasresult = newselectedatlas;
    outnumberofatlases = number;
else
    outatlasresult = atlasresult;
    outnumberofatlases = numberofatlases;
end
%else do nothing

return

function topology3D(target,output,atlas,numberofatlases,atlasresult,name)

if ispc
    seperation = '\';
else
    seperation = '/';
end

segstring = '';
index = 0;
for i = 1:numberofatlases
    segstring = [segstring,' tmps',seperation,'shape',atlasresult(i).name,'_segmentation_',name,'.nii.gz'];
    index = index + 1;
end

system(['resample lvsa_',name,'_enlarged.nii.gz lvsa_',name,'_enlarged_SR.nii.gz -isotropic']);

for i = 1:numberofatlases
    system(['nreg ',target,name,'.gipl ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'PHsegmentation_',name,'.gipl -parin ..',seperation,'..',seperation,'parameters',seperation,'segreg.txt -dofin dofs',seperation,'shapelandmarks',atlasresult(i).name,'.dof.gz -dofout dofs',seperation,'shape_',name,'_',atlasresult(i).name,'.dof.gz'])
    system(['transformation ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'PHsegmentation_',name,'.gipl tmps',seperation,'shape',atlasresult(i).name,'_segmentation_',name,'.nii.gz -dofin dofs',seperation,'shape_',name,'_',atlasresult(i).name,'.dof.gz -target lvsa_',name,'_enlarged_SR.nii.gz -nn'])
end

system(['combineLabels ',output,name,'.gipl ',num2str(index),' ',segstring])
return

function [numberofatlases,atlasresult] = atlaspreselection(atlas,numberofatlases,atlasresult,unseenname)


if ispc
    seperation = '\';
else
    seperation = '/';
end

index = 0;

for i = 1:numberofatlases
    % cross validation turned off && strcmp(atlasresult(i).name,unseenname) == false
    if(isdir(['..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name]) == true && strcmp(atlasresult(i).name,'.') == false && strcmp(atlasresult(i).name,'..') == false)
        index = index + 1;
        selectedatlas(index) = atlasresult(i);
    end
end

atlasresult = selectedatlas;
numberofatlases = index;

return

function detection(atlas,numberofatlases,atlasresult,limit)


if ispc
    seperation = '\';
else
    seperation = '/';
end

rregstring = '';
index = 0;

if(limit > numberofatlases)
    limit = numberofatlases;
end

for i = 1:limit
    rregstring = [rregstring,' ','tmps',seperation,'crop_',atlasresult(i).name,'_segmentation_ED.nii.gz'];
    index = index + 1;
end

result = dir('landmarks.vtk');
%%need to be changed
[rows,~]=size(result);

if(rows > 0)
    for i = 1:numberofatlases
        system(['pareg landmarks.vtk ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'landmarks.vtk -dofout dofs',seperation,'landmarks',atlasresult(i).name,'.dof.gz -s1']);
        cmd = ['transformation ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'segmentation_ED.gipl tmps',seperation,'crop_',atlasresult(i).name,'_segmentation_ED.nii.gz -dofin dofs',seperation,'landmarks',atlasresult(i).name,'.dof.gz -target lvsa_ED.gipl -nn'];
        system(cmd);
    end
end

system(['combineLabels tmps',seperation,'crop_segmentation_ED.gipl ',num2str(index),rregstring]);
%system(['cardiaccrop lvsa_ED.gipl tmps',seperation,'crop_segmentation_ED.gipl lvsa_ED_cropped.nii.gz -boarder 20']);

%!region lvsa.gipl lvsa_cropped.nii.gz -ref lvsa_ED_cropped.nii.gz
%!region lvsa_ES.gipl lvsa_ES_cropped.nii.gz -ref lvsa_ED_cropped.nii.gz
%!enlarge_image lvsa_ED_cropped.nii.gz lvsa_ED_enlarged.nii.gz -x 20 -value -1
%!enlarge_image lvsa_ES_cropped.nii.gz lvsa_ES_enlarged.nii.gz -x 20 -value -1

return

function palign(atlas,numberofatlases,atlasresult,limit)


if ispc
    seperation = '\';
else
    seperation = '/';
end

rregstring = '';
index = 0;

if(limit > numberofatlases)
    limit = numberofatlases;
end

for i = 1:limit
    rregstring = [rregstring,' ','tmps',seperation,'crop_',atlasresult(i).name,'_segmentation_ED.nii.gz'];
    index = index + 1;
end

result = dir('landmarks.vtk');
%%need to be changed
[rows,~]=size(result);

if(rows > 0)
    for i = 1:numberofatlases
        system(['pareg landmarks.vtk ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'landmarks.vtk -dofout dofs',seperation,'landmarks',atlasresult(i).name,'.dof.gz -s1']);
        cmd = ['transformation ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'segmentation_ED.gipl tmps',seperation,'crop_',atlasresult(i).name,'_segmentation_ED.nii.gz -dofin dofs',seperation,'landmarks',atlasresult(i).name,'.dof.gz -target lvsa_ED.gipl -nn'];
        system(cmd);
    end
end

system(['combineLabels tmps',seperation,'crop_segmentation_ED.gipl ',num2str(index),rregstring]);
%!region lvsa.gipl lvsa_cropped.nii.gz -ref lvsa_ED_cropped.nii.gz
%!region lvsa_ES.gipl lvsa_ES_cropped.nii.gz -ref lvsa_ED_cropped.nii.gz
%!enlarge_image lvsa_ED_cropped.nii.gz lvsa_ED_enlarged.nii.gz -z 3 -value -1
%!enlarge_image lvsa_ES_cropped.nii.gz lvsa_ES_enlarged.nii.gz -z 3 -value -1

return

function segmentation(atlas,numberofatlases,atlasresult)


if ispc
    seperation = '\';
else
    seperation = '/';
end

% segment(atlas,numberofatlases,atlasresult,'ED');
% [ednumberofatlases,edatlasresult] = atlasselection(['segmentations',seperation,'patch_segmentation_'],['tmps',seperation,'nreg_'],numberofatlases,atlasresult,8,'ED');
% topology(atlas,ednumberofatlases,edatlasresult,'ED');
% segment(atlas,numberofatlases,atlasresult,'ES');
% [esnumberofatlases,esatlasresult] = atlasselection(['segmentations',seperation,'patch_segmentation_'],['tmps',seperation,'nreg_'],numberofatlases,atlasresult,8,'ES');
% topology(atlas,esnumberofatlases,esatlasresult,'ES');

system('irtkinfo lvsa_ED_cropped.nii.gz -size size.txt');
imagesize = load('size.txt');
%if(imagesize(3) > 6)
 %   segment2D(['segmentations',seperation,'crop_segmentation_'],['segmentations',seperation,'patch_segmentation_'],atlas,numberofatlases,atlasresult,'ED',0.5);
%else
    segment(['segmentations',seperation,'patch_segmentation_'],atlas,numberofatlases,atlasresult,'ED');
%end

[ednumberofatlases,edatlasresult] = atlasselection(['segmentations',seperation,'patch_segmentation_'],['tmps',seperation,'nreg_'],numberofatlases,atlasresult,5,'ED');
topology(['segmentations',seperation,'patch_segmentation_'],['tmps',seperation,'label_'],['segmentations',seperation,'label_segmentation_'],atlas,ednumberofatlases,edatlasresult,'ED');

segment(['segmentations',seperation,'patch_segmentation_'],atlas,numberofatlases,atlasresult,'ES');

[esnumberofatlases,esatlasresult] = atlasselection(['segmentations',seperation,'patch_segmentation_'],['tmps',seperation,'nreg_'],numberofatlases,atlasresult,5,'ES');
topology(['segmentations',seperation,'patch_segmentation_'],['tmps',seperation,'label_'],['segmentations',seperation,'label_segmentation_'],atlas,esnumberofatlases,esatlasresult,'ES');

return

function [numberofatlases,atlasresult] = atlaspostselection(atlas,numberofatlases,atlasresult,number)

if ispc
    seperation = '\';
else
    seperation = '/';
end

system(['mkdir tmps',seperation,'nmi']);
delete(['tmps',seperation,'nmi',seperation,'*.txt']);

% if there's need to select the atlas
if(number < numberofatlases)
    for i = 1:numberofatlases
        system(['cardiacimageevaluation lvsa_cropped.nii.gz ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'lvsa.gipl -dofin dofs',seperation,'landmarks',atlasresult(i).name,'.dof.gz -nbins_x 64 -nbins_y 64 -output tmps',seperation,'nmi',seperation,atlasresult(i).name,'.txt']);
        similaritys = load(['tmps',seperation,'nmi',seperation,atlasresult(i).name,'.txt']);
        % 3 is NMI
        nmi(i) = similaritys(2);
    end
   
    [~,sortedIndexes] = sort(nmi,'descend');
   
    for i = 1:number
        newselectedatlas(i) = atlasresult(sortedIndexes(i));
    end
   
    atlasresult = newselectedatlas;
    numberofatlases = number;
end
%else do nothing
 
return

function [outnumberofatlases,outatlasresult] = atlasselection(target,source,numberofatlases,atlasresult,number,name)


if ispc
    seperation = '\';
else
    seperation = '/';
end

% if there's need to select the atlas
delete(['tmps',seperation,'nmi*.txt']);
if(number < numberofatlases)
    for i = 1:numberofatlases
        system(['cardiacimageevaluation ',target,name,'.gipl ',source,atlasresult(i).name,'_segmentation_',name,'.nii.gz -nbins_x 64 -nbins_y 64 -output tmps',seperation,'nmi',atlasresult(i).name,'.txt']);
        similaritys = load(['tmps',seperation,'nmi',atlasresult(i).name,'.txt']);
        % 3 is NMI
        nmi(i) = similaritys(4);
    end
    
    [~,sortedIndexes] = sort(nmi,'descend');
    
    for i = 1:number
        newselectedatlas(i) = atlasresult(sortedIndexes(i));
    end
    
    outatlasresult = newselectedatlas;
    outnumberofatlases = number;
else
    outatlasresult = atlasresult;
    outnumberofatlases = numberofatlases;
end
%else do nothing

return

function topology(target,source,output,atlas,numberofatlases,atlasresult,name)

if ispc
    seperation = '\';
else
    seperation = '/';
end

segstring = '';
index = 0;
for i = 1:numberofatlases
    segstring = [segstring,' ',source,atlasresult(i).name,'_segmentation_',name,'.nii.gz'];
    index = index + 1;
end

for i = 1:numberofatlases
    system(['nreg ',target,name,'.gipl ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'PHsegmentation_',name,'.gipl -parin ..',seperation,'..',seperation,'parameters',seperation,'segreg.txt -dofin dofs',seperation,'labelnreg',atlasresult(i).name,'.dof.gz -dofout dofs',seperation,'label_',name,'_',atlasresult(i).name,'.dof.gz'])
    system(['transformation ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'PHsegmentation_',name,'.gipl ',source,atlasresult(i).name,'_segmentation_',name,'.nii.gz -dofin dofs',seperation,'label_',name,'_',atlasresult(i).name,'.dof.gz -target lvsa_',name,'_enlarged.nii.gz -nn'])
end

system(['combineLabels ',output,name,'.gipl ',num2str(index),' ',segstring])
return

function segment(output,atlas,numberofatlases,atlasresult,name)

if ispc
    seperation = '\';
else
    seperation = '/';
end

delete('atlas.txt');
delete('seg.txt');

segstring = {};
atlasstring = {};
index = 0;
for i = 1:numberofatlases
    segstring{i} = ['tmps',seperation,'nreg_',atlasresult(i).name,'_segmentation_',name,'.nii.gz'];
    atlasstring{i} = ['tmps',seperation,'sourcefeature',num2str(i,'%.5d'),'.nii.gz'];
    index = index + 1;
end

fid = fopen('atlas.txt', 'wt');
for i = 1:numberofatlases
    fprintf(fid, '%s\n', atlasstring{i});
end
fclose(fid);

fid = fopen('seg.txt', 'wt');
for i = 1:numberofatlases
    fprintf(fid, '%s\n', segstring{i});
end
fclose(fid);

delete(['tmps',seperation,'targetfeature*.nii.gz']);
delete(['tmps',seperation,'sourcefeature*.nii.gz']);

for i = 1:numberofatlases
    cmd = ['nreg segmentation_',name,'.gipl ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'segmentation_',name,'.gipl -dofin dofs',seperation,'landmarks',atlasresult(i).name,'.dof.gz -dofout dofs',seperation,'labelnreg',atlasresult(i).name,'.dof.gz -parin ..',seperation,'..',seperation,'parameters',seperation,'segregcoarse.txt'];
    system(cmd);
    system(['transformation ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'PHsegmentation_',name,'.gipl tmps',seperation,'nreg_',atlasresult(i).name,'_segmentation_',name,'.nii.gz -dofin dofs',seperation,'labelnreg',atlasresult(i).name,'.dof.gz -target lvsa_',name,'_cropped.nii.gz -nn'])
    system(['transformation ..',seperation,'..',seperation,'',atlas,seperation,atlasresult(i).name,'',seperation,'lvsa_',name,'.gipl tmps',seperation,'rreg_',atlasresult(i).name,'_',name,'.nii.gz -dofin dofs',seperation,'labelnreg',atlasresult(i).name,'.dof.gz -cspline -target lvsa_',name,'_cropped.nii.gz -Sp -1'])
    system(['normalize lvsa_',name,'_cropped.nii.gz tmps',seperation,'rreg_',atlasresult(i).name,'_',name,'.nii.gz tmps',seperation,'nreg_',atlasresult(i).name,'_',name,'.nii.gz -Tp -1 -Sp -1 -piecewise'])
    BuildFeatures(['lvsa_',name,'_cropped.nii.gz'],['tmps',seperation,'nreg_',atlasresult(i).name,'_',name,'.nii.gz'],['tmps',seperation,'targetfeature.nii.gz'],['tmps',seperation,'sourcefeature',num2str(i,'%.5d'),'.nii.gz']);
end

%Wenzhe if it works better keep the -numberofneighbors 2
%if it works worse remove the -numberofneighbors 2
%system(['EP_MAPM_Segmentation ',num2str(index),' atlas.txt tmps',seperation,'targetfeature.nii.gz seg.txt ',output,name,'.gipl 8 -searchradius 0.01 -radiusz 1 -numberofneighbors 2']);
system(['mapmSegmentation ',num2str(index),' atlas.txt tmps',seperation,'targetfeature.nii.gz seg.txt ',output,name,'.gipl 2 -searchradius 0.04 -numberofneighbors 2']);
%Wenzhe comment the following command out to enable trimming of the
%segmentation
system(['cardiacsegtrim ',output,name,'.gipl landmarks.vtk ',output,name,'.gipl -basaloffset 0']);
return