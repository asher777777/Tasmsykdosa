import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Mail, Lock, AlertCircle } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useLocation } from 'react-router-dom'; 
import { supabase } from '../../lib/supabase';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSendingReset, setIsSendingReset] = useState(false);
  const navigate = useNavigate();
  const { signIn, user } = useAuth();
  const location = useLocation();
  const from = location.state?.from?.pathname || '/';
  const redirectPath = from === '/login' ? '/' : from;

  useEffect(() => {
    if (user) {
      navigate(redirectPath, { replace: true });
    }
  }, [user, navigate, redirectPath]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (isLoading) return;
    
    setIsLoading(true);
    setError('');
    setSuccessMessage('');

    try {
      // Validate inputs
      if (!email.trim()) {
        throw new Error('נא להזין כתובת אימייל');
      }
      if (!password.trim()) {
        throw new Error('נא להזין סיסמה');
      }

      await signIn(email, password);
      
    } catch (err) {
      console.error('Error signing in:', err);
      if (err instanceof Error) {
        const message = err.message.toLowerCase();
        if (message.includes('invalid') || message.includes('credentials')) {
          setError('שם משתמש או סיסמה שגויים');
        } else if (message.includes('network') || message.includes('connection')) {
          setError('בעיית תקשורת, אנא בדוק את החיבור לאינטרנט');
        } else if (message.includes('rate limit')) {
          setError('נא להמתין מספר שניות לפני נסיון נוסף');
        } else {
          setError(err.message);
        }
      } else {
        setError('שגיאה בהתחברות, אנא נסה שוב מאוחר יותר');
      }
      // Clear password on error
      setPassword('');
    } finally {
      setIsLoading(false);
    }
  };

  const handleForgotPassword = async (e: React.MouseEvent) => {
    e.preventDefault();
    
    // Rate limit check
    const lastResetAttempt = localStorage.getItem('lastResetAttempt');
    if (lastResetAttempt) {
      const timeSinceLastAttempt = Date.now() - parseInt(lastResetAttempt);
      if (timeSinceLastAttempt < 60000) { // 60 seconds
        setError('נא להמתין דקה לפני שליחת בקשה נוספת');
        return;
      }
    }

    if (!email.trim()) {
      setError('נא להזין כתובת אימייל לשחזור הסיסמה');
      return;
    }

    setIsSendingReset(true);
    setError('');
    setSuccessMessage('');

    try {
      localStorage.setItem('lastResetAttempt', Date.now().toString());

      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email.trim(), {
        redirectTo: `${window.location.origin}/reset-password`,
      });

      if (resetError) throw resetError;

      setSuccessMessage('הוראות לאיפוס הסיסמה נשלחו לכתובת האימייל שלך');
      setPassword('');
    } catch (err) {
      if (err instanceof Error) {
        const message = err.message.toLowerCase();
        if (message.includes('rate limit')) {
          setError('נא להמתין מספר שניות לפני שליחת בקשה נוספת');
        } else if (message.includes('invalid')) {
          setError('כתובת האימייל אינה רשומה במערכת');
        } else {
          setError('אירעה שגיאה בשליחת האימייל. אנא נסה שוב מאוחר יותר');
        }
      } else {
        setError('אירעה שגיאה בשליחת האימייל. אנא נסה שוב מאוחר יותר');
      }
    } finally {
      setIsSendingReset(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8" dir="rtl">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            כניסה למערכת
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            או{' '}
            <Link to="/register" className="font-medium text-blue-600 hover:text-blue-500">
              הרשמה למערכת
            </Link>
          </p>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="rounded-md shadow-sm -space-y-px">
            <div>
              <label htmlFor="email" className="sr-only">אימייל</label>
              <div className="relative">
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  autoFocus
                  dir="ltr"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm text-left"
                  placeholder="אימייל"
                />
                <Mail className="absolute left-3 top-2.5 text-gray-400" size={20} />
              </div>
            </div>
            <div>
              <label htmlFor="password" className="sr-only">סיסמה</label>
              <div className="relative">
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="current-password"
                  required
                  dir="ltr"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
                  placeholder="סיסמה"
                />
                <Lock className="absolute left-3 top-2.5 text-gray-400" size={20} />
              </div>
            </div>
          </div>

          <div className="flex items-center justify-between">
            <div className="text-sm">
              <button
                onClick={handleForgotPassword}
                disabled={isSendingReset}
                className={`font-medium text-blue-600 hover:text-blue-500 ${
                  isSendingReset ? 'opacity-50 cursor-not-allowed' : ''
                }`}
              >
                {isSendingReset ? 'שולח...' : 'שכחתי סיסמה'}
              </button>
            </div>
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-600 rounded-md p-3 text-center text-sm">
              <AlertCircle className="inline-block mr-2" size={16} />
              {error}
            </div>
          )}

          {successMessage && (
            <div className="bg-green-50 border border-green-200 text-green-600 rounded-md p-3 text-center text-sm">
              {successMessage}
            </div>
          )}

          <div>
            <button
              type="submit"
              disabled={isLoading}
              className={`group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white ${
                isLoading ? 'bg-blue-400 cursor-not-allowed' : 'bg-blue-600 hover:bg-blue-700'
              } focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors`}
            >
              {isLoading ? (
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                'כניסה'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}