import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Home from './components/Home';
import Nder from './components/Nder';
import CashForm from './components/CashForm';

const App = () => {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/nder" element={<Nder />} />
      <Route path="/cashform" element={<CashForm />} />
    </Routes>
  );
};

export default App;
