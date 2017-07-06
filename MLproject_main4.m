% This script is a wrappe for Ludvigs functions.

%% Init

if isunix
    cd /nethome/nilsolav/repos/github/MLproject/
    addpath('/nethome/nilsolav/repos/github/LSSSreader/src/')
    addpath('/nethome/nilsolav/repos/github/NMDAPIreader/')
    addpath('/nethome/nilsolav/repos/nilsolav/MODELS/matlabtools/Enhanced_rdir')
    addpath('/nethome/nilsolav/repos/hg/matlabtoolbox/echolab/readEKRaw')
    dd='/data/cruise_data/';
    dd_out = '/data/deep/akustikk_all/';
    dd_scratch =  '/localscratch/';
else % Ludvig's playground
    cd D:\repos\svn\MODELS\MLprosjekt\
    dd='\\ces.imr.no\cruise_data\';
    % This is the output; change it to you local disk
    dd_out = '\\ces.imr.no\deep\akustikk_all\';
end

%% Start loop over cruise series
DataOverview = dir(fullfile(dd_out,'dataoverviews','DataOverview*.mat'));
   
% The sand eel data is k=11 and the frequency should be 200 kHz

f='200';

for k=11%1:length(DataOverview)
    dd_data = fullfile(dd_out,'rawdata',DataOverview(k).name(14:end-4));
    if ~exist(dd_data)
        mkdir(dd_data)
    end
    
    % Load the paired files
    dat = load(fullfile(dd_out,'dataoverviews',['DataPairedFiles',DataOverview(k).name(13:end)]));
    
   %
    for i=1%:length(dat.pairedfiles)  % this loops over years
        
        % I need column one and three (snap and raw)
        disp(i)
        if size(dat.pairedfiles{i}.F,2)==3
            for j=1:size(dat.pairedfiles{i}.F,1)
                if ~isempty(dat.pairedfiles{i}.F{j,3}) &&~isempty(dat.pairedfiles{i}.F{j,1})
                    snap=dat.pairedfiles{i}.F{j,1};
                    raw=dat.pairedfiles{i}.F{j,3};
                    [~,fn,~]=fileparts(dat.pairedfiles{i}.F{j,3});
                    % Copy file to scratch disk
                   try
                       snap2 = fullfile(dd_data,snap(18:end));
                       raw2  = fullfile(dd_data,raw(18:end));
                       MLproject_classify1(raw2,snap2)
                   catch ME
                        disp([datestr(now),'; failed  ; ',fn,' ; ',ME.message,' ; file:',ME.stack(end).file,' ; line:',num2str(ME.stack(end).line)])
                   end
                end
            end
        end
    end
end
disp('Finished!')