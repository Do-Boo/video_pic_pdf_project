import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mom_project/gets/g_nas_file_controller.dart';
import 'package:mom_project/theme/t_app_color.dart';
import 'package:mom_project/widgets/w_hover_container.dart';
import 'package:mom_project/widgets/w_hover_text.dart';
import 'package:mom_project/widgets/w_line.dart';

class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final controller = Get.find<SynologyFileListController>();

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
            const SizedBox(height: 24),
            Row(
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
                Expanded(
                  child: Obx(() {
                    return Row(
                      children: controller.currentPath.value.split("/").map((e) {
                        if (e.isNotEmpty) {
                          return Row(
                            children: [
                              const SizedBox(width: 8),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowLeft01,
                                color: customTheme.textColor.withOpacity(0.5),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              HoverText(data: e),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      }).toList(),
                    );
                  }),
                ),
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
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 3.4 / 1,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.error.isNotEmpty) {
                  return Center(child: Text(controller.error.value));
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 1.8 / 1,
                    ),
                    itemCount: controller.currentPath.value != '/' ? controller.items.length + 1 : controller.items.length,
                    itemBuilder: (context, index) {
                      if (controller.currentPath.value != '/' && index == 0) {
                        return InkWell(
                          onTap: controller.goToParentFolder,
                          child: HoverContainer(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(flex: 3, child: SizedBox()),
                                HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, size: 32, color: customTheme.textColor.withOpacity(0.5)),
                                const Expanded(flex: 3, child: SizedBox()),
                                const Text('', style: TextStyle(fontSize: 16)),
                                const Expanded(flex: 2, child: SizedBox()),
                                Text("   ...", style: TextStyle(fontSize: 12, color: customTheme.textColor.withOpacity(0.4))),
                                const Expanded(flex: 2, child: SizedBox()),
                              ],
                            ),
                          ),
                        );
                      } else {
                        var item = controller.items[controller.currentPath.value != '/' ? index - 1 : index];
                        return InkWell(
                          onTap: item['isdir'] == true ? () => controller.navigateToFolder(item['path']) : null,
                          child: HoverContainer(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(flex: 3, child: SizedBox()),
                                Icon(item['isdir'] == true ? Icons.folder : Icons.insert_drive_file, size: 32, color: customTheme.textColor.withOpacity(0.5)),
                                const Expanded(flex: 3, child: SizedBox()),
                                FittedBox(fit: BoxFit.scaleDown, child: Text(item['name'] ?? '', style: const TextStyle(fontSize: 16))),
                                const Expanded(flex: 2, child: SizedBox()),
                                if (item['isdir'] == true)
                                  FutureBuilder<int>(
                                    future: controller.getSubItemCount(item['path']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Text('Loading...');
                                      } else if (snapshot.hasError) {
                                        return const Text('Error');
                                      } else {
                                        return Text(
                                          "${snapshot.data ?? 0} files",
                                          style: TextStyle(fontSize: 12, color: customTheme.textColor.withOpacity(0.4)),
                                        );
                                      }
                                    },
                                  ),
                                const Expanded(flex: 3, child: SizedBox()),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
