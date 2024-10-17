clc
clear all
close all

%% Abre a imagem
frame = imread('base_futebol\0.jpg');
campo = imread('base_futebol\no_robots.jpg');
%% Aplicar o corte da imagem - Calibração
load('Transformacao_da_imagem.mat')
frame_cortado(i_,j_,:) = double(frame(Y_(2,:),Y_(1,:),:));
%% Normalização RGB
tic
% frame_cortado = frame_cortado(1:2:length(frame_cortado),1:2:length(frame_cortado),:);
R1 = frame_cortado(:,:,1); G1 = frame_cortado(:,:,2); B1 = frame_cortado(:,:,3);
frame_normalizado = (frame_cortado.^2)./(sqrt(R1.^2 + G1.^2 + B1.^2));
R2 = frame_normalizado(:,:,1); G2 = frame_normalizado(:,:,2); B2 = frame_normalizado(:,:,3);
toc
%% Plot parcial 1 - Ilustração do Efeito da Normalização
colors = [R1(:) G1(:) B1(:)];
colors = round(colors(1:5:end,:))./255;
figure(1)
subplot(221)
title('Sem Normalização')
grid on; hold on
scatter3(colors(:,1),colors(:,2),colors(:,3),10,colors,'filled');
xlabel('R');ylabel('G');zlabel('B');
subplot(222)
grid on; hold on
scatter(colors(:,1),colors(:,2),10,colors,'filled');
xlabel('R');ylabel('G');
subplot(223)
grid on; hold on
scatter(colors(:,1),colors(:,3),10,colors,'filled');
xlabel('R');ylabel('B');
subplot(224)
grid on; hold on
scatter(colors(:,3),colors(:,2),10,colors,'filled');
xlabel('B');ylabel('G');

colors = [R2(:) G2(:) B2(:)];
colors = round(colors(1:5:end,:))./255;
figure(2)
subplot(221)
title('Com Normalização')
grid on; hold on
scatter3(colors(:,1),colors(:,2),colors(:,3),10,colors,'filled');
xlabel('R');ylabel('G');zlabel('B');
subplot(222)
grid on; hold on
scatter(colors(:,1),colors(:,2),10,colors,'filled');
xlabel('R');ylabel('G');
subplot(223)
grid on; hold on
scatter(colors(:,1),colors(:,3),10,colors,'filled');
xlabel('R');ylabel('B');
subplot(224)
grid on; hold on
scatter(colors(:,3),colors(:,2),10,colors,'filled');
xlabel('B');ylabel('G');


figure(3)
subplot(221)
hold on
title('Sem Normalização')
imshow(uint8(frame_cortado));
subplot(222)
[histograma,edges] = histg(R1);
bar(edges, histograma, 'r');
subplot(223)
[histograma,edges] = histg(G1);
bar(edges, histograma, 'g');
subplot(224)
[histograma,edges] = histg(B1);
bar(edges, histograma, 'b');

figure(4)
subplot(221)
hold on
title('Com Normalização')
imshow(uint8(frame_normalizado));
subplot(222)
[histograma,edges] = histg(R2);
bar(edges, histograma, 'r');
subplot(223)
[histograma,edges] = histg(G2);
bar(edges, histograma, 'g');
subplot(224)
[histograma,edges] = histg(B2);
bar(edges, histograma, 'b');


%% Filtragem dos tons de cinza
tic
limiar = 40;
M = ((abs(G2-R2)>limiar) & (abs(B2-R2)>limiar))...
   |((abs(R2-G2)>limiar) & (abs(B2-G2)>limiar))...
   |((abs(R2-B2)>limiar) & (abs(G2-B2)>limiar));

frame_filtrado = frame_normalizado.*(double(M));
toc



%% Conversão para HSV
tic
frame_hsv = rgb2hsv(frame_filtrado);
Hue = frame_hsv(:,:,1)*255;
Value = frame_hsv(:,:,3)*255;
toc

%% Plot parcial 2 - Ilustração do Filtro de tons de cinza e o HSV

