classdef ReadData < handle
    %���������� ������ �� �����
    
    properties
        f0  %������� ������� �������
        fs  %������� �������������
        Tr  %������ ����������
        filename   %������ �������
        k   %��������� ��� �������� ������� � ���������
    end
    
    methods
        function obj = ReadData            
            %����������� ������, �.�. �������� ������� ������ 
            obj.fs = 44100; %������� ������������� �������� �����
            obj.Tr = 2e-2; %������ ���������� � ���                    
            obj.f0 = 2530e6; %���1
        end
        function openRawFile(obj,type)
            %�������� �����
            switch type
                case {'range'}
                    [fn,ph] = uigetfile('*_range.wav');
                    obj.filename = [ph,fn];
                    
                case {'velocity'}
                    [fn,ph] = uigetfile('*_velocity.wav');
                    obj.filename = [ph,fn];
                otherwise
                    fprintf(2,'no type specified\n');
            end
        end
        function Y = getVelocityMatrix(obj,T)
            %������ ����� � �������� �� ��������� T
            if nargin < 2
                T = 0.1; %������ ��������� ������
            end
            [Y,obj.fs] = audioread(obj.filename);
            Y = Y(:,1); %�������� ������
            ns = obj.fs*T;
            nlines = fix(numel(Y)/ns);
            Y = Y(1:ns*nlines);
            Y = reshape(Y,ns,[]).';
        end
        function Y = getRangeMatrix(obj)
            %������ ����� � �������� �� ��������� T
            [Y,obj.fs] = audioread(obj.filename);
            
            s = Y(:,1);     %�������� ������
            trig = Y(:,2);  %��������������
            
            N = obj.fs*obj.Tr;    % ����� ��������, ������������� �� ����� ������
            count = 0;
            thresh = 0;
            start = (trig > thresh); % ������������ ����������� ������� ������ ������������� ��������
            for ii = 100:(size(start,1)-N)
                %���� 10 ���������� �������� 0, � ������� 11-� ������ ����� 1
                if (start(ii) == 1) && (mean(start(ii-11:ii-1)) == 0)
                    count = count + 1;          % ���������������� ������� ������������ ��������� �� 1
                    sif(count,:) = s(ii:ii+N-1);% ������� � ������� ��������� ���������� ������� � ������� ii
                    time(count) = ii/obj.fs;      % ������������ ����� �������
                end
                if (start(ii) == 0) && (mean(start(ii-11:ii-1)) == 1)
                    count = count + 1;          % ���������������� ������� ������������ ��������� �� 1
                    sif(count,:) = s(ii:ii+N-1);% ������� � ������� ��������� ���������� ������� � ������� ii
                    time(count) = ii/obj.fs;      % ������������ ����� �������
                end
            end
            clear start;
            
            % �) ��������� ���������� ������������ �� �������
            avg = mean(sif);
            for ii = 1:size(sif,1);
                sif(ii,:) = sif(ii,:) - avg;
            end
            
            nw = size(sif);
            wnd = hamming(nw(2)).';
            wnd = repmat(wnd,nw(1),1);
            Y = sif.*wnd;
            
            %����c��������� ���������
            Y = Y(2:end,:)-Y(1:end-1,:);
        end
    end
    
end

