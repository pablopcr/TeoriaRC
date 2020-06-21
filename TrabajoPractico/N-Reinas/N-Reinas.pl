%P90 (**) Eight queens problem

% This is a classical problem in computer science. The objective is to
% place eight queens on a chessboard so that no two queens are attacking 
% each other; i.e., no two queens are in the same row, the same column, 
% or on the same diagonal. We generalize this original problem by 
% allowing for an arbitrary dimension N of the chessboard. 

% We represent the positions of the queens as a list of numbers 1..N.
% Example: [4,2,7,3,6,8,5,1] means that the queen in the first column
% is in row 4, the queen in the second column is in row 2, etc.
% By using the permutations of the numbers 1..N we guarantee that
% no two queens are in the same row. The only test that remains
% to be made is the diagonal test. A queen placed at column X and 
% row Y occupies two diagonals: one of them, with number C = X-Y, goes
% from bottom-left to top-right, the other one, numbered D = X+Y, goes
% from top-left to bottom-right. In the test predicate we keep track
% of the already occupied diagonals in Cs and Ds.   

% The first version is a simple generate-and-test solution.

% queens_1(+N,-Qs) :- Qs es la soluccion del problema


queens_1(N,Qs) :- range(1,N,Rs), permu(Rs,Qs), test(Qs).

/*
*range(+N1,+N2,-L)--> Es cierto, si L unifica con una lista que empiece por el elemento N1 y termine con el elemento N2, siendo los demás elementos de la lista números
*                     consecutivos que van de N1 a N2.
* El caso base es cuando N1 y N2 son el mismo elemento, y L solo contiene ese elemento.
* Los demás casos, se dan cuando N1 es menor que N2, y el primer elemento de L unifica con N1, donde se hace una llamada recursiva con el valor N1+1 y L sin el primer
*  elemento.
*/

range(A,A,[A]).
range(A,B,[A|L]) :- A < B, A1 is A+1, range(A1,B,L).

/*
* permu(+L1,-L2)--> Es cierto si L2 es una posible permutacion de L1
* El caso base se da cuando tanto L1, como L2 son listas vacías.
* Los demás casos se dan cuando L1 y L2, no son listas vacias, donde coge el primer valor de L2 y se llama recursivamente al predicado sin ese valor en L1 ni en L2.
*
*dell(+E,+L,-L2)--> Es cierto cuando L2 unifica con el contenido de L menos el elemento E.
* El caso base se da cuando en la cabeza de L unifica con E y el resto de L unifica con L2.
* Los demás casos se dan cuando la cabeza de L no unifica con E, por lo que la cabeza de L pasa a la cabeza de L2 y siendo el resto el resultado de la llamada recursiva.
*/

permu([],[]).
permu(Qs,[Y|Ys]) :- del(Y,Qs,Rs), permu(Rs,Ys).

del(X,[X|Xs],Xs).
del(X,[Y|Ys],[Y|Zs]) :- del(X,Ys,Zs).

/*
* test(+Qs)--> Es cierto si se hace cierto test(Qs,1,[],[])

*test(+L1,+C,+L2,+L3)--> Se hace cierto cuando cada elemento de L1-C no unifica con ningun elemento de L2 y L1+C no unifica con ningun elemento de L3.
El caso base que utilizaremos, es cuando L1 esta vacía.

*memberchk(?E,+L)--> Es cierto cuand E unifica con algun elemento de la lista L
* \+ A --> es cierto cuando A no se haga cierta.
*/

test(Qs) :- test(Qs,1,[],[]).

% test(Qs,X,Cs,Ds) :- the queens in Qs, representing columns X to N,
% are not in conflict with the diagonals Cs and Ds

test([],_,_,_).
test([Y|Ys],X,Cs,Ds) :- 
	C is X-Y, \+ memberchk(C,Cs),
	D is X+Y, \+ memberchk(D,Ds),
	X1 is X + 1,
	test(Ys,X1,[C|Cs],[D|Ds]).

%--------------------------------------------------------------

% Now, in version 2, the tester is pushed completely inside the
% generator permu.

/*
queens_2(+N,-Qs)--> Qs es la solucción del problema. La diferencia con queens_1(+N,-Qs) es que llama a permu_test/4

permu_test(+L1,+L2,+C,+L3,+L4)--> Se hace cierto cuando cada elemento de L1-C no unifica con ningun elemento de L2 y L1+C no unifica con ningun elemento de L3 y ademas
L2 tiene que ser una permutacion de L1.
El caso base que utilizaremos, es cuando L1 esta vacía.

*/

queens_2(N,Qs) :- range(1,N,Rs), permu_test(Rs,Qs,1,[],[]).

permu_test([],[],_,_,_).
permu_test(Qs,[Y|Ys],X,Cs,Ds) :- 
	del(Y,Qs,Rs), 
	C is X-Y, \+ memberchk(C,Cs),
	D is X+Y, \+ memberchk(D,Ds),
	X1 is X+1,
	permu_test(Rs,Ys,X1,[C|Cs],[D|Ds]).
