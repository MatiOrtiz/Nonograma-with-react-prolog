import React from 'react';
import Square from './Square';

function SolutionBoard({ solution }) {
    const numOfRows = solution.length;
    const numOfCols = solution[0].length;
    return (
        <div className="solution-board"
            style={{
                gridTemplateRows: `repeat(${numOfRows}, 40px)`,
                gridTemplateColumns: `repeat(${numOfCols}, 40px)`
            }}>
            {solution.map((row, i) =>
                row.map((cell, j) =>
                    <Square
                        value={cell}
                        key={i + j}
                    />
                )
            )}
        </div>
    );
}

export default SolutionBoard;
