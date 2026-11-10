import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/delete_my_data_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/delete_my_data_state.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/widgets/delete_my_data_dialog.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-bar action that permanently deletes this device's data.
///
/// Confirmation happens in a dialog; the API call is owned by
/// [DeleteMyDataCubit] so the bar can show a spinner while it runs.
class SettingsDeleteDataButton extends StatelessWidget {
  const SettingsDeleteDataButton({super.key});

  Future<void> _confirmAndDelete(BuildContext context) async {
    final cubit = context.read<DeleteMyDataCubit>();
    if (cubit.state.isDeleting) return;

    final confirmed = await showDeleteMyDataDialog(context);
    if (!context.mounted || !confirmed) return;

    await cubit.deleteMyData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<DeleteMyDataCubit, DeleteMyDataState>(
      buildWhen: (previous, current) =>
          previous.isDeleting != current.isDeleting,
      builder: (context, state) {
        return IconButton(
          onPressed: state.isDeleting ? null : () => _confirmAndDelete(context),
          tooltip: l10n.deleteMyDataTitle,
          icon: state.isDeleting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.error,
                  ),
                )
              : Icon(Icons.delete_outline_rounded, color: colors.error),
        );
      },
    );
  }
}
