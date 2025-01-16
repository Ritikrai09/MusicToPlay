import 'package:flutter/material.dart';
import 'package:blogit/Extensions/white_space_extension.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/widgets/button.dart';
import 'package:blogit/presentation/widgets/my_text_field.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controller/user_controller.dart';
import '../../../widgets/loader.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {


UserProvider user = UserProvider();
bool loading=false;

  final _focusNode = FocusNode();

@override
  void initState() {
    
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CustomLoader(
      isLoading: loading,
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        body: Form(
          key: user.forgetFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: size.width),
              SpaceUtils.ks60.height(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SpaceUtils.ks24.width(),
                  const BackbUT()
                ],
              ),
              SizedBox(
                height: 116.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 73.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: double.infinity,
                    ),
                    Text(
                     allMessages.value.forgotPassword ?? 'Forgot\nPassword?',
                      style:
                          FontStyleUtilities.h3(context, fontWeight: FWT.extrabold),
                    ),
                    SpaceUtils.ks10.height(),
                    Text(
                      allMessages.value.enterAValidEmail ??  'Enter your registered email address.',
                      style:FontStyleUtilities.p3(context, fontWeight: FWT.semiBold),
                    ),
                    SpaceUtils.ks26.height(),
                     MyTextField(
                      focus: _focusNode,
                      hint:  allMessages.value.email ?? 'Email Address',
                      fillColor: Theme.of(context).canvasColor,
                        onValidate: (v) {
                        setState(() {
                            user.user.email = v!.trim();
                         });
                        bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(user.user.email!);
                        if (user.user.email!.isEmpty) {
                          return allMessages.value.enterAValidEmail ?? 'Email is required';
                        } else if (!emailValid) {
                          return allMessages.value.enterAValidEmail ?? 'Enter a valid email';
                        }
                        return null;
                      },
                      
                       onFieldSubmit: (p0) {
                         setState(() {
                            user.user.email =p0.trim();
                         });
                         user.forgetPassword(context, onChanged: (value) {
                           loading=value;
                           setState(() {  });
                          });
                        },
                      onSaved: (v) {
                      setState(() {
                        user.user.email = v!.trim();
                      });
                    },
                    ),
                    SpaceUtils.ks16.height(),
                    Button(tittle:  allMessages.value.resetPassword ?? 'Reset Password', onTap: () {
                     
                         setState(() {
                            user.user.email = user.user.email.toString().trim();
                         });

                      user.forgetPassword(context, onChanged: (value) {
                        loading=value;
                        setState(() {  });
                      });
                    })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
