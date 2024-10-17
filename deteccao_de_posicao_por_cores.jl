using Pkg
Pkg.add("Images")
Pkg.add("Colors")
Pkg.add("StatsBase")
Pkg.add("FileIO")

using Images
using Colors
using StatsBase
using FileIO

# Abre a imagem
frame = FileIO.load("c:\\Users\\rodri\\Documents\\Visão Computacional\\projeto_final\\base_futebol\\0.jpg");
frame =  permutedims(channelview(frame),(2,3,1));
campo = FileIO.load("c:\\Users\\rodri\\Documents\\Visão Computacional\\projeto_final\\base_futebol\\no_robots.jpg");
campo =  permutedims(channelview(campo),(2,3,1));
# Aplicar o corte da imagem - Calibração
# imshow(frame);
# [px,py]=ginput(4);
# close
# % Transformação de perspectiva
# Y = [px py py.^0]';
# dY = abs(Y[1:2,2:end]-Y[1:2,1:end-1]); mdist = maximum(dY[:])+1;
# X = [1  mdist mdist  1;1 1 mdist mdist;1 1 1 1];
# H = Y/X;
# i_ = 1:mdist; j_ = 1:mdist;
# frame_cortado = zeros(mdist,mdist,3);
# Y_ = floor(H*[j_;i_;i_.^0]);
# frame_cortado[i_,j_,:] .= frame[Y_[2,:], Y_[1,:], :];
# campo_cortado[i_,j_,:] .= campo[Y_[2,:], Y_[1,:], :];
# save("frame_cortado.mat", "frame_cortado")
frame_cortado = load("frame_cortado.mat")["frame_cortado"]

# Normalização RGB
@time begin
    R1 = frame_cortado[:,:,1]; G1 = frame_cortado[:,:,2]; B1 = frame_cortado[:,:,3]
    frame_normalizado = (frame_cortado.^2)./(sqrt.(R1.^2 + G1.^2 + B1.^2))
    R2 = frame_normalizado[:,:,1]; G2 = frame_normalizado[:,:,2]; B2 = frame_normalizado[:,:,3]
end

# Plot parcial 1 - Ilustração do Efeito da Normalização
colors1 = [R1[1:5:end] G1[1:5:end] B1[1:5:end]]
colors1 = round.(colors1)./255
colors2 = [R2[1:5:end] G2[1:5:end] B2[1:5:end]]
colors2 = round.(colors2)./255

# Plot parcial 1 - Ilustração do Efeito da Normalização
colors1 = [R1[1:5:end] G1[1:5:end] B1[1:5:end]]
colors1 = round.(colors1)./255
colors2 = [R2[1:5:end] G2[1:5:end] B2[1:5:end]]
colors2 = round.(colors2)./255

# Continuação do código...
figure(1)
subplot(221)
title("Sem Normalização")

scatter3(colors1[:,1], colors1[:,2], colors1[:,3], 10, colors1, markersize=2)
xlabel("R"); ylabel("G"); zlabel("B")
subplot(222)

scatter(colors1[:,1], colors1[:,2], 10, colors1, markersize=2)
xlabel("R"); ylabel("G")
subplot(223)

scatter(colors1[:,1], colors1[:,3], 10, colors1, markersize=2)
xlabel("R"); ylabel("B")
subplot(224)

scatter(colors1[:,3], colors1[:,2], 10, colors1, markersize=2)
xlabel("B"); ylabel("G")

figure(2)
subplot(221)
title("Com Normalização")

scatter3(colors2[:,1], colors2[:,2], colors2[:,3], 10, colors2, markersize=2)
xlabel("R"); ylabel("G"); zlabel("B")
subplot(222)

scatter(colors2[:,1], colors2[:,2], 10, colors2, markersize=2)
xlabel("R"); ylabel("G")
subplot(223)

scatter(colors2[:,1], colors2[:,3], 10, colors2, markersize=2)
xlabel("R"); ylabel("B")
subplot(224)

scatter(colors2[:,3], colors2[:,2], 10, colors2, markersize=2)
xlabel("B"); ylabel("G")

figure(3)
subplot(221)
imshow(uint8(frame_cortado))
subplot(222)
histogram, edges = histg(R1)
bar(edges, histogram, color="r")
subplot(223)
histogram, edges = histg(G1)
bar(edges, histogram, color="g")
subplot(224)
histogram, edges = histg(B1)
bar(edges, histogram, color="b")

figure(4)
subplot(221)
imshow(uint8(frame_normalizado))
subplot(222)
histogram, edges = histg(R2)
bar(edges, histogram, color="r")
subplot(223)
histogram, edges = histg(G2)
bar(edges, histogram, color="g")
subplot(224)
histogram, edges = histg(B2)
bar(edges, histogram, color="b")


# Filtragem dos tons de cinza
tic()
limiar = 40
M = ((abs.(G2.-R2).>limiar) .& (abs.(B2.-R2).>limiar)) .|
    ((abs.(R2.-G2).>limiar) .& (abs.(B2.-G2).>limiar)) .|
    ((abs.(R2.-B2).>limiar) .& (abs.(G2.-B2).>limiar))

frame_filtrado = frame_normalizado .* float(M)
toc()

# Conversão para HSV
tic()
frame_hsv = rgb2hsv(frame_filtrado)
Hue = frame_hsv[:,:,1] .* 255
Value = frame_hsv[:,:,3] .* 255
toc()

# Plot parcial 2 - Ilustração do Filtro de tons de cinza e o HSV
figure(5)
subplot(121)
title("Antes do Filtro")
imshow(uint8(frame_normalizado))
subplot(122)
title("Depois do Filtro")
imshow(uint8(frame_filtrado))

