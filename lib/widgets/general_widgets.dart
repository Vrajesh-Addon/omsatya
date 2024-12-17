import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_images.dart';

showMessage(String message) {
  log(message);
  // if(kDebugMode){
  //   print(message);
  // }
}

enum ExtensionType { jpg, jpeg, png, mp4, mov, mkv, pdf }

enum RoleType {
  customer,
  engineer,
  sales,
  admin,
}

// #region emum
enum WidgetShape {
  square,
  circle,
  rounded,
}

enum WidgetAngle {
  lightToDark,
  darkToLight,
}

enum MenuOptions { edit, delete, addLocation, assignToEngineer, previousDetails }

enum TodoMenuOptions {
  previousDetails,
  delete,
  edit,
}

enum SalesMenuOptions {
  previousDetails,
  inOut,
  edit,
  delete,
}

enum Media {
  file,
  buffer,
  asset,
  stream,
  remoteExampleFile,
}

const int tSAMPLERATE = 8000;

const int tSTREAMSAMPLERATE = 44000;

dismissKeyboard(BuildContext context) {
  var f = FocusScope.of(context);
  if (!f.hasPrimaryFocus) {
    f.unfocus();
  }
}

extension StringExtension on String {
  String toCapitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

PreferredSizeWidget appBar({
  Widget? leading,
  Widget? title,
  Color? backgroundColor,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    leading: leading,
    title: title,
    actions: actions,
    bottom: bottom,
    backgroundColor: backgroundColor,
    centerTitle: true,
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onMenuPressed;
  final Function()? onBackPressed;
  final bool isShowBackButton;

  const CustomAppBar({
    super.key,
    this.isShowBackButton = false,
    this.onMenuPressed,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard app bar height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          AppImages.appLogo,
          width: 100,
          height: 100,
        ),
      ),
      centerTitle: false,
      titleSpacing: 0,
      leading: isShowBackButton
          ? IconButton(
              onPressed: onBackPressed,
              splashRadius: 25,
              splashColor: AppColors.primary.withOpacity(0.1),
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : IconButton(
              onPressed: onMenuPressed,
              splashRadius: 25,
              splashColor: AppColors.primary.withOpacity(0.1),
              icon: const Icon(Icons.menu_rounded),
            ),
      actions: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(AppDimen.padding),
            child: Text(
              AppGlobals.user != null ? AppGlobals.user!.name! : "",
              style: const TextStyle(
                color: AppColors.primary,
                // color: Colors.deepOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 250,
      // child: SvgPicture.asset(AppImages.appLogo),
      child: Image.asset(AppImages.appLogo),
    );
  }
}

class Error extends StatelessWidget {
  const Error({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error,
              size: AppDimen.iconSize,
              color: Theme.of(context).colorScheme.error,
            ),
            const FieldSpace(),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const FieldSpace(),
            const Text(AppStrings.errorMessage),
          ],
        ),
      ],
    );
  }
}

class NoInternet extends StatelessWidget {
  final void Function() onRetryPressed;

  const NoInternet({super.key, required this.onRetryPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.wifi_off,
              size: AppDimen.iconSize,
              color: AppColors.warning,
            ),
            const FieldSpace(),
            Text(
              'No Internet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const FieldSpace(),
            const Text(AppStrings.noInternet),
            const FieldSpace(),
            OutlinedButton(
              child: const Text("RETRY"),
              onPressed: () => onRetryPressed(),
            )
          ],
        ),
      ],
    );
  }
}

class NoRecord extends StatelessWidget {
  final String? message;

  const NoRecord({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.info,
              size: AppDimen.iconSize,
              color: AppColors.info,
            ),
            const FieldSpace(),
            Text(
              'No Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const FieldSpace(),
            Text(message ?? AppStrings.notFound),
          ],
        ),
      ],
    );
  }
}

class Loading extends StatelessWidget {
  final LoadingType loadingType;

  const Loading({
    super.key,
    this.loadingType = LoadingType.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimen.padding),
        child: loading(context),
      ),
    );
  }

  Widget loading(BuildContext context) {
    switch (loadingType) {
      case LoadingType.screen:
        return SpinKitThreeBounce(color: Theme.of(context).colorScheme.secondary);
      case LoadingType.image:
        return SpinKitPulse(color: Theme.of(context).colorScheme.secondary);
      default:
        return const CircularProgressIndicator();
    }
  }
}

class LoadMore extends StatelessWidget {
  final bool isLoadingMore;
  final Function()? onPressed;

  const LoadMore(this.isLoadingMore, {super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Visibility(
          visible: isLoadingMore,
          child: const Loading(loadingType: LoadingType.circular),
        ),
        Visibility(
          visible: !isLoadingMore && onPressed != null,
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onPressed,
              child: const Text("LOAD MORE"),
            ),
          ),
        ),
      ],
    );
  }
}

