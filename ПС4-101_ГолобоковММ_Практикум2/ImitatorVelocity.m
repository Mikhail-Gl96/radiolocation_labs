classdef ImitatorVelocity < handle
    %Генерация данных с неким доплером    
    properties
        f0  %рабочая частота сигнала
        fs  %частота дискретизации
        T   %время записи сигнала
        Ti  %интервал обработки сигнала
        k   %константа для персчета частоты в скорость
    end
    methods
        function obj = ImitatorVelocity(Time,Ti)            
            %конструктор класса, т.е. создание объекта класса 
            obj.T = Time;   %время моделирования
            obj.Ti = Ti;    %интервал времени в течение, которого делается обработка
            obj.fs = 44100; %частота дискретизации звуковой карты
            obj.f0 = 2530e6; %МГц
            obj.k = 3e8/obj.f0/2; %Vr = l/2*Fd коэфф. пропорциональности
            nT = fix(obj.T*obj.fs);
            nTi = fix(obj.Ti*obj.fs);
            obj.T = fix(nT/nTi)*nTi/obj.fs; %коррекция времени моделирования
            obj.Ti = nTi/obj.fs;
        end
        function Y = generateVelocitySignal(obj,Vr,noiseDb)
            %генерация сигнала
            if nargin < 3
                noiseDb = -100; %дб, т.е. отсутствует шум
            end
            t = 0:1/obj.fs:obj.T-1/obj.fs; %моменты дискретизации
            Vr = Vr(1:length(t)); %коррекция числа отсчетов
            Fdop = 2*Vr/(3e8/obj.f0); %2vr/lambda
            Y = exp(1j*2*pi*Fdop.*t);
            Y = real(Y+wgn(1,numel(Y),noiseDb,'complex')); %добавление шума
        end
        function t = getTime(obj)
            %возвращает моменты дискретизации
            t = 0:1/obj.fs:obj.T-1/obj.fs; %моменты дискретизации
        end
        function Y = generateVelocityMatrix(obj,Vr)
            %генерация сигнала в виде матрицы
            Y = obj.generateVelocitySignal(Vr);
            Y = reshape(Y,round(obj.fs*obj.Ti),[]).'; %вид матрицы по Ti столбцов
        end
        function t = getTimeMatrix(obj)
            %возвращает моменты дискретизации в виде матрицы
            t = 0:1/obj.fs:obj.T-1/obj.fs; %моменты дискретизации
            t = reshape(t,round(obj.fs*obj.Ti),[]).'; %вид матрицы по Ti
        end
    end
end

