import React from 'react';

function Square({ value, onClick }) {
    const className = value === "#" ? 'black-square' : 'square'; 
    
    return (
        <button className={className} onClick={onClick}>
            {value !== '_' ? value : null}
        </button>
    );
}

export default Square;