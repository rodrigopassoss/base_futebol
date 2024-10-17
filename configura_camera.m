%% Caso do Video
% Caminho do arquivo de vídeo
caminhoVideo = 'C:\Users\rodri\Documents\Visão Computacional\projeto_final\base_futebol\jogo.mp4';
% Cria um objeto VideoFileReader
CameraData = vision.VideoFileReader(caminhoVideo, 'PlayCount', Inf);
% Cria uma janela para exibir o vídeo
hFig = figure;
hAx = axes;



calibra_camera
%% Caso da WebCam

