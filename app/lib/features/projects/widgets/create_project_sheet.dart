import 'package:ai_assistant_app/bloc/project/project_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common_widgets/editorial_button.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';
import '../models/project_item.dart';

class CreateProjectSheet extends StatefulWidget {
  final ValueChanged<ProjectItem>? onProjectCreated;

  const CreateProjectSheet({this.onProjectCreated, super.key});

  static Future<ProjectItem?> show(BuildContext context) {
    return showModalBottomSheet<ProjectItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateProjectSheet(),
    );
  }

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final _titleController = TextEditingController(
    text: 'Legal Contract Analyzer & Risk Audit',
  );
  final _instructionsController = TextEditingController(
    text:
        'You are an expert contract specialist with an analytical tone. Summarize clauses, flag indemnification risks, and cite exact page numbers from provided attachments.',
  );
  String? _attachedFileName;
  String? _attachedFilePath;
  String _attachedFileSize = '';

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    final file = result?.files.single;
    if (file == null || file.path == null || !mounted) return;
    setState(() {
      _attachedFileName = file.name;
      _attachedFilePath = file.path;
      _attachedFileSize =
          '${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB';
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty || _attachedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a project name and select a PDF.')),
      );
      return;
    }
    if (context.read<ProjectBloc>().state.isCreating) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A project is already being created.')),
      );
      return;
    }
    context.read<ProjectBloc>().add(
      CreateProjectEvent(
        projectName: title,
        projectInstruction: _instructionsController.text.trim(),
        filePath: _attachedFilePath!,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Project',
                    style: typo.headline.copyWith(fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Define custom context rules, attach knowledge documents, and orchestrate deep thought threads.',
                    style: typo.bodyMd.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),

                  // Project Name Field
                  Text(
                    'Project Name',
                    style: typo.labelMd.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    style: typo.bodyMd,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Distributed Consensus Research',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),

                  // Custom Instructions Field
                  Text(
                    'Instructions for AI',
                    style: typo.labelMd.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 3,
                    style: typo.bodyMd,
                    decoration: const InputDecoration(
                      hintText:
                          'What should the AI know and how should it respond?',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),

                  // Knowledge Base Attach Box
                  Text(
                    'Knowledge Base Files',
                    style: typo.labelMd.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  if (_attachedFileName == null) ...[
                    InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.spaceSm),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          border: Border.all(color: colors.borderDefault),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.upload_file,
                              color: colors.brandPrimary,
                              size: 22,
                            ),
                            const SizedBox(width: AppSpacing.spaceSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attach document (PDF, TXT, MD)',
                                    style: typo.bodyMd.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text('Up to 30 MB', style: typo.caption),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.containerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Browse',
                                style: typo.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceSm,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubdued,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        border: Border.all(color: colors.borderDefault),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: colors.brandPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.spaceXs),
                          Expanded(
                            child: Text(
                              '$_attachedFileName · $_attachedFileSize',
                              style: typo.bodyMd.copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() {
                              _attachedFileName = null;
                              _attachedFilePath = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.spaceLg),

            // Modal footer action buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.borderDefault)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: EditorialButton(
                      label: 'Cancel',
                      variant: EditorialButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: EditorialButton(
                      label: 'Create Project',
                      variant: EditorialButtonVariant.primary,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
