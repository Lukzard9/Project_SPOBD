clear; clc; close all;

%% 1. Caricamento Dati e Selezione Segnale

stazioni = {
    'Aotizhongxin', 116.397, 39.982;
    'Changping', 116.23, 40.217;
    'Dingling', 116.22, 40.292;
    'Dongsi', 116.417, 39.929;
    'Guanyuan', 116.339, 39.929;
    'Gucheng', 116.184, 39.914;
    'Huairou', 116.628, 40.328;
    'Nongzhanguan', 116.461, 39.937;
    'Shunyi', 116.655, 40.127;
    'Tiantan', 116.407, 39.886;
    'Wanliu', 116.287, 39.987;
    'Wanshouxigong', 116.352, 39.878
};

dati = carica_dati();
coordinate = cell2mat(stazioni(:, 2:3));
nomi_stazioni = stazioni(:, 1);
N = size(coordinate, 1);

k = 4;
% Numero di vicini per il grafo k-NN

variabile_analisi = 'PM25';
% Opzioni disponibili: PM25, PM10, SO2, NO2, CO, O3, TEMP, PRES, DEWP, RAIN, WSPM

includi_grafici_caratteristiche_grafo = false;

%% 2. Preprocessing dei Dati

if ~isfield(dati, variabile_analisi)
    error('Variabile %s non trovata nei dati. Variabili disponibili: %s', ...
          variabile_analisi, strjoin(fieldnames(dati), ', '));
end

matrice_segnali = dati.(variabile_analisi);
[T, N_check] = size(matrice_segnali);
assert(N_check == N, 'Numero di stazioni non corrisponde');

percentuale_mancanti = sum(isnan(matrice_segnali(:))) / numel(matrice_segnali) * 100;

% Interpolazione lineare nel tempo
matrice_segnali_piena = matrice_segnali;
for stazione = 1:N
   dati_stazione = matrice_segnali(:, stazione);
    matrice_segnali_piena(:, stazione) = fillmissing(dati_stazione, 'linear');
end

% Interpolazione spaziale
for t = 1:T
   slice_temporale = matrice_segnali_piena(t, :);
   stazioni_mancanti = isnan(slice_temporale);

   if any(stazioni_mancanti) && sum(~stazioni_mancanti) > 0
       stazioni_disponibili = find(~stazioni_mancanti);
       indici_stazioni_mancanti = find(stazioni_mancanti);

       for idx_mancante = indici_stazioni_mancanti
           distanze_da_target = pdist2(coordinate(idx_mancante, :), coordinate(stazioni_disponibili, :));
           if any(distanze_da_target > 0)
               pesi = 1 ./ distanze_da_target;
               pesi = pesi / sum(pesi);
               matrice_segnali_piena(t, idx_mancante) = sum(pesi .* slice_temporale(stazioni_disponibili));
           end
       end
   end
end

% Media globale
media_globale = mean(matrice_segnali_piena(:), 'omitmissing');
matrice_segnali_piena(isnan(matrice_segnali_piena)) = media_globale;
matrice_segnali = matrice_segnali_piena;
matrice_segnali(isinf(matrice_segnali)) = media_globale;

fprintf('\nPreprocessing completato per la variabile %s:\n', variabile_analisi);
fprintf(' - Valori mancanti originali: %.2f%%\n', percentuale_mancanti);
fprintf(' - Valori mancanti rimanenti: %.2f%%\n', sum(isnan(matrice_segnali(:))) / numel(matrice_segnali) * 100);
fprintf(' - Periodo temporale: %s - %s\n', datestr(dati.timestamps(1)), datestr(dati.timestamps(end)));
fprintf(' - Durata analisi: %d giorni oppure %d ore\n', T/24, T);

%% 3. Costruzione del Grafo - k-NN

distanze = pdist2(coordinate, coordinate);

A = zeros(N);
[~, indici_ordinati] = sort(distanze, 2);

for i = 1:N
    vicini = indici_ordinati(i, 2:k+1);
    A(i, vicini) = 1;
end

A = double(A | A');
D = diag(sum(A));

fprintf('\nGrafo k-NN costruito con k = %d\n', k);
fprintf(' - Componenti connesse: %d\n', sum(abs(eig((D -A))) < 1e-10));
fprintf(' - Densità archi: %.3f\n', sum(A(:)) / (N * (N-1)));
fprintf(' - Grado medio: %.2f\n', mean(sum(A)));
fprintf(' - Archi totali: %d\n', sum(A(:))/2);

%% 4. Calcolo del Laplaciano e Decomposizione in Autovalori

L = (D - A);

[U, Lambda] = eig(L, 'vector');
[autovalori, idx] = sort(Lambda);
U = U(:, idx);

if U(1, 1) < 0
    U(:, 1) = -U(:, 1);
end

fprintf('Frequenze del grafo: ');
fprintf('%.4f ', autovalori');
fprintf('\n');

%% 5. Calcolo dei Coefficienti della GFT

coefficienti_gft = (matrice_segnali * U);

%% 6. Analisi delle Frequenze

grafo_dsp = mean(abs(coefficienti_gft).^2, 1); % Distribuzione spettrale di potenza

[~, freq_significative] = sort(grafo_dsp, 'descend');

fprintf('\nFrequenze del grafo più significative:\n');
for i = 1:5
    idx_freq = freq_significative(i);
    fprintf('Frequenza grafo %.4f (indice autovalore %2d): Potenza = %.4f\n', ...
        autovalori(idx_freq), idx_freq, grafo_dsp(idx_freq));
end

%% 7. Visualizzazione

visualizza_grafici(includi_grafici_caratteristiche_grafo, coordinate, A, T, N, U, nomi_stazioni, autovalori, ...
    matrice_segnali, coefficienti_gft, freq_significative, ...
    grafo_dsp, dati, variabile_analisi);
