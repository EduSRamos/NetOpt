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
% ARQUIVO: 'optsearch.m' 
% DESCRICAO: Algoritmo genetico de busca mono-objetivo para soma ponderada
%            de atrasos e adiantamentos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fit_min,best_sol]= optsearch(X,D,gMax,elit,forca_mut)
% Referencia:
% [1] 
%
% EXEMPLOS:
% 1) Instancia 1: 100 tarefas
%       X1 = csvread('sch100k1.csv');
%       D1 = 454;
%       gMax = 500;        
%       elit = 0.05;       
%       forca_mut = 0.005;  
%       [fit_min,best_sol]= optsearch(X1,D1,gMax,elit,forca_mut);
%
% 
% 2) Instancia 2: 200 tarefas
%       X2 = csvread('sch200k1.csv');
%       D2 = 851;
%       gMax = 1500;       
%       elit = 0.02;       
%       forca_mut = 0.0023; 
%       [fit_min,best_sol] = optsearch(X2,D2,gMax,elit,forca_mut)
%
%
% INPUTS:
%    X: (ntx3) - X(i,1)= tempo de processamento da tarefa i
%              - X(i,2)= penalidade por adiantamento da tarefa i
%              - X(i,3)= penalidade por adiantamento da tarefa i
%    D         - data de entrega
%    gMax      - numero maximo de geracoes
%    elit      - taxa de elitismo
%    forca_mut - forca da mutacao- % de trocas de tarefas por desvio padrao
%
% OUTPUTS:
%    fit_min  - best fitness
%    best_sol - best solution
%

%#ok<*AGROW>
      
   nt = size(X,1);   % no. tarefas
   
   % Dados do problema
   proc = X(:,1);  % tempo de processamento
   alpha = X(:,2); % penalidade por adiantamento
   beta = X(:,3);  % penalidade por atraso

   % Hiperparametros alem de (gMax,elit,forca_mut)
   np = 200;     % tam. populacao
   lifespan = 2; 


   % Gera populacao inicial
   % pop(i,k): tarefa i, individuo k
   pop = zeros(nt,np);
   for k=1:np
      pop(:,k) = randperm(nt)';
   end
   age = zeros(np,1);

   gen = 0;        % contador de geracoes
   fit_min = inf;  % fitness da melhor solucao global
   best_gen = [];  % fitness da melhor solucao da geracao
   mean_gen = [];  % media dos fitness para cada geracao
   best_global = []; % fitness da melhor solucao encontrada ate o momento
   best = [];      % guarda a melhor solucao
      
   % Funcao objetivo
   f = @(endVec) alpha'*max((D-endVec),0) + beta'*max((endVec-D),0);
   
   find_best_delay = false;
   while(gen<gMax) % criterios de parada: tempo e geracao
      age = age + 1;
      gen = gen + 1;
      if mod(gen,100)==0
         fprintf('Geracao %i/%i \n', gen, gMax);
      end
            
      % Avaliacao dos fitness
      fit = zeros(np,1); % soma dos adiantamentos e atrasos ponderados
      for k=1:np
         % Calcula ambos fitness para cada solucao
         endVec = zeros(nt,1); % endVec(i): entrega da tarefa i
         cumTime = 0;
         for i=1:nt
            % Adiciona tempo de processamento de cada tarefa
            cumTime = cumTime + proc(pop(i,k));
            endVec(pop(i,k))= cumTime;
         end
         
         if find_best_delay == true
            % [NOVO] Loop com otimizacao do delay inicial (secao aurea)
            % Taxa de decaimento: no. iteracoes ~ log_0.618(nt)
            tau=0.618;
            a = 0; d = D; b=round(a+(1-tau)*(d-a)); c=round(a+tau*(d-a));
            while d-a>1
               fb = f(endVec+b);
               fc = f(endVec+c);
               if fb <= fc
                  d = c; c = b;
                  b = round(a+(1-tau)*(d-a));
               else
                  a = b; b = c;
                  c = round(a+tau*(d-a));
               end
            end
            fit(k) = min(f(endVec+a),f(endVec+d)); % fitness do individuo
         else
            fit(k) = f(endVec); % fitness do individuo
         end
      end
      
      % Pior e melhor(factivel) individuos da geracao
      gen_max = max(fit);
      [gen_min,k] = min(fit);
      
      % Melhor individuo  - factivel - geral
      if(fit_min > gen_min)
         fit_min = gen_min;
         best_sol = pop(:,k);
      end
      best = [best fit_min];
      
      % Individuo medio e melhor (para plot)
      mean_gen = [mean_gen mean(fit)];
      best_gen = [best_gen gen_min]; % para plot
      best_global = [best_global, fit_min];
                  
      % Normaliza fitness
      fit = (repmat(gen_max,np,1)-fit)./repmat((gen_max-gen_min),np,1);

      % Aplica elitismo (sujeito ao lifespan dos individuos)
      n_elit = (round(elit*np/2)*2);
      [~,ordem] = sort(fit(age<lifespan)); % ordena sobreviventes
      ordem = ordem(end-n_elit+1:end);     % seleciona os melhores
      age(end-n_elit+1:end) = age(ordem);  % sobreviventes
      age(1:end-n_elit) = 0;               % novos individuos
      
      % Seleciona pais para reproducao
      P = selecionapais(fit,np-n_elit);

      % Recombinacao
      newPop = crossover(P,pop);

      % Mutacao
      newPop = mutate(newPop,forca_mut);
      
      % Populacao nova
      newPop(:,np-n_elit+1:end) = pop(:,ordem);
      
      % Muda a geracao
      pop = newPop;
   end
   
