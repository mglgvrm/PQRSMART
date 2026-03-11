"use client";
import "./Popup.css";

interface PopupProps {
  message: string;
  onClose: () => void;
}

const Popup = ({ message, onClose }: PopupProps) => {
  return (
    <div className="popup-overlay">
      <div className="popup-content">
        <p>{message}</p>
        <button onClick={onClose} className="popup-button">
          Cerrar
        </button>
      </div>
    </div>
  );
};

export default Popup;
