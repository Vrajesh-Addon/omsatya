import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImageFromNetwork extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final WidgetShape widgetShape;
  final BoxFit boxFit;

  const ImageFromNetwork(
      this.imageUrl, {
        super.key,
        this.width = 100,
        this.height = 100,
        this.widgetShape = WidgetShape.rounded,
        this.boxFit = BoxFit.cover,
      });

  @override
  Widget build(BuildContext context) {

    return ShapeContainer(
      width: width,
      height: height,
      widgetShape: widgetShape,
      child: imageUrl == null || imageUrl == ""
          ? Icon(Icons.hide_image_outlined, size: height / 2)
          : CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            image: DecorationImage(
              fit: boxFit,
              image: imageProvider,
            ),
          ),
        ),
        placeholder: (context, url) =>
        const Loading(loadingType: LoadingType.image),
        errorWidget: (context, url, error) =>
            Icon(Icons.broken_image_outlined, size: height / 6),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  final Color? buttonColor;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton(
      {super.key,
        required this.text,
        required this.onPressed,
        this.focusNode,
        this.buttonColor,
        this.padding,
      });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      focusNode: focusNode,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: padding,
      ),
      child: Text(text,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final FocusNode? focusNode;
  final String? msgText;

  const DeleteButton({super.key, required this.onPressed, this.focusNode, required this.msgText});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.onPrimary,
        child: Icon(
          Icons.delete_outline,
          size: 18.0,
          color: AppColors.danger,
        ),
      ),
      onPressed: () {
        AppGlobals.showConfirmDeleteDialog(context, msgText).then((value) {
          if (value == DialogResult.ok) {
            onPressed();
          }
        });
      },
    );
  }
}

class ImageFromConstant extends StatelessWidget {
  final String? name;
  final double width;
  final double height;
  final WidgetShape widgetShape;
  final BoxFit boxFit;

  const ImageFromConstant(
      this.name, {
        super.key,
        this.width = 100,
        this.height = 100,
        this.widgetShape = WidgetShape.rounded,
        this.boxFit = BoxFit.cover,
      });

  @override
  Widget build(BuildContext context) {

    return ShapeContainer(
      width: width,
      height: height,
      widgetShape: widgetShape,
      child: name == null || name == ""
          ? Icon(Icons.hide_image_outlined, size: height / 2)
          : CachedNetworkImage(
        imageUrl: name!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            image: DecorationImage(
              fit: boxFit,
              image: imageProvider,
            ),
          ),
        ),
        placeholder: (context, url) =>
        const Loading(loadingType: LoadingType.image),
        errorWidget: (context, url, error) =>
            Icon(Icons.broken_image_outlined, size: height / 6),
      ),
    );
  }
}

class ImageFormField extends FormField<File> {
  final String labelText;
  final String imageUrl;
  final double width;
  final double height;
  final WidgetShape widgetShape;

