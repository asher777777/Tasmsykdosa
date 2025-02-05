import React, { useCallback, useState } from 'react';
import { Upload, RefreshCw } from 'lucide-react';
import * as XLSX from 'xlsx';
import { Product } from '../types';
import { supabase } from '../lib/supabase';

interface ExcelUploaderProps {
  onProductsUpdate: (products: Product[]) => void;
}

export function ExcelUploader({ onProductsUpdate }: ExcelUploaderProps) {
  const [progress, setProgress] = useState(0);
  const [isProcessing, setIsProcessing] = useState(false);
  const [status, setStatus] = useState<string>('');

  const processExcel = useCallback(async (file: File, isUpdate: boolean) => {
    try {
      setIsProcessing(true);
      setProgress(0);
      setStatus('קורא את קובץ האקסל...');

      const reader = new FileReader();
      reader.onload = async (e) => {
        const data = e.target?.result;
        const workbook = XLSX.read(data, { type: 'binary' });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        const jsonData = XLSX.utils.sheet_to_json(worksheet);

        setStatus('מעבד נתונים...');
        setProgress(20);

        // Transform Excel data to match Product interface
        const products: Product[] = jsonData.map((row: any) => {
          const originalImageUrl = row['קישור לתמונה'] || row['SmallPack'] || '';
          let imageUrl = originalImageUrl;
          if (imageUrl && !imageUrl.startsWith('http')) {
            imageUrl = `https://images.judaica.com/img/${imageUrl}`;
          }

          return {
            id: row['מזהה'] || row['ITEMKEY'] || '',
            name: row['שם מוצר'] || row['Name'] || '',
            englishName: row['שם באנגלית'] || row['ORIGNAME'] || '',
            price: parseFloat(row['מחיר'] || row['PRICE']) || 0,
            image: imageUrl,
            weight: parseFloat(row['משקל (גרם)'] || row['WEIGHT']) || 0,
            barcode: row['ברקוד'] || row['BARCODE'] || '',
            material: row['חומר'] || row['Material'] || '',
            dimensions: {
              width: parseFloat(row['רוחב (ס"מ)'] || row['ItemWidth']) || undefined,
              length: parseFloat(row['אורך (ס"מ)'] || row['ItemLength']) || undefined,
              depth: parseFloat(row['עומק (ס"מ)']) || undefined
            },
            category: row['קטגוריה'] || row['category'] || '',
            inStock: parseInt(row['מלאי'] || row['Baner']) || 0,
            color: row['צבע'] || row['Color'] || '',
            language: row['שפה'] || row['Language'] || '',
            itemSize: row['גודל'] || row['ItemSize'] || '',
            periodicalZation: row['תקופה'] || row['PERIODICALZATION'] || '',
          };
        });

        setProgress(40);
        setStatus('מסיר כפילויות...');

        // Remove duplicates based on id
        const uniqueProducts = Array.from(new Map(products.map(product => [product.id, product])).values());

        // Prepare data for Supabase
        const supabaseProducts = uniqueProducts.map(product => ({
          id: product.id,
          name: product.name,
          english_name: product.englishName,
          price: product.price,
          image: product.image,
          weight: product.weight,
          barcode: product.barcode,
          material: product.material,
          width: product.dimensions?.width,
          length: product.dimensions?.length,
          depth: product.dimensions?.depth,
          category: product.category,
          in_stock: product.inStock,
          color: product.color,
          language: product.language,
          item_size: product.itemSize,
          periodical_zation: product.periodicalZation,
        }));

        setProgress(60);
        setStatus(isUpdate ? 'מעדכן מוצרים...' : 'מוסיף מוצרים...');

        try {
          if (isUpdate) {
            let processed = 0;
            const total = supabaseProducts.length;

            for (const product of supabaseProducts) {
              const { error } = await supabase
                .from('products')
                .update(product)
                .eq('id', product.id);

              if (error) throw error;

              processed++;
              setProgress(60 + Math.floor((processed / total) * 30));
            }
            setStatus('העדכון הושלם בהצלחה');
          } else {
            let processed = 0;
            const total = supabaseProducts.length;

            for (const product of supabaseProducts) {
              const { error } = await supabase
                .from('products')
                .upsert(product);

              if (error) throw error;

              processed++;
              setProgress(60 + Math.floor((processed / total) * 30));
            }
            setStatus('ההוספה הושלמה בהצלחה');
          }

          setProgress(100);
          onProductsUpdate(uniqueProducts);
          
          setTimeout(() => {
            setProgress(0);
            setStatus('');
            setIsProcessing(false);
          }, 2000);

        } catch (error) {
          console.error('Error processing products:', error);
          setStatus('שגיאה בעיבוד המוצרים. אנא נסה שוב.');
          setTimeout(() => {
            setProgress(0);
            setStatus('');
            setIsProcessing(false);
          }, 3000);
        }
      };

      reader.readAsBinaryString(file);
    } catch (err) {
      console.error('Error reading file:', err);
      setStatus('שגיאה בקריאת הקובץ. אנא נסה שוב.');
      setTimeout(() => {
        setProgress(0);
        setStatus('');
        setIsProcessing(false);
      }, 3000);
    }
  }, [onProductsUpdate]);

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>, isUpdate: boolean) => {
    const file = event.target.files?.[0];
    if (file) {
      processExcel(file, isUpdate);
    }
  };

  return (
    <div className="flex flex-col items-end gap-2">
      <div className="flex items-center gap-2">
        <input
          type="file"
          accept=".xlsx,.xls"
          onChange={(e) => handleFileUpload(e, false)}
          className="hidden"
          id="excel-upload"
          disabled={isProcessing}
        />
        <label
          htmlFor="excel-upload"
          className={`flex items-center gap-2 px-4 py-2 rounded-md transition-colors ${
            isProcessing
              ? 'bg-gray-400 cursor-not-allowed'
              : 'bg-green-600 hover:bg-green-700 text-white cursor-pointer'
          }`}
        >
          <Upload size={18} />
          העלאת מוצרים חדשים
        </label>

        <input
          type="file"
          accept=".xlsx,.xls"
          onChange={(e) => handleFileUpload(e, true)}
          className="hidden"
          id="excel-update"
          disabled={isProcessing}
        />
        <label
          htmlFor="excel-update"
          className={`flex items-center gap-2 px-4 py-2 rounded-md transition-colors ${
            isProcessing
              ? 'bg-gray-400 cursor-not-allowed'
              : 'bg-blue-600 hover:bg-blue-700 text-white cursor-pointer'
          }`}
        >
          <RefreshCw size={18} />
          עדכון מוצרים קיימים
        </label>
      </div>

      {(isProcessing || status) && (
        <div className="w-full max-w-md">
          {progress > 0 && (
            <div className="w-full bg-gray-200 rounded-full h-2.5 mb-2">
              <div
                className="bg-blue-600 h-2.5 rounded-full transition-all duration-300"
                style={{ width: `${progress}%` }}
              />
            </div>
          )}
          {status && (
            <p className="text-sm text-gray-600 text-right">{status}</p>
          )}
        </div>
      )}
    </div>
  );
}