import React, { useState, useEffect, useRef } from 'react';
import CardScanner from './CardScanner';

const MOSAD_ID = import.meta.env.VITE_NEDARIM_MOSAD_ID;
const API_VALID = import.meta.env.VITE_NEDARIM_API_KEY;

export function NedarimForm() {
  const iframeRef = useRef(null);
  const [iframeHeight, setIframeHeight] = useState(0);
  const [showWaitFrame, setShowWaitFrame] = useState(true);
  const [showWaitPay, setShowWaitPay] = useState(false);
  const [showPayButton, setShowPayButton] = useState(true);
  const [showSuccess, setShowSuccess] = useState(false);
  const [error, setError] = useState('');
  const [result, setResult] = useState('');
  const [showTokef, setShowTokef] = useState(false);

  useEffect(() => {
    const handleMessage = (event) => {
      console.log(event.data);
      if (event.data.Name === 'Height') {
        setIframeHeight(parseInt(event.data.Value) + 15);
        setShowWaitFrame(false);
      } else if (event.data.Name === 'TransactionResponse') {
        setResult(`TransactionResponse: ${JSON.stringify(event.data.Value)}`);
        console.log(event.data.Value);
        
        if (event.data.Value.Status === 'Error') {
          setError(event.data.Value.Message);
          setShowWaitPay(false);
          setShowPayButton(true);
        } else {
          setShowWaitPay(false);
          setShowSuccess(true);
        }
      }
    };

    if (window.addEventListener) {
      window.addEventListener("message", handleMessage, false);
    } else {
      window.attachEvent("onmessage", handleMessage);
    }

    // Initialize iframe
    if (iframeRef.current) {
      iframeRef.current.onload = () => {
        console.log('StartNedarim');
        postNedarim({ 'Name': 'GetHeight' });
      };
      iframeRef.current.src = "https://matara.pro/nedarimplus/iframe?language=he";
    }

    return () => {
      if (window.removeEventListener) {
        window.removeEventListener("message", handleMessage);
      }
    };
  }, []);

  const postNedarim = (data) => {
    if (iframeRef.current?.contentWindow) {
      iframeRef.current.contentWindow.postMessage(data, "*");
    }
  };

  const handlePayment = () => {
    setResult('');
    setShowPayButton(false);
    setShowSuccess(false);
    setShowWaitPay(true);
    setError('');

    postNedarim({
      'Name': 'FinishTransaction2',
      'Value': {
        'Mosad': MOSAD_ID,
        'ApiValid': API_VALID,
        'PaymentType': document.getElementById('PaymentType')?.value || 'Ragil',
        'Currency': '1',
        'Zeout': '',
        'FirstName': document.getElementById('ClientName')?.value || '',
        'LastName': '',
        'Street': document.getElementById('Street')?.value || '',
        'City': document.getElementById('City')?.value || '',
        'Phone': '',
        'Mail': '',
        'Amount': document.getElementById('Amount')?.value || '',
        'Tashlumim': '1',
        'Groupe': '',
        'Comment': document.getElementById('Comment')?.value || '',
        'Param1': '',
        'Param2': '',
        'ForceUpdateMatching': '1',
        'CallBack': '',
        'CallBackMailError': '',
        'Tokef': showTokef ? document.getElementById('Tokef')?.value : ''
      }
    });
  };

  const handleTokefChange = () => {
    setShowTokef(true);
    if (iframeRef.current) {
      iframeRef.current.src = 'https://matara.pro/nedarimplus/iframe?language=he&Tokef=Hide';
    }
  };

  const handleSecurityIconsHide = () => {
    setShowTokef(false);
    if (iframeRef.current) {
      iframeRef.current.src = 'https://matara.pro/nedarimplus/iframe?language=he&Picture=Hide';
    }
  };

  const handleHebrewDisplay = () => {
    setShowTokef(false);
    if (iframeRef.current) {
      iframeRef.current.src = 'https://matara.pro/nedarimplus/iframe?language=he';
    }
  };

  const handleAddCaptcha = () => {
    setShowTokef(false);
    if (iframeRef.current) {
      iframeRef.current.src = 'https://matara.pro/nedarimplus/iframe?language=he&Captcha=1';
    }
  };

  const handleScanComplete = (text) => {
    // Process the scanned text and fill in the fields
    console.log('Scanned text:', text);
    // Example: Extract card number and expiration date from the scanned text
    const cardNumber = text.match(/\d{4} \d{4} \d{4} \d{4}/);
    const expirationDate = text.match(/\d{2}\/\d{2}/);
    if (cardNumber) {
      document.getElementById('CardNumber').value = cardNumber[0];
    }
    if (expirationDate) {
      document.getElementById('Tokef').value = expirationDate[0];
    }
  };

  return (
    <div dir="rtl" className="max-w-lg mx-auto p-6 border-2 border-[#5f9ea0]">
      <div className="text-center">
        <h3 className="text-xl font-bold mb-2">טופס תשלום נדרים פלוס</h3>
        <span className="text-gray-500 text-sm">המסגרת האדומה היא האזור המאובטח</span>
      </div>

      <div className="space-y-4 my-6">
        <div>
          <label className="block text-gray-500 mb-1">שם:</label>
          <input
            id="ClientName"
            type="text"
            maxLength={30}
            className="w-full p-2 border rounded"
          />
        </div>

        <div>
          <label className="block text-gray-500 mb-1">רחוב:</label>
          <input
            id="Street"
            type="text"
            maxLength={30}
            className="w-full p-2 border rounded"
          />
        </div>

        <div>
          <label className="block text-gray-500 mb-1">עיר:</label>
          <input
            id="City"
            type="text"
            maxLength={30}
            className="w-full p-2 border rounded"
          />
        </div>

        <div>
          <label className="block text-gray-500 mb-1">סכום:</label>
          <input
            id="Amount"
            type="number"
            maxLength={30}
            className="w-full p-2 border rounded"
          />
        </div>

        <div>
          <label className="block text-gray-500 mb-1">הערות:</label>
          <textarea
            id="Comment"
            rows={3}
            className="w-full p-2 border rounded"
          />
        </div>

        {showTokef && (
          <div>
            <label className="block text-gray-500 mb-1">תוקף:</label>
            <input
              id="Tokef"
              type="text"
              maxLength={30}
              placeholder="MM/YY"
              className="w-full p-2 border rounded"
            />
          </div>
        )}

        <div>
          <label className="block text-gray-500 mb-1">סוג תשלום:</label>
          <select
            id="PaymentType"
            className="w-full p-2 border rounded"
          >
            <option value="Ragil">תשלום רגיל</option>
            <option value="HK">הוראת קבע</option>
            <option value="CreateToken">יצירת טוקן</option>
          </select>
        </div>
      </div>

      <div id="iframe-container" className="my-6">
        <iframe
          ref={iframeRef}
          className="w-full border border-red-400"
          style={{ height: `${iframeHeight}px` }}
          scrolling="no"
          title="Nedarim Payment"
        />
        
        {showWaitFrame && (
          <div className="text-center py-4 text-gray-500">
            <div className="w-12 h-12 border-4 border-blue-400 rounded-full animate-spin mx-auto mb-2" />
            מתחבר לשרת מאובטח...
          </div>
        )}
      </div>

      {showSuccess && (
        <div className="font-bold text-green-600 p-4 text-center">
          התשלום בוצע בהצלחה
        </div>
      )}

      {showPayButton && (
        <div className="my-4 text-center">
          <button
            onClick={handlePayment}
            className="w-full p-3 bg-[#17a2b8] text-white rounded cursor-pointer hover:bg-[#138496] transition-colors"
          >
            ביצוע תשלום
          </button>
          {error && (
            <div className="font-bold text-red-600 p-2">{error}</div>
          )}
        </div>
      )}

      {showWaitPay && (
        <div className="text-center py-4 text-gray-500">
          <div className="w-12 h-12 border-4 border-blue-400 rounded-full animate-spin mx-auto mb-2" />
          מבצע חיוב, נא להמתין...
        </div>
      )}

      {result && (
        <div className="text-center mt-4">
          <pre className="whitespace-pre-wrap text-sm bg-gray-50 p-4 rounded">{result}</pre>
        </div>
      )}

      <div className="text-center text-sm mt-8">
        <div className="grid grid-cols-2 gap-4 mb-4">
          <div>
            <label className="block text-gray-500 mb-1">מזהה מוסד:</label>
            <input
              id="MosadId"
              type="text"
              maxLength={30}
              className="w-full p-2 border rounded text-left text-sm bg-gray-100"
              value={MOSAD_ID}
              disabled
            />
          </div>
          <div>
            <label className="block text-gray-500 mb-1">מפתח API:</label>
            <input
              id="ApiValid"
              type="text"
              maxLength={30}
              className="w-full p-2 border rounded text-left text-sm bg-gray-100"
              value={API_VALID}
              disabled
            />
          </div>
        </div>

        <div className="space-y-2">
          <button
            onClick={handleTokefChange}
            className="w-full p-2 bg-gray-100 hover:bg-gray-200 rounded transition-colors"
          >
            ניהול שדה תוקף בדף ולא באייפרם
          </button>
          <button
            onClick={handleSecurityIconsHide}
            className="w-full p-2 bg-gray-100 hover:bg-gray-200 rounded transition-colors"
          >
            הסתרת אייקוני אבטחה
          </button>
          <button
            onClick={handleHebrewDisplay}
            className="w-full p-2 bg-gray-100 hover:bg-gray-200 rounded transition-colors"
          >
            תצוגה בעברית
          </button>
          <button
            onClick={handleAddCaptcha}
            className="w-full p-2 bg-gray-100 hover:bg-gray-200 rounded transition-colors"
          >
            הוסף קאפצ'ה
          </button>
        </div>
      </div>

      <CardScanner onScanComplete={handleScanComplete} />
    </div>
  );
}

export default NedarimForm;