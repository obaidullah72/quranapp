import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quranapp/common/constants.dart';

import 'package:get/get.dart';

import '../controller/registercontroller.dart';
import '../widgets/decoration_widget.dart';

class RegisterScreen extends StatelessWidget {
  RegisterController _registrationController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: height * 0.3,
                    decoration: BoxDecoration(
                      color: Constants.kPrimary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(70),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 40,
                    right: 30,
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image Picker
                    Obx(() => GestureDetector(
                          onTap: () => _registrationController.pickImage(),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _registrationController
                                        .profileImage.value !=
                                    null
                                ? FileImage(
                                    _registrationController.profileImage.value!)
                                : null,
                            child: _registrationController.profileImage.value ==
                                    null
                                ? Icon(Icons.camera_alt,
                                    size: 40, color: Colors.grey[800])
                                : null,
                          ),
                        )),
                    SizedBox(height: 20),
                    Form(
                      key: _registrationController.formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          _buildTextField(
                              controller:
                                  _registrationController.firstNameController,
                              label: "First Name",
                              icon: Icons.person),
                          // Last Name Field
                          _buildTextField(
                              controller:
                                  _registrationController.lastNameController,
                              label: "Last Name",
                              icon: Icons.person),
                          // Phone Number Field
                          _buildTextField(
                              controller:
                                  _registrationController.phoneNumberController,
                              label: "Phone Number",
                              icon: Icons.phone,
                              inputType: TextInputType.phone),
                          // Gender Selection Dropdown
                          _buildGenderDropdown(),

                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                    child: _buildDateOfBirthPicker(context)),
                                SizedBox(
                                  width: 8,
                                ),
                                Obx(() => Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${_registrationController.age.value} years',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    )),
                              ],
                            ),
                          ),

                          // // Date of Birth Picker
                          // _buildDateOfBirthPicker(context),
                          // // Display Age
                          // Obx(() => Text(
                          //   'Your Age: ${_registrationController.age.value} years',
                          //   style: TextStyle(fontSize: 12),
                          // )),
                          // // Existing fields like email, password...

                          // Submit Button
                          // _buildSubmitButton(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              // The validator receives the text that the user has entered.
                              controller:
                                  _registrationController.nameController,
                              onSaved: (value) {
                                _registrationController.name = value!;
                              },
                              validator: (value) {
                                return _registrationController
                                    .validName(value!);
                              },
                              decoration: DecorationWidget(
                                  context, "User Name", Icons.person),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              // The validator receives the text that the user has entered.
                              controller:
                                  _registrationController.emailController,
                              onSaved: (value) {
                                _registrationController.email = value!;
                              },
                              validator: (value) {
                                return _registrationController
                                    .validEmail(value!);
                              },
                              decoration: DecorationWidget(
                                  context, "Email", Icons.email),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Obx(() => TextFormField(
                              obscureText: !_registrationController.isPasswordVisible.value,
                              controller: _registrationController.passwordController,
                              onSaved: (value) {
                                _registrationController.password = value!;
                              },
                              validator: (value) {
                                return _registrationController.validPassword(value!);
                              },
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.vpn_key),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _registrationController.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    _registrationController.isPasswordVisible.value =
                                    !_registrationController.isPasswordVisible.value;
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            )),
                          ),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Constants.kPrimary,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 10),
                                textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'CormorantGaramond'),
                              ),
                              child: _registrationController.isLoading.value
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : FittedBox(
                                      // child: Obx(
                                      //   () => _registrationController
                                      //           .isLoading.value
                                      //       ? Center(
                                      //           child:
                                      //               CircularProgressIndicator(
                                      //             color: Colors.white,
                                      //           ),
                                      //         )
                                      //       : Text(
                                      //           'Register',
                                      //         ),
                                      // ),
                                      child: Obx(
                                        () => _registrationController
                                                .isLoading.value
                                            ? CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : Text('Register'),
                                      ),
                                    ),
                              onPressed: () {
                                _registrationController.registration();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text('Already have an account ? '),
                  TextButton(
                    onPressed: () {
                      // FirebaseServices op = FirebaseServices();
                      // op.signOut();
                      Get.offAllNamed('/login');
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: Constants.kPrimary, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated _buildTextField method
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  // Helper method to create gender dropdown
  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: _registrationController.gender.value.isNotEmpty
              ? _registrationController.gender.value
              : null,
          // Ensure null handling when no value is set
          items: ['Male', 'Female', 'Other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            _registrationController.gender.value = newValue ?? '';
          },
          decoration: InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a gender';
            }
            return null;
          },
        ),
      ),
    );
  }

  // Helper method to create date picker for date of birth
  Widget _buildDateOfBirthPicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _registrationController.dateOfBirthController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            _registrationController.dateOfBirthController.text =
                pickedDate.toLocal().toString().split(' ')[0];
            _registrationController.calculateAge(pickedDate);
          }
        },
      ),
    );
  }

// Helper method to create the submit button
// Widget _buildSubmitButton() {
//   return SizedBox(
//     width: double.infinity,
//     height: 50,
//     child: ElevatedButton(
//       onPressed: () {
//         _registrationController.registration();
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Constants.kPrimary,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//       ),
//       child: Obx(
//             () => _registrationController.isLoading.value
//             ? CircularProgressIndicator(color: Colors.white)
//             : Text('Register'),
//       ),
//     ),
//   );
// }
}
