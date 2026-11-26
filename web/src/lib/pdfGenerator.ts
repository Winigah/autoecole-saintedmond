import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import type { Candidat, BilanMois } from '../types';
import { SAINT_EDMOND_LOGO_BASE64 } from './logoBase64';

/**
 * Helpers de formatage monétaire avec espace standard ASCII (code 32)
 * Garanti sans espaces insécables Unicode (qui se transformaient en '/' dans Helvetica sous jsPDF).
 */
export const formatMontant = (val: number): string => {
  return (val || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
};

export const formatFCFA = (val: number): string => {
  return `${formatMontant(val)} FCFA`;
};

export const generateCandidatsPDF = (
  candidats: Candidat[],
  titre: string = 'Liste des Candidats',
  autoEcole: string = 'Auto-École Saint Edmond'
) => {
  const doc = new jsPDF();

  // Logo officiel
  try {
    doc.addImage(SAINT_EDMOND_LOGO_BASE64, 'PNG', 14, 12, 18, 18);
  } catch (e) {
    console.warn('Logo introuvable pour le PDF:', e);
  }

  // Entête
  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(29, 78, 216);
  doc.text(autoEcole, 36, 19);

  doc.setFontSize(12);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(30, 41, 59);
  doc.text(titre, 36, 26);

  doc.setFontSize(9);
  doc.setTextColor(100, 116, 139);
  doc.text(`Document officiel généré le ${new Date().toLocaleDateString('fr-FR')} à ${new Date().toLocaleTimeString('fr-FR')}`, 36, 32);

  const tableData = candidats.map((c, i) => [
    (i + 1).toString(),
    `${c.nom} ${c.prenom}`,
    c.contact,
    c.annexe,
    c.categorie,
    `${formatMontant(c.montant_paye)} / ${formatMontant(c.montant_total)} F`,
    c.statut,
  ]);

  autoTable(doc, {
    startY: 38,
    head: [['#', 'Nom & Prénom', 'Contact', 'Annexe', 'Permis', 'Scolarité', 'Statut']],
    body: tableData,
    theme: 'striped',
    headStyles: { fillColor: [29, 78, 216], textColor: 255 },
    styles: { fontSize: 9 },
  });

  doc.save(`${titre.toLowerCase().replace(/\s+/g, '_')}_${Date.now()}.pdf`);
};

export interface PresenceItemExport {
  nom: string;
  prenom: string;
  contact: string;
  annexe: string;
  categorie: string;
  discipline: string;
  present: boolean;
  heurePointage?: string;
}

export const generatePresencePDF = (
  items: PresenceItemExport[],
  date: string,
  heure: string,
  typeSeance: string,
  annexe: string = 'Toutes',
  autoEcole: string = 'Auto-École Saint Edmond'
) => {
  const doc = new jsPDF();

  // Logo officiel
  try {
    doc.addImage(SAINT_EDMOND_LOGO_BASE64, 'PNG', 14, 12, 18, 18);
  } catch (e) {
    console.warn('Logo introuvable pour le PDF:', e);
  }

  // Entête
  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(29, 78, 216);
  doc.text(autoEcole, 36, 19);

  doc.setFontSize(12);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(30, 41, 59);
  doc.text(`Feuille d'Émargement & Présence des Élèves (${typeSeance})`, 36, 26);

  doc.setFontSize(9);
  doc.setTextColor(100, 116, 139);
  doc.text(`Séance du ${date} à ${heure} | Annexe : ${annexe} | Registre officiel certifié`, 36, 32);

  const tableData = items.map((c, i) => [
    (i + 1).toString(),
    `${c.nom} ${c.prenom}`,
    c.contact,
    c.annexe,
    `Cat. ${c.categorie}`,
    c.discipline,
    c.present ? `PRÉSENT (${c.heurePointage || heure})` : 'ABSENT',
  ]);

  autoTable(doc, {
    startY: 38,
    head: [['#', 'Nom & Prénom', 'Contact', 'Annexe', 'Permis', 'Discipline', 'Émargement']],
    body: tableData,
    theme: 'striped',
    headStyles: { fillColor: [15, 23, 42], textColor: 255 },
    styles: { fontSize: 9 },
    didParseCell: (data) => {
      if (data.section === 'body' && data.column.index === 6) {
        if (data.cell.raw && String(data.cell.raw).startsWith('PRÉSENT')) {
          data.cell.styles.textColor = [22, 101, 52];
          data.cell.styles.fontStyle = 'bold';
        } else {
          data.cell.styles.textColor = [153, 27, 27];
        }
      }
    }
  });

  const finalY = (doc as any).lastAutoTable ? (doc as any).lastAutoTable.finalY + 14 : 220;
  if (finalY < 255) {
    doc.setFontSize(8.5);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(30, 41, 59);
    doc.text('Visa & Signature du Formateur / Moniteur :', 14, finalY);
    doc.text('Pour l\'Administration de l\'Auto-École :', 115, finalY);
    doc.setDrawColor(203, 213, 225);
    doc.roundedRect(14, finalY + 3, 80, 20, 2, 2, 'D');
    doc.roundedRect(115, finalY + 3, 80, 20, 2, 2, 'D');
  }

  doc.save(`feuille_presence_eleves_${date.replace(/-/g, '')}_${Date.now()}.pdf`);
};

export const generateBilanPDF = (
  bilans: BilanMois[],
  totalRevenus: number,
  totalDepenses: number,
  soldeNet: number,
  autoEcole: string = 'Auto-École Saint Edmond'
) => {
  const doc = new jsPDF();

  // Logo officiel
  try {
    doc.addImage(SAINT_EDMOND_LOGO_BASE64, 'PNG', 14, 12, 18, 18);
  } catch (e) {
    console.warn('Logo introuvable pour le PDF:', e);
  }

  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(29, 78, 216);
  doc.text(autoEcole, 36, 19);

  doc.setFontSize(12);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(30, 41, 59);
  doc.text('Rapport Financier & Bilan d\'Exploitation', 36, 26);

  doc.setFontSize(9);
  doc.setTextColor(100, 116, 139);
  doc.text(`Période 2026 - Certifié conforme le ${new Date().toLocaleDateString('fr-FR')}`, 36, 32);

  const tableData = bilans.map(b => [
    b.mois,
    formatFCFA(b.revenus),
    formatFCFA(b.depenses),
    formatFCFA(b.solde),
  ]);

  tableData.push([
    'TOTAL CUMULÉ',
    formatFCFA(totalRevenus),
    formatFCFA(totalDepenses),
    formatFCFA(soldeNet),
  ]);

  autoTable(doc, {
    startY: 44,
    head: [['Période', 'Revenus (Entrées)', 'Dépenses (Sorties)', 'Solde Net']],
    body: tableData,
    theme: 'grid',
    headStyles: { fillColor: [15, 23, 42], textColor: 255 },
    styles: { fontSize: 10 },
  });

  doc.save(`bilan_financier_${Date.now()}.pdf`);
};

/**
 * Génère un reçu d'inscription PDF professionnel et officiel pour un candidat.
 */
export const generateRecuCandidatPDF = (
  candidat: Candidat,
  autoEcole: string = 'Auto-École Saint Edmond',
  annexe: string = 'TOKOIN RAMCO (Siège)'
) => {
  const doc = new jsPDF({ unit: 'mm', format: 'a4' });
  const pageW = doc.internal.pageSize.getWidth();
  const pageH = doc.internal.pageSize.getHeight();
  const now = new Date();
  const dateStr = now.toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' });
  const heureStr = now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
  const numeroRecu = `REC-${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}${String(candidat.id).padStart(4, '0')}`;
  const montantRestant = candidat.montant_total - candidat.montant_paye;
  const estSolde = montantRestant <= 0;

  // ── Cadre extérieur de sécurité ─────────────────────────────
  doc.setDrawColor(203, 213, 225); // Slate 300
  doc.setLineWidth(0.4);
  doc.rect(8, 8, pageW - 16, pageH - 16);

  // ── Bandeau en-tête bleu marine ──────────────────────────────
  doc.setFillColor(15, 32, 68); // Bleu marine officiel
  doc.rect(8, 8, pageW - 16, 38, 'F');

  // Liseré or d'accent sous le bandeau
  doc.setFillColor(217, 119, 6); // Ambre / Or
  doc.rect(8, 46, pageW - 16, 1.5, 'F');

  // Boîte blanche avec logo officiel de l'entreprise
  doc.setFillColor(255, 255, 255);
  doc.roundedRect(12, 11, 28, 28, 2, 2, 'F');
  try {
    doc.addImage(SAINT_EDMOND_LOGO_BASE64, 'PNG', 13, 12, 26, 26);
  } catch (e) {
    console.warn('Logo introuvable pour le PDF:', e);
  }

  // Titre Auto-École & Coordonnées à droite du logo (5 lignes aérées)
  doc.setTextColor(255, 255, 255);
  doc.setFontSize(15);
  doc.setFont('helvetica', 'bold');
  doc.text(autoEcole.toUpperCase(), 43, 17.5);

  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(191, 219, 254);
  doc.text('AGRÉMENT N° 036/MTRAF/META   |   RCCM : TG-LOM 2018 A 4273', 43, 23.5);
  doc.text(`NIF : 1001269763   |   Annexe : ${annexe}`, 43, 29);
  doc.text('Von LG Shoppe Ramco, face Consulat Belgique, Lomé', 43, 34.5);
  doc.text('Tél : +228 91 88 02 75 / 93 61 65 57   |   saintedmondofficiel@gmail.com', 43, 40);

  // Bloc REÇU OFFICIEL (Droite de l'en-tête)
  doc.setFillColor(255, 255, 255);
  doc.roundedRect(pageW - 64, 11, 52, 28, 2, 2, 'F');

  doc.setTextColor(15, 32, 68);
  doc.setFontSize(12.5);
  doc.setFont('helvetica', 'bold');
  doc.text('REÇU OFFICIEL', pageW - 38, 18, { align: 'center' });

  doc.setFontSize(8.5);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(37, 99, 235);
  doc.text(`N° ${numeroRecu}`, pageW - 38, 24.5, { align: 'center' });

  doc.setFont('helvetica', 'normal');
  doc.setFontSize(7.5);
  doc.setTextColor(100, 116, 139);
  doc.text(`Date : ${dateStr}`, pageW - 38, 31, { align: 'center' });
  doc.text(`à ${heureStr}`, pageW - 38, 35.5, { align: 'center' });

  // ── Section 1 : INFORMATIONS DU CANDIDAT ─────────────────────
  let curY = 53;

  // Titre de section avec barre latérale
  doc.setFillColor(37, 99, 235);
  doc.rect(12, curY, 3, 7, 'F');
  doc.setFontSize(11);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text('FICHE ET IDENTIFICATION DU CANDIDAT', 18, curY + 5.5);

  curY += 10;

  // Boîte grise contenant les données
  doc.setDrawColor(226, 232, 240);
  doc.setFillColor(248, 250, 252);
  doc.roundedRect(12, curY, pageW - 24, 46, 2, 2, 'FD');

  const c1LabelX = 16;
  const c1ValX = 56;
  const c2LabelX = pageW / 2 + 4;
  const c2ValX = pageW / 2 + 44;

  const rowH = 7.5;
  const startRowY = curY + 7;

  // Ligne 1
  doc.setFontSize(9);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(100, 116, 139);
  doc.text('Nom & Prénom :', c1LabelX, startRowY);
  doc.text('Annexe :', c2LabelX, startRowY);

  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text(`${candidat.nom} ${candidat.prenom}`, c1ValX, startRowY);
  doc.setFont('helvetica', 'normal');
  doc.text(candidat.annexe, c2ValX, startRowY);

  // Ligne 2
  const r2Y = startRowY + rowH;
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(100, 116, 139);
  doc.text('Contact :', c1LabelX, r2Y);
  doc.text('Permis visé :', c2LabelX, r2Y);

  doc.setFont('helvetica', 'normal');
  doc.setTextColor(15, 32, 68);
  doc.text(candidat.contact, c1ValX, r2Y);
  doc.setFont('helvetica', 'bold');
  doc.text(`Catégorie ${candidat.categorie}`, c2ValX, r2Y);

  // Ligne 3
  const r3Y = startRowY + rowH * 2;
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(100, 116, 139);
  doc.text('Adresse / Ville :', c1LabelX, r3Y);
  doc.text('Langue de cours :', c2LabelX, r3Y);

  doc.setFont('helvetica', 'normal');
  doc.setTextColor(15, 32, 68);
  doc.text(candidat.adresse && candidat.adresse.trim() ? candidat.adresse : 'Lomé, Togo', c1ValX, r3Y);
  doc.text(candidat.langue, c2ValX, r3Y);

  // Ligne 4
  const r4Y = startRowY + rowH * 3;
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(100, 116, 139);
  doc.text('Date d\'inscription :', c1LabelX, r4Y);
  doc.text('Durée de formation :', c2LabelX, r4Y);

  doc.setFont('helvetica', 'normal');
  doc.setTextColor(15, 32, 68);
  const dInscription = new Date(candidat.date_inscription).toLocaleDateString('fr-FR');
  doc.text(dInscription, c1ValX, r4Y);
  doc.text(`${candidat.duree_formation_mois || 3} mois`, c2ValX, r4Y);

  // Ligne 5
  const r5Y = startRowY + rowH * 4;
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(100, 116, 139);
  doc.text('Sexe du candidat :', c1LabelX, r5Y);
  doc.text('Code App Candidat :', c2LabelX, r5Y);

  doc.setFont('helvetica', 'normal');
  doc.setTextColor(15, 32, 68);
  doc.text(candidat.sexe === 'FEMININ' ? 'Féminin' : 'Masculin', c1ValX, r5Y);

  // Badge du code App
  if (candidat.code_acces) {
    doc.setFillColor(238, 242, 255);
    doc.setDrawColor(199, 210, 254);
    doc.roundedRect(c2ValX - 2, r5Y - 4.5, 38, 6.5, 1.5, 1.5, 'FD');
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(67, 56, 202);
    doc.setFontSize(9);
    doc.text(candidat.code_acces, c2ValX + 17, r5Y, { align: 'center' });
  } else {
    doc.text('Non généré', c2ValX, r5Y);
  }

  // ── Section 2 : DÉTAIL DU PAIEMENT ───────────────────────────
  curY += 54;

  doc.setFillColor(37, 99, 235);
  doc.rect(12, curY, 3, 7, 'F');
  doc.setFontSize(11);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text('RÈGLEMENT FINANCIER DE LA FORMATION', 18, curY + 5.5);

  curY += 9;

  // Tableau AutoTable bien net
  autoTable(doc, {
    startY: curY,
    margin: { left: 12, right: 12 },
    head: [['Désignation des prestations', 'Montant en FCFA']],
    body: [
      ['Frais de Formation', formatFCFA(candidat.montant_total)],
      ['Montant payé', formatFCFA(candidat.montant_paye)],
      ['Solde restant', estSolde ? '0 FCFA  (SOLDÉ)' : formatFCFA(montantRestant)],
    ],
    theme: 'grid',
    headStyles: {
      fillColor: [15, 32, 68],
      textColor: 255,
      fontSize: 9.5,
      fontStyle: 'bold',
      halign: 'left',
    },
    bodyStyles: {
      fontSize: 9.5,
      cellPadding: 3.5,
    },
    columnStyles: {
      0: { cellWidth: 'auto', fontStyle: 'normal' },
      1: { cellWidth: 55, halign: 'right', fontStyle: 'bold' },
    },
    didParseCell(data) {
      if (data.row.index === 1 && data.column.index === 1) {
        data.cell.styles.textColor = [22, 163, 74]; // Vert émeraude
      }
      if (data.row.index === 2 && data.column.index === 1) {
        data.cell.styles.textColor = estSolde ? [22, 163, 74] : [220, 38, 38]; // Vert si soldé, Rouge si reste
      }
    },
  });

  const tableEnd = (doc as any).lastAutoTable.finalY;
  curY = tableEnd + 8;

  // ── Section 3 : BADGE DE STATUT DU PAIEMENT ──────────────────
  if (estSolde) {
    doc.setFillColor(240, 253, 244);
    doc.setDrawColor(187, 247, 208);
    doc.roundedRect(12, curY, pageW - 24, 16, 2, 2, 'FD');

    doc.setFontSize(10.5);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(22, 101, 52);
    doc.text('ATTESTATION : SCOLARITÉ ENTIÈREMENT RÉGLÉE (SOLDÉ)', pageW / 2, curY + 6.5, { align: 'center' });

    doc.setFontSize(8.5);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(21, 128, 61);
    doc.text('Le candidat est en règle avec l\'ensemble des frais de formation de l\'auto-école.', pageW / 2, curY + 12, { align: 'center' });
  } else {
    doc.setFillColor(254, 243, 199);
    doc.setDrawColor(253, 230, 138);
    doc.roundedRect(12, curY, pageW - 24, 16, 2, 2, 'FD');

    doc.setFontSize(10);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(146, 64, 14);
    doc.text(`RAPPEL : SOLDE RESTANT DE ${formatFCFA(montantRestant)}`, pageW / 2, curY + 6.5, { align: 'center' });

    doc.setFontSize(8.5);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(180, 83, 9);
    doc.text('Tout solde restant doit être intégralement versé avant toute réception du dossier d\'examen de permis.', pageW / 2, curY + 12, { align: 'center' });
  }

  curY += 22;

  // ── Section 4 : CONDITIONS ET RÈGLEMENT PÉDAGOGIQUE ───────────
  doc.setFillColor(248, 250, 252);
  doc.setDrawColor(226, 232, 240);
  doc.roundedRect(12, curY, pageW - 24, 28, 2, 2, 'FD');

  doc.setFontSize(8.5);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text('CONDITIONS GÉNÉRALES ET ENGAGEMENTS DU CANDIDAT :', 16, curY + 5.5);

  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(71, 85, 105);
  doc.text('1. Le présent document certifie l\'inscription régulière du candidat au registre officiel de l\'auto-école.', 16, curY + 10.5);
  doc.text('2. Toute absence au cours doit être signalé à l\'avance.', 16, curY + 15.5);
  doc.text('3. Le candidat peut accéder à son espace de révision sur l\'application mobile Saint Edmond Candidat avec son identifiant reçu à la Direction.', 16, curY + 20.5);

  // Mention formelle de validité & non-remboursement
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(7.5);
  doc.setTextColor(185, 28, 28); // Rouge bordeaux officiel
  doc.text('NB : Le présent reçu est valable pour 03 mois et n\'est en aucun cas remboursable.', 16, curY + 25.5);

  curY += 34;

  // ── Section 5 : SIGNATURE ET CACHET OFFICIEL ──────────────
  const signBoxH = 34;

  // Boîte Administration uniquement (pleine largeur)
  doc.setDrawColor(203, 213, 225);
  doc.setFillColor(255, 255, 255);
  doc.roundedRect(12, curY, pageW - 24, signBoxH, 2, 2, 'D');

  doc.setFontSize(8.5);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text('Par l\'Administration de l\'Auto-École', pageW / 2, curY + 6, { align: 'center' });
  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(100, 116, 139);
  doc.text('(Cachet officiel et Signature)', pageW / 2, curY + 11, { align: 'center' });

  // ── Pied de page sécurisé ────────────────────────────────────
  const footY = pageH - 14;
  doc.setFillColor(15, 32, 68);
  doc.rect(8, footY, pageW - 16, 8, 'F');

  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(191, 219, 254);
  doc.text(
    `Document officiel délivré par ${autoEcole}  |  Agrément N° 036/MTRAF/META  |  Vérification N° ${numeroRecu}`,
    pageW / 2,
    footY + 5.2,
    { align: 'center' }
  );

  doc.save(`recu_inscription_${candidat.nom}_${candidat.prenom}_${Date.now()}.pdf`);
};

/**
 * Génère un reçu officiel PDF pour l'achat de séances de conduite supplémentaires.
 */
export const generateRecuSupplementConduitePDF = (
  candidat: Candidat,
  nbSeances: number,
  montantSupplement: number,
  montantVerse: number,
  modePaiement: string = 'Espèces',
  motif: string = 'Perfectionnement & Pratique additionnelle',
  autoEcole: string = 'Auto-École Saint Edmond',
  annexe: string = 'TOKOIN RAMCO (Siège)'
) => {
  const doc = new jsPDF({ unit: 'mm', format: 'a4' });
  const pageW = doc.internal.pageSize.getWidth();
  const pageH = doc.internal.pageSize.getHeight();
  const now = new Date();
  const dateStr = now.toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' });
  const heureStr = now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
  const numeroRecu = `SUPP-${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}${String(candidat.id).padStart(3, '0')}-${nbSeances}S`;
  const resteSupplement = montantSupplement - montantVerse;
  const estSolde = resteSupplement <= 0;

  // ── Cadre extérieur de sécurité ─────────────────────────────
  doc.setDrawColor(203, 213, 225);
  doc.setLineWidth(0.4);
  doc.rect(8, 8, pageW - 16, pageH - 16);

  // ── Bandeau en-tête bleu marine ──────────────────────────────
  doc.setFillColor(15, 32, 68);
  doc.rect(8, 8, pageW - 16, 38, 'F');

  // Liseré or d'accent sous le bandeau
  doc.setFillColor(217, 119, 6);
  doc.rect(8, 46, pageW - 16, 1.5, 'F');

  // Boîte blanche avec logo officiel de l'entreprise
  doc.setFillColor(255, 255, 255);
  doc.roundedRect(12, 11, 28, 28, 2, 2, 'F');
  try {
    doc.addImage(SAINT_EDMOND_LOGO_BASE64, 'PNG', 13, 12, 26, 26);
  } catch (e) {
    console.warn('Logo introuvable pour le PDF:', e);
  }

  // Titre Auto-École & Coordonnées à droite du logo (5 lignes aérées)
  doc.setTextColor(255, 255, 255);
  doc.setFontSize(15);
  doc.setFont('helvetica', 'bold');
  doc.text(autoEcole.toUpperCase(), 43, 17.5);

  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(191, 219, 254);
  doc.text('AGRÉMENT N° 036/MTRAF/META   |   RCCM : TG-LOM 2018 A 4273', 43, 23.5);
  doc.text(`NIF : 1001269763   |   Annexe : ${annexe}`, 43, 29);
  doc.text('Von LG Shoppe Ramco, face Consulat Belgique, Lomé', 43, 34.5);
  doc.text('Tél : +228 91 88 02 75 / 93 61 65 57   |   saintedmondofficiel@gmail.com', 43, 40);

  // Bloc REÇU OFFICIEL (Droite de l'en-tête)
  doc.setFillColor(255, 255, 255);
  doc.roundedRect(pageW - 64, 11, 52, 28, 2, 2, 'F');

  doc.setTextColor(15, 32, 68);
  doc.setFontSize(10.5);
  doc.setFont('helvetica', 'bold');
  doc.text('SÉANCES CONDUITE', pageW - 38, 17, { align: 'center' });
  doc.setFontSize(8);
  doc.setTextColor(217, 119, 6);
  doc.text('REÇU SUPPLÉMENT', pageW - 38, 22, { align: 'center' });

  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(37, 99, 235);
  doc.text(`N° ${numeroRecu}`, pageW - 38, 27.5, { align: 'center' });

  doc.setFont('helvetica', 'normal');
  doc.setFontSize(7);
  doc.setTextColor(100, 116, 139);
  doc.text(`Date : ${dateStr}`, pageW - 38, 33, { align: 'center' });
  doc.text(`à ${heureStr}`, pageW - 38, 36.5, { align: 'center' });

  let curY = 53;

  // ── Section 1 : IDENTITÉ DU CANDIDAT ──────────────────────────
  doc.setFillColor(37, 99, 235);
  doc.rect(12, curY, 3, 7, 'F');
  doc.setFontSize(11);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text('INFORMATIONS DU CANDIDAT', 18, curY + 5.5);

  curY += 9;

  doc.setFillColor(248, 250, 252);
  doc.setDrawColor(226, 232, 240);
  doc.roundedRect(12, curY, pageW - 24, 32, 2, 2, 'FD');

  const c1LabelX = 16;
  const c1ValX = 52;
  const c2LabelX = pageW / 2 + 6;
  const c2ValX = pageW / 2 + 54;

  const r1Y = curY + 7;
  const r2Y = curY + 15;
  const r3Y = curY + 23;

  doc.setFontSize(8.5);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(71, 85, 105);
  doc.text('Nom & Prénom :', c1LabelX, r1Y);
  doc.text('Téléphone / Contact :', c1LabelX, r2Y);
  doc.text('Permis / Catégorie :', c1LabelX, r3Y);

  doc.setFont('helvetica', 'normal');
  doc.setTextColor(15, 32, 68);
  doc.setFont('helvetica', 'bold');
  doc.text(`${candidat.nom} ${candidat.prenom}`, c1ValX, r1Y);
  doc.setFont('helvetica', 'normal');
  doc.text(candidat.contact, c1ValX, r2Y);
  doc.text(`Permis Catégorie ${candidat.categorie}`, c1ValX, r3Y);

  doc.setFont('helvetica', 'bold');
  doc.setTextColor(71, 85, 105);
  doc.text('Annexe :', c2LabelX, r1Y);
  doc.text('Mode de Règlement :', c2LabelX, r2Y);
  doc.text('Code App Candidat :', c2LabelX, r3Y);

  doc.setFont('helvetica', 'normal');
  doc.setTextColor(15, 32, 68);
  doc.text(candidat.annexe, c2ValX, r1Y);
  doc.text(modePaiement, c2ValX, r2Y);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(67, 56, 202);
  doc.text(candidat.code_acces || 'N/A', c2ValX, r3Y);

  curY += 38;

  // ── Section 2 : PRESTATION ET SÉANCES DE CONDUITE ─────────────
  doc.setFillColor(37, 99, 235);
  doc.rect(12, curY, 3, 7, 'F');
  doc.setFontSize(11);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text('DÉTAIL DU SUPPLÉMENT DE CONDUITE', 18, curY + 5.5);

  curY += 9;

  autoTable(doc, {
    startY: curY,
    margin: { left: 12, right: 12 },
    head: [['Prestation & Détails', 'Séances', 'Montant en FCFA']],
    body: [
      [
        `Séances de conduite supplémentaires\nMotif : ${motif}`,
        `+${nbSeances} séance(s)`,
        formatFCFA(montantSupplement)
      ],
      [
        `Montant versé et encaissé ce jour (${modePaiement})`,
        '-',
        formatFCFA(montantVerse)
      ],
      [
        'Solde restant sur le supplément',
        '-',
        estSolde ? '0 FCFA  (SOLDÉ)' : formatFCFA(resteSupplement)
      ],
    ],
    theme: 'grid',
    headStyles: {
      fillColor: [15, 32, 68],
      textColor: 255,
      fontSize: 9.5,
      fontStyle: 'bold',
      halign: 'left',
    },
    bodyStyles: {
      fontSize: 9.5,
      cellPadding: 3.5,
    },
    columnStyles: {
      0: { cellWidth: 'auto', fontStyle: 'normal' },
      1: { cellWidth: 35, halign: 'center', fontStyle: 'bold' },
      2: { cellWidth: 50, halign: 'right', fontStyle: 'bold' },
    },
    didParseCell(data) {
      if (data.row.index === 1 && data.column.index === 2) {
        data.cell.styles.textColor = [22, 163, 74];
      }
      if (data.row.index === 2 && data.column.index === 2) {
        data.cell.styles.textColor = estSolde ? [22, 163, 74] : [220, 38, 38];
      }
    },
  });

  const tableEnd = (doc as any).lastAutoTable.finalY;
  curY = tableEnd + 8;

  // ── Récapitulatif du quota total de conduite ──────────────────
  doc.setFillColor(239, 246, 255);
  doc.setDrawColor(191, 219, 254);
  doc.roundedRect(12, curY, pageW - 24, 18, 2, 2, 'FD');

  doc.setFontSize(9.5);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(30, 58, 138);
  doc.text(
    `🚘 NOUVEAU TOTAL AU DOSSIER DU CANDIDAT : ${candidat.nb_conduites_prevues || 0} SÉANCES DE CONDUITE PRÉVUES`,
    pageW / 2,
    curY + 7,
    { align: 'center' }
  );

  doc.setFontSize(8);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(71, 85, 105);
  doc.text(
    `Séances déjà effectuées : ${candidat.nb_conduites_effectuees || 0}   |   Séances restantes à programmer : ${(candidat.nb_conduites_prevues || 0) - (candidat.nb_conduites_effectuees || 0)}`,
    pageW / 2,
    curY + 13,
    { align: 'center' }
  );

  curY += 25;

  // ── Conditions d'usage ───────────────────────────────────────
  doc.setFillColor(248, 250, 252);
  doc.setDrawColor(226, 232, 240);
  doc.roundedRect(12, curY, pageW - 24, 28, 2, 2, 'FD');

  doc.setFontSize(8);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text('CONDITIONS ET MODALITÉS DES SÉANCES SUPPLÉMENTAIRES :', 16, curY + 5.5);

  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(71, 85, 105);
  doc.text('1. Les séances achetées sont créditées sur la fiche de formation du candidat et utilisables immédiatement.', 16, curY + 10.5);
  doc.text('2. La réservation des créneaux de conduite s\'effectue auprès du secrétariat ou directement avec le moniteur assigné.', 16, curY + 15.5);
  doc.text('3. Toute annulation de séance doit être signalée au moins 24 heures à l\'avance sous peine d\'être décomptée.', 16, curY + 20.5);

  // Mention formelle de validité & non-remboursement
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(7.5);
  doc.setTextColor(185, 28, 28);
  doc.text('NB : Le présent reçu est valable pour 03 mois et n\'est en aucun cas remboursable.', 16, curY + 25.5);

  curY += 34;

  // ── Signature ───────────────────────────────────────────────
  const signBoxH = 34;

  // Boîte Administration uniquement (pleine largeur)
  doc.setDrawColor(203, 213, 225);
  doc.setFillColor(255, 255, 255);
  doc.roundedRect(12, curY, pageW - 24, signBoxH, 2, 2, 'D');

  doc.setFontSize(8.5);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 32, 68);
  doc.text('Pour l\'Administration de l\'Auto-École', pageW / 2, curY + 6, { align: 'center' });
  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(100, 116, 139);
  doc.text('(Cachet officiel et Visa d\'encaissement)', pageW / 2, curY + 11, { align: 'center' });

  // ── Pied de page sécurisé ────────────────────────────────────
  const footY = pageH - 14;
  doc.setFillColor(15, 32, 68);
  doc.rect(8, footY, pageW - 16, 8, 'F');

  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(191, 219, 254);
  doc.text(
    `Reçu officiel de supplément délivré par ${autoEcole}  |  Agrément N° 036/MTRAF/META  |  Réf: ${numeroRecu}`,
    pageW / 2,
    footY + 5.2,
    { align: 'center' }
  );

  doc.save(`recu_supplement_conduite_${candidat.nom}_${candidat.prenom}_${Date.now()}.pdf`);
};

