clc; clear all;

radar = ModelRLS;
radar.openRawFile('velocity');
data = radar.getRawSignal('velocity','matrix');
figure;
imagesc(abs(data));
title('Raw ������');
[dataConv,scr,sct] = radar.getSpectrum('velocity');
figure;
imagesc(dataConv);
title('������ ������');
radar.m_POI.Pfa = 1e-7;
radar.m_POI.kTh = 2;
detections = radar.m_POI.detectConstTh(dataConv);
figure;
imagesc(detections);

N_targets=3;
% 
% for i=N_targets
%     data[i]
% end
% radar.m_POI.measure(dataConv,scr,[90,244],'velocity');

% ������ �� 3 ������, ������� ����� � ������� �������
% radar.m_POI.measure(dataConv,scr,[90,244],'velocity');
% radar.m_POI.measure(dataConv,scr,[59,205],'velocity');
% radar.m_POI.measure(dataConv,scr,[50,137],'velocity');


