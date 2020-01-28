classdef ImitatorRange < handle
      %Генерация данных с некими целями
    properties
        B   %рабочая полоса частот
        fs  %частота дискретизации
        T   %время записи сигнала
        k   %константа для персчета частоты в дальность
        Tr  %период повторения сигнала
        nTr %число отсчетов на период повторения сигнала
    end
    methods
        function obj = ImitatorRange(Time)            
            %конструктор класса, т.е. создание объекта класса 
            obj.T = Time; %время моделирования
            obj.fs = 44100; %частота дискретизации звуковой карты
            obj.B = (2530e6-2350e6); %Гц
            obj.Tr = 20e-3; %период повторения сигнала
            obj.k = 3e8/2*obj.Tr/obj.B*pi; %коэфф. пропорциональности
            %коррекция времени моделирования
            obj.nTr = obj.fs*obj.Tr;
            obj.T = fix(obj.T/obj.Tr)*obj.nTr/obj.fs-1/obj.fs;
        end
        function Y = generateRangeSignal(obj,R,noiseDb)
            if nargin < 3
                noiseDb = -100; %дб, т.е. отсутствует шум
            end
            %генерация сигнала
            t = 0:1/obj.fs:obj.T;   %моменты дискретизации
            R = R(1:length(t));     %коррекция числа отсчетов
            tz = 2*R/3e8;           %задержка прихода сигнала           
            Fb = obj.B/obj.Tr*tz/pi;%частоты биений
            Y = exp(1j*2*pi*Fb.*t);  %сигнал во времени
            Y = real(Y+wgn(1,numel(Y),noiseDb,'complex')); %добавление шума приемника
        end
        function t = getTime(obj)
            %возвращает моменты дискретизации
            t = 0:1/obj.fs:obj.T; %моменты дискретизации
        end
        function Y = generateRangeMatrix(obj,R,noiseDb)
            %матричное представление сигнала
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
            %возвращает моменты дискретизации
            t = 0:obj.nTr/obj.fs:obj.T; %моменты дискретизации
        end
    end
end

