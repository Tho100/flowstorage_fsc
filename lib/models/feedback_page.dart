import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/AlertForm.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/SingleText.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedBackPage extends StatelessWidget {
  FeedBackPage({super.key});

  final feedBackController = TextEditingController();

  Future<void> sendFeedback(String feedbackInput) async {

    final currentdate = DateFormat('dd/MM/yyyy');

    const query = "INSERT INTO feedback_info VALUES (:username,:feedback,:date)";
    final params = {"username": Globals.custUsername,"feedback": feedbackInput,"date": currentdate};

    await Crud().insert(query: query, params: params);
  }

  Widget buildTextField(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
              enabled: true,
              controller: feedBackController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "Write your feedback",
                contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
                fillColor: ThemeColor.darkGrey,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    width: 2.0,
                    color: Color.fromARGB(255, 6, 102, 226),
                  ),
                ),
              ),
            ),
            
          ),
        ),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28),
          child: HeaderText(title: "Feedback", subTitle: "We kindly request your feedback and features idea to improve Flowstorage experience."),
        ),
        
        const SizedBox(height: 35),        

        buildTextField(context),

        const SizedBox(height: 15),

        MainButton(
          text: "Send",
          onPressed: () async {
            final loading = SingleTextLoading();
            loading.startLoading(title: "Sending feedback...",context: context);
            sendFeedback(feedBackController.text);
            loading.stopLoading();

            AlertForm.alertDialogTitle("Feedback sent", "Thank you ${Globals.custUsername} for your feedback! We really appreciate it.", context);
          }
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
      ),
      body: buildBody(context)
    );
  }
}