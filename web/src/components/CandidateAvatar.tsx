import React, { useState, useRef, useEffect } from 'react';
import { Camera, Upload, Trash2, X, RefreshCw, Check } from 'lucide-react';
import type { Sexe } from '../types';

interface CandidateAvatarProps {
  sexe?: Sexe;
  photoUrl?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  editable?: boolean;
  onPhotoChange?: (newPhotoUrl: string | undefined) => void;
  className?: string;
}

export const CandidateAvatar: React.FC<CandidateAvatarProps> = ({
  sexe = 'MASCULIN',
  photoUrl,
  size = 'md',
  editable = false,
  onPhotoChange,
  className = '',
}) => {
  const [modalOpen, setModalOpen] = useState(false);
  const [cameraActive, setCameraActive] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [capturedPreview, setCapturedPreview] = useState<string | null>(null);

  const videoRef = useRef<HTMLVideoElement | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  const isFeminin = sexe === 'FEMININ';

  // Dimension mapping
  const sizeClasses = {
    sm: 'w-10 h-10',
    md: 'w-16 h-16',
    lg: 'w-24 h-24',
    xl: 'w-32 h-32',
  }[size];

  const cameraIconSize = {
    sm: 'w-3 h-3',
    md: 'w-4 h-4',
    lg: 'w-5 h-5',
    xl: 'w-6 h-6',
  }[size];

  // Stop video stream safely
  const stopStream = () => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((t) => t.stop());
      streamRef.current = null;
    }
    setCameraActive(false);
  };

  useEffect(() => {
    return () => {
      stopStream();
    };
  }, []);

  // Start webcam
  const startCamera = async () => {
    setCameraError(null);
    setCapturedPreview(null);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'user', width: { ideal: 640 }, height: { ideal: 640 } },
        audio: false,
      });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.play();
      }
      setCameraActive(true);
    } catch (err: any) {
      console.error('Erreur accès caméra:', err);
      setCameraError(
        'Impossible d\'accéder à la caméra. Vérifiez les permissions de votre navigateur ou utilisez "Joindre une photo".'
      );
    }
  };

  // Capture frame from video
  const capturePhoto = () => {
    if (!videoRef.current) return;
    const canvas = document.createElement('canvas');
    const width = videoRef.current.videoWidth || 480;
    const height = videoRef.current.videoHeight || 480;
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.drawImage(videoRef.current, 0, 0, width, height);
    const dataUrl = canvas.toDataURL('image/jpeg', 0.85);
    setCapturedPreview(dataUrl);
    stopStream();
  };

  // Handle local file upload
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      alert('Veuillez sélectionner un fichier image valide (JPG, PNG).');
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result as string;
      if (onPhotoChange) {
        onPhotoChange(result);
      }
      setModalOpen(false);
    };
    reader.readAsDataURL(file);
  };

  const confirmCapturedPhoto = () => {
    if (capturedPreview && onPhotoChange) {
      onPhotoChange(capturedPreview);
    }
    setCapturedPreview(null);
    setModalOpen(false);
  };

  const removePhoto = () => {
    if (onPhotoChange) {
      onPhotoChange(undefined);
    }
    setCapturedPreview(null);
    stopStream();
    setModalOpen(false);
  };

  return (
    <>
      <div className={`relative inline-block ${className}`}>
        {/* Main Avatar Container */}
        <div
          className={`${sizeClasses} rounded-full overflow-hidden bg-slate-100 border-2 border-slate-200/90 shadow-sm flex items-center justify-center relative cursor-pointer group`}
          onClick={() => editable && setModalOpen(true)}
          title={editable ? 'Cliquer pour ajouter ou modifier la photo' : undefined}
        >
          {photoUrl ? (
            <img
              src={photoUrl}
              alt="Photo candidat"
              className="w-full h-full object-cover"
            />
          ) : isFeminin ? (
            /* ================= AVATAR FEMININ ================= */
            <svg
              viewBox="0 0 120 120"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              className="w-full h-full"
            >
              <circle cx="60" cy="60" r="58" fill="#FDF2F4" />
              {/* Cheveux arrière */}
              <path
                d="M32 46C32 26 44 14 60 14C76 14 88 26 88 46C88 66 84 82 82 88C78 78 76 68 76 68L44 68C44 68 42 78 38 88C36 82 32 66 32 46Z"
                fill="#D97706"
              />
              {/* Cou */}
              <path d="M52 64H68V78H52V64Z" fill="#FBD5B5" />
              {/* Visage */}
              <path
                d="M40 44C40 32 48 24 60 24C72 24 80 32 80 44C80 58 71 68 60 68C49 68 40 58 40 44Z"
                fill="#FED7AA"
              />
              {/* Cheveux avant & frange */}
              <path
                d="M40 40C42 28 50 20 60 20C70 20 78 28 80 40C74 34 66 32 60 35C54 32 46 34 40 40Z"
                fill="#B45309"
              />
              <path
                d="M34 50C34 62 38 74 42 80C40 70 38 58 38 50H34Z"
                fill="#B45309"
              />
              <path
                d="M86 50C86 62 82 74 78 80C80 70 82 58 82 50H86Z"
                fill="#B45309"
              />
              {/* Vêtement féminin (tailleur / chemisier) */}
              <path
                d="M26 112C26 94 38 80 54 78L60 84L66 78C82 80 94 94 94 112H26Z"
                fill="#0284C7"
              />
              {/* Col / Chemisier blanc */}
              <path
                d="M52 78L60 92L68 78L60 84L52 78Z"
                fill="#FFFFFF"
              />
              {/* Veste tailleur contrastée */}
              <path
                d="M26 112C28 98 38 86 48 82L54 112H26Z"
                fill="#0369A1"
              />
              <path
                d="M94 112C92 98 82 86 72 82L66 112H94Z"
                fill="#0369A1"
              />
            </svg>
          ) : (
            /* ================= AVATAR MASCULIN ================= */
            <svg
              viewBox="0 0 120 120"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              className="w-full h-full"
            >
              <circle cx="60" cy="60" r="58" fill="#F0F9FF" />
              {/* Cou */}
              <path d="M51 62H69V78H51V62Z" fill="#FBD5B5" />
              {/* Visage */}
              <path
                d="M40 42C40 30 48 22 60 22C72 22 80 30 80 42C80 56 71 66 60 66C49 66 40 56 40 42Z"
                fill="#FED7AA"
              />
              {/* Cheveux courts soignés */}
              <path
                d="M38 38C38 24 46 16 60 16C74 16 82 24 82 38C82 39 80 34 77 32C72 28 66 28 60 28C54 28 48 28 43 32C40 34 38 39 38 38Z"
                fill="#1E293B"
              />
              <path
                d="M39 36C40 44 42 48 42 48C40 44 38 40 39 36Z"
                fill="#1E293B"
              />
              <path
                d="M81 36C80 44 78 48 78 48C80 44 82 40 81 36Z"
                fill="#1E293B"
              />
              {/* Costume veste sombre (comme sur la capture) */}
              <path
                d="M24 112C24 92 36 78 52 76L60 84L68 76C84 78 96 92 96 112H24Z"
                fill="#0F172A"
              />
              {/* Chemise col blanc */}
              <path
                d="M50 76L60 92L70 76L64 74L60 78L56 74L50 76Z"
                fill="#FFFFFF"
              />
              {/* Cravate bleue élégante */}
              <path
                d="M58 80L62 80L63 98L60 102L57 98L58 80Z"
                fill="#2563EB"
              />
              {/* Revers de la veste */}
              <path
                d="M24 112C26 96 36 84 48 80L54 112H24Z"
                fill="#1E293B"
              />
              <path
                d="M96 112C94 96 84 84 72 80L66 112H96Z"
                fill="#1E293B"
              />
            </svg>
          )}

          {/* Hover overlay if editable */}
          {editable && (
            <div className="absolute inset-0 bg-black/30 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center rounded-full">
              <Camera className="w-5 h-5 text-white drop-shadow" />
            </div>
          )}
        </div>

        {/* Camera badge icon (comme sur la capture) */}
        {editable && (
          <button
            type="button"
            onClick={() => setModalOpen(true)}
            className="absolute bottom-0 right-0 bg-blue-600 hover:bg-blue-700 text-white p-1 rounded-full border-2 border-white shadow-md transition transform hover:scale-110 flex items-center justify-center cursor-pointer"
            title="Prendre ou joindre une photo"
          >
            <Camera className={cameraIconSize} />
          </button>
        )}
      </div>

      {/* Hidden File Input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={handleFileChange}
      />

      {/* ================= MODAL PHOTO / CAMÉRA ================= */}
      {modalOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md p-6 shadow-2xl space-y-4 animate-in fade-in zoom-in-95 duration-150">
            {/* Header */}
            <div className="flex items-center justify-between border-b pb-3">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-xl bg-blue-100 text-blue-700 flex items-center justify-center">
                  <Camera className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-bold text-base text-slate-800">Photo du Candidat</h3>
                  <p className="text-xs text-slate-500">
                    {isFeminin ? 'Profil Féminin' : 'Profil Masculin'} • Caméra ou fichier
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => {
                  stopStream();
                  setCapturedPreview(null);
                  setModalOpen(false);
                }}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Video / Preview Area */}
            <div className="relative w-full aspect-square max-w-[280px] mx-auto rounded-2xl overflow-hidden bg-slate-900 border-2 border-slate-200 shadow-inner flex items-center justify-center">
              {capturedPreview ? (
                <img
                  src={capturedPreview}
                  alt="Aperçu capture"
                  className="w-full h-full object-cover"
                />
              ) : cameraActive ? (
                <video
                  ref={videoRef}
                  autoPlay
                  playsInline
                  muted
                  className="w-full h-full object-cover scale-x-[-1]"
                />
              ) : photoUrl ? (
                <img
                  src={photoUrl}
                  alt="Photo actuelle"
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-40 h-40">
                  <CandidateAvatar sexe={sexe} size="xl" editable={false} />
                </div>
              )}

              {/* Guide oval overlay when camera is running */}
              {cameraActive && !capturedPreview && (
                <div className="absolute inset-4 border-2 border-dashed border-white/60 rounded-full pointer-events-none" />
              )}
            </div>

            {/* Error Message */}
            {cameraError && (
              <div className="p-3 bg-rose-50 border border-rose-200 text-rose-700 text-xs rounded-xl">
                {cameraError}
              </div>
            )}

            {/* Actions Buttons */}
            <div className="space-y-2 pt-2">
              {capturedPreview ? (
                /* Confirmation de la capture */
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={startCamera}
                    className="py-2.5 px-3 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs rounded-xl flex items-center justify-center gap-1.5 transition"
                  >
                    <RefreshCw className="w-4 h-4" />
                    <span>Reprendre</span>
                  </button>
                  <button
                    type="button"
                    onClick={confirmCapturedPhoto}
                    className="py-2.5 px-3 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-xl flex items-center justify-center gap-1.5 shadow-md shadow-emerald-600/30 transition"
                  >
                    <Check className="w-4 h-4" />
                    <span>Valider cette photo</span>
                  </button>
                </div>
              ) : cameraActive ? (
                /* Bouton pour déclencher la capture */
                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={capturePhoto}
                    className="flex-1 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm rounded-xl flex items-center justify-center gap-2 shadow-lg shadow-blue-600/30 transition"
                  >
                    <Camera className="w-4 h-4" />
                    <span>Prendre la photo maintenant</span>
                  </button>
                  <button
                    type="button"
                    onClick={stopStream}
                    className="py-3 px-4 bg-slate-100 hover:bg-slate-200 text-slate-600 font-semibold text-xs rounded-xl"
                  >
                    Arrêter
                  </button>
                </div>
              ) : (
                /* Choix initial : Caméra ou Joindre un fichier */
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={startCamera}
                    className="py-3 px-3 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-xl flex items-center justify-center gap-2 shadow-md shadow-blue-600/25 transition"
                  >
                    <Camera className="w-4 h-4" />
                    <span>Prendre photo (Caméra)</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => fileInputRef.current?.click()}
                    className="py-3 px-3 bg-slate-100 hover:bg-slate-200 text-slate-800 font-bold text-xs rounded-xl flex items-center justify-center gap-2 border border-slate-200 transition"
                  >
                    <Upload className="w-4 h-4 text-slate-600" />
                    <span>Joindre un fichier</span>
                  </button>
                </div>
              )}

              {/* Bouton supprimer photo (si photoUrl existe) */}
              {(photoUrl || capturedPreview) && (
                <button
                  type="button"
                  onClick={removePhoto}
                  className="w-full py-2 text-xs text-rose-600 hover:bg-rose-50 rounded-xl font-semibold flex items-center justify-center gap-1.5 transition"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                  <span>Revenir à l'avatar par défaut ({isFeminin ? 'Femme' : 'Homme'})</span>
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
};
