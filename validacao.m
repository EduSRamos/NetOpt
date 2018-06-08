% Instancia base: 3 tarefas
X = generateinstance(5,1);

% Teste #1: Apenas penalidade por adiantamento
%    Comportamento esperado: todas terminam apos a data limite
X1 = X; X1(:,3) = 0; % remove punicao por atraso
D1 = 40;
[f, t, ad, at] = linearopt(X1,D1);

if f>0
   error('Erro no teste 1\n');
end

% Teste #2: Apenas ultima tarefa c/ penal. por atraso
%    Comportamento esperado: ultima tarefa deve ser a primeira a ser exec.
X2 = X1;
X2(end,3) = X2(end,2); X2(end,2) = 0;
D2 = 40;

[f, t, ad, at] = linearopt(X2,D2);

if f>0
   error('Erro no teste 2\n');
end

% Teste #3: Apenas penalidade por atraso
%    Comportamento esperado: ultima tarefa termina antes da data
X3 = X; X3(:,2) = 0; 
D3 = sum(X(:,1)); % coloca limite exato
[f, t, ad, at] = linearopt(X3,D3);

if f>0
   error('Erro no teste 3\n');
end

D3_2 = floor(D3/2); % coloca limite meio do caminho
[f, t, ad, at] = linearopt(X3,D3_2);
if f==0
   error('Erro no teste 3_2\n');
end

D3_3 = floor(D3/4); % coloca limite 1/4 do caminho
[f, t, ad, at] = linearopt(X3,D3_3);
if f==0
   error('Erro no teste 3_3\n');
end

D3_4 = 1; % coloca limite como 1
[f, t, ad, at] = linearopt(X3,D3_4);
if f==0
   error('Erro no teste 3_4\n');
end