import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/chopdi_service.dart';
import 'package:mychopdi/widgets/delete_chopdi_bottom_sheet.dart';

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

  final VoidCallback? onDelete;

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

   static const String defaultDescription =
    'My personal lending ledger\n'
    'to track loans and interest.';

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
  // LOAD CHOPDI
  // ===========================================================================

  Future<void> _loadChopdi() async {
  try {
    final chopdi =
        await ChopdiService.getCurrentChopdi();

    if (!mounted) return;

    _currentChopdi = chopdi;

    _nameController.text =
        widget.initialName ??
        chopdi.name;

    final description =
        widget.initialDescription ??
        chopdi.description;

    _descriptionController.text =
        description.trim().isEmpty
            ? defaultDescription
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

    _showError(
      'Unable to load Chopdi details.',
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

  final name =
      _nameController.text.trim();

  String description =
      _descriptionController.text.trim();

  // ---------------------------------------------------------------
  // VALIDATION
  // ---------------------------------------------------------------

  if (name.isEmpty) {
    _showError(
      'Please enter a Chopdi name.',
    );
    return;
  }

  if (name.length > 50) {
    _showError(
      'Chopdi name cannot exceed 50 characters.',
    );
    return;
  }

  // ---------------------------------------------------------------
  // IF USER DOES NOT ENTER A DESCRIPTION,
  // USE THE DEFAULT DESCRIPTION.
  // ---------------------------------------------------------------

  if (description.isEmpty) {
    description = defaultDescription;
  }

  if (description.length > 100) {
    _showError(
      'Description cannot exceed 100 characters.',
    );
    return;
  }

  if (_currentChopdi == null) {
    _showError(
      'Chopdi could not be found.',
    );
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    // -------------------------------------------------------------
    // SAVE BOTH NAME AND DESCRIPTION
    // -------------------------------------------------------------

    if (widget.onSave != null) {
      await widget.onSave!(
        name,
        description,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Chopdi updated successfully',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop(true);
  } catch (e) {
    debugPrint(
      '[EditChopdiScreen] Save failed: $e',
    );

    if (!mounted) return;

    _showError(
      'Unable to save changes. Please try again.',
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

  void _showDeleteChopdiBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withValues(alpha: 0.78),
      builder: (context) {
        return DeleteChopdiBottomSheet(
          onDelete: () async {
            // ---------------------------------------------------------------
            // Keep your existing delete logic.
            // ---------------------------------------------------------------

            if (widget.onDelete != null) {
              widget.onDelete!();
            }

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
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

                      // =======================================================
                      // SAME SCREEN PADDING AS MYCHOPDI SCREEN
                      // =======================================================

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                Icons.arrow_back,
                color: textColor,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Edit Chopdi title + subtitle
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Chopdi',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),

            SizedBox(height: 1),

            Text(
              'Update your chopdi details',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
        // width: double.infinity,
        width: 255,
      
        child: Stack(
          alignment: Alignment.center,
      
          children: [
            Image.asset(
              'assets/chopdi_book.png',
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
            'Chopdi Name',

            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700, 
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 5),

          _buildNameField(),

          const SizedBox(height: 12),

          // ===============================================================
          // DESCRIPTION
          // ===============================================================

          const Text(
            'Description (Optional)',

            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
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
          color: Color.fromRGBO(170, 185, 207, 1),
          width: 1.0,
        ),
      ),

      child: Row(
        children: [
          const SizedBox(width: 7),

          Image.asset(
            'assets/chopdi_edit_logo.png'
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
                fontWeight: FontWeight.w700,
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
    final currentLength =
        _descriptionController
            .text
            .length;

    return Container(
      height: 90,

      decoration: BoxDecoration(
        color: fieldColor,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Color.fromRGBO(170, 185, 207, 1),
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
              fontWeight: FontWeight.w700,
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

          // Positioned(
          //   right: 7,
          //   bottom: 5,

          //   child: Text(
          //     '$currentLength/100',

          //     style:
          //         const TextStyle(
          //       fontSize: 8,
          //       color: secondaryText,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INFO BOX
  // ===========================================================================

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      height: 51,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: Color.fromRGBO(253, 237, 217, 1),

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: const Color.fromRGBO(
            177, 95, 39, 0.23,
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
                EdgeInsets.only(top: 1),

            child: Image.asset(
              'assets/info-outline.png'
            )
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'These details help you manage your chopdi better.',

                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                    color: textColor,
                  ),
                ),

                SizedBox(height: 1),

                Text(
                  'You can change them anytime.',

                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
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
                'Save Changes',

                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(253, 237, 217, 1)
                ),
              ),
      ),
    );
  }

  // ===========================================================================
  // DELETE BUTTON
  // ===========================================================================

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap:
          _showDeleteChopdiBottomSheet,

      child: Container(
        width: double.infinity,
        height: 60,

        decoration: BoxDecoration(
          color:
              deleteBackground,

          borderRadius:
              BorderRadius.circular(7),

          border: Border.all(
            color: Color.fromRGBO(199, 76, 76, 1),
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
                color:
                    Color(0xFFF8D0C2),
                shape: BoxShape.circle,
              ),

              child: Image.asset(
                'assets/delete-outline.png'
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
                  'Delete Chopdi',

                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color: Color.fromRGBO(199, 76, 76, 1),
                  ),
                ),

                SizedBox(height: 1),

                Text(
                  'This action cannot be undone',

                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(199, 76, 76, 1),
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

