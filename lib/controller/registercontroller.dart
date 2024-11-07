import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

import '../common/common.dart';


class RegisterController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  Rx<File?> profileImage = Rx<File?>(null);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();


  var name = '';
  var email = '';
  var password = '';
  RxString gender = ''.obs; // For gender selection
  RxString age = ''.obs; // To store and display the age
  RxBool isPasswordVisible = false.obs; // Add this line

  var isImgAvailable = false.obs;
  // final _picker = ImagePicker();
  var selectedImagePath = ''.obs;
  var selectedImageSize = ''.obs;
  var isLoading = false.obs;

  CollectionReference userDatBaseReference = FirebaseFirestore.instance.collection("user");
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  void calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int calculatedAge = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      calculatedAge--;
    }
    age.value = calculatedAge.toString();
  }

  void getImage(ImageSource imageSource) async {
    final pickedFile = await _picker.pickImage(source: imageSource);

    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;
      selectedImageSize.value = ((File(selectedImagePath.value)).lengthSync() / 1024 / 1024).toStringAsFixed(2) + " Mb";
      isImgAvailable.value = true;
    } else {
      isImgAvailable.value = false;
      snackMessage("No image selected");
    }
  }

  String? validName(String value) {
    if (value.length < 3) {
      return "Name must be 3 characters";
    }
    return null;
  }

  String? validEmail(String value) {
    if (!GetUtils.isEmail(value.trim())) {
      return "Please Provide Valid Email";
    }
    return null;
  }

  String? validPassword(String value) {
    if (value.length < 6) {
      return "Password must be of 6 characters";
    }
    return null;
  }

  Future<void> registration() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    isLoading.value = true;

    formKey.currentState!.save();

    userRegister(email.trim(), password.toString().trim()).then((credentials) {
      if (credentials != null) {
        saveDataToDb().then((_) {
          snackMessage('Registration successful!');
          Get.offAllNamed('/login');
        }).catchError((error) {
          snackMessage('Failed to save user data: $error');
        });
      } else {
        snackMessage("User already exists");
      }
      isLoading.value = false;
    }).catchError((error) {
      isLoading.value = false;
      snackMessage('Registration failed: $error');
    });
  }

  // Future<UserCredential?> userRegister(String email, String password) async {
  //   UserCredential? userCredential;
  //   try {
  //     userCredential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(email: email, password: password).then((value) async {
  //       if (value != null) {
  //         User? user = FirebaseAuth.instance.currentUser;
  //         await user!.sendEmailVerification();
  //         snackMessage('Check your Email');
  //         saveDataToDb().then((value) async {
  //           await FirebaseAuth.instance.currentUser!.sendEmailVerification();
  //           Get.offAllNamed('/login');
  //         });
  //         return;
  //       }
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     snackMessage('user already exist');
  //   } catch (e) {
  //
  //   }
  //
  //   return userCredential;
  // }

  Future<UserCredential?> userRegister(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        snackMessage('Check your email for verification');
        await saveDataToDb();
        Get.offAllNamed('/login');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        snackMessage('Email is already in use');
      } else if (e.code == 'invalid-email') {
        snackMessage('Invalid email format');
      } else {
        snackMessage('Registration failed: ${e.message}');
      }
      return null;
    } catch (e) {
      snackMessage('An unexpected error occurred');
      print(e); // Log error for further debugging
      return null;
    }
  }


  Future<String?> uploadFile(String filePath) async {
    File file = File(filePath);
    String randomStr = String.fromCharCodes(
        Iterable.generate(8, (_) => 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890'.codeUnitAt(Random().nextInt(62))));

    try {
      await _storage.ref('uploads/user/$randomStr').putFile(file);
      String downloadURL = await _storage.ref('uploads/user/$randomStr').getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      snackMessage('Error uploading file: ${e.message}');
      return null;
    }
  }


  Future<void> saveDataToDb() async {
    User? user = FirebaseAuth.instance.currentUser;

    String imageUrl = '';

    // Upload profile image if available
    if (profileImage.value != null) {
      imageUrl = await uploadFile(profileImage.value!.path) ?? '';
    }
    await userDatBaseReference.doc(user!.uid).set({
      'uid': user.uid,
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'phone_number': phoneNumberController.text,
      'gender': gender.value,
      'date_of_birth': dateOfBirthController.text,
      'age': age.value,
      'name': name, // Assuming name is a combination of first and last
      'email': email,
      'url': imageUrl,
    });
  }

  void updateProfile(String argUrl) {
    User? user = FirebaseAuth.instance.currentUser;

    if (isImgAvailable == true) {
      uploadFile(selectedImagePath.value).then((url) {
        if (url != null) {
          userDatBaseReference.doc(user!.uid).update({
            'uid': user.uid,
            'name': nameController.text,
            'email': emailController.text,
            'url': url
          });
        } else {
          snackMessage("Image not Uploaded");
        }
      });
    } else {
      userDatBaseReference.doc(user!.uid).update({
        'uid': user.uid,
        'name': nameController.text,
        'email': emailController.text,
        'url': argUrl == "" ? '' : argUrl,
      });

      user.updateEmail(emailController.text.toString().trim()).then((value) {
        snackMessage("Updated Successfully");
      }).catchError((error) {
        snackMessage("Email not Updated");
        print(error);
      });
    }
  }
}