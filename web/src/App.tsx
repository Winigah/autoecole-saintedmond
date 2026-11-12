import React, { useState, useEffect } from 'react';
import { 
  Users, DollarSign, TrendingUp, Award, BookOpen, 
  UserCheck, Shield, FileText, Send, Menu, X, Plus, 
  Search, Download, RefreshCw, CheckCircle2, AlertCircle, MessageSquare, Calendar, Car,
  Pencil, Trash2, Clock, Check, CheckCheck, RotateCcw,
  KeyRound, LayoutGrid, List, Phone, Eye, Lock, Camera,
  Wifi, WifiOff,
  UserPlus, ArrowDownLeft, ArrowUpRight
} from 'lucide-react';

import type { Candidat, Depense, Recette, RoleUtilisateur, Sexe } from './types';
import { 
  generateCandidatsPDF, 
  generateBilanPDF, 
  generateRecuCandidatPDF, 
  generateRecuSupplementConduitePDF,
  generatePresencePDF
} from './lib/pdfGenerator';
import { AuthScreen } from './components/AuthScreen';
import { CandidateAvatar } from './components/CandidateAvatar';
import { updateUserPassword } from './lib/authService';
import { syncService, type SyncStatus } from './lib/syncService';

// Siège unique officiel de l'Auto-École Saint Edmond
const DEFAULT_SIEGE = 'Tokoin Ramco (Siège)';

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(true);
  const [schoolName, setSchoolName] = useState<string>('Auto-École Saint Edmond');
  const [directorName, setDirectorName] = useState<string>('M. KALIBOU Edmond B.');
  const [role, setRole] = useState<RoleUtilisateur>('DG');

  // Gestion dynamique des annexes : commence uniquement avec le Siège unique
  const [annexesList, setAnnexesList] = useState<string[]>(() => {
    try {
      const saved = localStorage.getItem('autoecole_annexes_saintedmond');
      return saved ? JSON.parse(saved) : [DEFAULT_SIEGE];
    } catch {
      return [DEFAULT_SIEGE];
    }
  });

  const [newAnnexeName, setNewAnnexeName] = useState('');

  const handleAddAnnexe = (e: React.FormEvent) => {
    e.preventDefault();
    const clean = newAnnexeName.trim();
    if (!clean) return;
    if (annexesList.includes(clean)) {
      showToast('Cette annexe existe déjà.');
      return;
    }
    const updated = [...annexesList, clean];
    setAnnexesList(updated);
    try {
      localStorage.setItem('autoecole_annexes_saintedmond', JSON.stringify(updated));
    } catch (err) {
      console.error(err);
    }
    setNewAnnexeName('');
    setModalType(null);
    syncService.syncAnnexe(clean);
    showToast(`Annexe "${clean}" ajoutée avec succès !`);
  };
  const [userPhoto, setUserPhoto] = useState<string | null>(() => {
    return localStorage.getItem('autoecole_user_photo_DG') || null;
  });
  const fileInputUserPhotoRef = React.useRef<HTMLInputElement | null>(null);

  // Sync photo with current role from localStorage
  useEffect(() => {
    const saved = localStorage.getItem(`autoecole_user_photo_${role}`);
    setUserPhoto(saved || null);
  }, [role]);

  const handleUserPhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 5 * 1024 * 1024) {
      alert('La taille de l\'image ne doit pas dépasser 5 Mo.');
      return;
    }
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result as string;
      setUserPhoto(result);
      localStorage.setItem(`autoecole_user_photo_${role}`, result);
      showToast('Photo de profil mise à jour avec succès !');
    };
    reader.readAsDataURL(file);
    e.target.value = '';
  };
  const [activeTab, setActiveTab] = useState<string>('Accueil');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [annexeFilter, setAnnexeFilter] = useState('Toutes');
  const [searchQuery, setSearchQuery] = useState('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');

  // Vue Candidats (Cartes ou Tableau)
  const [candidatsViewMode, setCandidatsViewMode] = useState<'cartes' | 'tableau'>('cartes');

  // Photo & Sexe pour nouveau candidat
  const [newCandPhoto, setNewCandPhoto] = useState<string | undefined>(undefined);
  const [newCandSexe, setNewCandSexe] = useState<Sexe>('MASCULIN');

  // Photo & Sexe pour modification candidat
  const [editCandPhoto, setEditCandPhoto] = useState<string | undefined>(undefined);
  const [editCandSexe, setEditCandSexe] = useState<Sexe>('MASCULIN');

  // Modal changement de mot de passe utilisateur
  const [passwordModalOpen, setPasswordModalOpen] = useState(false);
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [passwordError, setPasswordError] = useState<string | null>(null);

  // Modals state
  const [modalType, setModalType] = useState<string | null>(null);
  const [modalData, setModalData] = useState<any>(null);
  const [selectedCandidatForSupplement, setSelectedCandidatForSupplement] = useState<Candidat | null>(null);
  const [editingCandidat, setEditingCandidat] = useState<Candidat | null>(null);
  const [editingDepense, setEditingDepense] = useState<Depense | null>(null);
  const [editingRecette, setEditingRecette] = useState<Recette | null>(null);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Marketing Carousel
  const [slideIndex, setSlideIndex] = useState(0);
  const slides = [
    { title: "Permis de conduire, une nécessité et non un luxe", sub: "Formation d'excellence théorique et pratique partout à Lomé - Moniteurs expérimentés", color: "from-amber-600 to-yellow-600" },
    { title: "Formation à Domicile personnalisée", sub: "Formez-vous directement chez vous à votre convenance (120 000 F CFA - 12 séances de conduite)", color: "from-blue-600 to-indigo-700" },
    { title: "Agrément d'État N° 036/MTRAF/META", sub: "Centre agréé conforme aux normes de l'État togolais - RCCM : TG-LOM 2018 A 4273", color: "from-emerald-600 to-teal-700" },
    { title: "Démarches Cartes Grises & Visite Technique", sub: "Mutation, duplicata, plaques d'immatriculation, assurance auto", color: "from-purple-600 to-indigo-700" },
  ];

  useEffect(() => {
    const timer = setInterval(() => {
      setSlideIndex((prev) => (prev + 1) % slides.length);
    }, 4500);
    return () => clearInterval(timer);
  }, [slides.length]);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // PWA Install prompt
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  useEffect(() => {
    const onBefore = (e: any) => { e.preventDefault(); setDeferredPrompt(e); };
    const onInstalled = () => { setDeferredPrompt(null); showToast('Application installée sur votre bureau !'); };
    window.addEventListener('beforeinstallprompt', onBefore);
    window.addEventListener('appinstalled', onInstalled);
    return () => {
      window.removeEventListener('beforeinstallprompt', onBefore);
      window.removeEventListener('appinstalled', onInstalled);
    };
  }, []);
  const handleInstallApp = async () => {
    if (deferredPrompt) { deferredPrompt.prompt(); await deferredPrompt.userChoice; setDeferredPrompt(null); }
  };

  // Helper code generator for candidates
  const generateAccessCode = () => {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    let p1 = '', p2 = '';
    for (let i = 0; i < 4; i++) {
      p1 += chars[Math.floor(Math.random() * chars.length)];
      p2 += chars[Math.floor(Math.random() * chars.length)];
    }
    return `${p1}-${p2}`;
  };

  // Production Database State (Stockage réel persistent localStorage)
  const [candidats, setCandidats] = useState<Candidat[]>(() => {
    try {
      const saved = localStorage.getItem('autoecole_candidats_saintedmond');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  const [depenses, setDepenses] = useState<Depense[]>(() => {
    try {
      const saved = localStorage.getItem('autoecole_depenses_saintedmond');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  const [recettes, setRecettes] = useState<Recette[]>(() => {
    try {
      const saved = localStorage.getItem('autoecole_recettes_saintedmond');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  // Sauvegarde automatique des données réelles
  useEffect(() => {
    try {
      localStorage.setItem('autoecole_candidats_saintedmond', JSON.stringify(candidats));
    } catch (e) {
      console.error(e);
    }
  }, [candidats]);

  useEffect(() => {
    try {
      localStorage.setItem('autoecole_depenses_saintedmond', JSON.stringify(depenses));
    } catch (e) {
      console.error(e);
    }
  }, [depenses]);

  useEffect(() => {
    try {
      localStorage.setItem('autoecole_recettes_saintedmond', JSON.stringify(recettes));
    } catch (e) {
      console.error(e);
    }
  }, [recettes]);

  // État et abonnement au service de synchronisation Cloud / Offline-first
  const [syncStatus, setSyncStatus] = useState<SyncStatus>(() => syncService.getStatus());

  useEffect(() => {
    const unsub = syncService.subscribeStatus(setSyncStatus);

    // Chargement initial depuis Supabase et fusion avec les données locales
    syncService.fetchAllFromCloud().then((cloudData) => {
      if (!cloudData) return;
      if (cloudData.candidats && cloudData.candidats.length > 0) {
        setCandidats((prev) => {
          const merged = [...prev];
          cloudData.candidats!.forEach((cc) => {
            const idx = merged.findIndex((c) => c.id === cc.id);
            if (idx === -1) merged.push(cc);
            else merged[idx] = cc;
          });
          return merged;
        });
      }
      if (cloudData.depenses && cloudData.depenses.length > 0) {
        setDepenses((prev) => {
          const merged = [...prev];
          cloudData.depenses!.forEach((cd) => {
            const idx = merged.findIndex((d) => d.id === cd.id);
            if (idx === -1) merged.push(cd);
            else merged[idx] = cd;
          });
          return merged;
        });
      }
      if (cloudData.recettes && cloudData.recettes.length > 0) {
        setRecettes((prev) => {
          const merged = [...prev];
          cloudData.recettes!.forEach((cr) => {
            const idx = merged.findIndex((r) => r.id === cr.id);
            if (idx === -1) merged.push(cr);
            else merged[idx] = cr;
          });
          return merged;
        });
      }
      if (cloudData.annexes && cloudData.annexes.length > 0) {
        setAnnexesList((prev) => Array.from(new Set([...prev, ...cloudData.annexes!])));
      }
    });

    // Écoute en temps réel (Realtime) pour les mises à jour distantes (ex: depuis le mobile)
    syncService.startRealtime({
      onCandidatChange: (payload) => {
        if (payload.eventType === 'INSERT') {
          setCandidats((prev) => [payload.new as Candidat, ...prev.filter((c) => c.id !== payload.new.id)]);
        } else if (payload.eventType === 'UPDATE') {
          setCandidats((prev) => prev.map((c) => (c.id === payload.new.id ? (payload.new as Candidat) : c)));
        } else if (payload.eventType === 'DELETE') {
          setCandidats((prev) => prev.filter((c) => c.id !== payload.old.id));
        }
      },
      onDepenseChange: (payload) => {
        if (payload.eventType === 'INSERT') {
          setDepenses((prev) => [payload.new as Depense, ...prev.filter((d) => d.id !== payload.new.id)]);
        } else if (payload.eventType === 'UPDATE') {
          setDepenses((prev) => prev.map((d) => (d.id === payload.new.id ? (payload.new as Depense) : d)));
        } else if (payload.eventType === 'DELETE') {
          setDepenses((prev) => prev.filter((d) => d.id !== payload.old.id));
        }
      },
      onRecetteChange: (payload) => {
        if (payload.eventType === 'INSERT') {
          setRecettes((prev) => [payload.new as Recette, ...prev.filter((r) => r.id !== payload.new.id)]);
        } else if (payload.eventType === 'UPDATE') {
          setRecettes((prev) => prev.map((r) => (r.id === payload.new.id ? (payload.new as Recette) : r)));
        } else if (payload.eventType === 'DELETE') {
          setRecettes((prev) => prev.filter((r) => r.id !== payload.old.id));
        }
      },
    });

    return () => {
      unsub();
      syncService.stopRealtime();
    };
  }, []);

  // Attendance states (Émargement & Pointage des élèves uniquement)
  const [presenceDate, setPresenceDate] = useState(() => new Date().toISOString().split('T')[0]);
  const [presenceHeure, setPresenceHeure] = useState(() => {
    const d = new Date();
    return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
  });
  const [presenceType, setPresenceType] = useState<'TOUS' | 'CODE' | 'CONDUITE'>('TOUS');
  const [presenceSearch, setPresenceSearch] = useState('');
  const [presenceAnnexe, setPresenceAnnexe] = useState('Toutes');

  // États onglet Résultats d'Examen
  const [resultatEpreuve, setResultatEpreuve] = useState<'TOUS' | 'CODE' | 'CONDUITE'>('TOUS');
  const [resultatStatutFilter, setResultatStatutFilter] = useState<'TOUS' | 'ADMIS' | 'AJOURNE' | 'PROGRAMME' | 'NON_PROGRAMME'>('TOUS');
  const [resultatSearch, setResultatSearch] = useState('');
  const [sessionExamNom, setSessionExamNom] = useState(() => {
    const mois = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    const now = new Date();
    return `Session ${mois[now.getMonth()]} ${now.getFullYear()} - Lomé`;
  });

  // Pointages des élèves : clé composite "candidatId_date" => { heure, typeSeance }
  // Chaque date est un enregistrement indépendant - cumul automatique des séances.
  const [presencesRecords, setPresencesRecords] = useState<Record<string, {
    heure: string;
    typeSeance: 'CODE' | 'CONDUITE';
  }>>(() => {
    try {
      const saved = localStorage.getItem('autoecole_presences_saintedmond_v2');
      return saved ? JSON.parse(saved) : {};
    } catch {
      return {};
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem('autoecole_presences_saintedmond_v2', JSON.stringify(presencesRecords));
    } catch (e) {
      console.error(e);
    }
  }, [presencesRecords]);

  // Filter calculations
  const filteredCandidats = candidats.filter((c) => {
    const matchAnnexe = annexeFilter === 'Toutes' || c.annexe === annexeFilter;
    const matchQuery = `${c.nom} ${c.prenom} ${c.contact}`.toLowerCase().includes(searchQuery.toLowerCase());
    const matchDateFrom = !dateFrom || c.date_inscription >= dateFrom;
    const matchDateTo = !dateTo || c.date_inscription <= dateTo;
    return matchAnnexe && matchQuery && matchDateFrom && matchDateTo;
  });

  const filteredDepenses = depenses.filter((d) => {
    const matchAnnexe = annexeFilter === 'Toutes' || d.annexe === annexeFilter;
    const matchDateFrom = !dateFrom || d.date >= dateFrom;
    const matchDateTo = !dateTo || d.date <= dateTo;
    if (role === 'SECRETAIRE' && d.type === 'SPECIALE_DG') return false;
    return matchAnnexe && matchDateFrom && matchDateTo;
  });

  const filteredRecettes = recettes.filter((r) => {
    const matchAnnexe = annexeFilter === 'Toutes' || r.annexe === annexeFilter;
    const matchDateFrom = !dateFrom || r.date >= dateFrom;
    const matchDateTo = !dateTo || r.date <= dateTo;
    return matchAnnexe && matchDateFrom && matchDateTo;
  });

  const totalDepenses = filteredDepenses.reduce((acc, d) => acc + d.montant, 0);
  const totalRecettes = filteredRecettes.reduce((acc, r) => acc + r.montant, 0);
  const admisCount = filteredCandidats.filter(c => c.statut === 'ADMIS').length;
  const nonAdmisCount = filteredCandidats.filter(c => c.statut === 'NON_ADMIS').length;

  // Calcul dynamique du bilan mensuel et des graphiques à partir des données réelles
  const MOIS_LABELS = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
  const currentYear = new Date().getFullYear();

  // Inscriptions par mois pour l'année en cours
  const monthlyInscriptions = MOIS_LABELS.map((label, idx) => {
    const monthStr = String(idx + 1).padStart(2, '0');
    const count = filteredCandidats.filter((c) => {
      if (!c.date_inscription) return false;
      return c.date_inscription.startsWith(`${currentYear}-${monthStr}`);
    }).length;
    return { m: label, v: count };
  });

  // Flux financiers mensuels réels pour l'année en cours
  const monthlyFinance = MOIS_LABELS.map((label, idx) => {
    const monthStr = String(idx + 1).padStart(2, '0');
    const rMonth = filteredRecettes
      .filter((r) => r.date && r.date.startsWith(`${currentYear}-${monthStr}`))
      .reduce((sum, r) => sum + r.montant, 0);
    const dMonth = filteredDepenses
      .filter((d) => d.date && d.date.startsWith(`${currentYear}-${monthStr}`))
      .reduce((sum, d) => sum + d.montant, 0);
    return {
      m: label,
      moisLong: `${label} ${currentYear}`,
      r: rMonth,
      d: dMonth,
      rK: Math.round(rMonth / 1000),
      dK: Math.round(dMonth / 1000),
    };
  });

  // Table Bilan mensuel : mois avec au moins une recette ou dépense
  const activeBilanRows = monthlyFinance.filter((row) => row.r > 0 || row.d > 0);

  const handleAddCandidat = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const nom = (formData.get('nom') as string).trim().toUpperCase();
    const prenom = (formData.get('prenom') as string).trim();
    const contact = (formData.get('contact') as string).trim();
    const annexe = formData.get('annexe') as string;
    const categorie = formData.get('categorie') as any;
    const langue = formData.get('langue') as any;
    const sexe = formData.get('sexe') as any;
    const montant_total = Number(formData.get('montant_total')) || 0;
    const montant_paye = Number(formData.get('montant_paye')) || 0;
    const date_inscription = (formData.get('date_inscription') as string) || new Date().toISOString().split('T')[0];
    const adresse = (formData.get('adresse') as string)?.trim() || '';
    const email = (formData.get('email') as string)?.trim() || undefined;
    const duree_formation_mois = Number(formData.get('duree_formation_mois')) || 3;
    const type_formation = (formData.get('type_formation') as any) || 'COMPLETE';

    if (!nom || !prenom || !contact) {
      alert('Veuillez renseigner le nom, prénom et contact.');
      return;
    }

    // Conduites par défaut selon le type de formation
    const nb_conduites_prevues =
      type_formation === 'CODE_SEUL' ? 0 :
      type_formation === 'CONDUITE_SEULE' ? 14 : 20;

    // Statuts examen selon le type de formation
    const statut_examen_code =
      type_formation === 'CONDUITE_SEULE' ? 'ADMIS' :     // déjà obtenu
      type_formation === 'CODE_SEUL'      ? 'NON_PROGRAMME' :
                                            'NON_PROGRAMME';
    const statut_examen_conduite =
      type_formation === 'CODE_SEUL' ? undefined : 'NON_PROGRAMME';

    const newId = (candidats.length + 1).toString();
    const newCand: Candidat = {
      id: newId,
      nom,
      prenom,
      contact,
      email,
      adresse,
      annexe,
      categorie,
      langue,
      sexe,
      montant_total,
      montant_paye,
      date_inscription,
      duree_formation_mois,
      type_formation,
      statut: 'INSCRIT',
      code_acces: generateAccessCode(),
      nb_conduites_prevues,
      nb_conduites_effectuees: 0,
      statut_examen_code: statut_examen_code as any,
      statut_examen_conduite: statut_examen_conduite as any,
      photo_url: newCandPhoto,
    };

    setCandidats([newCand, ...candidats]);
    setNewCandPhoto(undefined);
    syncService.syncCandidat(newCand);

    if (montant_paye > 0) {
      const newRec: Recette = {
        id: Date.now().toString(),
        intitule: `Premier versement - ${nom} ${prenom}`,
        montant: montant_paye,
        date: date_inscription,
        annexe,
        candidat_id: newId,
      };
      setRecettes([newRec, ...recettes]);
      syncService.syncRecette(newRec);
    }

    setModalType(null);
    showToast(`Candidat ${nom} ${prenom} inscrit avec succès !`);

    // Proposer de générer le reçu PDF
    setTimeout(() => {
      const generer = window.confirm(
        `Candidat ${nom} ${prenom} inscrit avec succès !\n\nVoulez-vous générer le reçu PDF d'inscription maintenant ?`
      );
      if (generer) {
        generateRecuCandidatPDF(newCand, schoolName, annexe);
      }
    }, 300);
  };

  const handleUpdateCandidat = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!editingCandidat) return;

    const formData = new FormData(e.currentTarget);
    const nom = (formData.get('nom') as string).trim().toUpperCase();
    const prenom = (formData.get('prenom') as string).trim();
    const contact = (formData.get('contact') as string).trim();
    const annexe = formData.get('annexe') as string;
    const categorie = formData.get('categorie') as any;
    const langue = formData.get('langue') as any;
    const sexe = formData.get('sexe') as any;
    const montant_total = Number(formData.get('montant_total')) || 0;
    const montant_paye = Number(formData.get('montant_paye')) || 0;
    const adresse = (formData.get('adresse') as string)?.trim() || '';
    const email = (formData.get('email') as string)?.trim() || undefined;
    const duree_formation_mois = Number(formData.get('duree_formation_mois')) || 3;
    const type_formation = (formData.get('type_formation') as any) || 'COMPLETE';
    let statut = (formData.get('statut') as any) || 'INSCRIT';
    const nb_conduites_prevues = Number(formData.get('nb_conduites_prevues')) || 0;
    const nb_conduites_effectuees = Number(formData.get('nb_conduites_effectuees')) || 0;
    const code_acces = (formData.get('code_acces') as string)?.trim() || editingCandidat.code_acces;
    const statut_examen_code = (formData.get('statut_examen_code') as any) || editingCandidat.statut_examen_code || 'NON_PROGRAMME';
    const date_examen_code = (formData.get('date_examen_code') as string)?.trim() || undefined;
    const statut_examen_conduite = (formData.get('statut_examen_conduite') as any) || editingCandidat.statut_examen_conduite || 'NON_PROGRAMME';
    const date_examen_conduite = (formData.get('date_examen_conduite') as string)?.trim() || undefined;

    // Harmonisation automatique du statut global
    if (statut_examen_code === 'ADMIS' && (type_formation === 'CODE_SEUL' || statut_examen_conduite === 'ADMIS')) {
      statut = 'ADMIS';
    } else if (statut_examen_conduite === 'ADMIS' && type_formation === 'CONDUITE_SEULE') {
      statut = 'ADMIS';
    } else if (statut_examen_code === 'AJOURNE' || statut_examen_conduite === 'AJOURNE') {
      statut = 'NON_ADMIS';
    } else if (statut_examen_code === 'NON_PROGRAMME' && statut_examen_conduite === 'NON_PROGRAMME' && statut !== 'ADMIS' && statut !== 'NON_ADMIS') {
      statut = 'INSCRIT';
    }

    if (!nom || !prenom || !contact) {
      alert('Veuillez renseigner le nom, prénom et contact.');
      return;
    }

    const updatedCandidats = candidats.map((c) => {
      if (c.id === editingCandidat.id) {
        return {
          ...c,
          nom,
          prenom,
          contact,
          annexe,
          categorie,
          langue,
          sexe,
          montant_total,
          montant_paye,
          adresse,
          email,
          duree_formation_mois,
          type_formation,
          statut,
          statut_examen_code,
          date_examen_code,
          statut_examen_conduite,
          date_examen_conduite,
          nb_conduites_prevues,
          nb_conduites_effectuees,
          code_acces,
          photo_url: editCandPhoto !== undefined ? editCandPhoto : c.photo_url,
        };
      }
      return c;
    });

    const updatedCand = updatedCandidats.find(c => c.id === editingCandidat.id);
    setCandidats(updatedCandidats);
    if (updatedCand) syncService.syncCandidat(updatedCand);

    // --- Synchroniser la recette liée si montant_paye a changé ---
    const ancienMontantPaye = editingCandidat.montant_paye;
    if (montant_paye !== ancienMontantPaye) {
      const updatedRecettes = recettes.map((r) => {
        // Recette d'inscription initiale liée à ce candidat
        if (r.candidat_id === editingCandidat.id && r.intitule.startsWith('Premier versement')) {
          const recetteCorrigee = { ...r, montant: montant_paye };
          syncService.syncRecette(recetteCorrigee);
          return recetteCorrigee;
        }
        return r;
      });
      setRecettes(updatedRecettes);
      localStorage.setItem('autoecole_recettes_saintedmond', JSON.stringify(updatedRecettes));
    }
    // --- Fin synchronisation recette ---

    setEditCandPhoto(undefined);
    setModalType(null);
    setEditingCandidat(null);
    showToast(`Dossier de ${nom} ${prenom} mis à jour avec succès !`);
  };

  const handleUpdateCandidatPhoto = (candidatId: string, newPhotoUrl?: string) => {
    setCandidats(candidats.map(c => c.id === candidatId ? { ...c, photo_url: newPhotoUrl } : c));
    showToast('Photo du candidat mise à jour !');
  };

  const handlePasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPasswordError(null);
    if (newPassword !== confirmPassword) {
      setPasswordError('Le nouveau mot de passe et sa confirmation ne correspondent pas.');
      return;
    }
    const res = updateUserPassword(role, oldPassword, newPassword);
    if (!res.success) {
      setPasswordError(res.error || 'Erreur lors de la modification.');
      return;
    }
    setPasswordModalOpen(false);
    setOldPassword('');
    setNewPassword('');
    setConfirmPassword('');
    showToast('Votre mot de passe a été modifié avec succès !');
  };

  const handleDeleteCandidat = (candidatId: string, nomPrenom: string) => {

    const confirmer = window.confirm(
      `Êtes-vous sûr de vouloir supprimer le candidat "${nomPrenom}" ?\nCette action retirera son dossier.`
    );
    if (!confirmer) return;

    setCandidats(candidats.filter(c => c.id !== candidatId));
    syncService.deleteCandidat(candidatId);
    setModalType(null);
    setEditingCandidat(null);
    showToast(`Candidat ${nomPrenom} supprimé.`);
  };

  const handleAddSupplementConduite = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!selectedCandidatForSupplement) return;

    const formData = new FormData(e.currentTarget);
    const nb_seances = Number(formData.get('nb_seances')) || 0;
    const montant_supplement = Number(formData.get('montant_supplement')) || 0;
    const montant_verse = Number(formData.get('montant_verse')) || 0;
    const mode_paiement = (formData.get('mode_paiement') as string) || 'Espèces';
    const motif = (formData.get('motif') as string) || 'Perfectionnement conduite';
    const date_operation = (formData.get('date_operation') as string) || new Date().toISOString().split('T')[0];

    if (nb_seances <= 0) {
      alert('Veuillez indiquer un nombre de séances valide (au moins 1).');
      return;
    }
    if (montant_supplement <= 0) {
      alert('Veuillez indiquer un montant pour le supplément.');
      return;
    }

    const updatedCandidats = candidats.map((c) => {
      if (c.id === selectedCandidatForSupplement.id) {
        return {
          ...c,
          nb_conduites_prevues: (c.nb_conduites_prevues || 0) + nb_seances,
          montant_total: c.montant_total + montant_supplement,
          montant_paye: c.montant_paye + montant_verse,
        };
      }
      return c;
    });

    setCandidats(updatedCandidats);

    // Enregistrement automatique de la recette si encaissement
    if (montant_verse > 0) {
      const newRecette: Recette = {
        id: Date.now().toString(),
        intitule: `Séances conduite (+${nb_seances}) – ${selectedCandidatForSupplement.nom} ${selectedCandidatForSupplement.prenom} [${motif}]`,
        montant: montant_verse,
        date: date_operation,
        annexe: selectedCandidatForSupplement.annexe,
        candidat_id: selectedCandidatForSupplement.id,
      };
      setRecettes([newRecette, ...recettes]);
      syncService.syncRecette(newRecette);
    }

    const updatedCand = updatedCandidats.find(c => c.id === selectedCandidatForSupplement.id)!;
    if (updatedCand) syncService.syncCandidat(updatedCand);
    const candSnapshot = { ...selectedCandidatForSupplement };
    setModalType(null);
    showToast(`+${nb_seances} séances de conduite enregistrées pour ${candSnapshot.nom} ${candSnapshot.prenom} !`);

    setTimeout(() => {
      const imprimer = window.confirm(
        `+${nb_seances} séances de conduite ajoutées avec succès pour ${candSnapshot.nom} ${candSnapshot.prenom}.\n\nVoulez-vous générer le reçu officiel PDF de ce supplément maintenant ?`
      );
      if (imprimer) {
        generateRecuSupplementConduitePDF(
          updatedCand,
          nb_seances,
          montant_supplement,
          montant_verse,
          mode_paiement,
          motif,
          schoolName,
          candSnapshot.annexe
        );
      }
    }, 250);
  };

  const handleAddDepense = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const intitule = (formData.get('intitule') as string).trim();
    const montant = Number(formData.get('montant')) || 0;
    const type = formData.get('type') as any;
    const annexe = formData.get('annexe') as string;
    const date = (formData.get('date') as string) || new Date().toISOString().split('T')[0];

    if (!intitule || montant <= 0) {
      alert('Veuillez spécifier un intitulé et un montant supérieur à 0.');
      return;
    }

    const newDep: Depense = { id: Date.now().toString(), intitule, montant, type, annexe, date };
    setDepenses([newDep, ...depenses]);
    syncService.syncDepense(newDep);
    setModalType(null);
    showToast('Dépense enregistrée.');
  };

  const handleAddRecette = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const intitule = (formData.get('intitule') as string).trim();
    const montant = Number(formData.get('montant')) || 0;
    const annexe = formData.get('annexe') as string;
    const date = (formData.get('date') as string) || new Date().toISOString().split('T')[0];

    if (!intitule || montant <= 0) {
      alert('Veuillez spécifier un intitulé et un montant valide.');
      return;
    }

    const newRec: Recette = { id: Date.now().toString(), intitule, montant, annexe, date };
    setRecettes([newRec, ...recettes]);
    syncService.syncRecette(newRec);
    setModalType(null);
    showToast('Recette ajoutée.');
  };
  const handleUpdateDepense = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!editingDepense) return;
    const formData = new FormData(e.currentTarget);
    const intitule = (formData.get('intitule') as string).trim();
    const montant = Number(formData.get('montant')) || 0;
    const type = formData.get('type') as any;
    const annexe = formData.get('annexe') as string;
    const date = (formData.get('date') as string) || editingDepense.date;

    if (!intitule || montant <= 0) {
      alert('Veuillez spécifier un intitulé et un montant valide.');
      return;
    }

    const updatedDep: Depense = { ...editingDepense, intitule, montant, type, annexe, date };
    const updatedList = depenses.map(d => d.id === editingDepense.id ? updatedDep : d);
    setDepenses(updatedList);
    syncService.syncDepense(updatedDep);
    setModalType(null);
    setEditingDepense(null);
    showToast('Dépense mise à jour avec succès.');
  };

  const handleDeleteDepense = (id: string, intitule: string) => {
    if (!window.confirm(`Voulez-vous vraiment supprimer la dépense "${intitule}" ?`)) return;
    const updatedList = depenses.filter(d => d.id !== id);
    setDepenses(updatedList);
    syncService.deleteDepense(id);
    showToast('Dépense supprimée.');
  };

  const handleUpdateRecette = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!editingRecette) return;
    const formData = new FormData(e.currentTarget);
    const intitule = (formData.get('intitule') as string).trim();
    const montant = Number(formData.get('montant')) || 0;
    const annexe = formData.get('annexe') as string;
    const date = (formData.get('date') as string) || editingRecette.date;

    if (!intitule || montant <= 0) {
      alert('Veuillez spécifier un intitulé et un montant valide.');
      return;
    }

    const updatedRec: Recette = { ...editingRecette, intitule, montant, annexe, date };
    const updatedList = recettes.map(r => r.id === editingRecette.id ? updatedRec : r);
    setRecettes(updatedList);
    syncService.syncRecette(updatedRec);

    // Si cette recette est liée à un candidat, synchroniser aussi le montant_paye du candidat
    if (editingRecette.candidat_id && editingRecette.intitule.startsWith('Premier versement')) {
      const cand = candidats.find(c => c.id === editingRecette.candidat_id);
      if (cand && cand.montant_paye !== montant) {
        const updatedCand = { ...cand, montant_paye: montant };
        setCandidats(candidats.map(c => c.id === cand.id ? updatedCand : c));
        syncService.syncCandidat(updatedCand);
      }
    }

    setModalType(null);
    setEditingRecette(null);
    showToast('Recette mise à jour avec succès.');
  };

  const handleDeleteRecette = (id: string, intitule: string) => {
    if (!window.confirm(`Voulez-vous vraiment supprimer la recette "${intitule}" ?`)) return;
    const updatedList = recettes.filter(r => r.id !== id);
    setRecettes(updatedList);
    syncService.deleteRecette(id);
    showToast('Recette supprimée.');
  };


  const navigationItems = [
    { name: 'Accueil', icon: TrendingUp, roles: ['DG', 'SUPER_ADMIN'] },
    { name: 'Candidats', icon: Users, roles: ['DG', 'SECRETAIRE', 'SUPER_ADMIN'] },
    { name: 'Dépenses', icon: DollarSign, roles: ['DG', 'SUPER_ADMIN'] },
    { name: 'Recettes', icon: DollarSign, roles: ['DG', 'SUPER_ADMIN'] },
    { name: 'Bilan Global', icon: FileText, roles: ['DG', 'SUPER_ADMIN'] },
    { name: 'Présence', icon: UserCheck, roles: ['DG', 'SUPER_ADMIN'] },
    { name: 'Résultats', icon: Award, roles: ['DG', 'SUPER_ADMIN'] },

  ];

  if (!isAuthenticated) {
    return (
      <AuthScreen
        onLoginSuccess={(newSchool, newDirector, newRole, primaryBranch) => {
          setSchoolName(newSchool);
          setDirectorName(newDirector);
          setRole(newRole);
          if (primaryBranch && !annexesList.includes(primaryBranch)) {
            setAnnexesList((prev) => [primaryBranch, ...prev]);
            setAnnexeFilter(primaryBranch);
          }
          setIsAuthenticated(true);
          showToast(`Bienvenue sur ${newSchool} !`);
        }}
      />
    );
  }

  return (
    <div className="flex min-h-screen bg-slate-50 text-slate-800">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed top-5 right-5 z-50 flex items-center gap-2 bg-emerald-600 text-white px-4 py-3 rounded-xl shadow-xl animate-bounce">
          <CheckCircle2 className="w-5 h-5" />
          <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Sidebar Navigation */}
      <aside className={`fixed inset-y-0 left-0 z-40 w-72 bg-slate-900 text-white p-5 flex flex-col justify-between transition-transform duration-200 lg:static lg:translate-x-0 ${mobileMenuOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <div>
          <div className="flex items-center justify-between pb-6 border-b border-slate-800">
            <div className="flex items-center gap-3 min-w-0">
              <img
                src="/app_icon.png"
                alt="Logo Auto-École Saint Edmond"
                className="w-11 h-11 rounded-xl object-contain bg-white p-1 shadow-md shadow-black/40 border border-white/20 shrink-0"
              />
              <div className="overflow-hidden min-w-0">
                <h1 className="font-extrabold text-[15px] leading-snug text-white tracking-tight">
                  Auto-École Saint Edmond
                </h1>
                <p className="text-[10px] text-amber-400 font-bold tracking-wide uppercase mt-0.5">
                  Agrément N° 036/MTRAF/META
                </p>
              </div>
            </div>
            <button onClick={() => setMobileMenuOpen(false)} className="lg:hidden text-slate-400 hover:text-white shrink-0 ml-1">
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* User Profile Card */}
          <div className="mt-5 p-3 rounded-xl bg-slate-800/60 border border-slate-700/50">
            <div className="flex items-center gap-3">
              {/* Avatar avec upload depuis la galerie */}
              <div className="relative group shrink-0">
                <input
                  type="file"
                  ref={fileInputUserPhotoRef}
                  onChange={handleUserPhotoUpload}
                  accept="image/*"
                  className="hidden"
                />
                {userPhoto ? (
                  <img
                    src={userPhoto}
                    alt={directorName}
                    className="w-10 h-10 rounded-full object-cover border-2 border-blue-400 shadow-sm"
                  />
                ) : (
                  <div className="w-10 h-10 rounded-full bg-blue-500 text-white flex items-center justify-center font-bold text-xs uppercase shadow-sm">
                    {directorName.split(' ').map(n => n[0]).join('').slice(0, 2)}
                  </div>
                )}
                <button
                  type="button"
                  onClick={() => fileInputUserPhotoRef.current?.click()}
                  title="Changer ma photo de profil (depuis la galerie)"
                  className="absolute -bottom-1 -right-1 w-5 h-5 rounded-full bg-blue-600 hover:bg-blue-500 text-white flex items-center justify-center shadow-md transition cursor-pointer border border-slate-900"
                >
                  <Camera className="w-2.5 h-2.5" />
                </button>
              </div>

              <div className="overflow-hidden flex-1">
                <p className="text-sm font-medium truncate">{directorName}</p>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <span className={`inline-block w-2 h-2 rounded-full ${role === 'DG' ? 'bg-amber-400' : 'bg-emerald-400'}`} />
                  <span className="text-xs text-slate-400 font-medium">{role === 'DG' ? 'Directeur Général' : 'Secrétariat'}</span>
                </div>
              </div>
            </div>

            {userPhoto && (
              <button
                type="button"
                onClick={() => {
                  setUserPhoto(null);
                  localStorage.removeItem(`autoecole_user_photo_${role}`);
                  showToast('Photo supprimée.');
                }}
                className="mt-1 text-[10px] text-slate-400 hover:text-rose-400 transition underline text-left px-1"
              >
                Supprimer ma photo
              </button>
            )}

            <button
              type="button"
              onClick={() => {
                setPasswordError(null);
                setOldPassword('');
                setNewPassword('');
                setConfirmPassword('');
                setPasswordModalOpen(true);
              }}
              className="mt-2.5 w-full py-1.5 px-2.5 rounded-lg bg-slate-900/80 hover:bg-slate-700/80 text-[11px] font-semibold text-slate-300 hover:text-white border border-slate-700/60 transition flex items-center justify-center gap-1.5"
            >
              <KeyRound className="w-3.5 h-3.5 text-amber-400" />
              <span>Modifier mon mot de passe</span>
            </button>
          </div>


          {/* Navigation Links */}
          <nav className="mt-6 space-y-1.5">
            {navigationItems
              .filter((item) => item.roles.includes(role))
              .map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.name;
                return (
                  <button
                    key={item.name}
                    onClick={() => {
                      setActiveTab(item.name);
                      setMobileMenuOpen(false);
                    }}
                    className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium transition-colors ${
                      isActive ? 'bg-blue-600 text-white shadow-md shadow-blue-600/25' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                    }`}
                  >
                    <Icon className="w-4 h-4" />
                    <span>{item.name}</span>
                  </button>
                );
              })}
          </nav>
        </div>

        {/* Bottom Actions */}
        <div className="pt-4 border-t border-slate-800 space-y-2">

          <button
            onClick={() => {
              setModalType('logout');
            }}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 text-xs text-rose-400 hover:bg-rose-500/10 rounded-lg transition"
          >
            <span>Déconnexion</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Header */}
        <header className="sticky top-0 z-30 bg-white border-b border-slate-200 px-5 py-3.5 flex items-center justify-between shadow-xs">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setMobileMenuOpen(true)}
              className="lg:hidden p-2 rounded-lg text-slate-600 hover:bg-slate-100"
            >
              <Menu className="w-5 h-5" />
            </button>
            <h2 className="text-xl font-bold text-slate-800">{activeTab}</h2>
          </div>

          <div className="flex items-center gap-3">
            {/* Date range filter */}
            <div className="hidden xl:flex items-center gap-2 text-xs bg-slate-100 px-2.5 py-1.5 rounded-lg border border-slate-200">
              <Calendar className="w-3.5 h-3.5 text-slate-500" />
              <input
                type="date"
                value={dateFrom}
                onChange={(e) => setDateFrom(e.target.value)}
                className="bg-transparent text-slate-700 font-medium focus:outline-none"
              />
              <span className="text-slate-400">à</span>
              <input
                type="date"
                value={dateTo}
                onChange={(e) => setDateTo(e.target.value)}
                className="bg-transparent text-slate-700 font-medium focus:outline-none"
              />
            </div>

            {/* Annexe selector dynamique + Bouton Ajouter Annexe (pour le DG) */}
            <div className="hidden sm:flex items-center gap-1.5">
              <div className="flex items-center gap-2 text-sm bg-slate-100 px-3 py-1.5 rounded-lg border border-slate-200">
                <span className="text-slate-500 font-medium">Agence / Siège :</span>
                <select
                  value={annexeFilter}
                  onChange={(e) => setAnnexeFilter(e.target.value)}
                  className="bg-transparent font-semibold text-slate-700 focus:outline-none cursor-pointer"
                >
                  <option value="Toutes">Toutes les agences</option>
                  {annexesList.map((a) => (
                    <option key={a} value={a}>{a}</option>
                  ))}
                </select>
              </div>

              {role === 'DG' && (
                <button
                  type="button"
                  onClick={() => setModalType('add_annexe')}
                  title="Créer une nouvelle annexe"
                  className="flex items-center gap-1 bg-slate-100 hover:bg-slate-200 text-slate-700 border border-slate-200 px-2.5 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer"
                >
                  <Plus className="w-3.5 h-3.5 text-blue-600" />
                  <span>Nouvelle Annexe</span>
                </button>
              )}
            </div>

            {/* Indicateur de statut Offline-First / Cloud Sync */}
            <div 
              onClick={() => {
                if (syncStatus === 'online_synced') {
                  showToast('Cloud actif : Données synchronisées avec Supabase en temps réel.');
                } else if (syncStatus === 'syncing') {
                  showToast('Synchronisation en cours avec le serveur cloud...');
                } else {
                  showToast('Mode Hors Ligne : Données protégées et stockées localement sur cet appareil.');
                }
              }}
              title="Statut de synchronisation des données (cliquez pour infos)"
              className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs font-semibold border cursor-pointer transition select-none ${
                syncStatus === 'online_synced' 
                  ? 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100'
                  : syncStatus === 'syncing'
                  ? 'bg-blue-50 text-blue-700 border-blue-200 animate-pulse'
                  : 'bg-amber-50 text-amber-700 border-amber-200 hover:bg-amber-100'
              }`}
            >
              {syncStatus === 'online_synced' ? (
                <>
                  <Wifi className="w-3.5 h-3.5 text-emerald-600" />
                  <span className="hidden md:inline">En ligne (Cloud)</span>
                </>
              ) : syncStatus === 'syncing' ? (
                <>
                  <RefreshCw className="w-3.5 h-3.5 text-blue-600 animate-spin" />
                  <span className="hidden md:inline">Synchronisation...</span>
                </>
              ) : (
                <>
                  <WifiOff className="w-3.5 h-3.5 text-amber-600" />
                  <span className="hidden md:inline">Hors ligne (Local)</span>
                </>
              )}
            </div>

            {/* Bouton Installer l'application (PWA) */}
            {deferredPrompt && (
              <button
                type="button"
                onClick={handleInstallApp}
                title="Installer le logiciel sur votre bureau"
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold bg-amber-500 hover:bg-amber-600 text-slate-950 shadow-sm transition"
              >
                <Download className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">Installer l'application</span>
              </button>
            )}

            {/* Quick action button based on tab */}
            {activeTab === 'Candidats' && (
              <button
                onClick={() => setModalType('add_candidat')}
                className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-3.5 py-1.5 rounded-lg text-sm font-semibold shadow-sm transition"
              >
                <Plus className="w-4 h-4" />
                <span>Nouveau Candidat</span>
              </button>
            )}
          </div>
        </header>

        {/* Tab Content */}
        <main className="p-5 lg:p-7 max-w-7xl mx-auto w-full space-y-6">
          {/* ================= ACCUEIL / DASHBOARD ================= */}
          {activeTab === 'Accueil' && (
            <>
              {/* Marketing & Pedagogical Banner */}
              <div className={`relative overflow-hidden rounded-2xl bg-gradient-to-r ${slides[slideIndex].color} text-white p-6 shadow-md transition-all duration-500`}>
                <div className="relative z-10 max-w-xl">
                  <span className="inline-block bg-white/20 backdrop-blur-xs text-xs font-bold tracking-wider uppercase px-2.5 py-1 rounded-full mb-2">
                    Actualité Auto-École
                  </span>
                  <h3 className="text-2xl font-bold mb-1">{slides[slideIndex].title}</h3>
                  <p className="text-white/90 text-sm">{slides[slideIndex].sub}</p>
                </div>
                <div className="absolute right-5 bottom-4 flex gap-1.5">
                  {slides.map((_, i) => (
                    <button
                      key={i}
                      onClick={() => setSlideIndex(i)}
                      className={`w-2.5 h-2.5 rounded-full transition-all ${i === slideIndex ? 'bg-white w-6' : 'bg-white/40'}`}
                    />
                  ))}
                </div>
              </div>

              {/* Subscription Notice */}
              <div className="bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 rounded-2xl p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 shadow-xs">
                <div>
                  <h4 className="font-bold text-amber-900 text-sm flex items-center gap-1.5">
                    <Shield className="w-4 h-4 text-amber-600" />
                    <span>Licence Auto-École Saint Edmond - Active</span>
                  </h4>
                  <p className="text-xs text-amber-700 mt-0.5">
                    Agrément d'État N° 036/MTRAF/META • Siège unique : Tokoin Ramco (Von Boutique LG, face Ambassade de Belgique, Lomé) • Tél : +228 91 88 02 75
                  </p>
                </div>
                <div className="bg-amber-100 text-amber-800 text-xs px-3 py-1.5 rounded-lg font-semibold shrink-0">
                  Valide 2026-2027
                </div>
              </div>

              {/* KPI Cards Grid */}
              <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <div
                  onClick={() => setActiveTab('Candidats')}
                  className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs hover:border-blue-500 hover:shadow-md cursor-pointer transition"
                >
                  <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Inscrits</p>
                  <p className="text-2xl font-extrabold text-slate-800 mt-1">{filteredCandidats.length}</p>
                  <p className="text-xs text-emerald-600 mt-1 font-medium">Actifs en formation</p>
                </div>

                <div
                  onClick={() => {
                    setModalData({ statut: 'ADMIS' });
                    setModalType('broadcast_msg');
                  }}
                  className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs hover:border-emerald-500 hover:shadow-md cursor-pointer transition"
                >
                  <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Admis</p>
                  <p className="text-2xl font-extrabold text-emerald-600 mt-1">{admisCount}</p>
                  <p className="text-xs text-slate-500 mt-1 font-medium">Cliquez pour notifier</p>
                </div>

                <div
                  onClick={() => {
                    setModalData({ statut: 'NON_ADMIS' });
                    setModalType('broadcast_msg');
                  }}
                  className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs hover:border-rose-500 hover:shadow-md cursor-pointer transition"
                >
                  <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Non Admis</p>
                  <p className="text-2xl font-extrabold text-rose-600 mt-1">{nonAdmisCount}</p>
                  <p className="text-xs text-slate-500 mt-1 font-medium">À relancer pour session</p>
                </div>

                <div
                  onClick={() => setActiveTab('Recettes')}
                  className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs hover:border-blue-500 hover:shadow-md cursor-pointer transition"
                >
                  <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Recettes</p>
                  <p className="text-xl font-extrabold text-slate-800 mt-1 truncate">{totalRecettes.toLocaleString('fr-FR')} F</p>
                  <p className="text-xs text-blue-600 mt-1 font-medium">Entrées de caisse</p>
                </div>

                <div
                  onClick={() => setActiveTab('Dépenses')}
                  className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs hover:border-rose-500 hover:shadow-md cursor-pointer transition"
                >
                  <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Dépenses</p>
                  <p className="text-xl font-extrabold text-rose-600 mt-1 truncate">{totalDepenses.toLocaleString('fr-FR')} F</p>
                  <p className="text-xs text-slate-500 mt-1 font-medium">Charges du mois</p>
                </div>

                <div
                  onClick={() => setModalType('permis_retires')}
                  className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs hover:border-blue-500 hover:shadow-md cursor-pointer transition"
                >
                  <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Permis Retirés</p>
                  <p className="text-2xl font-extrabold text-slate-800 mt-1">{admisCount}</p>
                  <p className="text-xs text-slate-500 mt-1 font-medium">Délivrés aux élèves</p>
                </div>

                <div
                  onClick={() => setModalType('export_pdf')}
                  className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs hover:border-blue-500 hover:shadow-md cursor-pointer transition"
                >
                  <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Export PDF</p>
                  <p className="text-base font-extrabold text-blue-600 mt-1 flex items-center gap-1">
                    <Download className="w-4 h-4" /> 4 Rapports
                  </p>
                  <p className="text-xs text-slate-500 mt-1 font-medium">Télécharger les états</p>
                </div>

                <div
                  onClick={() => setModalType('sessions_stats')}
                  className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs hover:border-blue-500 hover:shadow-md cursor-pointer transition"
                >
                  <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Examens</p>
                  <p className="text-2xl font-extrabold text-slate-800 mt-1">{filteredCandidats.filter(c => c.date_examen_code || c.date_examen_conduite).length}</p>
                  <p className="text-xs text-slate-500 mt-1 font-medium">Sessions planifiées</p>
                </div>
              </div>

              {/* Graphic Comparisons (Dynamiques réels) */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs">
                  <div className="flex items-center justify-between mb-4">
                    <h4 className="font-bold text-slate-800 text-sm">Évolution des inscriptions par mois ({currentYear})</h4>
                    <span className="text-xs text-blue-600 font-bold">{filteredCandidats.length} total</span>
                  </div>
                  <div className="h-44 flex items-end justify-between gap-1 pt-6 border-b border-slate-200 pb-2 overflow-x-auto">
                    {monthlyInscriptions.map((item) => {
                      const maxInsc = Math.max(...monthlyInscriptions.map((x) => x.v), 1);
                      const heightPercent = item.v > 0 ? Math.max((item.v / maxInsc) * 100, 10) : 0;
                      return (
                        <div key={item.m} className="flex-1 min-w-[28px] flex flex-col items-center gap-1 h-full justify-end">
                          <span className={`text-[10px] font-bold ${item.v > 0 ? 'text-blue-600' : 'text-slate-300'}`}>{item.v}</span>
                          <div
                            style={{ height: `${heightPercent}%` }}
                            className={`w-full rounded-t-lg transition-all ${item.v > 0 ? 'bg-blue-600 hover:bg-blue-700' : 'bg-slate-100 h-1'}`}
                          />
                          <span className="text-[10px] text-slate-500 font-medium">{item.m}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>

                <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs">
                  <div className="flex items-center justify-between mb-4">
                    <h4 className="font-bold text-slate-800 text-sm">Recettes vs Dépenses (en milliers F - {currentYear})</h4>
                    <div className="flex items-center gap-3 text-xs font-semibold">
                      <span className="flex items-center gap-1 text-emerald-600">
                        <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 inline-block" /> Recettes
                      </span>
                      <span className="flex items-center gap-1 text-rose-600">
                        <span className="w-2.5 h-2.5 rounded-full bg-rose-500 inline-block" /> Dépenses
                      </span>
                    </div>
                  </div>
                  <div className="h-44 flex items-end justify-between gap-1 pt-6 border-b border-slate-200 pb-2 overflow-x-auto">
                    {monthlyFinance.map((item) => {
                      const maxVal = Math.max(...monthlyFinance.map((x) => Math.max(x.rK, x.dK)), 1);
                      const rPercent = item.rK > 0 ? Math.max((item.rK / maxVal) * 100, 8) : 0;
                      const dPercent = item.dK > 0 ? Math.max((item.dK / maxVal) * 100, 8) : 0;
                      return (
                        <div key={item.m} className="flex-1 min-w-[40px] flex flex-col items-center gap-1 h-full justify-end">
                          <div className="w-full flex items-end justify-center gap-0.5 h-full">
                            {/* Recette bar */}
                            <div className="flex-1 flex flex-col items-center justify-end h-full">
                              <span className={`text-[9px] font-bold leading-none mb-0.5 ${item.rK > 0 ? 'text-emerald-700' : 'text-slate-300'}`}>
                                {item.rK > 0 ? `${item.rK}k` : '0'}
                              </span>
                              <div
                                style={{ height: `${rPercent}%` }}
                                className={`w-full rounded-t-sm transition-all ${item.rK > 0 ? 'bg-emerald-500 hover:bg-emerald-600' : 'bg-slate-100 h-1'}`}
                              />
                            </div>
                            {/* Dépense bar */}
                            <div className="flex-1 flex flex-col items-center justify-end h-full">
                              <span className={`text-[9px] font-bold leading-none mb-0.5 ${item.dK > 0 ? 'text-rose-700' : 'text-slate-300'}`}>
                                {item.dK > 0 ? `${item.dK}k` : '0'}
                              </span>
                              <div
                                style={{ height: `${dPercent}%` }}
                                className={`w-full rounded-t-sm transition-all ${item.dK > 0 ? 'bg-rose-500 hover:bg-rose-600' : 'bg-slate-100 h-1'}`}
                              />
                            </div>
                          </div>
                          <span className="text-[10px] text-slate-500 font-medium">{item.m}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>

              </div>
            </>
          )}

          {/* ================= CANDIDATS ================= */}
          {activeTab === 'Candidats' && (
            <div className="space-y-4">
              {role === 'SECRETAIRE' && (
                <div className="bg-blue-50 border border-blue-200 rounded-xl p-3.5 text-xs text-blue-900 flex items-center gap-2">
                  <Shield className="w-4 h-4 text-blue-600 shrink-0" />
                  <span>
                    <strong>Espace Secrétaire Sécurisé :</strong> Vous êtes autorisée à enregistrer de nouvelles inscriptions et à encaisser les frais de scolarité.
                  </span>
                </div>
              )}

              {/* Filters Bar */}
              <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex flex-wrap items-center justify-between gap-3">
                <div className="relative flex-1 min-w-[220px]">
                  <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                  <input
                    type="text"
                    placeholder="Rechercher par nom, prénom ou contact..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>

                <div className="flex items-center gap-2 flex-wrap">
                  {/* Bascule Mode Cartes / Tableau */}
                  <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200">
                    <button
                      type="button"
                      onClick={() => setCandidatsViewMode('cartes')}
                      className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                        candidatsViewMode === 'cartes'
                          ? 'bg-white text-blue-600 shadow-xs'
                          : 'text-slate-500 hover:text-slate-800'
                      }`}
                      title="Afficher sous forme de cartes profils avec photos"
                    >
                      <LayoutGrid className="w-3.5 h-3.5" />
                      <span>Cartes</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => setCandidatsViewMode('tableau')}
                      className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                        candidatsViewMode === 'tableau'
                          ? 'bg-white text-blue-600 shadow-xs'
                          : 'text-slate-500 hover:text-slate-800'
                      }`}
                      title="Afficher sous forme de tableau détaillé"
                    >
                      <List className="w-3.5 h-3.5" />
                      <span>Tableau</span>
                    </button>
                  </div>

                  <button
                    onClick={() => generateCandidatsPDF(filteredCandidats)}
                    className="flex items-center gap-2 bg-slate-100 hover:bg-slate-200 text-slate-700 px-3.5 py-2 rounded-xl text-xs font-semibold transition"
                  >
                    <Download className="w-3.5 h-3.5" />
                    <span>Export PDF</span>
                  </button>
                  <button
                    onClick={() => setModalType('autre_frais')}
                    className="bg-slate-100 hover:bg-slate-200 text-slate-700 px-3.5 py-2 rounded-xl text-xs font-semibold transition"
                  >
                    Autres Frais
                  </button>
                  <button
                    onClick={() => {
                      setNewCandPhoto(undefined);
                      setNewCandSexe('MASCULIN');
                      setModalType('add_candidat');
                    }}
                    className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-xl text-xs font-semibold shadow-xs transition"
                  >
                    <Plus className="w-3.5 h-3.5" />
                    <span>Inscrire Candidat</span>
                  </button>
                </div>
              </div>


              {/* ================= VUE CARTES PROFILS (AVATARS HOMME / FEMME) ================= */}
              {candidatsViewMode === 'cartes' ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3.5">
                  {filteredCandidats.map((c) => {
                    const solde = (c.montant_total || 0) - (c.montant_paye || 0);
                    return (
                      <div
                        key={c.id}
                        className="bg-white rounded-2xl border border-slate-200/90 p-3.5 shadow-2xs hover:shadow-md hover:border-blue-300 transition-all flex flex-col items-center text-center relative group"
                      >
                        {/* Avatar Homme/Femme avec caméra cliquable */}
                        <div className="mb-2">
                          <CandidateAvatar
                            sexe={c.sexe}
                            photoUrl={c.photo_url}
                            size="md"
                            editable={true}
                            onPhotoChange={(newUrl) => handleUpdateCandidatPhoto(c.id, newUrl)}
                          />
                        </div>

                        {/* Nom complet */}
                        <h4 className="font-bold text-xs text-slate-900 uppercase tracking-tight line-clamp-1 w-full" title={`${c.nom} ${c.prenom}`}>
                          {c.nom} {c.prenom}
                        </h4>

                        {/* Contact téléphone */}
                        <p className="text-[11px] text-blue-600 font-semibold mt-0.5 flex items-center justify-center gap-1">
                          <Phone className="w-2.5 h-2.5" />
                          <span>{c.contact || '—'}</span>
                        </p>

                        {/* Login App Candidat (comme sur la capture écran) */}
                        <div className="mt-1.5 inline-flex items-center gap-1 px-2 py-0.5 bg-slate-50 border border-slate-200/80 rounded-md text-[10px] text-slate-600 font-mono">
                          <span className="text-slate-400">Login:</span>
                          <span className="font-bold text-indigo-700">{c.code_acces || '—'}</span>
                          <Eye className="w-2.5 h-2.5 text-slate-400" />
                        </div>

                        {/* Badges d'informations */}
                        <div className="mt-2 flex flex-wrap items-center justify-center gap-1 text-[9px] w-full">
                          <span className="px-1.5 py-0.5 rounded font-bold bg-blue-50 text-blue-700 border border-blue-200/60">
                            Permis {c.categorie || 'B'}
                          </span>
                          <span className="px-1.5 py-0.5 rounded font-medium bg-slate-100 text-slate-600">
                            {c.annexe?.replace('Tokoin Ramco (Siège)', 'Tokoin Ramco') || 'Siège'}
                          </span>
                          <span className={`px-1.5 py-0.5 rounded font-bold ${
                            c.statut === 'ADMIS'
                              ? 'bg-emerald-50 text-emerald-700 border border-emerald-200/60'
                              : c.statut === 'NON_ADMIS'
                              ? 'bg-rose-50 text-rose-700 border border-rose-200/60'
                              : 'bg-amber-50 text-amber-700 border border-amber-200/60'
                          }`}>
                            {c.statut === 'ADMIS' ? 'Admis' : c.statut === 'NON_ADMIS' ? 'Ajourné' : 'En cours'}
                          </span>
                          <span className={`px-1.5 py-0.5 rounded font-bold ${
                            solde > 0
                              ? 'bg-amber-50 text-amber-700 border border-amber-200/60'
                              : 'bg-emerald-50 text-emerald-700 border border-emerald-200/60'
                          }`}>
                            {solde > 0 ? `Reste: ${solde.toLocaleString('fr-FR')} F` : 'Soldé ✓'}
                          </span>
                        </div>

                        {/* Bouton VOIR (comme sur la capture écran) */}
                        <div className="mt-2.5 w-full pt-2 border-t border-slate-100 flex items-center gap-1.5">
                          <button
                            type="button"
                            onClick={() => {
                              setEditingCandidat(c);
                              setEditCandPhoto(c.photo_url);
                              setEditCandSexe(c.sexe);
                              setModalType('edit_candidat');
                            }}
                            className="flex-1 py-1.5 px-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-[11px] rounded-lg shadow-2xs transition flex items-center justify-center gap-1 cursor-pointer"
                          >
                            <span>VOIR</span>
                          </button>
                          <button
                            type="button"
                            onClick={() => generateRecuCandidatPDF(c, schoolName, c.annexe)}
                            className="p-1.5 text-slate-500 hover:text-blue-600 hover:bg-blue-50 border border-slate-200 rounded-lg transition"
                            title="Télécharger le reçu d'inscription"
                          >
                            <FileText className="w-3 h-3" />
                          </button>
                        </div>
                      </div>
                    );
                  })}
                  {filteredCandidats.length === 0 && (
                    <div className="col-span-full py-12 text-center text-slate-400 bg-white rounded-2xl border border-slate-200">
                      Aucun candidat trouvé pour ces critères.
                    </div>
                  )}
                </div>
              ) : (
                /* Candidates Table */
                <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="bg-slate-50 text-slate-500 font-semibold text-xs border-b border-slate-200 uppercase tracking-wider">

                      <tr>
                        <th className="px-4 py-3.5">Candidat</th>
                        <th className="px-3 py-3.5">Code App</th>
                        <th className="px-3 py-3.5">Annexe</th>
                        <th className="px-3 py-3.5">Permis & Conduite</th>
                        <th className="px-3 py-3.5">Règlement Financier</th>
                        <th className="px-3 py-3.5">Statut</th>
                        <th className="px-4 py-3.5 text-right">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {filteredCandidats.map((c) => {
                        const solde = (c.montant_total || 0) - (c.montant_paye || 0);
                        const pctConduite = (c.nb_conduites_prevues || 0) > 0
                          ? Math.round(((c.nb_conduites_effectuees || 0) / (c.nb_conduites_prevues || 1)) * 100)
                          : 0;
                        const msgInvitation = `Bonjour ${c.prenom || ''} ! Votre inscription à l'Auto-École Saint Edmond est validée. Téléchargez l'application Saint Edmond Candidat et connectez-vous avec votre code d'accès : *${c.code_acces || 'CODE'}* pour suivre vos cours, conduites et examens.`;
                        const annexeAffichee = (c.annexe || 'Tokoin Ramco')
                          .replace('Tokoin Ramco (Siège)', 'Tokoin Ramco')
                        const contactClean = (c.contact || '').replace(/\s+/g, '');


                        return (
                          <tr key={c.id} className="hover:bg-slate-50/80 transition">
                            {/* Candidat + Contact */}
                            <td className="px-4 py-3.5 whitespace-nowrap">
                              <div className="flex items-center gap-2.5">
                                <CandidateAvatar
                                  sexe={c.sexe}
                                  photoUrl={c.photo_url}
                                  size="sm"
                                  editable={true}
                                  onPhotoChange={(url) => handleUpdateCandidatPhoto(c.id, url)}
                                />
                                <div>

                                  <span className="font-bold text-slate-900 block text-xs leading-tight">
                                    {c.nom} {c.prenom}
                                  </span>
                                  <span className="text-[11px] text-slate-500 font-medium block mt-0.5">
                                    {c.contact || '—'}
                                  </span>
                                </div>
                              </div>
                            </td>

                            {/* Code App */}
                            <td className="px-3 py-3.5 whitespace-nowrap">
                              <span className="font-mono font-bold text-xs bg-indigo-50 text-indigo-700 border border-indigo-200/80 px-2 py-1 rounded-md tracking-wider">
                                {c.code_acces || '—'}
                              </span>
                            </td>

                            {/* Annexe */}
                            <td className="px-3 py-3.5 whitespace-nowrap">
                              <span className="inline-flex items-center text-xs font-medium text-slate-700 bg-slate-100 border border-slate-200/70 px-2.5 py-1 rounded-lg">
                                {annexeAffichee}
                              </span>
                            </td>

                            {/* Permis & Conduite */}
                            <td className="px-3 py-3.5 whitespace-nowrap">
                              <div className="flex items-center gap-1.5">
                                <span className="font-bold text-blue-600 text-xs">Cat. {c.categorie || 'B'}</span>
                                {c.type_formation === 'CONDUITE_SEULE' && (
                                  <span className="text-[9px] font-bold bg-indigo-100 text-indigo-700 px-1.5 py-0.5 rounded">Conduite seule</span>
                                )}
                                {c.type_formation === 'CODE_SEUL' && (
                                  <span className="text-[9px] font-bold bg-purple-100 text-purple-700 px-1.5 py-0.5 rounded">Code seul</span>
                                )}
                              </div>
                              <div className="flex items-center gap-1.5 mt-1">
                                <div className="w-16 h-1.5 bg-slate-100 rounded-full overflow-hidden border border-slate-200/50">
                                  <div
                                    className={`h-full rounded-full transition-all ${pctConduite >= 100 ? 'bg-emerald-500' : 'bg-blue-500'}`}
                                    style={{ width: `${Math.min(pctConduite, 100)}%` }}
                                  />
                                </div>
                                <span className="text-[10px] font-semibold text-slate-500 whitespace-nowrap">
                                  {c.nb_conduites_effectuees || 0}/{c.nb_conduites_prevues || 20} séances
                                </span>
                              </div>
                            </td>

                            {/* Règlement Financier */}
                            <td className="px-3 py-3.5 whitespace-nowrap">
                              <div className="flex items-baseline gap-1">
                                <span className="font-extrabold text-slate-900 text-xs tabular-nums">
                                  {(c.montant_paye || 0).toLocaleString('fr-FR')} F
                                </span>
                                <span className="text-slate-400 text-[11px]">
                                  / {(c.montant_total || 0).toLocaleString('fr-FR')} F
                                </span>
                              </div>
                              <div className="mt-0.5">
                                {solde <= 0 ? (
                                  <span className="inline-flex items-center text-[10px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-1.5 py-0.5 rounded">
                                    ✓ Soldé
                                  </span>
                                ) : (
                                  <span className="inline-flex items-center text-[10px] font-bold text-amber-700 bg-amber-50 border border-amber-200 px-1.5 py-0.5 rounded">
                                    Reste: {(solde || 0).toLocaleString('fr-FR')} F
                                  </span>
                                )}
                              </div>
                            </td>

                            {/* Statut */}
                            <td className="px-3 py-3.5 whitespace-nowrap">
                              <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-bold ${
                                c.statut === 'ADMIS' ? 'bg-emerald-100 text-emerald-800' :
                                c.statut === 'NON_ADMIS' ? 'bg-rose-100 text-rose-800' : 'bg-amber-100 text-amber-800'
                              }`}>
                                {c.statut === 'NON_ADMIS' ? 'AJOURNÉ' : c.statut}
                              </span>
                            </td>

                            {/* Actions */}
                            <td className="px-4 py-3.5 text-right whitespace-nowrap">
                              <div className="flex items-center justify-end gap-1.5">
                                <button
                                  onClick={() => {
                                    setSelectedCandidatForSupplement(c);
                                    setModalType('add_supplement_conduite');
                                  }}
                                  className="inline-flex items-center gap-1 text-[11px] font-bold bg-amber-50 hover:bg-amber-100 text-amber-800 border border-amber-300 px-2.5 py-1 rounded-lg transition shadow-2xs"
                                  title="Acheter des séances de conduite supplémentaires"
                                >
                                  <Car className="w-3 h-3 text-amber-600" />
                                  <span>+ Conduite</span>
                                </button>
                                <a
                                  href={`https://wa.me/228${contactClean}?text=${encodeURIComponent(msgInvitation)}`}
                                  target="_blank"
                                  rel="noreferrer"
                                  className="inline-flex items-center gap-1 text-[11px] font-semibold bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-200 px-2 py-1 rounded-lg transition"
                                  title="Envoyer code d'accès par WhatsApp"
                                >
                                  <MessageSquare className="w-3 h-3 text-emerald-600" />
                                  <span>Code</span>
                                </a>
                                <button
                                  onClick={() => generateRecuCandidatPDF(c, schoolName, c.annexe || 'Siège')}
                                  className="inline-flex items-center gap-1 text-[11px] font-semibold bg-blue-50 hover:bg-blue-100 text-blue-700 border border-blue-200 px-2 py-1 rounded-lg transition"
                                  title="Télécharger reçu d'inscription PDF"
                                >
                                  <FileText className="w-3 h-3 text-blue-600" />
                                  <span>Reçu</span>
                                </button>
                                <button
                                  onClick={() => {
                                    setEditingCandidat(c);
                                    setModalType('edit_candidat');
                                  }}
                                  className="p-1.5 text-slate-500 hover:text-blue-600 hover:bg-blue-50 border border-slate-200 rounded-lg transition"
                                  title="Modifier les données du candidat"
                                >
                                  <Pencil className="w-3.5 h-3.5" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })}
                      {filteredCandidats.length === 0 && (
                        <tr>
                          <td colSpan={7} className="text-center py-8 text-slate-400">
                            Aucun candidat trouvé pour ces critères.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>
        )}


          {/* ================= DÉPENSES ================= */}
          {activeTab === 'Dépenses' && (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex gap-3">
                  <div className="bg-white p-3.5 rounded-xl border border-slate-200">
                    <p className="text-xs font-semibold text-slate-400 uppercase">Total Dépenses</p>
                    <p className="text-xl font-bold text-rose-600 mt-0.5">{totalDepenses.toLocaleString('fr-FR')} FCFA</p>
                  </div>
                </div>
                <button
                  onClick={() => setModalType('add_depense')}
                  className="flex items-center gap-2 bg-rose-600 hover:bg-rose-700 text-white px-4 py-2 rounded-xl text-xs font-semibold shadow-xs transition"
                >
                  <Plus className="w-3.5 h-3.5" />
                  <span>Ajouter une Dépense</span>
                </button>
              </div>

              <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-50 text-slate-500 font-semibold text-xs border-b border-slate-200">
                    <tr>
                      <th className="px-5 py-3.5">Date</th>
                      <th className="px-4 py-3.5">Type</th>
                      <th className="px-4 py-3.5">Intitulé</th>
                      <th className="px-4 py-3.5">Annexe</th>
                      <th className="px-4 py-3.5 text-right">Montant</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {filteredDepenses.map((d) => (
                      <tr key={d.id} className="hover:bg-slate-50/80 transition">
                        <td className="px-5 py-3.5 text-slate-600">{d.date}</td>
                        <td className="px-4 py-3.5">
                          <span className="inline-block bg-slate-100 text-slate-700 px-2 py-0.5 rounded text-xs font-semibold">
                            {d.type}
                          </span>
                        </td>
                        <td className="px-4 py-3.5 font-medium text-slate-800">{d.intitule}</td>
                        <td className="px-4 py-3.5 text-slate-600">{d.annexe}</td>
                        <td className="px-4 py-3.5 text-right font-bold text-rose-600">
                          -{d.montant.toLocaleString('fr-FR')} F
                        </td>
                        <td className="px-4 py-3.5 text-center">
                          <div className="flex items-center justify-center gap-1.5">
                            <button
                              type="button"
                              onClick={() => {
                                setEditingDepense(d);
                                setModalType('edit_depense');
                              }}
                              className="p-1.5 text-slate-500 hover:text-blue-600 hover:bg-blue-50 border border-slate-200 rounded-lg transition cursor-pointer"
                              title="Modifier la dépense"
                            >
                              <Pencil className="w-3.5 h-3.5" />
                            </button>
                            <button
                              type="button"
                              onClick={() => handleDeleteDepense(d.id, d.intitule)}
                              className="p-1.5 text-slate-500 hover:text-rose-600 hover:bg-rose-50 border border-slate-200 rounded-lg transition cursor-pointer"
                              title="Supprimer la dépense"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ================= RECETTES ================= */}
          {activeTab === 'Recettes' && (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="bg-white p-3.5 rounded-xl border border-slate-200">
                  <p className="text-xs font-semibold text-slate-400 uppercase">Total Recettes</p>
                  <p className="text-xl font-bold text-emerald-600 mt-0.5">{totalRecettes.toLocaleString('fr-FR')} FCFA</p>
                </div>
                <button
                  onClick={() => setModalType('add_recette')}
                  className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-xl text-xs font-semibold shadow-xs transition"
                >
                  <Plus className="w-3.5 h-3.5" />
                  <span>Ajouter une Recette</span>
                </button>
              </div>

              <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-50 text-slate-500 font-semibold text-xs border-b border-slate-200">
                    <tr>
                      <th className="px-5 py-3.5">Date</th>
                      <th className="px-4 py-3.5">Intitulé</th>
                      <th className="px-4 py-3.5">Annexe</th>
                      <th className="px-4 py-3.5 text-right">Montant</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {filteredRecettes.map((r) => (
                      <tr key={r.id} className="hover:bg-slate-50/80 transition">
                        <td className="px-5 py-3.5 text-slate-600">{r.date}</td>
                        <td className="px-4 py-3.5 font-medium text-slate-800">{r.intitule}</td>
                        <td className="px-4 py-3.5 text-slate-600">{r.annexe}</td>
                        <td className="px-4 py-3.5 text-right font-bold text-emerald-600">
                          +{r.montant.toLocaleString('fr-FR')} F
                        </td>
                        <td className="px-4 py-3.5 text-center">
                          <div className="flex items-center justify-center gap-1.5">
                            <button
                              type="button"
                              onClick={() => {
                                setEditingRecette(r);
                                setModalType('edit_recette');
                              }}
                              className="p-1.5 text-slate-500 hover:text-blue-600 hover:bg-blue-50 border border-slate-200 rounded-lg transition cursor-pointer"
                              title="Modifier la recette"
                            >
                              <Pencil className="w-3.5 h-3.5" />
                            </button>
                            <button
                              type="button"
                              onClick={() => handleDeleteRecette(r.id, r.intitule)}
                              className="p-1.5 text-slate-500 hover:text-rose-600 hover:bg-rose-50 border border-slate-200 rounded-lg transition cursor-pointer"
                              title="Supprimer la recette"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ================= BILAN GLOBAL ================= */}
          {activeTab === 'Bilan Global' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-bold text-slate-800">Bilan d'Exploitation Mensuel</h3>
                  <p className="text-xs text-slate-500">Synthèse consolidée des flux financiers réels</p>
                </div>
                <button
                  onClick={() => {
                    const exportBilans = activeBilanRows.length > 0
                      ? activeBilanRows.map(b => ({ mois: b.moisLong, revenus: b.r, depenses: b.d, solde: b.r - b.d }))
                      : [{ mois: `Exercice ${currentYear}`, revenus: totalRecettes, depenses: totalDepenses, solde: totalRecettes - totalDepenses }];
                    generateBilanPDF(exportBilans, totalRecettes, totalDepenses, totalRecettes - totalDepenses);
                  }}
                  className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-xl text-xs font-semibold shadow-xs transition cursor-pointer"
                >
                  <Download className="w-3.5 h-3.5" />
                  <span>Exporter Bilan PDF</span>
                </button>
              </div>

              <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-50 text-slate-500 font-semibold text-xs border-b border-slate-200">
                    <tr>
                      <th className="px-5 py-3.5">Mois</th>
                      <th className="px-4 py-3.5">Revenus</th>
                      <th className="px-4 py-3.5">Dépenses</th>
                      <th className="px-4 py-3.5 text-right">Solde Net</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {activeBilanRows.map((row) => {
                      const net = row.r - row.d;
                      return (
                        <tr key={row.m} className="hover:bg-slate-50/80 transition">
                          <td className="px-5 py-3.5 font-bold text-slate-800">{row.moisLong}</td>
                          <td className="px-4 py-3.5 text-emerald-600 font-semibold">{row.r.toLocaleString('fr-FR')} F</td>
                          <td className="px-4 py-3.5 text-rose-600 font-semibold">{row.d.toLocaleString('fr-FR')} F</td>
                          <td className={`px-4 py-3.5 text-right font-extrabold ${net >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                            {net >= 0 ? '+' : ''}{net.toLocaleString('fr-FR')} F
                          </td>
                        </tr>
                      );
                    })}
                    {activeBilanRows.length === 0 && (
                      <tr>
                        <td colSpan={4} className="px-5 py-10 text-center text-slate-400">
                          Aucun flux financier enregistré pour le moment. Enregistrez des inscriptions, recettes ou dépenses pour générer le bilan.
                        </td>
                      </tr>
                    )}
                  </tbody>
                  <tfoot className="bg-slate-50 font-bold border-t border-slate-200">
                    <tr>
                      <td className="px-5 py-3.5 text-slate-800">TOTAL CUMULÉ</td>
                      <td className="px-4 py-3.5 text-emerald-700">{totalRecettes.toLocaleString('fr-FR')} F</td>
                      <td className="px-4 py-3.5 text-rose-700">{totalDepenses.toLocaleString('fr-FR')} F</td>
                      <td className={`px-4 py-3.5 text-right font-extrabold ${totalRecettes - totalDepenses >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                        {totalRecettes - totalDepenses >= 0 ? '+' : ''}{(totalRecettes - totalDepenses).toLocaleString('fr-FR')} FCFA
                      </td>
                    </tr>
                  </tfoot>
                </table>
              </div>
            </div>
          )}

          {/* ================= PRÉSENCE ================= */}
          {activeTab === 'Présence' && (() => {
            const effectiveAnnexe = annexeFilter !== 'Toutes' ? annexeFilter : presenceAnnexe;
            const filteredPresenceCandidats = candidats.filter((c) => {
              const matchAnnexe = effectiveAnnexe === 'Toutes' || c.annexe === effectiveAnnexe;
              const matchSearch = `${c.nom || ''} ${c.prenom || ''} ${c.contact || ''}`.toLowerCase().includes(presenceSearch.toLowerCase());
              const matchType = presenceType === 'TOUS' || (
                presenceType === 'CODE' ? c.type_formation !== 'CONDUITE_SEULE' : c.type_formation !== 'CODE_SEUL'
              );
              return matchAnnexe && matchSearch && matchType;
            });

            const getPresenceKey = (candidatId: string, date: string) => `${candidatId}_${date}`;

            const presenceTotalCount = filteredPresenceCandidats.length;
            const presencePresentsCount = filteredPresenceCandidats.filter(c => Boolean(presencesRecords[getPresenceKey(c.id, presenceDate)])).length;
            const presenceAbsentsCount = presenceTotalCount - presencePresentsCount;
            const presenceTaux = presenceTotalCount > 0 ? Math.round((presencePresentsCount / presenceTotalCount) * 100) : 0;

            const togglePresence = (c: Candidat) => {
              const key = getPresenceKey(c.id, presenceDate);
              const alreadyPointed = Boolean(presencesRecords[key]);
              const sessionDiscipline = presenceType === 'TOUS'
                ? (c.type_formation === 'CODE_SEUL' ? 'CODE' : 'CONDUITE')
                : presenceType;

              if (alreadyPointed) {
                // Annuler le pointage de cette date
                setPresencesRecords(prev => {
                  const next = { ...prev };
                  delete next[key];
                  return next;
                });
                // Si c'était une séance de Conduite, décrémenter le compteur
                if (sessionDiscipline === 'CONDUITE') {
                  setCandidats(prev => prev.map(cd => {
                    if (cd.id !== c.id) return cd;
                    const updated = { ...cd, nb_conduites_effectuees: Math.max(0, (cd.nb_conduites_effectuees || 0) - 1) };
                    syncService.syncCandidat(updated);
                    return updated;
                  }));
                }
                showToast(`Pointage du ${presenceDate} annulé pour : ${c.nom} ${c.prenom}`);
              } else {
                // Nouveau pointage pour cette date
                setPresencesRecords(prev => ({
                  ...prev,
                  [key]: { heure: presenceHeure, typeSeance: sessionDiscipline }
                }));
                // Si c'est une séance de Conduite, incrémenter le compteur
                if (sessionDiscipline === 'CONDUITE') {
                  setCandidats(prev => prev.map(cd => {
                    if (cd.id !== c.id) return cd;
                    const updated = { ...cd, nb_conduites_effectuees: (cd.nb_conduites_effectuees || 0) + 1 };
                    syncService.syncCandidat(updated);
                    return updated;
                  }));
                }
                showToast(`✓ Pointé(e) PRÉSENT(E) : ${c.nom} ${c.prenom} (${sessionDiscipline === 'CODE' ? 'Code' : 'Conduite'}) à ${presenceHeure}`);
              }
            };

            const handleMarkAll = () => {
              const toIncrement: string[] = [];
              setPresencesRecords(prev => {
                const next = { ...prev };
                filteredPresenceCandidats.forEach(c => {
                  const key = getPresenceKey(c.id, presenceDate);
                  if (!next[key]) {
                    const sessionDiscipline = presenceType === 'TOUS'
                      ? (c.type_formation === 'CODE_SEUL' ? 'CODE' : 'CONDUITE')
                      : presenceType;
                    next[key] = { heure: presenceHeure, typeSeance: sessionDiscipline };
                    if (sessionDiscipline === 'CONDUITE') toIncrement.push(c.id);
                  }
                });
                return next;
              });
              // Incrémenter les conduites uniquement pour les nouveaux pointages
              if (toIncrement.length > 0) {
                setCandidats(prev => prev.map(cd => {
                  if (!toIncrement.includes(cd.id)) return cd;
                  const updated = { ...cd, nb_conduites_effectuees: (cd.nb_conduites_effectuees || 0) + 1 };
                  syncService.syncCandidat(updated);
                  return updated;
                }));
              }
              showToast(`${filteredPresenceCandidats.length} élève(s) pointé(s) PRÉSENTS pour le ${presenceDate} à ${presenceHeure} !`);
            };

            const handleResetAll = () => {
              const toDecrement: string[] = [];
              setPresencesRecords(prev => {
                const next = { ...prev };
                filteredPresenceCandidats.forEach(c => {
                  const key = getPresenceKey(c.id, presenceDate);
                  if (next[key]) {
                    if (next[key].typeSeance === 'CONDUITE') toDecrement.push(c.id);
                    delete next[key];
                  }
                });
                return next;
              });
              if (toDecrement.length > 0) {
                setCandidats(prev => prev.map(cd => {
                  if (!toDecrement.includes(cd.id)) return cd;
                  const updated = { ...cd, nb_conduites_effectuees: Math.max(0, (cd.nb_conduites_effectuees || 0) - 1) };
                  syncService.syncCandidat(updated);
                  return updated;
                }));
              }
              showToast('Pointages de la journée réinitialisés pour la sélection');
            };

            const handleExportPDF = () => {
              const items = filteredPresenceCandidats.map(c => {
                const pdfKey = getPresenceKey(c.id, presenceDate);
                const rec = presencesRecords[pdfKey];
                const disc = rec?.typeSeance || (presenceType === 'TOUS' ? (c.type_formation === 'CODE_SEUL' ? 'CODE' : 'CONDUITE') : presenceType);
                return {
                  nom: c.nom,
                  prenom: c.prenom,
                  contact: c.contact,
                  annexe: c.annexe,
                  categorie: c.categorie,
                  discipline: disc === 'CODE' ? 'Cours de Code' : 'Conduite Pratique',
                  present: Boolean(rec),
                  heurePointage: rec ? rec.heure : undefined,
                };
              });
              generatePresencePDF(
                items,
                presenceDate,
                presenceHeure,
                presenceType === 'TOUS' ? 'Code & Conduite' : presenceType === 'CODE' ? 'Cours de Code' : 'Conduite Pratique',
                effectiveAnnexe,
                schoolName
              );
            };

            return (
              <div className="space-y-4">
                {/* En-tête de section avec titre et bouton Export PDF */}
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div>
                    <h3 className="text-xl font-bold text-slate-900 flex items-center gap-2">
                      <UserCheck className="w-5 h-5 text-emerald-600" />
                      <span>Liste de Présence & Émargement des Élèves</span>
                    </h3>
                    <p className="text-xs text-slate-500 mt-0.5">
                      Pointage direct en un clic aux cours de code et séances de conduite.
                    </p>
                  </div>
                  <button
                    onClick={handleExportPDF}
                    className="flex items-center gap-2 bg-slate-900 hover:bg-slate-800 text-white px-4 py-2 rounded-xl text-xs font-semibold shadow-xs transition shrink-0 cursor-pointer"
                  >
                    <Download className="w-3.5 h-3.5" />
                    <span>Exporter Feuille d'Émargement (PDF)</span>
                  </button>
                </div>

                {/* 1. BARRE DE CONTRÔLE UNIFIÉE & COMPACTE */}
                <div className="bg-white p-4 rounded-2xl border border-slate-200/90 shadow-xs space-y-3">
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    {/* Date, Heure & Raccourcis */}
                    <div className="flex flex-wrap items-center gap-2">
                      {/* Sélecteur de Date */}
                      <div className="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-xl px-3 py-1.5 focus-within:ring-2 focus-within:ring-blue-500 transition">
                        <Calendar className="w-3.5 h-3.5 text-blue-600 shrink-0" />
                        <input
                          type="date"
                          value={presenceDate}
                          onChange={(e) => setPresenceDate(e.target.value)}
                          className="bg-transparent text-xs font-bold text-slate-800 focus:outline-none cursor-pointer"
                        />
                      </div>

                      {/* Sélecteur d'Heure */}
                      <div className="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-xl px-3 py-1.5 focus-within:ring-2 focus-within:ring-emerald-500 transition">
                        <Clock className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
                        <input
                          type="time"
                          value={presenceHeure}
                          onChange={(e) => setPresenceHeure(e.target.value)}
                          className="bg-transparent text-xs font-bold text-slate-800 focus:outline-none cursor-pointer"
                        />
                        <button
                          type="button"
                          onClick={() => {
                            const d = new Date();
                            setPresenceHeure(`${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`);
                          }}
                          title="Régler à l'heure courante"
                          className="text-[10px] bg-white border border-slate-200 hover:bg-emerald-50 hover:text-emerald-700 text-slate-600 font-semibold px-2 py-0.5 rounded transition cursor-pointer"
                        >
                          Maintenant
                        </button>
                      </div>

                      {/* Créneaux usuels rapides */}
                      <div className="hidden lg:flex items-center gap-1 text-[11px] bg-slate-100 p-1 rounded-xl">
                        {['08:00', '10:00', '15:00', '17:00'].map((cr) => (
                          <button
                            key={cr}
                            type="button"
                            onClick={() => setPresenceHeure(cr)}
                            className={`px-2 py-0.5 rounded-lg font-medium transition cursor-pointer ${
                              presenceHeure === cr
                                ? 'bg-white text-blue-700 font-bold shadow-2xs'
                                : 'text-slate-600 hover:text-slate-900'
                            }`}
                          >
                            {cr}
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Barre de recherche instantanée */}
                    <div className="relative min-w-[220px] max-w-sm flex-1">
                      <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                      <input
                        type="text"
                        placeholder="Rechercher élève par nom, prénom ou contact..."
                        value={presenceSearch}
                        onChange={(e) => setPresenceSearch(e.target.value)}
                        className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-9 pr-7 py-1.5 text-xs text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
                      />
                      {presenceSearch && (
                        <button
                          type="button"
                          onClick={() => setPresenceSearch('')}
                          className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 text-xs font-bold cursor-pointer"
                        >
                          ✕
                        </button>
                      )}
                    </div>
                  </div>

                  {/* Ligne 2 : Filtres de Discipline & Annexe */}
                  <div className="flex flex-wrap items-center justify-between gap-3 pt-2.5 border-t border-slate-100">
                    <div className="flex items-center gap-1.5 p-1 bg-slate-100 rounded-xl">
                      <button
                        type="button"
                        onClick={() => setPresenceType('TOUS')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                          presenceType === 'TOUS' ? 'bg-white text-slate-900 shadow-2xs' : 'text-slate-600 hover:text-slate-900'
                        }`}
                      >
                        Tous les Élèves ({presenceTotalCount})
                      </button>
                      <button
                        type="button"
                        onClick={() => setPresenceType('CODE')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition cursor-pointer ${
                          presenceType === 'CODE' ? 'bg-purple-600 text-white shadow-2xs' : 'text-purple-700 hover:bg-purple-50'
                        }`}
                      >
                        <BookOpen className="w-3.5 h-3.5" />
                        <span>Cours de Code</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => setPresenceType('CONDUITE')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition cursor-pointer ${
                          presenceType === 'CONDUITE' ? 'bg-blue-600 text-white shadow-2xs' : 'text-blue-700 hover:bg-blue-50'
                        }`}
                      >
                        <Car className="w-3.5 h-3.5" />
                        <span>Séances de Conduite</span>
                      </button>
                    </div>

                    {/* Filtre Annexe si "Toutes" sélectionné au niveau global */}
                    {annexeFilter === 'Toutes' && (
                      <div className="flex items-center gap-2">
                        <span className="text-[11px] font-semibold text-slate-500">Annexe :</span>
                        <select
                          value={presenceAnnexe}
                          onChange={(e) => setPresenceAnnexe(e.target.value)}
                          className="bg-slate-50 border border-slate-200 rounded-xl px-3 py-1.5 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
                        >
                          <option value="Toutes">Toutes les agences</option>
                          {annexesList.map((a) => (
                            <option key={a} value={a}>{a}</option>
                          ))}
                        </select>
                      </div>
                    )}
                  </div>
                </div>

                {/* 2. BARRE DE SYNTHÈSE FLUIDE (Compacte & Visuelle) */}
                <div className="bg-gradient-to-r from-slate-50 via-white to-slate-50 border border-slate-200/90 p-3 sm:px-5 rounded-2xl flex flex-wrap items-center justify-between gap-3 shadow-xs">
                  <div className="flex flex-wrap items-center gap-4 sm:gap-6 text-xs">
                    {/* Total Élèves */}
                    <div className="flex items-center gap-1.5">
                      <span className="text-slate-500 font-medium">Élèves concernés :</span>
                      <span className="font-extrabold text-slate-900 bg-slate-200/80 px-2 py-0.5 rounded-md">
                        {presenceTotalCount}
                      </span>
                    </div>

                    {/* Pointés Présents */}
                    <div className="flex items-center gap-1.5">
                      <span className="text-emerald-700 font-medium flex items-center gap-1.5">
                        <span className="w-2 h-2 rounded-full bg-emerald-500 inline-block"></span>
                        Pointés Présents :
                      </span>
                      <span className="font-extrabold text-emerald-800 bg-emerald-100 border border-emerald-200 px-2 py-0.5 rounded-md">
                        {presencePresentsCount}
                      </span>
                    </div>

                    {/* Absents */}
                    <div className="flex items-center gap-1.5">
                      <span className="text-amber-700 font-medium flex items-center gap-1.5">
                        <span className="w-2 h-2 rounded-full bg-amber-400 inline-block"></span>
                        Absents :
                      </span>
                      <span className="font-extrabold text-amber-800 bg-amber-100 border border-amber-200 px-2 py-0.5 rounded-md">
                        {presenceAbsentsCount}
                      </span>
                    </div>

                    {/* Taux de présence avec jauge fine */}
                    <div className="flex items-center gap-2 pl-2 sm:border-l border-slate-200">
                      <span className="text-slate-500 font-medium">Taux :</span>
                      <span className="font-extrabold text-blue-700">{presenceTaux}%</span>
                      <div className="w-20 sm:w-28 h-2 bg-slate-200 rounded-full overflow-hidden">
                        <div
                          className={`h-full transition-all duration-300 ${
                            presenceTaux >= 80 ? 'bg-emerald-500' : presenceTaux >= 50 ? 'bg-blue-500' : 'bg-amber-500'
                          }`}
                          style={{ width: `${presenceTaux}%` }}
                        />
                      </div>
                    </div>
                  </div>

                  {/* Actions collectives */}
                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={handleMarkAll}
                      className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold transition shadow-xs cursor-pointer"
                    >
                      <CheckCheck className="w-3.5 h-3.5" />
                      <span>Tout pointer présent</span>
                    </button>
                    <button
                      type="button"
                      onClick={handleResetAll}
                      className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-semibold transition cursor-pointer"
                    >
                      <RotateCcw className="w-3.5 h-3.5 text-slate-500" />
                      <span>Réinitialiser</span>
                    </button>
                  </div>
                </div>

                {/* 3. TABLEAU D'ÉMARGEMENT ÉPURÉ & MODERNE (5 Colonnes) */}
                <div className="bg-white rounded-2xl border border-slate-200/90 shadow-xs overflow-hidden">
                  <div className="px-5 py-3.5 bg-slate-50/80 border-b border-slate-200 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-xs text-slate-800 uppercase tracking-wider">
                        Feuille d'Émargement – {new Date(presenceDate + 'T12:00:00').toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
                      </span>
                      <span className="text-xs bg-blue-100 text-blue-800 font-bold px-2.5 py-0.5 rounded-full">
                        Créneau de {presenceHeure}
                      </span>
                    </div>
                    <span className="text-xs text-slate-500 font-medium hidden sm:inline">
                      Cliquez directement pour pointer la présence
                    </span>
                  </div>

                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="bg-slate-50/60 text-slate-500 font-semibold text-[11px] border-b border-slate-200 uppercase tracking-wider">
                        <tr>
                          <th className="px-4 py-3.5 w-48">Pointage Direct</th>
                          <th className="px-4 py-3.5">Élève & Contact</th>
                          <th className="px-4 py-3.5">Séance & Annexe</th>
                          <th className="px-4 py-3.5">Progression</th>
                          <th className="px-4 py-3.5 text-right">Action</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {filteredPresenceCandidats.map((c) => {
                          const presKey = getPresenceKey(c.id, presenceDate);
                          const record = presencesRecords[presKey];
                          const isPresent = Boolean(record);
                          const initiales = `${(c.nom || 'C').slice(0, 1)}${(c.prenom || 'P').slice(0, 1)}`.toUpperCase();
                          const sessionDiscipline = record?.typeSeance || (
                            presenceType === 'TOUS' ? (c.type_formation === 'CODE_SEUL' ? 'CODE' : 'CONDUITE') : presenceType
                          );
                          const pct = (c.nb_conduites_prevues || 0) > 0
                            ? Math.round(((c.nb_conduites_effectuees || 0) / (c.nb_conduites_prevues || 1)) * 100)
                            : 0;

                          const msgConfirmation = isPresent
                            ? `Bonjour ${c.prenom} ! L'Auto-École Saint Edmond confirme votre présence au ${sessionDiscipline === 'CODE' ? 'cours de Code' : 'cours de Conduite'} du ${presenceDate} a ${record?.heure || presenceHeure}. Bonne formation !`
                            : `Bonjour ${c.prenom} ! Vous avez été marqué(e) absent(e) au cours de ${sessionDiscipline === 'CODE' ? 'Code' : 'Conduite'} du ${presenceDate} à ${presenceHeure} à l'Auto-École Saint Edmond. Merci de contacter le secrétariat si nécessaire.`;

                          return (
                            <tr
                              key={c.id}
                              className={`transition-colors ${
                                isPresent ? 'bg-emerald-50/30 hover:bg-emerald-50/60' : 'hover:bg-slate-50/80'
                              }`}
                            >
                              {/* Colonne 1 : Pointage Direct 1-Clic */}
                              <td className="px-4 py-3.5 whitespace-nowrap">
                                <button
                                  type="button"
                                  onClick={() => togglePresence(c)}
                                  className={`w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl text-xs font-bold transition-all border cursor-pointer ${
                                    isPresent
                                      ? 'bg-emerald-600 hover:bg-emerald-700 text-white border-emerald-600 shadow-xs'
                                      : 'bg-white hover:bg-emerald-50 text-slate-700 hover:text-emerald-700 border-slate-200 hover:border-emerald-300'
                                  }`}
                                  title={isPresent ? 'Cliquer pour marquer absent' : 'Cliquer pour valider la présence maintenant'}
                                >
                                  {isPresent ? (
                                    <>
                                      <Check className="w-4 h-4 stroke-[3]" />
                                      <span>Présent(e) à {record?.heure || presenceHeure}</span>
                                    </>
                                  ) : (
                                    <>
                                      <div className="w-3.5 h-3.5 rounded-full border-2 border-slate-300" />
                                      <span>Pointer Présent</span>
                                    </>
                                  )}
                                </button>
                              </td>

                              {/* Colonne 2 : Élève, Contact & Permis */}
                              <td className="px-4 py-3.5 whitespace-nowrap">
                                <div className="flex items-center gap-3">
                                  <div className={`w-9 h-9 rounded-full font-bold text-xs flex items-center justify-center border uppercase shrink-0 ${
                                    isPresent ? 'bg-emerald-100 text-emerald-800 border-emerald-300' : 'bg-slate-100 text-slate-700 border-slate-200'
                                  }`}>
                                    {initiales}
                                  </div>
                                  <div>
                                    <div className="flex items-center gap-2">
                                      <span className="font-bold text-slate-900 text-xs">
                                        {c.nom} {c.prenom}
                                      </span>
                                      <span className="text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200 px-1.5 py-0.2 rounded">
                                        Permis {c.categorie || 'B'}
                                      </span>
                                    </div>
                                    <span className="text-[11px] text-slate-500 font-medium block mt-0.5">
                                      {c.contact ? (
                                        <a href={`tel:${c.contact}`} className="hover:text-blue-600 hover:underline">
                                          {c.contact}
                                        </a>
                                      ) : (
                                        '—'
                                      )}
                                    </span>
                                  </div>
                                </div>
                              </td>

                              {/* Colonne 3 : Séance & Annexe */}
                              <td className="px-4 py-3.5 whitespace-nowrap">
                                {sessionDiscipline === 'CODE' ? (
                                  <span className="inline-flex items-center gap-1 text-[11px] font-bold bg-purple-50 text-purple-700 border border-purple-200 px-2 py-0.5 rounded-lg">
                                    <BookOpen className="w-3 h-3" />
                                    <span>Cours de Code</span>
                                  </span>
                                ) : (
                                  <span className="inline-flex items-center gap-1 text-[11px] font-bold bg-blue-50 text-blue-700 border border-blue-200 px-2 py-0.5 rounded-lg">
                                    <Car className="w-3 h-3" />
                                    <span>Conduite Pratique</span>
                                  </span>
                                )}
                                <span className="text-[11px] text-slate-500 font-medium block mt-1">
                                  {c.annexe?.replace('Tokoin Ramco (Siège)', 'Tokoin Ramco').replace('Formation à Domicile', 'À Domicile')}
                                </span>
                              </td>

                              {/* Colonne 4 : Progression */}
                              <td className="px-4 py-3.5 whitespace-nowrap">
                                {sessionDiscipline === 'CODE' ? (
                                  <div className="space-y-1">
                                    <span className={`inline-flex items-center text-[10px] font-bold px-2 py-0.5 rounded-full ${
                                      c.statut_examen_code === 'ADMIS'
                                        ? 'bg-emerald-100 text-emerald-800'
                                        : 'bg-slate-100 text-slate-600'
                                    }`}>
                                      {c.statut_examen_code === 'ADMIS' ? 'Code validé' : 'Code en cours'}
                                    </span>
                                  </div>
                                ) : (
                                  <div>
                                    <div className="flex items-center gap-2">
                                      <div className="w-20 h-1.5 bg-slate-100 rounded-full overflow-hidden border border-slate-200/50">
                                        <div
                                          className={`h-full rounded-full transition-all ${pct >= 100 ? 'bg-emerald-500' : 'bg-blue-500'}`}
                                          style={{ width: `${Math.min(pct, 100)}%` }}
                                        />
                                      </div>
                                      <span className="text-[11px] font-bold text-slate-700">
                                        {c.nb_conduites_effectuees || 0}/{c.nb_conduites_prevues || 20}
                                      </span>
                                    </div>
                                    <span className="text-[10px] text-slate-400 font-medium block mt-0.5">
                                      séances effectuées
                                    </span>
                                  </div>
                                )}
                              </td>

                              {/* Colonne 5 : Action WhatsApp */}
                              <td className="px-4 py-3.5 text-right whitespace-nowrap">
                                <a
                                  href={`https://wa.me/228${(c.contact || '').replace(/\s+/g, '')}?text=${encodeURIComponent(msgConfirmation)}`}
                                  target="_blank"
                                  rel="noreferrer"
                                  className={`inline-flex items-center gap-1.5 text-xs font-semibold px-2.5 py-1.5 rounded-xl border transition shadow-2xs cursor-pointer ${
                                    isPresent
                                      ? 'bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border-emerald-200'
                                      : 'bg-slate-50 hover:bg-slate-100 text-slate-700 border-slate-200'
                                  }`}
                                  title="Envoyer confirmation par WhatsApp"
                                >
                                  <MessageSquare className="w-3.5 h-3.5 text-emerald-600" />
                                  <span>WhatsApp</span>
                                </a>
                              </td>
                            </tr>
                          );
                        })}

                        {filteredPresenceCandidats.length === 0 && (
                          <tr>
                            <td colSpan={5} className="text-center py-10 text-slate-400 text-xs">
                              Aucun élève trouvé pour cette sélection.
                            </td>
                          </tr>
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            );
          })()}

          {/* ================= RÉSULTATS ================= */}
          {activeTab === 'Résultats' && (() => {
            const effectiveAnnexe = annexeFilter !== 'Toutes' ? annexeFilter : 'Toutes';

            // Filtrage des candidats selon épreuve, statut, annexe et recherche
            const filteredResultats = candidats.filter(c => {
              const matchAnnexe = effectiveAnnexe === 'Toutes' || c.annexe === effectiveAnnexe;
              const matchSearch = `${c.nom || ''} ${c.prenom || ''} ${c.contact || ''}`.toLowerCase().includes(resultatSearch.toLowerCase());

              // Filtre selon l'épreuve active
              if (resultatEpreuve === 'CODE' && c.type_formation === 'CONDUITE_SEULE') return false;
              if (resultatEpreuve === 'CONDUITE' && c.type_formation === 'CODE_SEUL') return false;

              // Statut d'examen de référence selon l'épreuve choisie
              let refStatut: 'NON_PROGRAMME' | 'PROGRAMME' | 'ADMIS' | 'AJOURNE' = 'NON_PROGRAMME';
              if (resultatEpreuve === 'CODE') {
                refStatut = c.statut_examen_code || 'NON_PROGRAMME';
              } else if (resultatEpreuve === 'CONDUITE') {
                refStatut = c.statut_examen_conduite || 'NON_PROGRAMME';
              } else {
                // TOUS : Admis si les deux épreuves requises sont ADMIS, Ajourné si l'une est AJOURNE, etc.
                if (c.statut === 'ADMIS' || (c.statut_examen_code === 'ADMIS' && c.statut_examen_conduite === 'ADMIS')) {
                  refStatut = 'ADMIS';
                } else if (c.statut_examen_code === 'AJOURNE' || c.statut_examen_conduite === 'AJOURNE' || c.statut === 'NON_ADMIS') {
                  refStatut = 'AJOURNE';
                } else if (c.statut_examen_code === 'PROGRAMME' || c.statut_examen_conduite === 'PROGRAMME') {
                  refStatut = 'PROGRAMME';
                } else {
                  refStatut = 'NON_PROGRAMME';
                }
              }

              const matchStatut = resultatStatutFilter === 'TOUS' || refStatut === resultatStatutFilter;

              return matchAnnexe && matchSearch && matchStatut;
            });

            // Statistiques pour les compteurs
            const countAdmis = candidats.filter(c => {
              if (resultatEpreuve === 'CODE') return c.statut_examen_code === 'ADMIS';
              if (resultatEpreuve === 'CONDUITE') return c.statut_examen_conduite === 'ADMIS';
              return c.statut === 'ADMIS' || (c.statut_examen_code === 'ADMIS' && c.statut_examen_conduite === 'ADMIS');
            }).length;

            const countAjournes = candidats.filter(c => {
              if (resultatEpreuve === 'CODE') return c.statut_examen_code === 'AJOURNE';
              if (resultatEpreuve === 'CONDUITE') return c.statut_examen_conduite === 'AJOURNE';
              return c.statut_examen_code === 'AJOURNE' || c.statut_examen_conduite === 'AJOURNE' || c.statut === 'NON_ADMIS';
            }).length;

            const countProgrammes = candidats.filter(c => {
              if (resultatEpreuve === 'CODE') return c.statut_examen_code === 'PROGRAMME';
              if (resultatEpreuve === 'CONDUITE') return c.statut_examen_conduite === 'PROGRAMME';
              return (c.statut_examen_code === 'PROGRAMME' || c.statut_examen_conduite === 'PROGRAMME') && c.statut !== 'ADMIS' && c.statut !== 'NON_ADMIS';
            }).length;

            const countEnCours = candidats.length - countAdmis - countAjournes - countProgrammes;

            return (
              <div className="space-y-4">
                {/* 1. EN-TÊTE DE SECTION */}
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div>
                    <h3 className="text-xl font-bold text-slate-900 flex items-center gap-2">
                      <Award className="w-5 h-5 text-amber-500" />
                      <span>Résultats d'Examen Permis</span>
                    </h3>
                    <div className="flex items-center gap-2 mt-0.5">
                      <span className="text-xs text-slate-500">Session active :</span>
                      <input
                        type="text"
                        value={sessionExamNom}
                        onChange={(e) => setSessionExamNom(e.target.value)}
                        className="bg-transparent border-b border-dashed border-slate-300 text-xs font-semibold text-slate-800 focus:outline-none focus:border-blue-500 px-1 py-0.5"
                        placeholder="Ex: Session Novembre 2026 - Lomé"
                      />
                    </div>
                  </div>
                  <button
                    onClick={() => {
                      setModalData({ statut: 'ADMIS' });
                      setModalType('broadcast_msg');
                    }}
                    className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-xl text-xs font-semibold shadow-xs transition shrink-0 cursor-pointer"
                  >
                    <Send className="w-3.5 h-3.5" />
                    <span>Diffuser Résultats (SMS/WhatsApp)</span>
                  </button>
                </div>

                {/* 2. BARRE DE FILTRES : ONGLETS DEMANDÉS + STATUT + RECHERCHE */}
                <div className="bg-white p-4 rounded-2xl border border-slate-200/90 shadow-xs space-y-3">
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    {/* ONGLETS EXACTS DEMANDÉS : Tous | Code de la Route | Conduite */}
                    <div className="flex items-center gap-1.5 p-1 bg-slate-100 rounded-xl">
                      <button
                        type="button"
                        onClick={() => setResultatEpreuve('TOUS')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                          resultatEpreuve === 'TOUS' ? 'bg-white text-slate-900 shadow-2xs' : 'text-slate-600 hover:text-slate-900'
                        }`}
                      >
                        Tous
                      </button>
                      <button
                        type="button"
                        onClick={() => setResultatEpreuve('CODE')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition cursor-pointer ${
                          resultatEpreuve === 'CODE' ? 'bg-purple-600 text-white shadow-2xs' : 'text-purple-700 hover:bg-purple-50'
                        }`}
                      >
                        <BookOpen className="w-3.5 h-3.5" />
                        <span>Code de la Route</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => setResultatEpreuve('CONDUITE')}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition cursor-pointer ${
                          resultatEpreuve === 'CONDUITE' ? 'bg-blue-600 text-white shadow-2xs' : 'text-blue-700 hover:bg-blue-50'
                        }`}
                      >
                        <Car className="w-3.5 h-3.5" />
                        <span>Conduite</span>
                      </button>
                    </div>

                    {/* Recherche Candidat */}
                    <div className="relative min-w-[200px] max-w-xs flex-1">
                      <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                      <input
                        type="text"
                        placeholder="Rechercher candidat par nom..."
                        value={resultatSearch}
                        onChange={(e) => setResultatSearch(e.target.value)}
                        className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-8 pr-3 py-1.5 text-xs text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
                      />
                      {resultatSearch && (
                        <button
                          type="button"
                          onClick={() => setResultatSearch('')}
                          className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 text-xs font-bold"
                        >
                          ✕
                        </button>
                      )}
                    </div>
                  </div>

                  {/* Ligne Filtre Statut */}
                  <div className="flex flex-wrap items-center gap-2 pt-2.5 border-t border-slate-100 text-xs">
                    <span className="text-slate-500 font-semibold mr-1">Filtrer par statut :</span>
                    {[
                      { id: 'TOUS', label: 'Tous les candidats' },
                      { id: 'ADMIS', label: 'Admis uniquement' },
                      { id: 'AJOURNE', label: 'Ajournés uniquement' },
                      { id: 'PROGRAMME', label: 'Programmés pour examen' },
                      { id: 'NON_PROGRAMME', label: 'En cours de formation' },
                    ].map(f => (
                      <button
                        key={f.id}
                        type="button"
                        onClick={() => setResultatStatutFilter(f.id as any)}
                        className={`px-2.5 py-1 rounded-lg font-medium transition cursor-pointer ${
                          resultatStatutFilter === f.id
                            ? 'bg-slate-900 text-white font-bold'
                            : 'bg-slate-100 hover:bg-slate-200 text-slate-600'
                        }`}
                      >
                        {f.label}
                      </button>
                    ))}
                  </div>
                </div>

                {/* 3. SYNTHÈSE DES RÉSULTATS */}
                <div className="bg-gradient-to-r from-slate-50 via-white to-slate-50 border border-slate-200/90 p-3 sm:px-5 rounded-2xl flex flex-wrap items-center justify-between gap-3 shadow-xs text-xs">
                  <div className="flex flex-wrap items-center gap-4 sm:gap-6">
                    <div className="flex items-center gap-1.5">
                      <span className="text-slate-500 font-medium">Total candidats :</span>
                      <span className="font-extrabold text-slate-900 bg-slate-200/80 px-2 py-0.5 rounded-md">
                        {candidats.length}
                      </span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <span className="text-emerald-700 font-medium flex items-center gap-1.5">
                        <span className="w-2 h-2 rounded-full bg-emerald-500 inline-block"></span>
                        Admis :
                      </span>
                      <span className="font-extrabold text-emerald-800 bg-emerald-100 border border-emerald-200 px-2 py-0.5 rounded-md">
                        {countAdmis}
                      </span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <span className="text-rose-700 font-medium flex items-center gap-1.5">
                        <span className="w-2 h-2 rounded-full bg-rose-500 inline-block"></span>
                        Ajournés :
                      </span>
                      <span className="font-extrabold text-rose-800 bg-rose-100 border border-rose-200 px-2 py-0.5 rounded-md">
                        {countAjournes}
                      </span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <span className="text-blue-700 font-medium flex items-center gap-1.5">
                        <span className="w-2 h-2 rounded-full bg-blue-500 inline-block"></span>
                        Programmés :
                      </span>
                      <span className="font-extrabold text-blue-800 bg-blue-100 border border-blue-200 px-2 py-0.5 rounded-md">
                        {countProgrammes}
                      </span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <span className="text-slate-600 font-medium flex items-center gap-1.5">
                        <span className="w-2 h-2 rounded-full bg-slate-400 inline-block"></span>
                        En formation :
                      </span>
                      <span className="font-bold text-slate-700 bg-slate-100 px-2 py-0.5 rounded-md">
                        {Math.max(0, countEnCours)}
                      </span>
                    </div>
                  </div>
                </div>

                {/* 4. TABLEAU DES RÉSULTATS D'EXAMEN */}
                <div className="bg-white rounded-2xl border border-slate-200/90 shadow-xs overflow-hidden">
                  <div className="px-5 py-3.5 bg-slate-50/80 border-b border-slate-200 flex items-center justify-between">
                    <span className="font-bold text-xs text-slate-800 uppercase tracking-wider">
                      Procès-Verbal des Résultats - {sessionExamNom}
                    </span>
                    <span className="text-xs text-slate-500 font-medium hidden sm:inline">
                      Modifiez le statut d'un élève directement en 1 clic
                    </span>
                  </div>

                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="bg-slate-50/60 text-slate-500 font-semibold text-[11px] border-b border-slate-200 uppercase tracking-wider">
                        <tr>
                          <th className="px-4 py-3.5">Candidat & Contact</th>
                          <th className="px-4 py-3.5">Permis & Formation</th>
                          {(resultatEpreuve === 'TOUS' || resultatEpreuve === 'CODE') && (
                            <th className="px-4 py-3.5">Code de la Route</th>
                          )}
                          {(resultatEpreuve === 'TOUS' || resultatEpreuve === 'CONDUITE') && (
                            <th className="px-4 py-3.5">Conduite</th>
                          )}
                          <th className="px-4 py-3.5 text-center">Résultat Global</th>
                          <th className="px-4 py-3.5 text-right">Action</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {filteredResultats.map((c) => {
                          const initiales = `${(c.nom || 'C').slice(0, 1)}${(c.prenom || 'P').slice(0, 1)}`.toUpperCase();

                          const isAdmisCode = c.statut_examen_code === 'ADMIS';
                          const isAdmisConduite = c.statut_examen_conduite === 'ADMIS';
                          const isAjourneCode = c.statut_examen_code === 'AJOURNE';
                          const isAjourneConduite = c.statut_examen_conduite === 'AJOURNE';
                          const isProgrammeCode = c.statut_examen_code === 'PROGRAMME';
                          const isProgrammeConduite = c.statut_examen_conduite === 'PROGRAMME';

                          // Formateur date simple JJ/MM/AAAA
                          const formatDateSimple = (dStr?: string) => {
                            if (!dStr) return '';
                            const parts = dStr.split('-');
                            if (parts.length === 3) return `${parts[2]}/${parts[1]}/${parts[0]}`;
                            return dStr;
                          };

                          // Date d'examen programmée prioritaire (conduite ou code)
                          const dateProgrammeeRaw = c.date_examen_conduite || c.date_examen_code;
                          const dateProgrammeeFormattee = formatDateSimple(dateProgrammeeRaw);

                          // Calcul du résultat global :
                          // 1. Si Admis -> Badge vert "Admis ✓"
                          // 2. Si Ajourné -> Badge rouge "Ajourné ✗"
                          // 3. Si Programmé -> Affiche la date programmée
                          // 4. Si En formation -> Totalement VIDE (tiret discret)
                          let affichageGlobal: { type: 'admis' | 'ajourne' | 'programme' | 'vide'; text: string } = {
                            type: 'vide',
                            text: '—'
                          };

                          if (c.statut === 'ADMIS' || (isAdmisCode && isAdmisConduite) || (c.type_formation === 'CODE_SEUL' && isAdmisCode) || (c.type_formation === 'CONDUITE_SEULE' && isAdmisConduite)) {
                            affichageGlobal = { type: 'admis', text: 'Admis ✓' };
                          } else if (isAjourneCode || isAjourneConduite || c.statut === 'NON_ADMIS') {
                            affichageGlobal = { type: 'ajourne', text: 'Ajourné ✗' };
                          } else if (isProgrammeCode || isProgrammeConduite) {
                            affichageGlobal = {
                              type: 'programme',
                              text: dateProgrammeeFormattee ? `Prévu le ${dateProgrammeeFormattee}` : 'Programmé'
                            };
                          } else {
                            // En formation : reste vide !
                            affichageGlobal = { type: 'vide', text: '—' };
                          }

                          // Message WhatsApp pré-rempli
                          const msgResultat = affichageGlobal.type === 'admis'
                            ? `Félicitations ${c.prenom} ! L'Auto-École SAINT EDMOND vous informe que vous avez réussi votre examen du Permis ${c.categorie || 'B'}. Présentez-vous au secrétariat pour les formalités.`
                            : affichageGlobal.type === 'ajourne'
                            ? `Bonjour ${c.prenom}, l'Auto-École SAINT EDMOND vous informe que votre examen n'a pas été validé. Contactez le secrétariat pour vous inscrire à la prochaine session de rattrapage.`
                            : affichageGlobal.type === 'programme'
                            ? `Bonjour ${c.prenom}, l'Auto-École SAINT EDMOND vous informe que vous êtes convoqué(e) à l'examen du Permis ${c.categorie || 'B'}${dateProgrammeeFormattee ? ` le ${dateProgrammeeFormattee}` : ''}. Merci de contacter le secrétariat.`
                            : `Bonjour ${c.prenom}, point sur votre formation Permis ${c.categorie || 'B'} à l'Auto-École SAINT EDMOND. N'hésitez pas à contacter le secrétariat.`;

                          return (
                            <tr key={c.id} className="hover:bg-slate-50/80 transition-colors">
                              {/* Colonne 1 : Candidat & Contact */}
                              <td className="px-4 py-3.5 whitespace-nowrap">
                                <div className="flex items-center gap-3">
                                  <div className="w-9 h-9 rounded-full bg-slate-100 text-slate-700 border border-slate-200 font-bold text-xs flex items-center justify-center uppercase shrink-0">
                                    {initiales}
                                  </div>
                                  <div>
                                    <span className="font-bold text-slate-900 text-xs block">
                                      {c.nom} {c.prenom}
                                    </span>
                                    <span className="text-[11px] text-slate-500 font-medium block mt-0.5">
                                      {c.contact ? (
                                        <a href={`tel:${c.contact}`} className="hover:text-blue-600 hover:underline">
                                          {c.contact}
                                        </a>
                                      ) : '—'}
                                    </span>
                                  </div>
                                </div>
                              </td>

                              {/* Colonne 2 : Permis & Formation */}
                              <td className="px-4 py-3.5 whitespace-nowrap">
                                <span className="inline-block text-[11px] font-bold bg-blue-50 text-blue-700 border border-blue-200 px-2 py-0.5 rounded-lg">
                                  Permis {c.categorie || 'B'}
                                </span>
                                <span className="text-[11px] text-slate-500 font-medium block mt-1">
                                  {c.type_formation === 'RECYCLAGE' ? 'Recyclage' : c.type_formation === 'CONDUITE_SEULE' ? 'Conduite Uniquement' : 'Formation Complète'}
                                </span>
                              </td>

                              {/* Colonne 3 : Épreuve Code de la Route (Affichage lecture seule) */}
                              {(resultatEpreuve === 'TOUS' || resultatEpreuve === 'CODE') && (
                                <td className="px-4 py-3.5 whitespace-nowrap">
                                  {c.type_formation === 'CONDUITE_SEULE' ? (
                                    <span className="text-[11px] text-slate-400 font-medium italic">Non concerné</span>
                                  ) : isAdmisCode ? (
                                    <span className="inline-flex items-center gap-1 text-xs font-bold text-emerald-800 bg-emerald-50 border border-emerald-300 px-2.5 py-1 rounded-lg">
                                      Admis ✓
                                    </span>
                                  ) : isAjourneCode ? (
                                    <span className="inline-flex items-center gap-1 text-xs font-bold text-rose-800 bg-rose-50 border border-rose-300 px-2.5 py-1 rounded-lg">
                                      Ajourné ✗
                                    </span>
                                  ) : isProgrammeCode ? (
                                    <div className="space-y-0.5">
                                      <span className="inline-flex items-center gap-1 text-xs font-bold text-blue-800 bg-blue-50 border border-blue-300 px-2.5 py-1 rounded-lg">
                                        Programmé
                                      </span>
                                      {c.date_examen_code && (
                                        <span className="block text-[10px] text-blue-600 font-medium">
                                          le {formatDateSimple(c.date_examen_code)}
                                        </span>
                                      )}
                                    </div>
                                  ) : (
                                    <span className="text-xs text-slate-400 font-medium">—</span>
                                  )}
                                </td>
                              )}

                              {/* Colonne 4 : Épreuve Conduite (Affichage lecture seule) */}
                              {(resultatEpreuve === 'TOUS' || resultatEpreuve === 'CONDUITE') && (
                                <td className="px-4 py-3.5 whitespace-nowrap">
                                  {c.type_formation === 'CODE_SEUL' ? (
                                    <span className="text-[11px] text-slate-400 font-medium italic">Non concerné</span>
                                  ) : isAdmisConduite ? (
                                    <span className="inline-flex items-center gap-1 text-xs font-bold text-emerald-800 bg-emerald-50 border border-emerald-300 px-2.5 py-1 rounded-lg">
                                      Admis ✓
                                    </span>
                                  ) : isAjourneConduite ? (
                                    <span className="inline-flex items-center gap-1 text-xs font-bold text-rose-800 bg-rose-50 border border-rose-300 px-2.5 py-1 rounded-lg">
                                      Ajourné ✗
                                    </span>
                                  ) : isProgrammeConduite ? (
                                    <div className="space-y-0.5">
                                      <span className="inline-flex items-center gap-1 text-xs font-bold text-blue-800 bg-blue-50 border border-blue-300 px-2.5 py-1 rounded-lg">
                                        Programmé
                                      </span>
                                      {c.date_examen_conduite && (
                                        <span className="block text-[10px] text-blue-600 font-medium">
                                          le {formatDateSimple(c.date_examen_conduite)}
                                        </span>
                                      )}
                                    </div>
                                  ) : (
                                    <span className="text-xs text-slate-400 font-medium">—</span>
                                  )}
                                </td>
                              )}

                              {/* Colonne 5 : Résultat Global Réel */}
                              <td className="px-4 py-3.5 text-center whitespace-nowrap">
                                {affichageGlobal.type === 'admis' && (
                                  <span className="inline-flex px-3 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-300">
                                    {affichageGlobal.text}
                                  </span>
                                )}
                                {affichageGlobal.type === 'ajourne' && (
                                  <span className="inline-flex px-3 py-1 rounded-full text-xs font-bold bg-rose-100 text-rose-800 border border-rose-300">
                                    {affichageGlobal.text}
                                  </span>
                                )}
                                {affichageGlobal.type === 'programme' && (
                                  <span className="inline-flex px-3 py-1 rounded-full text-xs font-bold bg-blue-100 text-blue-800 border border-blue-300">
                                    {affichageGlobal.text}
                                  </span>
                                )}
                                {affichageGlobal.type === 'vide' && (
                                  <span className="text-slate-300 font-bold">—</span>
                                )}
                              </td>

                              {/* Colonne 6 : Actions (Modifier fiche + WhatsApp) */}
                              <td className="px-4 py-3.5 text-right whitespace-nowrap">
                                <div className="flex items-center justify-end gap-1.5">
                                  <button
                                    type="button"
                                    onClick={() => {
                                      setEditingCandidat(c);
                                      setEditCandSexe(c.sexe);
                                      setEditCandPhoto(c.photo_url);
                                      setModalType('edit_candidat');
                                    }}
                                    className="inline-flex items-center gap-1 text-xs font-semibold px-2.5 py-1.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 transition cursor-pointer"
                                    title="Modifier la fiche et le statut d'examen de ce candidat"
                                  >
                                    <Pencil className="w-3.5 h-3.5 text-blue-600" />
                                    <span>Modifier</span>
                                  </button>

                                  <a
                                    href={`https://wa.me/228${(c.contact || '').replace(/\s+/g, '')}?text=${encodeURIComponent(msgResultat)}`}
                                    target="_blank"
                                    rel="noreferrer"
                                    className="inline-flex items-center gap-1 text-xs font-semibold px-2.5 py-1.5 rounded-xl border bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border-emerald-200 transition shadow-2xs cursor-pointer"
                                    title="Notifier le candidat sur WhatsApp"
                                  >
                                    <MessageSquare className="w-3.5 h-3.5 text-emerald-600" />
                                    <span>WhatsApp</span>
                                  </a>
                                </div>
                              </td>
                            </tr>
                          );
                        })}</tbody>
                    </table>
                  </div>
                </div>
              </div>
            );
          })()}
          </main>
      </div>

      {/* ================= MODALS SYSTEM ================= */}

      {/* Modal Modification Candidat - Design Moderne par Sections */}
      {modalType === 'edit_candidat' && editingCandidat && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-2xl max-h-[92vh] overflow-y-auto shadow-2xl border border-slate-100">
            {/* En-tête modal */}
            <div className="sticky top-0 bg-white/95 backdrop-blur-xs z-10 px-6 py-4 border-b border-slate-100 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center shadow-xs">
                  <Pencil className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Modifier la Fiche Candidat</h3>
                  <p className="text-xs text-slate-500 font-medium">Mise à jour des informations administratives et de scolarité</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => { setModalType(null); setEditingCandidat(null); }}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleUpdateCandidat} className="p-6 space-y-6">
              {/* SECTION 1 : IDENTITÉ */}
              <div className="bg-slate-50/70 border border-slate-200/80 rounded-2xl p-4 sm:p-5 space-y-4">
                <div className="flex items-center gap-2 pb-2 border-b border-slate-200/60">
                  <span className="text-sm font-bold text-blue-900 flex items-center gap-1.5">
                    Identité & Coordonnées
                  </span>
                </div>

                {/* Photo & Sexe interactif */}
                <div className="bg-white border border-slate-200 rounded-xl p-3.5 flex flex-col sm:flex-row items-center gap-4">
                  <div className="flex flex-col items-center shrink-0">
                    <CandidateAvatar
                      sexe={editCandSexe}
                      photoUrl={editCandPhoto}
                      size="xl"
                      editable={true}
                      onPhotoChange={(url) => setEditCandPhoto(url)}
                    />
                    <span className="text-[10px] text-slate-500 font-medium mt-1">
                      Changer la photo
                    </span>
                  </div>

                  <div className="flex-1 w-full space-y-2">
                    <label className="block text-xs font-bold text-slate-700">
                      Genre / Sexe *
                    </label>
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        type="button"
                        onClick={() => setEditCandSexe('MASCULIN')}
                        className={`py-2 px-3 rounded-xl text-xs font-bold border transition flex items-center justify-center gap-1.5 cursor-pointer ${
                          editCandSexe === 'MASCULIN'
                            ? 'bg-blue-600 text-white border-blue-600 shadow-sm'
                            : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                        }`}
                      >
                        <span>♂ Homme</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => setEditCandSexe('FEMININ')}
                        className={`py-2 px-3 rounded-xl text-xs font-bold border transition flex items-center justify-center gap-1.5 cursor-pointer ${
                          editCandSexe === 'FEMININ'
                            ? 'bg-pink-600 text-white border-pink-600 shadow-sm'
                            : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                        }`}
                      >
                        <span>♀ Femme</span>
                      </button>
                    </div>
                    <input type="hidden" name="sexe" value={editCandSexe} />
                    <p className="text-[11px] text-slate-500">
                      Prenez une photo webcam en direct ou sélectionnez une photo sur votre ordinateur.
                    </p>
                  </div>
                </div>

                {/* Nom & Prénom */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Nom de famille *</label>
                    <input
                      required
                      name="nom"
                      defaultValue={editingCandidat.nom}
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm uppercase font-bold text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Prénom *</label>
                    <input
                      required
                      name="prenom"
                      defaultValue={editingCandidat.prenom}
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                </div>

                {/* Contact & Annexe */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Téléphone (Contact) *</label>
                    <input
                      required
                      type="tel"
                      name="contact"
                      defaultValue={editingCandidat.contact}
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Annexe d'affectation</label>
                    <select
                      name="annexe"
                      defaultValue={editingCandidat.annexe}
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 cursor-pointer"
                    >
                      {annexesList.map(a => <option key={a} value={a}>{a}</option>)}
                    </select>
                  </div>
                </div>

                {/* Adresse & Email */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Adresse / Ville</label>
                    <input
                      name="adresse"
                      defaultValue={editingCandidat.adresse || ''}
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Email (Optionnel)</label>
                    <input
                      type="email"
                      name="email"
                      defaultValue={editingCandidat.email || ''}
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                </div>
              </div>

              {/* SECTION 2 : FORMATION & EXAMEN */}
              <div className="bg-indigo-50/50 border border-indigo-200/80 rounded-2xl p-4 sm:p-5 space-y-4">
                <div className="flex items-center gap-2 pb-2 border-b border-indigo-200/60">
                  <span className="text-sm font-bold text-indigo-900 flex items-center gap-1.5">
                    Formation & Statut Examen
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-indigo-950 mb-1.5">Permis</label>
                    <select
                      name="categorie"
                      defaultValue={editingCandidat.categorie}
                      className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-bold text-blue-700 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                    >
                      <option value="A">Permis A</option>
                      <option value="B">Permis B</option>
                      <option value="C">Permis C</option>
                      <option value="D">Permis D</option>
                      <option value="E">Permis E</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-indigo-950 mb-1.5">Langue</label>
                    <select
                      name="langue"
                      defaultValue={editingCandidat.langue}
                      className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                    >
                      <option value="FRANCAIS">Français</option>
                      <option value="EWE">Ewé</option>
                      <option value="MINA">Mina</option>
                      <option value="MOBA">Moba</option>
                      <option value="KOTOKOLI">Kotokoli</option>
                      <option value="KABYE">Kabyè</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-indigo-950 mb-1.5">Statut Examen</label>
                    <select
                      name="statut"
                      defaultValue={editingCandidat.statut}
                      className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-bold text-slate-900 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                    >
                      <option value="INSCRIT">INSCRIT (En cours)</option>
                      <option value="ADMIS">ADMIS (Succès)</option>
                      <option value="NON_ADMIS">NON ADMIS (Ajourné)</option>
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-indigo-950 mb-1.5">Type de Formation</label>
                    <select
                      name="type_formation"
                      defaultValue={editingCandidat.type_formation || 'COMPLETE'}
                      className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                    >
                      <option value="COMPLETE">Formation Complète</option>
                      <option value="CONDUITE_SEULE">Achat de Conduite Uniquement</option>
                      <option value="RECYCLAGE">Recyclage</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-indigo-950 mb-1.5">Durée Formation</label>
                    <select
                      name="duree_formation_mois"
                      defaultValue={editingCandidat.duree_formation_mois || 3}
                      className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                    >
                      {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map(m => (
                        <option key={m} value={m}>{m} mois</option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Programmation & Statuts des Examens (Code & Conduite) */}
                <div className="pt-3 border-t border-indigo-200/60 space-y-3">
                  <span className="text-xs font-bold text-indigo-950 block">Détails des Épreuves d'Examen</span>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                    {/* Épreuve Code */}
                    <div className="bg-white/80 border border-indigo-200/80 rounded-xl p-3 space-y-2">
                      <span className="text-xs font-bold text-slate-800 block">Épreuve Code de la Route</span>
                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 mb-1">Statut Code</label>
                        <select
                          name="statut_examen_code"
                          defaultValue={editingCandidat.statut_examen_code || 'NON_PROGRAMME'}
                          className="w-full bg-slate-50 border border-slate-200 rounded-lg px-2.5 py-1.5 text-xs font-semibold text-slate-800 cursor-pointer"
                        >
                          <option value="NON_PROGRAMME">Non programmé (En formation)</option>
                          <option value="PROGRAMME">Programmé</option>
                          <option value="ADMIS">Admis ✓</option>
                          <option value="AJOURNE">Ajourné ✗</option>
                        </select>
                      </div>
                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 mb-1">Date d'examen Code</label>
                        <input
                          type="date"
                          name="date_examen_code"
                          defaultValue={editingCandidat.date_examen_code || ''}
                          className="w-full bg-slate-50 border border-slate-200 rounded-lg px-2.5 py-1.5 text-xs font-medium text-slate-800 cursor-pointer"
                        />
                      </div>
                    </div>

                    {/* Épreuve Conduite */}
                    <div className="bg-white/80 border border-indigo-200/80 rounded-xl p-3 space-y-2">
                      <span className="text-xs font-bold text-slate-800 block">Épreuve Conduite</span>
                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 mb-1">Statut Conduite</label>
                        <select
                          name="statut_examen_conduite"
                          defaultValue={editingCandidat.statut_examen_conduite || 'NON_PROGRAMME'}
                          className="w-full bg-slate-50 border border-slate-200 rounded-lg px-2.5 py-1.5 text-xs font-semibold text-slate-800 cursor-pointer"
                        >
                          <option value="NON_PROGRAMME">Non programmé (En formation)</option>
                          <option value="PROGRAMME">Programmé</option>
                          <option value="ADMIS">Admis ✓</option>
                          <option value="AJOURNE">Ajourné ✗</option>
                        </select>
                      </div>
                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 mb-1">Date d'examen Conduite</label>
                        <input
                          type="date"
                          name="date_examen_conduite"
                          defaultValue={editingCandidat.date_examen_conduite || ''}
                          className="w-full bg-slate-50 border border-slate-200 rounded-lg px-2.5 py-1.5 text-xs font-medium text-slate-800 cursor-pointer"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* SECTION 3 : CONDUITE & FINANCES */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {/* Conduite */}
                <div className="bg-amber-50/50 border border-amber-200/80 rounded-2xl p-4 space-y-3">
                  <span className="text-xs font-bold text-amber-950 block">Séances de Conduite</span>
                  <div>
                    <label className="block text-[11px] font-semibold text-slate-600 mb-1">Effectuées</label>
                    <input
                      type="number"
                      name="nb_conduites_effectuees"
                      min="0"
                      defaultValue={editingCandidat.nb_conduites_effectuees || 0}
                      className="w-full bg-white border border-amber-200 rounded-xl px-3 py-2 text-sm font-bold text-slate-900"
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-semibold text-slate-600 mb-1">Prévues au total</label>
                    <input
                      type="number"
                      name="nb_conduites_prevues"
                      min="0"
                      defaultValue={editingCandidat.nb_conduites_prevues || 20}
                      className="w-full bg-white border border-amber-200 rounded-xl px-3 py-2 text-sm font-bold text-slate-900"
                    />
                  </div>
                </div>

                {/* Scolarité */}
                <div className="bg-emerald-50/50 border border-emerald-200/80 rounded-2xl p-4 space-y-3">
                  <span className="text-xs font-bold text-emerald-950 block">Règlement Scolarité</span>
                  <div>
                    <label className="block text-[11px] font-semibold text-slate-600 mb-1">Montant Total (FCFA)</label>
                    <input
                      required
                      type="number"
                      name="montant_total"
                      defaultValue={editingCandidat.montant_total}
                      className="w-full bg-white border border-emerald-200 rounded-xl px-3 py-2 text-sm font-bold text-slate-900"
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-semibold text-slate-600 mb-1">Montant Encaissé (FCFA)</label>
                    <input
                      required
                      type="number"
                      name="montant_paye"
                      defaultValue={editingCandidat.montant_paye}
                      className="w-full bg-white border border-emerald-200 rounded-xl px-3 py-2 text-sm font-bold text-emerald-700"
                    />
                  </div>
                </div>
              </div>

              {/* Code d'accès application */}
              <div className="bg-slate-50 border border-slate-200 rounded-2xl p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div className="flex-1">
                  <label className="block text-xs font-bold text-slate-700 mb-1">Code d'accès App Candidat</label>
                  <input
                    id="input_edit_code_acces"
                    name="code_acces"
                    defaultValue={editingCandidat.code_acces || ''}
                    className="w-full bg-white border border-slate-200 rounded-xl px-3.5 py-2 text-sm font-mono font-bold text-indigo-700 tracking-wider"
                  />
                </div>
                <button
                  type="button"
                  onClick={() => {
                    const input = document.getElementById('input_edit_code_acces') as HTMLInputElement;
                    if (input) input.value = generateAccessCode();
                  }}
                  className="sm:mt-5 px-4 py-2.5 text-xs bg-indigo-50 hover:bg-indigo-100 text-indigo-700 border border-indigo-200 rounded-xl font-bold transition flex items-center justify-center gap-1.5 cursor-pointer"
                >
                  <RefreshCw className="w-3.5 h-3.5" />
                  <span>Régénérer</span>
                </button>
              </div>

              {/* Boutons d'action */}
              <div className="pt-3 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-3">
                <button
                  type="button"
                  onClick={() => handleDeleteCandidat(editingCandidat.id, `${editingCandidat.nom} ${editingCandidat.prenom}`)}
                  className="w-full sm:w-auto flex items-center justify-center gap-1.5 px-4 py-2.5 text-xs text-rose-600 hover:text-white hover:bg-rose-600 border border-rose-200 hover:border-rose-600 rounded-xl font-bold transition cursor-pointer"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                  <span>Supprimer dossier</span>
                </button>

                <div className="w-full sm:w-auto flex items-center justify-end gap-2.5">
                  <button
                    type="button"
                    onClick={() => { setModalType(null); setEditingCandidat(null); }}
                    className="px-4 py-2.5 text-sm text-slate-500 hover:bg-slate-100 rounded-xl font-semibold cursor-pointer"
                  >
                    Annuler
                  </button>
                  <button
                    type="submit"
                    className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-blue-600/25 transition cursor-pointer flex items-center gap-2"
                  >
                    <CheckCircle2 className="w-4 h-4" />
                    <span>Enregistrer</span>
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Achat Séances de Conduite Supplémentaires - Design Moderne */}
      {modalType === 'add_supplement_conduite' && selectedCandidatForSupplement && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-xl max-h-[92vh] overflow-y-auto shadow-2xl border border-slate-100">
            {/* En-tête */}
            <div className="sticky top-0 bg-white/95 backdrop-blur-xs z-10 px-6 py-4 border-b border-slate-100 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center shadow-xs">
                  <Car className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Séances de Conduite Supplémentaires</h3>
                  <p className="text-xs text-slate-500 font-medium">Ajout d'heures de conduite & encaissement</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setModalType(null)}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Fiche récapitulative du candidat */}
            <div className="p-6 space-y-5">
              <div className="bg-slate-50 border border-slate-200 rounded-2xl p-4 flex items-center justify-between">
                <div>
                  <p className="font-extrabold text-slate-900 text-sm">
                    {selectedCandidatForSupplement.nom} {selectedCandidatForSupplement.prenom}
                  </p>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Permis {selectedCandidatForSupplement.categorie} • {selectedCandidatForSupplement.annexe} • Tél: {selectedCandidatForSupplement.contact}
                  </p>
                </div>
                <div className="text-right">
                  <span className="inline-block bg-blue-100 text-blue-800 text-xs font-bold px-3 py-1 rounded-xl">
                    {selectedCandidatForSupplement.nb_conduites_effectuees || 0} / {selectedCandidatForSupplement.nb_conduites_prevues || 20} séances
                  </span>
                  <p className="text-[10px] text-slate-400 mt-0.5">Quota actuel</p>
                </div>
              </div>

              <form onSubmit={handleAddSupplementConduite} className="space-y-5">
                {/* Séances */}
                <div className="bg-amber-50/50 border border-amber-200/80 rounded-2xl p-4 sm:p-5 space-y-3">
                  <div className="flex items-center gap-1.5 pb-2 border-b border-amber-200/60">
                    <span className="text-sm font-bold text-amber-950 flex items-center gap-1.5">
                      <span>🚗</span> Nombre de séances à ajouter
                    </span>
                  </div>

                  <div className="grid grid-cols-4 gap-2">
                    {[2, 4, 6, 10].map((preset) => (
                      <button
                        key={preset}
                        type="button"
                        onClick={() => {
                          const inputNb = document.getElementById('input_nb_seances') as HTMLInputElement;
                          const inputPrix = document.getElementById('input_montant_supp') as HTMLInputElement;
                          const inputPaye = document.getElementById('input_montant_verse') as HTMLInputElement;
                          if (inputNb) inputNb.value = preset.toString();
                          const total = preset * 5000;
                          if (inputPrix) inputPrix.value = total.toString();
                          if (inputPaye) inputPaye.value = total.toString();
                        }}
                        className="py-2 px-1 bg-white hover:bg-amber-100 border border-amber-200 text-amber-900 text-xs font-bold rounded-xl transition cursor-pointer shadow-xs text-center"
                      >
                        +{preset} séances
                      </button>
                    ))}
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-amber-950 mb-1">
                      Nombre total de séances supplémentaires :
                    </label>
                    <input
                      id="input_nb_seances"
                      required
                      type="number"
                      name="nb_seances"
                      min="1"
                      max="50"
                      defaultValue="4"
                      onChange={(e) => {
                        const nb = Number(e.target.value) || 0;
                        const inputPrix = document.getElementById('input_montant_supp') as HTMLInputElement;
                        const inputPaye = document.getElementById('input_montant_verse') as HTMLInputElement;
                        const total = nb * 5000;
                        if (inputPrix) inputPrix.value = total.toString();
                        if (inputPaye) inputPaye.value = total.toString();
                      }}
                      className="w-full bg-white border border-amber-200 rounded-xl px-3.5 py-2.5 text-sm font-bold text-slate-800 focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-100 transition"
                    />
                  </div>
                </div>

                {/* Règlement financier */}
                <div className="bg-emerald-50/50 border border-emerald-200/80 rounded-2xl p-4 sm:p-5 space-y-3">
                  <div className="flex items-center gap-1.5 pb-2 border-b border-emerald-200/60">
                    <span className="text-sm font-bold text-emerald-950 flex items-center gap-1.5">
                      <span>💳</span> Règlement Financier
                    </span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                    <div>
                      <label className="block text-xs font-bold text-slate-800 mb-1.5">
                        Prix Total du supplément (FCFA) *
                      </label>
                      <input
                        id="input_montant_supp"
                        required
                        type="number"
                        name="montant_supplement"
                        defaultValue="20000"
                        className="w-full bg-white border border-emerald-200 rounded-xl px-3.5 py-2.5 text-sm font-bold text-slate-900 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition"
                      />
                      <span className="text-[10px] text-slate-500 mt-1 block">5 000 FCFA / séance conseillé</span>
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-emerald-900 mb-1.5">
                        Montant Versé ce jour (FCFA) *
                      </label>
                      <input
                        id="input_montant_verse"
                        required
                        type="number"
                        name="montant_verse"
                        defaultValue="20000"
                        className="w-full bg-white border border-emerald-200 rounded-xl px-3.5 py-2.5 text-sm font-bold text-emerald-700 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition"
                      />
                      <span className="text-[10px] text-emerald-700 mt-1 block">Paiement total ou partiel</span>
                    </div>
                  </div>
                </div>

                {/* Mode & Date & Motif */}
                <div className="bg-slate-50 border border-slate-200 rounded-2xl p-4 sm:p-5 space-y-3.5">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                    <div>
                      <label className="block text-xs font-bold text-slate-700 mb-1.5">Mode de règlement</label>
                      <select name="mode_paiement" className="w-full bg-white border border-slate-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 cursor-pointer">
                        <option value="Espèces">Espèces (Caisse)</option>
                        <option value="TMoney (+228)">TMoney</option>
                        <option value="Flooz (+228)">Flooz</option>
                        <option value="Virement Bancaire">Virement Bancaire</option>
                        <option value="Chèque">Chèque</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-slate-700 mb-1.5">Date du versement</label>
                      <input
                        type="date"
                        name="date_operation"
                        defaultValue={new Date().toISOString().split('T')[0]}
                        className="w-full bg-white border border-slate-200 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-800 cursor-pointer"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Motif / Justificatif</label>
                    <select name="motif" className="w-full bg-white border border-slate-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 cursor-pointer">
                      <option value="Perfectionnement créneau et manœuvres">Perfectionnement créneau et manœuvres</option>
                      <option value="Heures supplémentaires après échec examen">Heures supplémentaires après ajournement</option>
                      <option value="Renforcement conduite circulation / route">Renforcement circulation et route</option>
                      <option value="Séances supplémentaires à la demande de l'élève">À la demande du candidat</option>
                    </select>
                  </div>
                </div>

                {/* Boutons actions */}
                <div className="pt-2 flex items-center justify-end gap-3 border-t border-slate-100">
                  <button
                    type="button"
                    onClick={() => setModalType(null)}
                    className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                  >
                    Annuler
                  </button>
                  <button
                    type="submit"
                    className="px-6 py-2.5 bg-amber-600 hover:bg-amber-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-amber-600/25 flex items-center gap-2 transition cursor-pointer"
                  >
                    <Car className="w-4 h-4" />
                    <span>Valider & Générer Reçu</span>
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Inscrire Candidat Modal - Design Moderne & Organisé par Sections */}
      {modalType === 'add_candidat' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-2xl max-h-[92vh] overflow-y-auto shadow-2xl border border-slate-100">
            {/* En-tête modal */}
            <div className="sticky top-0 bg-white/95 backdrop-blur-xs z-10 px-6 py-4 border-b border-slate-100 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center shadow-xs">
                  <UserPlus className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Inscription d'un Nouveau Candidat</h3>
                  <p className="text-xs text-slate-500 font-medium">Auto-École Saint Edmond • Enregistrement officiel</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setModalType(null)}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddCandidat} className="p-6 space-y-6">
              {/* SECTION 1 : IDENTITÉ */}
              <div className="bg-slate-50/70 border border-slate-200/80 rounded-2xl p-4 sm:p-5 space-y-4">
                <div className="pb-2 border-b border-slate-200/60">
                  <span className="text-sm font-bold text-blue-900">
                    Identité du Candidat
                  </span>
                </div>

                {/* Photo & Sexe interactif */}
                <div className="bg-white border border-slate-200 rounded-xl p-3.5 flex flex-col sm:flex-row items-center gap-4">
                  <div className="flex flex-col items-center shrink-0">
                    <CandidateAvatar
                      sexe={newCandSexe}
                      photoUrl={newCandPhoto}
                      size="xl"
                      editable={true}
                      onPhotoChange={(url) => setNewCandPhoto(url)}
                    />
                    <span className="text-[10px] text-slate-500 font-medium mt-1">
                      Photo / Webcam
                    </span>
                  </div>

                  <div className="flex-1 w-full space-y-2">
                    <label className="block text-xs font-bold text-slate-700">
                      Genre / Sexe *
                    </label>
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        type="button"
                        onClick={() => setNewCandSexe('MASCULIN')}
                        className={`py-2 px-3 rounded-xl text-xs font-bold border transition flex items-center justify-center gap-1.5 cursor-pointer ${
                          newCandSexe === 'MASCULIN'
                            ? 'bg-blue-600 text-white border-blue-600 shadow-sm'
                            : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                        }`}
                      >
                        <span>Homme</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => setNewCandSexe('FEMININ')}
                        className={`py-2 px-3 rounded-xl text-xs font-bold border transition flex items-center justify-center gap-1.5 cursor-pointer ${
                          newCandSexe === 'FEMININ'
                            ? 'bg-pink-600 text-white border-pink-600 shadow-sm'
                            : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                        }`}
                      >
                        <span>Femme</span>
                      </button>
                    </div>
                    <input type="hidden" name="sexe" value={newCandSexe} />
                    <p className="text-[11px] text-slate-500">
                      Cliquez sur la caméra pour prendre directement une photo ou joindre un fichier.
                    </p>
                  </div>
                </div>

                {/* Nom & Prénom */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">
                      Nom de famille <span className="text-rose-500">*</span>
                    </label>
                    <input
                      required
                      name="nom"
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm uppercase font-semibold text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">
                      Prénom <span className="text-rose-500">*</span>
                    </label>
                    <input
                      required
                      name="prenom"
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                </div>

                {/* Téléphone & Date d'inscription */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">
                      Téléphone (Contact) <span className="text-rose-500">*</span>
                    </label>
                    <input
                      required
                      type="tel"
                      name="contact"
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">
                      Date d'inscription <span className="text-rose-500">*</span>
                    </label>
                    <input
                      required
                      type="date"
                      name="date_inscription"
                      defaultValue={new Date().toISOString().split('T')[0]}
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition cursor-pointer"
                    />
                  </div>
                </div>

                {/* Adresse & Email */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">
                      Adresse / Ville du candidat
                    </label>
                    <input
                      name="adresse"
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">
                      Email (Optionnel)
                    </label>
                    <input
                      type="email"
                      name="email"
                      className="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                </div>
              </div>

              {/* SECTION 2 : FORMATION */}
              <div className="bg-indigo-50/50 border border-indigo-200/80 rounded-2xl p-4 sm:p-5 space-y-4">
                <div className="pb-2 border-b border-indigo-200/60">
                  <span className="text-sm font-bold text-indigo-900">
                    Formation & Permis
                  </span>
                </div>

                {/* Type de Formation */}
                <div>
                  <label className="block text-xs font-bold text-indigo-950 mb-1.5">
                    Type de Formation
                  </label>
                  <select
                    name="type_formation"
                    className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer shadow-xs"
                  >
                    <option value="COMPLETE">Formation Complète</option>
                    <option value="CONDUITE_SEULE">Achat de Conduite Uniquement</option>
                    <option value="RECYCLAGE">Recyclage</option>
                  </select>
                </div>

                {/* Grille Permis, Langue, Durée */}
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-indigo-950 mb-1.5">
                      Catégorie Permis
                    </label>
                    <select
                      name="categorie"
                      defaultValue="B"
                      className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-bold text-blue-700 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                    >
                      <option value="A">Permis A</option>
                      <option value="B">Permis B</option>
                      <option value="C">Permis C</option>
                      <option value="D">Permis D</option>
                      <option value="E">Permis E</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-indigo-950 mb-1.5">
                      Langue
                    </label>
                    <select
                      name="langue"
                      defaultValue="FRANCAIS"
                      className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                    >
                      <option value="FRANCAIS">Français</option>
                      <option value="EWE">Ewé</option>
                      <option value="MINA">Mina</option>
                      <option value="MOBA">Moba</option>
                      <option value="KOTOKOLI">Kotokoli</option>
                      <option value="KABYE">Kabyè</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-indigo-950 mb-1.5">
                      Durée Formation
                    </label>
                    <select
                      name="duree_formation_mois"
                      defaultValue="3"
                      className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                    >
                      {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map((m) => (
                        <option key={m} value={m}>{m} mois</option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Séances de conduite prévues */}
                <div className="bg-amber-50 border border-amber-200 rounded-xl px-3.5 py-2.5 flex items-center justify-between gap-2">
                  <span className="text-[11px] font-bold text-amber-900 uppercase tracking-wide">Séances de Conduite prévues</span>
                  <input
                    type="number"
                    name="nb_conduites_prevues"
                    min="0"
                    max="99"
                    className="w-20 bg-white border border-amber-300 rounded-xl px-2 py-1.5 text-sm font-extrabold text-amber-900 text-center focus:outline-none focus:ring-2 focus:ring-amber-400"
                  />
                </div>

                {/* Annexe d'inscription */}
                <div>
                  <label className="block text-xs font-bold text-indigo-950 mb-1.5">
                    Annexe d'inscription
                  </label>
                  <select
                    name="annexe"
                    className="w-full bg-white border border-indigo-200 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 cursor-pointer"
                  >
                    {annexesList.map((a) => (
                      <option key={a} value={a}>{a}</option>
                    ))}
                  </select>
                </div>
              </div>

              {/* SECTION 3 : RÈGLEMENT & PAIEMENT */}
              <div className="bg-emerald-50/50 border border-emerald-200/80 rounded-2xl p-4 sm:p-5 space-y-4">
                <div className="pb-2 border-b border-emerald-200/60">
                  <span className="text-sm font-bold text-emerald-900">
                    Règlement & Scolarité
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-xs font-bold text-slate-800 mb-1.5">
                      Montant Total de la formation (FCFA) <span className="text-rose-500">*</span>
                    </label>
                    <input
                      required
                      type="number"
                      name="montant_total"
                      className="w-full bg-white border border-emerald-200 rounded-xl px-3.5 py-2.5 text-sm font-bold text-slate-900 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-emerald-900 mb-1.5">
                      Premier versement encaissé (FCFA)
                    </label>
                    <input
                      type="number"
                      name="montant_paye"
                      className="w-full bg-white border border-emerald-200 rounded-xl px-3.5 py-2.5 text-sm font-bold text-emerald-700 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition"
                    />
                  </div>
                </div>
              </div>

              {/* BOUTONS ACTIONS */}
              <div className="pt-2 flex items-center justify-end gap-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setModalType(null)}
                  className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-blue-600/25 flex items-center gap-2 transition cursor-pointer"
                >
                  <CheckCircle2 className="w-4 h-4" />
                  <span>Valider l'Inscription</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Dépense Modal - Design Moderne */}
      {modalType === 'add_depense' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-lg shadow-2xl border border-slate-100 overflow-hidden">
            {/* En-tête */}
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center shadow-xs">
                  <ArrowUpRight className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Enregistrer une Dépense</h3>
                  <p className="text-xs text-slate-500 font-medium">Sortie de caisse • Auto-École Saint Edmond</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setModalType(null)}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddDepense} className="p-6 space-y-4">
              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-slate-700">Catégorie de Dépense *</label>
                <select name="type" className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 focus:outline-none focus:border-rose-500 focus:ring-2 focus:ring-rose-100 cursor-pointer">
                  <option value="NORMALE">NORMALE (Carburant, entretien)</option>
                  <option value="FIXE">FIXE (Loyer, salaires, eau/élec)</option>
                  <option value="SPECIALE_DG">SPÉCIALE DG (Investissement, missions)</option>
                  <option value="SECRETAIRE">SECRÉTAIRE (Papeterie, menus frais)</option>
                </select>
              </div>

              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-slate-700">Intitulé / Motif de la dépense *</label>
                <input
                  required
                  name="intitule"
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-rose-500 focus:ring-2 focus:ring-rose-100 transition"
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">Montant décaissé (FCFA) *</label>
                  <input
                    required
                    type="number"
                    name="montant"
                    className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-bold text-rose-600 focus:outline-none focus:border-rose-500 focus:ring-2 focus:ring-rose-100 transition"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">Annexe concernée</label>
                  <select name="annexe" className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 cursor-pointer">
                    {annexesList.map(a => <option key={a} value={a}>{a}</option>)}
                  </select>
                </div>
              </div>

              <div className="pt-3 flex items-center justify-end gap-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setModalType(null)}
                  className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  className="px-6 py-2.5 bg-rose-600 hover:bg-rose-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-rose-600/25 flex items-center gap-2 transition cursor-pointer"
                >
                  <CheckCircle2 className="w-4 h-4" />
                  <span>Enregistrer Dépense</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Recette Modal - Design Moderne */}
      {modalType === 'add_recette' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-lg shadow-2xl border border-slate-100 overflow-hidden">
            {/* En-tête */}
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center shadow-xs">
                  <ArrowDownLeft className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Encaisser une Recette</h3>
                  <p className="text-xs text-slate-500 font-medium">Entrée en caisse • Auto-École Saint Edmond</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setModalType(null)}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddRecette} className="p-6 space-y-4">
              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-slate-700">Intitulé de l'encaissement *</label>
                <input
                  required
                  name="intitule"
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition"
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">Montant perçu (FCFA) *</label>
                  <input
                    required
                    type="number"
                    name="montant"
                    className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-bold text-emerald-700 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">Annexe concernée</label>
                  <select name="annexe" className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 cursor-pointer">
                    {annexesList.map(a => <option key={a} value={a}>{a}</option>)}
                  </select>
                </div>
              </div>

              <div className="pt-3 flex items-center justify-end gap-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setModalType(null)}
                  className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  className="px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-emerald-600/25 flex items-center gap-2 transition cursor-pointer"
                >
                  <CheckCircle2 className="w-4 h-4" />
                  <span>Encaisser Recette</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Modifier Dépense - Design Moderne */}
      {modalType === 'edit_depense' && editingDepense && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-lg shadow-2xl border border-slate-100 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center shadow-xs">
                  <Pencil className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Corriger la Dépense</h3>
                  <p className="text-xs text-slate-500 font-medium">Modification de la pièce comptable</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => { setModalType(null); setEditingDepense(null); }}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleUpdateDepense} className="p-6 space-y-4">
              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-slate-700">Catégorie de Dépense</label>
                <select name="type" defaultValue={editingDepense.type} className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 cursor-pointer">
                  <option value="NORMALE">NORMALE (Carburant, entretien)</option>
                  <option value="FIXE">FIXE (Loyer, salaires, eau/élec)</option>
                  <option value="SPECIALE_DG">SPÉCIALE DG (Investissement, missions)</option>
                  <option value="SECRETAIRE">SECRÉTAIRE (Papeterie, menus frais)</option>
                </select>
              </div>

              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-slate-700">Intitulé / Motif</label>
                <input
                  required
                  name="intitule"
                  defaultValue={editingDepense.intitule}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">Montant (FCFA)</label>
                  <input
                    required
                    type="number"
                    name="montant"
                    defaultValue={editingDepense.montant}
                    className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-bold text-rose-600 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">Annexe</label>
                  <select name="annexe" defaultValue={editingDepense.annexe} className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 cursor-pointer">
                    {annexesList.map(a => <option key={a} value={a}>{a}</option>)}
                  </select>
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-slate-700">Date d'opération</label>
                <input
                  required
                  type="date"
                  name="date"
                  defaultValue={editingDepense.date}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 cursor-pointer"
                />
              </div>

              <div className="pt-3 flex items-center justify-end gap-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => { setModalType(null); setEditingDepense(null); }}
                  className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-blue-600/25 flex items-center gap-2 transition cursor-pointer"
                >
                  <CheckCircle2 className="w-4 h-4" />
                  <span>Enregistrer</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Modifier Recette - Design Moderne */}
      {modalType === 'edit_recette' && editingRecette && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-lg shadow-2xl border border-slate-100 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center shadow-xs">
                  <Pencil className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Corriger la Recette</h3>
                  <p className="text-xs text-slate-500 font-medium">Modification de la recette encaissée</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => { setModalType(null); setEditingRecette(null); }}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleUpdateRecette} className="p-6 space-y-4">
              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-slate-700">Intitulé de l'encaissement</label>
                <input
                  required
                  name="intitule"
                  defaultValue={editingRecette.intitule}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">Montant (FCFA)</label>
                  <input
                    required
                    type="number"
                    name="montant"
                    defaultValue={editingRecette.montant}
                    className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-bold text-emerald-700 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">Annexe</label>
                  <select name="annexe" defaultValue={editingRecette.annexe} className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-800 cursor-pointer">
                    {annexesList.map(a => <option key={a} value={a}>{a}</option>)}
                  </select>
                </div>
              </div>

              <div className="pt-3 flex items-center justify-end gap-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => { setModalType(null); setEditingRecette(null); }}
                  className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-blue-600/25 flex items-center gap-2 transition cursor-pointer"
                >
                  <CheckCircle2 className="w-4 h-4" />
                  <span>Enregistrer</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Export PDF Selector Modal */}
      {modalType === 'export_pdf' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md p-6 shadow-2xl space-y-4">
            <h3 className="font-bold text-lg text-slate-800 border-b pb-3">Télécharger vos États PDF Officiels</h3>
            <div className="space-y-2.5">
              <button
                onClick={() => {
                  generateCandidatsPDF(filteredCandidats, 'Liste Générale des Candidats');
                  setModalType(null);
                  showToast('PDF Téléchargé');
                }}
                className="w-full flex items-center justify-between p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 font-medium text-sm text-slate-700 transition"
              >
                <span>Liste Complète des Candidats</span>
                <Download className="w-4 h-4 text-blue-600" />
              </button>
              <button
                onClick={() => {
                  const admis = filteredCandidats.filter(c => c.statut === 'ADMIS');
                  generateCandidatsPDF(admis, 'Liste des Candidats Admis aux Examens');
                  setModalType(null);
                  showToast('PDF Téléchargé');
                }}
                className="w-full flex items-center justify-between p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 font-medium text-sm text-slate-700 transition"
              >
                <span>Liste des Candidats Admis</span>
                <Download className="w-4 h-4 text-blue-600" />
              </button>
              <button
                onClick={() => {
                  const nonSoldes = filteredCandidats.filter(c => c.montant_paye < c.montant_total);
                  generateCandidatsPDF(nonSoldes, 'État des Soldes de Scolarité Débiteurs');
                  setModalType(null);
                  showToast('PDF Téléchargé');
                }}
                className="w-full flex items-center justify-between p-3.5 rounded-xl border border-slate-200 hover:bg-slate-50 font-medium text-sm text-slate-700 transition"
              >
                <span>Candidats Non Soldés (Relance Dettes)</span>
                <Download className="w-4 h-4 text-blue-600" />
              </button>
            </div>
            <div className="pt-2 flex justify-end">
              <button onClick={() => setModalType(null)} className="px-4 py-2 text-sm text-slate-500 font-semibold">Fermer</button>
            </div>
          </div>
        </div>
      )}

      {/* Broadcast Message Modal */}
      {modalType === 'broadcast_msg' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md p-6 shadow-2xl space-y-4">
            <h3 className="font-bold text-lg text-slate-800 border-b pb-3">
              Notification aux Candidats {modalData?.statut}
            </h3>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5">Canaux d'expédition</label>
              <div className="flex gap-4 text-sm font-medium">
                <label className="flex items-center gap-1.5 cursor-pointer">
                  <input type="checkbox" defaultChecked className="rounded text-blue-600" /> SMS
                </label>
                <label className="flex items-center gap-1.5 cursor-pointer">
                  <input type="checkbox" defaultChecked className="rounded text-blue-600" /> WhatsApp
                </label>
                <label className="flex items-center gap-1.5 cursor-pointer">
                  <input type="checkbox" className="rounded text-blue-600" /> Email
                </label>
              </div>
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5">Contenu du message</label>
              <textarea
                rows={4}
                defaultValue={
                  modalData?.statut === 'ADMIS'
                    ? "Félicitations de la part de l'Auto-École SAINT EDMOND! Vous avez réussi votre examen de permis de conduire. Rendez-vous au secrétariat pour les formalités de retrait."
                    : "Bonjour, votre résultat à la dernière session n'a pas été validé. Contactez le secrétariat pour vous inscrire à la prochaine session de rattrapage."
                }
                className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="pt-3 flex justify-end gap-2">
              <button onClick={() => setModalType(null)} className="px-4 py-2 text-sm text-slate-500">Annuler</button>
              <button
                onClick={() => {
                  setModalType(null);
                  showToast('Messages transmis aux candidats via la passerelle SMS & WhatsApp !');
                }}
                className="flex items-center gap-2 px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-md"
              >
                <Send className="w-4 h-4" />
                <span>Envoyer le Broadcast</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Subscription modal */}
      {modalType === 'abonnement' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg p-6 shadow-2xl space-y-4">
            <h3 className="font-bold text-lg text-slate-800 border-b pb-3">Licence & Modules Logiciels Auto-École Saint Edmond</h3>
            <div className="grid grid-cols-3 gap-3">
              {[
                { name: 'Mensuel', price: '15 000 F', period: '/ mois' },
                { name: 'Trimestriel', price: '40 000 F', period: '/ 3 mois' },
                { name: 'Annuel', price: '150 000 F', period: '/ 12 mois', popular: true },
              ].map((p) => (
                <div key={p.name} className={`p-4 rounded-xl border ${p.popular ? 'border-blue-500 bg-blue-50/30' : 'border-slate-200'} text-center flex flex-col justify-between`}>
                  <div>
                    <h5 className="font-bold text-sm text-slate-800">{p.name}</h5>
                    <p className="text-base font-extrabold text-blue-600 mt-2">{p.price}</p>
                    <p className="text-xs text-slate-400">{p.period}</p>
                  </div>
                  <button
                    onClick={() => {
                      setModalType(null);
                      showToast(`Paiement Mobile Money (TMoney / Flooz) initié pour ${p.name}`);
                    }}
                    className="mt-4 w-full bg-blue-600 text-white py-1.5 rounded-lg text-xs font-bold hover:bg-blue-700 transition"
                  >
                    Choisir
                  </button>
                </div>
              ))}
            </div>
            <div className="pt-2 flex justify-end">
              <button onClick={() => setModalType(null)} className="px-4 py-2 text-sm text-slate-500">Fermer</button>
            </div>
          </div>
        </div>
      )}

      {/* Logout modal */}
      {modalType === 'logout' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-sm p-6 shadow-2xl text-center space-y-4">
            <div className="w-12 h-12 bg-rose-100 text-rose-600 rounded-full flex items-center justify-center mx-auto">
              <AlertCircle className="w-6 h-6" />
            </div>
            <h3 className="font-bold text-lg text-slate-800">Déconnexion</h3>
            <p className="text-sm text-slate-500">Souhaitez-vous fermer votre session sécurisée ?</p>
            <div className="flex gap-2 justify-center">
              <button onClick={() => setModalType(null)} className="px-4 py-2 rounded-xl text-sm font-semibold bg-slate-100 text-slate-700">
                Annuler
              </button>
              <button
                onClick={() => {
                  setModalType(null);
                  setIsAuthenticated(false);
                }}
                className="px-4 py-2 rounded-xl text-sm font-semibold bg-rose-600 text-white hover:bg-rose-700"
              >
                Confirmer
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Password change modal (DG et Secrétaire) */}
      {passwordModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl border border-slate-100 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center shadow-xs">
                  <KeyRound className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Modifier mon Mot de Passe</h3>
                  <p className="text-xs text-slate-500 font-medium">Sécurité du compte • ${role === 'DG' ? 'Direction Générale' : 'Secrétariat'}</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setPasswordModalOpen(false)}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-6 space-y-4">
              {passwordError && (
                <div className="bg-rose-50 border border-rose-200 text-rose-700 text-xs rounded-xl p-3 flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 shrink-0" />
                  <span>{passwordError}</span>
                </div>
              )}

              <form onSubmit={handlePasswordSubmit} className="space-y-4">
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">
                    Mot de passe actuel *
                  </label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                    <input
                      type="password"
                      required
                      value={oldPassword}
                      onChange={(e) => setOldPassword(e.target.value)}
                      className="w-full pl-10 pr-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-xl text-sm font-medium focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">
                    Nouveau mot de passe *
                  </label>
                  <div className="relative">
                    <KeyRound className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                    <input
                      type="password"
                      required
                      minLength={4}
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      className="w-full pl-10 pr-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-xl text-sm font-medium focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">
                    Confirmer le nouveau mot de passe *
                  </label>
                  <div className="relative">
                    <KeyRound className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                    <input
                      type="password"
                      required
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      className="w-full pl-10 pr-3.5 py-2.5 bg-slate-50 border border-slate-300 rounded-xl text-sm font-medium focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                    />
                  </div>
                </div>

                <div className="pt-3 flex items-center justify-end gap-3 border-t border-slate-100">
                  <button
                    type="button"
                    onClick={() => setPasswordModalOpen(false)}
                    className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                  >
                    Annuler
                  </button>
                  <button
                    type="submit"
                    className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-blue-600/25 flex items-center gap-2 transition cursor-pointer"
                  >
                    <CheckCircle2 className="w-4 h-4" />
                    <span>Enregistrer</span>
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {modalType === 'add_annexe' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl border border-slate-100 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center shadow-xs">
                  <Plus className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-lg text-slate-900 leading-tight">Créer une Nouvelle Annexe</h3>
                  <p className="text-xs text-slate-500 font-medium">Auto-École Saint Edmond • Expansion</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setModalType(null)}
                className="w-9 h-9 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition flex items-center justify-center cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-6 space-y-4">
              <p className="text-xs text-slate-500 bg-blue-50/60 border border-blue-200/60 rounded-xl p-3 leading-relaxed">
                Le siège principal officiel est <strong>Tokoin Ramco (Siège)</strong>. Vous pouvez enregistrer ici les nouvelles annexes de l'auto-école dès leur mise en service.
              </p>

              <form onSubmit={handleAddAnnexe} className="space-y-4">
                <div className="space-y-1.5">
                  <label className="block text-xs font-bold text-slate-700">
                    Nom de l'Annexe / Quartier *
                  </label>
                  <input
                    type="text"
                    required
                    value={newAnnexeName}
                    onChange={(e) => setNewAnnexeName(e.target.value)}
                    className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3.5 py-2.5 text-sm font-semibold text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition"
                  />
                </div>

                <div className="pt-3 flex items-center justify-end gap-3 border-t border-slate-100">
                  <button
                    type="button"
                    onClick={() => setModalType(null)}
                    className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                  >
                    Annuler
                  </button>
                  <button
                    type="submit"
                    className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-lg shadow-blue-600/25 flex items-center gap-2 transition cursor-pointer"
                  >
                    <CheckCircle2 className="w-4 h-4" />
                    <span>Créer l'Annexe</span>
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
