classdef Detector < handle
    %����� ������������ ��������
    properties
        Pfa %����������� ������ �������
        kTh %�����. ��������� ������
        thr %������������ �����
        Detections  %������ �����������
    end
    
    methods
        function obj = Detector
            %������ �����������
        end
        function det = detectConstTh(obj,signal)
            %����������� �������
            %������ ������
            obj.thr = obj.threshold(signal(:,end));
            det = signal > obj.thr;
            obj.Detections = det;
        end
        function thr = threshold(obj,s)
            %������ �������� ������
            noise_pwr = var(s(:))/(2-pi/2); %�������� �����
            %����� �����������
            thr = sqrt(-2*obj.kTh*log(obj.Pfa)*noise_pwr);
        end
        function measure(obj,data,ranges,coords,type)
            %������������ ������ �����������
            if nargin < 5
                type = ''; %�� ���������� ��������
            end
            switch type
                case {'range'}
                    s1 = '��������� �� ���� = ';
                    s2 = ' �';
                case {'velocity'}
                    s1 = '�������� ���� = ';
                    s2 = ' �/�';
                otherwise
                    s1 = '';
                    s2 = '';
            end
            rows = coords(2); %�� ��� �y
            cols = coords(1)-5:coords(1)+5;
            ampl = data(rows,cols); %��������� ������������� �������
            rdet = ranges(cols); %�������� ���������� ������������� �������
            rest = sum(ampl.*rdet)/sum(ampl); %������� ������ ���������
            msgbox([s1 num2str(rest) s2]);

            %����������� ����������� �����������
            figure;
            %����������� �������
            plot(ranges,data(rows,:));
            xlabel(s2);
            ylabel('ampl, popugai');
            hold on;grid on;
            %����������� ������
            line(xlim,[obj.thr obj.thr],'color','red');
            plot(ranges,2*obj.thr*obj.Detections(rows,:));
            title('������, �����, ������� �����������');
            legend('������', '�����', '������� �����������');
        end
    end
    
end

