import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { User } from '@supabase/supabase-js';
import { RefreshCw } from 'lucide-react';

interface AuthContextType {
  user: User | null;
  isAdmin: boolean;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const [retryCount, setRetryCount] = useState(0);

  const checkAdminStatus = async (userId: string) => {
    try {
      const { data } = await supabase
        .from('user_roles')
        .select('role')
        .eq('user_id', userId);
      
      // Check if any roles were returned
      if (data && data.length > 0) {
        setIsAdmin(data[0].role === 'admin');
      } else {
        // If no role exists, create a default role
        const { error: insertError } = await supabase
          .from('user_roles')
          .insert({ user_id: userId, role: 'user' });

        if (insertError) {
          console.error('Error creating user role:', insertError);
        }
        setIsAdmin(false);
      }
    } catch (error) {
      console.error('Error checking admin status:', error);
      setIsAdmin(false);
    }
  };

  useEffect(() => {
    const initializeAuth = async () => {
      try {
        setLoading(true);
        setError(null);

        const { data: { session }, error: sessionError } = await supabase.auth.getSession();
        
        if (sessionError) throw sessionError;

        setUser(session?.user ?? null);
        if (session?.user) {
          await checkAdminStatus(session.user.id);
        }
        setRetryCount(0);
      } catch (err) {
        console.error('Auth initialization error:', err);
        if (retryCount < 3) {
          setRetryCount(prev => prev + 1);
          setTimeout(initializeAuth, 1000 * Math.pow(2, retryCount));
        } else {
          setError(err instanceof Error ? err : new Error('Failed to initialize auth'));
        }
      } finally {
        setLoading(false);
      }
    };

    initializeAuth();
    return () => setLoading(false);

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
      setUser(session?.user ?? null);
      if (session?.user) {
        await checkAdminStatus(session.user.id);
      } else {
        setIsAdmin(false);
      }
      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  const signIn = async (email: string, password: string) => {
    try {
      setError(null);
      if (loading) return;
      setLoading(true);

      
      // Validate credentials
      const trimmedEmail = email.trim();
      const trimmedPassword = password.trim();
      
      if (!trimmedEmail) {
        throw new Error('נא להזין כתובת אימייל');
      }
      if (!trimmedPassword) {
        throw new Error('נא להזין סיסמה');
      }

      // Attempt sign in
      const { data: { user: authUser }, error: signInError } = await supabase.auth.signInWithPassword({
        email: trimmedEmail,
        password: trimmedPassword
      });

      if (signInError) {
        console.error('Sign in error:', signInError);
        const errorMessage = signInError.message.toLowerCase();
        if (errorMessage.includes('invalid') || errorMessage.includes('credentials')) {
          throw new Error('שם משתמש או סיסמה שגויים');
        } else if (errorMessage.includes('network')) {
          throw new Error('בעיית תקשורת, אנא בדוק את החיבור לאינטרנט');
        } else if (errorMessage.includes('rate limit')) {
          throw new Error('נא להמתין מספר שניות לפני נסיון נוסף');
        } else {
          throw signInError;
        }
      }

      if (authUser) {
        setUser(authUser);
        await checkAdminStatus(authUser.id);
      } else {
        throw new Error('לא ניתן להתחבר כרגע, אנא נסה שוב מאוחר יותר');
      }

    } catch (error) {
      console.error('Sign in error:', error);
      setError(error instanceof Error ? error : new Error('אירעה שגיאה בכניסה למערכת'));
      setUser(null);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const signOut = async () => {
    try {
      setError(null);
      setLoading(true);
      setUser(null);
      setIsAdmin(false);
      localStorage.clear();
      sessionStorage.clear();
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
    } catch (error) {
      console.error('Sign out error:', error);
      setError(error instanceof Error ? error : new Error('Failed to sign out'));
      throw error;
    } finally {
      setLoading(false);
    }
  };

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-lg shadow-lg p-8 max-w-md w-full text-center" dir="rtl">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">שגיאת אימות</h2>
          <p className="text-gray-600 mb-6">
            {error.message}
          </p>
          <button
            onClick={() => window.location.reload()}
            className="inline-flex items-center justify-center gap-2 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors w-full"
          >
            <RefreshCw size={20} />
            נסה שוב
          </button>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">טוען...</p>
        </div>
      </div>
    );
  }
  const value = {
    user,
    isAdmin,
    loading,
    signIn,
    signOut
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}