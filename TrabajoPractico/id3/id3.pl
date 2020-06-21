﻿%%%%%%%%%%%%%%%%%%%%%%
%% Given Predicates %%
%%%%%%%%%%%%%%%%%%%%%%


call1(F, X) :- G=.. [F,X], call(G).

%% name/1 --> Define la lista de todos los nombers.

name(batman).
name(robin).
name(alfred).
name(penguin).
name(catwoman).
name(joker).
name(batgirl).
name(riddler).

%% attribute/1--> Define la lista de todos los atributos.

attribute(man).
attribute(mask).
attribute(cape).
attribute(tie).
attribute(ears).
attribute(smoker).

%% class/1 --> Define la lista de todas las clases.

class(good).
class(evil).

%% Attributes. Define que atributo tiene cada individuo

man(batman).
man(robin). 
man(alfred).
man(penguin).
man(joker).
man(riddler).

mask(batman).
mask(robin).
mask(catwoman).
mask(batgirl).
mask(riddler).

cape(batman).
cape(robin).
cape(batgirl).

tie(alfred).
tie(penguin).

ears(batman).
ears(catwoman).
ears(batgirl).

smoker(penguin).

%% examples(?Ns) --> Es cierto cuando Ns es la lista de nombres N para los que existe una clase C que cumple clasede(+N,+C)
/*
    findall(-Termino, +Objetivo, +ListaResultado)
        Se hace cierto cuando cada los valores del Termino cumplen el Objetivo y todos juntos unifican con ListaResultado.
*/

classof(batman, good).
classof(robin, good).
classof(alfred, good).
classof(penguin, evil).
classof(catwoman, evil).
classof(joker, evil).

examples(Ns) :- findall(N, (name(N),class(C), classof(N, C)), Ns).

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Predicates %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

/*
    call(+X)--> Se hace cierto cuando X es cierto
    X =.. Lista --> X unifica con una lista que termina con Lista. ej: X = [_,Lista] 
*/

call1(F, X) :- G=.. [F,X], call(G).

%% sameclass(+Ns, ?C) --> Es cierto si todos los nobres de Ns son de la clase C
/*
    ! --> Descarta todos los puntos de elección creados desde que se inicio el predicado en el que aparece.
*/
sameclass([N1|[]],C):- name(N1),classof(N1,C),!.
sameclass([N1,N2|Ns],C):- name(N1),classof(N1,C),name(N2),classof(N2,C),sameclass([N2|Ns],C),!.

%partition(+Ns, +A, ?NT, ?NF) --> Divide Ns en NT y NF, teniendo en cuenta los nombres que no tienen como atributo A.
partition(Xs, A, NT, NF) :- findall(X, (attribute(A),member(X, Xs), call1(A, X)), NT), findall(Y, (attribute(A),member(Y, Xs),name(Y), not(call1(A, Y))), NF).

%%filterByClas(+Ns, +C, -Rs)--> Devuelve todos los nombres de Ns que cumplan class(C).
filterByClass(Ns,C,Rs):- findall(N, (member(N,Ns),class(C),name(N),classof(N,C)), Rs).

attributes(As):-findall(A,attribute(A),As),!.

%% proportion(+Ns, +C, +A, ?P)--> P son las proposiciones de la clase C que esta en la lista Ns para los cuales el atributo A es verdadero.
proportion([],_,_,0),!.
proportion(Ns, C, A, 0):- attribute(A),class(C), partition(Ns,A,NT,NF), filterByClass(NT,C,Rs), length(Rs,TLista),length(NT,T),T=0.
proportion(Ns, C, A, P):- attribute(A),class(C), partition(Ns,A,NT,NF), filterByClass(NT,C,Rs), length(Rs,TLista),length(NT,T),T>0,P is (TLista/T).

/*
    log(+X,-Y)--> Realiza el log de base 10 de X y lo unifica con Y.
    sum(+[Cabeza|Resto],+Ns,+A,+Acc,-E) --> En el caso que resto unifique con [], y P unifique con 0, E unifica con Acc. En el caso que E unifique con [] y P sea mayor
    que 0, E unifica con (Acc +P * log(P)). En el caso que Resto no unifique con [], se procede como los predicados anteriores, pero con la diferencia que se consulta
    otra vez a sum siendo [Cabeza2|Resto2] = Resto.
*/
sum([C|Cs],Ns,A,Acc,E):-  proportion(Ns,C,A,P), P=0, A1 is (Acc+0),sum(Cs,Ns,A,A1,E).
sum([C|Cs],Ns,A,Acc,E):-  proportion(Ns,C,A,P), P>0, log(P,R), A1 is (Acc+P*R),sum(Cs,Ns,A,A1,E).
sum([C|[]],Ns,A,Acc,E):- proportion(Ns,C,A,P), P>0, log(P,R), E is (Acc+P*R).
sum([C|[]],Ns,A,Acc,Acc):- proportion(Ns,C,A,P), P=0.

