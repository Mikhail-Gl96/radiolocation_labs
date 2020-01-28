classdef ReadData < handle
    %Извлечение данных из файла
    
    properties
        f0  %рабочая частота сигнала
        fs  %частота дискретизации
        Tr  %период повторения
        filename   %запись сигнала
        k   %константа для персчета частоты в дальность
    end
    
    methods
        function obj = ReadData            
            %конструктор класса, т.е. создание объекта класса 
            obj.fs = 44100; %частота дискретизации звуковой карты
            obj.Tr = 2e-2; %период повторения в сек                    
            obj.f0 = 2530e6; %МГц1
        end
        function openRawFile(obj,type)
            %открытие файла
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
            %чтение файла и разбивка на интервалы T
            if nargin < 2
                T = 0.1; %период обработки данных
            end
            [Y,obj.fs] = audioread(obj.filename);
            Y = Y(:,1); %полезный сигнал
            ns = obj.fs*T;
            nlines = fix(numel(Y)/ns);
            Y = Y(1:ns*nlines);
            Y = reshape(Y,ns,[]).';
        end
        function Y = getRangeMatrix(obj)
            %чтение файла и разбивка на интервалы T
            [Y,obj.fs] = audioread(obj.filename);
            
            s = Y(:,1);     %полезный сигнал
            trig = Y(:,2);  %синхроимпульсы
            
            N = obj.fs*obj.Tr;    % число отсчетов, приоходящихся на время записи
            count = 0;
            thresh = 0;
            start = (trig > thresh); % формирование логического массива только положительных отсчетов
            for ii = 100:(size(start,1)-N)
                %если 10 предыдущих отсчетов 0, а текущий 11-й отсчет равен 1
                if (start(ii) == 1) && (mean(start(ii-11:ii-1)) == 0)
                    count = count + 1;          % инкрементировать счетчик обнаруженных импульсов на 1
                    sif(count,:) = s(ii:ii+N-1);% занести в матрицу временную реализацию сигнала с позиции ii
                    time(count) = ii/obj.fs;      % формирование шкалы времени
                end
                if (start(ii) == 0) && (mean(start(ii-11:ii-1)) == 1)
                    count = count + 1;          % инкрементировать счетчик обнаруженных импульсов на 1
                    sif(count,:) = s(ii:ii+N-1);% занести в матрицу временную реализацию сигнала с позиции ii
                    time(count) = ii/obj.fs;      % формирование шкалы времени
                end
            end
            clear start;
            
            % б) Вычитание постоянной составляющей из сигнала
            avg = mean(sif);
            for ii = 1:size(sif,1);
                sif(ii,:) = sif(ii,:) - avg;
            end
            
            nw = size(sif);
            wnd = hamming(nw(2)).';
            wnd = repmat(wnd,nw(1),1);
            Y = sif.*wnd;
            
            %череcпериодное вычитание
            Y = Y(2:end,:)-Y(1:end-1,:);
        end
    end
    
end

