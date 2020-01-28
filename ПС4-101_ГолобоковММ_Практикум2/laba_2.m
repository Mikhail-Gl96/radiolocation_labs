
clear all;
close all;
T_nabl = 10;
F_disc = 44100;
x0 = 5;
y0 = 0;
start_pos = [x0, y0];
v1 = 1.5;
v2 = 0;
v3 = -0.5;
V = [v1, v2, v3];
P_c = 1;
delta_f = 180;
T_v = 0.02;

radar = ModelRLS(10); %создание модели РЛС
radar.addTarget(5,1.5,0,-0.5); %добавление 1 цели для наблюдения
radar.m_TargetsArray{1}.move; %формирование отчетов 1 цели
radar.m_TargetsArray{1}.show('range'); %отображение траектории движения 1 цели

radar.signalProcessing('range'); %получение данных о цели для измерения дальности
dataTime = radar.getRawSignal('range','time'); %осциллограмма сигнала
dataMatrix = radar.getRawSignal('range','matrix');%матричное представление сигнала
figure;plot(dataTime);
figure;imagesc(dataMatrix);

dataConv = radar.getSpectrum('range');
figure;imagesc(dataConv);


radar.m_POI.Pfa = 1e-7;
radar.m_POI.k = 2;
detections = radar.m_POI.detectConstTh(dataConv);
figure;
imagesc(detections);
title('массив обнаружений');

% radar.m_POI.measure(dataConv,scr,[46,138],'range');
