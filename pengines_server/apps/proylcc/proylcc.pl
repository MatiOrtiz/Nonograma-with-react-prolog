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


coinciden([],[],1).
coinciden([],_Ys,0).
coinciden([Head|_Tail],[],0):- Head=="#".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%

put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 0, 0):-
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
	
	rowSat(RowN, newRow, RowsClues, RowStat).


%Busca las pistas correspondientes al numero de fila o columna.
%Caso Base: Num = 0, las pistas de la fila es el primer elemento de la lista de pistas.
findClues(0, [H| Tail], H).
%Caso Recursivo: Busca en la cola de la lista de pistas recursivamente.
findClues(LineNum, [H | Tail], Clues):-
	LineNumS is N - 1,
	findClues(LineNumS, Tail, Clues).




rowSat(RowN, Row, RowsClues,RowSat):-
	findClues(RowN, RowsClues, Clues),
	rowCounter(Row, List),
	checkRowSat(List, Clues, RowSat).
	%Recorrer fila y comparar.
	
	
	rowCounter([], []). % Caso base: la fila está vacía.
	rowCounter([X|Row] , List) :-
		(X == "#"" -> rowCounterConsec(Row, Rest, 1, RestCount), List = [RestCount|Rest] ; List = Rest),
		rowCounter(Row, Rest).
	
	rowCounterConsec([], [], Count, Count).

	rowCounterConsec([X|Row], Rest, Count, RestCount) :-
		(X == "#" -> NewCount is Count + 1, rowCounterConsec(Row, Rest, NewCount, RestCount) ;
                RestCount = Count, Rest = Row).


/*
rowCounter([], []).	
rowCounter([H|Row], List) :-
	(H == # -> rowCounterConsec(Row, List, 1, NewList) ;
		 rowCounter(Row, Rest)),
	List = NewList.
	


rowCounterConsec([], List, Count, NewList):-
	Count > 0 -> NewList = [Count | List].
rowCounterConsec([H|Row], List, Count, NewList) :-
	(H == # -> NewCount is Count + 1, rowCounterConsec(Row, List, NewCount, NewList);
		NewList = [Count | List],
		rowCounter(Row, Rest)
	).
*/	
	
	% Verificamos si RowSat es igual a la suma de los números en Clues.
checkRowSat(List, Clues, RowSat) :-
	sum_list(Clues, List),
	(RowSat =:= Sum -> RowSat = 1 ; RowSat = 0).


%TODO:
colSat(ColN, Grid, ColsClues, ColSat):-
	findClues(ColN, ColsClues, Clues).
	%Recorrer columna y comparar.

%gameStatus(Grid)



/*
		[[3], [1,2], [4], [5], [5]],  PistasFilas

		[[2], [5], [1,3], [5], [4]],  PistasColumnas

		[["#", _ , # , # , _ ],
		 ["X", _ ,"X", _ , _ ],
		 ["X", _ , _ , _ , _ ], % Grilla
		 ["#","#","#", _ , _ ],
		 [ _ , _ ,"#","#","#"]
		]
*/

% proylcc:rowCounter([a, "#", "#", b, "#", "#", "#", c], List).