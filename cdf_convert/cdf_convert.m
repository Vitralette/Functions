function cdf_convert

%% ******************** Clear ********************************************

clc

%% ******************** User Settings ************************************

%List to overwrite Variable Names and Units of SIM_RTS (ON/OFF)

mode_overwrite=false;
load('SIM_RTS_list.mat')

%Approximate SIM_TIME, if not available (ON/OFF)

mode_simtime=false;

%Reduce Data to SIM_STATUS==1 (ON/OFF)

mode_reduce=false;

%Add SIM_HXW from EC-DMC Interface(ON/OFF)

mode_HXW=false;

%Variables for Extraction

var_names={ 'COB_ETA0' 'COB_ETAP' 'COB_ETAX' 'COB_ETAY'...
        'COB_EP_DX' 'COB_EP_DY' 'COB_EP_DP' 'COB_EP_D0'...
        'FC0_ACTPCX' 'FC0_ACTPCY' 'FC0_ACTPCP' 'FC0_ACTPC0'...
        'EKF_PDOT' 'EKF_QDOT' 'EKF_RDOT' 'EKF_P'...
        'EKF_Q' 'EKF_R' 'EKF_PHI' 'EKF_THETA' 'EKF_PSI' 'EKF_AX' 'EKF_AY'...
        'EKF_AZ' 'EKF_U' 'EKF_V' 'EKF_W'...
        'EKF_WNDN' 'EKF_WNDE' 'EKF_DAD1' 'EKF_DAD2' 'EKF_DNB0' 'EKF_X'...
        'EKF_Y' 'EKF_Z' 'EKF_AX_GC' 'EKF_AY_GC' 'EKF_AZ_GC' 'EKF_AX_FP'...
        'EKF_AY_FP' 'EKF_AZ_FP' 'EKF_ACCN'...
        'EKF_ACCE' 'EKF_ACCU' 'EKF_PHIDOT' 'EKF_THETADOT' 'EKF_PSIDOT'...
        'EKF_VX' 'EKF_VY' 'EKF_VZ' 'EKF_VELN' 'EKF_VELE' 'EKF_VELU'...
        'EKF_U_G' 'EKF_V_G' 'EKF_VX_K' 'EKF_VY_K'...
        'EKF_VCAS' 'EKF_VTAS' 'EKF_VTAS5S' 'EKF_VGND' 'EKF_VGND5S'...
        'EKF_ROC' 'EKF_WNDV' 'EKF_WNDLAM' 'EKF_ALPHA' 'EKF_BETA'...
        'EKF_CHI' 'EKF_GAM' 'EKF_PMH' 'EKF_HAE' 'EKF_HASL'...
        'EKF_BARALT' 'EKF_LAT' 'EKF_LONG' 'EKF_HD_AX' 'EKF_HD_AY'...
        'EKF_HD_AZ' 'EKF_SLINP' 'EKF_GC_FL' 'EKF_GC_FR' 'EKF_GC_RR'...
        'EKF_GC_RL' 'EKF_ACM_11' 'EKF_ACM_12' 'EKF_ACM_21'...
        'EKF_ACM_22' 'EKF_STAT' 'EKF_SENS' 'EKF_S_PD' 'EKF_S_QD'...
        'EKF_S_RD' 'EKF_S_PHI' 'EKF_S_THETA' 'EKF_S_PSI' 'EKF_S_P'...
        'EKF_S_Q' 'EKF_S_R' 'EKF_S_AX' 'EKF_S_AY' 'EKF_S_AZ'...
        'EKF_S_U' 'EKF_S_V' 'EKF_S_W' 'EKF_S_X' 'EKF_S_Y' 'EKF_S_Z'...
        'EKF_S_WN' 'EKF_S_WE' 'EKF_S_AD1' 'EKF_S_AD2' 'EKF_S_NB'...
        'EKF_S00' 'EKF_S01' 'EKF_S02' 'EKF_S03' 'EKF_S04'...
        'EKF_S05' 'EKF_S06' 'EKF_S07' 'EKF_S08' 'EKF_S09' 'EKF_UND'...
        'SIM_RTS189' 'SIM_RTS190' 'SIM_RTS191' 'SIM_RTS192' 'SIM_RTS193'... 
        'SIM_RTS194' 'SIM_RTS195' 'SIM_RTS196' 'SIM_RTS197' 'SIM_RTS198'...
        'SIM_RTS199' 'SIM_RTS200' 'SIM_RTS201' 'SIM_RTS202' 'SIM_RTS203'...
        'SIM_RTS204' 'SIM_RTS205' 'SIM_RTS206' 'SIM_RTS207' 'SIM_RTS208'...
        'SIM_RTS209' 'SIM_RTS210' 'SIM_RTS211' 'SIM_RTS212'...
        'SIM_RTS005' 'SIM_STATUS' 'COB_ETAx' 'COB_ETAY' 'COB_ETAP' ...
        'COB_ETA0' 'CP1_FLI1VA' 'SW0_FTEEXP' 'CP1_TRQF1' 'EKF_WNDDIR'...
        'EKF_WNDMAG' 'HL0_HE_EEW' 'CP1_TFQ' 'DMC_UTCTIME' };
    
