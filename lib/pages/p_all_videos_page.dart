import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mom_project/gets/g_context_controller.dart';
import 'package:mom_project/gets/g_synology_controller.dart';
import 'package:mom_project/service/api_data.dart';
import 'package:mom_project/theme/t_app_theme.dart';
import 'package:mom_project/widgets/w_file_update_button.dart';
import 'package:mom_project/widgets/w_hover_container.dart';
import 'package:mom_project/widgets/w_hover_text.dart';
import 'package:mom_project/widgets/w_line.dart';
import 'package:mom_project/widgets/w_video_thumbnail.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final controller1 = Get.find<SynologyFileManagerController>();
    final controller2 = Get.find<ResponsiveController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller1.getItems().isEmpty) {
        controller1.searchFiles(fileType: "video");
      }
    });

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
                  const Text("ALL Videos", style: TextStyle(fontSize: 21)),
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
                      children: controller1.getCurrentPath().replaceAll(rootFolder, "").split("/").map((e) {
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
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   height: 42,
                //   width: 184,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(8),
                //     color: customTheme.containerColor,
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       HugeIcon(icon: HugeIcons.strokeRoundedFolder01, color: customTheme.textColor.withOpacity(0.5)),
                //       const SizedBox(width: 8),
                //       const Text("Show All"),
                //       const Expanded(child: SizedBox()),
                //       Icon(Icons.keyboard_arrow_down_rounded, color: customTheme.textColor.withOpacity(0.5)),
                //     ],
                //   ),
                // ),
                FileUploadButton(controller: controller1),
                TextButton(
                  onPressed: () async {
                    List<FileItem> videoResults = await controller1.searchFiles(fileType: "video");
                    for (var value in videoResults) {
                      debugPrint(value.path);
                    }
                  },
                  child: const Text("asdf"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              print(controller2.screenRate);
              if (controller1.getIsLoading()) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller1.getErrorMessage().isNotEmpty) {
                return Center(child: Text(controller1.getErrorMessage()));
              } else {
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: controller2.screenRate > 0.8 ? 4 : 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 4 / 4.2,
                  ),
                  itemCount: controller1.getItems().length,
                  itemBuilder: (context, index) {
                    var item = controller1.getItems()[index];
                    return InkWell(
                      onTap: item.isDirectory ? () => controller1.navigateToFolder(item.path) : null,
                      child: HoverContainer(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VideoThumbnail(videoPath: 'http://$nasUrl/files/${Uri.encodeFull(item.path)}'),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(8),
                              width: double.infinity,
                              child: Text(item.name.replaceAll(".${item.extension}", ""), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