class FieldSpace extends StatelessWidget {
  final SpaceType spaceType;

  const FieldSpace([this.spaceType = SpaceType.medium, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (spaceType) {
      case SpaceType.extraSmall:
        return const SizedBox(height: 4.0, width: 4.0);
      case SpaceType.small:
        return const SizedBox(height: 8.0, width: 8.0);
      case SpaceType.medium:
        return const SizedBox(height: 16.0, width: 16.0);
      case SpaceType.large:
        return const SizedBox(height: 24.0, width: 24.0);
      case SpaceType.extraLarge:
        return const SizedBox(height: 32.0, width: 32.0);
    }
  }
}

class ProgressDialog {
  bool _isShowing = false;
  late BuildContext _context;

  void show(BuildContext context, {String text = "Loading..."}) {
    AlertDialog dialog = AlertDialog(

      content: WillPopScope(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const CircularProgressIndicator(),
            const FieldSpace(SpaceType.small),
            Text(text),
          ],
        ),
        onWillPop: () {
          return Future.value(false);
        },
      ),
    );
    if (_isShowing == false) {
      _isShowing = true;
      _context = context;

      showDialog(barrierDismissible: false, context: _context, builder: (BuildContext context) => dialog);
    }
  }

  void hide() {
    if (_isShowing == true) {
      _isShowing = false;

      if (Navigator.of(_context).canPop()) {
        Navigator.of(_context).pop();
      }
    }
  }
}

class ScaffoldContainer extends StatelessWidget {
  final Widget child;

  const ScaffoldContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.centerLeft,
          radius: 1,
          colors: [
            AppColors.gradient,
            AppColors.background,
          ],
        ),
      ),
      child: child,
    );
  }
}

class ShapeContainer extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final CustomClipper<Path>? clipper;
  final WidgetShape widgetShape;
  final WidgetAngle widgetAngle;
  final bool gradient;
  final bool shadow;

  const ShapeContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.clipper,
    this.widgetShape = WidgetShape.rounded,
    this.widgetAngle = WidgetAngle.lightToDark,
    this.gradient = false,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget gradientChild = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );

    return gradientChild;
  }
}

class AppLoader extends StatelessWidget {
  final Color loaderColor;
  final double loaderSize;

  const AppLoader({super.key, this.loaderColor = AppColors.primary, this.loaderSize = 40});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: AppColors.primary,
        size: loaderSize,
      ),
    );
  }
}

class ButtonLoader extends StatelessWidget {
  final double? width;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? loaderSize;
  final EdgeInsetsGeometry? margin;

  const ButtonLoader({
    super.key,
    this.width,
    this.verticalPadding,
    this.horizontalPadding,
    this.loaderSize,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? AppDimen.paddingSmall,
        horizontal: horizontalPadding ?? 0.0,
      ),
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimen.textRadius),
      ),
      child: AppLoader(
        loaderColor: Colors.white,
        loaderSize: loaderSize ?? 40,
      ),
    );
  }
}

class WidgetMethods {
  static BorderRadius getBorderRadius(WidgetShape shape, double? width, double? height) {
    BorderRadius borderRadius;
    switch (shape) {
      case WidgetShape.square:
        borderRadius = const BorderRadius.all(Radius.circular(0.0));
        break;
      case WidgetShape.rounded:
        borderRadius = BorderRadius.all(Radius.circular(AppDimen.roundedBorderRadius));
        break;
      case WidgetShape.circle:
        double tempWidth = width ?? 0;
        double tempHeight = height ?? 0;
        double radius = tempWidth > tempHeight ? tempWidth / 2 : tempHeight / 2;
        borderRadius = BorderRadius.all(Radius.circular(radius));
        break;
    }
    return borderRadius;
  }
}

Widget buildDashboardCard({
  required BuildContext context,
  Color? bgColor,
  String? counter,
  String? text,
  Color cardBg = Colors.white,
}) {
  return Card(
    color: cardBg,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimen.textRadius),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimen.paddingSmall, horizontal: AppDimen.paddingSmall),
          height: MediaQuery.of(context).size.height * 0.12,
          alignment: Alignment.center,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              if (counter != null)
                Center(
                  child: Text(
                    counter,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (counter != null) const FieldSpace(SpaceType.small),
              Wrap(
                children: [
                  Center(
                    child: Text(
                      text!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (bgColor != null)
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppDimen.textRadius),
                bottomRight: Radius.circular(AppDimen.textRadius),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget buildDashboardHomeCard({
  required BuildContext context,
  required String text,
  required String image,
  Color cardBg = AppColors.primary,
}) {
  return Card(
    color: AppColors.primary,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimen.paddingSmall, horizontal: AppDimen.paddingSmall),
      alignment: Alignment.center,
      child: Row(
        children: [
          Image.asset(
            image,
            width: 80,
            height: 80,
          ),
          const FieldSpace(),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