%% ******************** Start ********************************************

%***** Initialize ****

mode_simtime_unit=false;
var_names_max=length(var_names);

%***** Find all Files *****

dir_work=pwd;
dir_input=uigetdir;
%dir_input='D:\strb_al\01_DLR\60_Programme\01_MATLAB\40_cdf_convert\Version 1.X\Test Data';

cd(dir_input)

list=dir('*.cdf');
file_list={list.name};
file_list=file_list';

cd(dir_work)

%***** Convert all Files *****

pp_max=length(file_list);

for pp=1:pp_max
    
    disp(file_list{pp})
    
    %***** Select File *****
    
    file_name=file_list{pp};
    out_name=strrep(file_name,'.cdf','.mat');
    
    file_path=[dir_input '\' file_name];
    out_path=[dir_input '\' out_name];

%% ******************** Add SIM_HXW from EC-DMC Interface ****************
    
    if (mode_HXW==true)
        
        num_double=10;
        num_float=100;
        
        %***** Add Double Variables for Extraction *****
        
        nn=var_names_max+1;
        
        for qq=1:num_double
            
            var_names{nn}=['SIM_HWX64' '(' num2str(qq) ')'];
            
            nn=nn+1;
            
        end
        
        %***** Add Float Variables for Extraction *****
        
        for qq=1:num_float
            
            var_names{nn}=['SIM_HWX32' '(' num2str(qq) ')'];
            
            nn=nn+1;
            
        end
        
    end
    
%% ******************** Read Data from CDF *******************************
    
    %***** Read Data *****
    
    [out_struct,unzipped_files]=cdf_read_io(file_path,var_names,0);
    
    %***** Rename Vector Components in var_names *****
    
    rr_max=length(var_names);
    
	for rr=1:rr_max
        
        %Check, if var_names(rr) is a Vector Component
        
        [var_p1,var_p2]=strtok(var_names(rr),'(');
        
        if (isempty(char(var_p2))==false)
            
            %If var_names(rr) is a Vector Component -> rename
            
            var_p2_str=char(var_p2);
            var_p2_len=length(var_p2_str);
            var_p2_num=str2double(var_p2_str(2:var_p2_len-1));
            var_names{rr}=[char(var_p1) '_' num2str(var_p2_num)];
            
        end
        
    end
    
%% ******************** Reorganize Data **********************************
    
    %***** Overwrite SIM_RTS Names from SIM_RTS_list.mat *****
    
    var_names_new=var_names;
    
    if (mode_overwrite==true)
        
        qq_max=length(SIM_RTS_list);
        rr_max=length(var_names);
        
        for qq=1:qq_max
            
            %Current Variable
            
            cur_var=SIM_RTS_list(qq,1);
            
            for rr=1:rr_max
                
                %Check for Match in SIM_RTS_list
                
                if strcmp(cur_var,var_names(rr))
                    
                    var_names_new{rr}=SIM_RTS_list{qq,2};
                    
                    break
                    
                end
                
            end
            
        end
        
    end
    
    %***** Get 'time' and 'time_abs' *****
    
    Data.time=out_struct.time;
    Data.time_abs=out_struct.time_abs;
    
    %***** Get Residual Data *****
    
    qq_max=length(var_names);
    
    for qq=1:qq_max
        
        Data.(var_names_new{qq})=out_struct.(var_names{qq});
        
    end
    
%% ******************** Approximate SIM_TIME *****************************
    
    if (mode_simtime==true&&~isfield(Data,'SIM_TIME'))                      %If active and SIM_TIME does not exists
        
        rr_max=length(Data.SIM_STATUS);
        
        for rr=1:rr_max
            
            if (Data.SIM_STATUS(rr)==1)
                
                Data.SIM_TIME=times(Data.time-Data.time(rr),Data.SIM_STATUS);
                disp 'Warning: Approximate SIM_TIME'
                disp ' '
                
                mode_simtime_unit=true;
                
                break
                
            end
            
        end
        
    elseif (mode_simtime==true&&isfield(Data,'SIM_TIME'))                   %If active and SIM_TIME exists
        
        if (max(Data.SIM_TIME)==0)                                          %If SIM_TIME is zero
           
            rr_max=length(Data.SIM_STATUS);
            
            for rr=1:rr_max
                
                if (Data.SIM_STATUS(rr)==1)
                    
                    Data.SIM_TIME=times(Data.time-Data.time(rr),Data.SIM_STATUS);
                    disp 'Warning: Approximate SIM_TIME'
                    disp ' '
                    
                    break
                    
                end
                
            end
            
        end
        
    end
    
%% ******************** Reduce Data **************************************
    
    %***** Reduce Data with SIM_STATUS Off *****
    
    if (mode_reduce==true)
        
        idx_start=0;
        idx_end=0;
        
        %Seach for Start/End of Simulation
        
        rr_max=length(Data.SIM_STATUS);
        
        for rr=1:rr_max
            
            if (Data.SIM_STATUS(rr)==1&&idx_start==0)
                
                idx_start=rr;
                
            elseif (Data.SIM_STATUS(rr)==0&&idx_start~=0)
                
                %Value for best practice 
                idx_end=rr-200;
                break
                
            elseif (rr==rr_max)
                
                %Value for best practice 
                idx_end=rr-200;
                
            end
            
        end
        
        %Reduce Data
        
        var_names_new=fieldnames(Data);
        qq_max=length(var_names_new);
        
        for qq=1:qq_max
            
            %Current Variable
            
            Data.(var_names_new{qq})=Data.(var_names_new{qq})(idx_start:idx_end);
            
        end
        
    end
    
%% ******************** Units ********************************************
    
    %***** Load Info from File *****
    
    file_info=cdfinfo(file_path);
    
    %***** Define Units of 'time' and 'time_abs' *****
    
    var_units{1,1}='time';
    var_units{1,2}='s';
    var_units{2,1}='time_abs';
    var_units{2,2}='s';
    
    %***** Search Units in File Info *****
    
    qq_max=length(var_names);
    rr_max=length(file_info.VariableAttributes.SIGNALID(:,1));
    
    for qq=1:qq_max
        
        %Current Variable
        
        cur_var=var_names(qq);
        
        for rr=1:rr_max
            
            %For all Signals in File Info
            
            if strcmp(cur_var,file_info.VariableAttributes.SIGNALID(rr,1))
                
                %If Unit of var_names(qq) is found in File Info
                
                var_units{qq+2,1}=file_info.VariableAttributes.SIGNALID{rr,1};
                var_units{qq+2,2}=file_info.VariableAttributes.SIGUNIT{rr,2};
                
                break
                
            elseif (rr==rr_max)
                
                %If Unit of var_names(qq) is NOT found in File Info
                
                var_units{qq+2,1}=char(cur_var);
                var_units{qq+2,2}='-';
                
            end
            
        end
        
    end
    
    %***** Overwrite SIM_RTS Units from SIM_RTS_list.mat *****
    
	if (mode_overwrite==true)
        
        qq_max=length(SIM_RTS_list);
        rr_max=length(var_units);
        
        for qq=1:qq_max
            
            %Current Variable
            
            cur_var=SIM_RTS_list(qq,1);
            
            for rr=1:rr_max
                
                %Check for Match in File Info
                
                if strcmp(cur_var,var_units(rr,1))
                    
                    var_units{rr,1}=SIM_RTS_list{qq,2};
                    var_units{rr,2}=SIM_RTS_list{qq,3};
                    
                    break
                    
                end
                
            end
            
        end
        
    end
    
	%***** Approximate SIM_TIME Units *****
    
    if (mode_simtime_unit==true)
        
        var_units_max=length(var_units);
        
        var_units{var_units_max+1,1}='SIM_TIME';
        var_units{var_units_max+1,2}='s';
        
    end
    
    %***** Add Channel *****
    
    Data.channel.names=char(var_units{:,1});
    Data.channel.units=char(var_units{:,2});
    
%% ******************** Save Data ****************************************
    
    save(out_path,'-struct','Data');
    
%% ******************** New Loop *****************************************
    
    clear Data
    
end

%% ******************** End **********************************************

disp done

end
