function RunPAll(target,atlas,phatlas,shapeatlas,prepare,segment,threads)
%   RunPAll(target,atlas,prepare,segment,threads)
%   Segment the target images using the specified atlas
%   Need manual landmarks on RV insertion point remote liver and the tip of RV apex basal,
%   rview will automaticall pops up! Landmarks -> Add -> Save as
%   landmarks.vtk (already created by system)
%   Prepare,segment is trigger for respectively dicom
%   convert and add landmarks, run multi-atals PM segmentation. 0 means off, 1 means on
%   finally threads defines number of threads used.
%   number denotes the number of atlases to be selected
%   for segment, 0 means off just calculate the phenotypes from existing
%   segmentations if there's any, 1 means redo the semgnetation, 2 means
%   just segment the images that are not segmented, 3 means calculate the
%   phenotypes with scale normalized.

if ispc
    seperation = '\';
else
    seperation = '/';
end

if nargin < 3
    return;
end

if nargin < 4
    prepare = 1;
    segment = 1;
    threads = 4;
end

if nargin < 5
    segment = 1;
    threads = 4;
end

if nargin < 6
    threads = 4;
end



addpath(pwd);
disp('checkpoint 1');
%parpool(threads)

disp('checkpoint 2');
atlasresult = dir(atlas);
[numberofatlases,~]=size(atlasresult);

disp('checkpoint 3');
phatlasresult = dir(phatlas);
[numberofphatlases,~]=size(phatlasresult);

disp('checkpoint 4');
shapeatlasresult = dir(shapeatlas);
[numberofshapeatlases,~] = size(shapeatlasresult);

disp('checkpoint 5');
result = dir(target);
[rows,~]=size(result);
disp('checkpoint 6');

parfor i = 1:rows
    if(isdir([target,seperation,result(i).name]) == true && strcmp(result(i).name,'.') == false && strcmp(result(i).name,'..') == false)
        if(prepare > 0)
            PrepareP([target,seperation,result(i).name],atlas);
        end
    end
end

disp('checkpoint 7');

for i = 1:rows
    if(isdir([target,seperation,result(i).name]) == true && strcmp(result(i).name,'.') == false && strcmp(result(i).name,'..') == false)
        LandmarkP([target,seperation,result(i).name]);
    end
end

% Change from for / parfor as needed
parfor i = 1:rows
     if(isdir([target,seperation,result(i).name]) == true && strcmp(result(i).name,'.') == false && strcmp(result(i).name,'..') == false)
        if(segment > 0)
            if(segment == 1)
                SegmentTargetsP([target,seperation,result(i).name],atlas,numberofatlases,atlasresult,result(i).name);
                SegmentTargetsPH([target,seperation,result(i).name],phatlas,numberofphatlases,phatlasresult,shapeatlas,numberofshapeatlases,shapeatlasresult,result(i).name);
            else
                segmentations = dir([target,seperation,result(i).name,seperation,'segmentation_E*.gipl']);
                [segmented,~] = size(segmentations);
                if(segmented < 2)
                    SegmentTargetsP([target,seperation,result(i).name],atlas,numberofatlases,atlasresult,result(i).name);
                    SegmentTargetsPH([target,seperation,result(i).name],phatlas,numberofphatlases,phatlasresult,shapeatlas,numberofshapeatlases,shapeatlasresult,result(i).name);
                else
                    display([target,seperation,result(i).name,' segmented']);
                end
            end
        end
        if(segment > 2)
            GenerateNormalizedResults([target,seperation,result(i).name],result(i).name,atlas);
        else
            GenerateResults([target,seperation,result(i).name],result(i).name,atlas);
        end
    end
end

% index1 = 0;
% matrixindex = {};
% !mkdir matrix
% for i = 1:rows
%     if(exist([target,seperation,result(i).name,seperation,'vtks',seperation,'F_RV_ED.vtk'],'file'))
%         index1 = index1 + 1;
%         matrixindex(index1) = cellstr([target,seperation,result(i).name]);
%         index2 = 0;
%         for j = 1:rows
%             if(exist([target,seperation,result(j).name,'\vtks\F_RV_ED.vtk'],'file'))
%                 index2 = index2 + 1;
%                 filename = ['matrix\',num2str(index1),'_',num2str(index2),'.txt'];
%                 delete(filename);
%                 system(['currents_distance ',target,seperation,result(i).name,'\vtks\F_RV_ED.vtk ',target,seperation,result(j).name,'\vtks\F_RV_ED.vtk -output ',filename]);
%                 if(exist(filename,'file'))
%                     value(index1,index2)=load(filename);
%                 else
%                     value(index1,index2)=-1;
%                 end
%             end
%         end
%     end
% end
%
% save('C:\Users\Wyedemaa\Dropbox\4D Atlas paper\matlabscripts\surfacedistancematrix_rv.txt','value','-ascii');
% dlmcell('C:\Users\Wyedemaa\Dropbox\4D Atlas paper\matlabscripts\matrixindex_rv.txt',matrixindex)

delete(gcp('nocreate'))
return
