import { supabase, isConfigured } from './supabase';
import type { Candidat, Depense, Recette } from '../types';

export type SyncStatus = 'offline' | 'online_synced' | 'syncing' | 'error';

class SyncService {
  private statusListeners: Array<(status: SyncStatus) => void> = [];
  private currentStatus: SyncStatus = 'offline';
  private realtimeChannel: any = null;

  constructor() {
    this.updateOnlineStatus();
    if (typeof window !== 'undefined') {
      window.addEventListener('online', () => this.handleConnectivityChange(true));
      window.addEventListener('offline', () => this.handleConnectivityChange(false));
    }
  }

  public getStatus(): SyncStatus {
    return this.currentStatus;
  }

  public subscribeStatus(listener: (status: SyncStatus) => void): () => void {
    this.statusListeners.push(listener);
    listener(this.currentStatus);
    return () => {
      this.statusListeners = this.statusListeners.filter(l => l !== listener);
    };
  }

  private setStatus(newStatus: SyncStatus) {
    this.currentStatus = newStatus;
    this.statusListeners.forEach(listener => listener(newStatus));
  }

  private updateOnlineStatus() {
    if (typeof navigator !== 'undefined' && !navigator.onLine) {
      this.setStatus('offline');
    } else if (!isConfigured) {
      // Pas encore connecté au cloud Supabase -> mode local offline actif
      this.setStatus('offline');
    } else {
      this.setStatus('online_synced');
    }
  }

  private async handleConnectivityChange(isOnline: boolean) {
    if (!isOnline || !isConfigured) {
      this.setStatus('offline');
      return;
    }
    this.setStatus('syncing');
    await this.flushSyncQueue();
    this.setStatus('online_synced');
  }

  // --- FILE D'ATTENTE HORS LIGNE (OFFLINE QUEUE) ---
  private getSyncQueue(): Array<{ table: string; action: 'upsert' | 'delete'; data: any }> {
    try {
      const q = localStorage.getItem('autoecole_sync_queue');
      return q ? JSON.parse(q) : [];
    } catch {
      return [];
    }
  }

  private saveSyncQueue(queue: any[]) {
    try {
      localStorage.setItem('autoecole_sync_queue', JSON.stringify(queue));
    } catch (e) {
      console.error('Erreur sauvegarde queue:', e);
    }
  }

  private enqueue(table: string, action: 'upsert' | 'delete', data: any) {
    const queue = this.getSyncQueue();
    // Évite les doublons pour le même ID
    const filtered = queue.filter(item => !(item.table === table && item.data?.id === data?.id));
    filtered.push({ table, action, data });
    this.saveSyncQueue(filtered);
  }

  public async flushSyncQueue() {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) return;
    const queue = this.getSyncQueue();
    if (queue.length === 0) return;

    this.setStatus('syncing');
    const remaining: typeof queue = [];

    for (const item of queue) {
      try {
        if (item.action === 'upsert') {
          await supabase.from(item.table).upsert(item.data);
        } else if (item.action === 'delete') {
          await supabase.from(item.table).delete().eq('id', item.data.id);
        }
      } catch (err) {
        console.warn(`Échec synchronisation élément (${item.table}):`, err);
        remaining.push(item);
      }
    }

