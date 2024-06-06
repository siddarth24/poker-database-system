import React, { createContext, useState } from 'react';
import './App.css';
import AppRouter from './router/AppRouter';


function App() {
  return (
    <div className="App">
      <AppRouter></AppRouter>
    </div>
  );
}

export default App;
