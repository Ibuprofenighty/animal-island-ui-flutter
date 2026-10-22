import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/animal_island_upload_platform.dart';

import '../../shared/story.dart';

class UploadStory extends StatefulWidget {
  const UploadStory({super.key, this.pickFiles = islandPickFiles});
  final IslandUploadPicker pickFiles;
  @override
  State<UploadStory> createState() => _UploadStoryState();
}

class _UploadStoryState extends State<UploadStory> {
  final notifications = IslandNotificationsController();
  late final simulate = islandSimulatedUpload();
  late final slow = islandSimulatedUpload(
    interval: const Duration(milliseconds: 300),
    step: 8,
  );
  late final http = islandHttpUpload(
    endpoint: (_) => Uri.parse('https://httpbin.org/post'),
    data: (_) => {'source': 'demo'},
  );
  List<IslandUploadFile> cards = [], pictures = [];
  int pickedCount = 0, existingCount = 0;
  @override
  void dispose() {
    notifications.dispose();
    super.dispose();
  }

  void notice(
    String text, [
    IslandNotificationType type = IslandNotificationType.info,
  ]) {
    if (mounted)
      notifications.show(IslandNotification(message: Text(text), type: type));
  }

  Widget block(Widget child) => SizedBox(width: 720, child: child);
  Widget tip(String value) => Text(value);
  Future<IslandUploadSource?> guard(
    IslandUploadSource file,
    List<IslandUploadSource> batch,
  ) async {
    if (!RegExp(
      r'\.(png|jpe?g|gif|webp|svg|bmp|ico)$',
      caseSensitive: false,
    ).hasMatch(file.name)) {
      notice('${file.name} 不是支持的图片类型,已拦截', IslandNotificationType.warning);
      return null;
    }
    if (existingCount >= 3) {
      notice('${file.name} 已达数量上限(3 个),已拦截', IslandNotificationType.warning);
      return null;
    }
    if (file.size > 1024 * 1024) {
      notice('${file.name} 超过 1 MB,已拦截', IslandNotificationType.warning);
      return null;
    }
    return file;
  }

