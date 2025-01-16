

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import '../../../model/blog.dart';
import 'package:http/http.dart' as http;
import '../../../utils/color_util.dart';
import '../../Utils/custom_toast.dart';
import '../../Utils/urls.dart';
import '../../controller/user_controller.dart';

class BlogPoll extends StatefulWidget {
  const BlogPoll({super.key,this.model,required this.pollKey,required this.onChanged});
 final Blog? model;
 final GlobalKey<State<StatefulWidget>> pollKey;
 final ValueChanged onChanged;

  @override
  State<BlogPoll> createState() => _BlogPollState();
}

class _BlogPollState extends State<BlogPoll> {
  int? vote;
  bool isLoading = false;  
  bool isExpand=true;

  void _saveVoting(int option) async {
    try {
      final msg = jsonEncode({
        "option_id": option,
        'blog_id': widget.model!.id
      });
      final String url = '${Urls.baseUrl}add-vote';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'api-token': currentUser.value.apiToken.toString(),
          },
        body: msg,
      );
      Map data = json.decode(response.body);
        
       if (data['success'] == true) {
        widget.model!.isVote = option;
        widget.model!.question!.options =[];
        data['data']['options'].forEach((e){
          widget.model!.question!.options!.add(PollOption.fromJSON(e));
        });
       }
         isLoading=false;
        setState(() { });

    } on SocketException {
        isLoading=false;
        setState(() { });
        showCustomToast(context, 'No internet Connection');
      }catch (e){
          isLoading=false;
        setState(() { });
       
    }
  }


  @override
  Widget build(BuildContext context) {
     var textStyle = const TextStyle(
       fontFamily: 'Roboto',
       fontSize: 16,
        color: Colors.white
     );
    return  Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
              children: [
             Padding(
               padding:const EdgeInsets.symmetric(horizontal: 20, vertical:20),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                 children: [
                  Row(
                    children: [
                      const Icon(Icons.poll,
                      size: 20
                      ),
                      const SizedBox(width: 8),
                      Text(allMessages.value.pollTitle ?? 'Signal Poll',
                      style: const TextStyle(fontSize: 16,
                      fontFamily: 'QuickSand',
                      fontWeight: FontWeight.w700)),
                    ],
                  ),
                   AnimatedContainer(
                    duration: const Duration(microseconds: 300),
                    curve: Curves.easeInOut,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 24),
                    // decoration: BoxDecoration(
                    // color: dark(context) ? ColorUtil.white 
                    // : Colors.black,
                      // borderRadius: BorderRadius.circular(20)),
                     child:   Column(
                        children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(  widget.model!.question!.question ??  '',style: 
                                    textStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                       fontFamily: 'QuickSand',
                                      color: dark(context) ? ColorUtil.white : Colors.black
                                    )),
                                  ),
                            //        isExpand && widget.model!.isVote != 0 ?  TapInk(
                            //   pad: 4,
                            //   onTap: () async{
                            //       // Future.delayed(const Duration(milliseconds: 100));
                            //       // await captureScreenshot(widget.pollKey,isPost : true).then((value) async{
                            //       // Future.delayed(const Duration(milliseconds: 10));
                            //       // final  data2 = await convertToXFile(value!);
                            //       // Future.delayed(const Duration(milliseconds: 10));
                            //       // shareImage(data2);
                            //       // provider.addPollShare(widget.model!.id!.toInt());
                            //       // });
                            //     setState(() {   });
                            //   },
                            //   child: SvgPicture.asset(SvgImg.share,
                            //   color:dark(context) ? Colors.white: Colors.black,
                            //   ),
                            // ) : const SizedBox()
                                ],
                              ),
                              // vote == 1 || vote == 0 ? AnimateIcon(
                              //   child: Container(
                              //     key:  ValueKey(widget.model!.id),
                              //     width: size(context).width,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(30)
                              //     ),
                              //     child:  Row(
                              //       children: [
                              //         Expanded(
                              //           flex: 89,
                              //           child: PollPercent(
                              //             poll: 1,
                              //             fraction: double.parse(widget.model!.yesPerc.toString()),
                              //             percText: '${widget.model!.yesPerc.toString()}%',
                              //           ),
                              //         ),
                              //         Expanded(
                              //           flex: 22,
                              //           child: PollPercent(
                              //               poll: 0,
                              //                fraction: double.parse(widget.model!.noPerc.toString()),
                              //               percText: '${widget.model!.noPerc.toString()}%',
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ) : 
                              Column(
                                 key: const ValueKey('boat'),
                                children: [
                                   const SizedBox(height:20),
                                    ...List.generate(widget.model!.question!.options!.length , (index) => 
                                      
                                     Container(
                                      margin:  EdgeInsets.only(bottom:widget.model!.question!.options!.length-1 == index? 0 : 12),
                                      child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0),
                                       child: Stack(
                                         children: [
                                          InkWell(
                                               borderRadius: const BorderRadius.only(
                                                    topRight: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8),
                                                    topLeft: Radius.circular(8),
                                                  ),
                                                onTap: () {
                                                  if (currentUser.value.id != null) {
                                                  
                                                 if (widget.model!.isVote != 0) {
                                                    //  showCustomToast(context, 'Vote already registered');
                                                 } else {
                                                    if (currentUser.value.id == null) {
                                                       Navigator.push(context,MaterialPageRoute(builder:(context) => const Login()));
                                                    } else {
                                                       isLoading = true;
                                                     setState(() {  });
                                                    _saveVoting(widget.model!.question!.options![index].id!.toInt()); 
                                                    }
                                                 }
                                                 }else{
                                                     Navigator.push(context,MaterialPageRoute(builder:(context) => const Login()));
                                                 }
                                                },
                                                child: Container(
                                                width: MediaQuery.of(context).size.width,
                                               // margin: const EdgeInsets.only(bottom: 12),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.only(
                                                    topRight: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8),
                                                    topLeft: Radius.circular(8),
                                                  ),
                                                  border: Border.all(width: widget.model!.isVote == widget.model!.question!.options![index].id ? 1.25 :1 ,
                                                  color: widget.model!.isVote == widget.model!.question!.options![index].id ?
                                                  Theme.of(context).primaryColor : dark(context) ? Colors.grey.shade800 : Colors.black)
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  child: Text(widget.model!.question!.options![index].option.toString(),
                                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                    fontSize: 16,
                                                  )),
                                                ),
                                               ),
                                          ),
                                         if(widget.model!.isVote !=0)
                                           Positioned.fill(
                                            bottom: 0,
                                            child: ClipRRect(
                                               borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                               ),
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                width: (MediaQuery.of(context).size.width-12)*(widget.model!.question!.options![index].percentage!.toInt()/100),
                                                //  decoration: BoxDecoration(
                                                // borderRadius: BorderRadius.circular(10),
                                                color: widget.model!.isVote == widget.model!.question!.options![index].id ?
                                               Theme.of(context).primaryColor.withOpacity(0.3) :
                                                  dark(context) ? Colors.grey.shade800.withOpacity(0.4) :ColorUtil.black.withOpacity(0.3) ,
                                              // ),
                                              child:const Text(''),
                                              ),
                                            )
                                            ),
                                            if(widget.model!.isVote != 0)
                                            Positioned(
                                              right: 8,
                                              top: 16,
                                              child: Text(
                                              "${widget.model!.question!.options![index].percentage.toStringAsFixed(0)}%",
                                              style:const TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 14,
                                                letterSpacing: 1,
                                                fontWeight: FontWeight.w600
                                              )))
                                         ],
                                       ),
                                     )
                                    )
                                    // Expanded(
                                    //   child: IconTextButton(
                                    //   text: 'Yes',
                                    //   padding: const EdgeInsets.symmetric(vertical: 7),
                                    //   style: textStyle,
                                    //   trailIcon: svgPicture,
                                    //   onTap: () {
                                    //     isLoading=true;
                                    //     vote = 1;
                                    //     setState(() {});
               
                                    //     Future.delayed(const Duration(seconds: 2),() {
                                    //      isLoading = false;
                                    //     setState(() {       });
                                    //     });
                                    //   }),
                                    // ),
                                    // const SizedBox(width: 15),
                                    // Expanded(
                                    //   child: IconTextButton(
                                    //   color: ColorUtil.textblack,
                                    //   text: 'No',
                                    //   trailIcon: svgPicture,
                                    //     padding: const EdgeInsets.symmetric(vertical: 7),
                                    //   style: textStyle,
                                    //   onTap: () {
                                    //    isLoading=true;
                                    //     vote = 0;
                                    //     setState(() {});
                                    //      Future.delayed(const Duration(seconds: 2),() {
                                    //         isLoading = false;
                                    //       setState(() {});
                                    //      });
                                         
                                    //   }),
                                    // )
                                    )
                                ],
                              )
                        ],
                      ),
                       ),
                 ],
               ),
             ),
                isLoading ? Positioned.fill(child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),  
                  margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                 curve: Curves.easeIn,
                   decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isLoading ? 
                    dark(context) ? Colors.grey.shade700.withOpacity(0.85) 
                    :ColorUtil.white.withOpacity(0.9) : Colors.transparent 
                  ),
                )): const SizedBox() ,
               isLoading ? 
                   const Positioned.fill(
                    left: 24,
                    right: 24,
                    child: 
                    Center(
                      child: CircularProgressIndicator())
                    ) : const SizedBox() 
              ],
            ),
    );
  }
}

class PollPercent extends StatelessWidget {
  const PollPercent({
    super.key,
    this.fraction,
    this.poll,
    this.percText,
  });

  final int? poll;
  final String? percText;
  final double? fraction;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: poll == 0 ? Colors.black : null,
        // gradient: poll == 0 ? null : [],
        borderRadius: poll == 0 ? const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30)
        ) : const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30)
        )
      ),
      alignment: Alignment.center,
     padding: EdgeInsets.symmetric(vertical: 7,horizontal:fraction! < 20.0 ? 2 : 0),
      child: Text(percText ?? '89%',style: const TextStyle(
        fontFamily: 'Roboto',
        color: Colors.white,
        height: 0,
        fontSize:16,
      )));
  }
}