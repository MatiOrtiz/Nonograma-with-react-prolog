/* eslint-disable no-unreachable */
import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import { ReactComponent as Cuadrado } from "./img/cuadrado.svg";
import { ReactComponent as Cruz } from "./img/cruz.svg";

let pengine;

function Game() {

  // State
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [useX, setUseX] = useState(false);
  const [rowSat, setRowSat] = useState([]);
  const [colSat, setColSat] = useState([]);
  const [statusText, setStatusText] = useState('Keep playing');
  const [handleClickEnabled, setHandleClickEnabled] = useState(true);


  useEffect(() => {
    // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    // The callback will run when the server is ready, and it stores the pengine instance in the pengine variable. 
    PengineClient.init(handleServerReady);
  }, []);

  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid)';
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
      }
    });
  }

  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting || !handleClickEnabled) {
      return;
    }
    // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    const content = useX ? 'X' : '#'; // Content to put in the clicked square.
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
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
      }
      setWaiting(false);
    });
    
    
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

  

  return (
    <div className="game">
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        onClick={(i, j) => handleClick(i, j)}
        rowSat={rowSat}
        colSat={colSat}
      />
      <div className="game-info">
        {statusText}
      </div>
      <ToggleButton/>
    </div>
  );
}

export default Game;