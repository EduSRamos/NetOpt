%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                UNIVERSIDADE FEDERAL DE MINAS GERAIS
%                        OTIMIZACAO EM REDES
%                       TRABALHO COMPUTACIONAL
%                   PROF. EDUARDO GONTIJO CARRRANO
%                   PROF. LUCAS DE SOUZA BATISTA
%                          
%
% NOMES: Bruno
%        Eduardo Santiago Ramos - 2014015435
%        Marcus Vinicius Bastos - 2013030147
%
% DATA: 21/06/2018
%
% ARQUIVO: 'generateinstance.m' 
% DESCRICAO: Gera instancia similar 'as passadas pelos professores.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function X = generateinstance(n, seed)
   if nargin>1
      rng(seed)
   else
      rng('default');
   end
   
   p = randi([1,20], n, 1);
   a = randi([1,10], n, 1);
   b = randi([1,15], n, 1);
   
   X = [p,a,b];
end