import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/chopdi_service.dart';

class ChopdiDeleteResult {
  final Chopdi? nextChopdi;
  final bool deleted;

  const ChopdiDeleteResult({
    this.nextChopdi,
    required this.deleted,
  });
}

class EditChopdiScreen extends StatefulWidget {
  const EditChopdiScreen({
    super.key,
    this.initialName,
    this.initialDescription,
    this.onSave,
    this.onDelete,
  });

  /// Optional values.
  ///
  /// If they are not supplied, the screen loads the currently active
  /// Chopdi directly from Isar.
  final String? initialName;
  final String? initialDescription;

  final Future<void> Function(
      String name,
      String description,
      )? onSave;

  final Future<void> Function()? onDelete;

  @override
  State<EditChopdiScreen> createState() =>
      _EditChopdiScreenState();
}

class _EditChopdiScreenState extends State<EditChopdiScreen> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor =
  Color(0xFFFFEEDB);

  static const Color cardColor =
  Color(0xFFFFFBF6);

  static const Color darkBlue =
  Color(0xFF223A5E);

  static const Color textColor =
  Color(0xFF223A5E);

  static const Color secondaryText =
  Color(0xFF69778A);

  static const Color borderColor =
  Color(0xFFB8C7D9);

  static const Color fieldColor =
  Color(0xFFFFF9F2);

  static const Color orange =
  Color(0xFFFF7A3D);

  static const Color infoBackground =
  Color(0xFFFFEEDB);

  static const Color deleteBackground =
  Color(0xFFFFEDE2);

  static const Color deleteBorder =
  Color(0xFFE96E55);

  static const Color deleteRed =
  Color(0xFFD94D3D);

  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  late final TextEditingController _nameController;

  late final TextEditingController
  _descriptionController;

  final FocusNode _nameFocusNode =
  FocusNode();

  final FocusNode _descriptionFocusNode =
  FocusNode();

  // ===========================================================================
  // STATE
  // ===========================================================================

  Chopdi? _currentChopdi;

  bool _isLoading = true;

  bool _isSaving = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController();

    _descriptionController =
        TextEditingController();

    _descriptionController.addListener(
      _descriptionChanged,
    );

    _loadChopdi();
  }

  // ===========================================================================
  // DEFAULT DESCRIPTION
  // ===========================================================================

  String _defaultDescription(
      AppLocalizations l10n,
      ) {
    return l10n.myPersonalLendingLedger;
  }

  // ===========================================================================
  // LOAD CHOPDI
  // ===========================================================================

  Future<void> _loadChopdi() async {
    try {
      final chopdi =
      await ChopdiService.getCurrentChopdi();

      if (!mounted) return;

      final l10n =
      AppLocalizations.of(context);

      _currentChopdi = chopdi;

      _nameController.text =
          widget.initialName ??
              chopdi.name;

      final description =
          widget.initialDescription ??
              chopdi.description;

      _descriptionController.text =
      description.trim().isEmpty
          ? _defaultDescription(l10n)
          : description;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        '[EditChopdiScreen] Failed to load Chopdi: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final l10n =
      AppLocalizations.of(context);

      _showError(
        l10n.unableToLoadChopdiDetails,
      );
    }
  }

  // ===========================================================================
  // DESCRIPTION LISTENER
  // ===========================================================================

  void _descriptionChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _nameController.dispose();

    _descriptionController.dispose();

    _nameFocusNode.dispose();

    _descriptionFocusNode.dispose();

    super.dispose();
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    final l10n =
    AppLocalizations.of(context);

    final name =
    _nameController.text.trim();

    String description =
    _descriptionController.text.trim();

    // ============================================================
    // VALIDATION
    // ============================================================

    if (name.isEmpty) {
      await _showError(
        l10n.pleaseEnterChopdiName,
      );
      return;
    }

    if (name.length > 50) {
      await _showError(
        l10n.chopdiNameCannotExceed50,
      );
      return;
    }

    // ============================================================
    // DEFAULT DESCRIPTION
    // ============================================================

    if (description.isEmpty) {
      description =
          _defaultDescription(l10n);
    }

    if (description.length > 100) {
      await _showError(
        l10n.descriptionCannotExceed100,
      );
      return;
    }

    // ============================================================
    // CHECK CHOPDI
    // ============================================================

    if (_currentChopdi == null) {
      await _showError(
        l10n.chopdiCouldNotBeFound,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ==========================================================
      // UPDATE LOCAL CHOPDI
      // ==========================================================

      _currentChopdi!
        ..name = name
        ..description = description;

      // ==========================================================
      // SAVE TO ISAR
      // ==========================================================

      await ChopdiService.updatedChopdi(
        _currentChopdi!,
      );

      // ==========================================================
      // OPTIONAL CALLBACK
      // ==========================================================

      if (widget.onSave != null) {
        await widget.onSave!(
          name,
          description,
        );
      }

      if (!mounted) return;

      // ==========================================================
      // SUCCESS POPUP
      // ==========================================================

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(16),
            ),
            title: Text(
              l10n.success,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
                color: textColor,
              ),
            ),
            content: Text(
              l10n.chopdiUpdatedSuccessfully,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight:
                FontWeight.w500,
                color: secondaryText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: Text(
                  l10n.ok,
                  style:
                  GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // ==========================================================
      // RETURN UPDATED CHOPDI
      // ==========================================================

      Navigator.of(context).pop(
        _currentChopdi,
      );
    } catch (e) {
      debugPrint(
        '[EditChopdiScreen] Save failed: $e',
      );

      if (!mounted) return;

      await _showError(
        l10n.unableToSaveChanges,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  Future<void> _showDeleteChopdiBottomSheet() async {
    final l10n =
    AppLocalizations.of(context);

    if (_currentChopdi == null) {
      await _showError(
        l10n.chopdiCouldNotBeFound,
      );
      return;
    }

    // ============================================================
    // CONFIRM DELETE POPUP
    // ============================================================

    final bool? shouldDelete =
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
          title: Text(
            '${l10n.deleteChopdi}?',
            style: GoogleFonts.manrope(
              fontSize: 19,
              fontWeight:
              FontWeight.w700,
              color: textColor,
            ),
          ),
          content: Text(
            '${l10n.areYouSureDeleteChopdi} '
                '"${_currentChopdi!.name}"?\n\n'
                '${l10n.thisActionCannotBeUndone}',
            style: GoogleFonts.manrope(
              fontSize: 14,
              height: 1.4,
              fontWeight:
              FontWeight.w500,
              color: secondaryText,
            ),
          ),
          actionsPadding:
          const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            14,
          ),
          actions: [
            // ======================================================
            // CANCEL
            // ======================================================

            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: Text(
                l10n.cancel,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w700,
                  color: secondaryText,
                ),
              ),
            ),

            // ======================================================
            // DELETE / OK
            // ======================================================

            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(
                l10n.ok,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w700,
                  color: deleteRed,
                ),
              ),
            ),
          ],
        );
      },
    );

    // ============================================================
    // USER PRESSED CANCEL
    // ============================================================

    if (shouldDelete != true) {
      return;
    }

    // ============================================================
    // DELETE
    // ============================================================

    try {
      final deletedId =
          _currentChopdi!.id;

      final nextChopdi =
      await ChopdiService.deleteChopdi(
        deletedId,
      );

      if (!mounted) return;

      // ============================================================
      // GET REMAINING CHOPDIS
      // ============================================================

      final remainingChopdis =
      await ChopdiService.getAllChopdis();

      // ============================================================
      // ONLY ONE CHOPDI REMAINS
      // ============================================================

      if (remainingChopdis.length == 1) {
        await ChopdiService.setActiveChopdi(
          remainingChopdis.first,
        );

        if (!mounted) return;

        Navigator.of(context).pop(
          ChopdiDeleteResult(
            nextChopdi:
            remainingChopdis.first,
            deleted: true,
          ),
        );

        return;
      }

      // ============================================================
      // MULTIPLE CHOPDIS REMAIN
      // ============================================================

      Navigator.of(context).pop(
        ChopdiDeleteResult(
          nextChopdi: nextChopdi,
          deleted: true,
        ),
      );
    } catch (e) {
      debugPrint(
        '[EditChopdiScreen] Delete failed: $e',
      );

      if (!mounted) return;

      await _showError(
        l10n.unableToDeleteChopdi,
      );
    }
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  Future<void> _showError(
      String message,
      ) async {
    if (!mounted) return;

    final l10n =
    AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          const Color(0xFFFFFBF6),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
          title: Text(
            l10n.somethingWentWrong,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w700,
              color: Color(0xFF223A5E),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF69778A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: Text(
                l10n.ok,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w700,
                  color: Color(0xFF223A5E),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final keyboardVisible =
        MediaQuery.of(context)
            .viewInsets
            .bottom >
            0;

    return Scaffold(
      backgroundColor:
      backgroundColor,
      resizeToAvoidBottomInset:
      true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus();
          },
          child: _isLoading
              ? const Center(
            child:
            CircularProgressIndicator(),
          )
              : LayoutBuilder(
            builder:
                (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                physics:
                const BouncingScrollPhysics(),
                padding:
                EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 14,
                  bottom:
                  keyboardVisible
                      ? 30
                      : 14,
                ),
                child:
                ConstrainedBox(
                  constraints:
                  BoxConstraints(
                    minHeight:
                    constraints
                        .maxHeight -
                        28,
                  ),
                  child:
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      // =================================================
                      // HEADER
                      // =================================================

                      _buildHeader(),

                      const SizedBox(
                        height: 12,
                      ),

                      // =================================================
                      // BOOK
                      // =================================================

                      _buildBookSection(),

                      const SizedBox(
                        height: 12,
                      ),

                      // =================================================
                      // EDIT CARD
                      // =================================================

                      _buildEditCard(),

                      const SizedBox(
                        height: 60,
                      ),

                      // =================================================
                      // DELETE
                      // =================================================

                      _buildDeleteButton(),

                      const SizedBox(
                        height: 14,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    final l10n =
    AppLocalizations.of(context);

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // Back arrow
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const SizedBox(
            width: 24,
            height: 32,
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                color: textColor,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Edit Chopdi title + subtitle
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              l10n.editChopdi,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight:
                FontWeight.w700,
                color: textColor,
              ),
            ),

            const SizedBox(height: 1),

            Text(
              l10n.updateYourChopdiDetails,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight:
                FontWeight.w600,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // BOOK
  // ===========================================================================

  Widget _buildBookSection() {
    return Center(
      child: SizedBox(
        height: 170,
        width: 255,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/edit_chopdi_book.png',
              width: 255,
              height: 170,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // EDIT CARD
  // ===========================================================================

  Widget _buildEditCard() {
    final l10n =
    AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.fromLTRB(
        11,
        12,
        11,
        12,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ===============================================================
          // NAME
          // ===============================================================

          Text(
            l10n.chopdiName,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 5),

          _buildNameField(),

          const SizedBox(height: 12),

          // ===============================================================
          // DESCRIPTION
          // ===============================================================

          Text(
            l10n.descriptionOptional,
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 5),

          _buildDescriptionField(),

          const SizedBox(height: 14),

          // ===============================================================
          // INFO
          // ===============================================================

          _buildInfoBox(),

          const SizedBox(height: 20),

          // ===============================================================
          // SAVE
          // ===============================================================

          _buildSaveButton(),
        ],
      ),
    );
  }

  // ===========================================================================
  // NAME FIELD
  // ===========================================================================

  Widget _buildNameField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius:
        BorderRadius.circular(6),
        border: Border.all(
          color:
          const Color.fromRGBO(
            170,
            185,
            207,
            1,
          ),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 7),

          Image.asset(
            'assets/edit_chopdi_book.png',
          ),

          const SizedBox(width: 6),

          Expanded(
            child: TextField(
              controller:
              _nameController,
              focusNode:
              _nameFocusNode,
              maxLength: 50,
              textInputAction:
              TextInputAction.next,
              onSubmitted: (_) {
                _descriptionFocusNode
                    .requestFocus();
              },
              style:
              GoogleFonts.manrope(
                fontSize: 14,
                fontWeight:
                FontWeight.w700,
                color: darkBlue,
              ),
              decoration:
              const InputDecoration(
                border:
                InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding:
                EdgeInsets.only(
                  bottom: 1,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  // ===========================================================================
  // DESCRIPTION FIELD
  // ===========================================================================

  Widget _buildDescriptionField() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color:
          const Color.fromRGBO(
            170,
            185,
            207,
            1,
          ),
          width: 1.0,
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller:
            _descriptionController,
            focusNode:
            _descriptionFocusNode,
            maxLength: 100,
            maxLines: 3,
            keyboardType:
            TextInputType.multiline,
            style:
            GoogleFonts.manrope(
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
              color: textColor,
            ),
            decoration:
            const InputDecoration(
              border:
              InputBorder.none,
              counterText: '',
              contentPadding:
              EdgeInsets.fromLTRB(
                7,
                6,
                7,
                18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INFO BOX
  // ===========================================================================

  Widget _buildInfoBox() {
    final l10n =
    AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      height: 51,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
        const Color.fromRGBO(
          253,
          237,
          217,
          1,
        ),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color:
          const Color.fromRGBO(
            177,
            95,
            39,
            0.23,
          ),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
            const EdgeInsets.only(
              top: 1,
            ),
            child: Image.asset(
              'assets/info-outline.png',
              height: 20,
              width: 20,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  l10n
                      .theseDetailsHelpManageChopdi,
                  style:
                  GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  l10n.youCanChangeAnytime,
                  style:
                  GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w500,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SAVE BUTTON
  // ===========================================================================

  Widget _buildSaveButton() {
    final l10n =
    AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
        _isSaving
            ? null
            : _saveChanges,
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          textColor,
          disabledBackgroundColor:
          textColor.withValues(
            alpha: 0.6,
          ),
          foregroundColor:
          Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(6),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
          width: 17,
          height: 17,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          l10n.saveChanges,
          style:
          GoogleFonts.manrope(
            fontSize: 20,
            fontWeight:
            FontWeight.w700,
            color:
            const Color.fromRGBO(
              253,
              237,
              217,
              1,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DELETE BUTTON
  // ===========================================================================

  Widget _buildDeleteButton() {
    final l10n =
    AppLocalizations.of(context);

    return GestureDetector(
      onTap:
      _showDeleteChopdiBottomSheet,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: deleteBackground,
          borderRadius:
          BorderRadius.circular(7),
          border: Border.all(
            color:
            const Color.fromRGBO(
              199,
              76,
              76,
              1,
            ),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),

            Container(
              width: 40,
              height: 40,
              decoration:
              const BoxDecoration(
                color: Color(0xFFF8D0C2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/delete_outline_rounded_transactions.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(width: 9),

            Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deleteChopdi,
                  style:
                  GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color.fromRGBO(
                      199,
                      76,
                      76,
                      1,
                    ),
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  l10n.thisActionCannotBeUndone,
                  style:
                  GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color.fromRGBO(
                      199,
                      76,
                      76,
                      1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}