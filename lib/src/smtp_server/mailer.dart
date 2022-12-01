import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future Mailer(String code, String email, int mailActived,
    String body, String footer) async {

  String bodyStr = createMsg(code, mailActived, body, footer);
  SmtpServer smtpServer = SmtpServer('smtp.ionos.es',
  port: 465,
  username: 'noreply@kellyfindermail.com',
  password: 'a98sdfADF!',
  ssl: true);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.
  // Create our message.
  final message = Message()
    ..from = Address('noreply@kellyfindermail.com', 'Kelly Finder')
    ..recipients.add(email)
    ..subject = 'SORTEO CESTA DE NAVIDAD'
    ..text = ''
    ..html = bodyStr;

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

String createMsg(String code, int mailActived, String body, String footer) {
  if(mailActived == 1){
    return '$body'
        '<br><br>Su número asignado es: $code'
        '$footer';
  }else{
    return '$body'
        '$footer';
  }
}