  void preview(IslandUploadFile file) {
    Navigator.of(context, rootNavigator: true).push(
      IslandDialogRoute<void>(
        context: context,
        builder: (context) => IslandModal(
          variant: IslandModalVariant.normal,
          width: 560,
          title: Text(file.name),
          onClose: () => Navigator.of(context).pop(),
          child: file.thumbnail == null && file.thumbnailBuilder == null
              ? const Center(child: Text('该文件暂无可预览的图片'))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * .68,
                    ),
                    child: file.thumbnailBuilder != null
                        ? Builder(
                            builder: (context) =>
                                file.thumbnailBuilder!(context, BoxFit.contain),
                          )
                        : Image(image: file.thumbnail!, fit: BoxFit.contain),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => IslandNotifications(
    controller: notifications,
    child: StoryPanel(
      title: 'Upload',
      tags: ["上传", "拖拽", "模拟进度"],
      children: [
        const StoryLabel('基础用法 — 点击上传(默认模拟上传进度)'),
        block(
          IslandUpload.uncontrolled(
            pickFiles: widget.pickFiles,
            request: simulate,
            tip: tip('未接入 customRequest 时,组件会用定时器模拟上传进度,方便联调 UI'),
          ),
        ),
        const StoryLabel('defaultFileList — 预置已完成文件 + onChange 收集'),
        block(
          IslandUpload.uncontrolled(
            pickFiles: widget.pickFiles,
            request: simulate,
            multiple: true,
            accept: 'image/*,.pdf',
            initialFiles: const [
              IslandUploadFile(
                id: 'island-1',
                name: '海岛全景.png',
                size: 2400000,
                mimeType: 'image/png',
                status: IslandUploadStatus.done,
                percent: 100,
              ),
              IslandUploadFile(
                id: 'island-2',
                name: '露营清单.pdf',
                size: 512000,
                mimeType: 'application/pdf',
                status: IslandUploadStatus.done,
                percent: 100,
              ),
            ],
            onChanged: (info) {
              if (pickedCount != info.files.length) {
                pickedCount = info.files.length;
                notice('列表变化:当前 ${info.files.length} 个文件');
              }
            },
            tip: tip('支持多选,accept 限定图片与 PDF'),
          ),
        ),
        const StoryLabel('drag — 拖拽上传区域'),
        block(
          IslandUpload.uncontrolled(
            pickFiles: widget.pickFiles,
            request: simulate,
            dropBuilder: islandFileDrop,
            drag: true,
            multiple: true,
            tip: tip('点击或把文件拖进虚线框均可'),
          ),
        ),
        const StoryLabel('maxCount + beforeUpload — 数量上限与类型拦截'),
        block(
          IslandUpload.uncontrolled(
            pickFiles: widget.pickFiles,
            request: simulate,
            dropBuilder: islandFileDrop,
            drag: true,
            multiple: true,
            maxCount: 3,
            beforeUpload: guard,
            onChanged: (info) => existingCount = info.files.length,
            tip: tip('最多 3 个图片文件;类型/数量上限/大小拦截均以 warning 提示(可拖一张非图片试试)'),
          ),
        ),
        const StoryLabel('listType="picture-card" — 图片卡片 + 预览'),
        block(
          IslandUpload(
            pickFiles: widget.pickFiles,
            request: simulate,
            listType: IslandUploadListType.pictureCard,
            accept: 'image/*',
            multiple: true,
            maxCount: 4,
            files: cards,
            onChanged: (info) => setState(() => cards = info.files),
            onExceed: (files, _) => notice(
              '${files.length} 个文件超出上限(最多 4 张),已忽略',
              IslandNotificationType.warning,
            ),
            tip: tip('最多 4 张;满员后新选择的文件会被丢弃,用 onExceed 给出提示'),
          ),
        ),
        const StoryLabel('customRequest — 接入真实上传(示例为慢速模拟)'),
        block(
          IslandUpload.uncontrolled(
            pickFiles: widget.pickFiles,
            request: (transfer) async {
              final response = await slow(transfer);
              if (!transfer.cancellation.isCancelled)
                notice(
                  '${transfer.file.name} 上传完成',
                  IslandNotificationType.success,
                );
              return response;
            },
            tip: tip('真实项目中也可直接把接口地址交给 action,由组件内置 XHR 处理进度'),
          ),
        ),
        const StoryLabel('action — 内置 XHR 真实上传(带进度与取消)'),
        block(
          IslandUpload.uncontrolled(
            pickFiles: widget.pickFiles,
            request: http,
            multiple: true,
            tip: tip('设置 action 后组件用原生 XMLHttpRequest 上传并自动上报进度;删除文件会中止请求'),
          ),
        ),
        const StoryLabel('children — 自定义触发区内容'),
        block(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IslandUpload.uncontrolled(
                pickFiles: widget.pickFiles,
                request: simulate,
                multiple: true,
                tip: tip('用 children 完全自定义触发按钮'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f8f0),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    '点击上传头像',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff794f27),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              IslandUpload.uncontrolled(
                pickFiles: widget.pickFiles,
                request: simulate,
                dropBuilder: islandFileDrop,
                drag: true,
                multiple: true,
                tip: tip('也适用于拖拽区域'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IslandIcon(IslandGlyph.upload, size: 22),
                          SizedBox(width: 6),
                          Text(
                            '拖拽上传',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff794f27),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('把文件拖进这片空地'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const StoryLabel('showUploadList=false — 纯上传按钮(隐藏列表)'),
        block(
          IslandUpload.uncontrolled(
            pickFiles: widget.pickFiles,
            request: simulate,
            showList: false,
            multiple: true,
            accept: 'image/*,.pdf',
            tip: tip('列表由外部自行渲染时,关闭内置列表只保留触发钮'),
          ),
        ),
        const StoryLabel('onPreview — 点击缩略图直接预览大图'),
        block(
          IslandUpload(
            pickFiles: widget.pickFiles,
            request: simulate,
            listType: IslandUploadListType.pictureCard,
            accept: 'image/*',
            multiple: true,
            maxCount: 4,
            files: cards,
            onChanged: (info) => setState(() => cards = info.files),
            onPreview: preview,
            tip: tip('鼠标悬停图片出现眼睛图标;点击直接打开预览大图'),
          ),
        ),
        const StoryLabel('listType="picture" — 行内缩略图'),
        block(
          IslandUpload(
            pickFiles: widget.pickFiles,
            request: simulate,
            listType: IslandUploadListType.picture,
            accept: 'image/*',
            multiple: true,
            maxCount: 4,
            files: pictures,
            onChanged: (info) => setState(() => pictures = info.files),
            tip: tip('text 形态但每条带缩略图,图片文件自动生成预览'),
          ),
        ),
        const StoryCode(
          """import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/animal_island_upload_platform.dart';

// Gallery explicitly selects simulation; production selects an HTTP adapter.
IslandUpload.uncontrolled(
  pickFiles: islandPickFiles,
  request: islandHttpUpload(endpoint: (_) => Uri.parse('https://example.com/upload')),
  dropBuilder: islandFileDrop,
  drag: true, multiple: true, accept: 'image/*,.pdf',
  onChanged: (change) => print(change.files.length),
);""",
        ),
        const StoryApi(
          rows: [
            ('accept', '选择和拖放共同执行类型过滤', 'String', "''"),
            (
              'multiple / maxCount',
              '多选 / 数量上限；1 时替换',
              'bool / int?',
              'false / null',
            ),
            ('disabled', '禁用选择、删除和预览', 'bool', 'false'),
            (
              'files / initialFiles',
              '父级受控列表 / 非受控初始值',
              'List<IslandUploadFile>',
              '[]',
            ),
            ('listType', '文本、行内缩略图、图片卡片', 'IslandUploadListType', 'text'),
            (
              'showList / showPreview / showRemove',
              '列表、预览和删除按钮',
              'bool',
              'true',
            ),
            (
              'onPreview',
              '由宿主替换默认预览',
              'ValueChanged<IslandUploadFile>?',
              'null',
            ),
            (
              'drag / dropBuilder',
              '拖拽区域及平台文件入口',
              'bool / IslandUploadDropBuilder?',
              'false / null',
            ),
            ('tip / child', '提示及非交互触发内容', 'Widget?', 'null'),
            (
              'beforeUpload',
              '异步预检；null 跳过，可转换源',
              'IslandUploadBefore?',
              'null',
            ),
            ('pickFiles', '文件选择适配器', 'IslandUploadPicker', 'required'),
            ('request', '每个传输的进度、结果与取消', 'IslandUploadRequest', 'required'),
            (
              'islandHttpUpload',
              '独立 HTTP multipart 适配器',
              'endpoint, method, headers, data, fieldName, withCredentials',
              'POST / file / false',
            ),
            (
              'onChanged',
              '不可变列表快照；父级可拒绝',
              'ValueChanged<IslandUploadChange>?',
              'null',
            ),
            ('onExceed', '超出数量上限的文件', 'callback?', 'null'),
            (
              'onRemove',
              '异步删除前检查；false 拒绝',
              'FutureOr<bool> Function(file)?',
              'null',
            ),
            ('onSelectionError', '当前选择／预检／删除错误；过期操作忽略', 'callback?', 'null'),
            ('label', '辅助技术名称', 'String', '上传文件'),
          ],
        ),
      ],
    ),
  );
}
