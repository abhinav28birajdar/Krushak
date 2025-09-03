import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';

class FarmManagementScreen extends StatefulWidget {
  const FarmManagementScreen({super.key});

  @override
  State<FarmManagementScreen> createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen> {
  List<Map<String, dynamic>> farms = [];
  List<Map<String, dynamic>> crops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final [farmsData, cropsData] = await Future.wait([
        SupabaseService.getUserFarms(),
        SupabaseService.getUserCrops(),
      ]);

      setState(() {
        farms = farmsData;
        crops = cropsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Farm Management',
          style: KrushakTextStyles.h4.copyWith(color: Colors.white),
        ),
        backgroundColor: KrushakColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFarmDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: KrushakColors.primaryGreen,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: KrushakColors.primaryGreen,
                    tabs: const [
                      Tab(text: 'My Farms'),
                      Tab(text: 'Active Crops'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [_buildFarmsTab(), _buildCropsTab()],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFarmsTab() {
    return farms.isEmpty
        ? _buildEmptyState('No farms added yet', Icons.agriculture)
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: farms.length,
            itemBuilder: (context, index) {
              final farm = farms[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: KrushakColors.primaryGreen,
                    child: const Icon(Icons.agriculture, color: Colors.white),
                  ),
                  title: Text(
                    farm['name'] ?? 'Unknown Farm',
                    style: KrushakTextStyles.bodyLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Size: ${farm['size_acres']} acres'),
                      Text('Location: ${farm['location']}'),
                      Text('Soil Type: ${farm['soil_type']}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditFarmDialog(farm);
                      } else if (value == 'delete') {
                        _deleteFarm(farm['id']);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildCropsTab() {
    return crops.isEmpty
        ? _buildEmptyState('No active crops', Icons.eco)
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: KrushakColors.secondaryYellow,
                    child: const Icon(Icons.eco, color: Colors.white),
                  ),
                  title: Text(
                    crop['crop_name'] ?? 'Unknown Crop',
                    style: KrushakTextStyles.bodyLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Variety: ${crop['variety']}'),
                      Text('Planted: ${_formatDate(crop['planting_date'])}'),
                      Text(
                        'Expected Harvest: ${_formatDate(crop['expected_harvest_date'])}',
                      ),
                      Text('Area: ${crop['area_acres']} acres'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(crop['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      crop['status'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: KrushakTextStyles.bodyLarge.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'growing':
        return Colors.green;
      case 'harvested':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.orange;
    }
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

  void _showAddFarmDialog() {
    final nameController = TextEditingController();
    final sizeController = TextEditingController();
    final locationController = TextEditingController();
    String selectedSoilType = 'Loamy';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Farm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Farm Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Size (acres)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSoilType,
                decoration: const InputDecoration(
                  labelText: 'Soil Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Loamy', 'Clay', 'Sandy', 'Silty', 'Chalky', 'Peaty']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => selectedSoilType = value!,
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
              if (nameController.text.isNotEmpty &&
                  sizeController.text.isNotEmpty &&
                  locationController.text.isNotEmpty) {
                try {
                  await SupabaseService.addFarm({
                    'name': nameController.text,
                    'size_acres': double.parse(sizeController.text),
                    'location': locationController.text,
                    'soil_type': selectedSoilType,
                  });
                  Navigator.pop(context);
                  _loadData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding farm: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditFarmDialog(Map<String, dynamic> farm) {
    final nameController = TextEditingController(text: farm['name']);
    final sizeController = TextEditingController(
      text: farm['size_acres'].toString(),
    );
    final locationController = TextEditingController(text: farm['location']);
    String selectedSoilType = farm['soil_type'] ?? 'Loamy';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Farm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Farm Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Size (acres)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSoilType,
                decoration: const InputDecoration(
                  labelText: 'Soil Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Loamy', 'Clay', 'Sandy', 'Silty', 'Chalky', 'Peaty']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => selectedSoilType = value!,
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
              try {
                await SupabaseService.updateFarm(farm['id'], {
                  'name': nameController.text,
                  'size_acres': double.parse(sizeController.text),
                  'location': locationController.text,
                  'soil_type': selectedSoilType,
                });
                Navigator.pop(context);
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating farm: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFarm(String farmId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm'),
        content: const Text('Are you sure you want to delete this farm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService.deleteFarm(farmId);
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting farm: $e')));
      }
    }
  }
}
