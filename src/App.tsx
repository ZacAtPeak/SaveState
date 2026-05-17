import { useState } from "react";
import BestiaryViewer from "./components/BestiaryViewer";
import "./App.css";

function App() {
  const [showBestiary, setShowBestiary] = useState(false);

  if (showBestiary) {
    return <BestiaryViewer onClose={() => setShowBestiary(false)} />;
  }

  return (
    <div className="home-container">
      <button className="book-icon-btn" onClick={() => setShowBestiary(true)} aria-label="Open Bestiary">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
          <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
          <path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15z" />
          <path d="M8 7h8M8 11h8M8 15h4" />
        </svg>
      </button>
    </div>
  );
}

export default App;