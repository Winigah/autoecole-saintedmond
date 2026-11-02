import React, { useState } from 'react';
import { Shield, CheckCircle2, Building2, User, Phone, MapPin, Mail, Lock, Sparkles, ArrowRight, AlertCircle } from 'lucide-react';
import type { RoleUtilisateur } from '../types';
import { authenticateUser } from '../lib/authService';

interface AuthScreenProps {
  onLoginSuccess: (schoolName: string, directorName: string, role: RoleUtilisateur, primaryBranch: string) => void;
}

export const AuthScreen: React.FC<AuthScreenProps> = ({ onLoginSuccess }) => {
  const [isSignup, setIsSignup] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState<'mensuel' | 'trimestriel' | 'annuel'>('mensuel');
  
  // Login fields
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loginError, setLoginError] = useState<string | null>(null);

  // Signup fields
  const [schoolName, setSchoolName] = useState('Auto-École Saint Edmond');
  const [directorName, setDirectorName] = useState('M. KALIBOU Edmond B.');
  const [phone, setPhone] = useState('+228 91 88 02 75');
  const [cityBranch, setCityBranch] = useState('Tokoin Ramco (Siège)');
  const [signupEmail, setSignupEmail] = useState('');
  const [signupPassword, setSignupPassword] = useState('');
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

      onLoginSuccess('Auto-École Saint Edmond', res.user.nom, res.user.role, res.user.annexe || 'Tokoin Ramco (Siège)');
    }, 450);
  };

  const handleSignupSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!schoolName || !directorName || !phone) {
      alert('Veuillez renseigner le nom de l\'auto-école, le nom du responsable et le contact téléphonique.');
      return;
    }

    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      onLoginSuccess(
        schoolName,
        directorName,
        'DG',
        cityBranch ? cityBranch : 'Siège Principal'
      );
    }, 800);
  };

  return (
    <div className="min-h-screen bg-slate-900 text-white flex flex-col justify-center items-center p-4">
      {/* Background glow effects */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-600/20 blur-[120px] rounded-full pointer-events-none" />

      <div className="relative z-10 w-full max-w-xl">
        {/* Brand header */}
        <div className="text-center mb-6">
          <img
            src="/app_icon.png"
            alt="Logo Auto-École Saint Edmond"
            className="w-20 h-20 rounded-2xl object-contain shadow-xl shadow-yellow-500/30 mb-3 mx-auto bg-white p-1"
          />
          <h1 className="text-3xl font-extrabold tracking-tight">Auto-École Saint Edmond</h1>
          <p className="text-slate-400 text-sm mt-1">Votre espace de gestion officiel - Lomé, Togo</p>
          <p className="text-yellow-400/80 text-xs mt-1 font-medium">Agrément N° 036/MTRAF/META</p>
        </div>

        {/* Card Box */}
        <div className="bg-slate-800/90 border border-slate-700/80 rounded-3xl p-6 sm:p-8 backdrop-blur-xl shadow-2xl">
          {/* Tabs Switcher */}
          <div className="flex bg-slate-900/80 p-1.5 rounded-2xl mb-6 border border-slate-700/50">
            <button
              type="button"
              onClick={() => setIsSignup(false)}
              className={`flex-1 py-2.5 rounded-xl text-sm font-bold transition ${
                !isSignup ? 'bg-blue-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
              }`}
            >
              Connexion
            </button>
            <button
              type="button"
              onClick={() => setIsSignup(true)}
              className={`flex-1 py-2.5 rounded-xl text-sm font-bold transition flex items-center justify-center gap-1.5 ${
                isSignup ? 'bg-blue-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
              }`}
            >
              <Sparkles className="w-4 h-4 text-amber-300" />
              <span>Inscrire mon Auto-École</span>
            </button>
          </div>

          {!isSignup ? (
            /* ================= LOGIN FORM ================= */
            <form onSubmit={handleLoginSubmit} className="space-y-4">
              {loginError && (
                <div className="p-3 bg-rose-500/10 border border-rose-500/50 rounded-xl text-xs text-rose-300 flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-rose-400 shrink-0" />
                  <span>{loginError}</span>
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-slate-400 mb-1">Identifiant ou Email officiel</label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                  <input
                    type="text"
                    value={loginEmail}
                    onChange={(e) => setLoginEmail(e.target.value)}
                    required
                    placeholder="Ex: dg@saintedmond.tg ou secretaire@saintedmond.tg"
                    className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-4 py-3 text-sm text-white focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="block text-xs font-semibold text-slate-400">Mot de passe</label>
                  <span className="text-[10px] text-amber-300/80">Modifiable par l'utilisateur</span>
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
                    <span>Accéder à mon espace sécurisé</span>
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>

            </form>

          ) : (
            /* ================= SIGNUP FORM (NOUVELLE ENTREPRISE) ================= */
            <form onSubmit={handleSignupSubmit} className="space-y-4">
              <div className="bg-blue-950/60 border border-blue-800/60 rounded-2xl p-3 text-xs text-blue-200 flex items-center gap-2.5">
                <CheckCircle2 className="w-5 h-5 text-emerald-400 shrink-0" />
                <span>
                  <strong>14 jours d'essai gratuit offert</strong>. Aucune carte bancaire requise. Accès immédiat pour votre auto-école.
                </span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-400 mb-1">Nom de l'Auto-École</label>
                  <div className="relative">
                    <Building2 className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                    <input
                      type="text"
                      placeholder="Ex: Auto-École La Référence"
                      value={schoolName}
                      onChange={(e) => setSchoolName(e.target.value)}
                      required
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-3 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-400 mb-1">Directeur / Propriétaire</label>
                  <div className="relative">
                    <User className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                    <input
                      type="text"
                      placeholder="Ex: Koffi Mensah"
                      value={directorName}
                      onChange={(e) => setDirectorName(e.target.value)}
                      required
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-3 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                    />
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-400 mb-1">Téléphone / WhatsApp</label>
                  <div className="relative">
                    <Phone className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                    <input
                      type="tel"
                      placeholder="Ex: 90 12 34 56"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      required
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-3 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-400 mb-1">Siège (Ville / Quartier)</label>
                  <div className="relative">
                    <MapPin className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                    <input
                      type="text"
                      placeholder="Ex: Lomé - Tokoin"
                      value={cityBranch}
                      onChange={(e) => setCityBranch(e.target.value)}
                      required
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-3 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                    />
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-400 mb-1">Email de connexion</label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                    <input
                      type="email"
                      placeholder="direction@autoecole.com"
                      value={signupEmail}
                      onChange={(e) => setSignupEmail(e.target.value)}
                      required
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-3 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-400 mb-1">Mot de passe (Min 8 car.)</label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                    <input
                      type="password"
                      placeholder="••••••••"
                      value={signupPassword}
                      onChange={(e) => setSignupPassword(e.target.value)}
                      required
                      minLength={8}
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-10 pr-3 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                    />
                  </div>
                </div>
              </div>

              {/* Formule de renouvellement future */}
              <div>
                <label className="block text-xs font-semibold text-slate-400 mb-1.5">
                  Formule après les 14 jours d'essai
                </label>
                <div className="grid grid-cols-3 gap-2 text-center text-xs">
                  {[
                    { id: 'mensuel', name: 'Mensuel', price: '15 000 F' },
                    { id: 'trimestriel', name: 'Trimestriel', price: '40 000 F' },
                    { id: 'annuel', name: 'Annuel', price: '150 000 F' },
                  ].map((p) => (
                    <button
                      key={p.id}
                      type="button"
                      onClick={() => setSelectedPlan(p.id as any)}
                      className={`p-2.5 rounded-xl border transition ${
                        selectedPlan === p.id
                          ? 'border-blue-500 bg-blue-600/20 text-white font-bold'
                          : 'border-slate-700 bg-slate-900 text-slate-400 hover:border-slate-600'
                      }`}
                    >
                      <div>{p.name}</div>
                      <div className="text-blue-400 font-extrabold mt-0.5">{p.price}</div>
                    </button>
                  ))}
                </div>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full mt-2 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-bold py-3.5 rounded-xl text-sm shadow-xl shadow-blue-600/30 transition flex items-center justify-center gap-2"
              >
                {isLoading ? (
                  <span>Configuration de votre espace...</span>
                ) : (
                  <>
                    <span>Créer l'Auto-École & Démarrer l'essai</span>
                    <Sparkles className="w-4 h-4 text-amber-300" />
                  </>
                )}
              </button>
            </form>
          )}

          {/* Security badge footer */}
          <div className="mt-6 pt-5 border-t border-slate-700/60 flex items-center justify-center gap-2 text-xs text-slate-400">
            <Shield className="w-4 h-4 text-emerald-400" />
            <span>Sécurité certifiée • Données isolées (Multi-tenant) • RLS PostgreSQL</span>
          </div>
        </div>
      </div>
    </div>
  );
};
