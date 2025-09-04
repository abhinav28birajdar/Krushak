import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';

class LoanScheme {
  final String id;
  final String name;
  final String bankName;
  final String description;
  final double interestRate;
  final String interestType; // 'fixed' or 'floating'
  final double maxAmount;
  final double minAmount;
  final int maxTenureMonths;
  final List<String> eligibility;
  final List<String> documents;
  final String category; // 'crop', 'equipment', 'land', 'dairy', 'poultry'
  final bool isSubsidized;
  final double subsidyPercentage;
  final String applicationUrl;
  final String contactNumber;
  final bool isActive;
  final DateTime lastUpdated;

  LoanScheme({
    required this.id,
    required this.name,
    required this.bankName,
    required this.description,
    required this.interestRate,
    required this.interestType,
    required this.maxAmount,
    required this.minAmount,
    required this.maxTenureMonths,
    required this.eligibility,
    required this.documents,
    required this.category,
    required this.isSubsidized,
    required this.subsidyPercentage,
    required this.applicationUrl,
    required this.contactNumber,
    required this.isActive,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bank_name': bankName,
      'description': description,
      'interest_rate': interestRate,
      'interest_type': interestType,
      'max_amount': maxAmount,
      'min_amount': minAmount,
      'max_tenure_months': maxTenureMonths,
      'eligibility': eligibility,
      'documents': documents,
      'category': category,
      'is_subsidized': isSubsidized,
      'subsidy_percentage': subsidyPercentage,
      'application_url': applicationUrl,
      'contact_number': contactNumber,
      'is_active': isActive,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  static LoanScheme fromJson(Map<String, dynamic> json) {
    return LoanScheme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bankName: json['bank_name'] ?? '',
      description: json['description'] ?? '',
      interestRate: (json['interest_rate'] ?? 0).toDouble(),
      interestType: json['interest_type'] ?? 'fixed',
      maxAmount: (json['max_amount'] ?? 0).toDouble(),
      minAmount: (json['min_amount'] ?? 0).toDouble(),
      maxTenureMonths: json['max_tenure_months'] ?? 12,
      eligibility: List<String>.from(json['eligibility'] ?? []),
      documents: List<String>.from(json['documents'] ?? []),
      category: json['category'] ?? 'crop',
      isSubsidized: json['is_subsidized'] ?? false,
      subsidyPercentage: (json['subsidy_percentage'] ?? 0).toDouble(),
      applicationUrl: json['application_url'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      isActive: json['is_active'] ?? true,
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}

class LoanApplication {
  final String id;
  final String userId;
  final String schemeId;
  final String schemeName;
  final String bankName;
  final double requestedAmount;
  final int tenureMonths;
  final String purpose;
  final String status; // 'pending', 'approved', 'rejected', 'processing'
  final DateTime applicationDate;
  final DateTime? approvalDate;
  final String? remarks;
  final Map<String, dynamic> documents;

  LoanApplication({
    required this.id,
    required this.userId,
    required this.schemeId,
    required this.schemeName,
    required this.bankName,
    required this.requestedAmount,
    required this.tenureMonths,
    required this.purpose,
    required this.status,
    required this.applicationDate,
    this.approvalDate,
    this.remarks,
    this.documents = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'scheme_id': schemeId,
      'scheme_name': schemeName,
      'bank_name': bankName,
      'requested_amount': requestedAmount,
      'tenure_months': tenureMonths,
      'purpose': purpose,
      'status': status,
      'application_date': applicationDate.toIso8601String(),
      'approval_date': approvalDate?.toIso8601String(),
      'remarks': remarks,
      'documents': documents,
    };
  }

  static LoanApplication fromJson(Map<String, dynamic> json) {
    return LoanApplication(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      schemeId: json['scheme_id'] ?? '',
      schemeName: json['scheme_name'] ?? '',
      bankName: json['bank_name'] ?? '',
      requestedAmount: (json['requested_amount'] ?? 0).toDouble(),
      tenureMonths: json['tenure_months'] ?? 12,
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? 'pending',
      applicationDate: DateTime.parse(json['application_date']),
      approvalDate: json['approval_date'] != null
          ? DateTime.parse(json['approval_date'])
          : null,
      remarks: json['remarks'],
      documents: Map<String, dynamic>.from(json['documents'] ?? {}),
    );
  }
}

class BankLoanService {
  static const String _apiKey = String.fromEnvironment(
    'BANK_API_KEY',
    defaultValue: 'demo_key',
  );

  static Future<List<LoanScheme>> getAllLoanSchemes() async {
    try {
      final response = await SupabaseService.client
          .from('loan_schemes')
          .select('*')
          .eq('is_active', true)
          .order('interest_rate', ascending: true);

      return (response as List)
          .map((json) => LoanScheme.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching loan schemes: $e');
      return _getDefaultLoanSchemes();
    }
  }

  static List<LoanScheme> _getDefaultLoanSchemes() {
    return [
      LoanScheme(
        id: 'sbi_crop_loan',
        name: 'SBI Crop Loan',
        bankName: 'State Bank of India',
        description:
            'Short-term crop loan for seasonal agricultural activities',
        interestRate: 7.0,
        interestType: 'fixed',
        maxAmount: 300000,
        minAmount: 50000,
        maxTenureMonths: 12,
        eligibility: [
          'Farmer with valid land documents',
          'Age between 18-65 years',
          'Good credit history',
          'Land holding minimum 1 acre',
        ],
        documents: [
          'Aadhaar Card',
          'PAN Card',
          'Land Documents',
          'Bank Statements',
          'Income Certificate',
        ],
        category: 'crop',
        isSubsidized: true,
        subsidyPercentage: 3.0,
        applicationUrl: 'https://sbi.co.in/crop-loan',
        contactNumber: '1800-11-2211',
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
      LoanScheme(
        id: 'hdfc_kisan_loan',
        name: 'HDFC Kisan Credit Card',
        bankName: 'HDFC Bank',
        description: 'Comprehensive credit facility for all agricultural needs',
        interestRate: 7.5,
        interestType: 'floating',
        maxAmount: 500000,
        minAmount: 25000,
        maxTenureMonths: 60,
        eligibility: [
          'Farmer or sharecropper',
          'Land ownership or lease documents',
          'Age 18-70 years',
          'Good repayment capacity',
        ],
        documents: [
          'KYC Documents',
          'Land Records',
          'Income Proof',
          'Crop Plan',
          'Passport Photos',
        ],
        category: 'crop',
        isSubsidized: true,
        subsidyPercentage: 2.0,
        applicationUrl: 'https://hdfc.com/kisan-credit-card',
        contactNumber: '1800-202-6161',
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
      LoanScheme(
        id: 'pnb_equipment_loan',
        name: 'PNB Farm Equipment Loan',
        bankName: 'Punjab National Bank',
        description: 'Loan for purchasing tractors and farm equipment',
        interestRate: 8.5,
        interestType: 'fixed',
        maxAmount: 2000000,
        minAmount: 100000,
        maxTenureMonths: 84,
        eligibility: [
          'Farmer with minimum 2 acres land',
          'Age 21-65 years',
          'Regular income source',
          'Good credit score',
        ],
        documents: [
          'Identity Proof',
          'Address Proof',
          'Land Documents',
          'Income Certificate',
          'Equipment Quotation',
        ],
        category: 'equipment',
        isSubsidized: false,
        subsidyPercentage: 0.0,
        applicationUrl: 'https://pnb.co.in/equipment-loan',
        contactNumber: '1800-180-2222',
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
      LoanScheme(
        id: 'icici_dairy_loan',
        name: 'ICICI Dairy Development Loan',
        bankName: 'ICICI Bank',
        description: 'Loan for dairy farming and livestock development',
        interestRate: 9.0,
        interestType: 'floating',
        maxAmount: 1000000,
        minAmount: 50000,
        maxTenureMonths: 72,
        eligibility: [
          'Dairy farmer or entrepreneur',
          'Experience in dairy farming',
          'Adequate land for cattle shed',
          'Age 21-60 years',
        ],
        documents: [
          'KYC Documents',
          'Project Report',
          'Land Documents',
          'Veterinary Certificate',
          'Financial Statements',
        ],
        category: 'dairy',
        isSubsidized: true,
        subsidyPercentage: 5.0,
        applicationUrl: 'https://icici.com/dairy-loan',
        contactNumber: '1800-200-3344',
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
      LoanScheme(
        id: 'axis_organic_loan',
        name: 'Axis Organic Farming Loan',
        bankName: 'Axis Bank',
        description: 'Special loan scheme for organic farming practices',
        interestRate: 6.5,
        interestType: 'fixed',
        maxAmount: 400000,
        minAmount: 75000,
        maxTenureMonths: 36,
        eligibility: [
          'Certified organic farmer',
          'Organic certification documents',
          'Minimum 3 years farming experience',
          'Age 25-65 years',
        ],
        documents: [
          'Organic Certification',
          'Land Documents',
          'Identity Proof',
          'Crop Plan',
          'Bank Statements',
        ],
        category: 'crop',
        isSubsidized: true,
        subsidyPercentage: 4.0,
        applicationUrl: 'https://axis.com/organic-loan',
        contactNumber: '1800-419-5555',
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  static Future<List<LoanScheme>> getLoanSchemesByCategory(
    String category,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('loan_schemes')
          .select('*')
          .eq('category', category)
          .eq('is_active', true)
          .order('interest_rate', ascending: true);

      return (response as List)
          .map((json) => LoanScheme.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching loan schemes by category: $e');
      return _getDefaultLoanSchemes()
          .where((scheme) => scheme.category == category)
          .toList();
    }
  }

  static Future<List<LoanScheme>> getRecommendedLoans(
    double farmSize,
    String cropType,
    double annualIncome,
  ) async {
    try {
      final prompt =
          '''
      Recommend suitable loan schemes based on farmer profile:
      Farm Size: $farmSize acres
      Crop Type: $cropType
      Annual Income: ₹$annualIncome
      
      Consider:
      1. Loan amount suitability
      2. Interest rates
      3. Tenure options
      4. Subsidy availability
      5. Farmer's repayment capacity
      
      Provide recommendations with reasoning.
      ''';

      final aiRecommendation = await GeminiAIService.analyzeWithPrompt(prompt);

      // Get all schemes and filter based on farmer profile
      final allSchemes = await getAllLoanSchemes();

      return allSchemes
          .where((scheme) {
            // Basic filtering logic
            final maxLoanAmount = annualIncome * 3; // 3x annual income
            return scheme.maxAmount <= maxLoanAmount &&
                scheme.minAmount <= annualIncome * 0.5;
          })
          .take(5)
          .toList();
    } catch (e) {
      print('Error getting recommended loans: $e');
      return _getDefaultLoanSchemes().take(3).toList();
    }
  }

  static Future<String> submitLoanApplication({
    required String schemeId,
    required double requestedAmount,
    required int tenureMonths,
    required String purpose,
    required Map<String, dynamic> documents,
  }) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final scheme = (await getAllLoanSchemes()).firstWhere(
        (s) => s.id == schemeId,
      );

      final applicationId = DateTime.now().millisecondsSinceEpoch.toString();

      final application = LoanApplication(
        id: applicationId,
        userId: user.id,
        schemeId: schemeId,
        schemeName: scheme.name,
        bankName: scheme.bankName,
        requestedAmount: requestedAmount,
        tenureMonths: tenureMonths,
        purpose: purpose,
        status: 'pending',
        applicationDate: DateTime.now(),
        documents: documents,
      );

      await SupabaseService.client
          .from('loan_applications')
          .insert(application.toJson());

      return applicationId;
    } catch (e) {
      print('Error submitting loan application: $e');
      throw Exception('Failed to submit loan application');
    }
  }

  static Future<List<LoanApplication>> getUserLoanApplications() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await SupabaseService.client
          .from('loan_applications')
          .select('*')
          .eq('user_id', user.id)
          .order('application_date', ascending: false);

      return (response as List)
          .map((json) => LoanApplication.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching loan applications: $e');
      return [];
    }
  }

  static Future<double> calculateEMI(
    double loanAmount,
    double interestRate,
    int tenureMonths,
  ) async {
    try {
      final monthlyRate = interestRate / (12 * 100);
      final emi =
          (loanAmount * monthlyRate * (1 + monthlyRate) * tenureMonths) /
          ((1 + monthlyRate) * tenureMonths - 1);
      return emi;
    } catch (e) {
      return 0.0;
    }
  }

  static Future<Map<String, dynamic>> getLoanEligibility({
    required double annualIncome,
    required double farmSize,
    required int age,
    required String cropType,
  }) async {
    try {
      final prompt =
          '''
      Assess loan eligibility for farmer:
      Annual Income: ₹$annualIncome
      Farm Size: $farmSize acres
      Age: $age years
      Crop Type: $cropType
      
      Provide:
      1. Eligibility status (eligible/not eligible/partially eligible)
      2. Maximum loan amount recommendation
      3. Suitable loan categories
      4. Documents required
      5. Tips to improve eligibility
      
      Format as JSON response.
      ''';

      final response = await GeminiAIService.analyzeWithPrompt(prompt);

      // Calculate basic eligibility
      final maxLoanAmount = annualIncome * 5; // 5x annual income
      final isEligible =
          age >= 18 && age <= 70 && farmSize >= 0.5 && annualIncome >= 50000;

      return {
        'eligible': isEligible,
        'maxLoanAmount': maxLoanAmount,
        'recommendedCategories': ['crop', 'equipment'],
        'aiRecommendation':
            response ?? 'Basic eligibility assessment completed',
        'creditScore': isEligible ? 'Good' : 'Needs Improvement',
      };
    } catch (e) {
      print('Error assessing loan eligibility: $e');
      return {
        'eligible': false,
        'maxLoanAmount': 0.0,
        'recommendedCategories': [],
        'aiRecommendation': 'Unable to assess eligibility',
        'creditScore': 'Unknown',
      };
    }
  }
}

class LoanSchemesNotifier extends StateNotifier<List<LoanScheme>> {
  LoanSchemesNotifier() : super([]) {
    _loadLoanSchemes();
  }

  Future<void> _loadLoanSchemes() async {
    try {
      final schemes = await BankLoanService.getAllLoanSchemes();
      state = schemes;
    } catch (e) {
      print('Error loading loan schemes: $e');
    }
  }

  Future<void> filterByCategory(String category) async {
    try {
      final schemes = await BankLoanService.getLoanSchemesByCategory(category);
      state = schemes;
    } catch (e) {
      print('Error filtering loan schemes: $e');
    }
  }

  Future<void> getRecommendations(
    double farmSize,
    String cropType,
    double annualIncome,
  ) async {
    try {
      final schemes = await BankLoanService.getRecommendedLoans(
        farmSize,
        cropType,
        annualIncome,
      );
      state = schemes;
    } catch (e) {
      print('Error getting loan recommendations: $e');
    }
  }

  Future<void> refresh() async {
    await _loadLoanSchemes();
  }
}

class LoanApplicationsNotifier extends StateNotifier<List<LoanApplication>> {
  LoanApplicationsNotifier() : super([]) {
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    try {
      final applications = await BankLoanService.getUserLoanApplications();
      state = applications;
    } catch (e) {
      print('Error loading loan applications: $e');
    }
  }

  Future<String> submitApplication({
    required String schemeId,
    required double requestedAmount,
    required int tenureMonths,
    required String purpose,
    required Map<String, dynamic> documents,
  }) async {
    try {
      final applicationId = await BankLoanService.submitLoanApplication(
        schemeId: schemeId,
        requestedAmount: requestedAmount,
        tenureMonths: tenureMonths,
        purpose: purpose,
        documents: documents,
      );

      await _loadApplications(); // Refresh the list
      return applicationId;
    } catch (e) {
      print('Error submitting application: $e');
      throw e;
    }
  }

  Future<void> refresh() async {
    await _loadApplications();
  }
}

final loanSchemesProvider =
    StateNotifierProvider<LoanSchemesNotifier, List<LoanScheme>>((ref) {
      return LoanSchemesNotifier();
    });

final loanApplicationsProvider =
    StateNotifierProvider<LoanApplicationsNotifier, List<LoanApplication>>((
      ref,
    ) {
      return LoanApplicationsNotifier();
    });

final cropLoansProvider = Provider<List<LoanScheme>>((ref) {
  final schemes = ref.watch(loanSchemesProvider);
  return schemes.where((scheme) => scheme.category == 'crop').toList();
});

final equipmentLoansProvider = Provider<List<LoanScheme>>((ref) {
  final schemes = ref.watch(loanSchemesProvider);
  return schemes.where((scheme) => scheme.category == 'equipment').toList();
});

final subsidizedLoansProvider = Provider<List<LoanScheme>>((ref) {
  final schemes = ref.watch(loanSchemesProvider);
  return schemes.where((scheme) => scheme.isSubsidized).toList();
});

final pendingApplicationsProvider = Provider<List<LoanApplication>>((ref) {
  final applications = ref.watch(loanApplicationsProvider);
  return applications.where((app) => app.status == 'pending').toList();
});
