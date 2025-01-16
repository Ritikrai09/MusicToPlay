import 'dart:convert';
import 'dart:io';

import 'package:blogit/Utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/Home_wrapper/home_wrapper.dart';
import 'package:blogit/presentation/widgets/loader.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../../../Utils/custom_toast.dart';
import '../../../Utils/urls.dart';
import '../../../controller/app_provider.dart';
import '../../../controller/user_controller.dart';

class SelectInterest extends StatefulWidget {
  const SelectInterest({super.key,this.isDrawer=false});
  final bool isDrawer;

  @override
  State<SelectInterest> createState() => _SelectInterestState();
}

class _SelectInterestState extends State<SelectInterest>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  bool load=false;
  List<int> selectCategories = [];

  @override
  void initState() {

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, .80, curve: Curves.decelerate)));
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((widget){ 
        var provider = Provider.of<AppProvider>(context,listen: false);
        provider.selectedFeed.forEach((e){
        selectCategories.add(e);
      });
      setState(() { });
     });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

   Future setCategory(AppProvider provider) async {
    
    if ( selectCategories.length < 3) {
      showCustomToast(context ,allMessages.value.minimum3Select  ?? "Minimum 3 should be selected");
    } else {
    
      if (true) {

        final formMap = jsonEncode({
          "category_id": selectCategories
        });
        try {
          setState(() {
            load = true;
          });
          var url = "${Urls.baseUrl}add-feed";
          var result = await http.post(
            Uri.parse(url),
            headers: {
             HttpHeaders.contentTypeHeader: "application/json",
              "api-token" : currentUser.value.apiToken ?? '',
            },
            body: formMap,
          );

          Map data = json.decode(result.body);

          if (result.statusCode == 200) {
            showCustomToast(context,data['message']);
            if (widget.isDrawer) {
                setState(() {
                  load = true;
                });
                  await provider.getCategory(headCall: false).then((value) {
                    setState(() {
                      load = false;
                    });
             Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => const HomeWrapper(key: ValueKey(23))),(route) => false);
              });
            }
            if (!widget.isDrawer) {
              setState(() {
                load = true;
               currentUser.value.isNewUser = true;
              });
              await provider.getCategory().then((value) {
                setState(() {
                  load = false;
                });
               Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => const HomeWrapper()),(route) => false);
              });
              // });
            }
          }
          setState(() {
            load = false;
          });
        } catch (e) {
          setState(() {
            load = false;
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
   var provider = Provider.of<AppProvider>(context,listen: false);
    return CustomLoader(
      isLoading: load,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor ,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: widget.isDrawer==false ? 82.h : 62.h,
              ),
             widget.isDrawer==false ? const SizedBox() : InkResponse(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                  'asset/Icons/arrow.png',
                  width: 24,
                  height: 24,
                  color: dark(context) ? Colors.white 
                  : Colors.black)),
              SizedBox(height: 22.h),
              AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, snapshot) {
                    return Transform.translate(
                      offset: Offset(size.width * _animation.value, 0),
                      child: Text(
                       widget.isDrawer ? allMessages.value.editSaveInterests  ?? 'Customize your interests for better content & experience.'
                       : allMessages.value.saveYourInterestsForBetterContentExperience ?? 'Save your interests for better content & experience.',
                        style: FontStyleUtilities.h3(context,
                            fontWeight: FWT.extrabold,
                            fontColor: dark(context) ? Colors.white :Theme.of(context).primaryColor),
                      ),
                    );
                  }),
              SizedBox(
                height: 32.h,
              ),
              Expanded(
                child: SingleChildScrollView(
                child: Column(
                  children: [
                    InterestWrapper(usersInterest: (value) {},
                    selectCategories: selectCategories
                    ),
                  ],
                ))
              ),
               SizedBox(height: 24.h),
              Button(
                color: Theme.of(context).primaryColor,
                  tittle: allMessages.value.saveInterests ?? 'Save Interests',
                  onTap: () {
                    setCategory(provider);
                  },
                  textColor: isWhiteRange(Theme.of(context).primaryColor) ? Colors.black : Colors.white,
                ),
              SizedBox(
                height: 56.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InterestWrapper extends StatefulWidget {
  const InterestWrapper({
    super.key,required this.usersInterest,
    required this.selectCategories
  });

  final ValueChanged<List> usersInterest;
  final List<int> selectCategories;
  @override
  _InterestWrapperState createState() => _InterestWrapperState();
}

class _InterestWrapperState extends State<InterestWrapper>
    with SingleTickerProviderStateMixin {
      
  late AnimationController _animationController;
  late List<String> _interests;
  late List<Animation<double>> _animationList;
  late AppProvider provider;

  late List<int> selectCategories;

  @override
  void initState() {
    selectCategories = widget.selectCategories;
    _interests = [];
    _animationList = [];
     provider = Provider.of<AppProvider>(context,listen: false);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000));
    List.generate(
        provider.blog!.categories!.length,
        (int index) => _animationList.add(Tween<double>(begin: 1, end: 0)
            .animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                    0.0 * ((index * (1 / provider.blog!.categories!.length)) + 1),
                    .2 * ((index * (1 /provider.blog!.categories!.length)) + 1),
                    curve: Curves.decelerate)))));

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationList.clear();
    _interests.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return ListView.builder(
      itemCount: provider.blog!.categories!.length,
      itemBuilder: (context, index1) {
        return InkWell(
          onTap:(){
            if ( selectCategories.contains(provider.blog!.categories![index1].id!.toInt())) {
              
            } else {
              
            }
          }, 
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                InterestWidget(title: provider.blog!.categories![index1].title ?? "",
                 onTap: () {
                      if (selectCategories.contains( provider.blog!.categories![index1].id!.toInt())) {
                          selectCategories.remove( provider.blog!.categories![index1].id!.toInt());
                        } else {
                          selectCategories.add( provider.blog!.categories![index1].id!.toInt());
                        }
                        setState(() {});
                  },
                isChecked:  selectCategories.contains(provider.blog!.categories![index1].id!.toInt()),
                ),
                if(provider.blog!.categories![index1].blogSubCategory != null  && provider.blog!.categories![index1].blogSubCategory!.isNotEmpty)
                SizedBox(height: 12),
                if(provider.blog!.categories![index1].blogSubCategory != null  && provider.blog!.categories![index1].blogSubCategory!.isNotEmpty)
                Wrap(
                  runSpacing: 24.h,
                  spacing: 12.w,
                  children: [
                    ...List.generate(provider.blog!.categories![index1].blogSubCategory!.length, (index) {
                      var interest = provider.blog!.categories![index].blogSubCategory![index];
                      return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, snapshot) {
                            return Transform.translate(
                              offset: Offset(size.width * _animationList[index].value, 0),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width : size.width/3.75,
                                    child:
                                      InterestWidget(title: provider.blog!.categories![index1].title ?? "",
                                       onTap: () {
                                              if (selectCategories.contains(interest.id!.toInt())) {
                                                  selectCategories.remove(interest.id!.toInt());
                                                } else {
                                                  selectCategories.add(interest.id!.toInt());
                                                }
                                                widget.usersInterest(selectCategories);
                                                setState(() {});
                                         },
                                      isChecked:  selectCategories.contains(provider.blog!.categories![index1].id!.toInt()),
                                      ),
                                  ),
                                   if(selectCategories.contains(interest.id!.toInt()))
                                    Positioned(
                                     top:4,
                                     right : 4,
                                     child: CircleAvatar(radius : 12, 
                                     backgroundColor:  Colors.green.shade700,
                                     child:const Icon(Icons.done, size: 12)
                                    ),
                                   )
                                ],
                              )
                            );
                          });
                    })
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class InterestWidget extends StatelessWidget {
  const InterestWidget({
    super.key,
    required this.title,
    this.isChecked=false,
    this.isBackgroundColor=false,
    this.color,
    required this.onTap
  });

  final String title;
  final bool isChecked;
  final VoidCallback onTap;
  final Color? color;
  final bool isBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: isBackgroundColor ? EdgeInsets.symmetric(vertical: 4,horizontal: 8) : null,
        decoration: BoxDecoration(
          color: isBackgroundColor ? color : null,
          borderRadius: BorderRadius.circular(100)
        ),
        child: Row(
          children: [
            Text(title),
            SizedBox(width: 12),
            CheckWidget(isChecked: isChecked)
          ],
        ),
      ),
    );
  }
}

class CheckWidget extends StatelessWidget {
  const CheckWidget({
    super.key,
    required this.isChecked,
  });

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:
        isChecked == true ?
         Theme.of(context).primaryColor : null,
        border: Border.all(width: 1,color: Theme.of(context).dividerColor)
      ),
      width: 24,
      height: 24,
      child: isChecked == true ? Icon(Icons.check) : SizedBox(),
    );
  }
}

class TheInterestButton extends StatefulWidget {
  const TheInterestButton(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.onTap});
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  _TheInterestButtonState createState() => _TheInterestButtonState();
}

class _TheInterestButtonState extends State<TheInterestButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
            color: widget.isSelected ? Colors.white : Colors.transparent,
            border: Border.all(
                color: widget.isSelected ? Colors.white : Colors.white24,
                width: 1.5),
            borderRadius: BorderRadius.circular(18.r)),
        padding: EdgeInsets.only(
          left: 23.w,
          right: 23.w,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: FontStyleUtilities.t4(context,
                  fontWeight: FWT.extrabold,
                  fontColor: widget.isSelected ? Colors.black : Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
