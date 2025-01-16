import 'dart:convert';
import 'dart:io';

import 'package:blogit/presentation/widgets/maintenance_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Auth/Forget_password/forget_password.dart';
import 'package:blogit/presentation/screens/Auth/Register/register.dart';
import 'package:blogit/presentation/screens/Main/Home_wrapper/home_wrapper.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:blogit/model/blog.dart';
import '../../../../controller/app_provider.dart';
import '../../../../controller/user_controller.dart';
import '../../../../main.dart';
import '../../../../model/settings.dart';
import '../../../widgets/loader.dart';
import '../../Main/Article_details/article_details.dart';

class Login extends StatefulWidget {
  const Login({super.key,
  this.prefilled=false,
  this.email,
  this.isFromHome=true
  });
  final bool prefilled,isFromHome;
  final String? email;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
 
UserProvider user = UserProvider();
bool loading=false;
bool isValidate=false;
late TextEditingController emailCtrl;
bool isObscure=true;


@override
  void initState() {
    emailCtrl = TextEditingController(text:widget.email );
    prefs!.remove('url');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if(widget.isFromHome == false){
      var provider  = Provider.of<AppProvider>(context,listen: false); 
      user.getLanguageFromServer(context);
      provider.getCategory();
     } else {
       user.checkSettingUpdate();
     }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: widget.isFromHome,
      onPopInvoked: (didPop) {

         if (widget.isFromHome == false) {
        //   Navigator.pop(context);
        // } else {

        showCustomDialog(
        context: context,
        title: allMessages.value.confirmExitTitle ?? "Exit Application",
        text: allMessages.value.confirmExitApp ?? 'Do you want to exit from app ?',
        onTap: () {
            var provider = Provider.of<AppProvider>(context,listen: false);
            var end = DateTime.now();
            provider.addAppTimeSpent(startTime: provider.appStartTime,endTime: end);
            provider.getAnalyticData();
            Future.delayed(const Duration(milliseconds: 300));
            exit(0);
         },
         isTwoButton: true
        );
          
       }
      },
      child: CustomLoader(
        isLoading: loading,
        child: ValueListenableBuilder<SettingModel>(
          valueListenable: allSettings,
          builder: (context,value,child) {
            return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body:value.enableMaintainanceMode == '1'
                       ?  MaintainanceWidget(value: value)
                       :  Stack(
                  children: [
                    Form(
                    key: user.loginFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                         
                   SizedBox(
                     width: size.width,
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
                     padding: EdgeInsets.symmetric(horizontal: 33.w, vertical: 24.h),
                     width: size.width,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(24.r),
                       color: Theme.of(context).scaffoldBackgroundColor,
                     ),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Text(
                            allMessages.value.signIn ??  'Log In',
                            textAlign: TextAlign.center,
                           style: FontStyleUtilities.h3(context,
                               fontWeight: FWT.extrabold),
                         ),
                         SpaceUtils.ks26.height(),
                          MyTextField(
                           textInputAction: TextInputAction.next,
                           hint:  allMessages.value.email ??  'E-mail',
                           autovalidateMode: isValidate ? AutovalidateMode.onUserInteraction  : AutovalidateMode.disabled,
                           maxHeight: 70,
                          //  fillColor: isWhiteRange(Theme.of(context).primaryColor) ? Colors.white : null,
                           controller: emailCtrl,
                           onFieldSubmit: (p0) {
                           setState(() {
                              user.user.email = p0.trim();
                           });
                          },
                           onValidate: (v) {
                             setState(() {
                              user.user.email = v!.trim();
                           });
                           bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(user.user.email!);
                           if (user.user.email!.isEmpty) {
                             return '${allMessages.value.email} is required';
                           } else if (!emailValid) {
                             return allMessages.value.enterAValidEmail ?? 'Enter a valid email';
                           }
                           return null;
                         },
                         onSaved: (v) {
                         setState(() {
                           user.user.email = v!.trim();
                         });
                       },
                         ),
                         SpaceUtils.ks16.height(),
                          MyTextField(
                          textInputAction: TextInputAction.done,
                           hint:  allMessages.value.password ??  'Password',
                             autovalidateMode: isValidate ?
                              AutovalidateMode.onUserInteraction  : AutovalidateMode.disabled,
                            maxHeight: 70,
                            autoFocus: widget.prefilled,
                            suffix: InkResponse(
                              onTap: () {
                                isObscure = !isObscure;
                                setState(() {  });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                                child: Icon( isObscure==false ? Icons.visibility_off :Icons.visibility,
                                color: dark(context) ? ColorUtil.white :Colors.grey,
                                ),
                              ),
                            ),
                            isObscure: isObscure,
                            onValidate: (v) {
                             if (v!.isEmpty) {
                               return allMessages.value.passwordRequired ?? 'Password field is required';
                             } else if (v.length < 8) {
                               // return allMessages.value.enterAValidPassword;
                               return  allMessages.value.enterAValidPassword  ?? 'Wrong password';
                             }
                             return null;
                           },
                           onSaved: (v) {
                             setState(() {
                               user.user.password = v!.trim();
                             });
                           },
                           onFieldSubmit: (p0) {
                               loading=true;
                                setState(() {   });
                               FocusScope.of(context).requestFocus(FocusNode());
                               isValidate = true;
                               setState(() {  });
                               user.signin(context, onChanged: (value) {
                                 loading = value;
                                 
                                 setState(() { });
                               });
                           },
                         ),
                         SpaceUtils.ks16.height(),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             GestureDetector(
                               onTap: () {
                                 NavigationUtil.to(context, const ForgetPassword());
                               },
                               child: Text(
                                allMessages.value.forgotPassword ??  'Forgot Password?',
                                 style: FontStyleUtilities.p2(context,
                                     fontWeight: FWT.extrabold,
                                     fontColor:
                                         Theme.of(context).brightness == Brightness.light
                                             ? Theme.of(context).primaryColor
                                             : Colors.white),
                               ),
                             ),
                           ],
                         ),
                         SpaceUtils.ks24.height(),
                         Button(
                             tittle:  allMessages.value.signIn ??'Log In',
                             onTap: () {
                               loading=true;
                                setState(() {   });
                               FocusScope.of(context).requestFocus(FocusNode());
                               isValidate = true;
                               setState(() {  });
                               user.signin(context, onChanged: (value) {
                                 loading = value;
                                 
                                 setState(() { });
                               });
                               // NavigationUtil.to(context, const SelectInterest());
                             }),
                          SpaceUtils.ks30.height(),
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
                                        allMessages.value.orSignIn ?? 'Or Sign In with',
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
                         SpaceUtils.ks30.height(),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             if(Platform.isIOS)
                             // ============ Apple SignIn ==========
                             appleSignIn(context), 
                             // ============ Google SignIn ==========
                             googleSignIn(context),  
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
                           NavigationUtil.to(context, const Register());
                      },
                     child: Wrap(
                     children: [
                       Text(
                        allMessages.value.dontHaveAccount ?? 'Don’t have an account ?',
                         style: FontStyleUtilities.l1(context, fontWeight: FWT.extrabold),
                       ),
                       const SizedBox(width: 8),
                      Text(
                           allMessages.value.signUp ?? 'Register Here',
                           style: FontStyleUtilities.l1(context,  
                               fontColor: Theme.of(context).primaryColor,
                               fontWeight: FWT.extrabold),
                         ),
                     ],
                   )),
                   SpaceUtils.ks20.height()
                        ],
                      ),
                    ),
                  ),
      
                Positioned(
                  right: 24,
                  left: 24,
                  top: kToolbarHeight,
                  child: SizedBox(
                    width: size.width/2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(widget.isFromHome)
                        const BackbUT()
                        else
                        const SizedBox(),
                        const Spacer(),
                        if(allSettings.value.isEnableSkip == '1')
                        const TextButt(),
                      ],
                    ),
                  ))
              ],
            ),
       );
          }
        )),
    );
  }

  InkResponse googleSignIn(BuildContext context) {
    return InkResponse(
                             onTap:() {
                               user.googleLogin(context, onChanged: (value) {
                                 loading = value;
                                 setState(() {   });
                               });
                             },
                             child: SizedBox(
                               height: 30.h,
                               width: 30.w,
                               child: const SvgIcon('asset/Images/Social/google.svg'),
                             ),
                           );
  }

  Widget appleSignIn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkResponse(
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
    );
  }
}

