function varargout = conf_grid(varargin)
%% Create an empty calculation grid for tephra2.
%     - conf_grid
%         Opens the GUI
%     - conf_grid(grid)
%         Creates a grid using parameters stored in the grid structure:
%                 grid.name        = name;         % Grid name (string)
%                 grid.min_east    = min_east;     % Minimum easting (UTM, WGS84)
%                 grid.max_east    = max_east;     % Maximum easting (UTM, WGS84)
%                 grid.min_north   = min_north;    % Minimum northing (UTM, WGS84)
%                 grid.max_north   = max_north;    % Maximum norting (UTM, WGS84)
%                 grid.res         = 1000;         % Grid resolution (m)
%                 grid.vent_zone   = 17;           % Vent UTM zone - only number, negative in S hemisphere
%                 grid.elevation   = 1;            % Mean grid elevation (m asl)
%                 grid.cross_zn    = 0;            % Sets if grid crosses multiple UTM zones
%                 grid.cross_eq    = 0;            % Sets if grid crosses the equator
%                 % If both cross_zn and cross_eq are 0
%                 grid.zone        = 17;           % UTM zone
%                 % If grid is across lateral zones - cross_zn == 1
%                 grid.zone_W      = 17;           % UTM zone of the west grid
%                 grid.zone_E      = 18;           % UTM zone of the east grid
%                 % If grid is across equator - cross_eq == 1
%                 grid.zone_N      = 17;           % UTM zone of the north grid
%                 grid.zone_S      = -17;          % UTM zone of the south grid
%                 % If grid is across zones and equator
%                 grid.zone_NW     = 17;           % UTM zone of the northwest grid
%                 grid.zone_NE     = 18;           % UTM zone of the northeast grid
%                 grid.zone_SW     = -17;          % UTM zone of the southwest grid
%                 grid.zone_SE     = -18;          % UTM zone of the southeast grid
%     - conf_grid(grid, sve, dsp)
%         Defines if the grid is savec (sve) or displayed (dsp). Both a
%         booleans 0/1, 1 as default
%     - grid = conf_grid
%         Returns an empty structure for the grid
    

if nargout == 1
    grid.name        = 'test';    % Grid name (string)
    grid.min_east    = 655415.189073598;      % Minimum easting (UTM, WGS84)
    grid.max_east    = 436987.081148139;      % Maximum easting (UTM, WGS84)
    grid.min_north   = 8772370.66069626;     % Minimum northing (UTM, WGS84)
    grid.max_north   = 9878189.52156841;     % Maximum norting (UTM, WGS84)
    grid.res         = 10000;        % Grid resolution (m)
    grid.vent_zone   = -48;          % Vent UTM zone - only number, negative in S hemisphere
    grid.elevation   = 247;           % Mean grid elevation (m asl)
    grid.cross_zn    = 1;           % Sets if grid crosses multiple UTM zones
    grid.cross_eq    = 0;           % Sets if grid crosses the equator
    % If both cross_zn and cross_eq are 0
    grid.zone        = [];          % UTM zone
    % If grid is across lateral zones - cross_zn == 1
    grid.zone_W      = -47;          % UTM zone of the west grid
    grid.zone_E      = -49;          % UTM zone of the east grid
    % If grid is across equator - cross_eq == 1
    grid.zone_N      = [];          % UTM zone of the north grid
    grid.zone_S      = [];          % UTM zone of the south grid
    % If grid is across zones and equator
    grid.zone_NW     = [];          % UTM zone of the northwest grid
    grid.zone_NE     = [];          % UTM zone of the northeast grid
    grid.zone_SW     = [];          % UTM zone of the southwest grid
    grid.zone_SE     = [];          % UTM zone of the southeast grid
    
    varargout{1} = grid;
    return
end


function but_grd_next(~, ~)
global h

if check_values == 1
    go = 1;
    if exist(fullfile(getenv('GRID'), get(h.grd_grid_name, 'String')), 'dir')
        choice = questdlg('This name already exists. Overwrite?','','Yes','No','No');
        switch choice
            case 'No'
                go = 0;
            case 'Yes'
                rmdir(fullfile(getenv('GRID'), get(h.grd_grid_name, 'String')), 's');
                go = 1;
        end
    end

    if go == 1
        tmp_grid = make_struct(h);
        make_grid(tmp_grid, 0, 1);
    end
