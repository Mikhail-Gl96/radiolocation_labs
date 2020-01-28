clc; clear all;
% random.seed(0);
N = 4;  % Номер варианта

target_numbers = N;
P_deflected = random('unif', 0, 100, N, 3);
x_cord = random('unif', -100, 100, N, 3);
y_cord = random('unif', -100, 100, N, 3);
z_cord = random('unif', -100, 100, N, 3);

delta_x = 0.6;  % Пространственный шаг между импульсами
Tp = 0.4e-6;   % Длительность зондирующего импульса
Wr = 575.3; % Продольная ширина исследуемой области
Wa = 442.9; % Азимутальная ширина исследуемой области
Fc = 242.4e6; % Центральная несущая частота ЛЧМ зондирующего импульса
alpha = 33.375e6; % Скорость нарастания частоты 
BW = 133.5e6; % Полоса сигнала
Fs = 2560e6; % Частота дискретизации сигнала
Dr = 1; % Разрешающая способность по дальности
Da = 1; % Разрешающая способность по азимутальной координате (продольной координате)
Kr = 0.89; % Коэффициент расширения главного лепестка антенны по дальности
Ka = 0.89; % Коэффициент расширения главного лепестка антенны по азимутальной координате 
R_scene = 1000; % Дальность до центра исследуемого изображения
Phi_ac = deg2rad(90); % Угол наклона антенны 
Theta_ac = deg2rad(90); % Угол скоса луча антенны 
L = 760.8; % Длина синтезируемой апертуры 
dTheta = deg2rad(41.6); % Интервал когерентного накопления
N_points = N; % Количество моделируемых блестящих точек
point_coord = [x_cord;   % Координаты моделируемых блестящих точек
               y_cord;
               z_cord];
Pc = P_deflected;
k = -L/2:delta_x:L/2;
t = 0:1/Fs:Tp-1/Fs;
f = linspace(Fc-BW,Fc,length(t));
Na = length(k);
Nf = length(t);
V = delta_x/Tp;
c = 3e8; lambda = c./f;
Vsum = zeros(length(k),length(t));
for i = 1:Na
     dist_ant = [k(i) R_scene]; %положение антенны
     for n = 1:N_points
         %наклонная дальность цель - самолет
         rc = sqrt((point_coord(n,1) -dist_ant(1))^2 +(point_coord(n,2)-dist_ant(2))^2);
         Vc = 1*exp(-1j*4*pi*rc./lambda);
         Vsum(i,:) = Vsum(i,:) + Vc;
     end
end

Kr = 4*pi*f/c;
Kr = repmat(Kr,Na,1);
Vsum = Vsum.*exp(1j*R_scene*Kr); %компенсация фазовых набегов
%перемещение отражателей по каналам дальности в течение полета – ЛЧМ дальномер
Vsum_compr = fftshift(fft(Vsum,[],2),2);
imagesc(abs(Vsum_compr));

Vsum = fftshift(Vsum,1);
Vsum = fft(Vsum,[],1);
Vsum = fftshift(Vsum,1);
% результат азмиутального сжатия сигнала
Vsum_compr = fftshift(ifft(Vsum,[],2),2);
imagesc(abs(Vsum_compr));

Kx = linspace(-pi/delta_x,pi/delta_x,L/delta_x+1).';
Kx = repmat(Kx,1,Nf);
Ky_sq = Kr.^2-Kx.^2;
Neg = logical(Ky_sq < 0);
Ky_sq(Neg) = NaN;Vsum(Neg) = NaN;Kr(Neg) = NaN;
Fmf = -R_scene*Kr+R_scene*sqrt(Ky_sq);
Vsum = Vsum.*exp(1j*Fmf);
Vsum_compr = fftshift(ifft(Vsum,[],2),2);
imagesc(abs(Vsum_compr));

Ky = sqrt(Ky_sq);
Ky_int = Ky(Na/2-0.5,:);
Ky_int = Ky_int.'; Ky = Ky.'; Vsum = Vsum.';
for i = 1:size(Vsum,1)
    Vsum_temp(:,i) = spline(Ky(:,i),Vsum(:,i),Ky_int.');
end
Vsum = Vsum_temp.';
Ny=750;
Vsum=Vsum(:,1:Ny);
Ky_int=Ky_int(1:Ny);

Vsum = fftshift(ifft(Vsum,[],2),2);%Сжатие по прод. координате
Vsum = ifft(fftshift(Vsum,1),[],1);%Сжатие по азимут. координате
Vsum = fftshift(Vsum,1);
% Восстановим исходные координаты для изображения
dy=2*pi/(Ky_int(end)-Ky_int(1));
Y=-Ny/2*dy:dy:(Ny/2-1)*dy;
X=linspace(-L/2,L/2,L/delta_x+1).';
imagesc(R_scene+Y,X,abs(Vsum));
imagesc(abs(Vsum));
colormap('pink');
