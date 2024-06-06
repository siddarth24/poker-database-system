// GlobalStateContext.js
import React, { createContext, useContext, useState } from 'react';

const defaultGlobalContext = {
    "api_endpoint": "http://127.0.0.1:5000/api"
}
const GlobalContext = createContext(defaultGlobalContext);

export default GlobalContext;