classdef Focusing < handle
    %������ ������ ���
    
    properties
        %         f0  %������� ������� �������
        %         fs  %������� �������������
        %         Tr  %������ ����������
        filename   %������ �������
        %         k   %��������� ��� �������� ������� � ���������
    end
    
    methods
        function obj = Focusing
            %����������� ������, �.�. �������� ������� ������
            [fn,ph] = uigetfile('*.mat');
            obj.filename = [ph,fn];
            %             obj.fs = 44100; %������� ������������� �������� �����
            %             obj.Tr = 2.2e-2; %������ ���������� � ���
        end
        function conv(obj)
            %������ ����� � �������� �� ��������� T
            %             [Y,obj.fs] = audioread(obj.filename);
            %% ��������� ��������� ������, ���������� � ������� ������������� ������
            %�������� ������ ��� ���������� ��� �����������, ����������� ����������
            %������������� ������ � ��������
            %------------------------------------------------------------------------%
            tic;
            load(obj.filename,'sif');                 % �������� ��������� ����������� �������
            c = 3E8;                            %(�/�) �������� �����
            fc = (2590E6 - 2260E6)/2 + 2260E6;  %(��) ����������� ������� ������ ���
            B = (2590E6 - 2260E6);              %(��) ������ �������
            cr = B/20E-3;                       %(��/���) �������� ���������� �������
            Tp = 20E-3;                         %(���) ������������ ������������ ��������
            Rs = 0;                     %(�) ���������� �� ������ ����������� �� ����������� ����������
            % ������������� ����� ��� ��� ���������� ��
            % ������� ����������
            dx = 0.05;                  %(�) ���������� ����� ���������� ��������������� �������
            Na = size(sif,1);           % ����� ��������� �������������� �� ������������ ����������
            Nf = size(sif,2);           % ����� �������� �� ����������� ����������
            L = dx*Na;                  %(�) ����� ��������������� �������� �������
            Za = 0;                     %(�) ��������� ���������� ������ �������
            Ya = Rs;                    %(�) ��������� ����������� ���������� ������� ���
            xpad = 2048;                % "���������" ������������ ���������� ��� ����,
            % ����� ���� ����� ������������
            rpad = 1024;                % ����� ����� � ����������� �����������
            k = 1;                      % ���������� ������� ���
            
            cr1 = -4;      %(�) ����� ������� ������� �� ������������ ����������
            cr2 = 4;       %(�) ������ ������� ������� �� ������������ ����������
            dr1 = 1+Rs;     %(�) ������� ������� ������� �� ����������� ����������
            dr2 = 10+Rs;   %(�) ������� ������� ������� �� ����������� ����������
            
            %(�) ������������ ��������� �������� ������������ ��������
            t = linspace(0, Tp, Nf);
            %(�) ������������ ������������ ���������� ���
            Xa = linspace(-L/2, L/2, Na).';
            %(���/�) ������������ �������� ����� �� ������������ ����������
            Kx = linspace(-pi/dx,pi/dx,xpad).';
            Kx = repmat(Kx,1,Nf);
            %(���/�) ������������ �������� ����� �� ����������� ����������
            freq = linspace((fc - B/2),(fc + B/2),Nf);
            Kr = 4*pi*freq/c;
            Kr=repmat(Kr,xpad,1);
            
            %% �������� "��������������" �����������
            %sif=sif.*exp(1j*Rs*Kr);
            
            %data_compr=fftshift(ifft(sif,[],2),2);
            %imagesc(abs(data_compr));
            
            %% ��������� ���� �������� � �������� ������ � �������
            % ���������� ������� ������� ��������
            % for ii = 1:Nf
            %     H(ii) = 0.5 + 0.5*cos(2*pi*(ii-Nf/2)/Nf);
            % end
            % H = repmat(H,Na,1);
            H = hamming(size(sif,2));
            H = repmat(H',size(sif,1),1);
            
            % ���������� ������ ������� � �������� ������
            sif = sif.*H;
            
            %% �������� �������� ���������
            % ����������� ���������� ������, ��� ����� ������������ ������������
            % ���������� ��������� �����
            szeros = zeros(xpad, Nf);
            for ii = 1:Nf
                index = round((xpad - Na)/2);
                szeros(index+1:(index + Na),ii) = sif(:,ii); %symetrical zero pad
            end
            sif = szeros;
            clear ii index szeros;
            
            % data_compr=fftshift(ifft(sif,[],2),2);
            % imagesc(abs(data_compr));
            
            %% ���� �1. ������������ ���
            S = fftshift(fft(sif, [], 1), 1);
            clear sif;
            
            % data_compr=fftshift(ifft(S,[],2),2);
            % imagesc(abs(data_compr));
            
            %% ���� �2. ������������� ����������
            %% ��������� �������������� ������� eq 10.8
            
            Ky_sq = Kr.^2-Kx.^2;
            Neg=logical(Ky_sq < 0); %
            Ky_sq(Neg)=NaN; S(Neg)=NaN; Kr(Neg)=NaN; %����� ����� ������ ������������� ��������
            Ky = sqrt(Ky_sq);
            Fmf=-Rs.*Kr+Rs.*Ky;
            %mesh(Kr,Kx,Fmf);
            %���������� ������������� ���������� � ��������������� �������
            S_mf = S.*exp(1j*Fmf);
            clear S Fmf Ky_sq Neg;
            
            % data_compr=fftshift(fft(S_mf,[],2),2);
            % imagesc(abs(data_compr));
            
            %% ���� �3. ������������ ������
            kstart = 73;
            kstop = 108.5;
            
            Ky_int=linspace(kstart,kstop,rpad);         %��������� ����������������� ������� ����������
            S_st= obj.stolt_int(Ky,S_mf,Ky_int,'linear');   %1D ������������
            Empty = isnan(S_st);
            S_st(Empty) = 1e-30;
            
            %imagesc(Ky_int,Kx(1,:),angle(S_st));
            clear Kr Kx Ky_int S_mf Empty;
            
            %% ���� �4. �������� ��������� �������������� ������������ ������
            % �������� ������:  v(x,y), ��� x - ����������� ����������
            % ������ �� ����������� ���������� � ����������� ������� ��������������
            % � k ���
            bw = 3E8*(kstop-kstart)/(4*pi); %����������� ��������������� ������ �������
            max_range = (3E8*rpad/(2*bw));  %����������� ������������ ��������� (???)
            
            S_image = ifft2(S_st,xpad*k,rpad*k);
            S_image = fliplr(rot90(S_image));   %������ (1) - ���������, ������� (2) - ������
            
            % ���������� �������� ��� ������� ����������� �������
            dr_index1 = round((dr1/max_range)*size(S_image,1));
            dr_index2 = round((dr2/max_range)*size(S_image,1));
            cr_index1 = round(((cr1+xpad*dx/2)/(xpad*dx))*size(S_image,2));
            cr_index2 = round(((cr2+xpad*dx/2)/(xpad*dx))*size(S_image,2));
            
            % ������� ������ �� �������
            trunc_image = S_image(dr_index1:dr_index2,cr_index1:cr_index2);
            clear S_image;
            
            % �������� ���� ��� ���������� ��������
            % ������������ ����������� ���������
            downrange = linspace(-1*dr1,-1*dr2, size(trunc_image,1)) + Rs;
            % ������������ ������������ ���������
            crossrange = linspace(cr1, cr2, size(trunc_image, 2));
            
            %����������� �������� � ����������� �� ���������
            %scale down range columns by range^(3/2), delete to make like
            clear ii;
            for ii = 1:size(trunc_image,2)
                trunc_image(:,ii) = (trunc_image(:,ii)').*(abs(downrange)).^2;
            end
            
            % ���������� �������� �����������
            trunc_image = dbv(trunc_image);
            imagesc(crossrange, downrange, trunc_image, [max(max(trunc_image))-15, max(max(trunc_image))-0]);
            colormap('default');
            title('��� �����������');
            ylabel('����������� ���������� (�)');
            xlabel('������������ ���������� (�)');
            axis equal;
            cbar = colorbar;
            set(get(cbar, 'Title'), 'String', '��','fontsize',13);
            toc;
        end
        function [ yy ] = stolt_int(obj,X,Y,xx, method )
            %STOLT_INT ������������� �������� Y �� ��������� @ xx. X ��������������
            %������ �������� �������
            
            xx_row = size(xx,1);
            if xx_row == 1, %xx - ������� ������
                xx=xx.';X=X.';Y=Y.';
            end
            
            Y_col=size(Y,2); %����� ��������
            yy=zeros(length(xx),Y_col);
            
            for i=1:Y_col
                yy(:,i)=interp1( X(:,i),Y(:,i),xx,method ); %��������������� �������
            end
            
            if xx_row == 1, %�������� ���������������� �����������
                yy=yy.';
            end
            
        end
    end
end

