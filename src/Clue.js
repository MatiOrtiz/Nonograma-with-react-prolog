import React from 'react';

function Clue({ clue,checked }) {
    return (
        <div className={`${checked ? 'clueSat' : 'clue'}`} >
            {clue.map((num, i) =>
                <div key={i}>
                    {num}
                </div>
            )}
        </div>
    );
}



export default Clue;