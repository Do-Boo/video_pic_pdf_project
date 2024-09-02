import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mom_project/theme/t_app_color.dart';
import 'package:mom_project/widgets/%08w_line.dart';

class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              height: 66,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Text("ALl FILES", style: TextStyle(fontSize: 21)),
                  const Expanded(child: SizedBox()),
                  HugeIcon(icon: HugeIcons.strokeRoundedAddSquare, color: customTheme.textColor.withOpacity(0.5)),
                  const SizedBox(width: 32),
                  HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: customTheme.textColor.withOpacity(0.5)),
                  const SizedBox(width: 32),
                  HugeIcon(icon: HugeIcons.strokeRoundedStar, color: customTheme.textColor.withOpacity(0.5)),
                ],
              ),
            ),
            const CustomLine(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 42,
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: customTheme.containerColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedFolder01, color: customTheme.textColor.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, color: customTheme.textColor.withOpacity(0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(child: Text("asdfasdfasdfasdfasdfasdfasdf")),
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 42,
                    width: 184,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: customTheme.containerColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedFolder01, color: customTheme.textColor.withOpacity(0.5)),
                        const SizedBox(width: 8),
                        const Text("Show All"),
                        const Expanded(child: SizedBox()),
                        Icon(Icons.keyboard_arrow_down_rounded, color: customTheme.textColor.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.8 / 1,
              ),
              itemCount: 25,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: customTheme.containerColor,
                  ),
                  child: Center(child: Text('${index + 1}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
