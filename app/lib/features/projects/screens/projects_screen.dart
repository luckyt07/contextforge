import 'package:ai_assistant_app/bloc/project/project_bloc.dart';
import 'package:ai_assistant_app/core/models/response/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/editorial_theme_scope.dart';
import '../widgets/create_project_sheet.dart';
import '../widgets/project_card_widget.dart';
import '../../project_detail/screens/project_detail_screen.dart';
import '../../settings/screens/settings_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  static const _pageSize = 20;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _visibleProjects = _pageSize;

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(GetProjectEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateSheet() async {
    if (context.read<ProjectBloc>().state.isCreating) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A project is already being created.')),
      );
      return;
    }
    await CreateProjectSheet.show(context);
  }

  void _openProjectDetail(ProjectModel project) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
    );
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Future<void> _editProject(ProjectModel project) async {
    final nameController = TextEditingController(text: project.projectName);
    final instructionController = TextEditingController(
      text: project.instruction,
    );
    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Project name'),
            ),
            TextField(
              controller: instructionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Instructions'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              context.read<ProjectBloc>().add(
                UpdateProjectEvent(
                  projectId: project.id,
                  projectName: name,
                  projectInstruction: instructionController.text.trim(),
                ),
              );
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();
    instructionController.dispose();
    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project update requested.')),
      );
    }
  }

  Future<void> _deleteProject(ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          '“${project.projectName}” and its conversations will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<ProjectBloc>().add(DeleteProjectEvent(project.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorialColors;
    final typo = context.editorialTypography;

    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final query = _searchQuery.toLowerCase();
        final projects = state.projects.where((project) {
          return query.isEmpty ||
              project.projectName.toLowerCase().contains(query) ||
              project.instruction.toLowerCase().contains(query) ||
              project.filename.toLowerCase().contains(query);
        }).toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Projects',
              style: typo.headline.copyWith(fontSize: 22),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                onPressed: _openSettings,
              ),
              const SizedBox(width: AppSpacing.spaceXs),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: colors.borderSubtle),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search Bar Input
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.spaceMd),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceSubdued,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: typo.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'Search projects or documents...',
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,
                          color: colors.textTertiary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : Icon(
                                Icons.mic_none,
                                size: 20,
                                color: colors.textTertiary,
                              ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                // Project List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : projects.isEmpty
                      ? Center(
                          child: Text(
                            'No projects found',
                            style: typo.bodyMd.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<ProjectBloc>().add(GetProjectEvent());
                            setState(() => _visibleProjects = _pageSize);
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.spaceMd,
                              right: AppSpacing.spaceMd,
                              bottom: 96,
                            ),
                            itemCount: _itemCount(projects.length),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.spaceSm),
                            itemBuilder: (context, index) {
                              if (index ==
                                  projects.length.clamp(0, _visibleProjects)) {
                                return Center(
                                  child: TextButton(
                                    onPressed: () => setState(() {
                                      _visibleProjects += _pageSize;
                                    }),
                                    child: const Text('Load more projects'),
                                  ),
                                );
                              }
                              final project = projects[index];
                              return ProjectCardWidget(
                                project: project,
                                onTap: () => _openProjectDetail(project),
                                onEdit: () => _editProject(project),
                                onDelete: () => _deleteProject(project),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCreateSheet,
            backgroundColor: colors.brandPrimary,
            foregroundColor: colors.brandOnPrimary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: const Text(
              'New Project',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  int _itemCount(int total) {
    final visible = total < _visibleProjects ? total : _visibleProjects;
    return visible < total ? visible + 1 : visible;
  }
}
