(* ::Package:: *)

%%%%%%% This script is to be used in Matlab softwar
%%%%%%% walvet-coherence toolbox and ASToolbox2014 from Anguiar-Conraria and Soares (2014) has to be download.
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
%%% Warning : Because of the number of Monte Carlo simulations used to assess
%%% significance , script takes long (one part of the constraint model took me 18 hours on an Asus ZenBook14 - intel core i7 8th gen - )
 
 %%%%%%%%%%%%%%%%%     Clear all variables and screen          %%%%%%%%%%%%% 
clear all;
clc;


%%%%%%%%%%%%%%%%%            Update path                      %%%%%%%%%%%%%
% NOTE: HAS TO BE CHANGED APPROPRIATELY!!

addpath('C:\Users\marie\Documents\AS\ASToolbox2014\Functions\Auxiliary');
addpath('C:\Users\marie\Documents\AS\ASToolbox2014\Functions\WaveletTransforms');
 
 
%%%%% To save each figure one can use the following command
%%%%% The command has to be added after each figure command
% NOTE: PATH HAS TO BE CHANGED APPROPRIATELY!
% saveas(gcf, 'C:\Users\marie\Documents\AS\FigExample', 'fig');
 
 
 
%% defaultStream = RandStream.getDefaultStream;
%% savedState = defaultStream.State; % This is to guarantee that we obtain 
%% the same results if we re-use the script in the same matlab session
%%   
%%%%%%%%%%%%%%              Read data  WTI / SUN AND WIND     %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% To import data 
% NOTE: PATH HAS TO BE CHANGED APPROPRIATELY!
data=xlsread('C:\......\n ame_file.xlsx');
%%%%%%%%%%%%% keep only data if trend<2852
 
t = datare.trend; % Vector of times
 
x = datare.return_wti; % WTI
y = datare.return_solar; % SUN
z = datare.return_wind; % WIND
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
 
dt=1/60;
dj = 1/25;
lowPeriod = 2/60;
upPeriod = 1000/60;
pad=0;
mother = 'Morlet';
be=6.0;
ga=[];
 
%%%%%   Choice of smoothing parameters for coherency computations    %%%%%%
% wT_type='Ham';
wT_size=2;
% wS_type='Ham';
wS_size=2;
 
% This choice of windows requires the use of Signal Processing Toolbox
% If you do not have this toolbox, choose
 wT_type='Bar'
 wS_type='Bar'
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
nSurCO=5000;    % This is the number of Monte Carlo simulations            
                % used to assess statistical significance    
                % With this number, it takes long!
% nSurCO=10; % Just to test
sur_type='ARMABoot';      
p=1;
q=0;     % Surrogates are based on an ARMA(1,1) model and bootstrap
         % Makes use of Econometrics Toolbox
 
% NOTE: If you do not have Econometrics Toolbox, you have to choose
%  q=0 (AR(1) model) but in this case, the pictures do not exactly 
% replicate the ones in  the paper
 
%%%%%%%%%%%%%%%%%%%  Wavelet Coherencies Computation    %%%%%%%%%%%%%%%%%%%%
 
% Coherency WTI/SUN 
[WCOxy,Wxy,sWxy,~,~,~,pvCOxy] =...
       AWCO(x,y,dt,dj,lowPeriod,upPeriod,pad,mother,be,ga,...
            wT_type,wT_size,wS_type,wS_size,...
            nSurCO,sur_type,p,q);
        
% Coherency WTI/WIND 
[WCOxz,Wxz,sWxz,periods,~,coi,pvCOxz] =...
       AWCO(x,z,dt,dj,lowPeriod,upPeriod,pad,mother,be,ga,...
            wT_type,wT_size,wS_type,wS_size,...
            nSurCO,sur_type,p,q);
        
%%%%%%%%    Frequency (period) band selections (for time-lag)     %%%%%%%%
 
% Lower and upper  periods (short regime)
lowPF1=2;
upPF1=4;
 
% Lower and upper  periods (long regime) 
lowPF2=8;
upPF2=10;
 
%%%%%%%%%%%%%%%%%%%      Time-lags  computation          %%% 5%%%%%%%%%%%%%%
 
% Time-lags WTI/SUN
[~,~,~,~,lagF1xy]=AWCOOutput(WCOxy,Wxy,periods,lowPF1,upPF1);% 
[~,~,~,~,lagF2xy]=AWCOOutput(WCOxy,Wxy,periods,lowPF2,upPF2);% 
 
% Time-lags WTI/WIND 
[~,~,~,~,lagF1xz]=AWCOOutput(WCOxz,Wxz,periods,lowPF1,upPF1);% 
[~,~,~,~,lagF2xz]=AWCOOutput(WCOxz,Wxz,periods,lowPF2,upPF2);%
 
% defaultStream.State = savedState; % To obtain the same results if we reuse
% the script in the same matlab section
 
%% Plots
figure(1)
 
% Things common to all pictures
pictEnh = 5;   % Picture enhancer
perc = 0.05;
xlim = [t(1) t(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4 9 15];  
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
%%%%%%%%%%%%%          Plot of Coherency WTI/SUN       %%%%%%%%%%%%%%%%%%%
subplot(4,7,[1 10])
% Makes use of function plotWAVE (new function in Functions\Auxiliary)
tit='(a .1)  Wavelet Coherency (WTI,SUN) ';
  plotWAVE(WCOxy,t,periods,coi,1,...
                pvCOxy,perc,[],xticks,[],yticks,tit,pictEnh);
 xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'});  
  
%%%%%%%%%%%%%%%%     Plot Time-Lags   WTI/SUN            %%%%%%%%%%%%%%%%%%
 % Makes use of function plotPHASE 
 % (new function in Functionx\Auxiliary)
 subplot(4,7,[15 17])
    tit='(a .2)  4~8 months frequency band';
    plotPHASE(lagF1xy,t,tit,1,xlim,xticks,' ')
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'});
 
    
 subplot(4,7,[22 24])
    tit='(a .3)  18~20 months frequency band';
    plotPHASE(lagF2xy,t,tit,1,xlim,xticks,'    Phase-Difference');   
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
  
    
%%%%%%%%%%%%%          Plot of Coherency  WTI/WIND      %%%%%%%%%%%%%%%%%%%%%%
 
subplot(4,7,[5 14])
    tit= '(b .1)  Wavelet Coherency (WTI,WIND) ';
    plotWAVE(WCOxz,t,periods,coi,1,...
                pvCOxz,perc,[],xticks,[],yticks,tit,pictEnh);        
 xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
   
%%%%%%%%%%%%%%%%%%%%%%  Plot Time-Lags  WTI/WIND       %%%%%%%%%%%%%%%%%%%%%
 
 subplot(4,7,[19 21])
    tit='(b .2)  4~8 months years frequency band';
    plotPHASE(lagF1xz,t,tit,1,xlim,xticks,' ');
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
 subplot(4,7,[26 28])
    tit='(b .3)  18~20 months frequency band';
    plotPHASE(lagF2xz,t,tit,1,xlim,xticks,'  Phase-Difference');
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
ttime=datare.trend; % Vector of times
 
 
X = datare.return_solar; % SUN 
Y = datare.return_wti; % WTI
Z = datare.return_vix; % VIX
W = datare.return_epu; % EPU
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/30;
lowerPeriod=2/60; 
upperPeriod=1000/60;
% NOTE: Other parameters take default values
 
%%%%%   Choice of smoothing parameters for coherency computations    %%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size =2;
% NOTE: This choice of windows makes use of the Signal Processing Toolbox
% If you do not have this toolbox, choose
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
% This is the number of Monte Carlo simulations used to assess
% significance 
%  NOTE: Takes long!
nSur=5000          
% sur_type = 'ARMAEcon'; 
% p = 1;
% q = 1; 
 % Surrogates are based on an ARMA(1,1) model and drawing errors from a
 % Gaussian distribution
 % Makes use of Econometrics Toolbox
 % NOTE: If you do not have the Econometrics Toolbox, you have to choose
 sur_type='ARMABoot'
 p=1;
 q=0;
 
 
%%%%%%%%%%%%%%%%%  Wavelet Coherency Sun/Oil Computation     %%%%%%%%%%%%%%%
[WCO,d1,d2,period,d3,d4,pvCO] = ...
    AWCO(X,Y,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
         wT_type,wT_size,wS_type,wS_size, nSur,sur_type,p,q); % #ok<*ASGLU>
 
 
 
%%%%%%%%%%%%%%%%%%%  Phase Difference Sun/Oil Computation    %%%%%%%%%%%%%%%
%%%  Frequency (period) band selection     
lowPF1=3;
upPF1=9;
 
% Lower and upper  periods (long regime) 
% lowPF2=4.3;
% upPF2=8.6;
 
%%% Phase-Difference Computation for selected band
[d1,d2,d3,dphaseXY] = AWCOOutput(WCO, WCO,period,lowPF1,upPF1);
 
 
 
% Phase-difference is computed from coherency, i.e. form Eq. (27) in 
% NIPE WP 16/2011
 
%%%%%%%%%%%   Partial Wavelet Coherency Sun/Oil Computation      %%%%%%%%%%%
coher_type='part'; % Compute partial wavelet coherency only
indexP=2;
 
[WMCO,WPCO,periods,coi,pvM,pvP] =...
  MPAWCO([X Y Z W],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],coher_type,...
         indexP,wT_type,wT_size,wS_type,wS_size,nSur,sur_type,p,q);
      