    this.saveSyncQueue(remaining);
    this.setStatus(remaining.length === 0 ? 'online_synced' : 'offline');
  }

  // --- ACTIONS DE SYNCHRONISATION ENTITÉS ---

  public async syncCandidat(candidat: Candidat) {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) {
      this.enqueue('candidats', 'upsert', candidat);
      return;
    }
    try {
      await supabase.from('candidats').upsert(candidat);
    } catch (e) {
      console.warn('Erreur sync candidat, mise en file locale:', e);
      this.enqueue('candidats', 'upsert', candidat);
    }
  }

  public async deleteCandidat(id: string) {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) {
      this.enqueue('candidats', 'delete', { id });
      return;
    }
    try {
      await supabase.from('candidats').delete().eq('id', id);
    } catch (e) {
      this.enqueue('candidats', 'delete', { id });
    }
  }

  public async syncDepense(depense: Depense) {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) {
      this.enqueue('depenses', 'upsert', depense);
      return;
    }
    try {
      await supabase.from('depenses').upsert(depense);
    } catch (e) {
      this.enqueue('depenses', 'upsert', depense);
    }
  }

  public async deleteDepense(id: string) {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) {
      this.enqueue('depenses', 'delete', { id });
      return;
    }
    try {
      await supabase.from('depenses').delete().eq('id', id);
    } catch (e) {
      this.enqueue('depenses', 'delete', { id });
    }
  }

  public async syncRecette(recette: Recette) {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) {
      this.enqueue('recettes', 'upsert', recette);
      return;
    }
    try {
      await supabase.from('recettes').upsert(recette);
    } catch (e) {
      this.enqueue('recettes', 'upsert', recette);
    }
  }

  public async deleteRecette(id: string) {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) {
      this.enqueue('recettes', 'delete', { id });
      return;
    }
    try {
      await supabase.from('recettes').delete().eq('id', id);
    } catch (e) {
      this.enqueue('recettes', 'delete', { id });
    }
  }

  public async syncAnnexe(nom: string) {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) {
      this.enqueue('annexes', 'upsert', { nom });
      return;
    }
    try {
      await supabase.from('annexes').upsert({ nom });
    } catch (e) {
      this.enqueue('annexes', 'upsert', { nom });
    }
  }

  // --- CHARGEMENT INITIAL DEPUIS CLOUD ---

  public async fetchAllFromCloud(): Promise<{
    candidats?: Candidat[];
    depenses?: Depense[];
    recettes?: Recette[];
    annexes?: string[];
  } | null> {
    if (!isConfigured || (typeof navigator !== 'undefined' && !navigator.onLine)) return null;

    try {
      this.setStatus('syncing');

      const [candRes, depRes, recRes, annRes] = await Promise.all([
        supabase.from('candidats').select('*'),
        supabase.from('depenses').select('*'),
        supabase.from('recettes').select('*'),
        supabase.from('annexes').select('nom'),
      ]);

      this.setStatus('online_synced');

      return {
        candidats: candRes.data as Candidat[] | undefined,
        depenses: depRes.data as Depense[] | undefined,
        recettes: recRes.data as Recette[] | undefined,
        annexes: annRes.data?.map(a => a.nom) as string[] | undefined,
      };
    } catch (err) {
      console.error('Erreur chargement Supabase:', err);
      this.setStatus('offline');
      return null;
    }
  }

  // --- REALTIME (ÉCOUTE TEMPS RÉEL) ---

  public startRealtime(callbacks: {
    onCandidatChange?: (payload: any) => void;
    onDepenseChange?: (payload: any) => void;
    onRecetteChange?: (payload: any) => void;
  }) {
    if (!isConfigured || this.realtimeChannel) return;

    try {
      this.realtimeChannel = supabase
        .channel('schema-db-changes')
        .on(
          'postgres_changes',
          { event: '*', schema: 'public', table: 'candidats' },
          payload => callbacks.onCandidatChange?.(payload)
        )
        .on(
          'postgres_changes',
          { event: '*', schema: 'public', table: 'depenses' },
          payload => callbacks.onDepenseChange?.(payload)
        )
        .on(
          'postgres_changes',
          { event: '*', schema: 'public', table: 'recettes' },
          payload => callbacks.onRecetteChange?.(payload)
        )
        .subscribe();
    } catch (err) {
      console.warn('Realtime souscription non active:', err);
    }
  }

  public stopRealtime() {
    if (this.realtimeChannel) {
      supabase.removeChannel(this.realtimeChannel);
      this.realtimeChannel = null;
    }
  }
}

export const syncService = new SyncService();
