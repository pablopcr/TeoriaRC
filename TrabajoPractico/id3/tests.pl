%% casos de tests

call2(L) :- G=.. L, call(G).


test(1, A) :- tree(A). % Devuelve el árbol que genera el conjunto de entrenamiento

test(2, Xs) :- findall(N,name(N),Ns),clasification(Ns,Xs). %% dime todos lo que no tiene clase, y clasificalo