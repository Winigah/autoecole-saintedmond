import React, { useState } from 'react';
import { Shield, Lock, User, ArrowRight, AlertCircle, KeyRound } from 'lucide-react';
import type { RoleUtilisateur } from '../types';
import { authenticateUser } from '../lib/authService';

interface AuthScreenProps {
  onLoginSuccess: (schoolName: string, directorName: string, role: RoleUtilisateur, primaryBranch: string) => void;
}

export const AuthScreen: React.FC<AuthScreenProps> = ({ onLoginSuccess }) => {
  // Login fields
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loginError, setLoginError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleLoginSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoginError(null);
    setIsLoading(true);

    setTimeout(() => {
      setIsLoading(false);
      const res = authenticateUser(loginEmail, loginPassword);
      if (!res.success || !res.user) {
        setLoginError(res.error || 'Identifiant ou mot de passe incorrect.');
        return;
      }

      onLoginSuccess(
        'Auto-École Saint Edmond',
        res.user.nom,
        res.user.role,
        res.user.annexe || 'Tokoin Ramco (Siège)'
      );
    }, 400);
  };

  return (
    <div className="min-h-screen bg-slate-900 text-white flex flex-col justify-center items-center p-4">
      {/* Background glow effects */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-600/20 blur-[120px] rounded-full pointer-events-none" />

      <div className="relative z-10 w-full max-w-md">
        {/* Brand header */}
        <div className="text-center mb-6">
          <img
            src="/app_icon.png"
            alt="Logo Auto-École Saint Edmond"
            className="w-20 h-20 rounded-2xl object-contain shadow-xl shadow-yellow-500/30 mb-3 mx-auto bg-white p-1"
          />
          <h1 className="text-3xl font-extrabold tracking-tight">Auto-École Saint Edmond</h1>
          <p className="text-slate-400 text-sm mt-1">Espace de gestion sécurisé • Lomé, Togo</p>
          <p className="text-yellow-400/80 text-xs mt-1 font-medium">Agrément N° 036/MTRAF/META</p>
        </div>

        {/* Card Box */}
        <div className="bg-slate-800/90 border border-slate-700/80 rounded-3xl p-6 sm:p-8 backdrop-blur-xl shadow-2xl">
          <div className="mb-5 flex items-center gap-2.5 pb-4 border-b border-slate-700/60">
            <div className="w-9 h-9 rounded-xl bg-blue-600/20 border border-blue-500/30 flex items-center justify-center text-blue-400">
              <KeyRound className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-white">Connexion Direction & Secrétariat</h2>
              <p className="text-xs text-slate-400">Saisissez vos identifiants pour continuer</p>
            </div>
          </div>

          <form onSubmit={handleLoginSubmit} className="space-y-4">
            {loginError && (
              <div className="p-3 bg-rose-500/10 border border-rose-500/50 rounded-xl text-xs text-rose-300 flex items-center gap-2">
                <AlertCircle className="w-4 h-4 text-rose-400 shrink-0" />
                <span>{loginError}</span>
              </div>
            )}

            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1">
                Identifiant
              </label>
              <div className="relative">
                <User className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                <input
                  type="text"
                  value={loginEmail}
                  onChange={(e) => setLoginEmail(e.target.value)}
                  required
                  placeholder="Ex: DG Saint Edmond ou Secretaire Saint Edmond"
                  className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-4 py-3 text-sm text-white focus:outline-none focus:border-blue-500"
                />
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-1">
                <label className="block text-xs font-semibold text-slate-400">Mot de passe</label>
              </div>
              <div className="relative">
                <Lock className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                <input
                  type="password"
                  value={loginPassword}
                  onChange={(e) => setLoginPassword(e.target.value)}
                  required
                  placeholder="••••••••"
                  className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-4 py-3 text-sm text-white focus:outline-none focus:border-blue-500"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full mt-2 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3.5 rounded-xl text-sm shadow-lg shadow-blue-600/30 transition flex items-center justify-center gap-2 cursor-pointer"
            >
              {isLoading ? (
                <span>Vérification des accès...</span>
              ) : (
                <>
                  <span>Accéder à mon espace</span>
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          {/* Security badge footer */}
          <div className="mt-6 pt-5 border-t border-slate-700/60 flex items-center justify-center gap-2 text-xs text-slate-400 text-center">
            <Shield className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>Sécurisé SHA-256 • Personnalisable après connexion</span>
          </div>
        </div>
      </div>
    </div>
  );
};
