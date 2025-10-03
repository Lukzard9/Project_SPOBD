function visualizza_grafici(includi_grafici_caratteristiche_grafo, coordinate, A, T, N, U, nomi_stazioni, autovalori, ...
    matrice_segnali, coefficienti_gft, freq_significative, ...
    grafo_dsp, dati, variabile_analisi)

    if includi_grafici_caratteristiche_grafo
        crea_figura_geografica(coordinate, A, nomi_stazioni, N);

        crea_figura_autovalori(autovalori, N);

        crea_figura_modi_autovettoriali(coordinate, A, U, autovalori, N);
    end

    crea_figura_patterns_spaziotemporali(matrice_segnali, dati, nomi_stazioni, ...
        grafo_dsp, variabile_analisi, N);

    crea_figura_spettrogramma(dati, coefficienti_gft, ...
        freq_significative, autovalori, T)

end

function crea_figura_geografica(coordinate, A, nomi_stazioni, N)
    figure('Position', [100, 100, 800, 600], 'Name', 'Struttura del Grafo');
    
    ax = geoaxes;
    hold(ax, 'on');
    
    lat_min = min(coordinate(:,2));
    lat_max = max(coordinate(:,2));
    lon_min = min(coordinate(:,1));
    lon_max = max(coordinate(:,1));
    
    lat_range = lat_max - lat_min;
    lon_range = lon_max - lon_min;
    padding_factor = 0.15;
    
    lat_lims = [lat_min - lat_range * padding_factor, lat_max + lat_range * padding_factor];
    lon_lims = [lon_min - lon_range * padding_factor, lon_max + lon_range * padding_factor];
    
    geolimits(ax, lat_lims, lon_lims);
    geobasemap(ax, 'satellite'); 

    for i = 1:N
        for j = i+1:N
            if A(i,j) == 1
                geoplot(ax, [coordinate(i,2), coordinate(j,2)], ...
                       [coordinate(i,1), coordinate(j,1)], ...
                       'Color', [0.7 0.7 0.7], 'LineWidth', 1.3, 'LineStyle', '-');
            end
        end
    end

    geoscatter(ax, coordinate(:,2), coordinate(:,1), 120, ...
        'MarkerFaceColor', [0.2 0.4 0.8], ...
        'MarkerEdgeColor', 'white', 'LineWidth', 1.5);

    aggiungi_etichette_stazioni(ax, coordinate, nomi_stazioni, N);    
    title('Geografia e Struttura della Rete', 'FontSize', 12, 'FontWeight', 'bold');
    hold(ax, 'off');
end

function aggiungi_etichette_stazioni(ax, coordinate, nomi_stazioni, N)
    for i = 1:N
        longitudine = coordinate(i,1);
        latitudine = coordinate(i,2);

        if i == 1 
            text(ax, latitudine + 0.033, longitudine + 0.01, nomi_stazioni{i}, ...
             'FontSize', 7.5, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
             'BackgroundColor', '#E7ECEF', 'EdgeColor', 'none', ...
             'Margin', 1, 'Color', 'black');
        elseif i == 4
            text(ax, latitudine + 0.023, longitudine - 0.005, nomi_stazioni{i}, ...
                'FontSize', 7.5, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
                'BackgroundColor', '#E7ECEF', 'EdgeColor', 'none', ...
                'Margin', 1, 'Color', 'black');
        elseif i == 5
            text(ax, latitudine + 0.023, longitudine - 0.015, nomi_stazioni{i}, ...
                'FontSize', 7.5, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
                'BackgroundColor', '#E7ECEF', 'EdgeColor', 'none', ...
                'Margin', 1, 'Color', 'black');
        elseif i == 5 || i == 12
            text(ax, latitudine - 0.014, longitudine - 0.013, nomi_stazioni{i}, ...
             'FontSize', 7.5, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
             'BackgroundColor', '#E7ECEF', 'EdgeColor', 'none', ...
             'Margin', 1, 'Color', 'black');
        elseif i == 7 || i == 8 || i == 9 || i == 10
            text(ax, latitudine - 0.006, longitudine + 0.020, nomi_stazioni{i}, ...
             'FontSize', 7.5, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
             'BackgroundColor', '#E7ECEF', 'EdgeColor', 'none', ...
             'Margin', 1, 'Color', 'black');
        elseif i == 2 || i == 3 || i == 6 || i == 11 
            text(ax, latitudine + 0.006, longitudine - 0.020, nomi_stazioni{i}, ...
                'FontSize', 7.5, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', ...
                'BackgroundColor', '#E7ECEF', 'EdgeColor', 'none', ...
                'Margin', 1, 'Color', 'black');
        else
            text(ax, latitudine - 0.013, longitudine, nomi_stazioni{i}, ...
             'FontSize', 7.5, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
             'BackgroundColor', '#E7ECEF', 'EdgeColor', 'none', ...
             'Margin', 1, 'Color', 'black');
        end
    end
end

