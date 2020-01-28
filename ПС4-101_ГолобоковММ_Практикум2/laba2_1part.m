
clear all;
close all;

N = 4;

T_nabl = 10;
F_disc = 44100;
x0 = N;
y0 = N;
start_pos = [x0, y0];
v1 = 1.5;
v2 = 0;
v3 = -0.5;
V = [v1, v2, v3];
P_c = 1;
delta_f = 180;
T_v = 0.02;

aim_number = 1:N;
radar = ModelRLS(T_nabl); %создание модели РЛС
v_border_1 = random('unif', 1, 30, N,1);
v_border_3 = random('unif', -10, -5, N, 1);

for i=aim_number
    radar.addTarget(x0,v_border_1(i),0,v_border_3(i)); %добавление 1 цели для наблюдения
    radar.m_TargetsArray{i}.move; %формирование отчетов 1 цели
    radar.m_TargetsArray{i}.show('range'); %отображение траектории движения 1 цели
    hold on;
end

radar.signalProcessing('range'); %получение данных о цели для измерения дальности
dataTime = radar.getRawSignal('range','time'); %осциллограмма сигнала
dataMatrix = radar.getRawSignal('range','matrix');%матричное представление сигнала
figure;plot(dataTime);
figure;imagesc(dataMatrix);

dataConv = radar.getSpectrum('range');
figure;imagesc(dataConv);
% 
% 
radar.m_POI.Pfa = 1e-7;
radar.m_POI.k = N;
detections = radar.m_POI.detectConstTh(dataConv);
figure;
imagesc(detections);
title('массив обнаружений');

% radar.m_POI.measure(dataConv,scr,[46,138],'range')


