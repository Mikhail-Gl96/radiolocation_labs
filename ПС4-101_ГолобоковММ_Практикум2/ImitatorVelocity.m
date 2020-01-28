classdef ImitatorVelocity < handle
    %��������� ������ � ����� ��������    
    properties
        f0  %������� ������� �������
        fs  %������� �������������
        T   %����� ������ �������
        Ti  %�������� ��������� �������
        k   %��������� ��� �������� ������� � ��������
    end
    methods
        function obj = ImitatorVelocity(Time,Ti)            
            %����������� ������, �.�. �������� ������� ������ 
            obj.T = Time;   %����� �������������
            obj.Ti = Ti;    %�������� ������� � �������, �������� �������� ���������
            obj.fs = 44100; %������� ������������� �������� �����
            obj.f0 = 2530e6; %���
            obj.k = 3e8/obj.f0/2; %Vr = l/2*Fd �����. ������������������
            nT = fix(obj.T*obj.fs);
            nTi = fix(obj.Ti*obj.fs);
            obj.T = fix(nT/nTi)*nTi/obj.fs; %��������� ������� �������������
            obj.Ti = nTi/obj.fs;
        end
        function Y = generateVelocitySignal(obj,Vr,noiseDb)
            %��������� �������
            if nargin < 3
                noiseDb = -100; %��, �.�. ����������� ���
            end
            t = 0:1/obj.fs:obj.T-1/obj.fs; %������� �������������
            Vr = Vr(1:length(t)); %��������� ����� ��������
            Fdop = 2*Vr/(3e8/obj.f0); %2vr/lambda
            Y = exp(1j*2*pi*Fdop.*t);
            Y = real(Y+wgn(1,numel(Y),noiseDb,'complex')); %���������� ����
        end
        function t = getTime(obj)
            %���������� ������� �������������
            t = 0:1/obj.fs:obj.T-1/obj.fs; %������� �������������
        end
        function Y = generateVelocityMatrix(obj,Vr)
            %��������� ������� � ���� �������
            Y = obj.generateVelocitySignal(Vr);
            Y = reshape(Y,round(obj.fs*obj.Ti),[]).'; %��� ������� �� Ti ��������
        end
        function t = getTimeMatrix(obj)
            %���������� ������� ������������� � ���� �������
            t = 0:1/obj.fs:obj.T-1/obj.fs; %������� �������������
            t = reshape(t,round(obj.fs*obj.Ti),[]).'; %��� ������� �� Ti
        end
    end
end

