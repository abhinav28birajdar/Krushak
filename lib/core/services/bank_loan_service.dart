class BankLoanService {
  static final List<Map<String, dynamic>> _maharashtraGraminBankLoans = [
    {
      'id': 'mgb_01',
      'bank': 'Maharashtra Gramin Bank',
      'loanType': 'Crop Loan',
      'maxAmount': '₹3,00,000',
      'interestRate': '7.0%',
      'tenure': '12 months',
      'description':
          'Short-term crop loans for seasonal agricultural activities',
      'eligibility': [
        'Farmers with land records',
        'Valid KYC documents',
        'Crop insurance',
      ],
      'documents': [
        'Land documents',
        'Aadhaar card',
        'PAN card',
        'Bank statements',
      ],
      'websiteUrl': 'https://mgb.org.in/crop-loan',
      'contactNumber': '1800-123-4567',
      'branch': 'Nearest MGB Branch',
      'processingTime': '7-10 days',
      'features': [
        'No prepayment penalty',
        'Flexible repayment',
        'Doorstep service',
      ],
    },
    {
      'id': 'mgb_02',
      'bank': 'Maharashtra Gramin Bank',
      'loanType': 'Farm Equipment Loan',
      'maxAmount': '₹5,00,000',
      'interestRate': '8.5%',
      'tenure': '5 years',
      'description':
          'Loans for purchasing agricultural equipment and machinery',
      'eligibility': [
        'Minimum 2 years farming experience',
        'Land ownership proof',
      ],
      'documents': ['Equipment quotation', 'Land documents', 'Income proof'],
      'websiteUrl': 'https://mgb.org.in/equipment-loan',
      'contactNumber': '1800-123-4567',
      'branch': 'Nearest MGB Branch',
      'processingTime': '10-15 days',
      'features': ['Subsidized rates', 'Easy EMI options', 'Quick approval'],
    },
  ];

  static final List<Map<String, dynamic>> _sbiLoans = [
    {
      'id': 'sbi_01',
      'bank': 'State Bank of India',
      'loanType': 'SBI Kisan Credit Card',
      'maxAmount': '₹1,60,000 per hectare',
      'interestRate': '7.0%',
      'tenure': '5 years',
      'description': 'Revolving credit facility for agricultural needs',
      'eligibility': [
        'All farmers - owner/tenant/sharecropper',
        'Age: 18-75 years',
      ],
      'documents': ['Application form', 'Land documents', 'Identity proof'],
      'websiteUrl':
          'https://sbi.co.in/web/agri-rural/agriculture/agricultural-banking/kisan-credit-card',
      'contactNumber': '1800-112-211',
      'branch': 'Nearest SBI Branch',
      'processingTime': '5-7 days',
      'features': [
        'Flexible repayment',
        'No collateral up to ₹1.60 lakh',
        'Crop insurance coverage',
      ],
    },
    {
      'id': 'sbi_02',
      'bank': 'State Bank of India',
      'loanType': 'SBI Farmer Package',
      'maxAmount': '₹50,00,000',
      'interestRate': '8.0%',
      'tenure': '10 years',
      'description': 'Comprehensive package for all agricultural needs',
      'eligibility': ['Progressive farmers', 'Good credit history'],
      'documents': [
        'Detailed project report',
        'Land documents',
        'Financial statements',
      ],
      'websiteUrl':
          'https://sbi.co.in/web/agri-rural/agriculture/agricultural-banking/farmer-package',
      'contactNumber': '1800-112-211',
      'branch': 'Nearest SBI Branch',
      'processingTime': '15-20 days',
      'features': [
        'Comprehensive coverage',
        'Technical support',
        'Insurance included',
      ],
    },
  ];

  static final List<Map<String, dynamic>> _nabardLoans = [
    {
      'id': 'nabard_01',
      'bank': 'National Bank for Agriculture and Rural Development (NABARD)',
      'loanType': 'NABARD Self Help Group Loan',
      'maxAmount': '₹10,00,000',
      'interestRate': '6.5%',
      'tenure': '3 years',
      'description': 'Loans through Self Help Groups for rural development',
      'eligibility': ['Member of registered SHG', 'Rural area resident'],
      'documents': ['SHG membership certificate', 'Group project proposal'],
      'websiteUrl': 'https://www.nabard.org/content1.aspx?id=23&catid=23',
      'contactNumber': '022-2653-4006',
      'branch': 'NABARD Regional Office',
      'processingTime': '20-30 days',
      'features': ['Group guarantee', 'Capacity building', 'Subsidy available'],
    },
    {
      'id': 'nabard_02',
      'bank': 'National Bank for Agriculture and Rural Development (NABARD)',
      'loanType': 'NABARD Watershed Development',
      'maxAmount': '₹15,00,000',
      'interestRate': '7.5%',
      'tenure': '7 years',
      'description': 'Loans for watershed development and water conservation',
      'eligibility': ['Farmers in watershed areas', 'Community participation'],
      'documents': ['Watershed development plan', 'Community consent letter'],
      'websiteUrl': 'https://www.nabard.org/content1.aspx?id=25&catid=25',
      'contactNumber': '022-2653-4006',
      'branch': 'NABARD Regional Office',
      'processingTime': '30-45 days',
      'features': [
        'Community development',
        'Technical assistance',
        'Subsidy component',
      ],
    },
  ];

  static final List<Map<String, dynamic>> _karnatakaLoans = [
    {
      'id': 'kb_01',
      'bank': 'Karnataka Bank',
      'loanType': 'KBL Kisan Credit Card',
      'maxAmount': '₹2,00,000',
      'interestRate': '7.0%',
      'tenure': '5 years',
      'description': 'Credit card facility for agricultural activities',
      'eligibility': ['Karnataka state farmers', 'Land ownership/tenancy'],
      'documents': [
        'Application with photograph',
        'Land documents',
        'Identity proof',
      ],
      'websiteUrl':
          'https://www.karnatakabank.com/personal-banking/agriculture-loans/kisan-credit-card',
      'contactNumber': '1800-425-1444',
      'branch': 'Nearest Karnataka Bank Branch',
      'processingTime': '7-10 days',
      'features': [
        'State government support',
        'Quick processing',
        'Flexible terms',
      ],
    },
    {
      'id': 'kb_02',
      'bank': 'Karnataka Bank',
      'loanType': 'KBL Gold Loan for Farmers',
      'maxAmount': '₹25,00,000',
      'interestRate': '8.5%',
      'tenure': '3 years',
      'description':
          'Gold loan facility specifically for agricultural purposes',
      'eligibility': [
        'Gold ornaments/coins as collateral',
        'Agricultural purpose',
      ],
      'documents': ['Gold appraisal certificate', 'Purpose declaration'],
      'websiteUrl':
          'https://www.karnatakabank.com/personal-banking/agriculture-loans/gold-loan',
      'contactNumber': '1800-425-1444',
      'branch': 'Nearest Karnataka Bank Branch',
      'processingTime': '1-2 days',
      'features': [
        'Quick disbursal',
        'Competitive rates',
        'Minimal documentation',
      ],
    },
  ];

  static final List<Map<String, dynamic>> _punjabLoans = [
    {
      'id': 'pnb_01',
      'bank': 'Punjab National Bank',
      'loanType': 'PNB Kisan Credit Card',
      'maxAmount': '₹1,60,000 per hectare',
      'interestRate': '7.0%',
      'tenure': '5 years',
      'description': 'Flexible credit facility for crop production',
      'eligibility': ['Individual/Joint borrowers who are farmers'],
      'documents': [
        'Application form',
        'Land records',
        'Identity & address proof',
      ],
      'websiteUrl':
          'https://www.pnbindia.in/agricultural-advance-kisan-credit-card.html',
      'contactNumber': '1800-180-2222',
      'branch': 'Nearest PNB Branch',
      'processingTime': '5-7 days',
      'features': ['Interest subvention', 'Crop insurance', 'ATM facility'],
    },
    {
      'id': 'pnb_02',
      'bank': 'Punjab National Bank',
      'loanType': 'PNB Krishak Bandhu',
      'maxAmount': '₹50,00,000',
      'interestRate': '8.0%',
      'tenure': '15 years',
      'description': 'Comprehensive loan for agriculture and allied activities',
      'eligibility': [
        'Farmers with proper land documents',
        'Good credit history',
      ],
      'documents': ['Project report', 'Land documents', 'Financial statements'],
      'websiteUrl': 'https://www.pnbindia.in/agricultural-advance.html',
      'contactNumber': '1800-180-2222',
      'branch': 'Nearest PNB Branch',
      'processingTime': '15-20 days',
      'features': [
        'Flexible repayment',
        'Competitive interest rates',
        'Processing fee waiver',
      ],
    },
  ];

  static List<Map<String, dynamic>> getAllLoans() {
    return [
      ..._maharashtraGraminBankLoans,
      ..._sbiLoans,
      ..._nabardLoans,
      ..._karnatakaLoans,
      ..._punjabLoans,
    ];
  }

  static List<Map<String, dynamic>> getLoansByBank(String bankName) {
    switch (bankName.toLowerCase()) {
      case 'maharashtra gramin bank':
        return _maharashtraGraminBankLoans;
      case 'sbi':
      case 'state bank of india':
        return _sbiLoans;
      case 'nabard':
      case 'national bank for agriculture and rural development':
        return _nabardLoans;
      case 'karnataka bank':
        return _karnatakaLoans;
      case 'punjab national bank':
      case 'pnb':
        return _punjabLoans;
      default:
        return [];
    }
  }

  static List<Map<String, dynamic>> getLoansByType(String loanType) {
    final allLoans = getAllLoans();
    return allLoans
        .where(
          (loan) => loan['loanType'].toString().toLowerCase().contains(
            loanType.toLowerCase(),
          ),
        )
        .toList();
  }

  static List<Map<String, dynamic>> getLoansByMaxAmount(double maxBudget) {
    final allLoans = getAllLoans();
    return allLoans.where((loan) {
      final amountStr = loan['maxAmount'].toString().replaceAll(
        RegExp(r'[₹,]'),
        '',
      );
      final amount = double.tryParse(amountStr) ?? 0;
      return amount <= maxBudget;
    }).toList();
  }

  static Map<String, dynamic>? getLoanById(String loanId) {
    final allLoans = getAllLoans();
    try {
      return allLoans.firstWhere((loan) => loan['id'] == loanId);
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> calculateEMI(
    double loanAmount,
    double interestRate,
    int tenureMonths,
  ) async {
    final monthlyRate = interestRate / (12 * 100);
    final emi =
        (loanAmount * monthlyRate * (1 + monthlyRate).pow(tenureMonths)) /
        ((1 + monthlyRate).pow(tenureMonths) - 1);

    final totalAmount = emi * tenureMonths;
    final totalInterest = totalAmount - loanAmount;

    return {
      'emi': emi.round(),
      'totalAmount': totalAmount.round(),
      'totalInterest': totalInterest.round(),
      'principal': loanAmount.round(),
    };
  }

  static List<String> getBankNames() {
    return [
      'Maharashtra Gramin Bank',
      'State Bank of India',
      'National Bank for Agriculture and Rural Development (NABARD)',
      'Karnataka Bank',
      'Punjab National Bank',
    ];
  }

  static List<String> getLoanTypes() {
    return [
      'Crop Loan',
      'Kisan Credit Card',
      'Farm Equipment Loan',
      'Gold Loan',
      'Self Help Group Loan',
      'Watershed Development',
      'Comprehensive Package',
    ];
  }
}

// Extension for power calculation
extension NumberExtension on double {
  double pow(int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}