else
    errordlg('Please fill up all parameters for your grid', '');
end
    
    
% Opens the manage grid panel
function manage_grid(~, ~)
global h

[fl, pth] = uigetfile('*.mat');

if fl == 0
    return
else
    load(fullfile(pth,fl));
end

% Updates fields
set(h.grd_grid_name, 'String', tmp.name);
set(h.grd_grid_min_easting, 'String', num2str(tmp.min_east));
set(h.grd_grid_max_easting, 'String', num2str(tmp.max_east));
set(h.grd_grid_min_northing, 'String', num2str(tmp.min_north));
set(h.grd_grid_max_northing, 'String', num2str(tmp.max_north));
set(h.grd_grid_resolution, 'String', num2str(tmp.res));
set(h.grd_vent_zone, 'String', tmp.vent_zone)

% Added the option for mean grid elevation as well as backwards
% compatibility
if isfield(tmp, 'elevation')
    set(h.grd_grid_elevation, 'String', num2str(tmp.elevation));
else
    set(h.grd_grid_elevation, 'String', '0');
end

% Main panel / Plot grid button
function disp_grid(hObject, eventdata)
global h

if check_values == 1
    tmp_grid = make_struct(h);
    make_grid(tmp_grid, 1, 0);
else
    errordlg('Please fill up all parameters for your grid', '')
end

% Checks if all values are filled
function check = check_values
global h

if  isempty(get(h.grd_grid_min_easting, 'String')) ||...
    isempty(get(h.grd_grid_max_easting, 'String')) ||...
    isempty(get(h.grd_grid_min_northing, 'String')) || ...
    isempty(get(h.grd_grid_max_northing, 'String')) || ...
    isempty(get(h.grd_grid_name, 'String'))
    check = 0;
elseif get(h.grd_utm_no, 'Value') == 1 &&...
    get(h.grd_eq_no, 'Value') == 1 &&...
    isempty(get(h.grd_grid_zone, 'String'))
    check = 0;
elseif  get(h.grd_utm_no, 'Value') == 0 &&...
        get(h.grd_eq_no, 'Value') == 1
    if  isempty(get(h.grd_grid_zone_E, 'String')) ||...
        isempty(get(h.grd_grid_zone_W, 'String'))      
        check = 0;
    else
        check = 1;
    end    
elseif  get(h.grd_utm_no, 'Value') == 1 &&...
        get(h.grd_eq_no, 'Value') == 0
    if  isempty(get(h.grd_grid_zone_N, 'String')) || ...
        isempty(get(h.grd_grid_zone_S, 'String'))
        check = 0;
    else
        check = 1;
    end
elseif  get(h.grd_utm_no, 'Value') == 0 &&...
        get(h.grd_eq_no, 'Value') == 0
    if  isempty(get(h.grd_grid_zone_NE, 'String')) ||...
        isempty(get(h.grd_grid_zone_NW, 'String')) ||...
        isempty(get(h.grd_grid_zone_SE, 'String')) ||...
        isempty(get(h.grd_grid_zone_SW, 'String'))    
        check = 0;
    else
        check = 1;
    end
else
    check = 1;
end

function tmp_grid = make_struct(h)
tmp_grid = struct;
tmp_grid.name       = get(h.grd_grid_name, 'String');
tmp_grid.cross_zn   = get(h.grd_utm_yes, 'Value');
tmp_grid.cross_eq   = get(h.grd_eq_yes, 'Value');
tmp_grid.min_east   = str2double(get(h.grd_grid_min_easting, 'String'));
tmp_grid.max_east   = str2double(get(h.grd_grid_max_easting, 'String'));
tmp_grid.min_north  = str2double(get(h.grd_grid_min_northing, 'String'));
tmp_grid.max_north  = str2double(get(h.grd_grid_max_northing, 'String'));
tmp_grid.res        = str2double(get(h.grd_grid_resolution, 'String'));
tmp_grid.vent_zone  = str2double(get(h.grd_vent_zone, 'String'));
tmp_grid.elevation  = str2double(get(h.grd_grid_elevation, 'String'));

if get(h.grd_utm_yes, 'Value') == 0 && get(h.grd_eq_yes, 'Value') == 0
    tmp_grid.zone   = str2double(get(h.grd_grid_zone, 'String'));
