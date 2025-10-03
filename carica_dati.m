function dati = carica_dati()
    if evalin('base', 'exist(''dati_pechino'', ''var'')')
        fprintf('Utilizzo dati precedentemente caricati dal workspace...\n');
        dati = evalin('base', 'dati_pechino');
        return;
    end
    
    if exist('dati_pechino.mat', 'file')
        fprintf('Caricamento dati da file .mat salvato...\n');
        load('dati_pechino.mat', 'dati_pechino');
        dati = dati_pechino;
        assignin('base', 'dati_pechino', dati);
        return;
    end
    
    fprintf('Caricamento dati da CSV ...\n');
    dati = carica_dati_da_csv();
    
    dati_pechino = dati;
    save('dati_pechino.mat', 'dati_pechino');
    fprintf('Dati salvati in dati_pechino.mat\n');
    
    assignin('base', 'dati_pechino', dati);
end


function dati = carica_dati_da_csv()

    nome_file_csv = 'beijing_air_quality.csv';
    
    if ~exist(nome_file_csv, 'file')
        error('File %s non trovato. Controlla il percorso del file.', nome_file_csv);
    end
    
    try
        dati_grezzi = readtable(nome_file_csv, 'VariableNamingRule', 'preserve');
        fprintf('File CSV caricato con successo: %d righe; %d colonne\n', height(dati_grezzi), width(dati_grezzi));
    catch ME
        error('Errore nella lettura del file CSV: %s', ME.message);
    end
    
    stazioni = unique(dati_grezzi.station, 'stable');
    
    fprintf('\nCreazione indice datetime...\n');
    vettore_datetime = datetime(dati_grezzi.year, dati_grezzi.month, dati_grezzi.day, dati_grezzi.hour, 0, 0);
    
    timestamp_unici = unique(vettore_datetime);
    timestamp_unici = sort(timestamp_unici);
    num_timestamp = length(timestamp_unici);
    
    fprintf('I dati coprono il periodo da %s a %s\n', datestr(timestamp_unici(1)), datestr(timestamp_unici(end)));
    fprintf('Punti temporali totali: %d\n', num_timestamp);
    
    num_stazioni = length(stazioni);
    
    matrice_PM25 = NaN(num_timestamp, num_stazioni);
    matrice_PM10 = NaN(num_timestamp, num_stazioni);
    matrice_SO2  = NaN(num_timestamp, num_stazioni);
    matrice_NO2  = NaN(num_timestamp, num_stazioni);
    matrice_CO   = NaN(num_timestamp, num_stazioni);
    matrice_O3   = NaN(num_timestamp, num_stazioni);
    
    matrice_TEMP = NaN(num_timestamp, num_stazioni);
    matrice_PRES = NaN(num_timestamp, num_stazioni);
    matrice_DEWP = NaN(num_timestamp, num_stazioni);
    matrice_RAIN = NaN(num_timestamp, num_stazioni);
    matrice_WSPM = NaN(num_timestamp, num_stazioni);
    
    fprintf('\nOrganizzazione dati per stazione e timestamp...\n');
    
    for i = 1:num_stazioni
        nome_stazione = stazioni{i};
        fprintf('Elaborazione stazione: %s (%d/%d)\n', nome_stazione, i, num_stazioni);
        
        maschera_stazione = strcmp(dati_grezzi.station, nome_stazione);
        dati_stazione = dati_grezzi(maschera_stazione, :);
        timestamp_stazione = vettore_datetime(maschera_stazione);
        
        [~, idx_globale] = ismember(timestamp_stazione, timestamp_unici);
        
        righe_valide = idx_globale > 0;
        idx_globale = idx_globale(righe_valide);
        dati_stazione = dati_stazione(righe_valide, :);
        
        [~, first_idx] = unique(idx_globale, 'first');
        idx_globale = idx_globale(first_idx);
        dati_stazione = dati_stazione(first_idx, :);
        
        matrice_PM25(idx_globale, i) = arrayfun(@converti_a_numerico, dati_stazione.('PM2.5'));
        matrice_PM10(idx_globale, i) = arrayfun(@converti_a_numerico, dati_stazione.PM10);
        matrice_SO2(idx_globale, i)  = arrayfun(@converti_a_numerico, dati_stazione.SO2);
        matrice_NO2(idx_globale, i)  = arrayfun(@converti_a_numerico, dati_stazione.NO2);
        matrice_CO(idx_globale, i)   = arrayfun(@converti_a_numerico, dati_stazione.CO);
        matrice_O3(idx_globale, i)   = arrayfun(@converti_a_numerico, dati_stazione.O3);
        
        matrice_TEMP(idx_globale, i) = arrayfun(@converti_a_numerico, dati_stazione.TEMP);
        matrice_PRES(idx_globale, i) = arrayfun(@converti_a_numerico, dati_stazione.PRES);
        matrice_DEWP(idx_globale, i) = arrayfun(@converti_a_numerico, dati_stazione.DEWP);
        matrice_RAIN(idx_globale, i) = arrayfun(@converti_a_numerico, dati_stazione.RAIN);
        matrice_WSPM(idx_globale, i) = arrayfun(@converti_a_numerico, dati_stazione.WSPM);
    end
    
    dati.timestamps = timestamp_unici;
    dati.nomi_stazioni = stazioni;
    
    dati.PM25 = matrice_PM25;
    dati.PM10 = matrice_PM10;
    dati.SO2  = matrice_SO2;
    dati.NO2  = matrice_NO2;
    dati.CO   = matrice_CO;
    dati.O3   = matrice_O3;
    
    dati.TEMP = matrice_TEMP;
    dati.PRES = matrice_PRES;
    dati.DEWP = matrice_DEWP;
    dati.RAIN = matrice_RAIN;
    dati.WSPM = matrice_WSPM;
    
    fprintf('\n=== RIASSUNTO QUALITÀ DATI ===\n');
    inquinanti = {'PM25', 'PM10', 'SO2', 'NO2', 'CO', 'O3'};
    for p = 1:length(inquinanti)
        dati_inq = dati.(inquinanti{p});
        tot = numel(dati_inq);
        manc = sum(isnan(dati_inq(:)));
        completezza = (tot - manc) / tot * 100;
        fprintf('%s: %.1f%% completo (%d mancanti su %d)\n', ...
                inquinanti{p}, completezza, manc, tot);
    end
    
    meteorologici = {'TEMP', 'PRES', 'DEWP', 'RAIN', 'WSPM'};
    for m = 1:length(meteorologici)
        dati_met = dati.(meteorologici{m});
        tot = numel(dati_met);
        manc = sum(isnan(dati_met(:)));
        completezza = (tot - manc) / tot * 100;
        fprintf('%s: %.1f%% completo (%d mancanti su %d)\n', ...
                meteorologici{m}, completezza, manc, tot);
    end
    
    fprintf('\nCaricamento dati completato\n');
end

function valore_numerico = converti_a_numerico(valore)
    if ismissing(valore) || isnan(valore)
        valore_numerico = NaN;
    elseif ischar(valore) || isstring(valore)
        if strcmpi(char(valore), 'NA') || isempty(char(valore))
            valore_numerico = NaN;
        else
            valore_numerico = str2double(valore);
        end
    else
        valore_numerico = double(valore);
    end
end