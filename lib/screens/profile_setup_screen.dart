import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../providers/user_data_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_dialog.dart';
import '../helpers/disabled_focus_node.dart';

class ProfileSetupScreen extends StatefulWidget {
  static const routeName = '/profile-setup-screen';

  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  var _user = AppUser(
    id: 'NO_ID',
    name: 'NO_NAME',
    dateOfBirth: DateTime.now(),
    interests: ['NO_INTERESTS'],
  );
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  DateTime? _pickedDate;
  var _editProfile = false;
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
          content: _editProfile ? 'Saving Profile...' : 'Loading...',
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
        if (!_editProfile) {
          await authProvider.isNewUser(false);
        }
        if (mounted && !_editProfile) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (mounted && _editProfile) {
          Navigator.of(context).pop();
          await showCustomDialog(
            context,
            title: 'Profile Saved!',
            content: 'Your profile information has been updated.',
            showActionButton: true,
          );
        }
        setState(() {
          _isLoading = false;
        });
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
        maxHeight: 256,
        maxWidth: 256,
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

  ImageProvider<Object>? _showProfileImage() {
    if (_pickedImage != null) {
      return FileImage(_pickedImage!);
    } else {
      if (_editProfile) {
        if (_user.profilePictureURL != null) {
          return NetworkImage(_user.profilePictureURL!);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scaffoldBodyHeight = mediaQuery.size.height -
        (kToolbarHeight * 1.25) -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    _editProfile =
        (ModalRoute.of(context)?.settings.arguments as bool?) ?? false;
    if (_editProfile) {
      _user = Provider.of<UserDataProvider>(context).user;
      _pickedDate ??= _user.dateOfBirth;
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kTextTabBarHeight * 1.25,
        title: Text(
          _editProfile ? 'Edit your profile' : 'Setup your profile',
          textScaleFactor: 1.25,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: mediaQuery.size.width * .08),
          height: scaffoldBodyHeight,
          width: mediaQuery.size.width,
          child: Column(
            children: [
              SizedBox(
                height: scaffoldBodyHeight * .4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: scaffoldBodyHeight * .2,
                      child: ClipOval(
                        child: _showProfileImage() != null
                            ? FadeInImage(
                                fadeInDuration:
                                    const Duration(milliseconds: 300),
                                placeholder: const AssetImage(
                                    'assets/images/default_profile.png'),
                                image: _showProfileImage() ??
                                    const AssetImage(
                                        'assets/images/default_profile.png'),
                                imageErrorBuilder:
                                    (context, error, stackTrace) => Image.asset(
                                        'assets/images/default_profile.png'),
                              )
                            : Image.asset('assets/images/default_profile.png'),
                      ),
                    ),
                    // CircleAvatar(
                    //   radius: mediaQuery.devicePixelRatio * 40,
                    //   foregroundImage: _showProfileImage(),
                    //   backgroundImage: const AssetImage(
                    //     'assets/images/default_profile.png',
                    //   ),
                    // ),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(_pickedImage != null
                          ? 'Change Image'
                          : _user.profilePictureURL != null
                              ? 'Change Image'
                              : 'Set Image'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: scaffoldBodyHeight * .6,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextFormField(
                        initialValue: _editProfile ? _user.name : null,
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
                        initialValue:
                            _editProfile ? _user.interests.join(', ') : null,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Interests/Hobbies',
                            hintText: 'e.g. Travel, Video Games'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter at least one interest/hobby!';
                          } else if ((value
                                      .split(',')
                                      .map((string) => string.trim())
                                      .toList()
                                    ..removeWhere((string) => string.isEmpty))
                                  .length >
                              3) {
                            return 'Please enter at most three interest/hobby!';
                          }
                          return null;
                        },
                        onSaved: (interests) {
                          _user = _user.copyWith(
                            interests: interests!
                                .split(',')
                                .map((string) => string.trim())
                                .toList()
                              ..removeWhere((string) => string.isEmpty),
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
                            child: Text(_editProfile ? 'Save' : 'Continue'),
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
