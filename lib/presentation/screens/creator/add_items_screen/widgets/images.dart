import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mashrou3i/core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../widgets/custom_button.dart';
import '../../dashboard_screen/logic/dashboard_cibit.dart';
import '../../dashboard_screen/logic/dashboard_states.dart';
import 'dart:io'; // Import for File

class ProfileImagesWidget extends StatelessWidget {
  const ProfileImagesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashBoardCubit, DashBoardStates>(
      listener: (context, state) {
        if (state is UpdateCreatorProfileSuccess) {
          final cubit = DashBoardCubit.get(context);
          cubit.profileImage = null;
          cubit.coverImage = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('Updated Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(Icons.check_circle_outline_outlined, color: Colors.black)
                ],
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = DashBoardCubit.get(context);
        final userModel = cubit.creatorProfile;

        Widget _buildImageWidget(File? fileImage, String? networkImageUrl, Widget errorWidget) {
          if (fileImage != null) {
            return Image.file(fileImage, fit: BoxFit.cover);
          } else if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
            return CachedNetworkImage(
              imageUrl: networkImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => errorWidget,
            );
          }
          return errorWidget; // fallback for no image
        }

        void _showImageDialog(Widget imageWidget) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: imageWidget,
              ),
            ),
          );
        }

        void _resetSelectedImages() {
          cubit.profileImage = null;
          cubit.coverImage = null;
          cubit.emit(DashBoardInitialState());
        }

        final bool hasPendingUploads = cubit.profileImage != null || cubit.coverImage != null;

        return SingleChildScrollView(
          child: Column(
            children: [
              if (state is UpdateCreatorProfileLoading)
                LinearProgressIndicator(color: Theme.of(context).primaryColor),
              const SizedBox(height: 20),
              Container(
                height: 190,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    // Cover Image Section
                    Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 140,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadiusDirectional.only(
                                topStart: Radius.circular(5.0),
                                topEnd: Radius.circular(5.0),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () => _showImageDialog(
                                _buildImageWidget(
                                  cubit.coverImage,
                                  userModel?.coverImage,
                                  const Icon(Icons.error), // Default error for cover
                                ),
                              ),
                              child: _buildImageWidget(
                                cubit.coverImage,
                                userModel?.coverImage,
                                const Center(child: Icon(Icons.add_box)), // Default placeholder for cover
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: IconButton(
                                onPressed: () async {
                                  await cubit.getCoverImage();
                                },
                                icon: const Icon(
                                  IconBroken.Camera,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Profile Image Section
                    CircleAvatar(
                      radius: 62,
                      backgroundColor: Colors.white,
                      child: Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: cubit.profileImage != null
                                ? FileImage(cubit.profileImage!)
                                : (userModel?.profileImage != null && userModel!.profileImage!.isNotEmpty
                                ? NetworkImage(userModel.profileImage!)
                                : const NetworkImage('https://static.vecteezy.com/system/resources/previews/027/708/418/non_2x/default-avatar-profile-icon-in-flat-style-free-vector.jpg')) as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: IconButton(
                                onPressed: () async {
                                  await cubit.getProfileImage();
                                },
                                icon: const Icon(
                                  IconBroken.Camera,
                                  color: Colors.black,
                                  size: 16,
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
              const SizedBox(height: 10),
              if (hasPendingUploads)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      children: [
                        if (cubit.profileImage != null)
                          Column(
                            children: [
                              if (state is AppUploadProfileImageLoading)
                                const LinearProgressIndicator(), // Use Linear for consistency with overall loading
                              if (state is! AppUploadProfileImageLoading) // Hide button during its specific upload
                                CustomButton(
                                  height: 50,
                                  text: LocaleKeys.uploadProfileImage.tr(),
                                  textColor: Colors.black,
                                  onPressed: () => cubit.uploadProfileImage(),
                                  color: Theme.of(context).primaryColor,
                                ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        if (cubit.coverImage != null)
                          Column(
                            children: [
                              if (state is AppUploadCoverImageLoading)
                                const LinearProgressIndicator(), // Use Linear for consistency
                              if (state is! AppUploadCoverImageLoading) // Hide button during its specific upload
                                CustomButton(
                                  height: 50,
                                  text: LocaleKeys.uploadCoverImage.tr(),
                                  textColor: Colors.black, // Assuming default color if not specified
                                  onPressed: () => cubit.uploadCoverImage(),
                                  color: Theme.of(context).primaryColor,
                                ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        CustomButton(
                          height: 50,
                          text: LocaleKeys.cancel.tr(),
                          onPressed: _resetSelectedImages,
                          color: Colors.red,
                          textColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}