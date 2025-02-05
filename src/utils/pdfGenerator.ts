import { supabase } from '../lib/supabase';
import type { Order } from '../types';

export const generatePDF = async (order: Order): Promise<Blob> => {
  // For now, return an empty blob since we removed jsPDF
  // This should be replaced with a proper PDF generation solution
  return new Blob([''], { type: 'application/pdf' });
};