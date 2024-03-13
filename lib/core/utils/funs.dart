import 'package:url_launcher/url_launcher.dart';

void openUrl(String link,{
  LaunchMode? mode,
}) async {
  if (await canLaunchUrl(Uri.parse(link))) {
    await launchUrl(
      Uri.parse(link),
      mode: mode ?? LaunchMode.externalApplication,
    );
  }else{
    print('Could not launch $link');
  }
}