classdef ImitatorRange < handle
      %��������� ������ � ������ ������
    properties
        B   %������� ������ ������
        fs  %������� �������������
        T   %����� ������ �������
        k   %��������� ��� �������� ������� � ���������
        Tr  %������ ���������� �������
        nTr %����� �������� �� ������ ���������� �������
    end
    methods
        function obj = ImitatorRange(Time)            
            %����������� ������, �.�. �������� ������� ������ 
            obj.T = Time; %����� �������������
            obj.fs = 44100; %������� ������������� �������� �����
            obj.B = (2530e6-2350e6); %��
            obj.Tr = 20e-3; %������ ���������� �������
            obj.k = 3e8/2*obj.Tr/obj.B*pi; %�����. ������������������
            %��������� ������� �������������
            obj.nTr = obj.fs*obj.Tr;
            obj.T = fix(obj.T/obj.Tr)*obj.nTr/obj.fs-1/obj.fs;
        end
        function Y = generateRangeSignal(obj,R,noiseDb)
            if nargin < 3
                noiseDb = -100; %��, �.�. ����������� ���
            end
            %��������� �������
            t = 0:1/obj.fs:obj.T;   %������� �������������
            R = R(1:length(t));     %��������� ����� ��������
            tz = 2*R/3e8;           %�������� ������� �������           
            Fb = obj.B/obj.Tr*tz/pi;%������� ������
            Y = exp(1j*2*pi*Fb.*t);  %������ �� �������
            Y = real(Y+wgn(1,numel(Y),noiseDb,'complex')); %���������� ���� ���������
        end
        function t = getTime(obj)
            %���������� ������� �������������
            t = 0:1/obj.fs:obj.T; %������� �������������
        end
        function Y = generateRangeMatrix(obj,R,noiseDb)
            %��������� ������������� �������
            if nargin < 3
                noiseDb = -100;
            end
            t = obj.getTime;
            R = R(1:length(t));
            Rmean = mean(reshape(R,obj.nTr,[]));
            R = repmat(Rmean,obj.nTr,1);
            R = R(:).';
            Y = obj.generateRangeSignal(R,noiseDb);
            Y = reshape(Y,obj.nTr,[]).';
        end
        function t = getTimeMatrix(obj)
            %���������� ������� �������������
            t = 0:obj.nTr/obj.fs:obj.T; %������� �������������
        end
    end
end

