import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_back_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/widgets/neo_loader.dart';
import '../../../../core/services/service_locator.dart';
import '../../bloc/signature_bloc.dart';
import '../widgets/signature_mode_selection.dart';
import '../widgets/signature_draw_view.dart';
import '../widgets/signature_scan_view.dart';
import '../widgets/signature_success_view.dart';

class SignatureView extends StatelessWidget {
  const SignatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SignatureBloc(signatureService: getIt(), historyService: getIt()),
      child: const _SignatureViewContent(),
    );
  }
}

class _SignatureViewContent extends StatefulWidget {
  const _SignatureViewContent();

  @override
  State<_SignatureViewContent> createState() => _SignatureViewContentState();
}

class _SignatureViewContentState extends State<_SignatureViewContent> {
  String?
  _selectedMode; // null = Selection screen, 'draw' = Draw Canvas, 'scan' = Scan Paper
  final GlobalKey _canvasKey = GlobalKey();

  void _handleBackPress(BuildContext context, SignatureState state) {
    final bloc = context.read<SignatureBloc>();
    if (state is SignatureSuccessState) {
      bloc.add(ResetSignatureEvent());
      setState(() {
        _selectedMode = null;
      });
    } else if (_selectedMode != null) {
      setState(() {
        _selectedMode = null;
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SignatureBloc, SignatureState>(
      listener: (context, state) {
        if (state is SignatureErrorState) {
          NeoToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        String appBarTitle = 'Digital Signature Creator';
        if (state is SignatureSuccessState) {
          appBarTitle = 'Exported Signature';
        } else if (_selectedMode == 'draw') {
          appBarTitle = 'Draw Digital Signature';
        } else if (_selectedMode == 'scan') {
          appBarTitle = 'Scan Paper Signature';
        }

        final bool canDirectPop =
            _selectedMode == null && state is! SignatureSuccessState;

        return PopScope(
          canPop: canDirectPop,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBackPress(context, state);
          },
          child: Scaffold(
            appBar: AppBar(
              leading: NeoBackButton(
                onPressed: () => _handleBackPress(context, state),
              ),
              title: Text(
                appBarTitle,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            body: SafeArea(child: _buildBody(context, state, isDark)),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SignatureState state, bool isDark) {
    if (state is SignatureProcessingState) {
      return _buildProcessingState(isDark);
    } else if (state is SignatureSuccessState) {
      return SignatureSuccessView(
        state: state,
        isDark: isDark,
        onCreateNew: () {
          context.read<SignatureBloc>().add(ResetSignatureEvent());
          setState(() {
            _selectedMode = null;
          });
        },
      );
    } else if (state is SignatureInitialState) {
      if (_selectedMode == 'draw') {
        return SignatureDrawView(
          state: state,
          isDark: isDark,
          canvasKey: _canvasKey,
        );
      } else if (_selectedMode == 'scan') {
        return SignatureScanView(
          isDark: isDark,
          onExtractSignature: ({
            required photoFile,
            required cropXRatio,
            required cropYRatio,
            required cropWidthRatio,
            required cropHeightRatio,
            required rotationAngle,
          }) {
            context.read<SignatureBloc>().add(ScanPaperSignatureEvent(
                  photoFile: photoFile,
                  cropXRatio: cropXRatio,
                  cropYRatio: cropYRatio,
                  cropWidthRatio: cropWidthRatio,
                  cropHeightRatio: cropHeightRatio,
                  rotationAngle: rotationAngle,
                ));
          },
        );
      } else {
        return SignatureModeSelection(
          isDark: isDark,
          onSelectDraw: () => setState(() => _selectedMode = 'draw'),
          onSelectScan: () => setState(() => _selectedMode = 'scan'),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildProcessingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: NeoStyles.neoDecoration(
              backgroundColor: isDark
                  ? NeoColors.darkSurface
                  : NeoColors.softYellow,
              borderColor: isDark
                  ? NeoColors.borderDark
                  : NeoColors.borderLight,
              radius: 20,
              shadow: 4,
            ),
            child: const Center(
              child: NeoLoader.large(
                size: 46,
                color: NeoColors.yellow,
                secondaryColor: NeoColors.pink,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Exporting Digital Signature...',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
