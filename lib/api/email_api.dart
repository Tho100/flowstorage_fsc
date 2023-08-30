import 'package:flowstorage_fsc/connection/auth_config.dart';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailApi {

  static const _fromAddress = "flowstoragebusiness@gmail.com";
  final smtpServer = gmail(_fromAddress, AuthConfig.emailApiAuth);

  Future<bool> sendFinishedRegistration({required String email}) async {

    bool isEmailSent = false;

    final message = Message()
    ..from = const Address(_fromAddress, 'Flowstorage')
    ..recipients.add(email)
    ..subject = 'Flowstorage - Welcome!'
    ..text = ''
    ..html = '''
      <html>
        <head>
          <style>
            .container {
              padding: 20px;
              background-color: #121212;
              display: inline-block; 
              width: 95%;
              text-align: center;
              color: #f6f6f6;
              font-family: 'Poppins', sans-serif; 
            }
            h1 {
              color: #f6f6f6;
            }
            h2 {
              color: #121212;
              font-weight: 700;
              padding: 8px;
            }
            span.flowstorage {
              color: #4a03a4;
              font-size: 24px;
              font-weight: 900;
              padding: 8px;
            }
            h3 {
              font-size: 24px;
              color: #4a03a4;
              padding: 8px;
            }
            ul, li {
              font-size: 18px;
              color: #121212;
              padding: 8px;
            }
          </style>
        </head>
        <body>
          <h1><span class="container">Account Created Successfully</span></h1>
          <h3> Hello newly registered<br><span class="flowstorage">Flowstorage</span>user!</h3>
          <h2>Here's a little of things you can do with Flowstorage:</h2>
          <ul>
            <li>  Backup your photos and videos</li>
            <li>  Backup your files, including documents, text files, etc.</li>
            <li>  ... and more!</li>
          </ul>
        </body>
      </html>
    ''';

    try {

      await send(message, smtpServer);
      isEmailSent = true;

    } on MailerException catch (e) {

      isEmailSent = false;
      for (var p in e.problems) {
        Logger().i("${p.code}\n${p.msg}");
      }

    }

    return isEmailSent;
  }

  Future<void> sendAccountUpgraded({
    required String plan, 
    required String price,
    required String email
  }) async {

    final planToColor = {
      "Max": "#FAC304",
      "Express": "#3164A9",
      "Supreme": "#4A03A4"
    };

    final message = Message()
    ..from = const Address(_fromAddress, 'Flowstorage')
    ..recipients.add(email)
    ..subject = 'Flowstorage - Account Plan Upgraded!'
    ..text = ''
    ..html = '''
      <html>
        <head>
          <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
          <style>
            .container {
              background-color: #121212;
              padding: 20px; 
              display: inline-block; 
              width: 95%;
              text-align: center;
              color: #f6f6f6;
              font-family: 'Poppins', sans-serif; 
            }

            table {
              width: 100%;
              border-collapse: collapse;
              border-radius: 15px;
            }

            table, th, td {
              border: 3px solid #121212;
            }

            th, td {
              padding: 10px;
              text-align: center;
              color: #121212;
              font-weight: bold;
              font-size: 24px;
              font-family: 'Poppins', sans-serif;
            }

            .price {
              font-size: 30px;
              font-family: 'Poppins', sans-serif;
            }

            .plan {
              font-size: 30px;
              color: ${planToColor[plan]};
              font-family: 'Poppins', sans-serif;
            }

            h3 {
              color: #121212;
              font-family: 'Poppins', sans-serif;
            }

          </style>
        </head>
        <body>
          <h1><span class="container">Account Plan Upgraded</span></h1>
          <table>
            <tr>
              <th>PLAN</th>
              <th>PRICE</th>
            </tr>
            <tr>
              <td class="plan">$plan</td>
              <td class="price">$price/monthly</td>
            </tr>
          </table>
          <h3>Cancel anytime without getting extra charges.</h3>
        </body>
      </html>
    ''';

    try {

      await send(message, smtpServer);

    } on MailerException catch (e) {

      for (var p in e.problems) {
        Logger().i("${p.code}\n${p.msg}");
      }

    }

  }

}