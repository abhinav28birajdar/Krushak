import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/bank_loan_service.dart';

class BankLoansScreen extends ConsumerStatefulWidget {
  const BankLoansScreen({super.key});

  @override
  ConsumerState<BankLoansScreen> createState() => _BankLoansScreenState();
}

class _BankLoansScreenState extends ConsumerState<BankLoansScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedBank = 'All Banks';
  String _selectedLoanType = 'All Types';
  List<Map<String, dynamic>> _filteredLoans = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredLoans = BankLoanService.getAllLoans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterLoans() {
    setState(() {
      _filteredLoans = BankLoanService.getAllLoans();

      if (_selectedBank != 'All Banks') {
        _filteredLoans = _filteredLoans
            .where(
              (loan) => loan['bank'].toString().toLowerCase().contains(
                _selectedBank.toLowerCase(),
              ),
            )
            .toList();
      }

      if (_selectedLoanType != 'All Types') {
        _filteredLoans = _filteredLoans
            .where(
              (loan) => loan['loanType'].toString().toLowerCase().contains(
                _selectedLoanType.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch $url');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening link: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KrushakColors.background,
      appBar: AppBar(
        title: Text(
          'Agricultural Loans',
          style: KrushakTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: KrushakColors.primary,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Loans'),
            Tab(text: 'Filter'),
            Tab(text: 'Calculator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoansListTab(),
          _buildFilterTab(),
          _buildCalculatorTab(),
        ],
      ),
    );
  }

  Widget _buildLoansListTab() {
    return Column(
      children: [
        _buildHeaderCard(),
        Expanded(
          child: _filteredLoans.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredLoans.length,
                  itemBuilder: (context, index) {
                    final loan = _filteredLoans[index];
                    return _buildLoanCard(loan);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KrushakColors.primary.withOpacity(0.1),
            KrushakColors.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KrushakColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KrushakColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agricultural Banking Solutions',
                  style: KrushakTextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  'Compare loans from top banks and apply online',
                  style: KrushakTextStyles.body.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: KrushakColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_filteredLoans.length} Loans',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KrushakColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan['loanType'],
                        style: KrushakTextStyles.heading3.copyWith(
                          color: KrushakColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loan['bank'],
                        style: KrushakTextStyles.body.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KrushakColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    loan['interestRate'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loan['description'], style: KrushakTextStyles.body),
                const SizedBox(height: 12),

                // Key details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Max Amount',
                        loan['maxAmount'],
                        Icons.currency_rupee,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Tenure',
                        loan['tenure'],
                        Icons.schedule,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Processing',
                        loan['processingTime'],
                        Icons.timer,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Contact',
                        loan['contactNumber'],
                        Icons.phone,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Features
                if (loan['features'] != null &&
                    loan['features'].isNotEmpty) ...[
                  Text('Key Features', style: KrushakTextStyles.subheading),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: loan['features']
                        .map<Widget>(
                          (feature) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KrushakColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              feature.toString(),
                              style: TextStyle(
                                color: KrushakColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showLoanDetails(loan),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: KrushakColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(color: KrushakColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _launchUrl(loan['websiteUrl']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KrushakColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Apply Online',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Loans', style: KrushakTextStyles.heading2),
          const SizedBox(height: 20),

          // Bank filter
          Text('Select Bank', style: KrushakTextStyles.subheading),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedBank,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: ['All Banks', ...BankLoanService.getBankNames()]
                .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedBank = value!;
              });
              _filterLoans();
            },
          ),

          const SizedBox(height: 20),

          // Loan type filter
          Text('Loan Type', style: KrushakTextStyles.subheading),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLoanType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: ['All Types', ...BankLoanService.getLoanTypes()]
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedLoanType = value!;
              });
              _filterLoans();
            },
          ),

          const SizedBox(height: 30),

          // Reset filters button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedBank = 'All Banks';
                  _selectedLoanType = 'All Types';
                });
                _filterLoans();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: KrushakColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Reset Filters',
                style: TextStyle(color: KrushakColors.primary),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Filter results
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KrushakColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KrushakColors.accent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: KrushakColors.accent),
                const SizedBox(width: 12),
                Text(
                  'Found ${_filteredLoans.length} matching loans',
                  style: TextStyle(
                    color: KrushakColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return const _EMICalculatorWidget();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No loans found',
            style: KrushakTextStyles.heading3.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: KrushakTextStyles.body.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showLoanDetails(Map<String, dynamic> loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Text(loan['loanType'], style: KrushakTextStyles.heading2),
              Text(
                loan['bank'],
                style: KrushakTextStyles.body.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailSection('Description', loan['description']),

                    if (loan['eligibility'] != null)
                      _buildListSection(
                        'Eligibility Criteria',
                        loan['eligibility'],
                      ),

                    if (loan['documents'] != null)
                      _buildListSection(
                        'Required Documents',
                        loan['documents'],
                      ),

                    if (loan['features'] != null)
                      _buildListSection('Key Features', loan['features']),

                    const SizedBox(height: 20),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _launchUrl(loan['websiteUrl']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KrushakColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: KrushakTextStyles.subheading),
          const SizedBox(height: 8),
          Text(content, style: KrushakTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: KrushakTextStyles.subheading),
          const SizedBox(height: 8),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: KrushakColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: KrushakTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _EMICalculatorWidget extends StatefulWidget {
  const _EMICalculatorWidget();

  @override
  State<_EMICalculatorWidget> createState() => _EMICalculatorWidgetState();
}

class _EMICalculatorWidgetState extends State<_EMICalculatorWidget> {
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();

  Map<String, dynamic>? _emiResult;

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculateEMI() async {
    final loanAmount = double.tryParse(_loanAmountController.text);
    final interestRate = double.tryParse(_interestRateController.text);
    final tenure = int.tryParse(_tenureController.text);

    if (loanAmount == null || interestRate == null || tenure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid values'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await BankLoanService.calculateEMI(
      loanAmount,
      interestRate,
      tenure,
    );
    setState(() {
      _emiResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EMI Calculator', style: KrushakTextStyles.heading2),
          const SizedBox(height: 20),

          // Input fields
          TextField(
            controller: _loanAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Loan Amount (₹)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.currency_rupee),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _interestRateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Interest Rate (%)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.percent),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _tenureController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Tenure (months)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.schedule),
            ),
          ),
          const SizedBox(height: 24),

          // Calculate button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _calculateEMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: KrushakColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Calculate EMI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Results
          if (_emiResult != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'EMI Calculation Results',
                    style: KrushakTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  _buildEMIResultRow('Monthly EMI', '₹${_emiResult!['emi']}'),
                  _buildEMIResultRow(
                    'Total Amount',
                    '₹${_emiResult!['totalAmount']}',
                  ),
                  _buildEMIResultRow(
                    'Total Interest',
                    '₹${_emiResult!['totalInterest']}',
                  ),
                  _buildEMIResultRow(
                    'Principal Amount',
                    '₹${_emiResult!['principal']}',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEMIResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: KrushakTextStyles.body),
          Text(
            value,
            style: KrushakTextStyles.subheading.copyWith(
              color: KrushakColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
