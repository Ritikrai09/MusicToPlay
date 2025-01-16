import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/Auth/Forget_password/reset_password.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/screens/fullscreen.dart';
import 'package:blogit/presentation/widgets/loader.dart';
import 'package:blogit/presentation/widgets/nav_util.dart';
import 'package:blogit/Utils/app_theme.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/main.dart';

import '../../../../Utils/custom_toast.dart';
import '../../../../Utils/urls.dart';
import '../../../../controller/repository.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../model/user.dart';

class EditProfile extends StatefulWidget {
 

  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  UserProvider user = UserProvider();
  bool load=false;
   TextEditingController controller = TextEditingController(text: currentUser.value.name);
 TextEditingController controller2 = TextEditingController(text: currentUser.value.email);
  
  File? _image;
  final picker = ImagePicker();


   Future getImage() async {
     
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          load = true;
        } else {}
      });
      var stream = http.ByteStream(_image!.openRead());
      stream.cast();
      var length = await _image!.length();
      var uri = Uri.parse("${Urls.baseUrl}update-profile");
      var request = http.MultipartRequest("POST", uri);
      request.fields["id"] = currentUser.value.id.toString();
      request.headers["api-token"] = currentUser.value.apiToken.toString();
      // request.fields["email"] = userProvider.user.email.toString();
      //  request.fields["phone"] = userProvider.user.id.toString();
      // ignore: unnecessary_new
      var multipartFile = http.MultipartFile('photo', stream, length,
          filename: _image!.path.split('/').last);
      request.files.add(multipartFile);
       
      await request.send().then((response) async {
        
        response.stream.transform(utf8.decoder).listen((value) async {
          
          getCurrentUser();
          await getProfile();
          setState(() {
            currentUser.value.isPageHome = false;
            load = false;
          });
        });
      }).catchError((e) {
       
      });
  }