elseif get(h.grd_utm_yes, 'Value') == 1 && get(h.grd_eq_yes, 'Value') == 0
    tmp_grid.zone_W = str2double(get(h.grd_grid_zone_W, 'String'));
    tmp_grid.zone_E = str2double(get(h.grd_grid_zone_E, 'String'));
elseif get(h.grd_utm_yes, 'Value') == 0 && get(h.grd_eq_yes, 'Value') == 1
    tmp_grid.zone_N = str2double(get(h.grd_grid_zone_N, 'String'));
    tmp_grid.zone_S = str2double(get(h.grd_grid_zone_S, 'String'));
elseif get(h.grd_utm_yes, 'Value') == 1 && get(h.grd_eq_yes, 'Value') == 1
    tmp_grid.zone_NW = str2double(get(h.grd_grid_zone_NW, 'String'));
    tmp_grid.zone_NE = str2double(get(h.grd_grid_zone_NE, 'String'));
    tmp_grid.zone_SW = str2double(get(h.grd_grid_zone_SW, 'String'));
    tmp_grid.zone_SE = str2double(get(h.grd_grid_zone_SE, 'String'));
end

function make_grid(tmp, dsp, sve)
% dsp:          choose if display map or not
% sve:          choose if save or not


% Case 1: Do not cross zone nor equator
if tmp.cross_zn == 0 && tmp.cross_eq == 0
    [TL_lat, TL_lon] = utm2ll(tmp.min_east, tmp.max_north, tmp.zone);
    [TR_lat, TR_lon] = utm2ll(tmp.max_east, tmp.max_north, tmp.zone);
    [BL_lat, BL_lon] = utm2ll(tmp.min_east, tmp.min_north, tmp.zone);
    [BR_lat, BR_lon] = utm2ll(tmp.max_east, tmp.min_north, tmp.zone);
    
    min_lat          = min([TL_lat, BL_lat]);
    max_lat          = max([TR_lat, BR_lat]);
    min_lon          = min([BL_lon, BR_lon]);
    max_lon          = max([TL_lon, TR_lon]);
   
% Case 2: Cross utm zones
elseif tmp.cross_zn == 1 && tmp.cross_eq == 0 

    [TL_lat, TL_lon] = utm2ll(tmp.min_east, tmp.max_north, tmp.zone_W);
    [TR_lat, TR_lon] = utm2ll(tmp.max_east, tmp.max_north, tmp.zone_E);
    [BL_lat, BL_lon] = utm2ll(tmp.min_east, tmp.min_north, tmp.zone_W);
    [BR_lat, BR_lon] = utm2ll(tmp.max_east, tmp.min_north, tmp.zone_E);
    
    min_lat          = min([TL_lat, BL_lat]);
    max_lat          = max([TR_lat, BR_lat]);
    min_lon          = min([BL_lon, BR_lon]);
    max_lon          = max([TL_lon, TR_lon]);
    
    
% Case 3: Cross equator
elseif tmp.cross_zn == 0 && tmp.cross_eq == 1
    
    [TL_lat, TL_lon] = utm2ll(tmp.min_east, tmp.max_north, tmp.zone_N);
    [TR_lat, TR_lon] = utm2ll(tmp.max_east, tmp.max_north, tmp.zone_N);
    [BL_lat, BL_lon] = utm2ll(tmp.min_east, tmp.min_north, tmp.zone_S);
    [BR_lat, BR_lon] = utm2ll(tmp.max_east, tmp.min_north, tmp.zone_S);
    
    min_lat          = min([TL_lat, BL_lat]);
    max_lat          = max([TR_lat, BR_lat]);
    min_lon          = min([BL_lon, BR_lon]);
    max_lon          = max([TL_lon, TR_lon]);
    
% Case 4: Cross both utm zones and equator
elseif tmp.cross_zn == 1 && tmp.cross_eq == 1  
    
    [TL_lat, TL_lon] = utm2ll(tmp.min_east, tmp.max_north, tmp.zone_NW);
    [TR_lat, TR_lon] = utm2ll(tmp.max_east, tmp.max_north, tmp.zone_NE);
    [BL_lat, BL_lon] = utm2ll(tmp.min_east, tmp.min_north, tmp.zone_SW);
    [BR_lat, BR_lon] = utm2ll(tmp.max_east, tmp.min_north, tmp.zone_SE);
    
    min_lat          = min([TL_lat, BL_lat]);
    max_lat          = max([TR_lat, BR_lat]);
    min_lon          = min([BL_lon, BR_lon]);
    max_lon          = max([TL_lon, TR_lon]);

