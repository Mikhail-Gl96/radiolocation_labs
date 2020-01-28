classdef Antenna < handle
    %Сжатие данных РСА
    properties
        
        dna7        %ДНА по формуле 7
        dna8        %ДНА по формуле 8
        dna9        %ДНА, смещенная по формуле 9
        dna10       %ДНА, смещенная по формуле 10
        dnaSAR      %ДНА, по формуле 14 для РСА
        
        N           %число излучателей
        lambda      %рабочая длина волны
        d           %шаг антенной решетки
        theta       %сетка углов
    end
    
    methods
        function obj = Antenna(M_in, d_in, lambda_in)
            %конструктор класса, т.е. создание объекта класса
            obj.N = (M_in-1)/2; %найти, согласно варианту
            obj.lambda = lambda_in; %рабочая длина волны
            obj.d = d_in;
            obj.theta = linspace(-pi/3,pi/3,720); %сетка направлений (углов)
        end
        function out = form7(obj)
            %Формирование ДН по формуле 7 мет. ук.
            fc = 3e8/obj.lambda; %рабочая частота
            t = 0; v0 = 1; r0 = 1;
            Em = v0/r0*exp(1j*2*pi*fc*t)*exp(-1j*2*pi*r0/obj.lambda);
            k = -obj.N:obj.N; %номера излучающих элементов
            obj.dna7 = Em*sum(exp(1j*2*pi*k.'*obj.d*sin(obj.theta)/obj.lambda),1);
            out = obj.dna7;
        end
        function out = form9(obj,theta_s)
            %Формирование ДН по формуле 9 мет. ук.
            if nargin < 2
                theta_s = 0; %в градусах
            end
            M = 2*obj.N+1; %колво элементов решетки(линейная антенная решетка)
            fc = 3e8/obj.lambda; %рабочая частота
            t = 0; v0 = 1; r0 = 1;
            Em = v0/r0*exp(1j*2*pi*fc*t)*exp(-1j*2*pi*r0/obj.lambda);
            k = -obj.N:obj.N; %номера излучающих элементов
            out = Em*sum(exp(-1j*2*pi*k.'*obj.d*sin(obj.theta)/obj.lambda), 1); %реализовать самостоятельно
            obj.dna9=out;
        end
        
        function out = form8(obj)
            %Формирование ДН по формуле 8 мет. ук.
            M = 2*obj.N+1; %колво элементов решетки(линейная антенная решетка)
            obj.dna8 = 1/M^2*(sin(M*pi*obj.d/obj.lambda*sin(obj.theta))./sin(pi*obj.d/obj.lambda*sin(obj.theta))).^2;   %реализовать самостоятельно
            out = obj.dna8;
        end
        function out = form10(obj,theta_s)
            %Формирование ДН по формуле 10 мет. ук.
            if nargin < 2
                theta_s = 0; %в градусах
            end
            M = 2*obj.N+1; %колво элементов решетки(линейная антенная решетка)
            obj.dna10 = 1/M^2*(sin(M*pi*obj.d/obj.lambda*(sin(obj.theta)-sin(deg2rad(theta_s))))./...
                sin(pi*obj.d/obj.lambda*(sin(obj.theta)-sin(deg2rad(theta_s))))).^2;
            out = cos(obj.theta).*obj.dna10;
            obj.dna10=out;
        end
        function out = form14(obj,theta_s)
            %Формирование ДН по формуле 10 мет. ук.
            if nargin < 2
                theta_s = 0; %в градусах
            end
            Pc = 1;
            r0c = 1;
            M = 2*obj.N+1; %колво элементов решетки(линейная антенная решетка)
            obj.dnaSAR = sqrt(Pc/r0c^2)/M^2*(sin(2*M*pi*obj.d/obj.lambda*(sin(deg2rad(theta_s))-sin(obj.theta)))./...
                sin(2*pi*obj.d/obj.lambda*(sin(deg2rad(theta_s))-sin(obj.theta)))).^2;
            out = obj.dnaSAR;
        end
        
        function showDNA(obj,what)
            %отображение несмещенных ДНА
            figure;
            ha = axes;
            hold on; grid on;
            ylim([0 1]);
            xlabel('angle,deg');
            ylabel('amplitude');
            legendTitles = {};
            for ii = 1:length(what)
                w = what{ii};
                switch w
                    case    {'7'}
                        plot(rad2deg(obj.theta),abs(obj.dna7));
                        legendTitles{end+1} = 'ф.7';
                    case    {'8'}
                        plot(rad2deg(obj.theta),abs(obj.dna8));
                        legendTitles{end+1} = 'ф.8';
                    case    {'9'}
                        plot(rad2deg(obj.theta),abs(obj.dna9));
                        legendTitles{end+1} = 'ф.9';
                    case    {'10'}
                        plot(rad2deg(obj.theta),abs(obj.dna10));
                        legendTitles{end+1} = 'ф.10';
                    case    {'14'}
                        plot(rad2deg(obj.theta),abs(obj.dnaSAR));
                        legendTitles{end+1} = 'ф.14 (SAR)';
                    otherwise
                        fprintf(2,'no data ot plot\n');
                end
            end
            legend(legendTitles);
        end
    end
end

