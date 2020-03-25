%% Useful links
% https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox


%% Generate my data please
clc;  % Clear system variables
clear vars % Clear output 
ep = mlep;  % Instantiate co-simulation tool

% Building simulation config file
ep.idfFile = 'C:\Users\Jacob\Google Drive\Documents\SCHOOL\Smart Grid 6160\Smart Grid Project Group\MATLAB Directory\Project B files from TA\Building_model1min9.idf';
ep.epwFile = 'C:\Users\Jacob\Google Drive\Documents\SCHOOL\Smart Grid 6160\Smart Grid Project Group\MATLAB Directory\Project B files from TA\USA_SC_Anderson.County.AP.723125_TMY3_1.epw';
% ep.idfFile = 'D:\Google Drive\Documents\SCHOOL\Smart Grid 6160\Smart Grid Project Group\MATLAB Directory\Project B files from TA\Building_model1min9.idf';
% ep.epwFile = 'D:\Google Drive\Documents\SCHOOL\Smart Grid 6160\Smart Grid Project Group\MATLAB Directory\Project B files from TA\USA_SC_Anderson.County.AP.723125_TMY3_1.epw';


% Initialize the co-simulation. This will load the IDF file.
ep.initialize; 

% Display inputs/outputs defined in the IDF file. 
disp('Input/output configuration.');
inputTable = ep.inputTable  %Note - ExternalInterface:Schedule in EnergyPlus IDF Editor
outputTable = ep.outputTable  %Note - OutputVariable (in Output Reporting) in IDF Editor

%Print useful info
disp("EnergyPlus Version:  " + ep.versionEnergyPlus);
disp("EnergyPlus Protocol:  " + ep.versionProtocol);
disp("Outputting to:  " + ep.outputDirFullPath);
disp("Number of inputs:   " + ep.nIn);
disp("Number of outputs:  " + ep.nOut);
idfData = ep.idfData  %All the data it got from the IDF I think
idfDataSchedule = ep.idfData.schedule';  %The inputTable but with unit and value
idfDataScheduleTable = cell2table(vertcat(idfDataSchedule{:}), 'VariableNames',{'Name' 'Description' 'InitialValue'})
idfDataSchedule = vertcat(idfDataSchedule{:});
% str2double(idfDataSchedule(:,3)) %Convert the last column to numbers 

%Set the timestep to match the simulation timestep
timestep = ep.timestep %[s]

% Specify simulation duration
myDuration = 100; % [hours]
endTime = myDuration*60*60; %[s]

% Logging - Prepare logging variables
logTable = table('Size',[0, 1 + ep.nOut],...
    'VariableTypes',repmat({'double'},1,1 + ep.nOut),...
    'VariableNames',[{'Time'}; ep.outputSigName]);


% Start co-simulation
disp("Starting the simulation, it might take 10-20 seconds so please be patient");
ep.start;

