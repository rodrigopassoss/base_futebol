%% Caso do Video
% Caminho do arquivo de v�deo
caminhoVideo = 'C:\Users\rodri\Documents\Vis�o Computacional\projeto_final\base_futebol\jogo.mp4';
% Cria um objeto VideoFileReader
CameraData = vision.VideoFileReader(caminhoVideo, 'PlayCount', Inf);
% Cria uma janela para exibir o v�deo
hFig = figure;
hAx = axes;



calibra_camera
%% Caso da WebCam

