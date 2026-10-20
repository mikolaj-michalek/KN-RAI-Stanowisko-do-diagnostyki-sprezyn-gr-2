%% MODEL SYSTEM DIAGNOSTYKI SPRĘŻYNY

%% PARAMETRY WEJŚCIOWE I SYMULACJA
k_wzorzec = 7.30;
k_pomiar = 7.89;
tolerancja_proc = 2.0;
model_name = 'model_sprezyny';
tol_dec = tolerancja_proc / 100;

% Uruchomienie modelu
if ~bdIsLoaded(model_name), open_system(model_name); end
out = sim(model_name);
% POBRANIE DANYCH
s = out.data_s; if isa(s, 'timeseries'), s = s.Data; end
F = out.data_F; if isa(F, 'timeseries'), F = F.Data; end
s = squeeze(double(s(:)));
F = squeeze(double(F(:)));
%% REGRESJA
coeffs = polyfit(s, F, 1);
k_real = coeffs(1);
F_regresja = polyval(coeffs, s);

% Wyznaczenie korytarza tolerancji
F_max = s * k_wzorzec * (1 + tol_dec);
F_min = s * k_wzorzec * (1 - tol_dec);

% Obliczenie błędu końcowego
error_proc = abs((k_real - k_wzorzec) / k_wzorzec) * 100;

%% 3. Generowanie wykresu
hFig = figure('Color', 'w', 'Name', 'Raport Techniczny');
ax = axes('Parent', hFig, 'Color', 'w');
set(ax, 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.2 0.2 0.2], 'GridAlpha', 0.15);
hold on; grid on; box on;

X_fill = [s; flipud(s)];
Y_fill = [F_max; flipud(F_min)];
fill(X_fill, Y_fill, [0.8 0.95 0.8], ...
'EdgeColor', [0.3 0.5 0.3], 'LineStyle', ':', 'FaceAlpha', 0.5, ...
'DisplayName', 'Tolerancja');

plot(s, F, 'Color', [0.2 0.2 0.2 0.3], 'LineWidth', 0.5, ...
'DisplayName', 'Dane pomiarowe');

plot(s, F_regresja, 'Color', [0.8 0 0], 'LineWidth', 2.5, ...
'DisplayName', 'Regresja liniowa pomiaru');

xlabel('Ugięcie s [mm]', 'FontWeight', 'bold', 'Color', 'k');
ylabel('Siła F [N]', 'FontWeight', 'bold', 'Color', 'k');
title('CHARAKTERYSTYKA STATYCZNA SPRĘŻYNY', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
lgd = legend('Location', 'northwest', 'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k');
title(lgd, 'Oznaczenia:');

%% WERDYKT I DANE
if error_proc <= tolerancja_proc
status_str = 'STATUS: OK';
box_color = [0.3 0.55 0.3];
else
status_str = 'STATUS: WADLIWA';
box_color = [0.75 0.2 0.2];
end
info_txt = {
['Wzorzec: ', num2str(k_wzorzec, '%.2f'), ' N/mm'], ...
['Pomiar: ', num2str(k_real, '%.2f'), ' N/mm'], ...
['Tolerancja: ', num2str(tolerancja_proc, '%.1f'), '%'], ...
['Błąd: ', num2str(error_proc, '%.2f'), '%'], ...
'', ...
status_str
};
annotation('textbox', [0.65, 0.15, 0.25, 0.25], ...
'String', info_txt, ...
'Color', 'w', ...
'BackgroundColor', box_color, ...
'FontWeight', 'bold', ...
'FontSize', 10, ...
'FontName', 'Consolas', ...
'HorizontalAlignment', 'left', ...
'VerticalAlignment', 'middle', ...
'EdgeColor', 'k', ...
'LineWidth', 1.2);
hold off;

