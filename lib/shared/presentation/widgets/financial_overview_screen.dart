import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';

class FinancialOverviewScreen extends StatefulWidget {
  const FinancialOverviewScreen({super.key});

  @override
  State<FinancialOverviewScreen> createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  List<Map<String, dynamic>> financialRecords = [];
  Map<String, double> summary = {
    'totalIncome': 0.0,
    'totalExpenses': 0.0,
    'netProfit': 0.0,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    try {
      final records = await SupabaseService.getFinancialRecords();
      setState(() {
        financialRecords = records;
        _calculateSummary();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading financial data: $e')),
      );
    }
  }

  void _calculateSummary() {
    double income = 0.0;
    double expenses = 0.0;

    for (final record in financialRecords) {
      final amount = (record['amount'] as num?)?.toDouble() ?? 0.0;
      if (record['type'] == 'income') {
        income += amount;
      } else {
        expenses += amount;
      }
    }

    summary = {
      'totalIncome': income,
      'totalExpenses': expenses,
      'netProfit': income - expenses,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Overview',
          style: KrushakTextStyles.h4.copyWith(color: Colors.white),
        ),
        backgroundColor: KrushakColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecordDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCards(),
                Expanded(child: _buildRecordsList()),
              ],
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Income',
              '₹${_formatCurrency(summary['totalIncome']!)}',
              Colors.green,
              Icons.trending_up,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Total Expenses',
              '₹${_formatCurrency(summary['totalExpenses']!)}',
              Colors.red,
              Icons.trending_down,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Net Profit',
              '₹${_formatCurrency(summary['netProfit']!)}',
              summary['netProfit']! >= 0 ? Colors.green : Colors.red,
              summary['netProfit']! >= 0 ? Icons.attach_money : Icons.money_off,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: KrushakTextStyles.labelMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: KrushakTextStyles.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (financialRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No financial records yet',
              style: KrushakTextStyles.bodyLarge.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: financialRecords.length,
      itemBuilder: (context, index) {
        final record = financialRecords[index];
        final isIncome = record['type'] == 'income';
        final amount = (record['amount'] as num?)?.toDouble() ?? 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green : Colors.red,
              child: Icon(
                isIncome ? Icons.add : Icons.remove,
                color: Colors.white,
              ),
            ),
            title: Text(
              record['description'] ?? 'No description',
              style: KrushakTextStyles.bodyLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${record['category'] ?? 'Other'}'),
                Text('Date: ${_formatDate(record['date'])}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}₹${_formatCurrency(amount)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            onTap: () => _showEditRecordDialog(record),
          ),
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Not set';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _showAddRecordDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'income';
    String selectedCategory = 'Sales';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Financial Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['income', 'expense']
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.capitalize()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      selectedCategory = selectedType == 'income'
                          ? 'Sales'
                          : 'Seeds';
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _getCategories(selectedType)
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Date: ${_formatDate(selectedDate.toIso8601String())}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (descriptionController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  try {
                    await SupabaseService.addFinancialRecord({
                      'description': descriptionController.text,
                      'amount': double.parse(amountController.text),
                      'type': selectedType,
                      'category': selectedCategory,
                      'date': selectedDate.toIso8601String(),
                    });
                    Navigator.pop(context);
                    _loadFinancialData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding record: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRecordDialog(Map<String, dynamic> record) {
    final descriptionController = TextEditingController(
      text: record['description'],
    );
    final amountController = TextEditingController(
      text: record['amount'].toString(),
    );
    String selectedType = record['type'] ?? 'income';
    String selectedCategory = record['category'] ?? 'Sales';
    DateTime selectedDate =
        DateTime.tryParse(record['date'] ?? '') ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Financial Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['income', 'expense']
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.capitalize()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      selectedCategory = selectedType == 'income'
                          ? 'Sales'
                          : 'Seeds';
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _getCategories(selectedType)
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Date: ${_formatDate(selectedDate.toIso8601String())}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Record'),
                    content: const Text(
                      'Are you sure you want to delete this record?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await SupabaseService.deleteFinancialRecord(record['id']);
                    Navigator.pop(context);
                    _loadFinancialData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting record: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await SupabaseService.updateFinancialRecord(record['id'], {
                    'description': descriptionController.text,
                    'amount': double.parse(amountController.text),
                    'type': selectedType,
                    'category': selectedCategory,
                    'date': selectedDate.toIso8601String(),
                  });
                  Navigator.pop(context);
                  _loadFinancialData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating record: $e')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCategories(String type) {
    if (type == 'income') {
      return ['Sales', 'Subsidy', 'Investment', 'Other'];
    } else {
      return [
        'Seeds',
        'Fertilizer',
        'Pesticide',
        'Equipment',
        'Labor',
        'Transportation',
        'Other',
      ];
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