figure(5)
subplot(121)
title('Antes do Filtro')
hold on
imshow(uint8(frame_normalizado));
subplot(122)
title('Depois do Filtro')
hold on
imshow(uint8(frame_filtrado));

% figure
% imshow(uint8(frame_hsv(:,:,1)*255))
[histograma,edges] = histg(Hue);
figure(6)
subplot(223)
hold on
title('HSV - Hue (Depois do Filtro)')
imshow(uint8(Hue));
subplot(224)
title('Hue - Histograma')
hBars = bar(edges, histograma);
hsv_palette(:, 1) = linspace(0, 1, numel(edges)); % Variação de tonalidade
hsv_palette(:, 2) = 0.8; % Saturação constante
hsv_palette(:, 3) = 1;   % Valor constante
% Converter a paleta HSV para RGB
rgb_palette = hsv2rgb(hsv_palette);
% Aplicar a paleta de cores a cada barra
set(hBars,'XData',edges,'YData',histograma,'FaceColor','flat','CData',rgb_palette)
ylim([0 5e-4])
subplot(221)
Hue_ = rgb2hsv(frame_normalizado);
Hue_ = Hue_(:,:,1)*255;
[histograma,edges] = histg(Hue_);
hold on
title('HSV - Hue (Antes do Filtro)')
imshow(uint8(Hue_));
subplot(222)
title('Hue - Histograma')
hBars = bar(edges, histograma);
hsv_palette(:, 1) = linspace(0, 1, numel(edges)); % Variação de tonalidade
hsv_palette(:, 2) = 0.8; % Saturação constante
hsv_palette(:, 3) = 1;   % Valor constante
% Converter a paleta HSV para RGB
rgb_palette = hsv2rgb(hsv_palette);
% Aplicar a paleta de cores a cada barra
set(hBars,'XData',edges,'YData',histograma,'FaceColor','flat','CData',rgb_palette)
% Aplicar a paleta de cores ï¿½s barras
% colormap(rgb_palette);
% colorbar
% ylim([0 1e-4])

%% Segmentação
% 1 - vermelho
% 2 - laranja
% 3 - Amarelo
% 4 - Verde
% 5 - Azul
% 6 - Magenta
tic

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

toc

figure(7)
imshow(uint8(frame_cortado));
raio = 10;
rectangle('Position', [Vermelho_centros(1,:) - raio, 2 * raio, 2 * raio], ...
          'Curvature', [1, 1], 'EdgeColor', 'r', 'LineWidth', 3);
rectangle('Position', [Vermelho_centros(2,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'r', 'LineWidth', 3);
rectangle('Position', [laranja_centro - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'y', 'LineWidth', 3);
rectangle('Position', [magenta_centros(1,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'm', 'LineWidth', 3);
rectangle('Position', [magenta_centros(2,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'm', 'LineWidth', 3);
rectangle('Position', [magenta_centros(3,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'm', 'LineWidth', 3);
rectangle('Position', [magenta_centros(4,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'm', 'LineWidth', 3);
rectangle('Position', [amarelo_centros(1,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'y', 'LineWidth', 3);
rectangle('Position', [amarelo_centros(2,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'y', 'LineWidth', 3);
rectangle('Position', [amarelo_centros(3,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'y', 'LineWidth', 3);
rectangle('Position', [verde_centros(1,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 3);
rectangle('Position', [verde_centros(2,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 3);
rectangle('Position', [verde_centros(3,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 3);
rectangle('Position', [verde_centros(4,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 3);
rectangle('Position', [verde_centros(5,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 3);
rectangle('Position', [verde_centros(6,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 3);
rectangle('Position', [azul_centros(1,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'b', 'LineWidth', 3);
rectangle('Position', [azul_centros(2,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'b', 'LineWidth', 3);
rectangle('Position', [azul_centros(3,:) - raio, 2 * raio, 2 * raio], ...
  'Curvature', [1, 1], 'EdgeColor', 'b', 'LineWidth', 3);

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


