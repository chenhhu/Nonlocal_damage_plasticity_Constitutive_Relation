% This code is developed to give the analytical solution of the 
% nonlocal continuum damage-plasticity model, see Chen et al., 2024 (Journal). 
% Stress state: Uniaxial compression stree state
% test data-Kupfer, 1969
clear all
close all
clc
%%
% csvread(filename,R1,C1,[R1 C1 R2 C2]) extracted from experimental datas 
y1=csvread('Kupfer1969.csv',0,0,[0,0,26,1])';
xdata=y1(1,:);
ydata=y1(2,:);
%%
syms chi_p E c_f alpha_p c_0 h_p beta kappa kappa_i sigma1 A B D
% local equivalent strain
kappa_fun0=sqrt( 2*chi_p/E*( c_f*alpha_p+(c_f-c_0)/h_p*(exp(-h_p*alpha_p)-1) ) );
kappa_fun1=str2func(['@(chi_p,E,c_f,alpha_p,c_0,h_p)',vectorize(kappa_fun0)]); % Construct function handle from function 
% damage evolution
D_fun0=1-exp(-beta*(kappa-kappa_i));
D_fun1=str2func(['@(beta,kappa,kappa_i)',vectorize(D_fun0)]); % Construct function handle from function 
% The following is the yield function under Uniaxial compression
f_fun0 = sqrt(sigma1^2/3)+A/3*sigma1-B*(1-chi_p*D)*(c_f-(c_f-c_0)*exp(-h_p*alpha_p))==0; 
sigma1_fun0=solve(f_fun0,sigma1); % sigma1 = f(alpha_p)
sigma1_fun1=str2func(['@(A,B,chi_p,D,c_f,c_0,h_p,alpha_p)',vectorize(sigma1_fun0(1))]); % Construct function handle from function "d2sigma1".
%% Initiation of material parameters. 
i=0;
E=31000; %[MPa]
c_0=7.7;
theta=pi/180*40;
A=6*sin(theta)/sqrt(3)/(3+sin(theta));
B=6*cos(theta)/sqrt(3)/(3+sin(theta));
vartheta=pi/180*30;
C=6*sin(vartheta)/sqrt(3)/(3+sin(vartheta));

par=[1.0000   18.3010   44.4205  306.1259  437.3266]; % R^2=0.99 % obtain from the calibration procedure using nonlinear leasr squares fitting
chi_p=par(1);
sigma_c=par(2);                        
kappa_i=sigma_c/E;
c_f=par(3);
h_p=par(4);
beta=par(5);
                                                                         
%% Load by increasing alpha_p
for alpha_p=0.000001:0.0001:0.015
    i=i+1;
    kappa=kappa_fun1(chi_p,E,c_f,alpha_p,c_0,h_p);
    if kappa<kappa_i
        D(i)=0;
    else
        D(i)=D_fun1(beta,kappa,kappa_i);
    end
    ana_sigma1(i)=sigma1_fun1(A,B,chi_p,D(i),c_f,c_0,h_p,alpha_p); % Axial stress
    N=-sqrt(3)/3+C/3; % Axial plastic flow direction
    ana_strain1(i)=alpha_p/B*N+ana_sigma1(i)/E; % Axial strain, see Eq. (33), (37), (24) and (25)
    ana_alpha_p(i)=alpha_p;
end  
%% 
figure(1)
plot(xdata,ydata,'ko',[0,ana_strain1],[0,ana_sigma1],'b-');
%  ylabel
ylabel({'Axial stress $\sigma_1$ [MPa]'},'Interpreter','latex');
%  xlabel
xlabel({'Axial strain $\varepsilon_1$ [\%]'},'Interpreter','latex');
xlim([-0.006 0])
set(gca,'XDir','reverse','YDir','reverse');
%
figure(2)
plot([0,ana_strain1],[0,D]);
xlim([-0.006 0])
set(gca,'XDir','reverse');
%
figure(3)
plot([0,ana_strain1],[0,ana_alpha_p]);
xlim([-0.006 0])
set(gca,'XDir','reverse');



