import React from 'react';
import Header from './header';
import NavButton from './navButton';

const HomePage: React.FC = () => {

    return (
        <div>
        <Header></Header>
        <div className='home-buttons'>
            <NavButton name="Games" path="/games" />
            <NavButton name="Replay" path="/replay" />
            <NavButton name="Admin" path="/admin" />
        </div>
        </div>
    )
}

export default HomePage