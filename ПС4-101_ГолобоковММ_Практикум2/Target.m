classdef Target < handle
    %����� ����������� �������� ����
    properties
        X0      %��������� ������ ��������� ���� (x,vx)
        V       %������ ��������� �� 3� ��������
        dT      %��� �������������
        T
        Z       %������ ���������� ���
    end
    methods
        function obj = Target(dT,T,x0,vx1,vx2,vx3)
            %����������� ������ ��������� ������ ���� � �������� �� 3
            %��������
            obj.dT = dT;            %��� �������������
            obj.T = T;              %����� �������������
            obj.X0 = [x0 vx1].';    %��������� ������ ���������
            obj.V = [vx1,vx2,vx3];  %���������� ���������
        end
        function move(obj)
            %����� ���������� ������ ��������� ���� � ������� �������
            %�������������
            F = [   1   obj.dT; %������� �������� ������� ���������
                0   1];
            X = obj.X0; %��������� ���������
            for ii = obj.dT:obj.dT:obj.T
                %if ii < 3 % ������ �� ������ �.�. ���
                %end
                if ii >=3 && ii < 6 %������ ������� ������
                    X(2,end) = obj.V(2); %��������� �������� ����
                end
                if ii >=6 %������ ������ ������
                    X(2,end) = obj.V(3);
                end
                X(:,end+1) = F*X(:,end);
            end
            obj.Z = X;
        end
        function out = getZ(obj,type)
            %���������� ���������� ��� ����������� ���������
            switch type
                case {'velocity'}
                    out = obj.Z(2,:);
                case {'range'}
                    out = obj.Z(1,:);
                otherwise
                    out = zeros(1,fix(obj.T,obj.dT));
            end
        end
        function show(obj,type)
            %����������� ����������� ������������� ����������
            if ~isempty(obj.Z)
                t = 0:obj.dT:obj.T;
                switch type
                    case {'velocity'}
                        x = obj.getZ(type);
                        plot(t,x)
                        grid on;
                        xlabel('time, s');
                        ylabel('x, m/s');
                        ylim([-max(x)*1.25 max(x)*1.25]);
                        title('������ ��������-�����');
                    case {'range'}
                        x = obj.getZ(type);
                        plot(t,x)
                        grid on;
                        xlabel('time, s');
                        ylabel('x, m');
                        ylim([0 max(x)*1.25]);
                        title('������ ���������-�����');
                    otherwise
                        fprintf(2,'no type\n');
                end
            end
        end
    end
end

