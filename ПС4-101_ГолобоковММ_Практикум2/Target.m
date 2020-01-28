classdef Target < handle
    %Класс описывающий движение цели
    properties
        X0      %начальный вектор состояния цели (x,vx)
        V       %массив скоростей на 3х участках
        dT      %шаг моделирования
        T
        Z       %вектор наблюдений РЛС
    end
    methods
        function obj = Target(dT,T,x0,vx1,vx2,vx3)
            %конструктор класса создающий объект цели и скорости на 3
            %участках
            obj.dT = dT;            %шаг моделирования
            obj.T = T;              %время моделирования
            obj.X0 = [x0 vx1].';    %начальный вектор состояния
            obj.V = [vx1,vx2,vx3];  %сохранение скоростей
        end
        function move(obj)
            %метод изменяющий вектор состояния цели в течение времени
            %моделирования
            F = [   1   obj.dT; %матрица перехода вектора состояния
                0   1];
            X = obj.X0; %начальное состояние
            for ii = obj.dT:obj.dT:obj.T
                %if ii < 3 % ничего не делать т.к. уже
                %end
                if ii >=3 && ii < 6 %второй участок модели
                    X(2,end) = obj.V(2); %изменение скорости цели
                end
                if ii >=6 %третий участо модели
                    X(2,end) = obj.V(3);
                end
                X(:,end+1) = F*X(:,end);
            end
            obj.Z = X;
        end
        function out = getZ(obj,type)
            %сохранение результата для последующей обработки
            switch type
                case {'velocity'}
                    out = obj.Z(2,:);
                case {'range'}
                    out = obj.Z(1,:);
                otherwise
                    out = zeros(1,fix(obj.T,obj.dT));
            end
        end
        function show(obj,type)
            %отображение результатов моделирования траектории
            if ~isempty(obj.Z)
                t = 0:obj.dT:obj.T;
                switch type
                    case {'velocity'}
                        x = obj.getZ(type);
                        plot(t,x)
                        grid on;
                        xlabel('time, s');
                        ylabel('x, m/s');
                        ylim([-max(x)*1.25 max(x)*1.25]);
                        title('График Скорость-Время');
                    case {'range'}
                        x = obj.getZ(type);
                        plot(t,x)
                        grid on;
                        xlabel('time, s');
                        ylabel('x, m');
                        ylim([0 max(x)*1.25]);
                        title('График Дальность-Время');
                    otherwise
                        fprintf(2,'no type\n');
                end
            end
        end
    end
end