histogram, edges = histg(Hue)
figure(6)
subplot(223)
title("HSV - Hue (Depois do Filtro)")
imshow(uint8(Hue))
subplot(224)
title("Hue - Histograma")
hBars = bar(edges, histogram)
hsv_palette = [linspace(0, 1, length(edges)); fill(0.8, length(edges)); fill(1, length(edges))]
rgb_palette = hsv2rgb(hsv_palette)'
set(hBars, x=edges, y=histogram, color=rgb_palette, facecolor="flat")
ylim([0, 5e-4])
subplot(221)
Hue_ = rgb2hsv(frame_normalizado)[:,:,1] * 255
histogram, edges = histg(Hue_)
title("HSV - Hue (Antes do Filtro)")
imshow(uint8(Hue_))
subplot(222)
title("Hue - Histograma")
hBars = bar(edges, histogram)
hsv_palette = [linspace(0, 1, length(edges)); fill(0.8, length(edges)); fill(1, length(edges))]
rgb_palette = hsv2rgb(hsv_palette)'
set(hBars, x=edges, y=histogram, color=rgb_palette, facecolor="flat")

# Segmentação
# 1 - vermelho
# 2 - laranja
# 3 - Amarelo
# 4 - Verde
# 5 - Azul
# 6 - Magenta
tic()
Pivots = 127 * ([0, 20, 45, 86, 160, 225] .- 127) / 127
Hue = 127 * (Hue .- 127) / 127

# vermelho
diff = abs.(mod.((Hue .- Pivots[1]) .+ 127, 2 * 127) .- 127)
Vermelho = imopen((diff .< 5) .& M, ones(5, 5))
y, x = findall(Vermelho)
idx, Vermelho_centros = kmeans(hcat(x[1:10:end], y[1:10:end]), 2)

# laranja
diff = abs.(mod.((Hue .- Pivots[2]) .+ 127, 2 * 127) .- 127)
laranja = imopen((diff .< 10) .& M, ones(5, 5))
y, x = findall(laranja)
idx, laranja_centro = kmeans(hcat(x[1:10:end], y[1:10:end]), 1)

# Amarelo
diff = abs.(mod.((Hue .- Pivots[3]) .+ 127, 2 * 127) .- 127)
amarelo = imopen((diff .< 10) .& M, ones(5, 5))
y, x = findall(amarelo)
idx, amarelo_centros = kmeans(hcat(x[1:10:end], y[1:10:end]), 3)

# verde
diff = abs.(mod.((Hue .- Pivots[4]) .+ 127, 2 * 127) .- 127)
verde = imopen((diff .< 10) .& M, ones(5, 5))
y, x = findall(verde)
idx, verde_centros = kmeans(hcat(x[1:10:end], y[1:10:end]), 6)

# Azul
diff = abs.(mod.((Hue .- Pivots[5]) .+ 127, 2 * 127) .- 127)
azul = imopen((diff .< 10) .& M, ones(5, 5))
y, x = findall(azul)
idx, azul_centros = kmeans(hcat(x[1:10:end], y[1:10:end]), 3)

# magenta
diff = abs.(mod.((Hue .- Pivots[6]) .+ 127, 2 * 127) .- 127)
magenta = imopen((diff .< 15) .& M, ones(5, 5))
y, x = findall(magenta)
idx, magenta_centros = kmeans(hcat(x[1:10:end], y[1:10:end]), 4)
toc()

figure(7)
imshow(uint8(frame_cortado))
raio = 10
rectangle("Position", [Vermelho_centros[1, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "r", "LineWidth", 3)
rectangle("Position", [Vermelho_centros[2, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "r", "LineWidth", 3)
rectangle("Position", [laranja_centro .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "y", "LineWidth", 3)
rectangle("Position", [magenta_centros[1, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "m", "LineWidth", 3)
rectangle("Position", [magenta_centros[2, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "m", "LineWidth", 3)
rectangle("Position", [magenta_centros[3, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "m", "LineWidth", 3)
rectangle("Position", [magenta_centros[4, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "m", "LineWidth", 3)
rectangle("Position", [amarelo_centros[1, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "y", "LineWidth", 3)
rectangle("Position", [amarelo_centros[2, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "y", "LineWidth", 3)
rectangle("Position", [amarelo_centros[3, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "y", "LineWidth", 3)
rectangle("Position", [verde_centros[1, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "g", "LineWidth", 3)
rectangle("Position", [verde_centros[2, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "g", "LineWidth", 3)
rectangle("Position", [verde_centros[3, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "g", "LineWidth", 3)
rectangle("Position", [verde_centros[4, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "g", "LineWidth", 3)
rectangle("Position", [verde_centros[5, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "g", "LineWidth", 3)
          rectangle("Position", [verde_centros[6, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "g", "LineWidth", 3)
rectangle("Position", [azul_centros[1, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "b", "LineWidth", 3)
rectangle("Position", [azul_centros[2, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "b", "LineWidth", 3)
rectangle("Position", [azul_centros[3, :] .- raio, 2 * raio, 2 * raio],
          "Curvature", [1, 1], "EdgeColor", "b", "LineWidth", 3)

# Funções Auxiliares
function histg(im)
    hist = zeros(256)
    lin, col = size(im)
    for k = 1:256
        hist[k] = count(im .== (k - 1))
    end
    hist ./= (lin * col)
    edges = 0:255
    return hist, edges
end

function histg2(im, MiN, MaX)
    hist = zeros(MaX - MiN + 1)
    lin, col = size(im)
    for k = MiN:MaX
        hist[k - MiN + 1] = count(im .== k)
    end
    hist ./= (lin * col)
    return hist
end
