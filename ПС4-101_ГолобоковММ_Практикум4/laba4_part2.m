clc; clear all;

N = 4;
lambda_data = [0.12 , 0.12 , 0.12 , 0.12 , 0.12 , 0.032, 0.032, 0.032, 0.032, 0.032, 0.05 , 0.05];
d_data = [lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, lambda_data/2, 3/4*lambda_data, 3/4*lambda_data];
M_data = [21, 19, 21, 19, 21, 19, 21, 19, 23, 27, 23, 27];
lambda = d_data(N)/2;
M = M_data(N);
d = lambda_data(N);

theta_s = 3 * N;

m_Ant = Antenna(M, d, lambda); %�������� ������� �������� �������
tg1 = m_Ant.form14(1); %������������ �� �� ������� 14 ��� ����, ��������� �� 1 ������
m_Ant.form10(1); %������������ �� �� ������� 10
m_Ant.showDNA({'10','14'}); %����������� �� �� �������
tg2 = m_Ant.form14(10); %������������ �� �� ������� 14 ��� ����, ��������� �� 10 ��������
figure;
plot(rad2deg(m_Ant.theta),tg1); %����������� 1 ����
hold on; grid on;
plot(rad2deg(m_Ant.theta),tg2); %����������� 2 ����