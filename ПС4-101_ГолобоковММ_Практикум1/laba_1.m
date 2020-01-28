%% signal models
close all;
N = 4;
D = N*1000; %in meters, ��������� �� ����
c = 3e8; %speed of light
tz = 2*D/c;%time lag, �������� ������� ����������� �������
tau = N*10e-9; %in sec, ������������ ������������ ��������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tau1 = 0.1*N*10e-9; %in sec, ������������ ������������ ��������
tau2 = 10*N*10e-9; %in sec, ������������ ������������ ��������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = 2.4e9; %in Hz - central freq, ������� �������
tdis = 1/10/f; %in sec %��� �������������
t = 0:tdis:1.2e6*tdis; %��������� �����
A = random('rayl',1,1,1); %random amplitude
phi = random('unif',0,2*pi,1,1); %random phase
%������ ������� �� ��������� ����������
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
fd = 1/tdis; %������� �������������
fr = linspace(-fd/2,fd/2,numel(spektr)); %����� ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fr1 = linspace(-fd/2,fd/2,numel(spektr1)); %����� ������
fr2 = linspace(-fd/2,fd/2,numel(spektr2)); %����� ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(fr,abs(spektr), fr, abs(spektr1), fr, abs(spektr2));
hfft=gca;
%% ����� ������� � ����
s_noise = s + wgn(1,numel(s),-N/2,'complex');
plot(htime, t,real(s));
hold (htime,'on');
plot(htime, t,real(s_noise));
xlim(htime,[2.6e-5 2.7e-5])



t = 0:tdis:fix(10000*tau/tdis)*tdis; %��������� �����
fD = N*100/(c/f);
s = exp(1j*2*pi*f*t)+0*wgn(1,numel(t),1/2,'complex');
sDop = exp(1j*2*pi*f*t).*exp(1j*2*pi*fD*t)+0*wgn(1,numel(t),1/2,'complex');
hold (htime,'on');
subplot(1,2,1);
plot(t,real(s));
subplot(1,2,2);
plot(t,real(sDop));

t = 0:tdis:1e6*tdis; %��������� �����
n = wgn(1,numel(t),1/2,'complex');
sn = N*exp(1j*2*pi*f*t)+n;
nabs = abs(n);
snabs = abs(sn);
histogram(nabs);
hold on;
histogram(snabs);

%% ������ � ������ ����������
close all;
t = 0:tdis:1e6*tdis; %��������� �����
s = A*exp(1j*2*pi*f*(t-tz))*exp(1j*phi).*(heav(t-tz)-heav(t-tau - tz))+wgn(1,numel(t),1/2,'complex');
s_get = s.*exp(-1j*2*pi*f*t); %����� ����������
spektr = fftshift(fft(s_get,5*numel(s_get)));
fd = 1/tdis; %������� �������������
fr = linspace(-fd/2,fd/2,numel(spektr)); %����� ������
plot(fr,abs(spektr)/numel(spektr));

%% �������� ������� �� ������ �����������
n = fix(tau/tdis); %����� �������� � ��������, ������� ������ �����
noise = s_get(n:end);
if ~isempty(noise)
 power = var(noise);
end

%% c������ ������� � ������ ������
referenceSignal = ones(1,n); %������� ������
convSignal = conv(s_get,referenceSignal,'same'); %������������� ����������
plot(t,abs(convSignal));
n = fix(tau/tdis); %����� �������� � ��������, ������� ������ �����
noise = convSignal(n:end); %������� ������ ������� ��������
if ~isempty(noise)
 power = var(noise);
end
threshold = sqrt(-2*log(1e-6)*power/(2-pi/2)); %������ ������
plot(t,abs((convSignal)));
hold on;
line(xlim,[1 1]*threshold,'color','red');

