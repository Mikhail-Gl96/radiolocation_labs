%M число элементов в AР, d м, lambda_data м
% 1 - [21, lambda_data/2, 0.12 ],
% 2 - [19, lambda_data/2, 0.12 ],
% 3 - [21, lambda_data/2, 0.12 ],
% 4 - [19, lambda_data/2, 0.12 ],
% 5- [21, lambda_data/2, 0.12 ],
% 6 - [19, lambda_data/2, 0.032],
% 7 - [21, lambda_data/2, 0.032],
% 8 - [19, lambda_data/2, 0.032],
% 9 - [23, lambda_data/2, 0.032],
% 10 - [27, lambda_data/2, 0.032],
% 11 - [23, 3/4*lambda_data, 0.05 ],
% 12 - [27, 3/4*lambda_data, 0.05 ]
clc; clear all;
N = 4;
lambda_data = [0.12 , 0.12 , 0.12 , 0.12 , 0.12 , 0.032, 0.032, 0.032, 0.032, 0.032, 0.05 , 0.05];
d_data = [lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, 3/4*lambda_data, 3/4*lambda_data];
M_data = [21, 19, 21, 19, 21, 19, 21, 19, 23, 27, 23, 27];
lambda = d_data(N)/2;
M = M_data(N);
d = lambda_data(N);

theta_s = 3 * N;

m_Ant = Antenna(M, d, lambda); %создание объекта антенной решетки
m_Ant.form7; %формирование ДН по формуле 7
m_Ant.form8; %формирование ДН по формуле 8
m_Ant.form9; %формирование ДН по формуле 9
m_Ant.form10(theta_s); %формирование ДН по формуле 10
m_Ant.showDNA({'7','9'}); %отображение ДН на графике не нормиров

m_Ant.showDNA({ '8','10'}); %отображение ДН на графике нормиров



