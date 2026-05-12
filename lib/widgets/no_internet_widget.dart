import 'package:flutter/material.dart';
import 'package:tech_app/l10n/app_localizations.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ICON
              Icon(Icons.wifi_off, size: 80, color: Colors.grey),

              SizedBox(height: 20),

              /// TITLE
              Text(
                AppLocalizations.of(context)!.noInternetTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              /// DESCRIPTION
              Text(
                AppLocalizations.of(context)!.noInternetMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
