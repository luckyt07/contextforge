import 'package:ai_assistant_app/bloc/project/project_bloc.dart';
import 'package:ai_assistant_app/theme/editorial_theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-level, non-blocking project creation feedback.
class ProjectCreationStatusBar extends StatelessWidget {
  const ProjectCreationStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      buildWhen: (previous, current) =>
          previous.isCreating != current.isCreating ||
          previous.creationMessage != current.creationMessage ||
          previous.creationProgress != current.creationProgress ||
          previous.creationCompleted != current.creationCompleted,
      builder: (context, state) {
        if (state.creationMessage == null) return const SizedBox.shrink();
        final colors = context.editorialColors;
        final isComplete = state.creationCompleted;
        final isFailed = state.creationStep == 'failed';
        final color = isFailed
            ? colors.textSecondary
            : isComplete
            ? colors.brandPrimary
            : colors.brandPrimary;

        return SafeArea(
          bottom: false,
          child: Material(
            color: colors.card,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: state.isCreating
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          )
                        : Icon(
                            isComplete
                                ? Icons.check_circle
                                : Icons.error_outline,
                            size: 18,
                            color: color,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.creationMessage!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (state.isCreating) ...[
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: state.creationProgress / 100,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!state.isCreating)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => context.read<ProjectBloc>().add(
                        DismissProjectCreationStatusEvent(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
