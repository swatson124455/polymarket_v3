import React, { useEffect, useState } from 'react';
import axios from 'axios';

function App() {
  const [health, setHealth] = useState('...');
  const [stats, setStats] = useState(null);

  useEffect(() => {
    axios.get('/health').then(res => setHealth(res.data.status));
  }, []);

  const runBacktest = () => {
    axios.get('/backtest').then(res => setStats(res.data));
  };

  return (
    <div style={{ padding: '2rem', fontFamily: 'Arial' }}>
      <h1>Polymarket v3</h1>
      <p>API Status: {health}</p>
      <button onClick={runBacktest}>Run Backtest</button>
      {stats && (
        <ul>
          <li>ROI: {stats.roi}</li>
          <li>Max Drawdown: {stats.max_drawdown}</li>
          <li>Win Rate: {stats.win_rate}</li>
          <li>Sharpe Ratio: {stats.sharpe_ratio}</li>
        </ul>
      )}
    </div>
  );
}

export default App;
