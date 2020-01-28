classdef Antenna < handle
    %������ ������ ���
    properties
        
        dna7        %��� �� ������� 7
        dna8        %��� �� ������� 8
        dna9        %���, ��������� �� ������� 9
        dna10       %���, ��������� �� ������� 10
        dnaSAR      %���, �� ������� 14 ��� ���
        
        N           %����� �����������
        lambda      %������� ����� �����
        d           %��� �������� �������
        theta       %����� �����
    end
    
    methods
        function obj = Antenna(M_in, d_in, lambda_in)
            %����������� ������, �.�. �������� ������� ������
            obj.N = (M_in-1)/2; %�����, �������� ��������
            obj.lambda = lambda_in; %������� ����� �����
            obj.d = d_in;
            obj.theta = linspace(-pi/3,pi/3,720); %����� ����������� (�����)
        end
        function out = form7(obj)
            %������������ �� �� ������� 7 ���. ��.
            fc = 3e8/obj.lambda; %������� �������
            t = 0; v0 = 1; r0 = 1;
            Em = v0/r0*exp(1j*2*pi*fc*t)*exp(-1j*2*pi*r0/obj.lambda);
            k = -obj.N:obj.N; %������ ���������� ���������
            obj.dna7 = Em*sum(exp(1j*2*pi*k.'*obj.d*sin(obj.theta)/obj.lambda),1);
            out = obj.dna7;
        end
        function out = form9(obj,theta_s)
            %������������ �� �� ������� 9 ���. ��.
            if nargin < 2
                theta_s = 0; %� ��������
            end
            M = 2*obj.N+1; %����� ��������� �������(�������� �������� �������)
            fc = 3e8/obj.lambda; %������� �������
            t = 0; v0 = 1; r0 = 1;
            Em = v0/r0*exp(1j*2*pi*fc*t)*exp(-1j*2*pi*r0/obj.lambda);
            k = -obj.N:obj.N; %������ ���������� ���������
            out = Em*sum(exp(-1j*2*pi*k.'*obj.d*sin(obj.theta)/obj.lambda), 1); %����������� ��������������
            obj.dna9=out;
        end
        
        function out = form8(obj)
            %������������ �� �� ������� 8 ���. ��.
            M = 2*obj.N+1; %����� ��������� �������(�������� �������� �������)
            obj.dna8 = 1/M^2*(sin(M*pi*obj.d/obj.lambda*sin(obj.theta))./sin(pi*obj.d/obj.lambda*sin(obj.theta))).^2;   %����������� ��������������
            out = obj.dna8;
        end
        function out = form10(obj,theta_s)
            %������������ �� �� ������� 10 ���. ��.
            if nargin < 2
                theta_s = 0; %� ��������
            end
            M = 2*obj.N+1; %����� ��������� �������(�������� �������� �������)
            obj.dna10 = 1/M^2*(sin(M*pi*obj.d/obj.lambda*(sin(obj.theta)-sin(deg2rad(theta_s))))./...
                sin(pi*obj.d/obj.lambda*(sin(obj.theta)-sin(deg2rad(theta_s))))).^2;
            out = cos(obj.theta).*obj.dna10;
            obj.dna10=out;
        end
        function out = form14(obj,theta_s)
            %������������ �� �� ������� 10 ���. ��.
            if nargin < 2
                theta_s = 0; %� ��������
            end
            Pc = 1;
            r0c = 1;
            M = 2*obj.N+1; %����� ��������� �������(�������� �������� �������)
            obj.dnaSAR = sqrt(Pc/r0c^2)/M^2*(sin(2*M*pi*obj.d/obj.lambda*(sin(deg2rad(theta_s))-sin(obj.theta)))./...
                sin(2*pi*obj.d/obj.lambda*(sin(deg2rad(theta_s))-sin(obj.theta)))).^2;
            out = obj.dnaSAR;
        end
        
        function showDNA(obj,what)
            %����������� ����������� ���
            figure;
            ha = axes;
            hold on; grid on;
            ylim([0 1]);
            xlabel('angle,deg');
            ylabel('amplitude');
            legendTitles = {};
            for ii = 1:length(what)
                w = what{ii};
                switch w
                    case    {'7'}
                        plot(rad2deg(obj.theta),abs(obj.dna7));
                        legendTitles{end+1} = '�.7';
                    case    {'8'}
                        plot(rad2deg(obj.theta),abs(obj.dna8));
                        legendTitles{end+1} = '�.8';
                    case    {'9'}
                        plot(rad2deg(obj.theta),abs(obj.dna9));
                        legendTitles{end+1} = '�.9';
                    case    {'10'}
                        plot(rad2deg(obj.theta),abs(obj.dna10));
                        legendTitles{end+1} = '�.10';
                    case    {'14'}
                        plot(rad2deg(obj.theta),abs(obj.dnaSAR));
                        legendTitles{end+1} = '�.14 (SAR)';
                    otherwise
                        fprintf(2,'no data ot plot\n');
                end
            end
            legend(legendTitles);
        end
    end
end

