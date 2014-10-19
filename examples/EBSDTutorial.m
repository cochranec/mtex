%% Short EBSD Analysis Tutorial 
% How to detect grains in EBSD data and estimate an ODF.
%
%% Open in Editor
%  

%% Import EBSD data
% The following script is automatically generated by the import wizard.

% crystal symmetry
CS = {...
  'Not Indexed',...
  crystalSymmetry('m-3m','mineral','Fe'),...
  crystalSymmetry('m-3m','mineral','Mg')};

% specify file name
fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');


% create an EBSD variable containing the data
ebsd = loadEBSD(fname,'CS',CS,'interface','generic' ...
  , 'ColumnNames', ...
  { 'Index' 'Phase' 'x' 'y' 'Euler1' 'Euler2' 'Euler3' 'MAD' 'BC' 'BS' 'Bands' 'Error' 'ReliabilityIndex'}, ...
  'ignorePhase', 0);

% plotting convention
plotx2east

%% Visualize the data
% First we make a spatial plot of the orientations of the crystals of phase
% 1

plot(ebsd('Fe'))

%%
% The colorcoding can be interpreted by the collored (0,0,1) inverse pole
% figure

oM = ipdfHSVOrientationMapping(ebsd('Fe'))
plot(oM)

%%

%% Grain reconstruction
% Next we reconstruct the grains within our measurements.
%

grains = calcGrains(ebsd)

%%
% and plot them into our orientation plot

plot(ebsd('Fe'))
hold on
plot(grains.boundary,'linewidth',1.5)

%%
% One can also plot all the grains together with their mean orientation

plot(grains('Fe'))

%% ODF estimation
% Next we reconstruct an ODF from the EBSD data. Therefore, we first have
% to fix a kenel function. This can be done by

psi = calcKernel(grains('Fe').meanOrientation)

%%
% Now the ODF is reconstructed by
odf = calcODF(ebsd('Fe').orientations,'kernel',psi)

%%
% Once an ODF is estimated all the functionallity MTEX offers for 
% <ODFCalculations.html ODF analysis> and <ODFPlot.html ODF visualisation>
% is available.

plotPDF(odf,[Miller(1,0,0,CS{2}),Miller(1,1,0,CS{2}),Miller(1,1,1,CS{2})],...
  'antipodal','silent')