Future<Users?> getProfile() async {
  try {
  final String url = '${Urls.baseUrl}get-profile';
  final client = http.Client();
  final response = await client.get(
    Uri.parse(url),
    headers: {
      "api-token":currentUser.value.apiToken.toString(),
      HttpHeaders.contentTypeHeader: 'application/json',
    },
  );
   debugPrint(response.body);
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
    setCurrentUser(decode);
    currentUser.value = Users.fromJSON(decode['data']);
    return currentUser.value;
  } else {
    showCustomToast(context,decode['message']);
  }
} on Exception catch (e) {
  throw Exception(e);
}
  return null;
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
      
    MediaQueryData data = MediaQuery.of(context);
    Size size = data.size;
    return CustomLoader(
      isLoading: load,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: const BackbUT(),
          leadingWidth: 62,
          actions: [
            // GestureDetector(
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            //   child: CircleAvatar(
            //     radius: 12.5.r,
            //     backgroundColor: Theme.of(context).colorScheme.onBackground,
            //     child: Icon(
            //       Icons.close,
            //       size: 20,
            //       color: Theme.of(context).cardColor,
            //     ),
            //   ),
            // ),
            SizedBox(
              width: 24.w,
            )
          ],
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Form(
            key: user.updateFormKey,
            child: SingleChildScrollView(
              child: SizedBox(
                height: size.height - (data.padding.top + kToolbarHeight),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    Text(
                     allMessages.value.myProfile ?? 'Update your\nProfile',
                      textAlign: TextAlign.center,
                      style:
                          FontStyleUtilities.h2(context, fontWeight: FWT.extrabold)
                              .copyWith(height: 32 / 28, fontSize: 28),
                    ),
                    // SizedBox(height: 11.h),
                    // Text(
                    //   'Lorem ipsum dolor sit amet, consectetur adipisicing\nelit, sed do eiusmod tempor incididunt.',
                    //   textAlign: TextAlign.center,
                    //   style: FontStyleUtilities.t4(context, fontWeight: FWT.medium),
                    // ),
                    SizedBox(height: 36.h),
                    ProfileEdit(photo: currentUser.value.photo,
                    radius: 65,
                    isEdit: true,onTap: ()async {
                    await getImage();
                   }),
                    SizedBox(height: 36.h),
                     MyTextField(
                      onChanged: (p0) {
                        setState(() {    });
                      },
                      onValidate: (v){
                        if (v!.isEmpty) {
                            return '${allMessages.value.userName} is required';
                          }else  if (isValidString(v) ==  false) {
                              return allMessages.value.enterAValidUserName ?? 'Name must contain 4 characters';
                          }
                          return null;
                        
                      },
                      onSaved: (p0) {
                         user.user.name = controller.text.trim();
                         setState(() { });
                      },
                      controller: controller,
                      hint: allMessages.value.userName ?? 'Username'),
                    SizedBox(height: 12.h),
                     MyTextField(
                    controller: controller2,
                     onChanged: (p0) {
                       setState(() {});
                      },
                     onSaved: (p0) {
                       user.user.email =controller2.text.trim();
                       setState(() { });
                     },
                     readOnly: true,
                    hint: allMessages.value.email ??'Email'),
                    const Spacer(),
                    Button(tittle : allMessages.value.updateProfile ??'Update',
                     onTap: () {
                      user.profile(context, onChanged: (value) {
                        load=value;
                        setState(() {  });
                      });
                     }),
                   SizedBox(
                      height: 12.h
                    ),
                     Row(
                       children: [
                        if(currentUser.value.loginFrom=='email')
                         Expanded(
                           child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(width: 1,color: appThemeModel.value.primaryColor.value)
                            ),
                            elevation: 0
                          ),
                          child: Text(allMessages.value.changePassword ?? 'Change Password',
                          style: TextStyle(color: dark(context) ? Colors.white : Colors.black)),
                           onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder:
                             (context) => const ResetPassword(isReset: false)));
                           }),
                         ),
                         if(currentUser.value.loginFrom=='email')
                         SizedBox(width: 12.w),
                         Expanded(
                           child: 
                         TextButton(
                          
                          style: TextButton.styleFrom(
                                padding:const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(width: 1,color: appThemeModel.value.primaryColor.value)
                            ),
                            elevation: 0
                          ),
                          onPressed:() {
                              showCustomDialog(
                                  context: context,
                                  title: allMessages.value.deleteAccount ?? 'Delete Account',
                                  text: allMessages.value.confirmDeleteAccount ?? 'Do you want to delete account ?',
                                  isTwoButton: true,
                                  onTap: () async{
                                    Navigator.pop(context);
                                    await deleteAccount();
                                  }
                                );
                         }, child: Text(allMessages.value.deleteAccount.toString(),
                         style: TextStyle(color: dark(context) ? Colors.white : Colors.black))))
                       ],
                     ),
                    SizedBox(
                      height: 12.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
 
  Future<void> deleteAccount() async {
  
  load = true;
  setState(() {});

  try {
  // final msg = jsonEncode({"id": currentUser.value.id});
  final String url = '${Urls.baseUrl}delete-account';
  final client = http.Client();
  final response = await client.get(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token" : currentUser.value.apiToken.toString()
    },
    // body: msg,
  );
  Map data = json.decode(response.body);

    if (data['success'] == true) {  
    await prefs!.remove('current_user');
    await prefs!.setBool("isUserLoggedIn", false);
    currentUser.value =Users();  
     setState(() {});
    await Future.delayed(const Duration(milliseconds: 100));

    showCustomToast(context,data['message']);
    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(context) => const Login(
      isFromHome: false,
    )),(route) => false);
  } else {
    load = false;
     setState(() {});
    showCustomToast(context,allMessages.value.somethingWentWrong ?? 'Something went wrong. Try again !!');
  }
} on SocketException{
     load = false;
     setState(() {});
   showCustomToast(context,allMessages.value.noInternetConnection ?? 'No Internet Connection');
}  on Exception {
    load = false;
     setState(() {});
}
  }
}

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({
    super.key,
    this.isEdit=false,
    this.radius,
    this.onTap,
    this.photo
  });

  final bool isEdit;
  final VoidCallback? onTap;
  final String? photo;
  final double? radius;

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {

  
  @override
  Widget build(BuildContext context) {
    String text ='';
    if (currentUser.value.id != null) {
       var first2 = currentUser.value.name!.split(' ').first[0];
      var s = currentUser.value.name!.split(' ').last.isNotEmpty ? first2+currentUser.value.name!.split(' ').last[0] : first2;
       text =currentUser.value.name!.contains(' ') ? s : currentUser.value.name![0];
    }
    return Stack(
      children: [
        widget.photo != null && widget.photo != '' ?
         InkResponse(
          onTap: widget.isEdit == false ? (){
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EditProfile())).then((value) {
                     setState(() {});
                });
          } : () {
               Navigator.push(context,PagingTransform(widget: FullScreen(index:  0,
               isProfile : true,image: widget.photo),slideUp: true));
            },
           child: CircleAvatar(
             radius:widget.radius ?? 60.r,
             backgroundImage:
             CachedNetworkImageProvider( widget.photo ?? '') ,
             backgroundColor:dark(context) ? Colors.grey.shade700 : Colors.grey.shade200,
           ),
         ) : 
         currentUser.value.id == null ?
           CircleAvatar(
           radius:widget.radius ?? 60.r,
           backgroundImage: const AssetImage('asset/Images/Temp/profile.jpeg'),
           backgroundColor:dark(context) ? Colors.grey.shade700 : Colors.grey.shade200,
         ) : CircleAvatar(
           radius:widget.radius ?? 60.r,
           backgroundColor:dark(context) ? Colors.grey.shade700 : Colors.grey.shade200,
           child: Text(text, style: const TextStyle(fontSize: 30,fontWeight: FontWeight.w600)),
         ),
          if(widget.isEdit == true)
          Positioned(
           right: 0,
           bottom:0,
           child: Container(
             decoration: BoxDecoration(
               boxShadow: [
                 BoxShadow(
                   offset: const Offset(0, 4),
                   spreadRadius: -8,
                   blurRadius: 20,
                   color: Colors.grey.shade700
                 )
               ]
             ),
             child: InkResponse(
                onTap:widget.onTap, 
               child: CircleAvatar(
                 radius: 18,
                 backgroundColor: Theme.of(context).cardColor,
                 child: Icon(Icons.edit,
                 size: 20,
                 color: ColorUtil.primaryColor),
               ),
             ),
           ))
      ],
    );
  }
}