class TextButt extends StatelessWidget {
  const TextButt({
    super.key,
    this.text,
    this.onTap
  });

  final String? text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:BorderSide(width: 1,color: Theme.of(context).primaryColor)
      )
    ),
    onPressed: onTap ?? () {
       Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder:(context) => const HomeWrapper(
          isInitial: true,
        )), (route) => false);
          }, child: Text( text ?? allMessages.value.skip ?? 'Skip',
           style: TextStyle(fontSize: 15,
           fontWeight: FontWeight.w600,
           color: dark(context) ? Colors.white :  Theme.of(context).primaryColor)
          ));
  }
}


  Future blogDetailDeepLink(context) async {
    try {
      var data = Blog.fromJson(jsonDecode(prefs!.getString('blog').toString())['data'],isNotification: true);
      // print('data');
      // print(data);
      prefs!.remove('blog');
       prefs!.remove('blogid');
    // if (data.type == 'quote') {
    //  Navigator.pushNamed(context,'/Quote',arguments:[
    //     data,
    //     null,
    //  ]);
    // } else {
        Navigator.push(navkey.currentState!.context, CupertinoPageRoute(builder:
          (context) => ArticleDetails(blog: data,
                likes: data.likes!.toString(),
          )
          ));
             
    //  Navigator.pushNamed(context,'/ReadBlog',arguments:[
    //     data,
    //     null,
    //     true
    //  ]);
  // }
    } on Exception catch (e) {
     throw Exception(e);
    }
  }