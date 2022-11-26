import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future Mailer(String code, String email) async {

  String bodyStr = createMsg(code);
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

String createMsg(String code) {
  return 'Bienvenido a Kelly Finder,'
      '<br><br>Le informamos que el número que le enviamos en este correo, es con el que participará en el Sorteo de Navidad del día 22 de Dic de 2022. '
      '<br><br>Si el número recibido es posterior al día 21-Dic-2022 a las 23:59, ya no será válido para este Sorteo de Navidad.'
      '<br><br>Su número asignado es: $code'
      '<br><br>Le deseamos mucha suerte.'
      '<br><br>Un saludo,'
      '<br>Equipo Kelly Finder.';
}