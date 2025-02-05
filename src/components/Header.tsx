import React, { useState, useEffect } from 'react';
import { ShoppingBag, Search, Grid, RefreshCw, Users, WifiOff, Menu, X, LayoutDashboard, LogIn, LogOut, CreditCard } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../lib/supabase';
import { Product } from '../types';

export function Header() {
  const { cart, isCartOpen, setIsCartOpen } = useCart();
  const { user, isAdmin, signOut } = useAuth();
  const navigate = useNavigate();
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [categories, setCategories] = useState<{ name: string; image: string }[]>([]);
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const cartItemsCount = cart.reduce((acc, item) => acc + item.quantity, 0);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<Product[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [showResults, setShowResults] = useState(false);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const { data } = await supabase
          .from('products')
          .select('category, image')
          .not('category', 'is', null)
          .not('category', 'eq', '');

        if (data) {
          const uniqueCategories = Array.from(
            new Map(
              data.map(item => [
                item.category,
                {
                  name: item.category,
                  image: item.image || 'https://images.unsplash.com/photo-1612538498456-e861df91d4d0'
                }
              ])
            ).values()
          );
          setCategories(uniqueCategories);
        }
      } catch (error) {
        console.error('Error fetching categories:', error);
      }
    };

    fetchCategories();
  }, []);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return (
    <header className="bg-white shadow-md">
      <div className="max-w-7xl mx-auto px-4 py-4">
        <div className="flex justify-between items-center">
          {user ? (
            <button
              onClick={async () => {
                await signOut();
                navigate('/login');
              }}
              className="p-2 hover:bg-gray-100 rounded-full"
              title="התנתק"
            >
              <LogOut size={24} />
            </button>
          ) : (
            <Link
              to="/login"
              className="p-2 hover:bg-gray-100 rounded-full"
              title="התחבר"
            >
              <LogIn size={24} />
            </Link>
          )}
          <button
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="p-2 hover:bg-gray-100 rounded-full"
          >
            {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
          {!isOnline && (
            <div className="fixed bottom-4 right-4 bg-yellow-100 text-yellow-800 px-4 py-2 rounded-lg shadow-lg flex items-center gap-2">
              <WifiOff size={20} />
              מצב לא מקוון
            </div>
          )}
          <div className="flex items-center gap-4">
            <button
              onClick={() => setIsCartOpen(!isCartOpen)}
              className="relative p-2 hover:bg-gray-100 rounded-full"
            >
              <ShoppingBag size={24} />
              {cartItemsCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                  {cartItemsCount}
                </span>
              )}
            </button>
            <Link
              to="/admin"
              className="p-2 hover:bg-gray-100 rounded-full"
              title="לוח בקרה"
            >
              <LayoutDashboard size={24} />
            </Link>
            <Link
              to="/cash-payment"
              className="p-2 hover:bg-gray-100 rounded-full"
              title="קופה ראשית"
            >
              <CreditCard size={24} />
            </Link>
          </div>
        </div>
        
        {/* Categories Menu */}
        {isMenuOpen && (
          <div className="fixed inset-0 z-50 bg-black bg-opacity-50">
            <div className="fixed inset-y-0 right-0 max-w-sm w-full bg-white shadow-xl">
              <div className="flex justify-between items-center p-4 border-b">
                <button
                  onClick={() => setIsMenuOpen(false)}
                  className="p-2 hover:bg-gray-100 rounded-full"
                >
                  <X size={24} />
                </button>
                <h2 className="text-xl font-bold">קטגוריות</h2>
              </div>
              <div className="overflow-y-auto h-full pb-20">
                <div className="grid gap-4 p-4">
                  {categories.map((category) => (
                    <Link
                      key={category.name}
                      to={`/category/${encodeURIComponent(category.name)}`}
                      className="flex items-center gap-4 p-3 rounded-lg hover:bg-gray-50 transition-colors"
                      onClick={() => setIsMenuOpen(false)}
                    >
                      <img
                        src={category.image}
                        alt={category.name}
                        className="w-12 h-12 object-cover rounded-lg"
                        onError={(e) => {
                          const img = e.target as HTMLImageElement;
                          img.src = 'https://images.unsplash.com/photo-1612538498456-e861df91d4d0';
                        }}
                      />
                      <span className="text-lg">{category.name}</span>
                    </Link>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </header>
  );
}