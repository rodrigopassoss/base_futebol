clc
clear all
close all

%% Configuracao + Calibração
configura_camera
%% Normalização RGB
while 1
    tic
    % Obtem frame da camera
    get_frame
    
    % frame_cortado = frame_cortado(1:2:length(frame_cortado),1:2:length(frame_cortado),:);
    R1 = frame_cortado(:,:,1); G1 = frame_cortado(:,:,2); B1 = frame_cortado(:,:,3);
    frame_normalizado = (frame_cortado.^2)./(sqrt(R1.^2 + G1.^2 + B1.^2));
    R2 = frame_normalizado(:,:,1); G2 = frame_normalizado(:,:,2); B2 = frame_normalizado(:,:,3);
    


    %% Filtragem dos tons de cinza
    limiar = 45;
    M = ((abs(G2-R2)>limiar) & (abs(B2-R2)>limiar))...
       |((abs(R2-G2)>limiar) & (abs(B2-G2)>limiar))...
       |((abs(R2-B2)>limiar) & (abs(G2-B2)>limiar));

    frame_filtrado = frame_normalizado.*(double(M));
    


    %% Conversão para HSV
    frame_hsv = rgb2hsv(frame_filtrado);
    Hue = frame_hsv(:,:,1)*255;
    Value = frame_hsv(:,:,3)*255;

    %% Segmentação
    % 1 - vermelho
    % 2 - laranja
    % 3 - Amarelo
    % 4 - Verde
    % 5 - Azul
    % 6 - Magenta
    Pivots = 127*([0 20 45 86 160 225]-127)/127;
    Hue = 127*(Hue-127)/127;
    % Vermelho
    diff = abs(mod((Hue-Pivots(1))+127,2*127)-127);
    Vermelho = imopen((diff < 5)&M, ones(5,5));
    [y x] = find(Vermelho);
    [idx, Vermelho_centros] = kmeans([x(1:10:end) y(1:10:end)],2);

    % laranja
    diff = abs(mod((Hue-Pivots(2))+127,2*127)-127);
    laranja = imopen((diff < 10)&M, ones(5,5));
    [y x] = find(laranja);
    [idx, laranja_centro] = kmeans([x(1:10:end) y(1:10:end)],1);

    % Amarelo
    diff = abs(mod((Hue-Pivots(3))+127,2*127)-127);
    amarelo = imopen((diff < 10)&M, ones(5,5));
    [y x] = find(amarelo);
    [idx, amarelo_centros] = kmeans([x(1:10:end) y(1:10:end)],3);
    % verde
    diff = abs(mod((Hue-Pivots(4))+127,2*127)-127);
    verde = imopen((diff < 10)&M, ones(5,5));
    [y x] = find(verde);
    [idx, verde_centros] = kmeans([x(1:10:end) y(1:10:end)],6);
    % Azul
    diff = abs(mod((Hue-Pivots(5))+127,2*127)-127);
    azul = imopen((diff < 10)&M, ones(5,5));
    [y x] = find(azul);
    [idx, azul_centros] = kmeans([x(1:10:end) y(1:10:end)],3);
    % magenta
    diff = abs(mod((Hue-Pivots(6))+127,2*127)-127);
    magenta = imopen((diff < 15)&M, ones(5,5));
    [y x] = find(magenta);
    [idx, magenta_centros] = kmeans([x(1:10:end) y(1:10:end)],4);

    plot_online
    
    t = toc;
    text(30,30,['FPS = ',num2str(round(1/t))]);
    drawnow;

    display(round(1/t))
end


%% Funçães Auxiliares
function [hist,edges] = histg(im);
    [lin,col]=size(im);
    for k = 1:256
       hist(k) = numel(find(round(im)==(k-1)));
    end
    hist = hist/(lin*col);
    edges = [1:256]-1;
end
function [hist] = histg2(im,MiN,MaX);
    [lin,col]=size(im);
    for k = MiN:MaX
       hist(k+1) = numel(find(im==k));
    end
    hist = hist/(lin*col);
end
function [imSeg,Reg] = segmentador(im,limiar);
    imSeg =  bwlabel(im);
    [hist] = histg2(imSeg,min(imSeg(:)),max(imSeg(:)));
    Reg = find(hist>limiar)-1;
end


