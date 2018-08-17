function [  ] = PrepareP(folder,atlas)

if ispc
    seperation = '\';
else
    seperation = '/';
end

cd(folder)

convert(atlas)
prepare()

levels = strfind(folder, seperation);
[~,rows]=size(levels);
for i = 1:rows
    cd ..
end
cd ..

return

function prepare()

!mkdir dofs
!mkdir tmps
!mkdir vtks
!mkdir segmentations

!cardiacphasedetection lvsa.gipl lvsa_ED.gipl lvsa_ES.gipl

return

function convert(atlas)

if ispc
    seperation = '\';
else
    seperation = '/';
end

delete('*.nii.gz')
delete('*.gipl')
result = dir('*.nii');
[rows,~]=size(result);
if(rows > 0)
    maxsize = -1;
    maxindex = 1;
    for i = 1:rows
        if(result(i).bytes > maxsize)
            maxsize = result(i).bytes;
            maxindex = i;
        end
    end
    eval(['!headertool ',result(maxindex).name,' lvsa.gipl -reset']);
    %temporal align
    eval(['!temporalalign ..',seperation,'..',seperation,atlas,seperation,'temporal.gipl lvsa.gipl lvsa.gipl -St1 0 -St2 0 -Et1 1 -Et2 1']);
    !autocontrast lvsa.gipl lvsa.gipl
    %self similarity spatial align
    %eval('!spatial_correct lvsa.gipl lvsa.gipl slvsa.gipl -translation');
    %!autocontrast slvsa.gipl lvsa.gipl
else
    result = dir('*.dcm');
    [rows,~]=size(result);
    if(rows > 0)
        !dcm2nii *.dcm -a -y
        result = dir('*.nii.gz');
        [rows,~]=size(result);
        maxsize = -1;
        maxindex = 1;
        for i = 1:rows
            if(result(i).bytes > maxsize)
                maxsize = result(i).bytes;
                maxindex = i;
            end
        end
        eval(['!rename ',result(maxindex).name,' lvsa.nii.gz']);
        !headertool lvsa.nii.gz lvsa.gipl -reset
        %temporal align
        eval(['!temporalalign ..',seperation,'..',seperation,atlas,seperation,'temporal.gipl lvsa.gipl lvsa.gipl -St1 0 -St2 0 -Et1 1 -Et2 1']);
        !autocontrast lvsa.gipl lvsa.gipl
        %self similarity spatial align
        %eval('!spatial_correct lvsa.gipl lvsa.gipl slvsa.gipl -translation');
        %!autocontrast slvsa.gipl lvsa.gipl
    end
end

return