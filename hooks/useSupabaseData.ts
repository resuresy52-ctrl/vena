import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { Database } from '../lib/database.types';
import { 
  Client, Project, TeamMember, Transaction, Card, FinancialPocket, 
  Lead, Package, AddOn, Asset, Contract, ClientFeedback, Notification, 
  SocialMediaPost, PromoCode, SOP, Profile, User, TeamProjectPayment, 
  TeamPaymentRecord, RewardLedgerEntry
} from '../types';

type Tables = Database['public']['Tables'];

// Helper function to transform database rows to app types
const transformProfile = (row: Tables['profiles']['Row']): Profile => ({
  id: row.id,
  adminUserId: row.admin_user_id || '',
  fullName: row.full_name,
  email: row.email,
  phone: row.phone,
  companyName: row.company_name,
  website: row.website,
  address: row.address,
  bankAccount: row.bank_account,
  authorizedSigner: row.authorized_signer,
  idNumber: row.id_number || undefined,
  bio: row.bio,
  incomeCategories: row.income_categories as string[],
  expenseCategories: row.expense_categories as string[],
  projectTypes: row.project_types as string[],
  eventTypes: row.event_types as string[],
  assetCategories: row.asset_categories as string[],
  sopCategories: row.sop_categories as string[],
  packageCategories: row.package_categories as string[],
  projectStatusConfig: row.project_status_config as any,
  notificationSettings: row.notification_settings as any,
  securitySettings: row.security_settings as any,
  briefingTemplate: row.briefing_template,
  termsAndConditions: row.terms_and_conditions || undefined,
  contractTemplate: row.contract_template || undefined,
  logoBase64: row.logo_base64 || undefined,
  brandColor: row.brand_color,
  publicPageConfig: row.public_page_config as any,
  packageShareTemplate: row.package_share_template || undefined,
  bookingFormTemplate: row.booking_form_template || undefined,
  chatTemplates: row.chat_templates as any,
});

const transformClient = (row: Tables['clients']['Row']): Client => ({
  id: row.id,
  name: row.name,
  email: row.email,
  phone: row.phone,
  whatsapp: row.whatsapp || undefined,
  instagram: row.instagram || undefined,
  clientType: row.client_type as any,
  since: row.since,
  status: row.status as any,
  lastContact: row.last_contact,
  portalAccessId: row.portal_access_id,
});

const transformProject = (row: Tables['projects']['Row']): Project => ({
  id: row.id,
  projectName: row.project_name,
  clientName: row.client_name,
  clientId: row.client_id,
  projectType: row.project_type,
  packageName: row.package_name,
  packageId: row.package_id,
  addOns: row.add_ons as any,
  date: row.date,
  deadlineDate: row.deadline_date || undefined,
  location: row.location,
  progress: row.progress,
  status: row.status,
  activeSubStatuses: row.active_sub_statuses as string[],
  totalCost: row.total_cost,
  amountPaid: row.amount_paid,
  paymentStatus: row.payment_status as any,
  team: row.team as any,
  notes: row.notes || undefined,
  accommodation: row.accommodation || undefined,
  driveLink: row.drive_link || undefined,
  clientDriveLink: row.client_drive_link || undefined,
  finalDriveLink: row.final_drive_link || undefined,
  startTime: row.start_time || undefined,
  endTime: row.end_time || undefined,
  image: row.image || undefined,
  revisions: row.revisions as any,
  promoCodeId: row.promo_code_id || undefined,
  discountAmount: row.discount_amount || undefined,
  shippingDetails: row.shipping_details || undefined,
  dpProofUrl: row.dp_proof_url || undefined,
  printingDetails: row.printing_details as any,
  printingCost: row.printing_cost || undefined,
  transportCost: row.transport_cost || undefined,
  bookingStatus: row.booking_status as any,
  rejectionReason: row.rejection_reason || undefined,
  chatHistory: row.chat_history as any,
  confirmedSubStatuses: row.confirmed_sub_statuses as string[],
  clientSubStatusNotes: row.client_sub_status_notes as any,
  completedDigitalItems: row.completed_digital_items as string[],
  invoiceSignature: row.invoice_signature || undefined,
  customSubStatuses: row.custom_sub_statuses as any,
  isEditingConfirmedByClient: row.is_editing_confirmed_by_client,
  isPrintingConfirmedByClient: row.is_printing_confirmed_by_client,
  isDeliveryConfirmedByClient: row.is_delivery_confirmed_by_client,
  subStatusConfirmationSentAt: row.sub_status_confirmation_sent_at as any,
});

