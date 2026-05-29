class Routes {
  Routes._();

  // Main tabs
  static const home = '/';
  static const search = '/cari';
  static const translate = '/terjemah';
  static const bookmarks = '/simpanan';
  static const profile = '/profil';

  // Onboarding
  static const onboarding = '/onboarding';

  // Word
  static const wordDetail = '/words/:id';

  // Auth
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/lupa-sandi';
  static const resetPassword = '/reset-sandi';
  static const verifyEmail = '/verifikasi-email';

  // Profile sub-routes
  static const editProfile = '/profil/edit';
  static const changePassword = '/profil/ubah-sandi';
  static const myContributions = '/profil/kontribusi';
  static const contributionDetail = '/profil/kontribusi/:id';

  // Contribution forms
  static const contributionNewWord = '/kontribusi/kata-baru';
  static const contributionNewDefinition = '/kontribusi/definisi-baru';
  static const contributionNewExample = '/kontribusi/contoh-baru';
  static const contributionEditWord = '/kontribusi/ubah-kata';

  // Admin
  static const adminPanel = '/admin';
  static const adminWords = '/admin/words';
  static const adminWordCreate = '/admin/words/create';
  static const adminWordEdit = '/admin/words/:id/edit';
  static const adminModerationQueue = '/admin/moderasi/antrian';
  static const adminContributionReview = '/admin/moderasi/kontribusi/:id';
  static const adminFlaggedComments = '/admin/moderasi/komentar';
  static const adminUsers = '/admin/pengguna';
  static const adminUserDetail = '/admin/pengguna/:id';
  static const adminAiRequests = '/admin/ai/permintaan';
  static const adminAiRequestDetail = '/admin/ai/permintaan/:id';

  // Helper: build path with param substituted
  static String wordDetailPath(String id) => '/words/$id';
  static String contributionDetailPath(String id) =>
      '/profil/kontribusi/$id';
  static String adminWordEditPath(String id) => '/admin/words/$id/edit';
  static String adminContributionReviewPath(String id) =>
      '/admin/moderasi/kontribusi/$id';
  static String adminUserDetailPath(String id) => '/admin/pengguna/$id';
  static String adminAiRequestDetailPath(String id) =>
      '/admin/ai/permintaan/$id';
}
