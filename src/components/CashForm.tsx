import React, { useState } from 'react';

type ReceiptRequestProps = {
  onAmountChange?: (amount: string) => void;
  initialAmount?: string;
  selectedProducts?: { name: string; quantity: number; price: number }[];
};

type ResponseDetails = {
  pdf_link: string;
  pdf_link_copy: string;
  doc_number: string;
  doc_uuid: string;
  sent_mails: string[];
  calculatedData?: any;
  warning?: string;
};

export function ReceiptRequestPage({ onAmountChange = () => {}, initialAmount = '0', selectedProducts = [] }: ReceiptRequestProps) {
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
  const [responseDetails, setResponseDetails] = useState<ResponseDetails | null>(null);
  const [items, setItems] = useState(selectedProducts);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    
    if (name === 'payment_sum') {
      onAmountChange(value);
    }
  };

  const handleItemChange = (index: number, field: string, value: string) => {
    const updatedItems = [...items];
    updatedItems[index] = { ...updatedItems[index], [field]: value };
    setItems(updatedItems);
    updateTotalAmount(updatedItems);
  };

  const addItem = () => {
    setItems([...items, { name: '', quantity: 1, price: 0 }]);
  };

  const removeItem = (index: number) => {
    const updatedItems = items.filter((_, i) => i !== index);
    setItems(updatedItems);
    updateTotalAmount(updatedItems);
  };

  const updateTotalAmount = (items: { name: string; quantity: number; price: number }[]) => {
    const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const discount = parseFloat(formData.discount) || 0;
    const finalTotal = total - discount;
    setFormData(prev => ({ ...prev, payment_sum: finalTotal.toString() }));
    onAmountChange(finalTotal.toString());
  };

  const handleSubmit = async (e: React.FormEvent) => {
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

  const generateWhatsAppLink = (pdfLink: string) => {
    const message = `קבלה: ${pdfLink}`;
    return `https://wa.me/?text=${encodeURIComponent(message)}`;
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <h2 className="text-xl font-bold mb-4">בקשת קבלה</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block mb-2">שם לקוח</label>
          <input
            type="text"
            name="customer_name"
            value={formData.customer_name}
            onChange={handleChange}
            className="w-full p-2 border rounded"
            required
          />
        </div>

        <div>
          <label className="block mb-2">טלפון לקוח</label>
          <input
            type="text"
            name="customer_phone"
            value={formData.customer_phone}
            onChange={handleChange}
            className="w-full p-2 border rounded"
            required
          />
        </div>

        <div>
          <label className="block mb-2">אימייל לקוח</label>
          <input
            type="email"
            name="customer_email"
            value={formData.customer_email}
            onChange={handleChange}
            className="w-full p-2 border rounded"
            required
          />
        </div>

        <div>
          <label className="block mb-2">סוג מסמך</label>
          <select
            name="document_type"
            value={formData.document_type}
            onChange={handleChange}
            className="w-full p-2 border rounded"
          >
            <option value="400">קבלה</option>
            <option value="405">קבלה על תרומה</option>
          </select>
        </div>

        <div>
          <label className="block mb-2">סוג תשלום</label>
          <select
            name="payment_type"
            value={formData.payment_type}
            onChange={handleChange}
            className="w-full p-2 border rounded"
          >
            <option value="1">מזומן</option>
            <option value="2">צ'ק</option>
            <option value="3">כרטיס אשראי</option>
            <option value="4">העברה בנקאית</option>
          </select>
        </div>

        <div>
          <label className="block mb-2">פריטים</label>
          <button
            type="button"
            onClick={addItem}
            className="p-2 bg-blue-500 text-white rounded mb-2"
          >
            הוסף פריט
          </button>
          <div className="overflow-x-auto">
            <table className="min-w-full bg-white border border-gray-200">
              <thead>
                <tr>
                  <th className="px-4 py-2 border">שם פריט</th>
                  <th className="px-4 py-2 border">כמות</th>
                  <th className="px-4 py-2 border">מחיר</th>
                  <th className="px-4 py-2 border">סה"כ</th>
                  <th className="px-4 py-2 border">הסר</th>
                </tr>
              </thead>
              <tbody>
                {items.map((item, index) => (
                  <tr key={index}>
                    <td className="px-4 py-2 border">
                      <input
                        type="text"
                        placeholder="שם פריט"
                        value={item.name}
                        onChange={(e) => handleItemChange(index, 'name', e.target.value)}
                        className="w-full p-2 border rounded"
                      />
                    </td>
                    <td className="px-4 py-2 border">
                      <input
                        type="number"
                        placeholder="כמות"
                        value={item.quantity}
                        onChange={(e) => handleItemChange(index, 'quantity', e.target.value)}
                        className="w-full p-2 border rounded"
                      />
                    </td>
                    <td className="px-4 py-2 border">
                      <input
                        type="number"
                        placeholder="מחיר"
                        value={item.price}
                        onChange={(e) => handleItemChange(index, 'price', e.target.value)}
                        className="w-full p-2 border rounded"
                      />
                    </td>
                    <td className="px-4 py-2 border">
                      ₪{(item.price * item.quantity).toFixed(2)}
                    </td>
                    <td className="px-4 py-2 border">
                      <button
                        type="button"
                        onClick={() => removeItem(index)}
                        className="p-2 bg-red-500 text-white rounded"
                      >
                        הסר
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div>
          <label className="block mb-2">הנחה</label>
          <input
            type="number"
            name="discount"
            value={formData.discount}
            onChange={handleChange}
            className="w-full p-2 border rounded"
          />
        </div>

        <div>
          <label className="block mb-2">סה"כ</label>
          <input
            type="number"
            name="payment_sum"
            value={formData.payment_sum}
            onChange={handleChange}
            className="w-full p-2 border rounded"
            readOnly
          />
        </div>

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
}

export default ReceiptRequestPage;
