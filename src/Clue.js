import React from 'react';

function Clue({ clue }) {
    const className= 'clue';
    function lineaSat(i){
        className= i === 1 ? 'clueSat' : 'clue';
    }
    return (
        <div className={className} >
            {clue.map((num, i) =>
                <div key={i}>
                    {num}
                </div>
            )}
        </div>
    );
}



export default Clue;