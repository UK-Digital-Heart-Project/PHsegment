function manualcheckrun(threads)

% if(matlabpool('size'))
%     matlabpool close
% end
% 
% matlabpool(threads);

if ispc
    seperation = '\';
else
    seperation = '/';
end

result = dir();
[rows,~]=size(result);

for i = 1:rows
    if(isdir([result(i).name]) == true && strcmp(result(i).name,'.') == false && strcmp(result(i).name,'..') == false)
        %4D graphcuts
        %Refine4Dgraphcuts(result(i).name,[result(i).name,'_crop.nii.gz'],[result(i).name,'_nreg_masp_crop_label.nii.gz'],[result(i).name,'_nreg_masp_label.nii.gz'],[result(i).name,'_nreg_masp_graphcut_label.nii.gz']);
        system(['rview ',result(i).name,seperation,'lvsa_ED_cropped.nii.gz ',result(i).name,seperation,'segmentation_ED.gipl -smin 1 -scontour'])
        %ystem(['rview ',result(i).name,seperation,result(i).name,'.nii.gz ',result(i).name,seperation,result(i).name,'_nreg_masp_graphcut_label.nii.gz -scontour 255 0 0'])
    end
end
% 
% matlabpool close

return