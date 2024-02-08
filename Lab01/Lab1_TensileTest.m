%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mechanics of Materials - Lab 01 - Data Analysis Script
% Author: Reynaldo Villarreal Zambrano
% Date: February 5, 2024
% Description: This script analyzes experimental data obtained in the 
% Mechanics of Materials laboratory, focusing on stress-strain curves to 
% determine various material properties. It reads material information and 
% experimental data from CSV files, calculates stress and strain, and 
% extracts key material properties such as yield strength, ultimate
% strength, fracture strength, modulus of elasticity, modulus of toughness,
% and modulus of resilience. The script also generates and plots the 
% stress-strain curve using data from a mechanical extensometer and 
% stress-strain curves for optical extensometer data along with an offset 
% curve for yield strength determination. Results and material properties 
% are displayed in the command window.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear workspace and command window
clear;
clc;

% Allow the user to select a CSV file (header)
[file, path] = uigetfile('*.csv', 'Select the CSV file');
if isequal(file, 0)
    disp('User canceled the operation. Script terminated.');
    return;
end

% Construct the full file path
fullFilePath = fullfile(path, file);

% Read the CSV file
headerData = readtable(fullFilePath);

% Extract material information
materialType = headerData{2, 'MaterialType'};
width = headerData{2, 'Width'};
thickness = headerData{2, 'Thickness'};
mechanicalGaugeLength = headerData{2, 'MechanicalExtensometerGaugeLength'};
opticalGaugeLength = headerData{2, 'OpticalExtensometerGaugeLength'};

% Allow the user to select a CSV file (data)
[file, path] = uigetfile('*.csv', 'Select the CSV file');
if isequal(file, 0)
    disp('User canceled the operation. Script terminated.');
    return;
end

% Construct the full file path
fullFilePath = fullfile(path, file);

% Read the CSV file
data = readtable(fullFilePath);

% Extract time, force, and displacement data
time = data{2:end, 'Time'};
force = data{2:end, 'Force'};
displacement = data{2:end, 'Displacement'};
opticalDisplacement = data{2:end, 'OpticalDisplacement'};
mechanicalDisplacement = data{2:end, 'MechanicalDisplacement'};

% Calculate stress and strain
area = width * thickness;
stress = force / area;
strain_optical = opticalDisplacement / opticalGaugeLength;
strain_mechanical = mechanicalDisplacement / mechanicalGaugeLength;

% Calculate material properties

% Finding modulus of elasticity (Young's modulus)
% *Change strain_mechanical <--> strain_optical dependenent on material 
modulusOfElasticity = (stress(250) - stress(45)) / (strain_mechanical(250) - strain_mechanical(45));
elasticityfunc = @(x) (modulusOfElasticity * (x - 0.002));

% Generate a curve representing the offset yield strength
offsetCurve = elasticityfunc(strain_mechanical);

% Find the first instance where strain in real data is greater and stress in real data is greater than offset data
yieldStrengthIndex = find((stress < offsetCurve), 1, 'first');
yieldStrain = strain_mechanical(yieldStrengthIndex);
yieldStrength = stress(yieldStrengthIndex);

% Ultimate strength is the highest engineering stress reached
ultimateStrength = max(stress);

% Fracture strength is the engineering stress at the point of final fracture
fractureStrength = stress(end);

% Modulus of toughness is the area under the entire stress-strain curve
modulusOfToughness = trapz(strain_mechanical, stress);

% Modulus of resilience is the area under the stress-strain curve up to the elastic limit
modulusOfResilience = trapz(strain_mechanical(1:yieldStrengthIndex), stress(1:yieldStrengthIndex));

% % Plot stress-strain curves
% figure;
% plot(strain_optical, stress, '-o');
% title('Stress-Strain Curve (Optical Extensometer)');
% xlabel('Strain');
% ylabel('Stress (lbf/in^2)');
% hold on
% fplot(elasticityfunc, [0.002, yieldStrain], '-r');
% hold off

% figure
plot(strain_mechanical, stress, '-o');
title('Stress-Strain Curve (Mechanical Extensometer)');
xlabel('Strain');
ylabel('Stress (lbf/in^2)');
hold on
fplot(elasticityfunc, [0.002, yieldStrain], '-r');
hold off

% Display results
disp('Material Information:');
disp(['Material Type: ' materialType]);
disp(['Width: ' num2str(width) ' in']);
disp(['Thickness: ' num2str(thickness) ' in']);
disp(['Mechanical Gauge Length: ' num2str(mechanicalGaugeLength) ' in']);
disp(['Optical Gauge Length: ' num2str(opticalGaugeLength) ' in']);

disp('Material Properties:');
disp(['Yield Strength: ' num2str(yieldStrength) ' lbf/in^2']);
disp(['Ultimate Strength: ' num2str(ultimateStrength) ' lbf/in^2']);
disp(['Fracture Strength: ' num2str(fractureStrength) ' lbf/in^2']);
disp(['Modulus of Elasticity: ' num2str(modulusOfElasticity) ' lbf/in^2']);
disp(['Modulus of Toughness: ' num2str(modulusOfToughness) ' lbf*in/in^3']);
disp(['Modulus of Resilience: ' num2str(modulusOfResilience) ' lbf*in/in^3']);