export const useSupabaseData = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  // State for all data
  const [profile, setProfile] = useState<Profile | null>(null);
  const [clients, setClients] = useState<Client[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [teamMembers, setTeamMembers] = useState<TeamMember[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [cards, setCards] = useState<Card[]>([]);
  const [pockets, setPockets] = useState<FinancialPocket[]>([]);
  const [leads, setLeads] = useState<Lead[]>([]);
  const [packages, setPackages] = useState<Package[]>([]);
  const [addOns, setAddOns] = useState<AddOn[]>([]);
  const [assets, setAssets] = useState<Asset[]>([]);
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [clientFeedback, setClientFeedback] = useState<ClientFeedback[]>([]);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [socialMediaPosts, setSocialMediaPosts] = useState<SocialMediaPost[]>([]);
  const [promoCodes, setPromoCodes] = useState<PromoCode[]>([]);
  const [sops, setSops] = useState<SOP[]>([]);
  const [teamProjectPayments, setTeamProjectPayments] = useState<TeamProjectPayment[]>([]);
  const [teamPaymentRecords, setTeamPaymentRecords] = useState<TeamPaymentRecord[]>([]);
  const [rewardLedgerEntries, setRewardLedgerEntries] = useState<RewardLedgerEntry[]>([]);

  const loadAllData = async () => {
    try {
      setIsLoading(true);
      setError(null);

      // Load all data in parallel
      const [
        profilesResult,
        clientsResult,
        projectsResult,
        teamMembersResult,
        transactionsResult,
        cardsResult,
        pocketsResult,
        leadsResult,
        packagesResult,
        addOnsResult,
        assetsResult,
        contractsResult,
        feedbackResult,
        notificationsResult,
        postsResult,
        promoCodesResult,
        sopsResult,
        teamPaymentsResult,
        paymentRecordsResult,
        rewardEntriesResult,
      ] = await Promise.all([
        supabase.from('profiles').select('*').single(),
        supabase.from('clients').select('*').order('created_at', { ascending: false }),
        supabase.from('projects').select('*').order('created_at', { ascending: false }),
        supabase.from('team_members').select('*').order('name'),
        supabase.from('transactions').select('*').order('date', { ascending: false }),
        supabase.from('cards').select('*').order('created_at'),
        supabase.from('financial_pockets').select('*').order('created_at'),
        supabase.from('leads').select('*').order('date', { ascending: false }),
        supabase.from('packages').select('*').order('name'),
        supabase.from('add_ons').select('*').order('name'),
        supabase.from('assets').select('*').order('created_at', { ascending: false }),
        supabase.from('contracts').select('*').order('created_at', { ascending: false }),
        supabase.from('client_feedback').select('*').order('date', { ascending: false }),
        supabase.from('notifications').select('*').order('timestamp', { ascending: false }),
        supabase.from('social_media_posts').select('*').order('scheduled_date', { ascending: false }),
        supabase.from('promo_codes').select('*').order('created_at', { ascending: false }),
        supabase.from('sops').select('*').order('title'),
        supabase.from('team_project_payments').select('*').order('date', { ascending: false }),
        supabase.from('team_payment_records').select('*').order('date', { ascending: false }),
        supabase.from('reward_ledger_entries').select('*').order('date', { ascending: false }),
      ]);

      // Handle profile
      if (profilesResult.data) {
        setProfile(transformProfile(profilesResult.data));
      }

      // Handle other data
      if (clientsResult.data) {
        setClients(clientsResult.data.map(transformClient));
      }

      if (projectsResult.data) {
        setProjects(projectsResult.data.map(transformProject));
      }

      if (teamMembersResult.data) {
        setTeamMembers(teamMembersResult.data.map(row => ({
          id: row.id,
          name: row.name,
          role: row.role,
          email: row.email,
          phone: row.phone,
          standardFee: row.standard_fee,
          noRek: row.no_rek || undefined,
          rewardBalance: row.reward_balance,
          rating: row.rating,
          performanceNotes: row.performance_notes as any,
          portalAccessId: row.portal_access_id,
        })));
      }

      if (transactionsResult.data) {
        setTransactions(transactionsResult.data.map(row => ({
          id: row.id,
          date: row.date,
          description: row.description,
          amount: row.amount,
          type: row.type as any,
          projectId: row.project_id || undefined,
          category: row.category,
          method: row.method as any,
          pocketId: row.pocket_id || undefined,
          cardId: row.card_id || undefined,
          printingItemId: row.printing_item_id || undefined,
          vendorSignature: row.vendor_signature || undefined,
        })));
      }

      if (cardsResult.data) {
        setCards(cardsResult.data.map(row => ({
          id: row.id,
          cardHolderName: row.card_holder_name,
          bankName: row.bank_name,
          cardType: row.card_type as any,
          lastFourDigits: row.last_four_digits,
          expiryDate: row.expiry_date || undefined,
          balance: row.balance,
          colorGradient: row.color_gradient,
        })));
      }

      if (pocketsResult.data) {
        setPockets(pocketsResult.data.map(row => ({
          id: row.id,
          name: row.name,
          description: row.description,
          icon: row.icon as any,
          type: row.type as any,
          amount: row.amount,
          goalAmount: row.goal_amount || undefined,
          lockEndDate: row.lock_end_date || undefined,
          members: row.members as any,
          sourceCardId: row.source_card_id || undefined,
        })));
      }

      if (leadsResult.data) {
        setLeads(leadsResult.data.map(row => ({
          id: row.id,
          name: row.name,
          contactChannel: row.contact_channel as any,
          location: row.location,
          status: row.status as any,
          date: row.date,
          notes: row.notes || undefined,
          whatsapp: row.whatsapp || undefined,
        })));
      }

      if (packagesResult.data) {
        setPackages(packagesResult.data.map(row => ({
          id: row.id,
          name: row.name,
          price: row.price,
          category: row.category,
          physicalItems: row.physical_items as any,
          digitalItems: row.digital_items as any,
          processingTime: row.processing_time,
          photographers: row.photographers || undefined,
          videographers: row.videographers || undefined,
          coverImage: row.cover_image || undefined,
        })));
      }

      if (addOnsResult.data) {
        setAddOns(addOnsResult.data.map(row => ({
          id: row.id,
          name: row.name,
          price: row.price,
        })));
      }

      // Continue with other transformations...
      if (assetsResult.data) {
        setAssets(assetsResult.data.map(row => ({
          id: row.id,
          name: row.name,
          category: row.category,
          purchaseDate: row.purchase_date,
          purchasePrice: row.purchase_price,
          serialNumber: row.serial_number || undefined,
          status: row.status as any,
          notes: row.notes || undefined,
        })));
      }

      if (contractsResult.data) {
        setContracts(contractsResult.data.map(row => ({
          id: row.id,
          contractNumber: row.contract_number,
          clientId: row.client_id,
          projectId: row.project_id,
          signingDate: row.signing_date,
          signingLocation: row.signing_location,
          clientName1: row.client_name1,
          clientAddress1: row.client_address1,
          clientPhone1: row.client_phone1,
          clientName2: row.client_name2 || undefined,
          clientAddress2: row.client_address2 || undefined,
          clientPhone2: row.client_phone2 || undefined,
          shootingDuration: row.shooting_duration,
          guaranteedPhotos: row.guaranteed_photos,
          albumDetails: row.album_details,
          digitalFilesFormat: row.digital_files_format,
          otherItems: row.other_items,
          personnelCount: row.personnel_count,
          deliveryTimeframe: row.delivery_timeframe,
          dpDate: row.dp_date || '',
          finalPaymentDate: row.final_payment_date || '',
          cancellationPolicy: row.cancellation_policy,
          jurisdiction: row.jurisdiction,
          vendorSignature: row.vendor_signature || undefined,
          clientSignature: row.client_signature || undefined,
          createdAt: row.created_at,
        })));
      }

      if (feedbackResult.data) {
        setClientFeedback(feedbackResult.data.map(row => ({
          id: row.id,
          clientName: row.client_name,
          satisfaction: row.satisfaction as any,
          rating: row.rating,
          feedback: row.feedback,
          date: row.date,
        })));
      }

      if (notificationsResult.data) {
        setNotifications(notificationsResult.data.map(row => ({
          id: row.id,
          title: row.title,
          message: row.message,
          timestamp: row.timestamp,
          isRead: row.is_read,
          icon: row.icon as any,
          link: row.link_view ? {
            view: row.link_view as any,
            action: row.link_action as any,
          } : undefined,
        })));
      }

      if (postsResult.data) {
        setSocialMediaPosts(postsResult.data.map(row => ({
          id: row.id,
          projectId: row.project_id,
          clientName: row.client_name,
          postType: row.post_type as any,
          platform: row.platform as any,
          scheduledDate: row.scheduled_date,
          caption: row.caption,
          mediaUrl: row.media_url || undefined,
          status: row.status as any,
          notes: row.notes || undefined,
        })));
      }

      if (promoCodesResult.data) {
        setPromoCodes(promoCodesResult.data.map(row => ({
          id: row.id,
          code: row.code,
          discountType: row.discount_type as any,
          discountValue: row.discount_value,
          isActive: row.is_active,
          usageCount: row.usage_count,
          maxUsage: row.max_usage || undefined,
          expiryDate: row.expiry_date || undefined,
          createdAt: row.created_at,
        })));
      }

      if (sopsResult.data) {
        setSops(sopsResult.data.map(row => ({
          id: row.id,
          title: row.title,
          category: row.category,
          content: row.content,
          lastUpdated: row.last_updated,
        })));
      }

      // Add transformations for remaining tables...
      if (teamPaymentsResult.data) {
        setTeamProjectPayments(teamPaymentsResult.data.map(row => ({
          id: row.id,
          projectId: row.project_id,
          teamMemberName: row.team_member_name,
          teamMemberId: row.team_member_id,
          date: row.date,
          status: row.status as any,
          fee: row.fee,
          reward: row.reward,
        })));
      }

      if (paymentRecordsResult.data) {
        setTeamPaymentRecords(paymentRecordsResult.data.map(row => ({
          id: row.id,
          recordNumber: row.record_number,
          teamMemberId: row.team_member_id,
          date: row.date,
          projectPaymentIds: row.project_payment_ids as string[],
          totalAmount: row.total_amount,
          vendorSignature: row.vendor_signature || undefined,
        })));
      }

      if (rewardEntriesResult.data) {
        setRewardLedgerEntries(rewardEntriesResult.data.map(row => ({
          id: row.id,
          teamMemberId: row.team_member_id,
          date: row.date,
          description: row.description,
          amount: row.amount,
          projectId: row.project_id || undefined,
        })));
      }

    } catch (err) {
      console.error('Error loading data:', err);
      setError('Failed to load data from database');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadAllData();
  }, []);

  // CRUD operations
  const createClient = async (clientData: Omit<Client, 'id'>) => {
    const { data, error } = await supabase
      .from('clients')
      .insert({
        name: clientData.name,
        email: clientData.email,
        phone: clientData.phone,
        whatsapp: clientData.whatsapp,
        instagram: clientData.instagram,
        client_type: clientData.clientType,
        since: clientData.since,
        status: clientData.status,
        last_contact: clientData.lastContact,
      })
      .select()
      .single();

    if (error) throw error;
    if (data) {
      const newClient = transformClient(data);
      setClients(prev => [newClient, ...prev]);
      return newClient;
    }
  };

  const updateClient = async (id: string, updates: Partial<Client>) => {
    const { data, error } = await supabase
      .from('clients')
      .update({
        name: updates.name,
        email: updates.email,
        phone: updates.phone,
        whatsapp: updates.whatsapp,
        instagram: updates.instagram,
        client_type: updates.clientType,
        status: updates.status,
        last_contact: updates.lastContact,
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    if (data) {
      const updatedClient = transformClient(data);
      setClients(prev => prev.map(c => c.id === id ? updatedClient : c));
      return updatedClient;
    }
  };

  const deleteClient = async (id: string) => {
    const { error } = await supabase
      .from('clients')
      .delete()
      .eq('id', id);

    if (error) throw error;
    setClients(prev => prev.filter(c => c.id !== id));
  };

  // Similar CRUD operations for other entities...
  const createProject = async (projectData: Omit<Project, 'id'>) => {
    const { data, error } = await supabase
      .from('projects')
      .insert({
        project_name: projectData.projectName,
        client_name: projectData.clientName,
        client_id: projectData.clientId,
        project_type: projectData.projectType,
        package_name: projectData.packageName,
        package_id: projectData.packageId,
        add_ons: projectData.addOns,
        date: projectData.date,
        deadline_date: projectData.deadlineDate,
        location: projectData.location,
        progress: projectData.progress,
        status: projectData.status,
        total_cost: projectData.totalCost,
        amount_paid: projectData.amountPaid,
        payment_status: projectData.paymentStatus,
        team: projectData.team,
        notes: projectData.notes,
        booking_status: projectData.bookingStatus,
        dp_proof_url: projectData.dpProofUrl,
        transport_cost: projectData.transportCost,
        promo_code_id: projectData.promoCodeId,
        discount_amount: projectData.discountAmount,
      })
      .select()
      .single();

    if (error) throw error;
    if (data) {
      const newProject = transformProject(data);
      setProjects(prev => [newProject, ...prev]);
      return newProject;
    }
  };

  const createLead = async (leadData: Omit<Lead, 'id'>) => {
    const { data, error } = await supabase
      .from('leads')
      .insert({
        name: leadData.name,
        contact_channel: leadData.contactChannel,
        location: leadData.location,
        status: leadData.status,
        date: leadData.date,
        notes: leadData.notes,
        whatsapp: leadData.whatsapp,
      })
      .select()
      .single();

    if (error) throw error;
    if (data) {
      const newLead: Lead = {
        id: data.id,
        name: data.name,
        contactChannel: data.contact_channel as any,
        location: data.location,
        status: data.status as any,
        date: data.date,
        notes: data.notes || undefined,
        whatsapp: data.whatsapp || undefined,
      };
      setLeads(prev => [newLead, ...prev]);
      return newLead;
    }
  };

  const createClientFeedback = async (feedbackData: Omit<ClientFeedback, 'id'>) => {
    const { data, error } = await supabase
      .from('client_feedback')
      .insert({
        client_name: feedbackData.clientName,
        satisfaction: feedbackData.satisfaction,
        rating: feedbackData.rating,
        feedback: feedbackData.feedback,
        date: feedbackData.date,
      })
      .select()
      .single();

    if (error) throw error;
    if (data) {
      const newFeedback: ClientFeedback = {
        id: data.id,
        clientName: data.client_name,
        satisfaction: data.satisfaction as any,
        rating: data.rating,
        feedback: data.feedback,
        date: data.date,
      };
      setClientFeedback(prev => [newFeedback, ...prev]);
      return newFeedback;
    }
  };

  return {
    // Data
    profile,
    clients,
    projects,
    teamMembers,
    transactions,
    cards,
    pockets,
    leads,
    packages,
    addOns,
    assets,
    contracts,
    clientFeedback,
    notifications,
    socialMediaPosts,
    promoCodes,
    sops,
    teamProjectPayments,
    teamPaymentRecords,
    rewardLedgerEntries,
    
    // State setters (for local updates)
    setProfile,
    setClients,
    setProjects,
    setTeamMembers,
    setTransactions,
    setCards,
    setPockets,
    setLeads,
    setPackages,
    setAddOns,
    setAssets,
    setContracts,
    setClientFeedback,
    setNotifications,
    setSocialMediaPosts,
    setPromoCodes,
    setSops,
    setTeamProjectPayments,
    setTeamPaymentRecords,
    setRewardLedgerEntries,
    
    // CRUD operations
    createClient,
    updateClient,
    deleteClient,
    createProject,
    createLead,
    createClientFeedback,
    
    // Loading state
    isLoading,
    error,
    refetch: loadAllData,
  };
};