end

 
[min_e, min_n]   = ll2utm(min_lat, min_lon, tmp.vent_zone);
[max_e, max_n]   = ll2utm(max_lat, max_lon, tmp.vent_zone);

% Correction for the southern hemisphere
if tmp.cross_eq == 1 
    if tmp.vent_zone < 0
        max_n = max_n+1e7;
    else
        min_n = -(1e7-min_n);
    end
end

x_vec = min_e : tmp.res : max_e;
y_vec = min_n : tmp.res : max_n;


%% Create the mesh
[utmx, utmy] = meshgrid(x_vec, y_vec);      % Create easting and northing matrices      
%[lat, lon]   = utm2ll(utmx, utmy, ones(size(utmx)).*tmp.vent_zone);
utmy         = flipud(utmy);             % Symetry

%% Convert into lat/lon and create 3-columns grid in UTM
[lat, lon, utm, dat] = fill_matrix(utmx, utmy, tmp.vent_zone, tmp);



%% Save matrices
if sve == 1
    write_matrix(tmp, lat, lon, utm, utmx, utmy, dat);
end

%% Display map
if dsp == 1
    display_map(lat, lon);
end

function display_map(lat, lon)
% Display the grid extent on a map
figure;
h1 = fill([min(min(lon)); max(max(lon)); max(min(lon)); min(max(lon))], [max(max(lat)); max(max(lat)); min(min(lat)); min(min(lat))], 'r'); 
set(h1, 'FaceAlpha', .3);
hold on;
%plot(lon, lat, 'xr')
plot_google_map('maptype', 'terrain', 'MapScale', 1);
xlabel('Longitude');
ylabel('Latitude');
axis equal
set(gca, 'Layer', 'top');

function write_matrix(tmp, lat, lon, utm, utmx, utmy, dat)
% Saving data
mkdir(fullfile(getenv('GRID'), tmp.name));
out_name = fullfile(getenv('GRID'),tmp.name,tmp.name);
wb = waitbar(0,'Writing grid...');
save([out_name, '.mat'], 'tmp');
waitbar(1 / 7);
dlmwrite([out_name, '.utm'], utm, 'delimiter', ' ', 'precision', '%.0f');
waitbar(2 / 7);
writeIt(dat, [out_name, '.dat']);
waitbar(3 / 7);
writeIt(utmx, [out_name, '_utmx.dat']);
waitbar(4 / 7);
writeIt(utmy, [out_name, '_utmy.dat']);
waitbar(5 / 7);
writeIt(lat, [out_name, '_lat.dat']);
waitbar(6 / 7);
writeIt(lon, [out_name, '_lon.dat']);
waitbar(7 / 7);
close(wb);
% msgbox('Your grid is ready!');

function [lat, lon, utm, dat] = fill_matrix(utmx, utmy, zone_max, tmp)
% Shapes data into final output

col = size(utmx, 2);	% Number of columns
lin = size(utmx, 1);	% Number of lines

% Preparing coordinate matrix in Lat/Lon
lat = zeros(lin, col);
lon = zeros(lin, col);
zone_mat = ones(size(utmx)).*zone_max;

wb       = waitbar(0,'Filling matrix...');

% Note: got rid of one loop, but UTM2ll does not work with matrices
for i = 1:lin
    [LT, LN] = utm2ll(utmx(i,:), utmy(i,:), zone_mat(i,:));	% Calculate lat/lon coordinate for each point
    
    lat(i,:) = LT;	% Fills up lat matrix
    lon(i,:) = LN;	% Fills up lon matrix
    waitbar(i / lin);
end
close(wb)

utm         = zeros(numel(utmy),3);	% Final XYZ utm matrix (for TEPHRA2 calculations)
utm(:,3)    = ones(numel(utmy),1).*tmp.elevation; 
dat         = zeros(lin, col);      % Final M*N matrix (for map display)

% Filling up final XYZ utm matrix
j = 1;
wb       = waitbar(0,'Making calculation grid...');
for i = 1:lin
    utm(j:i*col,1) = shiftdim(utmx(i,:));
    utm(j:i*col,2) = shiftdim(utmy(i,:));
    j = i*col+1;
    waitbar(i / lin);
end
close(wb)
