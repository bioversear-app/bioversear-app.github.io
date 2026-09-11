/* BioVerseAR — runtime config.
 * These are PUBLIC client credentials (anon / publishable). They are meant to be
 * embedded in the front end and are safe to commit — Row-Level Security in
 * supabase/schema.sql is what actually protects the data. NEVER put the
 * service_role / secret key here.
 * If Supabase is unreachable, the app falls back to on-device storage.
 */
window.BV_CONFIG = {
  SUPABASE_URL: 'https://znzboqqvtykwvsykkrxs.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpuemJvcXF2dHlrd3ZzeWtrcnhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0MzUzNzksImV4cCI6MjEwNDAxMTM3OX0.IgZ_Gm6fO426ANqSxMFcaw9p8rNRZ81PWGLOp0IFL-s'
};
