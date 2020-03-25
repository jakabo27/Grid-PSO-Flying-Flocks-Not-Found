function JT_GUI(logTable)
close;  %use this if you want to close the figure and redraw it
gui = createInterface();

% Now update the GUI with the current data
updateInterface(logTable);
drawnow;


% redrawDemo();

    function gui = createInterface(  )
        % Create the user interface for the application and return a
        % structure of handles for global use.
        gui = struct();
        % Open a window
        gui.Window = figure( 'Name', 'GUI Testing', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'NumberTitle', 'off' , 'Position', [100 100 1200 800]);
        
        mainLayout = uix.HBoxFlex('Parent', gui.Window, 'Spacing', 3);
        
        %Vertical sections
        leftPlots   = uix.VBoxFlex('Parent', mainLayout, 'Spacing', 3);
        rightPlots = uix.VBoxFlex('Parent', mainLayout, 'Spacing', 3);
        tableSection   = uix.VBoxFlex('Parent', mainLayout, 'Spacing', 3);
        set ( mainLayout, 'Widths', [-2,-2,250]);  %Set the size of each vertical section
        
        % Left Plots
        gui.axes1 = axes( 'Parent', uicontainer('Parent', leftPlots) );
        gui.axes2 = axes( 'Parent', uicontainer('Parent', leftPlots) );
        
        % Right Plots
        gui.axes3 = axes( 'Parent', uicontainer('Parent', rightPlots) );
        gui.axes4 = axes( 'Parent', uicontainer('Parent', rightPlots) );
        
        %Table Area
        gui.tableArea = uix.VBoxFlex('Parent', tableSection);
        buttonsArea = uix.VBox('Parent',tableSection);
        set(tableSection, 'Heights', [-1,80]);
        buttonsRow1 = uix.HBox('Parent',buttonsArea);
        buttonsRow2 = uix.HBox('Parent',buttonsArea);
        
        
        
        uicontrol('Parent', buttonsRow1, 'String', 'Button 1');
        uicontrol('Parent', buttonsRow1, 'String', 'Button 2');
        uicontrol('Parent', buttonsRow2, 'String', 'Button 3');
        uicontrol('Parent', buttonsRow2, 'String', 'Button 4');
    end % createInterface
%-------------------------------------------------------------------------%
    function updateInterface(logTable)
        %Fake temporary table data
        ZoneNames = { 'GN1'; 	'GN2'; 	'GNE'; 	'GNW'; 	'GS1'; 	'GS2'; 	'OFFICE'; 	'GSW'; 	'MN1'; 	'MN2'; 	'MNE'; 	'MNW'; 	'MS1'; 	'MS2'; 	'MSE'; 	'MSW'; 	'TN1'; 	'TN2'; 	'TNE'; 	'TNW'; 	'TS1'; 	'TS2'; 	'TSE'; 	'TSW'; 	'G Corridor'; 	'M Corridor'; 	'T Corridor'; };
        Temperature = num2cell(((24-20).*rand(27,1) + 20));
        HVACStatus = {'ON'; 	'ON'; 	'OFF'; 	'ON'; 	'OFF'; 	'OFF'; 	'ON'; 	'OFF'; 	'ON'; 	'ON'; 	'ON'; 	'OFF'; 	'OFF'; 	'ON'; 	'ON'; 	'OFF'; 	'OFF'; 	'ON'; 	'ON'; 	'OFF'; 	'ON'; 	'OFF'; 	'OFF'; 	'OFF'; 	'ON'; 	'ON'; 	'ON'; };
        
        T = table(ZoneNames, Temperature, HVACStatus);
        statusTable = uitable(gui.tableArea, 'Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
            'RowName',[],'Units', 'Normalized', 'Position',[0, 0, 1, 1], ...
            'ColumnWidth',{75,75,75}, 'ColumnFormat',{[],'bank',[]}, ...
            'FontSize',11);
        
        %The plot we care about
        plot(gui.axes3, seconds(logTable.Time), logTable.EP_G_N1_Apartment_ZN_Coil__Cooling_Coil_Electric_Power, ...
            seconds(logTable.Time), logTable.EP_G_S1_Apartment_ZN_Coil__Cooling_Coil_Electric_Power, ...
            seconds(logTable.Time), logTable.EP_M_NW_Apartment_ZN_Coil__Cooling_Coil_Electric_Power, ...
            seconds(logTable.Time), logTable.EP_M_SE_Apartment_ZN_Coil__Cooling_Coil_Electric_Power, ...
            seconds(logTable.Time), logTable.EP_T_S1_Apartment_ZN_Coil__Cooling_Coil_Electric_Power, ...
            seconds(logTable.Time), logTable.EP_T_N1_Apartment_ZN_Coil__Cooling_Coil_Electric_Power, ...
            seconds(logTable.Time), logTable.EP_T_SW_Apartment_ZN__Zone_Outdoor_Air_Drybulb_Temperature*9,':'); 
        xtickformat(gui.axes3, 'hh:mm:ss');
        title(gui.axes3, "Cooling Coil Power Draw", 'Interpreter','none');
        xlabel(gui.axes3, 'Time [hh:mm:ss]');
        ylabel(gui.axes3, 'Cooling Coil Power [W]');
        ylim(gui.axes3, [0,1100]);
        
        
        % Fill the other plots with random stuff
        surf( gui.axes1, membrane( 1, 15 ) );
        colorbar( gui.axes1 );
        theta = 0:360;
        plot( gui.axes2, theta, sind(theta), theta, cosd(theta) );
        legend( gui.axes2, 'sin', 'cos', 'Location', 'NorthWestOutside' );
        theta = 0:666;
        plot( gui.axes4, theta, sind(theta), theta, cosd(theta) );
        
    end


end %EOF
