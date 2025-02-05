
import React from 'react';
import { useNavigate } from 'react-router-dom';

const Home = () => {
  const navigate = useNavigate();

  const navigateToNder = () => {
    navigate('/nder');
  };

  const navigateToCashForm = () => {
    navigate('/cashform');
  };

  return (
    <div className="flex flex-col items-center justify-center h-screen">
      <h1 className="text-3xl font-bold mb-6">Welcome to the Payment Portal</h1>
      <button
        onClick={navigateToNder}
        className="mb-4 p-3 bg-blue-500 text-white rounded hover:bg-blue-700 transition-colors"
      >
        Go to Nder Page
      </button>
      <button
        onClick={navigateToCashForm}
        className="p-3 bg-green-500 text-white rounded hover:bg-green-700 transition-colors"
      >
        Go to CashForm Page
      </button>
    </div>
  );
};

export default Home;