function crea_figura_autovalori(autovalori, N)
    figure('Position', [950, 100, 600, 500], 'Name', 'Analisi Autovalori');
    stem(1:N, autovalori, 'filled', 'LineWidth', 2, 'MarkerSize', 8, ...
         'MarkerFaceColor', [0.2 0.4 0.8], 'MarkerEdgeColor', 'white', ...
         'Color', [0.2 0.4 0.8]);
    
    xlabel('Indice Autovalore', 'FontSize', 11, 'FontWeight', 'bold'); 
    ylabel('Autovalore', 'FontSize', 11, 'FontWeight', 'bold');
    title('Autovalori del Grafo (Frequenze del Grafo)', 'FontSize', 12, 'FontWeight', 'bold');
    grid on; grid minor;
    ylim([0, max(autovalori) * 1.1]);
    set(gca, 'FontSize', 10);
end

function crea_figura_modi_autovettoriali(coordinate, A, U, autovalori, N)
    figure('Position', [100 100 1200 600], 'Name', 'Modi Autovettoriali (3D)');
    
    num_modi_da_disegnare = 6;
    [xlims, ylims] = calcola_limiti_xy(coordinate);
    
    for modo = 1:num_modi_da_disegnare
        subplot(2, ceil(num_modi_da_disegnare/2), modo);
        disegna_autovettore_3d(coordinate, A, U, autovalori, modo, xlims, ylims, N);
    end
end

function [xlims, ylims] = calcola_limiti_xy(coordinate)
    xpad = 0.02 * range(coordinate(:,1));
    ypad = 0.02 * range(coordinate(:,2));
    xlims = [min(coordinate(:,1))-xpad, max(coordinate(:,1))+xpad];
    ylims = [min(coordinate(:,2))-ypad, max(coordinate(:,2))+ypad];
end

function disegna_autovettore_3d(coordinate, A, U, autovalori, idx_modo, xlims, ylims, N)
    valori = U(:,idx_modo) / max(abs(U(:,idx_modo)));
    
    scatter3(coordinate(:,1), coordinate(:,2), valori, ...
        150, valori, 'filled', 'MarkerEdgeColor', 'k');
    hold on;
    
    for i = 1:N
        for j = i+1:N
            if A(i,j) > 0
                plot3([coordinate(i,1), coordinate(j,1)], ...
                      [coordinate(i,2), coordinate(j,2)], ...
                      [valori(i), valori(j)], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.7);
            end
        end
    end
    
    xlabel('Longitudine'); ylabel('Latitudine'); zlabel('Valore Autovettore');
    title(sprintf('Autovettore %d (\\lambda = %.3f)', idx_modo, autovalori(idx_modo)));
    colormap(parula); colorbar;
    clim([-1 1]); xlim(xlims); ylim(ylims); zlim([-1 1]);
    grid on; box on; view(45,25); axis vis3d;
end

function crea_figura_spettrogramma(dati, coefficienti_gft, ...
    freq_significative, autovalori, T)

    figure('Position', [100, 100, 1200, 300], 'Name', 'Spettrogramma');
    
    idx_freq_dominante = freq_significative(1);
    coeff_dominante = detrend(coefficienti_gft(:, idx_freq_dominante));
    
    dimensione_finestra = min(24*14, floor(T/8));
    sovrapposizione = floor(dimensione_finestra * 0.75);
    nfft = max(dimensione_finestra*2, 2^nextpow2(dimensione_finestra*2));
    
    [S, F, T_spec] = spectrogram(coeff_dominante, dimensione_finestra, sovrapposizione, nfft, 1);
    
    [periodi_filtrati, S_filtrato, tempo_reale] = elabora_dati_spettrogramma(S, F, T_spec, dati);
    
    S_db = 10*log10(abs(S_filtrato) + eps);
    imagesc(tempo_reale, log10(periodi_filtrati), S_db);
    set(gca, 'YDir', 'normal');
    
    configura_asse_periodi(periodi_filtrati);
    
    aggiungi_linee_riferimento_periodi(periodi_filtrati);
    
    colorbar;
    xlabel('Tempo'); ylabel('Periodo');
    title(sprintf('Spettrogramma - Frequenza Grafo λ=%.3f', autovalori(idx_freq_dominante)));
    colormap('parula');
end

function [periodi_filtrati, S_filtrato, tempo_reale] = elabora_dati_spettrogramma(S, F, T_spec, dati)
    
    periodi_ore = 1./F;
    periodi_ore(F == 0) = Inf;
    periodi_ore(periodi_ore > 24*365) = 24*365;
    
    intervallo_periodi = periodi_ore >= 6 & periodi_ore <= 24*365;
    periodi_filtrati = periodi_ore(intervallo_periodi);
    S_filtrato = S(intervallo_periodi, :);
    
    tempo_reale = dati.timestamps(1) + T_spec * (dati.timestamps(end) - dati.timestamps(1)) / max(T_spec);
end

