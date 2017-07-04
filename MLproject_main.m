% this script reads the data from the server and generate the data overview
% and lists of files. The overviews are stored to the dd directory.
%% Init

if isunix
    %cd /nethome/nilsolav/repos/nilsolav/MODELS/MLprosjekt/
    addpath('/nethome/nilsolav/repos/github/LSSSreader/src/')
    addpath('/nethome/nilsolav/repos/github/NMDAPIreader/')
    addpath('/nethome/nilsolav/repos/nilsolav/MODELS/matlabtools/Enhanced_rdir')
    dd='/data/cruise_data/';
    dd_out = '/data/deep/akustikk_all/dataoverviews/';
else
    cd D:\repos\svn\MODELS\MLprosjekt\
    dd='\\ces.imr.no\cruise_data\';
end

%% Get survey time series structure
D = NMDAPIreader_readcruiseseries;
save('D','D')

% Get information and data statistics per survey

DataStatus = cell(1,8);
DataStatus(1,:) ={'CruiseSeries','Year','CruiseNr','ShipName','DataPath','Problem','raw','Snap'};
l=2;
for i = 1:length(D)
    disp([D(i).name])
    for j=1:length(D(i).sampletime)
        ds = fullfile(dd,D(i).sampletime(j).sampletime);
        disp(['   ',D(i).sampletime(j).sampletime])
        for k=1:length(D(i).sampletime(j).Cruise)
            DataStatus{l,1} = D(i).name;
            DataStatus{l,2} = D(i).sampletime(j).sampletime;
            DataStatus{l,3} = D(i).sampletime(j).Cruise(k).cruisenr;
            DataStatus{l,4} = D(i).sampletime(j).Cruise(k).shipName;
            if ~isempty(D(i).sampletime(j).Cruise(k).cruise)
                if isfield(D(i).sampletime(j).Cruise(k).cruise.datapath,'Text')
                    DataStatus{l,5} = D(i).sampletime(j).Cruise(k).cruise.datapath.Text;
                end
                DataStatus{l,6} = D(i).sampletime(j).Cruise(k).cruise.datapath.Comment;
                if isfield(D(i).sampletime(j).Cruise(k).cruise.datapath,'rawfiles')
                    DataStatus{l,7} = D(i).sampletime(j).Cruise(k).cruise.datapath.rawfiles;
                end
                if isfield(D(i).sampletime(j).Cruise(k).cruise.datapath,'snapfiles')
                    DataStatus{l,8} = D(i).sampletime(j).Cruise(k).cruise.datapath.snapfiles;
                end
            end
            l=l+1;
        end
    end
end

%% Save summary data
fid=fopen([fullfile(dd_out,'DataOverview.csv')],'w');
for i=1:size(DataStatus,1)
    for j=1:size(DataStatus,2)
        if i>1&&ismember(j,[7 8])
            st='%i;';
            str = (DataStatus{i,j});
        else
            st = '%s;';
            str=DataStatus{i,j};
        end
        fprintf(fid,st,str);
    end
    fprintf(fid,'\n');
end
fclose(fid);


%% Crunch data - count files per series and get list of files

for i = 1:length(D)
    tic
    DataStatus = cell(1,12);
    DataStatus(1,:) ={'CruiseSeries','Year','CruiseNr','ShipName','DataPath','Problem','Rawfiles','Snapfiles','Workfiles','RawfilesNotStdLocation','SnapfilesNotStdLocation','WorkfilesNotStdLocation'};
    l=2;
    disp([D(i).name])
    for j=1:length(D(i).sampletime)
        ds = fullfile(dd,D(i).sampletime(j).sampletime);
        disp(['   ',D(i).sampletime(j).sampletime])
        for k=1:length(D(i).sampletime(j).Cruise)
            DataStatus{l,1} = D(i).name;
            DataStatus{l,2} = D(i).sampletime(j).sampletime;
            DataStatus{l,3} = D(i).sampletime(j).Cruise(k).cruisenr;
            DataStatus{l,4} = D(i).sampletime(j).Cruise(k).shipName;
            if isfield(D(i).sampletime(j).Cruise(k).cruise.datapath,'Text')
                DataStatus{l,5} = D(i).sampletime(j).Cruise(k).cruise.datapath.Text;
            else
                DataStatus{l,5} = 'NA';
            end
            DataStatus{l,6} = D(i).sampletime(j).Cruise(k).cruise.datapath.Comment;
            
            % Go into the directory and check the files
            if isfield(D(i).sampletime(j).Cruise(k).cruise.datapath,'Text') && exist(DataStatus{l,5},'dir')==7

                % Get information per cruise
                [filecount,files]   = NMDAPIreader_getLSSSdatastatus(DataStatus{l,5});
                
                % Pair files
                pairedfiles{l-1}=LSSSreader_pairfiles(files);
                
                % Combine the different files
                DataStatus{l,7}  = filecount(1);
                DataStatus{l,8}  = filecount(2);
                DataStatus{l,9}  = filecount(3);
                DataStatus{l,10} = filecount(4);
                DataStatus{l,11} = filecount(5);
                DataStatus{l,12} = filecount(6);
            else
                % Combine the different files
                DataStatus{l,7}  = NaN;
                DataStatus{l,8}  = NaN;
                DataStatus{l,9}  = NaN;
                DataStatus{l,10} = NaN;
                DataStatus{l,11} = NaN;
                DataStatus{l,12} = NaN;
            end
            l=l+1;
        end
    end
    % Write data status
   save([dd_out,'DataPairedFiles_',D(i).name,'.mat'],'pairedfiles');
   save([dd_out,'DataOverview_',D(i).name,'.mat'],'DataStatus');
   clear pairedfiles
    fid=fopen([dd_out,'DataOverview_',D(i).name,'.csv'],'w');
    for q=1:size(DataStatus,1)
        for r=1:size(DataStatus,2)
            fprintf(fid,'%s;',DataStatus{q,r});
        end
        fprintf(fid,'\n');
    end
    fclose(fid)
    toc
end





