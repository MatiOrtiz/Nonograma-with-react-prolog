import React from 'react';

function Clue({ clue,done }) {
    return (
        <div className={`${done ? 'clueSat' : 'clue'}`} >
            {clue.map((num, i) =>
                <div key={i}>
                    {num}
                </div>
            )}
        </div>
    );
}



export default Clue;