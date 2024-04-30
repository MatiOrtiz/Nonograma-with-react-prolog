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
    checkStatus(RowsClues, ColsClues, Grid, Status),
    (Status == 1 ->
        % Si el estado es 1, no se realiza ninguna acción y se mantienen los valores de entrada.
        NewGrid = Grid,
        RowSat = 0,
        ColSat = 0
    ;   % Si el estado es 0, se ejecuta el resto del predicado normalmente.
        replace(Row, RowN, NewRow, Grid, NewGrid),
        (replace(Cell, ColN, _, Row, NewRow), Cell == Content
        ;
        replace(_Cell, ColN, Content, Row, NewRow)),
        rowSat(RowN, NewRow, RowsClues, RowSat),
        colSat(ColN, NewGrid, ColsClues, ColSat)
    ).


%Busca las pistas correspondientes al numero de fila o columna.
%Caso Base: Num = 0, las pistas de la fila es el primer elemento de la lista de pistas.
findClues(0, [H| _], H).
%Caso Recursivo: Busca en la cola de la lista de pistas recursivamente.
findClues(LineNum, [_H | Tail], Clues):-
	LineNumS is LineNum - 1,
	findClues(LineNumS, Tail, Clues).


%RowSat = 1 Si la fila N satisface las pistas.
rowSat(RowN, Row, RowsClues, RowSat):-
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




checkStatus(RowsClues, ColsClues, [H| Tail], Status):-
	length([H| Tail], GridSize),
	GridSizeS is GridSize - 1,
	(checkFilas(0, RowsClues,[H| Tail]), checkColumns(GridSizeS, ColsClues, [H| Tail]) -> Status = 1 
		; Status = 0).
	
	

%Caso Base:
checkFilas(_RowN, _RowsClues, []).
%Caso Recursivo
checkFilas(RowN, RowsClues, [H| Tail]):-
	rowSat(RowN, H, RowsClues, RowSat),
	(RowSat == 1 -> RowNS is RowN + 1,
		checkFilas(RowNS, RowsClues, Tail)).


%Caso Base:
checkColumns(0, ColsClues, Grid):-
	colSat(0, Grid, ColsClues, ColSat),
	ColSat == 1.
%Caso Recursivo
checkColumns(ColN, ColsClues, Grid):-
	colSat(ColN, Grid, ColsClues, ColSat),
	(ColSat == 1 -> ColNS is ColN - 1,
		checkColumns(ColNS, ColsClues, Grid)).




/*
		[[3], [1,2], [4], [5], [5]],  PistasFilas

		[[2], [5], [1,3], [5], [4]],  PistasColumnas

% Grilla
		[["X", "#", "#", "X", "X" ],
		 ["X", "#", "X", "X", "X" ],
		 ["X", "#", "#", "X", "#" ], 
		 ["#", "#", "#", "#", "#" ],
		 ["#", "#", "#", "#", "#"]
		]
*/

% proylcc:put("#", [0,1],[[3], [1,2], [4], [5], [5]], [[2], [5], [1,3], [5], [4]],  [ ["X", "#", "#", "X", "X"], ["X", "#", "X", "X", "X"], ["X", "#", "#", "X", "#"], ["#", "#", "#", "X", "X"], ["#", "#", "#", "#", "#"] ], GrillaRes, RowSat, ColSat).
% proylcc:checkStaus([[3], [1,2], [4], [5], [5]], [[2], [5], [1,3], [5], [4]], [ ["X", "#", "#", "X", "X"], ["X", "#", "X", "X", "X"], ["X", "#", "#", "X", "#"], ["#", "#", "#", "X", "X"], ["#", "#", "#", "#", "#"] ], Status ).
% proylcc:checkStatus( [ [2], [1], [2, 1], [3], [5] ], [ [2], [5], [1,3], [1], [1, 1] ], [ ["X", "#", "#", "X", "X"], ["X", "#", "X", "X", "X"], ["X", "#", "#", "X", "#"], ["#", "#", "#", "X", "X"], ["#", "#", "#", "#", "#"]] , Status ).

% proylcc:checkFilas(0, [ [2],[1], [2, 1], [3], [5] ], [ ["X", "#", "#", "X", "X"], ["X", "#", "X", "X", "X"], ["X", "#", "#", "X", "#"], ["#", "#", "#", "X", "X"], ["#", "#", "#", "#", "#"] ])
% proylcc:checkFilas(0, [ [2],[1], [2, 1], [3], [5] ], [ ["#", "#", "#", "X", "X"], ["X", "#", "X", "X", "X"], ["X", "#", "#", "X", "#"], ["#", "#", "#", "X", "X"], ["#", "#", "#", "#", "#"] ]) 

% proylcc:checkColumns(4, [ [2], [5], [1, 3], [5], [4] ], [ ["X", "#", "#", "#", "X", "X"], ["X", "#", "X", "#", "#"], ["X", "#", "#", "#", "#"], ["#", "#", "#", "#", "#"], ["#", "#", "#", "#","#"] ]).
