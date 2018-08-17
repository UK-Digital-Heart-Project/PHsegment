function [  ] = LandmarkP(folder)

if ispc
    seperation = '\';
else
    seperation = '/';
end

cd(folder)

result = dir('lvsa_ED.gipl');
[rows,~]=size(result);
if(rows == 1)
    result = dir('landmarks.vtk');
    [rows,~]=size(result);
    if(rows == 0 || (rows > 0 && result(1).bytes <= 50))
        while(true)
            !echo. 2>landmarks.vtk
            !rview lvsa_ED.gipl
            result = dir('landmarks.vtk');
            %%need to be changed
            rows = result(1).bytes;
            if(rows > 50)
                delete('checked.txt');
                !cardiacchecklandmarks landmarks.vtk 6 checked.txt
                checked = load('checked.txt');
                if(checked)
                    break;
                end
            end
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