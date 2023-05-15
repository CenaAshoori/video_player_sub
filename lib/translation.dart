import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player_sub/controller/translation_controller.dart';

Future<void> translationDialog(String text, {String? backbtn}) async {
  TranslationController trc = Get.find();

  if (trc.sourceText != text) {
    trc.translate(text);
    trc.sourceText = text;
  }

  await Get.bottomSheet(
    DraggableScrollableSheet(
        snap: true,
        snapSizes: [
          .5,
          .6,
          .7,
          .8,
          .9,
        ],
        expand: true,
        initialChildSize: .5,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromARGB(255, 253, 253, 253),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "From: ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TranslateDropDown(
                                      initialChoice: trc.fromLang,
                                      onChange: (value) {
                                        trc.fromLang = value;
                                      },
                                      isSourceLang: true,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "To: ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TranslateDropDown(
                                      initialChoice: trc.toLang,
                                      onChange: (value) {
                                        trc.toLang = value;
                                      },
                                      isSourceLang: false,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          // Sticky title
                          Container(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                          Divider(),
                          // Body
                          Obx(() {
                            return trc.isLoading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : SizedBox(
                                    width: 342,
                                    child: Text(
                                      trc.translated.isNotEmpty
                                          ? trc.translated
                                          : "",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                          })
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Get.theme.accentColor),
                            ),
                            child: InkWell(
                              onTap: () {
                                trc.translate(text);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  backbtn ?? "Translate",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () => Get.back(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                backbtn ?? "SKIP",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
    isScrollControlled: true,
  );
}

class TranslateDropDown extends StatefulWidget {
  final int initialChoice;
  final Function(int) onChange;
  final bool isSourceLang;
  TranslateDropDown(
      {Key? key,
      required this.initialChoice,
      required this.onChange,
      required this.isSourceLang})
      : super(key: key);

  @override
  _TranslateDropDownState createState() => _TranslateDropDownState();
}

class _TranslateDropDownState extends State<TranslateDropDown> {
  int curentValue = 0;
  @override
  void initState() {
    curentValue = widget.initialChoice;
    super.initState();
  }

  TranslationController trc = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: DropdownButton<int>(
        value: curentValue,
        items: [
          if (widget.isSourceLang)
            DropdownMenuItem<int>(
              value: -1,
              child: Text(
                'Auto',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          for (var i = 0; i < trc.options.length; i++)
            DropdownMenuItem<int>(
              value: i,
              child: Text(
                trc.options[i],
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
        ],
        onChanged: (value) {
          setState(() {
            curentValue = value!;
            widget.onChange(value);
          });
        },
      ),
    );
  }
}