%    figure;
%    plot(1:gMax, best_gen); hold on
%    plot(1:gMax, mean_gen);
%    plot(1:gMax, best_global);
%    legend('Melhor/ger', 'Medio/ger', 'Melhor global');
end

function P = selecionapais(fit,np)
   % Amostragem universal estocastica (SUS)   
   fx = cumsum(fit);
   fx = fx ./ fx(end);
   
   inds = (rand/np:1/np:1); % marcadores de selecao
   
   P = zeros(np,1);
   pFit = 1; % indice na matriz fit
   pInd = 1; % indice do marcador
   while(pInd<=np)
      while(fx(pFit)<inds(pInd)), pFit = pFit+1; end
      P(pInd)=pFit;
      pInd = pInd + 1;
   end
   P = randsample(P,np);
   P = reshape(P,np/2,2);
end

function newPop = crossover(P,pop)
   nPais = size(P,1);
   nt = size(pop,1);

   newPop = zeros(size(pop));
   
   % Sorteia tipo de recombinacao
   for i=1:nPais
      tr = randsample(nt,2);
      tr = sort(tr);

      % Copia trecho dos pais
      newPop(tr(1):tr(2),2*i-1) = pop(tr(1):tr(2),P(i,2));
      newPop(tr(1):tr(2),2*i) = pop(tr(1):tr(2),P(i,1));

      % Completa com restante das tarefas
      inds = ismember(pop(:,P(i,1)),newPop(tr(1):tr(2),2*i-1));
      newPop([1:tr(1)-1,tr(2)+1:end],2*i-1) = ...
         pop(~inds,P(i,1));
      inds = ismember(pop(:,P(i,2)),newPop(tr(1):tr(2),2*i));
      newPop([1:tr(1)-1,tr(2)+1:end],2*i) = ...
         pop(~inds,P(i,2));
   end
end

function pop = mutate(pop,swaps_per_std)
   np = size(pop,2);
   nt = size(pop,1);
   
   for i=1:np
      strength = abs(randn());

      % 1 Desvio padrao = swaps_per_std*100 porcentagem de tarefas trocam
      z = floor(swaps_per_std*nt*strength);

      for j=1:z
         toChange1 = randi(nt);
         toChange2 = randi(nt);
         linha1 = pop(toChange1,i);
         pop(toChange1,i) = pop(toChange2,i);
         pop(toChange2,i) = linha1;
      end
   end
end

