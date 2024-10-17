% Caminho do arquivo de vídeo
caminhoVideo = 'jogo.mp4';

% Cria um objeto VideoFileReader
videoFileReader = vision.VideoFileReader(caminhoVideo, 'PlayCount', Inf);

% Cria uma janela para exibir o vídeo
hFig = figure;
hAx = axes;

% Loop para exibir cada frame do vídeo
while 1
    % Lê o frame atual
    frame = step(videoFileReader);
    
    % Mostra o frame na janela da figura
    imshow(frame, 'Parent', hAx);
    
    % Pausa por um curto período de tempo (opcional)
    drawnow;
end

% Fecha a janela quando o vídeo terminar
close(hFig);
release(videoFileReader);