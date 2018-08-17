function BuildFeatures( targetimage, sourceimage, targetfeature, sourcefeature )

%   Combine the PatchMatch with the Spectral Matching for Patch Correspondence Mapping between two images
%   Take two 2D images and output a correspondence map as a image
%   The input images should be rigidly algined and intensity normalised

if nargin < 4
    display('not enough arguments');
    return
end

%coordinate -blur
result = dir(targetfeature);
[existed,~] = size(result);
if(existed < 1)
    cmd = ['featuredetect ',targetimage,' ',targetfeature,' -intensity -gradient -spatialimage ',targetimage];
    system(cmd);
end
%create feature image of the source
%,' -blur 2'
cmd = ['featuredetect ',sourceimage,' ',sourcefeature,' -intensity -gradient -spatialimage ',targetimage];
system(cmd);

end