%%%%%%%%%%%%%  Partial Phase Difference Sun /Oil Computation     %%%%%%%%%%%%
pdphaseXY = MPAWCOOutput(WPCO,periods,lowPF1,upPF1);
 
 
 
%% Plots
 
figure(2)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
%%%%%%%%%%%%%%%%%%%%    Plot coherency SUN/WTI    %%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,1)
    tit = '(a .1)  Wavelet Coherency (SUN,WTI)';
    plotWAVE(WCO,ttime,period,coi,1,...
                pvCO,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
     
%%%%%%%%%%%%%%%%%%   Plot phase-difference SUN/WTI   %%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,3)
    tit = '(a .2)  128 - 520 Days frequency band';
    plotPHASE(dphaseXY,ttime,tit,1,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
    
%%%%%%%%%%%%%%%%%%%%%   Plot partial coherency SUN/WTI  %%%%%%%%%%%%%%%%%%%%
subplot(2,2,2)
    tit = '(b .1)  Wavelet Partial Coherency (SUN, WTI | VIX, EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,...
                pvP,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference SUN/WTI %%%%%%%%%%%%%%%%%% 
subplot(2,2,4)
    tit='(b .2)  128 - 520 Days frequency band';
    plotPHASE(pdphaseXY,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%             WIND data                %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
%%%%%%%%%%%%%%              Read data                %%%%%%%%%%%%%%
 
 
ttime=datare.trend; % Vector of times
 
 
X =  datare.return_wind; % SUN 
Y = datare.return_wti; % WTI
Z = datare.return_vix; % VIX
W = datare.return_epu; % EPU
 
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/30;
lowerPeriod=2/60; 
upperPeriod=1000/60;
% NOTE: Other parameters take default values
 
%%%%%   Choice of smoothing parameters for coherency computations    %%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size =2;
% NOTE: This choice of windows makes use of the Signal Processing Toolbox
% If you do not have this toolbox, choose
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
% This is the number of Monte Carlo simulations used to assess
% significance 
%  NOTE: Takes long!
nSur=5000;           
% sur_type = 'ARMAEcon'; 
% p = 1;
% q = 1; 
 % Surrogates are based on an ARMA(1,1) model and drawing errors from a
 % Gaussian distribution
 % Makes use of Econometrics Toolbox
 % NOTE: If you do not have the Econometrics Toolbox, you have to choose
 sur_type='ARMABoot'
 p=1;
 q=0;
%%%%%%%%%%%%%%%%%  Wavelet Coherency WIND/Oil Computation     %%%%%%%%%%%%%%%
[WCO,d1,d2,period,d3,d4,pvCO] = ...
    AWCO(X,Y,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
         wT_type,wT_size,wS_type,wS_size, nSur,sur_type,p,q); % #ok<*ASGLU>
 
 
 
%%%%%%%%%%%%%%%%%%%  Phase Difference WIND/Oil Computation    %%%%%%%%%%%%%%%
%%%  Frequency (period) band selection  sans   
lowPF1=2.1;
upPF1=4.3;
 
%%%  Frequency (period) band selection sans    
lowPF2=8.6;
upPF2=14;
 
% Lower and upper  periods avec
lowPF3=4.3;
upPF3=8.6;
 
 
%%% Phase-Difference Computation for selected band
[d1,d2,d3,dphaseXY1] = AWCOOutput(WCO,WCO,period,lowPF1,upPF1);
[d1,d2,d3,dphaseXY2] = AWCOOutput(WCO,WCO,period,lowPF2,upPF2);
 
% Phase-difference is computed from coherency, i.e. form Eq. (27) in 
% NIPE WP 16/2011
 
%%%%%%%%%%%   Partial Wavelet Coherency WIND/Oil Computation      %%%%%%%%%%%
coher_type='part'; % Compute partial wavelet coherency only
indexP=2;
 
[WMCO,WPCO,periods,coi,pvM,pvP] =...
  MPAWCO([X Y Z W],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],coher_type,...
         indexP,wT_type,wT_size,wS_type,wS_size,nSur,sur_type,p,q);
 
      
%%%%%%%%%%%%%  Partial Phase Difference WIND/Oil Computation     %%%%%%%%%%%%
pdphaseXY1 = MPAWCOOutput(WPCO,periods,lowPF1,upPF1);
pdphaseXY3 = MPAWCOOutput(WPCO,periods,lowPF3,upPF3);
 
 
%% Plots
 
figure(3)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
%%%%%%%%%%%%%%%%%%%%    Plot coherency WIND/WTI    %%%%%%%%%%%%%%%%%%%%%%%%
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (WIND,WTI)';
    plotWAVE(WCO,ttime,period,coi,1,...
                pvCO,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
     
%%%%%%%%%%%%%%%%%%   Plot phase-difference WIND/WTI   %%%%%%%%%%%%%%%%%%%%%%%
subplot(4,7,[15 17])
    tit = '(a .2)  128 - 260 Days frequency band';
    plotPHASE(dphaseXY1,ttime,tit,1,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%%   Plot phase-difference WIND/WTI   %%%%%%%%%%%%%%%%%%%%%%%
subplot(4,7,[22 24])
    tit = '(a .3)  520 - 888 Days frequency band';
    plotPHASE(dphaseXY2,ttime,tit,1,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
    
%%%%%%%%%%%%%%%%%%%%%   Plot partial coherency WIND/WTI  %%%%%%%%%%%%%%%%%%%%
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (WIND, WTI | VIX, EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,...
                pvP,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference WIND/WTI %%%%%%%%%%%%%%%%%% 
subplot(4,7,[19 21])
    tit='(b .2)  128 - 260 days frequency band';
    plotPHASE(pdphaseXY1,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference WIND/WTI %%%%%%%%%%%%%%%%%% 
subplot(4,7,[26 28])
    tit='(b .2)  260 - 520 days frequency band';
    plotPHASE(pdphaseXY3,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 
 
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%             GEO data                %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%              Read data                %%%%%%%%%%%%%%
 
 
ttime=datare.trend; % Vector of times
 
 
X =  datare.return_geo; % SUN 
Y = datare.return_wti; % WTI
Z = datare.return_vix; % VIX
W = datare.return_epu; % EPU
 
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/30;
lowerPeriod=2/60; 
upperPeriod=1000/60;
% NOTE: Other parameters take default values
 
%%%%%   Choice of smoothing parameters for coherency computations    %%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size =2;
% NOTE: This choice of windows makes use of the Signal Processing Toolbox
% If you do not have this toolbox, choose
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
% This is the number of Monte Carlo simulations used to assess
% significance 
%  NOTE: Takes long!
nSur=5000;           
% sur_type = 'ARMAEcon'; 
% p = 1;
% q = 1; 
 % Surrogates are based on an ARMA(1,1) model and drawing errors from a
 % Gaussian distribution
 % Makes use of Econometrics Toolbox
 % NOTE: If you do not have the Econometrics Toolbox, you have to choose
 sur_type='ARMABoot'
 p=1;
 q=0;
%%%%%%%%%%%%%%%%%  Wavelet Coherency GEO/Oil Computation     %%%%%%%%%%%%%%%
[WCO,d1,d2,period,d3,d4,pvCO] = ...
    AWCO(X,Y,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
         wT_type,wT_size,wS_type,wS_size, nSur,sur_type,p,q); % #ok<*ASGLU>
 
%%%%%%%%%%%%%%%%%%%  Phase Difference GEO/Oil Computation    %%%%%%%%%%%%%%%
%%%  Frequency (period) band selection     
lowPF1=2.1;
upPF1=4.3;
 
%%%  Frequency (period) band selection     
lowPF2=8.6;
upPF2=14;
 
 
%%% Phase-Difference Computation for selected band
[d1,d2,d3,dphaseXY] = AWCOOutput(WCO, WCO,period,lowPF1,upPF1);
 
% Phase-difference is computed from coherency, i.e. form Eq. (27) in 
% NIPE WP 16/2011
 
%%%%%%%%%%%   Partial Wavelet Coherency GEO/Oil Computation      %%%%%%%%%%%
coher_type='part'; % Compute partial wavelet coherency only
indexP=2;
 
[WMCO,WPCO,periods,coi,pvM,pvP] =...
  MPAWCO([X Y Z W],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],coher_type,...
         indexP,wT_type,wT_size,wS_type,wS_size,nSur,sur_type,p,q);
      
%%%%%%%%%%%%%  Partial Phase Difference GEO/Oil Computation     %%%%%%%%%%%%
pdphaseXY = MPAWCOOutput(WPCO,periods,lowPF1,upPF1);
pdphaseXY2 = MPAWCOOutput(WPCO,periods,lowPF2,upPF2);
%% Plots
 
figure(4)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
%%%%%%%%%%%%%%%%%%%%    Plot coherency GEO/WTI    %%%%%%%%%%%%%%%%%%%%%%%%
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (GEO,WTI)';
    plotWAVE(WCO,ttime,period,coi,1,...
                pvCO,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
     
%%%%%%%%%%%%%%%%%%   Plot phase-difference GEO/WTI   %%%%%%%%%%%%%%%%%%%%%%%
subplot(4,7,[15 17])
    tit = '(a .2)  128 - 260 Days frequency band';
    plotPHASE(dphaseXY,ttime,tit,1,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
    
%%%%%%%%%%%%%%%%%%%%%   Plot partial coherency GEO/WTI  %%%%%%%%%%%%%%%%%%%%
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (GEO, WTI | VIX, EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,...
                pvP,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference GEO/WTI %%%%%%%%%%%%%%%%%% 
subplot(4,7,[19 21])
    tit='(b .2)  128 - 260 Days frequency band';
    plotPHASE(pdphaseXY,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference GEO/WTI %%%%%%%%%%%%%%%%%% 
subplot(4,7,[26 28])
    tit='(b .3)  520 - 888 Days frequency band';
    plotPHASE(pdphaseXY2,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 
 
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%             BIO data                %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
ttime=datare.trend; % Vector of times
 
 
X =  datare.return_bio; % SUN 
Y = datare.return_wti; % WTI
Z = datare.return_vix; % VIX
W = datare.return_epu; % EPU
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/30;
lowerPeriod=2/60; 
upperPeriod=1000/60;
% NOTE: Other parameters take default values
 
%%%%%   Choice of smoothing parameters for coherency computations    %%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size =2;
% NOTE: This choice of windows makes use of the Signal Processing Toolbox
% If you do not have this toolbox, choose
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
% This is the number of Monte Carlo simulations used to assess
% significance 
%  NOTE: Takes long!
nSur=5000;           
% sur_type = 'ARMAEcon'; 
% p = 1;
% q = 1; 
 % Surrogates are based on an ARMA(1,1) model and drawing errors from a
 % Gaussian distribution
 % Makes use of Econometrics Toolbox
 % NOTE: If you do not have the Econometrics Toolbox, you have to choose
 sur_type='ARMABoot'
 p=1;
 q=0;
%%%%%%%%%%%%%%%%%  Wavelet Coherency BIO/Oil Computation     %%%%%%%%%%%%%%%
[WCO,d1,d2,period,d3,d4,pvCO] = ...
    AWCO(X,Y,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
         wT_type,wT_size,wS_type,wS_size, nSur,sur_type,p,q); % #ok<*ASGLU>
 
%%%%%%%%%%%%%%%%%%%  Phase Difference BIO/Oil Computation    %%%%%%%%%%%%%%%
%%%  Frequency (period) band selection     
lowPF1=0.5;
upPF1=2;
%%%  Frequency (period) band selection     
lowPF2=0.5;
upPF2=2;
%%%  Frequency (period) band selection     
lowPF3=2.1;
upPF3=8.6;
 
%%% Phase-Difference Computation for selected band
[d1,d2,d3,dphaseXY1] = AWCOOutput(WCO, WCO,period,lowPF1,upPF1);
[d1,d2,d3,dphaseXY2] = AWCOOutput(WCO, WCO,period,lowPF3,upPF3);
 
% Phase-difference is computed from coherency, i.e. form Eq. (27) in 
% NIPE WP 16/2011
 
%%%%%%%%%%%   Partial Wavelet Coherency BIO/Oil Computation      %%%%%%%%%%%
coher_type='part'; % Compute partial wavelet coherency only
indexP=2;
 
[WMCO,WPCO,periods,coi,pvM,pvP] =...
  MPAWCO([X Y Z W],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],coher_type,...
         indexP,wT_type,wT_size,wS_type,wS_size,nSur,sur_type,p,q);
      
%%%%%%%%%%%%%  Partial Phase Difference BIO/Oil Computation     %%%%%%%%%%%%
pdphaseXY2 = MPAWCOOutput(WPCO,periods,lowPF2,upPF2);
pdphaseXY3 = MPAWCOOutput(WPCO,periods,lowPF3,upPF3);
 
%% Plots
 
figure(5)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
%%%%%%%%%%%%%%%%%%%%    Plot coherency BIO/WTI    %%%%%%%%%%%%%%%%%%%%%%%%
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (BIO,WTI)';
    plotWAVE(WCO,ttime,period,coi,1,...
                pvCO,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
     
%%%%%%%%%%%%%%%%%%   Plot phase-difference BIO/WTI   %%%%%%%%%%%%%%%%%%%%%%%
subplot(4,7,[15 17])
    tit = '(a .2)  32 - 128 Days frequency band';
    plotPHASE(dphaseXY1,ttime,tit,1,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%%   Plot phase-difference BIO/WTI   %%%%%%%%%%%%%%%%%%%%%%%
subplot(4,7,[22 24])
    tit = '(a .3)  128 - 512 Days frequency band';
    plotPHASE(dphaseXY2,ttime,tit,1,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 
    
%%%%%%%%%%%%%%%%%%%%%   Plot partial coherency BIO/WTI  %%%%%%%%%%%%%%%%%%%%
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (BIO, WTI | VIX, EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,...
                pvP,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference BIO/WTI %%%%%%%%%%%%%%%%%% 
subplot(4,7,[19 21])
    tit='(b .2)  32 - 128 Days frequency band';
    plotPHASE(pdphaseXY2,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference BIO/WTI %%%%%%%%%%%%%%%%%% 
subplot(4,7,[26 28])
    tit='(b .3)  128 - 512 Days frequency band';
    plotPHASE(pdphaseXY3,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%       Wavelet decomposition
 
addpath('C:\Program Files\Matlab2\toolbox\walvet-coherence')

 
%%%%%%%%%%%%% ENTIER
 
 
wtiwt = modwt(datare.return_wti,'db2',9);
sunwt = modwt(datare.return_solar,'db2',9);
windwt= modwt(datare.return_wind,'db2',9);
geowt = modwt(datare.return_geo,'db2',9);
biowt = modwt(datare.return_bio,'db2',9);
 
 
wtiwt_t=wtiwt.'
sunwt_t =sunwt.'
windwt_t=windwt.'
geowt_t = geowt.'
biowt_t = biowt.'
 
%%%%%%%%%%%%% save values inn excel

%%%%%%%%%%%%% ENTIER trend <2852
%%%%%%%%%%%%% Avant trend <2361
%%%%%%%%%%%%% COVID trend>2360
 
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Constraint one by one 
 
 
   
%%%%%%%%%%%%%%              Read data                %%%%%%%%%%%%%%
addpath('C:\Users\Documents\AS\ASToolbox2014\Functions\Auxiliary');
addpath('C:\Users\Documents\AS\ASToolbox2014\Functions\WaveletTransforms');
 
%%%%%%%%%%%%%% SUN \.16 WTI |VIX
 
 
 
ttime=datare.trend; % Vector of times
 
 
X = datare.return_solar; % SUN 
Y = datare.return_wti; % WTI
Z = datare.return_vix; % VIX
% W = datare.return_epu; % EPU
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/25;
lowerPeriod = 2/60;
upperPeriod = 1000/60;
% NOTE: Other parameters take default values
 
 
%%%%%%%%%%%%    Choice of smoothing parameters for Coherency   %%%%%%%%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size= 2;
% NOTE: This choice of windows require the use of the Signal Processing Toolbox
% If you do not have this toolbox, use
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
nSurCO=5000;    % This is the number of Monte Carlo simulations            
                % used to assess statistical significance    
                % With this number, it takes long!
 
 
%%%%%   Frequency (period) band selections (for phase-differences)   %%%%%
% Lower and upper  periods (short regime)
lpf_SR=1.1;
upf_SR=2.2;
 
% Lower and upper  periods (long regime)
lpf_LR=3;
upf_LR=9;
 
%%%%%%% Computation of Coherency and Phase-Differences of X,Y    %%%%%%%%%
[WCO,d1,d2,period] = ...
    AWCO(Y,X,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
    wT_type,wT_size,wS_type,wS_size); % #ok<*ASGLU>
 
[d1,d2,d3,dphase_SR] = AWCOOutputV2(WCO,WCO,period,lpf_SR,upf_SR);
[d1,d2,d3,dphase_LR] = AWCOOutputV2(WCO,WCO,period,lpf_LR,upf_LR);
% Computation of Partial Coherency and Partial Phase-Differences of X,Y    %
coher_type='part'; % Compute partial coherency only
indexP=2;
[d1,WPCO,periods,coi] =...
          MPAWCO([Y X Z],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
          coher_type,indexP,wT_type,wT_size,wS_type,wS_size);
      
pdphase_SR = MPAWCOOutputV2(WPCO,periods,lpf_SR,upf_SR);
pdphase_LR = MPAWCOOutputV2(WPCO,periods,lpf_LR,upf_LR);
 
%% Plots
figure(6)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
 
% Plot wavelet coherency
% Uses function plotWAVE (new function in Functions\Auxiliary)
 
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (WTI, SUN)';
    plotWAVE(WCO,ttime,period,coi,1,[],[],xlim,xticks,[],yticks,tit,pictEnh);   
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
      
% Plot phase-difference (SR)  
% Uses function plotPHASE (new function in Functions\Auxiliary)
subplot(4,7,[15 17])
    tit='(a .2)  62 - 128 days frequency band';
    plotPHASE(dphase_SR,ttime,tit,1,xlim,xticks); 
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
   
    
%  Plot phase-difference (LR)
subplot(4,7,[22 24])
    tit = '(a .3)  180 - 520 days frequency band';
    plotPHASE(dphase_LR,ttime,tit,1,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
% Plot partial wavelet coherency   
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (WTI,SUN|VIX)';
    plotWAVE(WPCO,ttime,period,coi,2,[],[],xlim,xticks,[],yticks,tit,pictEnh);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
    
% Plot partial phase-difference (SR)      
subplot(4,7,[19 21])
    tit = '(b .2) 62 - 128 days frequency band';
    plotPHASE(pdphase_SR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
    
% Plot partial phase-difference (LR)    
subplot(4,7,[26 28])
    tit = '(b .3) 180 - 520 days frequency band';
    plotPHASE(pdphase_LR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
 
 %%%%%%%%%%%%%% SUN \.16 WTI |EPU
 
ttime=datare.trend; % Vector of times
 
 
X = datare.return_solar; % SUN 
Y = datare.return_wti; % WTI
Z = datare.return_epu; % EPU
% W = datare.return_epu; % EPU
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/25;
lowerPeriod = 2/60;
upperPeriod = 1000/60;
% NOTE: Other parameters take default values
 
 
%%%%%%%%%%%%    Choice of smoothing parameters for Coherency   %%%%%%%%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size= 2;
% NOTE: This choice of windows require the use of the Signal Processing Toolbox
% If you do not have this toolbox, use
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
nSurCO=5000;    % This is the number of Monte Carlo simulations            
                % used to assess statistical significance    
                % With this number, it takes long!
 
 
%%%%%   Frequency (period) band selections (for phase-differences)   %%%%%
% Lower and upper  periods (short regime)
lpf_SR=3;
upf_SR=4;
 
% Lower and upper  periods (long regime)
lpf_LR=4;
upf_LR=9;
 
%%%%%%% Computation of Coherency and Phase-Differences of X,Y    %%%%%%%%%
[WCO,d1,d2,period] = ...
    AWCO(Y,X,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
    wT_type,wT_size,wS_type,wS_size); % #ok<*ASGLU>
 
[d1,d2,d3,dphase_SR] = AWCOOutputV2(WCO,WCO,period,lpf_SR,upf_SR);
[d1,d2,d3,dphase_LR] = AWCOOutputV2(WCO,WCO,period,lpf_LR,upf_LR);
% Computation of Partial Coherency and Partial Phase-Differences of X,Y    %
coher_type='part'; % Compute partial coherency only
indexP=2;
[d1,WPCO,periods,coi] =...
          MPAWCO([Y X Z],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
          coher_type,indexP,wT_type,wT_size,wS_type,wS_size);
      
pdphase_SR = MPAWCOOutputV2(WPCO,periods,lpf_SR,upf_SR);
pdphase_LR = MPAWCOOutputV2(WPCO,periods,lpf_LR,upf_LR);
 
%% Plots
figure(7)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
 
% Plot wavelet coherency
% Uses function plotWAVE (new function in Functions\Auxiliary)
 
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (WTI, SUN)';
    plotWAVE(WCO,ttime,period,coi,1,[],[],xlim,xticks,[],yticks,tit,pictEnh);   
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
      
% Plot phase-difference (SR)  
% Uses function plotPHASE (new function in Functions\Auxiliary)
subplot(4,7,[15 17])
    tit='(a .2)  128 - 250 days frequency band';
    plotPHASE(dphase_SR,ttime,tit,1,xlim,xticks); 
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
   
    
%  Plot phase-difference (LR)
subplot(4,7,[22 24])
    tit = '(a .3)  250 - 520 days frequency band';
    plotPHASE(dphase_LR,ttime,tit,1,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
% Plot partial wavelet coherency   
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (WTI,SUN|EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,[],[],xlim,xticks,[],yticks,tit,pictEnh);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
    
% Plot partial phase-difference (SR)      
subplot(4,7,[19 21])
    tit = '(b .2) 128 - 250 days frequency band';
    plotPHASE(pdphase_SR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
    
% Plot partial phase-difference (LR)    
subplot(4,7,[26 28])
    tit = '(b .3) 250 - 520 days frequency band';
    plotPHASE(pdphase_LR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 

%%%%%%%%%%%%%% WIND \.16 WTI |VIX 
 
 
ttime=datare.trend; % Vector of times
 
 
X = datare.return_wind; % wind 
Y = datare.return_wti; % WTI
Z = datare.return_vix; % VIX
% W = datare.return_epu; % EPU
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/25;
lowerPeriod = 2/60;
upperPeriod = 1000/60;
% NOTE: Other parameters take default values
 
 
%%%%%%%%%%%%    Choice of smoothing parameters for Coherency   %%%%%%%%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size= 2;
% NOTE: This choice of windows require the use of the Signal Processing Toolbox
% If you do not have this toolbox, use
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
nSurCO=5000;    % This is the number of Monte Carlo simulations            
                % used to assess statistical significance    
                % With this number, it takes long!
 
 
%%%%%   Frequency (period) band selections (for phase-differences)   %%%%%
% Lower and upper  periods (short regime)
lpf_SR=1.1;
upf_SR=2.2;
 
% Lower and upper  periods (long regime)
lpf_LR=3;
upf_LR=9;
 
%%%%%%% Computation of Coherency and Phase-Differences of X,Y    %%%%%%%%%
[WCO,d1,d2,period] = ...
    AWCO(Y,X,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
    wT_type,wT_size,wS_type,wS_size); % #ok<*ASGLU>
 
[d1,d2,d3,dphase_SR] = AWCOOutputV2(WCO,WCO,period,lpf_SR,upf_SR);
[d1,d2,d3,dphase_LR] = AWCOOutputV2(WCO,WCO,period,lpf_LR,upf_LR);
% Computation of Partial Coherency and Partial Phase-Differences of X,Y    %
coher_type='part'; % Compute partial coherency only
indexP=2;
[d1,WPCO,periods,coi] =...
          MPAWCO([Y X Z],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
          coher_type,indexP,wT_type,wT_size,wS_type,wS_size);
      
pdphase_SR = MPAWCOOutputV2(WPCO,periods,lpf_SR,upf_SR);
pdphase_LR = MPAWCOOutputV2(WPCO,periods,lpf_LR,upf_LR);
 
%% Plots
figure(8)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
 
% Plot wavelet coherency
% Uses function plotWAVE (new function in Functions\Auxiliary)
 
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (WTI, WIND)';
    plotWAVE(WCO,ttime,period,coi,1,[],[],xlim,xticks,[],yticks,tit,pictEnh);   
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
      
% Plot phase-difference (SR)  
% Uses function plotPHASE (new function in Functions\Auxiliary)
subplot(4,7,[15 17])
    tit='(a .2)  62 - 128 days frequency band';
    plotPHASE(dphase_SR,ttime,tit,1,xlim,xticks); 
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
   
    
%  Plot phase-difference (LR)
subplot(4,7,[22 24])
    tit = '(a .3)  180 - 520 days frequency band';
    plotPHASE(dphase_LR,ttime,tit,1,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
% Plot partial wavelet coherency   
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (WTI,WIND|VIX)';
    plotWAVE(WPCO,ttime,period,coi,2,[],[],xlim,xticks,[],yticks,tit,pictEnh);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
    
% Plot partial phase-difference (SR)      
subplot(4,7,[19 21])
    tit = '(b .2) 62 - 128 days frequency band';
    plotPHASE(pdphase_SR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
    
% Plot partial phase-difference (LR)    
subplot(4,7,[26 28])
    tit = '(b .3) 180 - 520 days frequency band';
    plotPHASE(pdphase_LR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
 
 %%%%%%%%%%%%%% WIND \.16 WTI |EPU
 
 
ttime=datare.trend; % Vector of times
 
 
X = datare.return_wind; % wind 
Y = datare.return_wti; % WTI
Z = datare.return_epu; % EPU
% W = datare.return_epu; % EPU
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/25;
lowerPeriod = 2/60;
upperPeriod = 1000/60;
% NOTE: Other parameters take default values
 
 
%%%%%%%%%%%%    Choice of smoothing parameters for Coherency   %%%%%%%%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size= 2;
% NOTE: This choice of windows require the use of the Signal Processing Toolbox
% If you do not have this toolbox, use
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
nSurCO=5000;    % This is the number of Monte Carlo simulations            
                % used to assess statistical significance    
                % With this number, it takes long!
 
 
%%%%%   Frequency (period) band selections (for phase-differences)   %%%%%
% Lower and upper  periods (short regime)
lpf_SR=3;
upf_SR=4;
 
% Lower and upper  periods (long regime)
lpf_LR=4;
upf_LR=9;
 
%%%%%%% Computation of Coherency and Phase-Differences of X,Y    %%%%%%%%%
[WCO,d1,d2,period] = ...
    AWCO(Y,X,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
    wT_type,wT_size,wS_type,wS_size); % #ok<*ASGLU>
 
[d1,d2,d3,dphase_SR] = AWCOOutputV2(WCO,WCO,period,lpf_SR,upf_SR);
[d1,d2,d3,dphase_LR] = AWCOOutputV2(WCO,WCO,period,lpf_LR,upf_LR);
% Computation of Partial Coherency and Partial Phase-Differences of X,Y    %
coher_type='part'; % Compute partial coherency only
indexP=2;
[d1,WPCO,periods,coi] =...
          MPAWCO([Y X Z],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
          coher_type,indexP,wT_type,wT_size,wS_type,wS_size);
      
pdphase_SR = MPAWCOOutputV2(WPCO,periods,lpf_SR,upf_SR);
pdphase_LR = MPAWCOOutputV2(WPCO,periods,lpf_LR,upf_LR);
 
%% Plots
figure(9)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
 
% Plot wavelet coherency
% Uses function plotWAVE (new function in Functions\Auxiliary)
 
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (WTI, SUN)';
    plotWAVE(WCO,ttime,period,coi,1,[],[],xlim,xticks,[],yticks,tit,pictEnh);   
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
      
% Plot phase-difference (SR)  
% Uses function plotPHASE (new function in Functions\Auxiliary)
subplot(4,7,[15 17])
    tit='(a .2)  128 - 250 days frequency band';
    plotPHASE(dphase_SR,ttime,tit,1,xlim,xticks); 
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
   
    
%  Plot phase-difference (LR)
subplot(4,7,[22 24])
    tit = '(a .3)  250 - 520 days frequency band';
    plotPHASE(dphase_LR,ttime,tit,1,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
% Plot partial wavelet coherency   
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (WTI,SUN;EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,[],[],xlim,xticks,[],yticks,tit,pictEnh);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
    
% Plot partial phase-difference (SR)      
subplot(4,7,[19 21])
    tit = '(b .2) 128 - 250 days frequency band';
    plotPHASE(pdphase_SR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
    
% Plot partial phase-difference (LR)    
subplot(4,7,[26 28])
    tit = '(b .3) 250 - 520 days frequency band';
    plotPHASE(pdphase_LR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
 %%%%%%%%%%%%%% BIO \.16 WTI |VIX
 
 
 
 
ttime=datare.trend; % Vector of times
 
 
X = datare.return_bio; % wind 
Y = datare.return_wti; % WTI
Z = datare.return_vix; % VIX
% W = datare.return_epu; % EPU
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/25;
lowerPeriod = 2/60;
upperPeriod = 1000/60;
% NOTE: Other parameters take default values
 
 
%%%%%%%%%%%%    Choice of smoothing parameters for Coherency   %%%%%%%%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size= 2;
% NOTE: This choice of windows require the use of the Signal Processing Toolbox
% If you do not have this toolbox, use
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
nSurCO=5000;    % This is the number of Monte Carlo simulations            
                % used to assess statistical significance    
                % With this number, it takes long!
 
 
%%%%%   Frequency (period) band selections (for phase-differences)   %%%%%
% Lower and upper  periods (short regime)
lpf_SR=3;
upf_SR=4;
 
% Lower and upper  periods (long regime)
lpf_LR=4;
upf_LR=9;
 
%%%%%%% Computation of Coherency and Phase-Differences of X,Y    %%%%%%%%%
[WCO,d1,d2,period] = ...
    AWCO(Y,X,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
    wT_type,wT_size,wS_type,wS_size); % #ok<*ASGLU>
 
[d1,d2,d3,dphase_SR] = AWCOOutputV2(WCO,WCO,period,lpf_SR,upf_SR);
[d1,d2,d3,dphase_LR] = AWCOOutputV2(WCO,WCO,period,lpf_LR,upf_LR);
% Computation of Partial Coherency and Partial Phase-Differences of X,Y    %
coher_type='part'; % Compute partial coherency only
indexP=2;
[d1,WPCO,periods,coi] =...
          MPAWCO([Y X Z],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
          coher_type,indexP,wT_type,wT_size,wS_type,wS_size);
      
pdphase_SR = MPAWCOOutputV2(WPCO,periods,lpf_SR,upf_SR);
pdphase_LR = MPAWCOOutputV2(WPCO,periods,lpf_LR,upf_LR);
 
%% Plots
figure(10)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
 
% Plot wavelet coherency
% Uses function plotWAVE (new function in Functions\Auxiliary)
 
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (WTI, WIND)';
    plotWAVE(WCO,ttime,period,coi,1,[],[],xlim,xticks,[],yticks,tit,pictEnh);   
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
      
% Plot phase-difference (SR)  
% Uses function plotPHASE (new function in Functions\Auxiliary)
subplot(4,7,[15 17])
    tit='(a .2)  128 - 250 days frequency band';
    plotPHASE(dphase_SR,ttime,tit,1,xlim,xticks); 
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
   
    
%  Plot phase-difference (LR)
subplot(4,7,[22 24])
    tit = '(a .3)  250 - 520 days frequency band';
    plotPHASE(dphase_LR,ttime,tit,1,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
% Plot partial wavelet coherency   
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (WTI,WIND|EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,[],[],xlim,xticks,[],yticks,tit,pictEnh);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
    
% Plot partial phase-difference (SR)      
subplot(4,7,[19 21])
    tit = '(b .2) 128 - 250 days frequency band';
    plotPHASE(pdphase_SR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
    
% Plot partial phase-difference (LR)    
subplot(4,7,[26 28])
    tit = '(b .3) 250 - 520 days frequency band';
    plotPHASE(pdphase_LR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
%%%%%%%%%%%%%% geo \.16 WTI |VIX
 
 
 
 
ttime=datare.trend; % Vector of times
 
 
X = datare.return_geo; % geo 
Y = datare.return_wti; % WTI
Z = datare.return_vix; % VIX
% W = datare.return_epu; % EPU
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/25;
lowerPeriod = 2/60;
upperPeriod = 1000/60;
% NOTE: Other parameters take default values
 
 
%%%%%%%%%%%%    Choice of smoothing parameters for Coherency   %%%%%%%%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size= 2;
% NOTE: This choice of windows require the use of the Signal Processing Toolbox
% If you do not have this toolbox, use
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
nSurCO=5000;    % This is the number of Monte Carlo simulations            
                % used to assess statistical significance    
                % With this number, it takes long!
 
 
%%%%%   Frequency (period) band selections (for phase-differences)   %%%%%
% Lower and upper  periods (short regime)
lpf_SR=3;
upf_SR=4;
 
% Lower and upper  periods (long regime)
lpf_LR=4;
upf_LR=9;
 
%%%%%%% Computation of Coherency and Phase-Differences of X,Y    %%%%%%%%%
[WCO,d1,d2,period] = ...
    AWCO(Y,X,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
    wT_type,wT_size,wS_type,wS_size); % #ok<*ASGLU>
 
[d1,d2,d3,dphase_SR] = AWCOOutputV2(WCO,WCO,period,lpf_SR,upf_SR);
[d1,d2,d3,dphase_LR] = AWCOOutputV2(WCO,WCO,period,lpf_LR,upf_LR);
% Computation of Partial Coherency and Partial Phase-Differences of X,Y    %
coher_type='part'; % Compute partial coherency only
indexP=2;
[d1,WPCO,periods,coi] =...
          MPAWCO([Y X Z],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
          coher_type,indexP,wT_type,wT_size,wS_type,wS_size);
      
pdphase_SR = MPAWCOOutputV2(WPCO,periods,lpf_SR,upf_SR);
pdphase_LR = MPAWCOOutputV2(WPCO,periods,lpf_LR,upf_LR);
 
%% Plots
figure(11)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
 
% Plot wavelet coherency
% Uses function plotWAVE (new function in Functions\Auxiliary)
 
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (WTI, GEO)';
    plotWAVE(WCO,ttime,period,coi,1,[],[],xlim,xticks,[],yticks,tit,pictEnh);   
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
      
% Plot phase-difference (SR)  
% Uses function plotPHASE (new function in Functions\Auxiliary)
subplot(4,7,[15 17])
    tit='(a .2)  128 - 250 days frequency band';
    plotPHASE(dphase_SR,ttime,tit,1,xlim,xticks); 
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
   
    
%  Plot phase-difference (LR)
subplot(4,7,[22 24])
    tit = '(a .3)  250 - 520 days frequency band';
    plotPHASE(dphase_LR,ttime,tit,1,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
% Plot partial wavelet coherency   
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (WTI,GEO|VIX)';
    plotWAVE(WPCO,ttime,period,coi,2,[],[],xlim,xticks,[],yticks,tit,pictEnh);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
    
% Plot partial phase-difference (SR)      
subplot(4,7,[19 21])
    tit = '(b .2) 128 - 250 days frequency band';
    plotPHASE(pdphase_SR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
    
% Plot partial phase-difference (LR)    
subplot(4,7,[26 28])
    tit = '(b .3) 250 - 520 days frequency band';
    plotPHASE(pdphase_LR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
%%%%%%%%%%%%%% GEO \.16 WTI |EPU
 
 
 
 
ttime=datare.trend; % Vector of times
 
 
X = datare.return_geo; % geo 
Y = datare.return_wti; % WTI
Z = datare.return_epu; % EPU
% W = datare.return_epu; % EPU
 
 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/25;
lowerPeriod = 2/60;
upperPeriod = 1000/60;
% NOTE: Other parameters take default values
 
 
%%%%%%%%%%%%    Choice of smoothing parameters for Coherency   %%%%%%%%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size= 2;
% NOTE: This choice of windows require the use of the Signal Processing Toolbox
% If you do not have this toolbox, use
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
nSurCO=5000;    % This is the number of Monte Carlo simulations            
                % used to assess statistical significance    
                % With this number, it takes long!
 
 
%%%%%   Frequency (period) band selections (for phase-differences)   %%%%%
% Lower and upper  periods (short regime)
lpf_SR=3;
upf_SR=4;
 
% Lower and upper  periods (long regime)
lpf_LR=4;
upf_LR=9;
 
%%%%%%% Computation of Coherency and Phase-Differences of X,Y    %%%%%%%%%
[WCO,d1,d2,period] = ...
    AWCO(Y,X,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
    wT_type,wT_size,wS_type,wS_size); % #ok<*ASGLU>
 
[d1,d2,d3,dphase_SR] = AWCOOutputV2(WCO,WCO,period,lpf_SR,upf_SR);
[d1,d2,d3,dphase_LR] = AWCOOutputV2(WCO,WCO,period,lpf_LR,upf_LR);
% Computation of Partial Coherency and Partial Phase-Differences of X,Y    %
coher_type='part'; % Compute partial coherency only
indexP=2;
[d1,WPCO,periods,coi] =...
          MPAWCO([Y X Z],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
          coher_type,indexP,wT_type,wT_size,wS_type,wS_size);
      
pdphase_SR = MPAWCOOutputV2(WPCO,periods,lpf_SR,upf_SR);
pdphase_LR = MPAWCOOutputV2(WPCO,periods,lpf_LR,upf_LR);
 
%% Plots
figure(12)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 
 
% Plot wavelet coherency
% Uses function plotWAVE (new function in Functions\Auxiliary)
 
subplot(4,7,[1 10])
    tit = '(a .1)  Wavelet Coherency (WTI, GEO)';
    plotWAVE(WCO,ttime,period,coi,1,[],[],xlim,xticks,[],yticks,tit,pictEnh);   
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
      
% Plot phase-difference (SR)  
% Uses function plotPHASE (new function in Functions\Auxiliary)
subplot(4,7,[15 17])
    tit='(a .2)  128 - 250 days frequency band';
    plotPHASE(dphase_SR,ttime,tit,1,xlim,xticks); 
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
   
    
%  Plot phase-difference (LR)
subplot(4,7,[22 24])
    tit = '(a .3)  250 - 520 days frequency band';
    plotPHASE(dphase_LR,ttime,tit,1,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
 
% Plot partial wavelet coherency   
subplot(4,7,[5 14])
    tit = '(b .1)  Wavelet Partial Coherency (WTI,GEO|EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,[],[],xlim,xticks,[],yticks,tit,pictEnh);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
    
% Plot partial phase-difference (SR)      
subplot(4,7,[19 21])
    tit = '(b .2) 128 - 250 days frequency band';
    plotPHASE(pdphase_SR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 
 
    
% Plot partial phase-difference (LR)    
subplot(4,7,[26 28])
    tit = '(b .3) 250 - 520 days frequency band';
    plotPHASE(pdphase_LR,ttime,tit,2,xlim,xticks);
xticklabels({'2010','03/2013','07/2015','11/2017','03/2020'}); 





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% robustesse 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  SUN   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ttime=datare.trend; % Vector of times


X = datare.return_solar;  
Y = datare.return_wti;
Z= datare.return_vix;
W = datare.return_epu;
V = datare.re_em;
 

%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/30;
lowerPeriod=2/60; 
upperPeriod=1000/60;
% NOTE: Other parameters take default values

%%%%%   Choice of smoothing parameters for coherency computations    %%%%%%
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
% NOTE: This choice of windows makes use of the Signal Processing Toolbox
% If you do not have this toolbox, choose
% wT_type='Bar';
% wT_size=2;
% wS_type='Bar';
% wS_size=2;


%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
% This is the number of Monte Carlo simulations used to assess
% significance 
%  NOTE: Takes long!
nSur=500;           
 sur_type='ARMABoot'
 p=1;
 q=0;
 % Surrogates are based on an ARMA(1,1) model and drawing errors from a
 % Gaussian distribution
 % Makes use of Econometrics Toolbox
 % NOTE: If you do not have the Econometrics Toolbox, you have to choose
 % sur_type='ARMABoot'
 % p=1;
 % q=0;
%%%%%%%%%%%%%%%%%  Wavelet Coherency SP/Oil Computation     %%%%%%%%%%%%%%%
[WCO,d1,d2,period,d3,d4,pvCO] = ...
	AWCO(X,Y,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
	     wT_type,wT_size,wS_type,wS_size, nSur,sur_type,p,q); % #ok<*ASGLU>


 
%%%%%%%%%%%%%%%%%%%  Phase Difference Sun/Oil Computation    %%%%%%%%%%%%%%%
%%%  Frequency (period) band selection     
lowPF1=3;
upPF1=9;
 
% Lower and upper  periods (long regime) 
% lowPF2=4.3;
% upPF2=8.6;
 
%%% Phase-Difference Computation for selected band
[d1,d2,d3,dphaseXY] = AWCOOutput(WCO, WCO,period,lowPF1,upPF1);
 
 
 
% Phase-difference is computed from coherency, i.e. form Eq. (27) in 
% NIPE WP 16/2011
 
%%%%%%%%%%%   Partial Wavelet Coherency Sun/Oil Computation      %%%%%%%%%%%
coher_type='part'; % Compute partial wavelet coherency only
indexP=2;
 
[WMCO,WPCO,periods,coi,pvM,pvP] =...
  MPAWCO([X Y Z W V],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],coher_type,...
         indexP,wT_type,wT_size,wS_type,wS_size,nSur,sur_type,p,q);
      
%%%%%%%%%%%%%  Partial Phase Difference Sun /Oil Computation     %%%%%%%%%%%%
pdphaseXY = MPAWCOOutput(WPCO,periods,lowPF1,upPF1);
 
 
 
%% Plots
 
figure(12)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

    
%%%%%%%%%%%%%%%%%%%%%   Plot partial coherency SUN/WTI  %%%%%%%%%%%%%%%%%%%%
subplot(2,1,1)
    tit = '  Wavelet Partial Coherency (SUN, WTI | VIX, EMV-ID, EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,...
                pvP,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference SUN/WTI %%%%%%%%%%%%%%%%%% 
subplot(2,1,2)
    tit=' 128 - 520 Days frequency band';
    plotPHASE(pdphaseXY,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WIND %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ttime=datare.trend; % Vector of times


X = datare.return_wind;  
Y = datare.return_wti;
Z= datare.return_vix;
W = datare.return_epu;
V = datare.re_em;



%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/30;
lowerPeriod=2/60; 
upperPeriod=1000/60;
% NOTE: Other parameters take default values

%%%%%   Choice of smoothing parameters for coherency computations    %%%%%%
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
% NOTE: This choice of windows makes use of the Signal Processing Toolbox
% If you do not have this toolbox, choose
% wT_type='Bar';
% wT_size=2;
% wS_type='Bar';
% wS_size=2;


%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
% This is the number of Monte Carlo simulations used to assess
% significance 
%  NOTE: Takes long!
nSur=5000;           
 sur_type='ARMABoot'
 p=1;
 q=0;
 % Surrogates are based on an ARMA(1,1) model and drawing errors from a
 % Gaussian distribution
 % Makes use of Econometrics Toolbox
 % NOTE: If you do not have the Econometrics Toolbox, you have to choose
 % sur_type='ARMABoot'
 % p=1;
 % q=0;
%%%%%%%%%%%%%%%%%  Wavelet Coherency SP/Oil Computation     %%%%%%%%%%%%%%%
[WCO,d1,d2,period,d3,d4,pvCO] = ...
	AWCO(X,Y,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
	     wT_type,wT_size,wS_type,wS_size, nSur,sur_type,p,q); % #ok<*ASGLU>


%%%%%%%%%%%%%%%%%%%  Phase Difference WIND/Oil Computation    %%%%%%%%%%%%%%%
%%%  Frequency (period) band selection  sans   
lowPF1=2.1;
upPF1=4.3;
 
%%%  Frequency (period) band selection sans    

 
% Lower and upper  periods avec
lowPF3=4.3;
upPF3=8.6;
 
 
%%% Phase-Difference Computation for selected band
[d1,d2,d3,dphaseXY1] = AWCOOutput(WCO,WCO,period,lowPF1,upPF1);
[d1,d2,d3,dphaseXY2] = AWCOOutput(WCO,WCO,period,lowPF2,upPF2);

% Phase-difference is computed from coherency, i.e. form Eq. (27) in 
% NIPE WP 16/2011

%%%%%%%%%%%   Partial Wavelet Coherency SP/Oil Computation      %%%%%%%%%%%
coher_type='part'; % Compute partial wavelet coherency only
indexP=2;

[WMCO,WPCO,periods,coi,pvM,pvP] =...
  MPAWCO([X Y Z W V],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],coher_type,...
         indexP,wT_type,wT_size,wS_type,wS_size,nSur,sur_type,p,q);
      
%%%%%%%%%%%%%  Partial Phase Difference SP/Oil Computation     %%%%%%%%%%%%

pdphaseXY1 = MPAWCOOutput(WPCO,periods,lowPF1,upPF1);
pdphaseXY3 = MPAWCOOutput(WPCO,periods,lowPF3,upPF3);
 
 
%% Plots
 
figure(13)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 


%%%%%%%%%%%%%%%%%%%%%   Plot partial coherency WIND/WTI  %%%%%%%%%%%%%%%%%%%%
subplot(3,1,1)
    tit = '(b .1)  Wavelet Partial Coherency (WIND, WTI | EMV-ID, EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,...
                pvP,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 

 %%%%%%%%%%%%%%%%%% Plot partial phase-difference WIND/WTI %%%%%%%%%%%%%%%%%% 
subplot(3,1,2)
    tit='(b .2)  128 - 260 days frequency band';
    plotPHASE(pdphaseXY1,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference WIND/WTI %%%%%%%%%%%%%%%%%% 
subplot(3,1,3)
    tit='(b .2)  260 - 520 days frequency band';
    plotPHASE(pdphaseXY3,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GEO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ttime=datare.trend; % Vector of times


X = datare.return_geo;  
Y = datare.return_wti;
Z= datare.return_vix;
W = datare.return_epu;
V = datare.re_em;


%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
% This is the number of Monte Carlo simulations used to assess
% significance 
%  NOTE: Takes long!
nSur=5000;           
% sur_type = 'ARMAEcon'; 
% p = 1;
% q = 1; 
 % Surrogates are based on an ARMA(1,1) model and drawing errors from a
 % Gaussian distribution
 % Makes use of Econometrics Toolbox
 % NOTE: If you do not have the Econometrics Toolbox, you have to choose
 sur_type='ARMABoot'
 p=1;
 q=0;
%%%%%%%%%%%%%%%%%  Wavelet Coherency GEO/Oil Computation     %%%%%%%%%%%%%%%
[WCO,d1,d2,period,d3,d4,pvCO] = ...
    AWCO(X,Y,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
         wT_type,wT_size,wS_type,wS_size, nSur,sur_type,p,q); % #ok<*ASGLU>
 
%%%%%%%%%%%%%%%%%%%  Phase Difference GEO/Oil Computation    %%%%%%%%%%%%%%%
%%%  Frequency (period) band selection     
lowPF1=2.1;
upPF1=4.3;
 
%%%  Frequency (period) band selection     
lowPF2=8.6;
upPF2=14;
 
 
%%% Phase-Difference Computation for selected band
[d1,d2,d3,dphaseXY] = AWCOOutput(WCO, WCO,period,lowPF1,upPF1);
 [d1,d2,d3,dphaseXY2] = AWCOOutput(WCO, WCO,period,lowPF2,upPF2);
% Phase-difference is computed from coherency, i.e. form Eq. (27) in 
% NIPE WP 16/2011
 
%%%%%%%%%%%   Partial Wavelet Coherency GEO/Oil Computation      %%%%%%%%%%%
coher_type='part'; % Compute partial wavelet coherency only
indexP=2;
 
[WMCO,WPCO,periods,coi,pvM,pvP] =...
  MPAWCO([X Y Z W V],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],coher_type,...
         indexP,wT_type,wT_size,wS_type,wS_size,nSur,sur_type,p,q);
      
%%%%%%%%%%%%%  Partial Phase Difference GEO/Oil Computation     %%%%%%%%%%%%
pdphaseXY = MPAWCOOutput(WPCO,periods,lowPF1,upPF1);
pdphaseXY2 = MPAWCOOutput(WPCO,periods,lowPF2,upPF2);
%% Plots
 
figure(14)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 

%%%%%%%%%%%%%%%%%%%%%   Plot partial coherency GEO/WTI  %%%%%%%%%%%%%%%%%%%%
subplot(3,1,1)
    tit = '(b .1)  Wavelet Partial Coherency (GEO, WTI | VIX, EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,...
                pvP,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference GEO/WTI %%%%%%%%%%%%%%%%%% 
subplot(3,1,2)
    tit='(b .2)  128 - 260 Days frequency band';
    plotPHASE(pdphaseXY,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference GEO/WTI %%%%%%%%%%%%%%%%%% 
subplot(3,1,3)
    tit='(b .3)  520 - 888 Days frequency band';
    plotPHASE(pdphaseXY2,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BIO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ttime=datare.trend; % Vector of times


X = datare.return_bio;  
Y = datare.return_wti;
Z= datare.return_vix;
W = datare.return_epu;
V = datare.re_em;

 
%%%%%%%%%%%%%%%%%      Choice of Wavelet Parameters           %%%%%%%%%%%%%
dt=1/60; 
dj = 1/30;
lowerPeriod=2/60; 
upperPeriod=1000/60;
% NOTE: Other parameters take default values
 
%%%%%   Choice of smoothing parameters for coherency computations    %%%%%%
% wT_type ='Ham';
% wT_size =2;
% wS_type ='Ham';
% wS_size =2;
% NOTE: This choice of windows makes use of the Signal Processing Toolbox
% If you do not have this toolbox, choose
 wT_type='Bar';
 wT_size=2;
 wS_type='Bar';
 wS_size=2;
 
 
%%% Choice of number of Monte Carlo simulations and type of surrogates %%%%
% This is the number of Monte Carlo simulations used to assess
% significance 
%  NOTE: Takes long!
nSur=5000;           
% sur_type = 'ARMAEcon'; 
% p = 1;
% q = 1; 
 % Surrogates are based on an ARMA(1,1) model and drawing errors from a
 % Gaussian distribution
 % Makes use of Econometrics Toolbox
 % NOTE: If you do not have the Econometrics Toolbox, you have to choose
 sur_type='ARMABoot'
 p=1;
 q=0;
%%%%%%%%%%%%%%%%%  Wavelet Coherency BIO/Oil Computation     %%%%%%%%%%%%%%%
[WCO,d1,d2,period,d3,d4,pvCO] = ...
    AWCO(X,Y,dt,dj,lowerPeriod,upperPeriod,[],[],[],[],...
         wT_type,wT_size,wS_type,wS_size, nSur,sur_type,p,q); % #ok<*ASGLU>
 
%%%%%%%%%%%%%%%%%%%  Phase Difference BIO/Oil Computation    %%%%%%%%%%%%%%%
%%%  Frequency (period) band selection     
lowPF1=0.5;
upPF1=2;
%%%  Frequency (period) band selection     
lowPF2=0.5;
upPF2=2;
%%%  Frequency (period) band selection     
lowPF3=2.1;
upPF3=8.6;
 
%%% Phase-Difference Computation for selected band
[d1,d2,d3,dphaseXY1] = AWCOOutput(WCO, WCO,period,lowPF1,upPF1);
[d1,d2,d3,dphaseXY2] = AWCOOutput(WCO, WCO,period,lowPF3,upPF3);
 
% Phase-difference is computed from coherency, i.e. form Eq. (27) in 
% NIPE WP 16/2011
 
%%%%%%%%%%%   Partial Wavelet Coherency BIO/Oil Computation      %%%%%%%%%%%
coher_type='part'; % Compute partial wavelet coherency only
indexP=2;
 

[WMCO,WPCO,periods,coi,pvM,pvP] =...
  MPAWCO([X Y Z W V],dt,dj,lowerPeriod,upperPeriod,[],[],[],[],coher_type,...
         indexP,wT_type,wT_size,wS_type,wS_size,nSur,sur_type,p,q);
      
%%%%%%%%%%%%%  Partial Phase Difference BIO/Oil Computation     %%%%%%%%%%%%
pdphaseXY2 = MPAWCOOutput(WPCO,periods,lowPF2,upPF2);
pdphaseXY3 = MPAWCOOutput(WPCO,periods,lowPF3,upPF3);
 
%% Plots
 
figure(15)
 
% Things common to all pictures
xlim=[ttime(1) ttime(end)];
xticks = [0 600 1200 1800 2400]; 
yticks = [0.03 0.06 0.15 0.5 1 2 4.3 8.6 14.8];
perc5 = 5/100;  % Percentil 5
perc10= 10/100; % Percentil 10
perc = [perc5 perc10];
pictEnh = 7.5;  % Picture enhancer
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
 

    
%%%%%%%%%%%%%%%%%%%%%   Plot partial coherency BIO/WTI  %%%%%%%%%%%%%%%%%%%%
subplot(3,1,1)
    tit = '(b .1)  Wavelet Partial Coherency (BIO, WTI | VIX, EPU)';
    plotWAVE(WPCO,ttime,period,coi,2,...
                pvP,perc,[],xticks,[],yticks,tit,pictEnh);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 yticklabels({'2','4','8','32','62','128', '260', '520', '888'}); 
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference BIO/WTI %%%%%%%%%%%%%%%%%% 
subplot(3,1,2)
    tit='(b .2)  32 - 128 Days frequency band';
    plotPHASE(pdphaseXY2,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
%%%%%%%%%%%%%%%%%% Plot partial phase-difference BIO/WTI %%%%%%%%%%%%%%%%%% 
subplot(3,1,3)
    tit='(b .3)  128 - 512 Days frequency band';
    plotPHASE(pdphaseXY3,ttime,tit,2,xlim,xticks);
    set(gca,'XTickLabel',{'2010','03/2013','07/2015','11/2017','03/2020'});
 
 
