import 'package:e_commerce/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: provider.formKey,
              child: Column(
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: provider.pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: provider.imageFile != null
                          ? FileImage(provider.imageFile!)
                          : null,
                      child: provider.imageFile == null
                          ? const Icon(Icons.camera_alt, size: 30)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  TextFormField(
                    controller: provider.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  DropdownButtonFormField<String>(
                    value: provider.selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.genders
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: provider.changeGender,
                  ),
                  const SizedBox(height: 16),

                  // Country Code + Phone
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: provider.selectedCountryCode,
                          decoration: const InputDecoration(
                            labelText: 'Code',
                            border: OutlineInputBorder(),
                          ),
                          items: provider.countryCodes
                              .map((code) => DropdownMenuItem(
                                    value: code,
                                    child: Text(code),
                                  ))
                              .toList(),
                          onChanged: provider.changeCountryCode,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: provider.phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter number'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => provider.submit(context),
                      child: const Text('Update Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