/**
 * Génération du rapport officiel PDF : État des Créances & Reste à Payer (Recouvrement)
 */
export const generateImpayesPDF = (
  candidats: Candidat[],
  annexe: string = 'Toutes',
  autoEcole: string = 'Auto-École Saint Edmond',
  directeur: string = 'M. KALIBOU Edmond B.'
) => {
  const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });
  const pageW = doc.internal.pageSize.getWidth(); // 297mm
  const pageH = doc.internal.pageSize.getHeight(); // 210mm

  // 1. Logo officiel
  try {
    doc.addImage(SAINT_EDMOND_LOGO_BASE64, 'PNG', 14, 10, 18, 18);
  } catch (e) {
    console.warn('Logo introuvable pour le PDF:', e);
  }

  // 2. Entête officiel
  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(29, 78, 216); // Bleu Saint Edmond
  doc.text(autoEcole.toUpperCase(), 36, 17);

  doc.setFontSize(12);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(185, 28, 28); // Rouge recouvrement
  doc.text('ÉTAT DES CRÉANCES & CANDIDATS NON SOLDÉS (RESTE À PAYER)', 36, 23);

  doc.setFontSize(8.5);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(100, 116, 139);
  doc.text(
    `Annexe : ${annexe}  |  Document confidentiel de recouvrement généré le ${new Date().toLocaleDateString('fr-FR')} à ${new Date().toLocaleTimeString('fr-FR')}`,
    36,
    28
  );

  // 3. Calculs des KPI
  const nonSoldes = candidats.filter(c => (c.montant_total || 0) > (c.montant_paye || 0));
  const totalForfaits = nonSoldes.reduce((acc, c) => acc + (c.montant_total || 0), 0);
  const totalEncaisse = nonSoldes.reduce((acc, c) => acc + (c.montant_paye || 0), 0);
  const totalReste = totalForfaits - totalEncaisse;
  const examensBloques = nonSoldes.filter(
    c => c.statut_examen_code === 'PROGRAMME' || c.statut_examen_conduite === 'PROGRAMME'
  ).length;

  // 4. Bannière Synthèse KPI (4 boîtes)
  const boxY = 32;
  const boxH = 16;
  const boxW = (pageW - 28 - 9) / 4; // 4 boîtes réparties

  // Boîte 1: Nombre de candidats
  doc.setFillColor(241, 245, 249);
  doc.setDrawColor(203, 213, 225);
  doc.roundedRect(14, boxY, boxW, boxH, 2, 2, 'FD');
  doc.setFontSize(7.5);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(100, 116, 139);
  doc.text('CANDIDATS EN DETTE', 14 + boxW / 2, boxY + 5.5, { align: 'center' });
  doc.setFontSize(examensBloques > 0 ? 9.5 : 11);
  doc.setTextColor(15, 23, 42);
  doc.text(
    examensBloques > 0
      ? `${nonSoldes.length} élève${nonSoldes.length > 1 ? 's' : ''} (${examensBloques} bloqué${examensBloques > 1 ? 's' : ''})`
      : `${nonSoldes.length} élève${nonSoldes.length > 1 ? 's' : ''}`,
    14 + boxW / 2,
    boxY + 12,
    { align: 'center' }
  );

  // Boîte 2: Total forfaits
  const b2X = 14 + boxW + 3;
  doc.setFillColor(241, 245, 249);
  doc.roundedRect(b2X, boxY, boxW, boxH, 2, 2, 'FD');
  doc.setFontSize(7.5);
  doc.setTextColor(100, 116, 139);
  doc.text('VOLUME GLOBAL FORFAITS', b2X + boxW / 2, boxY + 5.5, { align: 'center' });
  doc.setFontSize(10.5);
  doc.setTextColor(15, 23, 42);
  doc.text(`${formatMontant(totalForfaits)} F`, b2X + boxW / 2, boxY + 12, { align: 'center' });

  // Boîte 3: Déjà encaissé
  const b3X = b2X + boxW + 3;
  doc.setFillColor(236, 253, 245);
  doc.setDrawColor(167, 243, 208);
  doc.roundedRect(b3X, boxY, boxW, boxH, 2, 2, 'FD');
  doc.setFontSize(7.5);
  doc.setTextColor(4, 120, 87);
  doc.text('DÉJÀ ENCAISSÉ', b3X + boxW / 2, boxY + 5.5, { align: 'center' });
  doc.setFontSize(10.5);
  doc.setTextColor(4, 120, 87);
  doc.text(`${formatMontant(totalEncaisse)} F`, b3X + boxW / 2, boxY + 12, { align: 'center' });

  // Boîte 4: Reste à recouvrer (Mise en valeur rouge vif)
  const b4X = b3X + boxW + 3;
  doc.setFillColor(254, 242, 242);
  doc.setDrawColor(254, 202, 202);
  doc.roundedRect(b4X, boxY, boxW, boxH, 2, 2, 'FD');
  doc.setFontSize(7.5);
  doc.setTextColor(185, 28, 28);
  doc.text('TOTAL RESTE À RECOUVRER', b4X + boxW / 2, boxY + 5.5, { align: 'center' });
  doc.setFontSize(11);
  doc.setTextColor(185, 28, 28);
  doc.text(`${formatMontant(totalReste)} FCFA`, b4X + boxW / 2, boxY + 12, { align: 'center' });

  // 5. Tableau détaillé des créances
  const tableData = nonSoldes.map((c, i) => {
    const reste = (c.montant_total || 0) - (c.montant_paye || 0);
    const hasExamCode = c.statut_examen_code === 'PROGRAMME';
    const hasExamCond = c.statut_examen_conduite === 'PROGRAMME';
    let alerteExamen = '—';
    if (hasExamCode && hasExamCond) alerteExamen = '⚠️ Exam. Code & Conduite';
    else if (hasExamCode) alerteExamen = `⚠️ Exam. Code (${c.date_examen_code || 'Prévu'})`;
    else if (hasExamCond) alerteExamen = `⚠️ Exam. Conduite (${c.date_examen_conduite || 'Prévu'})`;

    return [
      (i + 1).toString(),
      `${c.nom} ${c.prenom}`.toUpperCase(),
      c.contact || '—',
      c.annexe?.replace('Tokoin Ramco (Siège)', 'Tokoin Ramco') || 'Siège',
      `Permis ${c.categorie || 'B'}`,
      `${formatMontant(c.montant_total)} F`,
      `${formatMontant(c.montant_paye)} F`,
      `${formatMontant(reste)} F`,
      alerteExamen,
    ];
  });

  autoTable(doc, {
    startY: 52,
    head: [[
      '#',
      'Candidat (Nom & Prénom)',
      'Contact',
      'Annexe',
      'Catégorie',
      'Forfait Total',
      'Déjà Réglé',
      'Reste Dû',
      'Statut Examen'
    ]],
    body: tableData,
    theme: 'striped',
    headStyles: {
      fillColor: [30, 41, 59],
      textColor: [255, 255, 255],
      fontSize: 8.5,
      fontStyle: 'bold',
      halign: 'center',
    },
    bodyStyles: {
      fontSize: 8,
      textColor: [30, 41, 59],
    },
    columnStyles: {
      0: { cellWidth: 10, halign: 'center' },
      1: { cellWidth: 55, fontStyle: 'bold' },
      2: { cellWidth: 28, halign: 'center' },
      3: { cellWidth: 32 },
      4: { cellWidth: 22, halign: 'center' },
      5: { cellWidth: 28, halign: 'right' },
      6: { cellWidth: 28, halign: 'right', textColor: [4, 120, 87] },
      7: { cellWidth: 32, halign: 'right', fontStyle: 'bold', textColor: [185, 28, 28] },
      8: { cellWidth: 35, halign: 'center', fontSize: 7.5 },
    },
    alternateRowStyles: {
      fillColor: [248, 250, 252],
    },
    didDrawPage: (data) => {
      // Pied de page
      const fY = pageH - 8;
      doc.setFontSize(7.5);
      doc.setFont('helvetica', 'normal');
      doc.setTextColor(148, 163, 184);
      doc.text(
        `${autoEcole}  |  Siège Tokoin Ramco  |  Direction Générale : ${directeur}  |  Page ${data.pageNumber}`,
        pageW / 2,
        fY,
        { align: 'center' }
      );
    },
  });

  doc.save(`etat_creances_impayes_${annexe.toLowerCase().replace(/\s+/g, '_')}_${Date.now()}.pdf`);
};


