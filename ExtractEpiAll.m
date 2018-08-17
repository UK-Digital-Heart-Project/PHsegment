function ExtractEpiAll(target,atlas,threads)
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
    threads = 4;
end

% if(matlabpool('size'))
%     matlabpool close
% end
% 
% matlabpool(num2str(threads))

result = dir(target);
[rows,~]=size(result);


epimask = load([atlas,seperation,'endo_epi.txt']);

for i = 1:rows
    if(isdir([target,seperation,result(i).name]) == true && strcmp(result(i).name,'.') == false && strcmp(result(i).name,'..') == false)
       myowallthickness = load([target,seperation,result(i).name,seperation,'lv_myoed_wallthickness.txt']);
       [vertices,~] = size(myowallthickness);
       index = 1;
       for j = 1:vertices
           if(epimask(j,4) == 1)
               epiwallthickness(index,:) = myowallthickness(index,:);
               index = index + 1;
           end
       end
       save([target,seperation,result(i).name,seperation,'lv_epied_wallthickness.txt'],'epiwallthickness','-ascii');
    end
end

% matlabpool close
return
