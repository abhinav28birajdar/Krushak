import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfileSettingsScreen({super.key, this.userData});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _selectedFarmerType = 'Small Scale';
  int _experienceYears = 1;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.userData != null) {
      _nameController.text = widget.userData!['full_name'] ?? '';
      _phoneController.text = widget.userData!['phone'] ?? '';
      _locationController.text = widget.userData!['location'] ?? '';
      _districtController.text = widget.userData!['district'] ?? '';
      _pincodeController.text = widget.userData!['pincode'] ?? '';
      _selectedFarmerType = widget.userData!['farmer_type'] ?? 'Small Scale';
      _experienceYears = widget.userData!['experience_years'] ?? 1;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await SupabaseService.updateUserProfile({
          'full_name': _nameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'district': _districtController.text,
          'pincode': _pincodeController.text,
          'farmer_type': _selectedFarmerType,
          'experience_years': _experienceYears,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Settings',
          style: KrushakTextStyles.h4.copyWith(color: Colors.white),
        ),
        backgroundColor: KrushakColors.primaryGreen,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _districtController,
                label: 'District',
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pincodeController,
                label: 'Pincode',
                icon: Icons.pin_drop,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Farmer Type',
                value: _selectedFarmerType,
                icon: Icons.agriculture,
                items: [
                  'Small Scale',
                  'Medium Scale',
                  'Large Scale',
                  'Progressive',
                  'Organic',
                ],
                onChanged: (value) =>
                    setState(() => _selectedFarmerType = value!),
              ),
              const SizedBox(height: 16),
              _buildSliderField(
                label: 'Experience (Years)',
                value: _experienceYears.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                onChanged: (value) =>
                    setState(() => _experienceYears = value.round()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KrushakColors.primary),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KrushakColors.primary),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.round()} years',
          style: KrushakTextStyles.labelLarge,
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: KrushakColors.primaryGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
