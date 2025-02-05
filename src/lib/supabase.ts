import { createClient } from '@supabase/supabase-js';
import type { Database } from './database.types';

// Validate environment variables
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables');
  throw new Error('חסרים פרטי התחברות לשרת');
}

// Create Supabase client with better error handling
export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
    storage: window.localStorage,
    storageKey: 'judaica-store-auth'
  },
  db: {
    schema: 'public'
  },
  global: {
    headers: { 
      'x-client-info': 'judaica-store',
      'cache-control': 'no-cache'
    }
  },
  // Add retry configuration
  shouldRetry: (err) => {
    const status = err?.status || 0;
    return status >= 500 || status === 429;
  },
  retryCount: 3,
  retryInterval: 1000
});