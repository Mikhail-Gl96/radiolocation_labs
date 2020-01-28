classdef Detector < handle
    %класс обнаружител€ сигналов
    properties
        Pfa %веро€тность ложной тревоги
        kTh %коэфф. настройки порога
        thr %рассчитанный порог
        Detections  %массив обнаружений
    end
    
    methods
        function obj = Detector
            %пустой конструктор
        end
        function det = detectConstTh(obj,signal)
            %обнаружение сигнала
            %расчет порога
            obj.thr = obj.threshold(signal(:,end));
            det = signal > obj.thr;
            obj.Detections = det;
        end
        function thr = threshold(obj,s)
            %оценка величины порога
            noise_pwr = var(s(:))/(2-pi/2); %мощность шумов
            %порог обнаружени€
            thr = sqrt(-2*obj.kTh*log(obj.Pfa)*noise_pwr);
        end
        function measure(obj,data,ranges,coords,type)
            %формирование оценок обнаружений
            if nargin < 5
                type = ''; %не определ€ть названи€
            end
            switch type
                case {'range'}
                    s1 = 'ƒальность до цели = ';
                    s2 = ' м';
                case {'velocity'}
                    s1 = '—корость цели = ';
                    s2 = ' м/с';
                otherwise
                    s1 = '';
                    s2 = '';
            end
            rows = coords(2); %по оси ќy
            cols = coords(1)-5:coords(1)+5;
            ampl = data(rows,cols); %амплитуды обнаруженного сигнала
            rdet = ranges(cols); %диапазон дальностей обнаруженного сигнала
            rest = sum(ampl.*rdet)/sum(ampl); %весова€ оценка дальности
            msgbox([s1 num2str(rest) s2]);

            %отображение результатов обнаружени€
            figure;
            %отображение сигнала
            plot(ranges,data(rows,:));
            xlabel(s2);
            ylabel('ampl, popugai');
            hold on;grid on;
            %отображение порога
            line(xlim,[obj.thr obj.thr],'color','red');
            plot(ranges,2*obj.thr*obj.Detections(rows,:));
            title('сигнал, порог, области обнаружени€');
            legend('сигнал', 'порог', 'области обнаружени€');
        end
    end
    
end

