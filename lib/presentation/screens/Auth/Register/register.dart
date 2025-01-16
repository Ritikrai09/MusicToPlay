import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/presentation/widgets/loader.dart';

import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:blogit/Extensions/extension.dart';

import '../../../../controller/user_controller.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

 UserProvider user = UserProvider();
bool loading=false;

  bool isObscure=true;

@override
  void initState() {
    
    super.initState();
  }


 bool isValidString(String input) {
  // Check if the string contains at least 4 alphabetic characters
  final RegExp alphabetRegExp = RegExp(r'(?=(?:[^A-Za-z]*[A-Za-z]){4})');
  // Check if the string is composed only of numbers
  final RegExp numberOnlyRegExp = RegExp(r'^\d+$');

  return alphabetRegExp.hasMatch(input) && !numberOnlyRegExp.hasMatch(input);
}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CustomLoader(
      isLoading: loading,
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        body: SingleChildScrollView(
          child: Form(
            key: user.signupFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: size.width),
                SizedBox(
                  height: 71.h,
                ),
                SizedBox(
                  height: 71.h,
                ),
                Transform.scale(scale: 2, child: const TheLogo(rectangle: true)),
                SizedBox(
                  height: 50.h,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 33.w, vertical: 32.h),
                
                  width: 295.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       allMessages.value.signUp ?? 'Register',
                        style: FontStyleUtilities.h3(context,
                            fontWeight: FWT.extrabold),
                      ),
                      SpaceUtils.ks26.height(),
                       MyTextField(
                        hint: '${allMessages.value.userName}',
                           onValidate: (v) {
                            if (v!.isEmpty) {
                              return '${allMessages.value.userName} is required';
                            }else  if ( isValidString(v)==false) {
                                return allMessages.value.enterAValidUserName ?? 'Name must contain 4 characters';
                            }
                            return null;
                          },
                          onSaved: (v) {
                            setState(() {
                              user.user.name = v;
                            });
                          },
                        maxHeight: 70),
                      SpaceUtils.ks12.height(),
                       MyTextField(
                        hint: 'E-mail',
                         onValidate: (v) {
                           setState(() {
                            user.user.email = v!.trim();
                         });
                          bool emailValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(user.user.email!);
                          if (user.user.email!.isEmpty) {
                            return allMessages.value.enterAValidEmail ?? 'Email is required';
                          } else if (emailValid == false) {
                            return allMessages.value.enterAValidEmail ?? 'Enter a valid email';
                          }
                          return null;
                        },
                        onFieldSubmit: (p0) {
                         setState(() {
                            user.user.email = p0.trim();
                         });
                        },
                      onSaved: (v) {
                        setState(() {
                          user.user.email = v!.trim();
                        });
                      },
                        maxHeight: 70),
                      SpaceUtils.ks12.height(),
                       MyTextField(hint:allMessages.value.password ?? 'Password',
                        suffix: InkResponse(
                            onTap: () {
                              isObscure = !isObscure;
                              setState(() {  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 16),
                              child: Icon( isObscure==false ? Icons.visibility_off :Icons.visibility,
                              color: dark(context) ? ColorUtil.white :Colors.grey,
                              ),
                            ),
                          ),
                         isObscure: isObscure,
                      onValidate: (v) {
                        if (v!.isEmpty) {
                          return allMessages.value.passwordRequired ?? 'Password field is required';
                        }else if (v.length <= 7) {
                          // return allMessages.value.enterAValidPassword;
                          return allMessages.value.enterAValidPassword ?? 'Password must contain 8 characters';
                        }
                        return null;
                      },
                      onSaved: (v) {
                        setState(() {
                          user.user.password = v!.trim();
                        });
                      },
                      maxHeight: 70),
                      SpaceUtils.ks16.height(),
                      Button(
                          tittle:allMessages.value.signUp ?? 'Register',
                          onTap: () {
                            setState(() {
                              loading=true;
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                            user.signup(context, onChanged: (value) {
                              loading=value;
                              setState(() {});
                            });
                          }),
                      SpaceUtils.ks20.height(),
                      SizedBox(
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              // width: size.width/1.75,
                              child: Row(
                                children: [
                                  Expanded(child: Container(height: 1,color: Theme.of(context).dividerColor)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      allMessages.value.orSignUp ?? 'Or Sign Up with',
                                      style: FontStyleUtilities.h6(context,
                                          fontWeight: FWT.semiBold),
                                    ),
                                  ),
                                  Expanded(child:Container(height: 1,color: Theme.of(context).dividerColor)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpaceUtils.ks20.height(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           if(Platform.isIOS)
                              InkResponse(
                                onTap: () {
                                   user.appleLogin(context, onChanged: (value) {
                                    loading = value;
                                    setState(() {   });
                                  });
                                },
                                child: SizedBox(
                                  height: 30.h,
                                  width: 30.w,
                                  child: SvgIcon('asset/Icons/apple.svg',
                                        color: dark(context) ? Colors.white : null
                                      ),
                                ),
                              ),
                               if(Platform.isIOS)
                              SpaceUtils.ks16.width(),
                          InkResponse(
                            onTap: () {
                               loading = true;
                              setState(() { });
                            user.googleLogin(context, onChanged: (value) {
                              loading = value;
                              setState(() { });
                            });
                            },
                            child: SizedBox(
                              height: 30.h,
                              width: 30.w,
                              child: const SvgIcon('asset/Images/Social/google.svg'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
                GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                 child: Wrap(
                  children: [
                    Text(
                      allMessages.value.alreadyHaveAnAccount ?? 'Already have an account?',
                      style: FontStyleUtilities.l1(context, fontWeight: FWT.extrabold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        allMessages.value.login ?? 'Log In',
                        style: FontStyleUtilities.l1(context,
                            fontColor: Theme.of(context).colorScheme.primary,
                            fontWeight: FWT.extrabold),
                     ),
                  ],
                ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
