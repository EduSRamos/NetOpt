%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                UNIVERSIDADE FEDERAL DE MINAS GERAIS
%                        OTIMIZACAO EM REDES
%                       TRABALHO COMPUTACIONAL
%                   PROF. EDUARDO GONTIJO CARRRANO
%                   PROF. LUCAS DE SOUZA BATISTA
%                          
%
% NOMES: Bruno Andrade Pereira - 2013030430
%        Eduardo Santiago Ramos - 2014015435
%        Marcus Vinicius Bastos - 2013030147
%
% DATA: 21/06/2018
%
% ARQUIVO: 'main.m' 
% DESCRICAO: Execucao do problema.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#ok<*ASGLU>

% % Instancia 1
% b = [];
% X1 = csvread('sch100k1.csv');
% D1 = 454;
% %     gMax = 500;        
% elit = 0.09;       
% forca_mut = 0.005;  
% for gMax = [1000,1500,2000]
%     parfor i = 1:20
%         [fit_min,best_sol]= optsearch(X1,D1,gMax,elit,forca_mut); 
%     %     fprintf('Solucao da instancia 1: %f', fit_min);
%         b = [b; {gMax, fit_min}]
%     end
% end


% % Instancia 2
% gMax = 1500;       
% elit = 0.08;       
% forca_mut = 0.0023; 
% [fit_min,best_sol] = optsearch(X2,D2,gMax,elit,forca_mut);
% fprintf('Solucao da instancia 2: %f', fit_min);

% Instancia 1
b = [];
X2 = csvread('sch200k1.csv');
D2 = 851;
elit = 0.08;
forca_mut = 0.0023; 
for gMax = [100, 300, 500, 1000, 1500, 2000, 3000, 5000]
    parfor i = 1:20
        [fit_min,best_sol] = optsearch(X2,D2,gMax,elit,forca_mut);
    %     fprintf('Solucao da instancia 1: %f', fit_min);
        b = [b; {gMax, fit_min}]
    end
end
