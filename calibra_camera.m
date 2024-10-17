% Lê o frame atual No caso do video
% frame = step(CameraData);
% imshow(frame);
% [px,py]=ginput(4);
% close
% % Transformação de pespectiva
% Y = [px py py.^0]';
% dY = abs(Y(1:2,2:end)-Y(1:2,1:end-1)); mdist = max(dY(:))+1;
% X = [1  mdist mdist  1;1 1 mdist mdist;1 1 1 1];
% H = Y/X;
% i_ = 1:mdist; j_ = 1:mdist;
% frame_cortado = zeros(mdist,mdist,3);
% Y_ = floor(H*[j_;i_;i_.^0]);
% frame_cortado(i_,j_,:) = frame(Y_(2,:),Y_(1,:),:);
% campo_cortado(i_,j_,:) = campo(Y_(2,:),Y_(1,:),:);
% save Transformacao_da_imagem.mat H Y_ i_ j_

load('Transformacao_da_imagem.mat')