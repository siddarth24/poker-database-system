import React from 'react';
import { useNavigate } from "react-router-dom";

interface INavButtonProps {
    name: string;
    path: string;
}

const NavButton: React.FC<INavButtonProps> = (props) => {
    const {name, path} = props
    const navigate = useNavigate();
    const handleClick = () => {
        try{
            navigate(path)
        }catch(e){
            console.log("Error navigating to path: " + path)
        }
    }

    return(
        <button className='nav-button' onClick={handleClick}>
            {name}
        </button>
    )
}

export default NavButton