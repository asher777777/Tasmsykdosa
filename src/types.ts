export interface Product {
  id: string;
  name: string;
  englishName: string;
  price: number;
  image: string;
  weight: number;
  barcode: string;
  material?: string;
  dimensions?: {
    width?: number;
    length?: number;
    depth?: number;
  };
  category: string;
  inStock: number;
  color?: string;
  language?: string;
  itemSize?: string;
  periodicalZation?: string;
}

export interface CartItem extends Product {
  quantity: number;
}