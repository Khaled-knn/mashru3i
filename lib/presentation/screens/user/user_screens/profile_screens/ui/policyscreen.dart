import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mashrou3i/core/theme/color.dart';

import '../../../../../widgets/compnents.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: popButton(context),
        title: Text('privacy_title'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold ,fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.white],

              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
            colors: [Colors.grey[900]!, Colors.grey[800]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : LinearGradient(
            colors: [Colors.grey[50]!, Colors.grey[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.privacy_tip_outlined,
                              size: 50,
                              color:
                                   Theme.of(context).primaryColor
                                  ),
                          const SizedBox(height: 10),
                          Text(
                            'privacy_title'.tr(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color : textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Last updated date
                    Text(
                      'last_updated'.tr(args: ['June 2023']),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Divider with decoration
                    Divider(
                      thickness: 1,
                      color: isDarkMode ? Colors.blueGrey : Colors.grey[300],
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 20),
                    // Privacy policy text
                    Text(
                      'privacy_text'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 30),
                    // Accept button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,

                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'i_understand'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                      ),
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
}