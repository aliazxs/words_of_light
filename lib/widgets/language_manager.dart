import 'package:words_of_light/widgets/clean_app_bar.dart';
import 'package:words_of_light/widgets/message_popup.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageManager extends StatefulWidget {
  const LanguageManager({
    super.key,
    required this.modelManager,
  });

  final OnDeviceTranslatorModelManager modelManager;

  @override
  LanguageManagerState createState() => LanguageManagerState();
}

class LanguageManagerState extends State<LanguageManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CleanAppBar(title: "Language Manager"),
      body: ListView.builder(
        itemCount: TranslateLanguage.values.length,
        itemBuilder: (context, index) {
          final language = TranslateLanguage.values[index];
          return ListTile(
            title: Text(language.name),
            trailing: FutureBuilder<bool>(
              future: widget.modelManager.isModelDownloaded(language.bcpCode),
              builder: (context, snapshot) => Icon(
                snapshot.hasData && snapshot.data == true
                    ? Icons.download_done
                    : null,
              ),
            ),
            onTap: () async {
              if (await widget.modelManager.downloadModel(language.bcpCode)) {
                messagePopup(
                  context,
                  "Finished downloading",
                  "Successfully downloaded ${language.name}.",
                );
              } else {
                messagePopup(
                  context,
                  "Error while downloading",
                  "Couldn't download ${language.name}.",
                );
              }
            },
          );
        },
      ),
    );
  }
}
