classdef ModelRLS < handle
    %класс описывающий работу –Ћ—
    properties
        m_TargetsArray      %массив целей, наблюдаемых –Ћ—
        m_ImitatorRange     %формирователь сигнала в режиме дальности
        m_ImitatorVelocity  %формировать сигнала в режиме скорости
        m_ExpData           %считыватель экспериментальных данных
        m_POI               %обнаружитель и измеритель
        
        T                   %общее врем€ моделировани€
        fs                  %частота дискретизации (шаг моделировани€)
        sRT                 %временна€ развертка сигнала дальности
        sRM                 %матричное представление сигнала (спектрограмма)
        sVT                 %временна€ развертка сигнал скорости
        sVM                 %матричное представление сигнала (спектрограмма)
        zpad = 4            %улучшение вида Ѕѕ‘
    end
    
    methods
        function obj = ModelRLS(time2model)
            %конструктор модели –Ћ—
            if nargin < 1
                time2model = 1; %значение по умолчанию
            end
            obj.T = time2model;
            obj.fs = 44100; %частота дискретизации сигналов
            obj.m_ImitatorRange = ImitatorRange(time2model);
            obj.m_ImitatorVelocity = ImitatorVelocity(time2model,0.1);
            %параметр 0.1 позвол€тет изменить врем€ наблюдени€
            obj.m_ExpData = ReadData;
            obj.m_POI = Detector;
        end
        function addTarget(obj,x0,vx1,vx2,vx3)
            %добавление цели дл€ наблюдени€
            obj.m_TargetsArray{end+1} = Target(1/obj.fs,obj.T,x0,vx1,vx2,vx3);
            obj.m_TargetsArray{end}.move;
        end
        function signalProcessing(obj,type)
            %в зависимости от выбранного типа выходного сигнала
            %сформировать матрицу отраженного сигнала
            switch type
                case {'velocity'}
                    for ii = 1:length(obj.m_TargetsArray)
                        %сохранить значени€ дальности
                        v = obj.m_TargetsArray{ii}.getZ('velocity');
                        %сформировать отраженный сигнал в двух видах
                        tempVT = obj.m_ImitatorVelocity.generateVelocitySignal(v);
                        tempVM = obj.m_ImitatorVelocity.generateVelocityMatrix(v);
                        %суммирование сигнала от разных целей
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
                        %суммирование сигнала от разных целей
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
            %вывод данных
            switch type
                case {'range'}
                    if strcmp(view,'time')
                        out = obj.sRT; %развертка по времени
                    else
                        out = obj.sRM; %матричный вид
                    end
                case {'velocity'}
                    if strcmp(view,'time')
                        out = obj.sVT; %развертка по времени
                    else
                        out = obj.sVM; %матричный вид
                    end
                otherwise
                    fprintf(2,'no type specified\n');
                    out = -1;
            end
        end
        function [out,brdx,brdy] = getSpectrum(obj,type)
            %формирование сжатого (в частотной области) сигнала
            out = []; %выходной спектр
            brdx = []; %границы по Ox
            brdy = []; %границы по Oy
            switch type
                case {'range'}
                    dT = size(obj.sRM,2)/obj.fs; %шаг по времени строки
                    n = obj.zpad*size(obj.sRM,2);
                    out = fft(obj.sRM,n,2);
                    f = linspace(-obj.fs/2,obj.fs/2,size(out,2)); %шкала частот
                    r = obj.m_ImitatorRange.k*f; %перевод частота -> дальность
                    out = abs(fftshift(out,2));
                    r(1:numel(r)/2) = [];
                    brdx = r;
                    brdy = 0:dT:dT*size(obj.sRM,1)-dT;
                    out(:,1:size(out,2)/2) = [];
                case {'velocity'}
                    dT = size(obj.sRM,2)/obj.fs; %шаг по времени строки
                    n = obj.zpad*size(obj.sVM,2);
                    out = fft(obj.sVM,n,2); %Ѕѕ‘ по столбцам
                    f = linspace(-obj.fs/2,obj.fs/2,size(out,2)); %шкала частот
                    v = obj.m_ImitatorVelocity.k*f; %перевод частота -> скорость
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
            %открытие экспериментальных файлов
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

