classdef ModelRLS < handle
    %����� ����������� ������ ���
    properties
        m_TargetsArray      %������ �����, ����������� ���
        m_ImitatorRange     %������������� ������� � ������ ���������
        m_ImitatorVelocity  %����������� ������� � ������ ��������
        m_ExpData           %����������� ����������������� ������
        m_POI               %������������ � ����������
        
        T                   %����� ����� �������������
        fs                  %������� ������������� (��� �������������)
        sRT                 %��������� ��������� ������� ���������
        sRM                 %��������� ������������� ������� (�������������)
        sVT                 %��������� ��������� ������ ��������
        sVM                 %��������� ������������� ������� (�������������)
        zpad = 4            %��������� ���� ���
    end
    
    methods
        function obj = ModelRLS(time2model)
            %����������� ������ ���
            if nargin < 1
                time2model = 1; %�������� �� ���������
            end
            obj.T = time2model;
            obj.fs = 44100; %������� ������������� ��������
            obj.m_ImitatorRange = ImitatorRange(time2model);
            obj.m_ImitatorVelocity = ImitatorVelocity(time2model,0.1);
            %�������� 0.1 ���������� �������� ����� ����������
            obj.m_ExpData = ReadData;
            obj.m_POI = Detector;
        end
        function addTarget(obj,x0,vx1,vx2,vx3)
            %���������� ���� ��� ����������
            obj.m_TargetsArray{end+1} = Target(1/obj.fs,obj.T,x0,vx1,vx2,vx3);
            obj.m_TargetsArray{end}.move;
        end
        function signalProcessing(obj,type)
            %� ����������� �� ���������� ���� ��������� �������
            %������������ ������� ����������� �������
            switch type
                case {'velocity'}
                    for ii = 1:length(obj.m_TargetsArray)
                        %��������� �������� ���������
                        v = obj.m_TargetsArray{ii}.getZ('velocity');
                        %������������ ���������� ������ � ���� �����
                        tempVT = obj.m_ImitatorVelocity.generateVelocitySignal(v);
                        tempVM = obj.m_ImitatorVelocity.generateVelocityMatrix(v);
                        %������������ ������� �� ������ �����
                        if isempty(obj.sVT)
                            obj.sVT = tempVT;
                            obj.sVM = tempVM;
                        else
                            obj.sVT = obj.sVT + tempVT;
                            obj.sVM = obj.sVM + tempVM;
                        end
                    end                    
                case {'range'}
                    for ii = 1:length(obj.m_TargetsArray)
                        r = obj.m_TargetsArray{ii}.getZ('range');
                        tempRT = obj.m_ImitatorRange.generateRangeSignal(r);
                        tempRM = obj.m_ImitatorRange.generateRangeMatrix(r);
                        %������������ ������� �� ������ �����
                        if isempty(obj.sRT)
                            obj.sRT = tempRT;
                            obj.sRM = tempRM;
                        else
                            obj.sRT = obj.sRT + tempRT;
                            obj.sRM = obj.sRM + tempRM;
                        end
                    end
                otherwise
                    fprintf(2,'no type\n');
                    return
            end            
        end
        function out = getRawSignal(obj,type,view)
            %����� ������
            switch type
                case {'range'}
                    if strcmp(view,'time')
                        out = obj.sRT; %��������� �� �������
                    else
                        out = obj.sRM; %��������� ���
                    end
                case {'velocity'}
                    if strcmp(view,'time')
                        out = obj.sVT; %��������� �� �������
                    else
                        out = obj.sVM; %��������� ���
                    end
                otherwise
                    fprintf(2,'no type specified\n');
                    out = -1;
            end
        end
        function [out,brdx,brdy] = getSpectrum(obj,type)
            %������������ ������� (� ��������� �������) �������
            out = []; %�������� ������
            brdx = []; %������� �� Ox
            brdy = []; %������� �� Oy
            switch type
                case {'range'}
                    dT = size(obj.sRM,2)/obj.fs; %��� �� ������� ������
                    n = obj.zpad*size(obj.sRM,2);
                    out = fft(obj.sRM,n,2);
                    f = linspace(-obj.fs/2,obj.fs/2,size(out,2)); %����� ������
                    r = obj.m_ImitatorRange.k*f; %������� ������� -> ���������
                    out = abs(fftshift(out,2));
                    r(1:numel(r)/2) = [];
                    brdx = r;
                    brdy = 0:dT:dT*size(obj.sRM,1)-dT;
                    out(:,1:size(out,2)/2) = [];
                case {'velocity'}
                    dT = size(obj.sRM,2)/obj.fs; %��� �� ������� ������
                    n = obj.zpad*size(obj.sVM,2);
                    out = fft(obj.sVM,n,2); %��� �� ��������
                    f = linspace(-obj.fs/2,obj.fs/2,size(out,2)); %����� ������
                    v = obj.m_ImitatorVelocity.k*f; %������� ������� -> ��������
                    out = abs(fftshift(out,2));
                    v(1:numel(v)/2) = [];
                    brdx = v;
                    brdy = 0:dT:dT*size(obj.sVM,1)-dT;
                    out(:,1:size(out,2)/2) = [];
                otherwise
                    fprintf(2,'no type specified\n');
            end
        end
        function openRawFile(obj,type)
            %�������� ����������������� ������
            if nargin < 2
                fprintf(2,'no type specified\n');
                return
            end
            switch type
                case {'range'}
                    obj.m_ExpData.openRawFile('range');
                    obj.sRM = obj.m_ExpData.getRangeMatrix;
                    temp = obj.sRM.';
                    obj.sRT = temp(:);
                case {'velocity'}
                    obj.m_ExpData.openRawFile('velocity');
                    obj.sVM = obj.m_ExpData.getVelocityMatrix;
                    temp = obj.sVM.';
                    obj.sVT = temp(:);
            end
        end
    end
end

