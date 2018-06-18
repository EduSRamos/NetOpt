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
% ARQUIVO: 'linearopt.m' 
% DESCRICAO: Algoritmo de otimizacao linear para o problema.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#ok<*AGROW>

function [f_opt, t_opt, ad_opt, at_opt] = linearopt(X, D)
   % T: tarefa i, maquina j
   nt = size(X,1);
   p  = X(:,1);    % tempo de processamento das tarefas
   alpha = X(:,2); % penalidade por adiantamento
   beta = X(:,3);  % penalidade por atraso

   G = D + sum(p); % numero grande
   
   % Variaveis (indices)
   % 1) x(i,j)=1 tarefa i vem em algum momento antes de j (i<j)
   % 2) t(i) - momento de inicio da tarefa i
   % 3) a(i) - adiantamento da tarefa i
   % 4) b(i) - atraso da tarefa i
   ix = reshape(1:nt*nt, nt, nt);
   it = reshape(ix(end)+1:ix(end)+nt, nt,  1);
   iad = reshape(it(end)+1:it(end)+nt, nt,  1);
   iat = reshape(iad(end)+1:iad(end)+nt, nt,  1);
   nvar = iat(end);
   
   A = [];
   b = [];
   Aeq = [];
   beq = [];
   
   % Restricoes de sequenciamento (definidas para i<j)
   for i=1:nt-1
      for j=i+1:nt
         % Restricao #1: define sequenciamento - parte 1
         % t(i) + p(i) <= t(j) + G(1-x(i,j)) 
         %              == 
         % t(i) - t(j) + G*x(i,j) <= G - p(i)
         ind = [it(i), it(j), ix(i,j)];
         val = [1, -1, G];
         A = [A; sparse(1,ind,val,1,nvar)]; 
         b = [b; G-p(i)];
         
         % Restricao #2: define sequenciamento - parte 2
         % t(j) + p(j) <= t(i) + G*x(i,j) 
         %              == 
         % t(j) - t(i) - G*x(i,j) <= -p(j)
         ind = [it(j), it(i), ix(i,j)];
         val = [1, -1, -G];
         A = [A; sparse(1,ind,val,1,nvar)];
         b = [b; -p(j)];
      end
   end
   
   % Restricoes de adiantamento/atraso
   for i=1:nt
      % Restricao #3: adiantamento
      % b(i) >= (t(i)+p(i)) - D 
      %         == 
      % t(i) - b(i) <= D - p(i)
      ind = [it(i), iat(i)];
      val = [1, -1];
      A = [A; sparse(1,ind,val,1,nvar)];
      b = [b; D-p(i)];
      
      % Restricao #4: atraso
      % a(i) >= D-(t(i)+p(i)) 
      %         == 
      % -t(i) - a(i) <= -D + p(i)
      ind = [it(i), iad(i)];
      val = [-1, -1];
      A = [A; sparse(1,ind,val,1,nvar)];
      b = [b; -D+p(i)];
   end
   
   % Funcao objetivo: minimizar soma ponderada
   ind = [iad(:);iat(:)]; % indices das variaveis de [adiantamento,atraso]
   val = [alpha(:);beta(:)]; % penalidade de [adiantamento,atraso]
   fobj = sparse(1,ind,val,1,nvar);
   
   % Variaveis inteiras: sequenciamento
   intcon=ix(:);
   
   % Bounds
   lb = sparse(1,nvar); % todas sao >= 0
   ub = inf(1,nvar); % maioria e' <= inf
   ub(intcon)=1; % as binarias sao <= 1
   
   % Resolve MLIP
   % 'ObjectiveCutOff' - valor sabidamente factivel ajuda a cortar B&B
   options = optimoptions(@intlinprog,'display','iter',...
      'MaxNodes',1e9,'MaxTime',10000,'TolGapAbs',0.999);
   [x_opt,fval,ext] = intlinprog(fobj,intcon,A,b,Aeq,beq,lb,ub,options);
   if ext==2
      warning('resultado subotimo');
   end

   f_opt = fval;
   t_opt = x_opt(it(:));
   ad_opt = x_opt(iad(:));
   at_opt = x_opt(iat(:));
end