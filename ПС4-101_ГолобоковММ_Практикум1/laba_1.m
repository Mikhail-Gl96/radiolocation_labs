%% signal models
close all;
N = 4;
D = N*1000; %in meters, дальность до цели
c = 3e8; %speed of light
tz = 2*D/c;%time lag, задержка прихода отраженного сигнала
tau = N*10e-9; %in sec, длительность зондирующего импульса
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tau1 = 0.1*N*10e-9; %in sec, длительность зондирующего импульса
tau2 = 10*N*10e-9; %in sec, длительность зондирующего импульса
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = 2.4e9; %in Hz - central freq, несущая частота
tdis = 1/10/f; %in sec %шаг дискретизации
t = 0:tdis:1.2e6*tdis; %временная сетка
A = random('rayl',1,1,1); %random amplitude
phi = random('unif',0,2*pi,1,1); %random phase
%модель сигнала со случайной амплитудой
s = A*exp(1j*2*pi*f*(t-tz))*exp(1j*phi).*(heav(t-tz)-heav(t-tau-tz));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s1 = A*exp(1j*2*pi*f*(t-tz))*exp(1j*phi).*(heav(t-tz)-heav(t-tau1-tz));
s2 = A*exp(1j*2*pi*f*(t-tz))*exp(1j*phi).*(heav(t-tz)-heav(t-tau2-tz));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(t,real(s));
htime = gca;

figure;
spektr = fftshift(fft(s));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spektr1 = fftshift(fft(s1));
spektr2 = fftshift(fft(s2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fd = 1/tdis; %частота дискретизации
fr = linspace(-fd/2,fd/2,numel(spektr)); %сетка частот
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fr1 = linspace(-fd/2,fd/2,numel(spektr1)); %сетка частот
fr2 = linspace(-fd/2,fd/2,numel(spektr2)); %сетка частот
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(fr,abs(spektr), fr, abs(spektr1), fr, abs(spektr2));
hfft=gca;
%% смесь сигнала и шума
s_noise = s + wgn(1,numel(s),-N/2,'complex');
plot(htime, t,real(s));
hold (htime,'on');
plot(htime, t,real(s_noise));
xlim(htime,[2.6e-5 2.7e-5])



t = 0:tdis:fix(10000*tau/tdis)*tdis; %временная сетка
fD = N*100/(c/f);
s = exp(1j*2*pi*f*t)+0*wgn(1,numel(t),1/2,'complex');
sDop = exp(1j*2*pi*f*t).*exp(1j*2*pi*fD*t)+0*wgn(1,numel(t),1/2,'complex');
hold (htime,'on');
subplot(1,2,1);
plot(t,real(s));
subplot(1,2,2);
plot(t,real(sDop));

t = 0:tdis:1e6*tdis; %временная сетка
n = wgn(1,numel(t),1/2,'complex');
sn = N*exp(1j*2*pi*f*t)+n;
nabs = abs(n);
snabs = abs(sn);
histogram(nabs);
hold on;
histogram(snabs);

%% спектр с выхода гетеродина
close all;
t = 0:tdis:1e6*tdis; %временная сетка
s = A*exp(1j*2*pi*f*(t-tz))*exp(1j*phi).*(heav(t-tz)-heav(t-tau - tz))+wgn(1,numel(t),1/2,'complex');
s_get = s.*exp(-1j*2*pi*f*t); %выход гетеродина
spektr = fftshift(fft(s_get,5*numel(s_get)));
fd = 1/tdis; %частота дискретизации
fr = linspace(-fd/2,fd/2,numel(spektr)); %сетка частот
plot(fr,abs(spektr)/numel(spektr));

%% мощность сигнала на выходе гетеородина
n = fix(tau/tdis); %число отсчетов в импульсе, граница начала шумов
noise = s_get(n:end);
if ~isempty(noise)
 power = var(noise);
end

%% cвертка сигнала и расчет порога
referenceSignal = ones(1,n); %опорный сигнал
convSignal = conv(s_get,referenceSignal,'same'); %согласованная фильтрация
plot(t,abs(convSignal));
n = fix(tau/tdis); %число отсчетов в импульсе, граница начала шумов
noise = convSignal(n:end); %выборка только шумовых отсчетов
if ~isempty(noise)
 power = var(noise);
end
threshold = sqrt(-2*log(1e-6)*power/(2-pi/2)); %расчет порога
plot(t,abs((convSignal)));
hold on;
line(xlim,[1 1]*threshold,'color','red');