% Run simulation
t = 0;  iLog = 1; numUpdates = 10; updateStep = endTime / numUpdates;  tStart = tic;
while t < endTime
    
    % Specify inputs
    %I think this is where we will use PSO to vary the setpoints for each
    %apartment.  
    u = str2double(idfDataSchedule(:,3))';  %Just give it the default values for now
    
    
    y = ep.step(u);   % Send inputs & get outputs from EnergyPlus
    t = ep.time; %[s]    % Obtain elapsed simulation time 
    
    % Log data
    logTable(iLog, :) = num2cell([t y']);
    iLog = iLog + 1;
    
    %Print updates on how long it's taking every 10% or so
    if (floor(t / updateStep) == (t/updateStep))
        tElapsed = toc(tStart);
        estRemain = (endTime - t) / updateStep * tElapsed;
        curPercent = t/endTime*100;
        fprintf("%0.0f%%\tTime Remaining:\t%0.1fs\n", curPercent, estRemain);
      
        %Show the GUI
        JT_GUI(logTable)
        
        tStart = tic;
    end
    
    
end


% Stop co-simulation and announce it to the world
ep.stop;  disp("\nFINISHED SIMULATING");

% close all;
JT_GUI(logTable)
%% plots
%Our data
%Plot the outdoor temperature with the temp inside the apartments
hold off; figure();
plot(seconds(logTable.Time), logTable.EP_T_SW_Apartment_ZN__Zone_Outdoor_Air_Drybulb_Temperature);  hold on;
plot(seconds(logTable.Time), logTable.EP_T_S1_Apartment_ZN__Zone_Mean_Air_Temperature);
plot(seconds(logTable.Time), logTable.EP_G_S1_Apartment_ZN__Zone_Mean_Air_Temperature);

xtickformat('hh:mm:ss');
title("Temperatures", 'Interpreter','none');
xlabel('Time [hh:mm:ss]');      ylabel('Temperature [C]');  grid on;
legend(logTable.Properties.VariableNames,'Interpreter','none','Location','southoutside');


%Plot of the Cooling coil electric power because that's all that's changing
%right now for me
hold off; figure();
plot(seconds(logTable.Time), logTable.EP_G_N1_Apartment_ZN_Coil__Cooling_Coil_Electric_Power); hold on;
plot(seconds(logTable.Time), logTable.EP_G_S1_Apartment_ZN_Coil__Cooling_Coil_Electric_Power);
plot(seconds(logTable.Time), logTable.EP_M_NW_Apartment_ZN_Coil__Cooling_Coil_Electric_Power);
plot(seconds(logTable.Time), logTable.EP_M_SE_Apartment_ZN_Coil__Cooling_Coil_Electric_Power);
plot(seconds(logTable.Time), logTable.EP_T_S1_Apartment_ZN_Coil__Cooling_Coil_Electric_Power);
plot(seconds(logTable.Time), logTable.EP_T_N1_Apartment_ZN_Coil__Cooling_Coil_Electric_Power);
plot(seconds(logTable.Time), logTable.EP_T_SW_Apartment_ZN__Zone_Outdoor_Air_Drybulb_Temperature*9,':');  % Temperature

xtickformat('hh:mm:ss');
title("Cooling Coil Power Draw", 'Interpreter','none');
xlabel('Time [hh:mm:ss]');
ylabel('Cooling Coil Power [W]');
ylim([0,1100]);
grid on;

% %% GUI
% 
% f = figure( 'Position', 200.*ones(1,4) );
% hold on;
% 
% legend(logTable.Properties.VariableNames(2:end),'Interpreter','none','Location','southoutside');
% vbox = uix.VBox( 'Parent', f );
% axes( 'Parent', vbox );
% hbox = uix.HButtonBox( 'Parent', vbox, 'Padding', 5 );
% uicontrol( 'Parent', hbox, 'String', 'Button 1' );
% uicontrol( 'Parent', hbox, 'String', 'Button 2' );
% set( vbox, 'Heights', [-1 35] )
% 
% %% NMew section maybe
% % Open the window
% % Open a new figure window and remove the toolbar and menus
% Window = figure( 'Name', 'GUI Testing', ...
%     'MenuBar', 'none', ...
%     'Toolbar', 'none', ...
%     'NumberTitle', 'off' );
% 
% mainLayout = uix.HBoxFlex('Parent', Window, 'Spacing', 3);
% 
% %Vertical sections
% leftPlots   = uix.VBoxFlex('Parent', mainLayout, 'Spacing', 3);
% rightPlots = uix.VBoxFlex('Parent', mainLayout, 'Spacing', 3);
% tableSection   = uix.VBoxFlex('Parent', mainLayout, 'Spacing', 3);
% set ( mainLayout, 'Widths', [-2,-2,-1]);  %Set the size of each vertical section
% 
% % Left Plots
% axes1 = axes( 'Parent', uicontainer('Parent', leftPlots) );
% axes2 = axes( 'Parent', uicontainer('Parent', leftPlots) );
% 
% % Right Plots
% axes3 = axes( 'Parent', uicontainer('Parent', rightPlots) );
% axes4 = axes( 'Parent', uicontainer('Parent', rightPlots) );
% 
% %Table Area
% tableArea = uix.VBoxFlex('Parent', tableSection);
% buttonsArea = uix.VBox('Parent',tableSection);  
% set(tableSection, 'Heights', [-1,80]);
% buttonsRow1 = uix.HBox('Parent',buttonsArea);
% buttonsRow2 = uix.HBox('Parent',buttonsArea);
% 
% uicontrol('Parent', buttonsRow1, 'String', 'Button 1');
% uicontrol('Parent', buttonsRow1, 'String', 'Button 2');
% uicontrol('Parent', buttonsRow2, 'String', 'Button 3');
% uicontrol('Parent', buttonsRow2, 'String', 'Button 4');
% 
% 
% % Create the layout
% surf( axes1, membrane( 1, 15 ) );
% colorbar( axes1 );
% 
% theta = 0:360;
% plot( axes2, theta, sind(theta), theta, cosd(theta) );
% legend( axes2, 'sin', 'cos', 'Location', 'NorthWestOutside' );
% theta = 0:666;
% plot( axes3, theta, sind(theta), theta, cosd(theta) );
% 
% %% asdf
% f = figure();
% b = uiextras.VBox( 'Parent', f );
% uicontrol( 'Parent', b, 'Background', 'r' )
% uicontrol( 'Parent', b, 'Background', 'b' )
% uicontrol( 'Parent', b, 'Background', 'g' )
% set( b, 'Sizes', [-1 100 -2], 'Spacing', 5 );
%     %
% f = figure();
% b1 = uiextras.VBox( 'Parent', f );
% b2 = uiextras.HBox( 'Parent', b1, 'Padding', 5, 'Spacing', 5 );
% uicontrol( 'Style', 'frame', 'Parent', b1, 'Background', 'r' )
% uicontrol( 'Parent', b2, 'String', 'Button1' )
% uicontrol( 'Parent', b2, 'String', 'Button2' )
% set( b1, 'Sizes', [30 -1] );
% 
% %% try my function
% JT_GUI(0:360);
% pause(1);
% JT_GUI(0:3600);
% pause(1);
% JT_GUI(0:10000);
% pause(1);
