import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../providers/user_data_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/show_dialog.dart';
import '../helpers/disabled_focus_node.dart';

class ProfileSetupScreen extends StatefulWidget {
  static const routeName = '/profile-setup-screen';

  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  AppUser _user = AppUser(
    id: 'NO_ID',
    name: 'NO_NAME',
    dateOfBirth: DateTime.now(),
    interests: ['NO_INTERESTS'],
  );
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  DateTime? _pickedDate;

  var _isLoading = false;

  Future<void> _saveForm() async {
    try {
      var profileProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      var authInstance = FirebaseAuth.instance;
      var isValid = _formKey.currentState!.validate();
      if (isValid) {
        setState(() {
          _isLoading = true;
        });
        showCustomDialog(
          context,
          content: 'Loading...',
          showActionButton: false,
        );
        _formKey.currentState!.save();
        profileProvider.setUserInfo = _user.copyWith(
          emailAddress: authInstance.currentUser!.email,
          phoneNumber: authInstance.currentUser!.phoneNumber,
        );
        if (_pickedImage != null) {
          await profileProvider.uploadProfileImage(_pickedImage!);
        }
        await profileProvider.fetchAndSetUserProfileInfo();
        await authProvider.isNewUser(false);
        if (!mounted) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (error) {
      Navigator.of(context).pop();
      showCustomDialog(context,
          title: 'Unknow Error!',
          content: error.toString(),
          showActionButton: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget dialogMenuItem({
    required String assetImage,
    required String title,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Image.asset(
            assetImage,
            height: 40,
            width: 40,
          ),
          const SizedBox(
            width: 50,
          ),
          Text(title)
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    ImageSource? imageSource = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(30),
          title: const Text(
            'Choose source',
            textAlign: TextAlign.center,
          ),
          children: [
            dialogMenuItem(
              assetImage: 'assets/images/camera_icon_64x64.png',
              title: 'Camera',
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(
              height: 30,
              child: Divider(
                indent: 30,
                endIndent: 30,
              ),
            ),
            dialogMenuItem(
              assetImage: 'assets/images/gallery_icon_64x64.png',
              title: 'Gallery',
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        );
      },
    );
    if (imageSource != null) {
      var pickedImage = await ImagePicker().pickImage(
        maxHeight: 128,
        maxWidth: 128,
        source: imageSource,
        preferredCameraDevice: CameraDevice.front,
      );
      if (pickedImage == null) {
        return;
      }
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ),
    ).then((dateTime) {
      if (dateTime == null) {
        return;
      }
      setState(() {
        _pickedDate = dateTime;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scaffoldBodyHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: mediaQuery.size.width * .08),
          height: scaffoldBodyHeight,
          width: mediaQuery.size.width,
          child: Column(
            children: [
              SizedBox(
                height: scaffoldBodyHeight * .2,
                child: Center(
                  child: Text(
                    'Setup your profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SizedBox(
                height: scaffoldBodyHeight * .3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: mediaQuery.devicePixelRatio * 40,
                      foregroundImage: _pickedImage == null
                          ? null
                          : FileImage(_pickedImage!),
                      backgroundImage: const AssetImage(
                        'assets/images/default_profile.png',
                      ),
                    ),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Set Image'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: scaffoldBodyHeight * .5,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Full Name',
                            hintText: 'e.g. John Smith'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name!';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          _user = _user.copyWith(name: name!.trim());
                        },
                      ),
                      TextFormField(
                        focusNode: AlwaysDisabledFocusNode(),
                        enableInteractiveSelection: false,
                        decoration: InputDecoration(
                          labelText: 'Date Of Birth',
                          hintText: _pickedDate != null
                              ? DateFormat.yMMMd().format(_pickedDate!)
                              : 'Not set',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: InkWell(
                            onTap: _showDatePicker,
                            child: const Icon(Icons.edit),
                          ),
                        ),
                        onSaved: (_) {
                          _user = _user.copyWith(dateOfBirth: _pickedDate);
                        },
                        validator: (_) {
                          if (_pickedDate == null) {
                            return 'Please set your date of birth!';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Interests/Hobbies',
                            hintText: 'e.g. Travel, Video Games'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter at least one interest/hobby!';
                          }
                          return null;
                        },
                        onSaved: (interests) {
                          _user = _user.copyWith(
                            interests: interests!
                                .split(',')
                                .map((string) => string.trim())
                                .toList(),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(mediaQuery.size.width * .4,
                                  mediaQuery.size.height * .07),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _isLoading == true ? null : _saveForm,
                            child: const Text('Continue'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
