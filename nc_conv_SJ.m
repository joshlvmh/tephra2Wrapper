% Matlab code to produce multiple Tephra2 wind files for multiple volcanoes 
% Sourcing ERA-5 hourly netcdf files

% Susanna Jenkins, Earth Observatory of Singapore, 2020.
% Modified from original script for ERA-Interim daily 6 hourly data
% Susanna.Jenkins@ntu.edu.sg

% To read the header information for a netcdf file: ncdisp('File')

% This script, the list of volcanoes (Volcanoes.txt) and the .nc file/s must be in the same folder; 
% Outputs will save there too. 
%cd /home/volcano/Wind/ERA5-3Hrly_2010-2019/

% Establish fixed parameters
NumYears = 10;  
Records = 4;   %Number of records per day
Resolution = 0.25;      %ERA5 resolution
NumVolcanoes = 41;      %Change for your number of volcanoes

% Read in list of volcanoes to produce wind files for
%fid = fopen('Volcanoes.txt')   %Change to wherever you put your list of volcanoes
%Volcs = textscan(fid,'%f %s %f %f %f',NumVolcanoes,'HeaderLines',1);  % One header line, 41 lines in file (in my example), with columns: VNUM, Long, Lat, Elev

% Loop through each volcano, and then each wind file
for v = 1:1 %length(Volcs{1,3})
    VNUM = 1 %Volcs{1}(v);
    Volcano = 'Krakatau' %Volcs{2}(v)
    VolcLat = -6.102 %Volcs{3}(v);
    VolcLong = 105.423 %Volcs{4}(v);
    if (VolcLong < 0)   %i.e. in Western Hem
       VolcLong = 360 + VolcLong; 
    end
    VolcElev = 155 %Volcs{5}(v);
   % if v>1
   %     cd /home/volcano/Wind/ERA5-Hrly_2010-2019/
   % end
    % Currently pulling from /home/volcano/Wind/ERA5-3Hrly_2010-2019/
    WfV = dir('download.nc') %dir(strcat(num2str(VNUM),'_ERA5*V.nc');       
    WfU = dir('download.nc') %(strcat(num2str(VNUM),'_ERA5*U.nc');       
    


    Levels = length(ncread(WfV(1).name, 'level'));
    
    for f = 1:length(WfV)       %This assumes that the V and U files are identical in their parameters, apart from one being U and one being V
        if (f==1)
            date(1:length(ncread(WfV(1).name, 'time'))) = ncread(WfV(f).name, 'time'); 
            Lat = (ncread(WfV(1).name, 'latitude'));
            Long = (ncread(WfV(1).name, 'longitude'));
        else
            date((length(date)+1):((length(date)+1)+length(ncread(WfV(f).name, 'time'))-1)) = ncread(WfV(f).name, 'time');
        end
    end
    Time = length(date);
    
    uMatrix = zeros(Time, Levels);
    for h = 1:Levels
        count = 0;
        for f = 1:1
            %uwnd_all_temp = ncread(WfU(f).name,'u', [(int16(((VolcLong-Long(1))/Resolution)+1)) (int16((Lat(1)-VolcLat)/Resolution)+1) h 1],[1 1 1 (length(ncread(WfU(f).name, 'time')))],[1 1 1 1]);
            uwnd_all_temp = ncread(WfV(f).name,'u', [2 2 h 1],[1 1 1 Time],[1 1 1 1]);     
            uwnd_all_temp = squeeze(uwnd_all_temp);
            uMatrix((count+1):(count+length(uwnd_all_temp)),h) = uwnd_all_temp;  
            count = count+length(uwnd_all_temp);
        end
    end

    vMatrix = zeros(Time, Levels);
    for h = 1:Levels        
        count = 0;
        for f = 1:1
            %vwnd_all_temp = ncread(WfV(f).name,'v', [(int16(((VolcLong-Long(1))/Resolution)+1)) (int16((Lat(1)-VolcLat)/Resolution)+1) h 1],[1 1 1 (length(ncread(WfV(f).name, 'time')))],[1 1 1 1]);     
            vwnd_all_temp = ncread(WfV(f).name,'v', [2 2 h 1],[1 1 1 Time],[1 1 1 1]);     
            vwnd_all_temp = squeeze(vwnd_all_temp);
            vMatrix((count+1):(count+length(vwnd_all_temp)),h) = vwnd_all_temp;  
            count = count+length(vwnd_all_temp);
        end
    end

    Dmatrix = zeros(Time,Levels);       % matrix of direction for each record (rows) at each height (cols)
    Imatrix = zeros(Time,Levels);       % matrix of intensity for each record (rows) at each height (cols)

    for h = 1:Levels  
        Dmatrix(:, h) = mod(90-atan2d(vMatrix(:,h),uMatrix(:,h)), 360); %calculation from u and vmatrix... for Direction.
        Imatrix(:, h) = sqrt((uMatrix(:,h).^2)+(vMatrix(:,h).^2));      %calculation from u and vmatrix... for Speed.
    end
    
    % To output TephraProb wind files:
    %mkdir(strcat(num2str(VNUM),'/'));

    Tephra2Out = zeros(h,3);
    stor_data = zeros(Levels,3,length(Dmatrix));    %These are for tephraProb analysis of wind, if wanted
    stor_time = zeros(length(Dmatrix),6);

    %From: http://www.csgnetwork.com/pressurealtcalc.html
    Altitude = {32435,30760,29675,28180,27115,25905,23315,21630,19315,17660,15790,14555,13505,12585,11770,11030,10360,9160,8115,7180,6340,5570,4865,4205,3590,3010,2465,2205,1950,1700,1455,1220,990,760,540,325,110};
    AltAsNumber = cell2mat(Altitude);
    AltAsNumber = reshape(AltAsNumber,Levels,1);
    Year = {2010,2011,2012,2013,2014,2015,2016,2017,2018,2019};

    for r = 1:1 %length(Dmatrix)   %9999 % length(Dmatrix)
        for h = 1:Levels
            Tephra2Out(h,1) = Altitude{h};
            Tephra2Out(h,2) = Imatrix(r,h); 
            Tephra2Out(h,3) = Dmatrix(r,h);

            %For tephraProb wind.mat stored file
            stor_data(h,1,r) = Tephra2Out(h,1); %Altitude
            stor_data(h,2,r) = Tephra2Out(h,2); %Speed
            stor_data(h,3,r) = Tephra2Out(h,3); %Dir
            stor_time(r,1) = Year{(ceil(r/Records/12))}; %Year 
            stor_time(r,2) = ceil(((r/Records))-(12*((ceil(r/Records/12))-1)));  %Month
            stor_time(r,3) = ((r-(((ceil(r/Records))-1)*Records))-1)*(24/Records);  %Day
            stor_time(r,4) = ((r-(((ceil(r/Records))-1)*Records))-1)*(24/Records);       %Hr
        end

       % sprintf('%f',Tephra2Out)
        for i = 37:-1:1     %i.e. output in reverse order
          s = sprintf('%u\t%.1f\t%.1f\r', Tephra2Out(i,:)); % write dir and int to 1.d.p.
          disp(s)
        end
        %To output TEPHRAPROB 00001.gen, 00002.gen files:
        num = strcat(num2str(stor_time(r,4)),'_',num2str(stor_time(r,3)),'_',num2str(stor_time(r,2)),'_',num2str(stor_time(r,1)));
        disp(num)

        %write out for Tephra2/Prob:
%        filename2 = strcat(num2str(VNUM),'/',num,'.gen');
%        fid2=fopen(filename2, 'a');
%        for h = 37:-1:1     %i.e. output in reverse order
%            fprintf(fid2, '%u\t%.1f\t%.1f\r\n', Tephra2Out(h,:)); % write dir and int to 1.d.p.
%        end
%        fclose(fid2);
    end
end
