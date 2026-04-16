import 'package:flutter/material.dart';
import 'package:tornado_img_app/extentions.dart';

class UnlockAllBottomSheet extends StatefulWidget {
  const UnlockAllBottomSheet({super.key, required this.onUnlockAll});

  final void Function(String passphrase) onUnlockAll;

  @override
  State<UnlockAllBottomSheet> createState() => _UnlockAllBottomSheetState();
}

class _UnlockAllBottomSheetState extends State<UnlockAllBottomSheet> {
  final _controller = TextEditingController();

  bool showPassphrase = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Unlock All Images", style: context.textTheme.titleMedium),
              Text(
                "This will attempt to unlock all encrypted images in your archive with the following passphrase",
                textAlign: TextAlign.center,
              ),
              TextFormField(
                controller: _controller,
                obscureText: !showPassphrase,
                decoration: InputDecoration(
                  labelText: "Passphrase",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPassphrase = !showPassphrase;
                      });
                    },
                    icon: Icon(
                      showPassphrase
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onUnlockAll(_controller.text);
                  Navigator.pop(context);
                },
                child: const Text("Unlock All"),
              ),
            ],
          ),
        );
      },
    );
  }
}