%% getClases(+Ns,-Cs)--> Cs unifica con una lista de todas las clases que hay en Ns
getClasses(Ns,Cs):-findall(C,(member(N,Ns),name(N),classof(N,C)),R),sort(R,Cs).

%% entropy(+Ns, +As, +A, ?E)--> E unifica con 1.0 si A no pertenece a As. En caso contrario, unifica con la entropia utilizada
entropy([], As, A,0):-attribute(A),member(A,As).
entropy(_, As, A, 1.0):- attribute(A),not(member(A,As)).
entropy(Ns, As, A, E):- attribute(A),member(A,As), getClasses(Ns,Clases), sum(Clases,Ns,A,0,S), E is (-1*S).

%minatr(+Ns, +As, ?M)--> M unifica con el elemento de As con menor entropia en Ns. Si hay varios.
minatr(Ns,[A1|[]],A1).
minatr(Ns,[A1,A2|[]],A1):-attribute(A1),attribute(A2), entropy(Ns,[A1,A2|[]],A1,E1),entropy(Ns,[A1,A2|[]],A2,E2),E1=<E2,!.
minatr(Ns, [A1,A2|[]], A2):- attribute(A1),attribute(A2),entropy(Ns,[A1,A2|[]],A1,E1),entropy(Ns,[A1,A2|[]],A2,E2),E1>E2,!.
minatr(Ns, [A1,A2|As], M):- attribute(A1),attribute(A2), entropy(Ns,[A1,A2|As],A1,E1),entropy(Ns,[A1,A2|As],A2,E2),E1=<E2,minatr(Ns,[A1|As],M),!.
minatr(Ns, [A1,A2|As], M):- attribute(A1),attribute(A2),entropy(Ns,[A1,A2|As],A1,E1),entropy(Ns,[A1,A2|As],A2,E2),E1>E2,minatr(Ns,[A2|As],M),!.

%%partitiona classs entre goods y evils, la sublista que tenga más elementos es la de la class más representativa
partitionClasses(Cs,Bs,Ms) :- findall(C, (member(C, Cs), class(C) == class(good)), Bs), findall(C, (member(C, Cs), class(C) == class(evil)), Ms),!.

%% maxcla(+Ns, ?C)--> C unifica con la clase mas representativa de Ns
maxcla(Ns,C):-length(Ns,L),L>0,class(C),getClasses(Ns,Cs),partitionClasses(Cs,Bs,Ms), length(Bs,B), length(Ms,M), B>=M,C=good,!.
maxcla(Ns,C):-length(Ns,L),L>0,class(C),getClasses(Ns,Cs),partitionClasses(Cs,Bs,Ms), length(Bs,B), length(Ms,M), M>B,C=evil,!.

%% id3(+Ns, +As, +C, ?T)-->T unifica con el arbol de decision donde la lista de nombres es Ns, la lista de atributos es As y la clase C. Cada hoja es una clase.
id3(Ns, [], C, leaf(C1)):- maxcla(Ns,C1),!.
id3([], As, C, T):- T=leaf(C),!.
id3(Ns, As, C, T):- sameclass(Ns,C1),T=leaf(C1),!.
id3(Ns,As,C,T):- minatr(Ns,As,A), delete(As,A,R), partition(Ns,A,NT,NF), id3(NT,R,C,T1), id3(NF,R,C,T2), (T=node(A,T1, T2)),!.

%%tree(?T)-->  Es cierto si T unifica con el arbol creado con el id3
tree(T):- examples(Ns),attributes(As), maxcla(Ns,C), id3(Ns,As,C,T).

%%clasify(+T, +N, ?C)--> C unifica con la clase del nombre N segun el arbol T.
classify(T, N,C):-name(N),classof(N,C),!.
classify(leaf(C), N,C):-name(N).
classify(node(A,T1,T2), N,C):- name(N),call1(A,N), classify(T1,N,C),!.
classify(node(A,T1,T2), N,C):- classify(T2,N,C),!.

%% clasification(+Ns, ?Xs)--> Xs unifica con una lista de (N,C) tal que N unifica con un elemento de Ns y C es la clase de ese elemento.
clasification(Ns, Xs):-tree(T),classifyaux(T,Ns,[],Xs).

%%función auxiliar que almacena en Aux los names de los elementos que no tienen una class.
classifyaux(T,[],Aux,Xs):-Xs=Aux.
classifyaux(T,[N|Ns],Aux,Xs):-classify(T,N,C),classof(N,C), classifyaux(T,Ns,Aux,Xs),!.
classifyaux(T,[N|Ns],Aux,Xs):-classify(T,N,C), classifyaux(T,Ns,[(N,C)|Aux],Xs),!.
