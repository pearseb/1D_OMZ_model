% Script to plot profiles from Ji et al., 2015
% Nitrous oxide production by nitrification and denitrification
% in the Eastern Tropical South Pacific oxygen minimum zone

close all ; clear all
% Specify file
fname = ['../Data/Ji2015_rates.mat'];

% Load it
load(fname,'ETSP')

% Process?

% Raw plots
vars = {'nh4ton2o','no2ton2o','no3ton2o'};


