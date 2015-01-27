function dataStruct = load_database_measurements(varargin)

    if isempty(varargin)
        % loads all data in a certain data folder
        [FileName,PathName] = uigetfile('*.csv');
        filename = fullfile(PathName,FileName);
    else
        filename = varargin{1};
    end
    
    if filename
        %% load
        fileID = fopen(filename,'r');
        
        if strcmp(filename, '../data/knxcontrol_measurements_20140915_20141001.csv')
            nameCell = textscan(fileID,'%s',1,'delimiter','\n');
            unitCell = textscan(fileID,'%s',1,'delimiter','\n');
        else
            nameCell = textscan(fileID,'%s',1,'delimiter','\n');
            quantityCell = textscan(fileID,'%s',1,'delimiter','\n');
            unitCell = textscan(fileID,'%s',1,'delimiter','\n');
            explanationCell = textscan(fileID,'%s',1,'delimiter','\n');
        end
        
        fclose(fileID);

        
        if strcmp(filename, '../data/knxcontrol_measurements_20140915_20141001.csv')
            data = csvread(filename,2,0);
        else
            data = csvread(filename,4,0);
        end
        

        % split header and unit
        if strcmp(filename, '../data/knxcontrol_measurements_20140915_20141001.csv')
            name = regexp(nameCell{1}{1}, ',', 'split');
            unit = regexp(unitCell{1}{1}, ',', 'split');
        else
            name = regexp(nameCell{1}{1}, ',', 'split');
            quantity = regexp(quantityCell{1}{1}, ',', 'split');
            unit = regexp(unitCell{1}{1}, ',', 'split');
            explanation = regexp(explanationCell{1}{1}, ',', 'split');
        end
        

        % create data structure
        dataStruct.time = data(:,1);
        for i=1:length(name)-1
            if strcmp(filename, '../data/knxcontrol_measurements_20140915_20141001.csv')
                dataStruct.signal(i).name = name{i+1};
                dataStruct.signal(i).unit = unit{i+1};
            else
                dataStruct.signal(i).name = name{i+1};
                dataStruct.signal(i).quantity = quantity{i+1};
                dataStruct.signal(i).unit = unit{i+1};
                dataStruct.signal(i).explanation = explanation{i+1};
            end
            
            if i+1<=size(data,2)
                dataStruct.signal(i).data = data(:,i+1);
            else
                dataStruct.signal(i).data = nan(length(dataStruct.time),1);
            end
        end


        save([filename(1:end-4),'.mat'] ,'dataStruct');
    end
end
