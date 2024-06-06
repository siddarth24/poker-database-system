import React from 'react';
import NavButton from './navButton';

const Header: React.FC = () => {

    return (
        <div className='header'>
            <NavButton name="Home" path="/" />
        </div>
    )
}

export default Header