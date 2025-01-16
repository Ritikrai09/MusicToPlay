import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/widgets/loader.dart';
import 'package:blogit/Utils/custom_toast.dart';

import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Utils/app_theme.dart';
import '../../../../controller/user_controller.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  UserProvider user  = UserProvider();
  @override
  void initState() {
    controller2 = TextEditingController(text: currentUser.value.email);
    controller1 = TextEditingController(text: currentUser.value.name);
    controller3 = TextEditingController();
    super.initState();
  }

bool load=false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CustomLoader(
      isLoading: load,
      child: Builder(builder: (context) {
        return Form(
          key: user.contactFormKey,
          child: Scaffold(
            bottomNavigationBar: Container(
                padding: EdgeInsets.only(
                    left: 24.w, right: 24.w, bottom: 36.h, top: 10.w),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SignalOutlinedButton(
                  
                  tittle: allMessages.value.send ?? 'Send', onTap: () {
                  if (user.contactFormKey!.currentState!.validate()) {
                    user.contactFormKey!.currentState!.save();
                   setState(() {
                     load=true;
                   });
                   user.setContact(controller1.text, controller2.text, controller3.text).then((value) {
                       if (value['success'] == true) {
                         showCustomToast(context, value["message"]);
                         Navigator.pop(context);
                       } else {
                          showCustomToast(context, value["message"]);
                           setState(() {
                            load=false;
                          });
                       }
                       setState(() {
                        load=false;
                      });
                   }).onError((e,s){
                    setState(() {
                        load=false;
                      });
                   });
                  }
                })),
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return true;
              },
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    MyStickyHeader(
                        floating: true,
                        elevation: 0,
                        height: 65.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                const BackbUT(),
                                  Text(
                                   allMessages.value.contactUs  ?? 'Contact',
                                    style: FontStyleUtilities.h5(context,
                                            fontWeight: FWT.extrabold)
                                        .copyWith(fontSize: 20),
                                  ),
                                   ThemeButton(
                                    onChanged: (value) {
                                        toggleDarkMode(!appThemeModel.value.isDarkModeEnabled.value);
                                          setState(() {    });
                                    },
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h)
                          ],
                        )),
                    MyStickyHeader(
                        pinned: true,
                        height: 56.h,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width,
                              ),
                              Center(
                                child: Text(
                                allMessages.value.getInTouch  ?? 'Get in touch',
                                  style: FontStyleUtilities.h3(
                                    context,
                                    fontWeight: FWT.extrabold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 14.h,
                              )
                            ],
                          ),
                        )),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 14.h,
                      ),
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate([
                       ContactUsTile(
                        tittle: allMessages.value.name ?? 'Name', 
                      value: MyTextField(
                        hint: allMessages.value.name ??'Enter name',
                         onValidate: (v) {
                               if (v!.isEmpty || v.length < 4) {
                                  return allMessages.value.enterAValidUserName ?? 'Name must contain 4 characters';
                              }
                              return null;
                            },
                            onSaved: (v) {
                              setState(() {
                                controller1.text = v.toString().trim();
                              });
                            },
                          
                        controller : controller1
                      )),
                      ContactUsTile(
                        tittle: allMessages.value.email ?? 'Email',
                        value:  MyTextField(
                          hint:  allMessages.value.email ?? 'Enter email',
                           onValidate: (v) {
                            bool emailValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v!);
                            
                            if (v.isEmpty || emailValid == false) {
                              return allMessages.value.enterAValidEmail ?? 'Enter a valid email';
                            }
                            return null;
                          },
                        onSaved: (v) {
                          setState(() {
                            controller2.text = v!.trim();
                          });
                        },
                          controller:controller2),
                        color: Theme.of(context).primaryColor,
                      ),
                     // SizedBox(height: 6.h),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 30.w),
                      //   child: const Row(
                      //     children:  [
                      //       Expanded(
                      //         child: MyDropDown(),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(height: 12.h),
                      ContactUsTile(
                        tittle:allMessages.value.message ?? 'Message',
                        value:  SizedBox(
                          height: 150,
                          child: MyTextField(
                            controller: controller3,
                            maxLines: 5,
                            autoFocus: true,
                            onValidate: (p0) {
                              if (p0!.isEmpty) {
                                return allMessages.value.messageRequired ?? 'Message field is empty';
                              } else {
                                return null;
                              }
                            },
                            onSaved: (p0) {
                              controller3.text = p0.toString().trim();
                              setState(() {     });
                            },
                            hint: allMessages.value.message ?? 'Message',
                            maxHeight: 150.h,
                          ),
                        ),
                      )
                    ])),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class MyDropDown extends StatefulWidget {
  const MyDropDown({
    super.key,
  });

  @override
  State<MyDropDown> createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String selectedValue = 'Interested In';
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        icon: const RotatedBox(
            quarterTurns: 1, child: SvgIcon('asset/Icons/arrow_right.svg')),
        value: selectedValue,
        isExpanded: true,
        underline: Container(color: Colors.transparent),
        borderRadius: BorderRadius.circular(8),
        alignment: Alignment.centerRight,
        style: FontStyleUtilities.t2(context,
            fontWeight: FWT.bold, fontColor: ColorUtil.themNeutral),
        items: [
          'Interested In',
          'FeedBack',
          'Help',
          'Bug report',
          'Subscription error'
        ]
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) {
          selectedValue = value ?? 'Interested In';
          setState(() {});
        });
  }
}

class MyCollapsedTextField extends StatelessWidget {
  const MyCollapsedTextField(
      {super.key,
      required this.hint,
      this.maxLines = 1,
      this.maxHeight,
      this.controller,
      this.onSubmitted,
      this.node});
  final String hint;
  final FocusNode? node;
  final int? maxLines;
  final TextEditingController? controller;
  final double? maxHeight;
  final ValueChanged<String>? onSubmitted;
  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(width: 1, color: Colors.transparent));
    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 18.h),
      child: TextField(
        focusNode: node,
        style: FontStyleUtilities.t2(context,
            fontColor: ColorUtil.themNeutral, fontWeight: FWT.bold),
        onSubmitted: onSubmitted,
        cursorColor: Theme.of(context).primaryColor,
        maxLines: maxLines,
        controller:controller,
        showCursor: true,
        
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: FontStyleUtilities.t2(context,
            fontWeight: FWT.bold, fontColor: ColorUtil.themNeutral),
            constraints: BoxConstraints(maxHeight: maxHeight ?? 20.h),
            filled: true,
            fillColor: dark(context) ? Colors.grey.shade800 : ColorUtil.themNeutral,
            border: border,
            focusedBorder: border,
            enabledBorder: border),
      ),
    );
  }
}

class ContactUsTile extends StatelessWidget {
  const ContactUsTile({
    super.key,
    required this.tittle,
    required this.value,
    this.color,
  });
  final String tittle;
  final Widget value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tittle,
                    style: FontStyleUtilities.t4(context,
                        fontColor: ColorUtil.themNeutral, fontWeight: FWT.bold),
                  ),
                  SpaceUtils.ks8.height(),
                  value
                ],
              ),
            ),
            SizedBox(
              height: 12.h,
            ),
          ],
        ));
  }
}
