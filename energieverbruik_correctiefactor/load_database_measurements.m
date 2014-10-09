clear; clc; close all;

% loads all data in a certain data folder
[FileName,PathName] = uigetfile('*.csv');
if FileName
    %% load
    fileID = fopen(fullfile(PathName,FileName),'r');
    nameCell = textscan(fileID,'%s',1,'delimiter','\n');
    unitCell = textscan(fileID,'%s',1,'delimiter','\n');
    fclose(fileID);
    
    data = csvread(fullfile(PathName,FileName),2,0);
   
    
            
    % split header and unit
    name = strsplit(nameCell{1}{1},',');
    unit = strsplit(unitCell{1}{1},',');
    
    % create data structure
    
    dataStruct.time = data(:,1);
    for i=1:length(name)-1
        dataStruct.signal(i).name = name{i+1};
        dataStruct.signal(i).unit = unit{i+1};
        if i+1<=size(data,2)
            dataStruct.signal(i).data = data(:,i+1);
        else
            dataStruct.signal(i).data = nan(length(dataStruct.time),1);
        end
    end

    
    save(fullfile(PathName,[FileName(1:end-4),'.mat']) ,'dataStruct');
end
