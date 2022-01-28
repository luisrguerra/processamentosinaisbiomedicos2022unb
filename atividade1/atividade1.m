plotATM("f2y05m", "Jovem",5); %f2y05m paciente escolhido
pause(1.3); %Pausa para mostrar que existe duas janelas uma em cima da outra
plotATM("f2o05m", "Idoso",5); %f2o05m paciente escolhido

function plotATM(Arquivo,Title,tempoMinutos)

% usage: plotATM('RECORDm')
%
% This function reads a pair of files (RECORDm.mat and RECORDm.info) generated
% by 'wfdb2mat' from a PhysioBank record, baseline-corrects and scales the time
% series contained in the .mat file, and plots them.  The baseline-corrected
% and scaled time series are the rows of matrix 'val', and each
% column contains simultaneous samples of each time series.
%
% 'wfdb2mat' is part of the open-source WFDB Software Package available at
%    http://physionet.org/physiotools/wfdb.shtml
% If you have installed a working copy of 'wfdb2mat', run a shell command
% such as
%    wfdb2mat -r 100s -f 0 -t 10 >100sm.info
% to create a pair of files ('100sm.mat', '100sm.info') that can be read
% by this function.
%
% The files needed by this function can also be produced by the
% PhysioBank ATM, at
%    http://physionet.org/cgi-bin/ATM
%

% plotATM.m           O. Abdala			16 March 2009
% 		      James Hislop	       27 January 2014	version 1.1

Name = strcat("dados\", Arquivo); %Adiciona o endereço do diretórios dos dados dos cardiogramas
infoName = strcat(Name, '.info');
matName = strcat(Name, '.mat');
Octave = exist('OCTAVE_VERSION');
load(matName);
fid = fopen(infoName, 'rt');
fgetl(fid);
fgetl(fid);
fgetl(fid);
[freqint] = sscanf(fgetl(fid), 'Sampling frequency: %f Hz  Sampling interval: %f sec');
interval = freqint(2);
fgetl(fid);

if(Octave)
    for i = 1:size(val, 1)
       R = strsplit(fgetl(fid), char(9));
       signal{i} = R{2};
       gain(i) = str2num(R{3});
       base(i) = str2num(R{4});
       units{i} = R{5};
    end
else
    for i = 1:size(val, 1)
      [row(i), signal(i), gain(i), base(i), units(i)]=strread(fgetl(fid),'%d%s%f%f%s','delimiter','\t');
    end
end

fclose(fid);
val(val==-32768) = NaN;

for i = 1:size(val, 1)
    val(i, :) = (val(i, :) - base(i)) / gain(i);
end

x = (1:size(val, 2)) * interval;

% Ajuste na posição e tamanho da janela
janela = figure('name',Name);
posicaox = 400;
posicaoy = 300;
altura = 400;
comprimento = 1000;
janela.Position = [posicaox posicaoy comprimento altura];

%Calculo para o intervalo de tempo
frequencia = 250;
tempox = tempoMinutos*60*frequencia;
%disp(tempox);


subplot(2,1,1);% Subplotar em cima
plot(x(1:tempox)', val(1, 1:tempox)'); %Plotar aplicando o intervalo de tempo
title( strcat(Arquivo," - ",Title, ' - Respiração') );
legend( strcat(signal{1}, ' (', units{1}, ')') ); %Legenda da linha com unidade de medida
xlabel('Tempo (segundos)');
grid on; %Ativar linha no gráfico

subplot(2,1,2);% Subplotar em baixo
plot(x(1:tempox)', val(2, 1:tempox)');%Plotar aplicando o intervalo de tempo
title( strcat(Arquivo," - ",Title,' - Eletrocardiograma') );
legend( strcat(signal{2}, ' (', units{2}, ')') ); %Legenda da linha com unidade de medida
xlabel('Tempo (segundos)');
grid on; %Ativar linha no gráfico

end % Fim da função plotATM()