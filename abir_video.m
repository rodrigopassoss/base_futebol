% Caminho do arquivo de v�deo
caminhoVideo = 'jogo.mp4';

% Cria um objeto VideoFileReader
videoFileReader = vision.VideoFileReader(caminhoVideo, 'PlayCount', Inf);

% Cria uma janela para exibir o v�deo
hFig = figure;
hAx = axes;

% Loop para exibir cada frame do v�deo
while 1
    % L� o frame atual
    frame = step(videoFileReader);
    
    % Mostra o frame na janela da figura
    imshow(frame, 'Parent', hAx);
    
    % Pausa por um curto per�odo de tempo (opcional)
    drawnow;
end

% Fecha a janela quando o v�deo terminar
close(hFig);
release(videoFileReader);