function [out_struct, unzipped_files] = cdf_read_io(filename, varnames, varargin)
% struct = cdf_read_io(filename, varnames, hardread, opts)
%
% Read data from cdf file and collect data in a structure.
%
% Input:
%   - filename: string containing file name
%   - varnames: cell containing data names to read, i.e. varnames =
%      {'FC0_DEL_X', 'FC0_ETA_FX', 'COB_ETAX'} (without time)
%   - hardread: 0 - use cdf_read, store global time channel (default)
%               1 - use cdf_hardread, store each time in variable VARNAME_T
%   -opts: 'hardread' -> hardread = 1; 'nodelete', unzipped files are not deleted
%
% Output:
%   - struct.name: name of extracted run
%   - struct.vars: readed data names
%   - struct.hardread: used read method (0 or 1)
%   - struct.time: readed time, if hardread == 0
%   - struct.VARNAME, i.e. struct.FCO_DEL_X: readed channel data
%   - struct.VARNAME_T, i.e. struct.FC0_DEL_X_T: channel time (hardread==1)
%
% Requires cdf_read, cdf_hardread; Tested with fitlab 2.3.0
%
% last commit: $Rev: 5675 $ $Date:: 2017-10-12 15:04:23#$ by $Author: DLR\wart_jo $


%% Set Default Variables
nodelete = 0;
hardread = 0;
unzipped_files = [];


%% Optional Inputs
optargin = size(varargin,2);
for i = 1:optargin
    if ( ischar(varargin{i}) == 1 ) % weitere Konfiguration
        switch lower(varargin{i})
            case 'nodelete'
                nodelete = 1;
            case 'hardread'
                hardread = 1;
        end
    elseif ( isnumeric(varargin{i}) == 1 ) % hardread = 1
        hardread = varargin{i};
    elseif ( iscell(varargin{i}) == 1 ) % unzipped_files
        unzipped_files = varargin{i};
    end
end


%% Remove duplicates in varnames
varnames = unique(varnames);


%% Unzip, if zip-file is selected
filename_wo_path = strfind(filename, '\');
% path is given
if ~isempty(filename_wo_path)
    filename_path = filename(1:filename_wo_path(end));
    filename_wo_path = filename(filename_wo_path(end)+1:end);
else
    filename_path = [pwd '\'];
    filename_wo_path = filename;
end
original_files = dir(filename_path); original_files = {original_files.name};
if strcmpi(filename(end-2:end), 'zip')
    if ~exist(filename(1:end-4), 'file') % cdf-file does not exist
        unzip(filename, filename_path);
    end
    filename(end-3:end) = '';
elseif strcmpi(filename(end-1:end), '7z')
    if ~exist(filename(1:end-3), 'file') % cdf-file does not exist
        [temp, status] = system(['"7z.exe" -y x ' '"' filename '"' ' -o' '"' filename_path '"']);
    end
    filename(end-2:end) = '';
end
% check if unzipped_files are given as input
if isempty(unzipped_files)
    unzipped_files = dir(filename_path); unzipped_files = {unzipped_files.name};
    unzipped_files = setdiff(unzipped_files, original_files);
    for i = 1:length(unzipped_files)
        display([unzipped_files{i} ' was unzipped.']);
    end
end


%% Read data
if hardread == 0
    try
        [time, temp] = cdf_read(filename, 'Time');
    catch exc
        if strfind(lower(exc.message), 'no_such_cdf')
            error(['Could not find file ' filename]);
        else
            rethrow(exc);
        end
    end
    [data, temp] = cdf_read(filename, char(varnames));
    time_abs = time;
    time = time - time(1);

else % HARDREAD
    maxtime = NaN(length(varnames),1);
    mintime = NaN(length(varnames),1);
    data = cell(1, length(varnames));
    htime = cell(1, length(varnames));
    
    % read cdf header to get signal names
    try
        [temp1,temp2,temp3,names,temp4] = cdf_head(filename);
    catch exc
        if strfind(lower(exc.message), 'no_such_cdf')
            error(['Could not find file ' filename]);
        else
            rethrow(exc);
        end
    end
    names = cellstr(names);
    
    for i=1:length(varnames)
        if any( strcmpi(names, char(varnames{i})) )
            [rawdata, temp5] = cdf_hardread(filename, char(varnames{i}));
            data{i} = rawdata(:,2);
            htime{i} = rawdata(:,1);% - rawdata(1,1);
            maxtime(i) = rawdata(end,1);
            mintime(i) = rawdata(1,1);
        else % if signal does not exist, add empty signal entry
            display([char(varnames{i}) ' does not exist in file.']);
            data{i} = [];
            htime{i} = [];            
        end
    end
    mintime = min(mintime(~isnan(mintime)));
    maxtime = max(maxtime(~isnan(maxtime))) - mintime;
end


%% Define Outputs
bslash = strfind(filename, '\');
if isempty(bslash)
    out_struct.filename = filename(1:end);
    out_struct.pathname = [];
else
    out_struct.filename = filename(bslash(end)+1:end);
    out_struct.pathname = filename(1:bslash(end));
end
out_struct.vars = varnames;
out_struct.hardread = hardread;

if hardread == 0
    out_struct.time = time;
    out_struct.time_abs = time_abs;

    for i=1:length(varnames)
        % Workaround for vector signal i.e. SIG(1) -> SIG_1
        [startind, endind] = regexpi(varnames{i}, '\(\d*\)');
        if ~isempty(startind) && ~isempty(endind)
            varnames{i} = [varnames{i}(1:startind-1) '_' num2str(varnames{i}(startind+1:endind-1)) varnames{i}(endind+1:end)];
        end
        out_struct.(varnames{i}) = data(:, i); % Assign signale to structure
    end

else % HARDREAD
    out_struct.time = [0 maxtime];
    out_struct.time_abs = mintime;
    
    for i=1:length(varnames)
        % Workaround for vector signal i.e. SIG(1) -> SIG_1
        [startind, endind] = regexpi(varnames{i}, '\(\d*\)');
        if ~isempty(startind) && ~isempty(endind)
            varnames{i} = [varnames{i}(1:startind-1) '_' num2str(varnames{i}(startind+1:endind-1)) varnames{i}(endind+1:end)];
        end
        out_struct.(varnames{i}) = data{i}; % Assign signale to structure
        out_struct.([varnames{i} '_T']) = htime{i} - mintime; % Assign time to structure
    end
end


%% Delete unzipped files
if ~nodelete
    if ~isempty(unzipped_files)
        for i = 1:length(unzipped_files)
            delete([filename_path unzipped_files{i}]);
            display([unzipped_files{i} ' was deleted.']);
        end
    end
end