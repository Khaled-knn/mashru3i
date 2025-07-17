import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mashrou3i/core/theme/color.dart';

import '../../../../../widgets/compnents.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor =Theme.of(context).primaryColor;
    final secondaryColor = textColor;

    return Scaffold(
      appBar: AppBar(
        leading: popButton(context),
        title: Text('terms_title'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold , fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:[Theme.of(context).primaryColor , Colors.white],

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
              colors: [Colors.grey[900]!, Colors.grey[850]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
                : LinearGradient(
              colors: [Colors.grey[100]!, Colors.grey[50]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
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
                          Icon(Icons.assignment_outlined,
                              size: 50, color: primaryColor),
                          const SizedBox(height: 10),
                          Text(
                            'terms_title'.tr(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Last updated date
                    Row(
                      children: [
                        Icon(Icons.update, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'last_updated'.tr(args: ['June 2023']),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section divider
                    Divider(
                      thickness: 1,
                      color: secondaryColor,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 20),

                    // Terms text with section headings
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'terms_section1_title'.tr()),
                        const SizedBox(height: 8),
                        _buildSectionText('terms_section1_text'.tr(), theme, isDarkMode),

                        const SizedBox(height: 24),
                        _buildSectionTitle(context, 'terms_section2_title'.tr()),
                        const SizedBox(height: 8),
                        _buildSectionText('terms_section2_text'.tr(), theme, isDarkMode),

                        const SizedBox(height: 24),
                        _buildSectionTitle(context, 'terms_section3_title'.tr()),
                        const SizedBox(height: 8),
                        _buildSectionText('terms_section3_text'.tr(), theme, isDarkMode),
                      ],
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
                          backgroundColor: primaryColor,
                          foregroundColor: isDarkMode ? Colors.black : Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'i_agree'.tr(),
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

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color:textColor,
      ),
    );
  }

  Widget _buildSectionText(String text, ThemeData theme, bool isDarkMode) {
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
      ),
      textAlign: TextAlign.justify,
    );
  }
}