  ImageFormField({
    super.key,
    this.imageUrl = "",
    this.labelText = "",
    this.width = 100,
    this.height = 100,
    this.widgetShape = WidgetShape.rounded,
    required FormFieldSetter<File> onChanged,
    //required FormFieldValidator<File> validator,
  }) : super(
    onSaved: onChanged,
    //validator: validator,
    builder: (FormFieldState<File> state) {
      BorderRadius borderRadius =
      WidgetMethods.getBorderRadius(widgetShape, width, height);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: labelText == "" ? false : true,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
              child: Text(
                labelText,
                style: Theme
                    .of(state.context)
                    .textTheme
                    .bodySmall,
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              Container(
                //padding: const EdgeInsets.all(AppDimen.paddingSmall),
                height: height,
                width: width,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: borderRadius,
                  color: Theme
                      .of(state.context)
                      .scaffoldBackgroundColor,
                ),
                child: InkWell(
                  // onTap: () => _handleAddChangePressed(imageUrl, state),
                  onTap: () => requestMultiplePermissions(imageUrl, state),
                  borderRadius: borderRadius,
                  child: Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      image: state.value == null
                          ? null
                          : DecorationImage(
                        image: Image
                            .file(
                          state.value!,
                        )
                            .image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: (state.value == null && imageUrl.isNotEmpty)
                        ? ImageFromNetwork(
                      height: height,
                      width: width,
                      imageUrl,
                      widgetShape: widgetShape,
                    )
                        : state.value == null
                        ? const Icon(Icons.image_outlined)
                        : null,
                  ),
                ),
              ),
              Positioned(
                right: 2.0,
                bottom: 2.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      color: AppColors.primary,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      color: Colors.white,
                      size: 20,
                      isImageExist(imageUrl, state) == false
                          ? Icons.add
                          : Icons.edit,
                    ),
                  ),
                  onTap: () => requestMultiplePermissions(imageUrl, state),
                  // onTap: () => _handleAddChangePressed(imageUrl, state),
                ),
              ),
            ],
          ),
          state.hasError
              ? Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 10.0,
            ),
            child: Text(
              state.errorText!,
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.danger,
              ),
            ),
          )
              : Container()
        ],
      );
    },
  );

  static Future<void> requestPermission(String imageUrl, FormFieldState<File> state) async {

    await Permission.camera
        .onDeniedCallback(() async {
      showMessage("Permission ==> 2 isDenied");
      await Permission.camera.request();
    }).onGrantedCallback(() {
      showMessage("Permission ==> isGranted");
      _handleAddChangePressed(imageUrl, state);
    }).onPermanentlyDeniedCallback(() async {
      showMessage("Permission ==> isPermanentlyDenied");
      final res = (await showDialog(
      context: state.context,
      barrierDismissible: false,
          builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'This permission is needed for camera. You can grant permission in the app settings.'),
        actions: [
          TextButton(
            onPressed: () async {
              bool result = await openAppSettings();
              if (result) {
                var ps = await Permission.camera.status;
                Navigator.of(context).pop(ps == PermissionStatus.granted);
              } else {
                Navigator.of(context).pop(false);
              }
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
      ));
    }).request();

  }

  static Future<void> requestMultiplePermissions(String imageUrl, FormFieldState<File> state) async {
    PermissionStatus status = await Permission.camera.request();

    // Request permission if not granted
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    // Check the permission result
    if (status.isGranted) {
      if (await Permission.manageExternalStorage.isGranted || await Permission.photos.isGranted) {
        _handleAddChangePressed(imageUrl, state);
      } else {
        PermissionStatus status;

        if (Platform.isAndroid) {
          status = await Permission.manageExternalStorage.request();
        } else {
          status = await Permission.photos.request();
        }
        // final status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          _handleAddChangePressed(imageUrl, state);
        } else if (status.isDenied) {
          print("Permission denied");
        } else if (Platform.isIOS || status.isPermanentlyDenied) {
          final res = (await showDialog(
            context: state.context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'This permission is needed for camera. You can grant permission in the app settings.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    bool result = await openAppSettings();
                    if (result) {
                      var ps;
                      if (Platform.isAndroid) {
                        status = await Permission.manageExternalStorage.request();
                      } else {
                        status = await Permission.photos.request();
                      }
                      Navigator.of(context).pop(ps == PermissionStatus.granted);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  },
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ));
        }
      }

    } else {
      final res = (await showDialog(
        context: state.context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'This permission is needed for camera. You can grant permission in the app settings.'),
          actions: [
            TextButton(
              onPressed: () async {
                bool result = await openAppSettings();
                if (result) {
                  var ps = await Permission.camera.status;
                  Navigator.of(context).pop(ps == PermissionStatus.granted);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ));
    }


    /*for (var permission in permissions) {
      await permission.request().then((status) async {
        if (status.isDenied) {
          showMessage("Permission ==> 2 isDenied");
          await permission.request();
        } else if (status.isGranted) {
          showMessage("Permission ==> isGranted");
          _handleAddChangePressed(imageUrl, state);
        } else if (status.isPermanentlyDenied) {
          showMessage("Permission ==> isPermanentlyDenied");
          final res = (await showDialog(
            context: state.context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'This permission is needed for camera. You can grant permission in the app settings.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    bool result = await openAppSettings();
                    if (result) {
                      var ps = await Permission.camera.status;
                      Navigator.of(context).pop(ps == PermissionStatus.granted);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  },
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ));
        }
      });
    }*/
  }

  static Future _handleAddChangePressed(
      String imageUrl, FormFieldState<File> state) async {
    // var result = await requestPermission(Permission.camera);
    // if(!result) return;
    // showMessage("result ==> $result");

    int? option = await showDialog<int>(
      context: state.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: isImageExist(imageUrl, state) == false
              ? const Text("Add photo")
              : const Text("Change photo"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.of(state.context).pop(1),
              child: const Padding(
                padding: EdgeInsets.only(
                  top: AppDimen.paddingSmall,
                  bottom: AppDimen.paddingSmall,
                ),
                child: Text("Take photo"),
              ),
            ),
            // SimpleDialogOption(
            //   onPressed: () => Navigator.of(state.context).pop(2),
            //   child: const Padding(
            //     padding: EdgeInsets.only(
            //       top: AppDimen.paddingSmall,
            //       bottom: AppDimen.paddingSmall,
            //     ),
            //     child: Text("Choose photo"),
            //   ),
            // ),
            Visibility(
              visible: isImageExist(imageUrl, state),
              child: SimpleDialogOption(
                onPressed: () => Navigator.of(state.context).pop(3),
                child: const Padding(
                  padding: EdgeInsets.only(
                    top: AppDimen.paddingSmall,
                    bottom: AppDimen.paddingSmall,
                  ),
                  child: Text("Remove photo"),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimen.padding,
                    right: AppDimen.padding,
                  ),
                  child: TextButton(
                    child: const Text("CANCEL"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    XFile? image;
    final picker = ImagePicker();
    if (option == null) {
      return;
    } else if (option == 1) {
      image = await picker.pickImage(source: ImageSource.camera);
    } else if (option == 2) {
      image = await picker.pickImage(source: ImageSource.gallery);
    } else {
      _handleRemovePressed(state);
    }

    if (image != null) {
      showMessage("Image.path ==> ${image.path}");
      state.didChange(File(image.path));
      state.save();
    }
  }

  static void _handleRemovePressed(FormFieldState<File> state) async {
    state.didChange(null);
    state.save();
  }

  static bool isImageExist(String imageUrl, FormFieldState<File> state) {
    if ((imageUrl.isNotEmpty) || state.value != null) {
      return true;
    }
    return false;
  }
}

class VideoFormField extends FormField<File> {
  final String labelText;
  final String imageUrl;
  final double width;
  final double height;
  final WidgetShape widgetShape;

  VideoFormField({
    super.key,
    this.imageUrl = "",
    this.labelText = "",
    this.width = 100,
    this.height = 100,
    this.widgetShape = WidgetShape.rounded,
    required FormFieldSetter<File> onChanged,
    //required FormFieldValidator<File> validator,
  }) : super(
    onSaved: onChanged,
    //validator: validator,
    builder: (FormFieldState<File> state) {
      BorderRadius borderRadius =
      WidgetMethods.getBorderRadius(widgetShape, width, height);



      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: labelText == "" ? false : true,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
              child: Text(
                labelText,
                style: Theme
                    .of(state.context)
                    .textTheme
                    .bodySmall,
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              Container(
                //padding: const EdgeInsets.all(AppDimen.paddingSmall),
                height: height,
                width: width,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: borderRadius,
                  color: Theme
                      .of(state.context)
                      .scaffoldBackgroundColor,
                ),
                child: InkWell(
                  onTap: () => requestMultiplePermissions([Permission.camera, Permission.manageExternalStorage], imageUrl, state),
                  // onTap: () => requestPermissions(imageUrl, state),
                  // onTap: () => _handleAddChangePressed(imageUrl, state),
                  borderRadius: borderRadius,
                  child: FutureBuilder<String?>(
                    future: _getVideoThumbnail(state.value),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data != null) {
                        return Container(
                                height: height,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: borderRadius,
                                ),
                                child: ClipRRect(
                                  clipBehavior: Clip.hardEdge,
                                  borderRadius: borderRadius,
                                  child: Image.file(
                                    File(snapshot.data!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                      } else if (state.value == null &&
                          imageUrl.isNotEmpty) {
                        return Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                          ),
                          child: ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            borderRadius: borderRadius,
                            child: ImageFromNetwork(
                              height: height,
                              width: width,
                              imageUrl,
                              widgetShape: widgetShape,
                            ),
                          ),
                        );
                      } else if (state.value == null) {
                        return const Icon(Icons.play_circle_outline_rounded);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  // child: Container(
                  //   height: height,
                  //   width: width,
                  //   decoration: BoxDecoration(
                  //     borderRadius: borderRadius,
                  //     image: state.value == null
                  //         ? null
                  //         : DecorationImage(
                  //       image: Image
                  //           .file(
                  //         state.value!,
                  //       )
                  //           .image,
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  //   child: (state.value == null && imageUrl.isNotEmpty)
                  //       ? ImageFromNetwork(
                  //     height: height,
                  //     width: width,
                  //     imageUrl,
                  //     widgetShape: widgetShape,
                  //   )
                  //       : state.value == null
                  //       ? const Icon(Icons.play_circle_outline_rounded)
                  //       : null,
                  // ),
                ),
              ),
              Positioned(
                right: 2.0,
                bottom: 2.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      color: AppColors.primary,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      color: Colors.white,
                      size: 20,
                      isImageExist(imageUrl, state) == false
                          ? Icons.add
                          : Icons.edit,
                    ),
                  ),
                  onTap: () => requestMultiplePermissions([Permission.camera, Permission.manageExternalStorage], imageUrl, state),
                  // onTap: () => requestPermissions(imageUrl, state),
                  // onTap: () => _handleAddChangePressed(imageUrl, state),
                ),
              ),
            ],
          ),
          state.hasError
              ? Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 10.0,
            ),
            child: Text(
              state.errorText!,
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.danger,
              ),
            ),
          )
              : Container()
        ],
      );
    },
  );


  static Future<void> requestCameraPermission(FormFieldState<File> state) async {
    await Permission.camera
        .onDeniedCallback(() async {
      showMessage("Permission ==> 2 isDenied");
      await Permission.camera.request();
    }).onGrantedCallback(() {
      showMessage("Permission ==> isGranted");
      // _handleAddChangePressed(imageUrl, state);
    }).onPermanentlyDeniedCallback(() async {
      showMessage("Permission ==> isPermanentlyDenied");
      final res = (await showDialog(
        context: state.context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'This permission is needed for camera. You can grant permission in the app settings.'),
          actions: [
            TextButton(
              onPressed: () async {
                bool result = await openAppSettings();
                if (result) {
                  var ps = await Permission.camera.status;
                  Navigator.of(context).pop(ps == PermissionStatus.granted);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ));
    }).request();
  }

  static Future<void> requestStoragePermission(FormFieldState<File> state) async {
    await Permission.manageExternalStorage
        .onDeniedCallback(() async {
      showMessage("Permission ==> 2 isDenied");
      await Permission.manageExternalStorage.request();
    }).onGrantedCallback(() {
      showMessage("Permission ==> isGranted");
      // _handleAddChangePressed(imageUrl, state);
    }).onPermanentlyDeniedCallback(() async {
      showMessage("Permission ==> isPermanentlyDenied");
      final res = (await showDialog(
        context: state.context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'This permission is needed for manage external storage. You can grant permission in the app settings.'),
          actions: [
            TextButton(
              onPressed: () async {
                bool result = await openAppSettings();
                if (result) {
                  var ps = await Permission.manageExternalStorage.status;
                  Navigator.of(context).pop(ps == PermissionStatus.granted);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ));
    }).request();
  }

  static Future<void> requestMultiplePermissions(List<Permission> permissions, String imageUrl, FormFieldState<File> state) async {
    PermissionStatus status = await Permission.camera.request();

    // Request permission if not granted
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    // Check the permission result
    if (status.isGranted) {

      if (await Permission.manageExternalStorage.isGranted || await Permission.photos.isGranted) {
        _handleAddChangePressed(imageUrl, state);
      } else {
        PermissionStatus status;

        if (Platform.isAndroid) {
          status = await Permission.manageExternalStorage.request();
        } else {
          status = await Permission.photos.request();
        }
        // final status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          _handleAddChangePressed(imageUrl, state);
        } else if (status.isDenied) {
          print("Permission denied");
        } else if (status.isPermanentlyDenied) {
          final res = (await showDialog(
            context: state.context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'This permission is needed for camera. You can grant permission in the app settings.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    bool result = await openAppSettings();
                    if (result) {
                      var ps;
                      if (Platform.isAndroid) {
                        ps = await Permission.manageExternalStorage.status;
                      } else {
                        ps = await Permission.photos.status;
                      }
                      Navigator.of(context).pop(ps == PermissionStatus.granted);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  },
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ));
        }
      }

    } else {
      final res = (await showDialog(
        context: state.context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'This permission is needed for camera. You can grant permission in the app settings.'),
          actions: [
            TextButton(
              onPressed: () async {
                bool result = await openAppSettings();
                if (result) {
                  var ps = await Permission.camera.status;
                  Navigator.of(context).pop(ps == PermissionStatus.granted);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ));
    }


    /*for (var permission in permissions) {
      await permission.request().then((status) async {
        if (status.isDenied) {
          showMessage("Permission ==> 2 isDenied");
          await permission.request();
        } else if (status.isGranted) {
          showMessage("Permission ==> isGranted");
          _handleAddChangePressed(imageUrl, state);
        } else if (status.isPermanentlyDenied) {
          showMessage("Permission ==> isPermanentlyDenied");
          final res = (await showDialog(
            context: state.context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'This permission is needed for camera. You can grant permission in the app settings.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    bool result = await openAppSettings();
                    if (result) {
                      var ps = await Permission.camera.status;
                      Navigator.of(context).pop(ps == PermissionStatus.granted);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  },
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ));
        }
      });
    }*/
  }

  static Future _handleAddChangePressed(
      String imageUrl, FormFieldState<File> state) async {

    int? option = await showDialog<int>(
      context: state.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: isImageExist(imageUrl, state) == false
              ? const Text("Add video")
              : const Text("Change video"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.of(state.context).pop(1),
              child: const Padding(
                padding: EdgeInsets.only(
                  top: AppDimen.paddingSmall,
                  bottom: AppDimen.paddingSmall,
                ),
                child: Text("Take video"),
              ),
            ),
            // SimpleDialogOption(
            //   onPressed: () => Navigator.of(state.context).pop(2),
            //   child: const Padding(
            //     padding: EdgeInsets.only(
            //       top: AppDimen.paddingSmall,
            //       bottom: AppDimen.paddingSmall,
            //     ),
            //     child: Text("Choose video"),
            //   ),
            // ),
            Visibility(
              visible: isImageExist(imageUrl, state),
              child: SimpleDialogOption(
                onPressed: () => Navigator.of(state.context).pop(3),
                child: const Padding(
                  padding: EdgeInsets.only(
                    top: AppDimen.paddingSmall,
                    bottom: AppDimen.paddingSmall,
                  ),
                  child: Text("Remove video"),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimen.padding,
                    right: AppDimen.padding,
                  ),
                  child: TextButton(
                    child: const Text("CANCEL"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    XFile? video;
    final picker = ImagePicker();
    if (option == null) {
      return;
    } else if (option == 1) {
      video = await picker.pickVideo(source: ImageSource.camera);
    } else if (option == 2) {
      video = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      _handleRemovePressed(state);
    }

    if (video != null) {
      showMessage("Image.path ==> ${video.path}");
      state.didChange(File(video.path));
      state.save();
    }
  }

  static void _handleRemovePressed(FormFieldState<File> state) async {
    state.didChange(null);
    state.save();
  }

  static bool isImageExist(String imageUrl, FormFieldState<File> state) {
    if ((imageUrl.isNotEmpty) || state.value != null) {
      return true;
    }
    return false;
  }

  static Future<String?> _getVideoThumbnail(File? videoFile) async {
    if (videoFile == null) return null;
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 128,
      quality: 100,
    );
    return thumbnail;
  }
}

class AudioFormField extends FormField<File> {
  final String labelText;
  final String imageUrl;
  final double width;
  final double height;
  final WidgetShape widgetShape;

  AudioFormField({
    super.key,
    this.imageUrl = "",
    this.labelText = "",
    this.width = 100,
    this.height = 100,
    this.widgetShape = WidgetShape.rounded,
    required FormFieldSetter<File> onChanged,
    //required FormFieldValidator<File> validator,
  }) : super(
    onSaved: onChanged,
    //validator: validator,
    builder: (FormFieldState<File> state) {
      BorderRadius borderRadius =
      WidgetMethods.getBorderRadius(widgetShape, width, height);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: labelText == "" ? false : true,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
              child: Text(
                labelText,
                style: Theme
                    .of(state.context)
                    .textTheme
                    .bodySmall,
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              Container(
                //padding: const EdgeInsets.all(AppDimen.paddingSmall),
                height: height,
                width: width,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: borderRadius,
                  color: Theme
                      .of(state.context)
                      .scaffoldBackgroundColor,
                ),
                child: InkWell(
                  onTap: () => _handleAddChangePressed(imageUrl, state),
                  borderRadius: borderRadius,
                  child: FutureBuilder<String?>(
                    future: _getVideoThumbnail(state.value),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data != null) {
                        return Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                          ),
                          child: ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            borderRadius: borderRadius,
                            child: Image.file(
                              File(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else if (state.value == null &&
                          imageUrl.isNotEmpty) {
                        return Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                          ),
                          child: ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            borderRadius: borderRadius,
                            child: ImageFromNetwork(
                              height: height,
                              width: width,
                              imageUrl,
                              widgetShape: widgetShape,
                            ),
                          ),
                        );
                      } else if (state.value == null) {
                        return const Icon(Icons.audiotrack_rounded);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  // child: Container(
                  //   height: height,
                  //   width: width,
                  //   decoration: BoxDecoration(
                  //     borderRadius: borderRadius,
                  //     image: state.value == null
                  //         ? null
                  //         : DecorationImage(
                  //       image: Image
                  //           .file(
                  //         state.value!,
                  //       )
                  //           .image,
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  //   child: (state.value == null && imageUrl.isNotEmpty)
                  //       ? ImageFromNetwork(
                  //     height: height,
                  //     width: width,
                  //     imageUrl,
                  //     widgetShape: widgetShape,
                  //   )
                  //       : state.value == null
                  //       ? const Icon(Icons.play_circle_outline_rounded)
                  //       : null,
                  // ),
                ),
              ),
              Positioned(
                right: 2.0,
                bottom: 2.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      color: AppColors.primary,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      color: Colors.white,
                      size: 20,
                      isImageExist(imageUrl, state) == false
                          ? Icons.add
                          : Icons.edit,
                    ),
                  ),
                  onTap: () => _handleAddChangePressed(imageUrl, state),
                ),
              ),
            ],
          ),
          state.hasError
              ? Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 10.0,
            ),
            child: Text(
              state.errorText!,
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.danger,
              ),
            ),
          )
              : Container()
        ],
      );
    },
  );

  static Future _handleAddChangePressed(
      String imageUrl, FormFieldState<File> state) async {

    int? option = await showDialog<int>(
      context: state.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: isImageExist(imageUrl, state) == false
              ? const Text("Add audio")
              : const Text("Change audio"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.of(state.context).pop(1),
              child: const Padding(
                padding: EdgeInsets.only(
                  top: AppDimen.paddingSmall,
                  bottom: AppDimen.paddingSmall,
                ),
                child: Text("Record audio"),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(state.context).pop(2),
              child: const Padding(
                padding: EdgeInsets.only(
                  top: AppDimen.paddingSmall,
                  bottom: AppDimen.paddingSmall,
                ),
                child: Text("Choose audio"),
              ),
            ),
            Visibility(
              visible: isImageExist(imageUrl, state),
              child: SimpleDialogOption(
                onPressed: () => Navigator.of(state.context).pop(3),
                child: const Padding(
                  padding: EdgeInsets.only(
                    top: AppDimen.paddingSmall,
                    bottom: AppDimen.paddingSmall,
                  ),
                  child: Text("Remove audio"),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimen.padding,
                    right: AppDimen.padding,
                  ),
                  child: TextButton(
                    child: const Text("CANCEL"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    XFile? video;
    final picker = ImagePicker();
    if (option == null) {
      return;
    } else if (option == 1) {
      video = await picker.pickVideo(source: ImageSource.camera);
    } else if (option == 2) {
      video = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      _handleRemovePressed(state);
    }

    if (video != null) {
      showMessage("Image.path ==> ${video.path}");
      state.didChange(File(video.path));
      state.save();
    }
  }

  static void _handleRemovePressed(FormFieldState<File> state) async {
    state.didChange(null);
    state.save();
  }

  static bool isImageExist(String imageUrl, FormFieldState<File> state) {
    if ((imageUrl.isNotEmpty) || state.value != null) {
      return true;
    }
    return false;
  }

  static Future<String?> _getVideoThumbnail(File? videoFile) async {
    if (videoFile == null) return null;
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 128,
      quality: 100,
    );
    return thumbnail;
  }
}