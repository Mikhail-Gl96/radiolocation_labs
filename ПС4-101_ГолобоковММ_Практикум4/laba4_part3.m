clc; clear all;
% random.seed(0);
N = 4;  % ����� ��������

target_numbers = N;
P_deflected = random('unif', 0, 100, N, 3);
x_cord = random('unif', -100, 100, N, 3);
y_cord = random('unif', -100, 100, N, 3);
z_cord = random('unif', -100, 100, N, 3);

delta_x = 0.6;  % ���������������� ��� ����� ����������
Tp = 0.4e-6;   % ������������ ������������ ��������
Wr = 575.3; % ���������� ������ ����������� �������
Wa = 442.9; % ������������ ������ ����������� �������
Fc = 242.4e6; % ����������� ������� ������� ��� ������������ ��������
alpha = 33.375e6; % �������� ���������� ������� 
BW = 133.5e6; % ������ �������
Fs = 2560e6; % ������� ������������� �������
Dr = 1; % ����������� ����������� �� ���������
Da = 1; % ����������� ����������� �� ������������ ���������� (���������� ����������)
Kr = 0.89; % ����������� ���������� �������� �������� ������� �� ���������
Ka = 0.89; % ����������� ���������� �������� �������� ������� �� ������������ ���������� 
R_scene = 1000; % ��������� �� ������ ������������ �����������
Phi_ac = deg2rad(90); % ���� ������� ������� 
Theta_ac = deg2rad(90); % ���� ����� ���� ������� 
L = 760.8; % ����� ������������� �������� 
dTheta = deg2rad(41.6); % �������� ������������ ����������
N_points = N; % ���������� ������������ ��������� �����
point_coord = [x_cord;   % ���������� ������������ ��������� �����
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
     dist_ant = [k(i) R_scene]; %��������� �������
     for n = 1:N_points
         %��������� ��������� ���� - �������
         rc = sqrt((point_coord(n,1) -dist_ant(1))^2 +(point_coord(n,2)-dist_ant(2))^2);
         Vc = 1*exp(-1j*4*pi*rc./lambda);
         Vsum(i,:) = Vsum(i,:) + Vc;
     end
end

Kr = 4*pi*f/c;
Kr = repmat(Kr,Na,1);
Vsum = Vsum.*exp(1j*R_scene*Kr); %����������� ������� �������
%����������� ����������� �� ������� ��������� � ������� ������ � ��� ���������
Vsum_compr = fftshift(fft(Vsum,[],2),2);
imagesc(abs(Vsum_compr));

Vsum = fftshift(Vsum,1);
Vsum = fft(Vsum,[],1);
Vsum = fftshift(Vsum,1);
% ��������� ������������� ������ �������
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

Vsum = fftshift(ifft(Vsum,[],2),2);%������ �� ����. ����������
Vsum = ifft(fftshift(Vsum,1),[],1);%������ �� ������. ����������
Vsum = fftshift(Vsum,1);
% ����������� �������� ���������� ��� �����������
dy=2*pi/(Ky_int(end)-Ky_int(1));
Y=-Ny/2*dy:dy:(Ny/2-1)*dy;
X=linspace(-L/2,L/2,L/delta_x+1).';
imagesc(R_scene+Y,X,abs(Vsum));
imagesc(abs(Vsum));
colormap('pink');
