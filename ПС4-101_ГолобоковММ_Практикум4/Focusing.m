classdef Focusing < handle
    %Сжатие данных РСА
    
    properties
        %         f0  %рабочая частота сигнала
        %         fs  %частота дискретизации
        %         Tr  %период повторения
        filename   %запись сигнала
        %         k   %константа для персчета частоты в дальность
    end
    
    methods
        function obj = Focusing
            %конструктор класса, т.е. создание объекта класса
            [fn,ph] = uigetfile('*.mat');
            obj.filename = [ph,fn];
            %             obj.fs = 44100; %частота дискретизации звуковой карты
            %             obj.Tr = 2.2e-2; %период повторения в сек
        end
        function conv(obj)
            %чтение файла и разбивка на интервалы T
            %             [Y,obj.fs] = audioread(obj.filename);
            %% Программа обработки данных, записанных с помощью лабораторного стенда
            %Загрузка данных для построения РСА изображения, определение параметров
            %лабораторного стенда и констант
            %------------------------------------------------------------------------%
            tic;
            load(obj.filename,'sif');                 % загрузка квадратур отраженного сигнала
            c = 3E8;                            %(м/с) скорость света
            fc = (2590E6 - 2260E6)/2 + 2260E6;  %(Гц) центральная частота макета РЛС
            B = (2590E6 - 2260E6);              %(Гц) полоса сигнала
            cr = B/20E-3;                       %(Гц/сек) скорость наростания сигнала
            Tp = 20E-3;                         %(сек) длительность зондирующего импульса
            Rs = 0;                     %(м) расстояние до центра изображения по дальностной координате
            % рекомендуется брать его как расстояние до
            % объекта калибровки
            dx = 0.05;                  %(м) расстояние между элементами синтезированной антенны
            Na = size(sif,1);           % число элементов синтезирования по азимутальной координате
            Nf = size(sif,2);           % число отсчетов по дальностной координате
            L = dx*Na;                  %(м) длина синтезированной апертуры антенны
            Za = 0;                     %(м) начальная координата высоты антенны
            Ya = Rs;                    %(м) начальная дальностная координата антенны РСА
            xpad = 2048;                % "подстилка" азимутальной координаты для того,
            % чтобы было видно закручивание
            rpad = 1024;                % число точке в дальностном направлении
            k = 1;                      % расширение области БПФ
            
            cr1 = -4;      %(м) левая сторона области по азимутальной координате
            cr2 = 4;       %(м) правая сторона области по азимутальной координате
            dr1 = 1+Rs;     %(м) ближняя сторона области по дальностной координате
            dr2 = 10+Rs;   %(м) дальняя сторона области по дальностной координате
            
            %(с) пространство временных отсчетов зондирующего импульса
            t = linspace(0, Tp, Nf);
            %(м) пространство азимутальной координаты РСА
            Xa = linspace(-L/2, L/2, Na).';
            %(рад/м) пространство волновых чисел по азимутальной координате
            Kx = linspace(-pi/dx,pi/dx,xpad).';
            Kx = repmat(Kx,1,Nf);
            %(рад/м) пространство волновых чисел по дальностной координате
            freq = linspace((fc - B/2),(fc + B/2),Nf);
            Kr = 4*pi*freq/c;
            Kr=repmat(Kr,xpad,1);
            
            %% Операция "расскручивания" изображения
            %sif=sif.*exp(1j*Rs*Kr);
            
            %data_compr=fftshift(ifft(sif,[],2),2);
            %imagesc(abs(data_compr));
            
            %% Наложение окна Хемминга к исходным данным к строкам
            % построение оконной функции Хемминга
            % for ii = 1:Nf
            %     H(ii) = 0.5 + 0.5*cos(2*pi*(ii-Nf/2)/Nf);
            % end
            % H = repmat(H,Na,1);
            H = hamming(size(sif,2));
            H = repmat(H',size(sif,1),1);
            
            % Применение оконой функции к исходным данным
            sif = sif.*H;
            
            %% Алгоритм миграции дальности
            % Располагаем записанные данные, так чтобы сымитировать закручивание
            % траекторий блестящих точек
            szeros = zeros(xpad, Nf);
            for ii = 1:Nf
                index = round((xpad - Na)/2);
                szeros(index+1:(index + Na),ii) = sif(:,ii); %symetrical zero pad
            end
            sif = szeros;
            clear ii index szeros;
            
            % data_compr=fftshift(ifft(sif,[],2),2);
            % imagesc(abs(data_compr));
            
            %% Этап №1. Азимутальное БПФ
            S = fftshift(fft(sif, [], 1), 1);
            clear sif;
            
            % data_compr=fftshift(ifft(S,[],2),2);
            % imagesc(abs(data_compr));
            
            %% Этап №2. Согласованная фильтрация
            %% Генерация согласованного фильтра eq 10.8
            
            Ky_sq = Kr.^2-Kx.^2;
            Neg=logical(Ky_sq < 0); %
            Ky_sq(Neg)=NaN; S(Neg)=NaN; Kr(Neg)=NaN; %смысл имеют только положительные значения
            Ky = sqrt(Ky_sq);
            Fmf=-Rs.*Kr+Rs.*Ky;
            %mesh(Kr,Kx,Fmf);
            %Применение согласованной фильтрации к обрабатываемому сигналу
            S_mf = S.*exp(1j*Fmf);
            clear S Fmf Ky_sq Neg;
            
            % data_compr=fftshift(fft(S_mf,[],2),2);
            % imagesc(abs(data_compr));
            
            %% Этап №3. Интерполяция Столта
            kstart = 73;
            kstop = 108.5;
            
            Ky_int=linspace(kstart,kstop,rpad);         %генерация интерполяционного вектора аргументов
            S_st= obj.stolt_int(Ky,S_mf,Ky_int,'linear');   %1D интерполяция
            Empty = isnan(S_st);
            S_st(Empty) = 1e-30;
            
            %imagesc(Ky_int,Kx(1,:),angle(S_st));
            clear Kr Kx Ky_int S_mf Empty;
            
            %% Этап №4. Обратное двумерное преобразование обработанных данных
            % Выходной сигнал:  v(x,y), где x - дальностная координата
            % Сжатие по дальностной координате с расширением области преобразования
            % в k раз
            bw = 3E8*(kstop-kstart)/(4*pi); %определение задействованной полосы сигнала
            max_range = (3E8*rpad/(2*bw));  %определение максимальной дальности (???)
            
            S_image = ifft2(S_st,xpad*k,rpad*k);
            S_image = fliplr(rot90(S_image));   %строки (1) - дальность, столбцы (2) - азимут
            
            % нахождение индексов для обрезки исследуемой области
            dr_index1 = round((dr1/max_range)*size(S_image,1));
            dr_index2 = round((dr2/max_range)*size(S_image,1));
            cr_index1 = round(((cr1+xpad*dx/2)/(xpad*dx))*size(S_image,2));
            cr_index2 = round(((cr2+xpad*dx/2)/(xpad*dx))*size(S_image,2));
            
            % вырезка данных из массива
            trunc_image = S_image(dr_index1:dr_index2,cr_index1:cr_index2);
            clear S_image;
            
            % создание осей для вырезанных областей
            % пространство дальностных координат
            downrange = linspace(-1*dr1,-1*dr2, size(trunc_image,1)) + Rs;
            % пространство азимутальных координат
            crossrange = linspace(cr1, cr2, size(trunc_image, 2));
            
            %компенсация мощности в зависимости от дальности
            %scale down range columns by range^(3/2), delete to make like
            clear ii;
            for ii = 1:size(trunc_image,2)
                trunc_image(:,ii) = (trunc_image(:,ii)').*(abs(downrange)).^2;
            end
            
            % построение искомого изображения
            trunc_image = dbv(trunc_image);
            imagesc(crossrange, downrange, trunc_image, [max(max(trunc_image))-15, max(max(trunc_image))-0]);
            colormap('default');
            title('РСА изображение');
            ylabel('Дальностная координата (м)');
            xlabel('Азимутальная координата (м)');
            axis equal;
            cbar = colorbar;
            set(get(cbar, 'Title'), 'String', 'дБ','fontsize',13);
            toc;
        end
        function [ yy ] = stolt_int(obj,X,Y,xx, method )
            %STOLT_INT интерполирует значения Y по аргументу @ xx. X первоначальный
            %вектор значений функции
            
            xx_row = size(xx,1);
            if xx_row == 1, %xx - векртор строка
                xx=xx.';X=X.';Y=Y.';
            end
            
            Y_col=size(Y,2); %число столбцов
            yy=zeros(length(xx),Y_col);
            
            for i=1:Y_col
                yy(:,i)=interp1( X(:,i),Y(:,i),xx,method ); %инетрполирующая функция
            end
            
            if xx_row == 1, %обратное транспонирование результатов
                yy=yy.';
            end
            
        end
    end
end

