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
tg1 = m_Ant.form14(1); %формирование ДН по формуле 14 для цели, смещенной на 1 градус
m_Ant.form10(1); %формирование ДН по формуле 10
m_Ant.showDNA({'10','14'}); %отображение ДН на графике
tg2 = m_Ant.form14(10); %формирование ДН по формуле 14 для цели, смещенной на 10 градусов
figure;
plot(rad2deg(m_Ant.theta),tg1); %отображение 1 цели
hold on; grid on;
plot(rad2deg(m_Ant.theta),tg2); %отображение 2 цели