function configura_asse_periodi(periodi_filtrati)
    
    tick_periodi = [6, 12, 24, 24*7, 24*30, 24*365];
    tick_periodi = tick_periodi(tick_periodi >= min(periodi_filtrati) & ...
                               tick_periodi <= max(periodi_filtrati));
    
    posizioni_ytick = log10(tick_periodi);
    etichette_ytick = cell(length(tick_periodi), 1);
    
    for i = 1:length(tick_periodi)
        p = tick_periodi(i);
        if p < 24
            etichette_ytick{i} = sprintf('%do', round(p));
        elseif p < 24*30
            etichette_ytick{i} = sprintf('%dg', round(p/24));
        else
            etichette_ytick{i} = sprintf('%dm', round(p/(24*30)));
        end
    end
    
    set(gca, 'YTick', posizioni_ytick, 'YTickLabel', etichette_ytick);
end

function aggiungi_linee_riferimento_periodi(periodi_filtrati)
    hold on;
    periodi_importanti = [24, 24*7];
    
    for periodo = periodi_importanti
        if periodo >= min(periodi_filtrati) && periodo <= max(periodi_filtrati)
            plot(xlim, [log10(periodo), log10(periodo)], 'LineWidth', 1.5, ...
                 'Color', [1, 1, 1, 0.2]);
        end
    end
    hold off;
end

function crea_figura_patterns_spaziotemporali(matrice_segnali, dati, nomi_stazioni, ...
    grafo_dsp, variabile_analisi, N)
    
    figure('Position', [200, 200, 1400, 600], 'Name', 'Patterns Spazio-Temporali Inquinamento');
    
    % Media inquinamento per stazione
    subplot(2, 3, 2);
    disegna_medie_stazioni(matrice_segnali, nomi_stazioni, variabile_analisi);
    
    % Pattern diurno
    subplot(2, 3, 3);
    disegna_pattern_diurno(matrice_segnali, dati.timestamps, variabile_analisi);
    
    % Matrice correlazione
    subplot(2, 3, 5);
    disegna_matrice_correlazione(matrice_segnali, nomi_stazioni, N);
    
    % Pattern stagionale
    subplot(2, 3, 6);
    disegna_pattern_stagionale(matrice_segnali, dati.timestamps, variabile_analisi);
    
    % Spettro di potenza frequenze grafo
    subplot(2, 3, [1,4]);
    disegna_spettro_potenza(grafo_dsp, N);
    
    sgtitle(['Patterns Spazio-Temporali - ' variabile_analisi]);
end

function disegna_medie_stazioni(matrice_segnali, nomi_stazioni, variabile_analisi)
    
    medie_stazioni = mean(matrice_segnali, 1);
    [medie_ordinate, idx_ordinamento] = sort(medie_stazioni, 'descend');
    bar(medie_ordinate);
    set(gca, 'XTickLabel', nomi_stazioni(idx_ordinamento), 'XTickLabelRotation', 45);
    ylabel(['Media ' variabile_analisi]);
    title(['Media ' variabile_analisi ' per Stazione']);
    grid on;
end

function disegna_pattern_diurno(matrice_segnali, timestamps, variabile_analisi)
    
    ora_del_giorno = hour(timestamps);
    medie_orarie = zeros(24, 1);
    
    for h = 0:23
        medie_orarie(h+1) = mean(matrice_segnali(ora_del_giorno == h, :), 'all');
    end
    
    plot(0:23, medie_orarie, 'o-', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('Ora del Giorno'); ylabel(['Media ' variabile_analisi]);
    title(['Pattern Diurno - ' variabile_analisi]);
    grid on; xlim([0, 23]);
end

function disegna_matrice_correlazione(matrice_segnali, nomi_stazioni, N)
    
    matrice_correlazione = corrcoef(matrice_segnali, 'rows', 'complete');
    imagesc(matrice_correlazione);
    colorbar; colormap('sky'); clim([-1, 1]);
    
    set(gca, 'XTick', 1:N, 'YTick', 1:N);
    set(gca, 'XTickLabel', nomi_stazioni, 'YTickLabel', nomi_stazioni);
    set(gca, 'XTickLabelRotation', 45, 'YTickLabelRotation', 0);
    title('Matrice Correlazione Inter-Stazione');
end

function disegna_pattern_stagionale(matrice_segnali, timestamps, variabile_analisi)
    
    mese_dell_anno = month(timestamps);
    medie_mensili = zeros(12, 1);
    nomi_mesi = {'Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', ...
                   'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'};
    
    for m = 1:12
        medie_mensili(m) = mean(matrice_segnali(mese_dell_anno == m, :), 'all');
    end
    
    bar(medie_mensili);
    set(gca, 'XTickLabel', nomi_mesi, 'XTickLabelRotation', 45);
    ylabel(['Media ' variabile_analisi]); title(['Pattern Stagionale - ' variabile_analisi]);
    grid on;
end

function disegna_spettro_potenza(grafo_dsp, N)
    
    bar(1:N, grafo_dsp);
    xlabel('Indice Frequenza Grafo'); ylabel('Potenza');
    title('Distribuzione Spettrale di Potenza');
    grid on;
end