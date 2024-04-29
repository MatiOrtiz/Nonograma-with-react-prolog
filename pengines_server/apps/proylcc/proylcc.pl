:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY is the result of replacing the occurrence of X in position XIndex of Xs by Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%

put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, RowSat, ColSat):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),
	rowSat(RowN,NewRow,RowsClues,RowSat),
	colSat(ColN, Grid,ColsClues, ColSat).


%Busca las pistas correspondientes al numero de fila o columna.
%Caso Base: Num = 0, las pistas de la fila es el primer elemento de la lista de pistas.
findClues(0, [H| _], H).
%Caso Recursivo: Busca en la cola de la lista de pistas recursivamente.
findClues(LineNum, [_H | Tail], Clues):-
	LineNumS is LineNum - 1,
	findClues(LineNumS, Tail, Clues).


%RowSat = 1 Si la fila N satisface las pistas.
rowSat(RowN, Row, RowsClues,RowSat):-
	findClues(RowN, RowsClues, Clues),
	lineCounter(Row, [], List),
	checkLineSat(List, Clues, RowSat).
	
%Predicado para transformar el estado actual de una linea a una lista.
%Caso Base
lineCounter([], List, Resultado):-
	reverse(List, Resultado).
%Casos recursivos:
lineCounter([H| Tail], List,Resultado) :-
	(H == "#" -> lineCounterConsec(Tail, 1, List, Resultado);
		lineCounter(Tail, List,Resultado)).

lineCounterConsec([], Count, List, Resultado):-
	lineCounter([], [Count| List], Resultado).
lineCounterConsec([H| Tail], Count, List, Resultado):-
	(H == "#" -> Ncount is Count+1, lineCounterConsec(Tail, Ncount, List, Resultado) ; 
		(Count > 0 -> lineCounter(Tail, [Count| List], Resultado);
			lineCounter(Tail, List, Resultado))
	).


% LineSat = 1 si el estado de la lista coincide con las pistas.
checkLineSat(List, Clues, LineSat) :-
    (List = Clues -> LineSat = 1 ; LineSat = 0).


%ColSat = 1 si la columna N satisface las pistas.
colSat(ColN, Grid, ColsClues, ColSat):-
	findClues(ColN, ColsClues, Clues),
	getColN(ColN, Grid, [], Col),
	lineCounter(Col, [], List),
	checkLineSat(List, Clues, ColSat).

%Transforma una columna en una lista.
%Caso Base:
getColN(_ColN, [], List, Col):-
	reverse(List, Col).
%Caso Recursivo:
getColN(ColN, [H| RestoDeGrilla], List, Col) :-
	getByIndex(ColN, H, Item),
	getColN(ColN, RestoDeGrilla, [Item| List], Col).
	

%Recupera el elemento N-esimo de una lista.
getByIndex(0, [H| _Tail], H).	
getByIndex(N, [_H| Tail], Item) :-
	NS is N - 1,
	getByIndex(NS, Tail, Item).


/*
		[[3], [1,2], [4], [5], [5]],  PistasFilas

		[[2], [5], [1,3], [5], [4]],  PistasColumnas

% Grilla
		[["#", _ , # , # , _ ],
		 ["X", _ ,"X", _ , _ ],
		 ["X", _ , _ , _ , _ ], 
		 ["#","#","#", _ , _ ],
		 [ _ , _ ,"#","#","#"]
		]
*/

