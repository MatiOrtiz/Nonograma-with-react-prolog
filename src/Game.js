/* eslint-disable no-unreachable */
import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import SolutionBoard from './SolutionBoard';
import { ReactComponent as Cuadrado } from "./img/cuadrado.svg";
import { ReactComponent as Cruz } from "./img/cruz.svg";
import { ReactComponent as Visible} from "./img/visible.svg"
import { ReactComponent as Oculto} from "./img/oculto.svg"
import { ReactComponent as Lampara} from "./img/lampara.svg"

let pengine;

function Game() {

  // State
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [useX, setUseX] = useState(false);
  const [viewTable, setViewTable]= useState(false);
  const [rowSat, setRowSat] = useState([]);
  const [colSat, setColSat] = useState([]);
  const [statusText, setStatusText] = useState('Keep playing');
  const [handleClickEnabled, setHandleClickEnabled] = useState(true);
  const [solution, setSolution] = useState(null);
  const [lastSelectedPosition, setLastSelectedPosition] = useState(false);
  const [waitForClick, setWaitForClick] = useState(false);
  const [clueClick, setClueClick] = useState(false);


  useEffect(() => {
    function handleServerReady(instance) {
      pengine = instance;
      const queryS = 'init(RowClues, ColumClues, Grid)';
      pengine.query(queryS, (success, response) => {
        if (success) {
          setGrid(response['Grid']);
          setRowsClues(response['RowClues']);
          setColsClues(response['ColumClues']);
          fetchSolution(response['Grid'], response['RowClues'], response['ColumClues']);

          checkSatisfaction(response['Grid'], response['RowClues'], response['ColumClues']);
        }
      });
    }
    // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    // The callback will run when the server is ready, and it stores the pengine instance in the pengine variable. 
    PengineClient.init(handleServerReady);
  }, []);


  function fetchSolution(initialGrid, initialRowClues, initialColClues) {
    const gridS = JSON.stringify(initialGrid).replaceAll('"_"', '_');
    const rowsCluesS = JSON.stringify(initialRowClues);
    const colsCluesS = JSON.stringify(initialColClues);
    const queryS = `findSolution(${gridS}, ${rowsCluesS}, ${colsCluesS}, Solution)`;

    pengine.query(queryS, (success, response) => {
        if (success) {
            setSolution(response['Solution']);
        }
    });
  }

  function checkSatisfaction(grid, rowsClues, colsClues) {
    const tempRowSat = [];
    const tempColSat = [];

    rowsClues.forEach((_, i) => {
      const row = JSON.stringify(grid[i]).replaceAll('"_"', '_');
      const queryRowSat = `rowSat(${i}, ${row}, ${JSON.stringify(rowsClues)}, RowSat)`;
      pengine.query(queryRowSat, (success, response) => {
        if (success && response['RowSat'] === 1) {
          tempRowSat.push(i);
        }
      });
    });
    
    colsClues.forEach((_, j) => {
      const colS = JSON.stringify(grid).replaceAll('"_"', '_');
      const queryColSat = `colSat(${j}, ${colS}, ${JSON.stringify(colsClues)}, ColSat)`;
      pengine.query(queryColSat, (success, response) => {
        if (success && response['ColSat'] === 1) {
          tempColSat.push(j);
        }
      });
    });

    setRowSat(tempRowSat);
    setColSat(tempColSat);

  }

  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting || !handleClickEnabled) {
      return;
    }
    // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    let content = useX ? 'X' : '#'; // Content to put in the clicked square.
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    if(clueClick){
      content = solution[i][j];
    }
    //Si el botón revelar celda está habilitado, y el valor en i,j es correcto, entonces no debe hacer la inserción.
    if(! (clueClick && content === grid[i][j])){
      const queryS = `put("${content}", [${i},${j}], ${rowsCluesS}, ${colsCluesS}, ${squaresS}, ResGrid, RowSat, ColSat)`; // queryS = put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
      setWaiting(true);
      pengine.query(queryS, (success, response) => {
        if (success) {
          setGrid(response['ResGrid']);
    
          if(response['RowSat']) {
            setRowSat([...rowSat, i]);
          } else {
            setRowSat(rowSat.filter(e => e !== i));
          }
          if(response['ColSat']) {
            setColSat([...colSat, j]);
          } else {
            setColSat(colSat.filter(e => e !== j));
          }
          checkGameStatus(response['ResGrid']);

          // Actualizar la última posición seleccionada después de completar la consulta
          setLastSelectedPosition({ row: i, col: j });
        }
        setWaiting(false);
      });
    }
    setWaitForClick(false);
    if(clueClick){
      handleButtonClueClick(false); 
    } 
  }

  function handleButtonClueClick() {
    // Verificar si waitForClick es true para evitar la ejecución de handleButtonClueClick
    if (waitForClick) {
      return;
    }
    setClueClick((prev) => !prev);
    
  }


  function checkGameStatus(grid){
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_');
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    const queryStatus =  `checkStatus( ${rowsCluesS}, ${colsCluesS}, ${squaresS}, Status)`;
    pengine.query(queryStatus, (success, response) => {
      if (success) {
          const status = response['Status'];
          if(status === 1){
            //Fin del juego.
            setStatusText('Winner!');
            setHandleClickEnabled(false);
            completeGrid(grid);
          } else {
            setHandleClickEnabled(true);
          }
      }
    });
  }

function completeGrid(grid){
  const squaresS = JSON.stringify(grid).replaceAll('"_"', '_');
  const queryS = `completeGrid(${squaresS}, NewGrid)`;
  pengine.query(queryS, (success, response) => {
    if (success) {
      setGrid(response['NewGrid']);
    }
  });
}


  if (!grid) {
    return null;
  }

  const handleCheckboxChange = () => {
    setUseX((prev) => !prev);
  };

  const handleCheckboxClueChange = () => {
    setViewTable((prev) => !prev);
    setHandleClickEnabled((prev)=> !prev);
  };

  const ToggleButton = () => {
    return (
      <div className='toggle-btn'>
        <input className='toggle-input' type='checkbox' id='switchToggle' onChange={handleCheckboxChange} checked={useX} />
        <label className='toggle-label' htmlFor='switchToggle'>
          <Cuadrado className='cuadrado'/>
          <Cruz className='cruz'/>
        </label>
      </div>
    );
  };

  const ToggleButtonTable = () => {
    return (
      <div className='toggle-table-btn'>
        <input className='toggle-table-input' type='checkbox' id='switchToggleTable' onChange={handleCheckboxClueChange} checked={viewTable}/>
        <label className='toggle-table-label' htmlFor='switchToggleTable'>
          <Visible className='visible'/>
          <Oculto className='oculto'/>
        </label>
      </div>
    );
  };

  const ButtonClue = () => {
    const className = clueClick ? 'clue-btn-clicked' : 'clue-btn';
    return (
      <button type='button' className={className} onClick={handleButtonClueClick} checked={lastSelectedPosition}>
        <Lampara className='lampara'/>
      </button>
    );
  }

  return (
    <div className="game">
      <div className="game-info">
        {statusText}
      </div>
      <Board 
        grid={grid} 
        rowsClues={rowsClues} 
        colsClues={colsClues} 
        onClick={handleClick} 
        rowSat={rowSat} 
        colSat={colSat} 
      />
      {viewTable && (
        <div className="game-section">
          <div className='solution-text'>
            {'SOLUTION'}
          </div>
          <SolutionBoard 
            solution={solution} 
          />
        </div>
      )}
      <ToggleButton/>
      <ToggleButtonTable/>
      <ButtonClue/>
    </div>
  );
}

export default Game;