import React, { useState } from 'react';
import ReactDOM from 'react-dom';

const ReceiptRequestPage = ({ onAmountChange = () => {}, initialAmount = '0', selectedProducts = [] }) => {
  const [formData, setFormData] = useState({
    payment_type: '1',
    payment_sum: initialAmount,
    discount: '0',
    comment: '',
    customer_name: '',
    customer_phone: '',
    customer_email: '',
    document_type: '400' // Default to 'קבלה'
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [responseDetails, setResponseDetails] = useState(null);
  const [items, setItems] = useState(selectedProducts);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    
    if (name === 'payment_sum') {
      onAmountChange(value);
    }
  };

  const handleItemChange = (index, field, value) => {
    const updatedItems = [...items];
    updatedItems[index] = { ...updatedItems[index], [field]: value };
    setItems(updatedItems);
    updateTotalAmount(updatedItems);
  };

  const addItem = () => {
    setItems([...items, { name: '', quantity: 1, price: 0 }]);
  };

  const removeItem = (index) => {
    const updatedItems = items.filter((_, i) => i !== index);
    setItems(updatedItems);
    updateTotalAmount(updatedItems);
  };

  const updateTotalAmount = (items) => {
    const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const discount = parseFloat(formData.discount) || 0;
    const finalTotal = total - discount;
    setFormData(prev => ({ ...prev, payment_sum: finalTotal.toString() }));
    onAmountChange(finalTotal.toString());
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setResponseDetails(null);

    const totalAmount = parseFloat(formData.payment_sum);

    const requestBody = {
      api_key: import.meta.env.VITE_EZY_API_KEY,
      developer_email: import.meta.env.VITE_EZY_DEVELOPER_EMAIL,
      type: formData.document_type,
      customer_name: formData.customer_name,
      customer_phone: formData.customer_phone,
      customer_email: formData.customer_email,
      forceItemsIntoNonItemsDocument: true,
      created_by_api_key: import.meta.env.VITE_EZY_API_KEY,
      item: items.map(product => ({
        details: product.name,
        quantity: product.quantity,
        price: product.price,
        amount: product.price * product.quantity
      })),
      payment: [{
        payment_type: parseInt(formData.payment_type),
        payment_sum: totalAmount,
        currency: 'ILS',
        currency_rate: 1,
        comment: formData.comment
      }],
      price_total: totalAmount,
      price_discount: parseFloat(formData.discount) || 0,
      comment: formData.comment
    };

    console.log('Request Body:', requestBody); // Log the request body

    try {
      const response = await fetch('http://localhost:5000/api/ezcount', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody)
      });

      if (!response.ok) {
        throw new Error(`שגיאת HTTP: ${response.status}`);
      }

      const data = await response.json();
      console.log(data); // Print the response from EZCount
      if (data.success) {
        onAmountChange(data.calculatedData.price_total?.toString() || '0');
        setResponseDetails({
          pdf_link: data.pdf_link,
          pdf_link_copy: data.pdf_link_copy,
          doc_number: data.doc_number,
          doc_uuid: data.doc_uuid,
          sent_mails: data.sent_mails,
          calculatedData: data.calculatedData,
          warning: data.warning
        });
      } else {
        console.error(data.errMsg); // Print the error message from EZCount
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'אירעה שגיאה');
    } finally {
      setLoading(false);
    }
  };

  const generateWhatsAppLink = (pdfLink) => {
    const message = `קבלה: ${pdfLink}`;
    return `https://wa.me/?text=${encodeURIComponent(message)}`;
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <h2 className="text-xl font-bold mb-4">בקשת קבלה</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <!-- ...existing code... -->
        <div>
          <label className="block mb-2">הערות</label>
          <input
            type="text"
            name="comment"
            value={formData.comment}
            onChange={handleChange}
            className="w-full p-2 border rounded"
          />
        </div>
        <div>
          <button
            type="submit"
            disabled={loading}
            className={`w-full p-2 rounded text-white ${
              loading ? 'bg-gray-400' : 'bg-blue-600 hover:bg-blue-700'
            }`}
          >
            {loading ? 'שולח...' : 'שלח בקשה'}
          </button>
        </div> 
      </form>

      {error && (
        <div className="mt-4 p-4 bg-red-50 text-red-600 rounded">
          {error}
        </div>
      )}

      {responseDetails && (
        <div className="mt-4 p-4 bg-green-50 text-green-600 rounded">
          <p>PDF קישור: <a href={responseDetails.pdf_link} target="_blank" rel="noopener noreferrer">לחץ כאן</a></p>
          <p>PDF קישור (עותק): <a href={responseDetails.pdf_link_copy} target="_blank" rel="noopener noreferrer">לחץ כאן</a></p>
          <p>מספר מסמך: {responseDetails.doc_number}</p>
          <p>מספר מזהה מסמך: {responseDetails.doc_uuid}</p>
          <p>מיילים שנשלחו: {responseDetails.sent_mails.join(', ')}</p>
          <p>סה"כ מחיר: ₪{responseDetails.calculatedData.price_total}</p>
          <p><a href={generateWhatsAppLink(responseDetails.pdf_link)} target="_blank" rel="noopener noreferrer" className="text-green-600 hover:underline">שלח קישור בוואטספ</a></p>
        </div>
      )}
    </div>
  );
};

ReactDOM.render(<ReceiptRequestPage />, document.getElementById('root'));
