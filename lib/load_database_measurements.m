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
        nameCell = textscan(fileID,'%s',1,'delimiter','\n');
        unitCell = textscan(fileID,'%s',1,'delimiter','\n');
        fclose(fileID);

        data = csvread(filename,2,0);



        % split header and unit
        name = regexp(nameCell{1}{1}, ',', 'split');
        %name = strsplit(nameCell{1}{1},',');
        unit = regexp(unitCell{1}{1}, ',', 'split');
        %unit = strsplit(unitCell{1}{1},',');

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


        save([filename(1:end-4),'.mat'] ,'dataStruct');
    end
end
