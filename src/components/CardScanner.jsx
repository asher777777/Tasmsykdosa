import React, { useRef, useState } from 'react';
import Webcam from 'react-webcam';
import Tesseract from 'tesseract.js';

const CardScanner = ({ onScanComplete }) => {
  const webcamRef = useRef(null);
  const [scanning, setScanning] = useState(false);

  const capture = async () => {
    setScanning(true);
    const imageSrc = webcamRef.current.getScreenshot();
    Tesseract.recognize(
      imageSrc,
      'eng',
      {
        logger: (m) => console.log(m),
      }
    ).then(({ data: { text } }) => {
      console.log(text);
      onScanComplete(text);
      setScanning(false);
    });
  };

  return (
    <div>
      <Webcam
        audio={false}
        ref={webcamRef}
        screenshotFormat="image/jpeg"
        width="100%"
      />
      <button onClick={capture} disabled={scanning}>
        {scanning ? 'Scanning...' : 'Scan Card'}
      </button>
    </div>
  );
};

export default CardScanner;
