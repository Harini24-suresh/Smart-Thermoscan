classdef ThermoScanGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure
        TitleLabel
        
        % Login Panel
        LoginPanel
        PatientIDLabel
        PatientIDField
        LoginButton
        
        % Patient Info Panel
        PatientPanel
        NameFieldLabel
        NameField
        AgeFieldLabel
        AgeField
        WeightFieldLabel
        WeightField
        SymptomsLabel
        SymptomsField
        HistoryLabel
        HistoryField
        ConditionsLabel
        ConditionsField
        
        % Scan Panel
        ScanPanel
        UploadScanButton
        ScanFileLabel
        
        % Prediction Panel
        PredictionPanel
        RiskScoreLabel
        RiskScoreValue
        HeatmapAxes
        
        % Options Panel
        OptionsGroup
        ScanOnlyButton
        ScanPlusAppointmentButton
        
        % Specialist Panel
        SpecialistPanel
        SpecialistTable
        
        % Generate Report
        GenerateReportButton
        
        % Patient data table
        patients table
    end

    methods (Access = private)
        
        %% Login Callback
        function LoginButtonPushed(app, event)
            pid = app.PatientIDField.Value;
            idx = find(strcmp(string(app.patients.PatientID), pid));
            
            if isempty(idx)
                uialert(app.UIFigure,'Invalid Patient ID','Error');
            else
                % Display basic details
                app.NameField.Value = app.patients.Name(idx);
                app.AgeField.Value = app.patients.Age(idx);
                app.WeightField.Value = app.patients.Weight(idx);
            end
        end
        
        %% Upload Scan Callback
        function UploadScanButtonPushed(app, event)
            [file, path] = uigetfile({'*.jpg;*.png;*.mat'}, 'Select Scan File');
            if isequal(file,0)
                app.ScanFileLabel.Text = 'No file selected';
            else
                app.ScanFileLabel.Text = fullfile(path, file);
                app.RiskScoreValue.Text = 'Calculating...';
                % TODO: Call ML model to get risk score & heatmap
            end
        end
        
        %% Generate Report Callback
        function GenerateReportButtonPushed(app, event)
            % TODO: Implement PDF report generation
            uialert(app.UIFigure,'Report Generated!','Success');
        end
    end

    methods (Access = public)

        % Constructor: create the app
        function app = ThermoScanGUI

            % ===================== Load Patient CSV =====================
            patients = readtable("C:\Users\Harini\OneDrive\Desktop\Smart Thermoscan\csv\Diagnostics.csv",'VariableNamingRule','preserve'); 
            numPatients = height(patients);

            % Generate dummy names
            firstNames = {'Alice','Bob','Charlie','Diana','Ethan','Fiona','George','Hannah','Irene','Jack'};
            lastNames  = {'Smith','Johnson','Brown','Taylor','Lee','Clark','Walker','Hall','Allen','Young'};
            rng(1);
            firstIdx = randi(length(firstNames), numPatients, 1);
            lastIdx  = randi(length(lastNames), numPatients, 1);
            patients.Name = strcat(firstNames(firstIdx)', " ", lastNames(lastIdx)');
            app.patients = patients;

            % ===================== UIFigure =====================
            app.UIFigure = uifigure('Position',[100 100 900 700],'Name','ThermoScan AI');

            % Title
            app.TitleLabel = uilabel(app.UIFigure);
            app.TitleLabel.Text = 'ThermoScan AI: Tumor Risk Assessment';
            app.TitleLabel.FontSize = 18;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.Position = [250 650 400 30];

            %% Login Panel
            app.LoginPanel = uipanel(app.UIFigure);
            app.LoginPanel.Title = 'Patient Login';
            app.LoginPanel.Position = [20 620 400 80];

            app.PatientIDLabel = uilabel(app.LoginPanel);
            app.PatientIDLabel.Text = 'Patient ID:';
            app.PatientIDLabel.Position = [10 30 70 20];

            app.PatientIDField = uieditfield(app.LoginPanel,'text');
            app.PatientIDField.Position = [90 30 100 22];

            app.LoginButton = uibutton(app.LoginPanel,'push');
            app.LoginButton.Text = 'Login';
            app.LoginButton.Position = [200 30 100 30];
            app.LoginButton.ButtonPushedFcn = @(src,event) app.LoginButtonPushed(event);

            %% Patient Info Panel
            app.PatientPanel = uipanel(app.UIFigure);
            app.PatientPanel.Title = 'Patient Information';
            app.PatientPanel.Position = [20 450 400 180];

            app.NameFieldLabel = uilabel(app.PatientPanel);
            app.NameFieldLabel.Text = 'Name:';
            app.NameFieldLabel.Position = [10 140 50 20];
            app.NameField = uieditfield(app.PatientPanel,'text');
            app.NameField.Position = [70 140 300 22];

            app.AgeFieldLabel = uilabel(app.PatientPanel);
            app.AgeFieldLabel.Text = 'Age:';
            app.AgeFieldLabel.Position = [10 110 50 20];
            app.AgeField = uieditfield(app.PatientPanel,'numeric');
            app.AgeField.Position = [70 110 50 22];

            app.WeightFieldLabel = uilabel(app.PatientPanel);
            app.WeightFieldLabel.Text = 'Weight:';
            app.WeightFieldLabel.Position = [10 80 50 20];
            app.WeightField = uieditfield(app.PatientPanel,'numeric');
            app.WeightField.Position = [70 80 50 22];

            app.SymptomsLabel = uilabel(app.PatientPanel);
            app.SymptomsLabel.Text = 'Symptoms:';
            app.SymptomsLabel.Position = [10 50 70 20];
            app.SymptomsField = uitextarea(app.PatientPanel);
            app.SymptomsField.Position = [90 30 280 50];

            app.HistoryLabel = uilabel(app.PatientPanel);
            app.HistoryLabel.Text = 'History:';
            app.HistoryLabel.Position = [10 0 70 20];
            app.HistoryField = uitextarea(app.PatientPanel);
            app.HistoryField.Position = [90 -20 280 50];

            app.ConditionsLabel = uilabel(app.PatientPanel);
            app.ConditionsLabel.Text = 'Conditions:';
            app.ConditionsLabel.Position = [10 -50 70 20];
            app.ConditionsField = uitextarea(app.PatientPanel);
            app.ConditionsField.Position = [90 -70 280 50];

            %% Scan Panel
            app.ScanPanel = uipanel(app.UIFigure);
            app.ScanPanel.Title = 'Scan Upload';
            app.ScanPanel.Position = [20 300 400 130];

            app.UploadScanButton = uibutton(app.ScanPanel,'push');
            app.UploadScanButton.Text = 'Upload Scan';
            app.UploadScanButton.Position = [10 60 100 30];
            app.UploadScanButton.ButtonPushedFcn = @(src,event) app.UploadScanButtonPushed(event);

            app.ScanFileLabel = uilabel(app.ScanPanel);
            app.ScanFileLabel.Text = 'No file selected';
            app.ScanFileLabel.Position = [120 60 260 30];

            %% Prediction Panel
            app.PredictionPanel = uipanel(app.UIFigure);
            app.PredictionPanel.Title = 'Prediction';
            app.PredictionPanel.Position = [450 300 420 300];

            app.RiskScoreLabel = uilabel(app.PredictionPanel);
            app.RiskScoreLabel.Text = 'Tumor Risk Score:';
            app.RiskScoreLabel.Position = [10 250 120 30];

            app.RiskScoreValue = uilabel(app.PredictionPanel);
            app.RiskScoreValue.Text = 'N/A';
            app.RiskScoreValue.FontWeight = 'bold';
            app.RiskScoreValue.Position = [140 250 100 30];

            app.HeatmapAxes = uiaxes(app.PredictionPanel);
            title(app.HeatmapAxes,'Heatmap');
            app.HeatmapAxes.Position = [10 10 400 230];

            %% Options Panel
            app.OptionsGroup = uibuttongroup(app.UIFigure);
            app.OptionsGroup.Title = 'Options';
            app.OptionsGroup.Position = [20 200 400 80];

            app.ScanOnlyButton = uiradiobutton(app.OptionsGroup);
            app.ScanOnlyButton.Text = 'Scan Only';
            app.ScanOnlyButton.Position = [10 30 100 20];

            app.ScanPlusAppointmentButton = uiradiobutton(app.OptionsGroup);
            app.ScanPlusAppointmentButton.Text = 'Scan + Appointment';
            app.ScanPlusAppointmentButton.Position = [150 30 150 20];

            %% Specialist Panel
            app.SpecialistPanel = uipanel(app.UIFigure);
            app.SpecialistPanel.Title = 'Assigned Specialist';
            app.SpecialistPanel.Position = [450 620 420 60];

            app.SpecialistTable = uitable(app.SpecialistPanel);
            app.SpecialistTable.Position = [10 10 400 40];
            app.SpecialistTable.ColumnName = {'Doctor Name','Specialty','Time Slot'};

            %% Generate Report Button
            app.GenerateReportButton = uibutton(app.UIFigure,'push');
            app.GenerateReportButton.Text = 'Generate PDF Report';
            app.GenerateReportButton.Position = [650 250 200 30];
            app.GenerateReportButton.ButtonPushedFcn = @(src,event) app.GenerateReportButtonPushed(event);

        end % Constructor
    end % Public methods
end % Classdef
