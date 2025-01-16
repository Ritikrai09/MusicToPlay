import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:blogit/Utils/utils.dart';

import '../../../../controller/user_controller.dart';
import '../../../widgets/loader.dart';

class ResetPassword extends StatefulWidget {

  const ResetPassword({super.key,this.isReset=false,this.mail});
  final bool isReset;
  final String? mail;


  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  late TextEditingController controller;
  
  bool isObscure=true,isObscure2=true,isObscure3=true;
  
  late TextEditingController controller2,controller3, controller4;
  late UserProvider userProvider;
  
  bool isLoad=false;
  FocusNode focus2 = FocusNode();
  FocusNode focus3 = FocusNode();
  FocusNode focus4 = FocusNode();

  @override
  void initState() {
    controller2 = TextEditingController();
    controller3 = TextEditingController();
    controller4 = TextEditingController();
    userProvider = UserProvider();
    super.initState();
  }

  @override
  void dispose() {
    controller2.dispose();
    controller3.dispose();
     controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return CustomLoader(
      isLoading: isLoad,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
              child:Container(
            width: size.width,
            height: size.height-kToolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:   Form(
              key: widget.isReset == true ?  userProvider.resetFormKey : userProvider.changeFormKey,
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       SizedBox(height: 24.h),
                      Row(
                        children: [
                       widget.isReset ? const SizedBox() 
                       :  InkResponse(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                        'asset/Icons/arrow.png',
                        width: 22,height: 22,
                        color: dark(context) ? Colors.white : Colors.black)),
                        ],
                      ),
                       const Spacer(),
                       TheLogo(rectangle: true,width: 60.w,height: 60.h),
                    //  Image.asset('asset/Images/Logo/splash_logo.png',
                    //   width: 80,
                    //   height: 80,
                    //   ),
                      const SizedBox(height:30),
                      Text( widget.isReset ? allMessages.value.resetPassword ?? 'Reset password' 
                      : allMessages.value.changePassword ??  'Change password',
                       style: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'QuickSand',
                        fontWeight:FontWeight.w600,
                      )),
                      const SizedBox(height:30),
                    
                     widget.isReset ? const SizedBox() :TextLabel(
                      label: allMessages.value.currentPassword ?? 'Current password',
                       child: MyTextField(
                         key: const ValueKey(2345),
                           hint: allMessages.value.currentPassword ?? 'Current password',
                           onSaved: (p0) {
                             setState(() {
                              controller2.text = p0!.trim();
                             });
                           },
                           onValidate: (p0) {
                               if (p0!.isEmpty) {
                                  return allMessages.value.entercurrentpassword ?? 'Enter current password';
                               } else if (p0.length < 8) {
                               // return allMessages.value.enterAValidPassword;
                               return  allMessages.value.enterAValidPassword  ?? 'Wrong password';
                             }
                               return null;
                           },
                           onFieldSubmit: (p0) {
                             focus3.requestFocus();
                             
                           },
                           controller: controller2,
                          focus: focus2,
                          textInputAction: TextInputAction.next,
                          suffix: InkResponse(
                            onTap: () {
                              isObscure = !isObscure;
                              setState(() {  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                              child: Icon( isObscure==true ? Icons.visibility :Icons.visibility_off,
                              color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                            onChanged: (p0) {
                             setState(() { });
                           },
                          isObscure: isObscure,
                          prefix:const Padding(
                            padding:  EdgeInsets.symmetric(vertical: 16,horizontal: 17),
                            child: Icon(Icons.lock,
                               size: 22,
                            ),
                          ),
                         ),
                     ),
                   const SizedBox(height: 15),
                    TextLabel(
                      label: allMessages.value.newpassword ?? 'New password',
                       child: MyTextField(
                       key: const ValueKey(345),
                          hint: allMessages.value.newpassword ?? 'New password',
                          onValidate: (p0) {
                             if (p0!.isEmpty) {
                             return allMessages.value.newEnterPassword ?? 'Enter new password';
                           } else if (p0.length < 8) {
                               // return allMessages.value.enterAValidPassword;
                               return  allMessages.value.enterAValidPassword  ?? 'Wrong password';
                             }
                            return null;
                           },
                          focus: focus3,
                           onSaved: (p0) {
                             setState(() {
                              controller3.text = p0.toString();
                               userProvider.user.password = p0!.trim();
                             });
                           },
                            onFieldSubmit: (p0) {
                             focus4.requestFocus();
                             
                           },
                           
                           textInputAction: TextInputAction.next,
                           controller: controller3,
                          suffix: InkResponse(
                            onTap: () {
                              isObscure2 = !isObscure2;
                              setState(() {  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                              child: Icon( isObscure2==true ? Icons.visibility :Icons.visibility_off,
                              color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          isObscure: isObscure2,
                          prefix: const Padding(
                            padding:  EdgeInsets.symmetric(vertical: 16,horizontal: 17),
                            child:Icon(Icons.lock,
                               size: 22,
                            ),
                          ),
                        ),
                        ),
                       SizedBox(height: widget.isReset ? 30 :15),
                         TextLabel(
                      label: allMessages.value.confirmpassword ?? 'Confirm new password',
                       child: MyTextField(
                            hint: allMessages.value.confirmpassword ?? 'Confirm new password',
                             onValidate: (p0) {
                             if (p0!.isEmpty) {
                                  return  allMessages.value.confirmpassword ?? 'Enter confirm new password';
                            } else if (p0.length < 8) {
                               // return allMessages.value.enterAValidPassword;
                               return  allMessages.value.enterAValidPassword  ?? 'Wrong password';
                             }
                            return null;
                           },
                           onChanged: (p0) {
                             setState(() { });
                           },
                           controller: controller4,
                           onSaved: (p0) {
                             setState(() {
                              // controller4!.text = p0.toString();
                               userProvider.user.cpassword = p0!.trim();
                             });
                           },
                           onFieldSubmit: (p0) {
                              if (widget.isReset == true) {
                            setState(() { isLoad = true;});
                              userProvider.resetPass(context,widget.mail ?? "",onChanged: (value) {
                              setState(() { isLoad = false; });
                              });
                          } else {
                              setState(() { isLoad = true;});
                              userProvider.changePassword(context,conPass: controller4.text,
                              newPass: controller3.text, oldPass: controller2.text,onChanged: (value) {
                                setState(() { isLoad = false;});
                              });
                          }
                           },
                            suffix: InkResponse(
                            onTap: () {
                              isObscure3 = !isObscure3;
                              setState(() {  });
                            },
                            
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                              child: Icon( isObscure3==true ? Icons.visibility :Icons.visibility_off,
                            color: Colors.grey.shade400,
                              ),
                            ),
                            ),
                            isObscure: isObscure3,
                            prefix: const Padding(
                            padding:  EdgeInsets.symmetric(vertical: 16,horizontal: 17),
                            child: Icon(Icons.lock,
                               size: 22,
                            ),
                          ),
                           ),
                         ),
                       const Spacer(flex: 3),
                        Button(
                       
                        onTap:() {
                          if (widget.isReset == true) {
                           
                              userProvider.resetPass(context, widget.mail ?? "",onChanged: (value) {
                              setState(() { isLoad = value;});
                              });
                          } else {
                            
                              userProvider.changePassword(context,conPass: controller4.text,
                              newPass: controller3.text, oldPass: controller2.text,onChanged: (value) {
                                setState(() { isLoad = value;});
                              });
                          }
                       },tittle: allMessages.value.submit ?? 'Submit'),
                       const Spacer(flex: 3)
                        ],),
            ),
            ),
            ),
          ),
    
      ),
    );
  }
}


class TextLabel extends StatelessWidget {
  const TextLabel({super.key,this.label='',required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label , style: const TextStyle(
          fontFamily: 'QuickSand',
          fontSize: 14,
        )),
        const SizedBox(height: 8),
        child
      ],
    );
  }
}