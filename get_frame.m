
% Lê o frame atual No caso do video
frame = step(CameraData);
% Aplica a transformaçao
frame_cortado(i_,j_,:) = 255*frame(Y_(2,:),Y_(1,:),:);
% campo_cortado(i_,j_,:) = 255*campo(Y_(2,:),Y_(1,:),:);