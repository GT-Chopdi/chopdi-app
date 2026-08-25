import 'package:flutter/material.dart';

class EditChopdiScreen extends StatefulWidget {
  const EditChopdiScreen({
    super.key,
    this.initialName = 'My Chopdi',
    this.initialDescription =
        'My personal lending ledger to track loans and interest.',
    this.onSave,
    this.onDelete,
  });

  final String initialName;
  final String initialDescription;

  final Future<void> Function(String name, String description)? onSave;
  final VoidCallback? onDelete;

  @override
  State<EditChopdiScreen> createState() => _EditChopdiScreenState();
}

class _EditChopdiScreenState extends State<EditChopdiScreen> {
  // ---------------------------------------------------------------------------
  // COLORS
  // ---------------------------------------------------------------------------

  static const Color backgroundColor = Color(0xFFFFEEDB);
  static const Color cardColor = Color(0xFFFFFBF6);
  static const Color darkBlue = Color(0xFF203E68);
  static const Color textColor = Color(0xFF263C5A);
  static const Color secondaryText = Color(0xFF69778A);
  static const Color borderColor = Color(0xFFB8C7D9);
  static const Color fieldColor = Color(0xFFFFF9F2);
  static const Color orange = Color(0xFFFF7A3D);
  static const Color infoBackground = Color(0xFFFFEEDB);
  static const Color deleteBackground = Color(0xFFFFEDE2);
  static const Color deleteBorder = Color(0xFFE96E55);
  static const Color deleteRed = Color(0xFFD94D3D);

  // ---------------------------------------------------------------------------
  // CONTROLLERS
  // ---------------------------------------------------------------------------

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName,
    );

    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );

    _descriptionController.addListener(_descriptionChanged);
  }

  void _descriptionChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SAVE
  // ---------------------------------------------------------------------------

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter a Chopdi name.');
      return;
    }

    if (name.length > 50) {
      _showError('Chopdi name cannot exceed 50 characters.');
      return;
    }

    if (description.length > 100) {
      _showError('Description cannot exceed 100 characters.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.onSave != null) {
        await widget.onSave!(
          name,
          description,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chopdi updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      _showError('Unable to save changes. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  void _deleteChopdi() {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Chopdi?',
            style: TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'This action cannot be undone. All data associated with this Chopdi may be permanently deleted.',
            style: TextStyle(
              color: secondaryText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: darkBlue,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: deleteRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },

          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                physics: const BouncingScrollPhysics(),

                padding: EdgeInsets.only(
                  left: 28,
                  right: 16,
                  top: 34,
                  bottom: keyboardVisible ? 30 : 45,
                ),

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 34,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------------------------------------------------------
                      // HEADER
                      // -------------------------------------------------------

                      _buildHeader(),

                      const SizedBox(height: 12),

                      // -------------------------------------------------------
                      // BOOK
                      // -------------------------------------------------------

                      _buildBookSection(),

                      const SizedBox(height: 7),

                      // -------------------------------------------------------
                      // EDIT CARD
                      // -------------------------------------------------------

                      _buildEditCard(),

                      const SizedBox(height: 40),

                      // -------------------------------------------------------
                      // DELETE
                      // -------------------------------------------------------

                      _buildDeleteButton(),
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

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.only(
              top: 1,
              right: 6,
            ),
            child: Icon(
              Icons.arrow_back,
              size: 19,
              color: darkBlue,
            ),
          ),
        ),

        const SizedBox(width: 1),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Edit Chopdi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),

            SizedBox(height: 1),

            Text(
              'Update your chopdi details',
              style: TextStyle(
                fontSize: 8.5,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BOOK SECTION
  // ---------------------------------------------------------------------------

  Widget _buildBookSection() {
    return SizedBox(
      height: 121,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Positioned(
            top: 7,
            child: Container(
              width: 94,
              height: 94,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE3CD),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Decorative left branch
          Positioned(
            left: 62,
            bottom: 12,
            child: Transform.rotate(
              angle: -0.15,
              child: const Icon(
                Icons.spa_outlined,
                size: 39,
                color: Color(0xFFD6A36C),
              ),
            ),
          ),

          // Decorative right branch
          Positioned(
            right: 62,
            bottom: 12,
            child: Transform.scale(
              scaleX: -1,
              child: const Icon(
                Icons.spa_outlined,
                size: 39,
                color: Color(0xFFD6A36C),
              ),
            ),
          ),

          // Small decorative dots
          const Positioned(
            left: 98,
            top: 32,
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFFD5A06A),
              ),
            ),
          ),

          const Positioned(
            right: 98,
            top: 36,
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFFD5A06A),
              ),
            ),
          ),

          // Book
          _buildBook(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOOK
  // ---------------------------------------------------------------------------

  Widget _buildBook() {
    return Transform.rotate(
      angle: -0.045,
      child: SizedBox(
        width: 72,
        height: 95,
        child: Stack(
          children: [
            // Book shadow
            Positioned(
              left: 8,
              bottom: 4,
              child: Container(
                width: 59,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0x442B1D16),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            // Main book
            Positioned(
              left: 8,
              top: 3,
              child: Container(
                width: 57,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFA91F25),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 3,
                      offset: Offset(2, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Spine
                    Positioned(
                      left: 4,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        width: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7E161C),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Inner cover
                    Positioned(
                      left: 12,
                      top: 9,
                      right: 6,
                      bottom: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE4B96A),
                            width: 1.1,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.currency_rupee_rounded,
                              size: 22,
                              color: Color(0xFFE4B96A),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Chopdi',
                              style: TextStyle(
                                fontSize: 6,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE4B96A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pages
            Positioned(
              left: 62,
              top: 10,
              child: Container(
                width: 5,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7D2B6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Bottom bookmark
            Positioned(
              left: 34,
              bottom: 0,
              child: Container(
                width: 8,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF78151B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EDIT CARD
  // ---------------------------------------------------------------------------

  Widget _buildEditCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        11,
        12,
        11,
        12,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------------
          // CHOPDI NAME LABEL
          // ---------------------------------------------------------------

          const Text(
            'Chopdi Name',
            style: TextStyle(
              fontSize: 9,
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 5),

          // ---------------------------------------------------------------
          // NAME FIELD
          // ---------------------------------------------------------------

          _buildNameField(),

          const SizedBox(height: 12),

          // ---------------------------------------------------------------
          // DESCRIPTION LABEL
          // ---------------------------------------------------------------

          const Text(
            'Description (Optional)',
            style: TextStyle(
              fontSize: 9,
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 5),

          // ---------------------------------------------------------------
          // DESCRIPTION FIELD
          // ---------------------------------------------------------------

          _buildDescriptionField(),

          const SizedBox(height: 14),

          // ---------------------------------------------------------------
          // INFO BOX
          // ---------------------------------------------------------------

          _buildInfoBox(),

          const SizedBox(height: 20),

          // ---------------------------------------------------------------
          // SAVE BUTTON
          // ---------------------------------------------------------------

          _buildSaveButton(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NAME FIELD
  // ---------------------------------------------------------------------------

  Widget _buildNameField() {
    return Container(
      height: 27,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 7),

          const Icon(
            Icons.menu_book_outlined,
            size: 13,
            color: Color(0xFF526B89),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              maxLength: 50,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                _descriptionFocusNode.requestFocus();
              },
              style: const TextStyle(
                fontSize: 9.5,
                color: darkBlue,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.only(
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

  // ---------------------------------------------------------------------------
  // DESCRIPTION FIELD
  // ---------------------------------------------------------------------------

  Widget _buildDescriptionField() {
    final currentLength = _descriptionController.text.length;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            maxLength: 100,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              fontSize: 9.2,
              height: 1.25,
              color: darkBlue,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.fromLTRB(
                7,
                6,
                7,
                18,
              ),
            ),
          ),

          // Character count
          Positioned(
            right: 7,
            bottom: 5,
            child: Text(
              '$currentLength/100',
              style: const TextStyle(
                fontSize: 8,
                color: secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFO BOX
  // ---------------------------------------------------------------------------

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      height: 34,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: infoBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFFFC58D),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline,
              size: 12,
              color: orange,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'These details help you manage your chopdi better.',
                  style: TextStyle(
                    fontSize: 7.1,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'You can change them anytime.',
                  style: TextStyle(
                    fontSize: 6.7,
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

  // ---------------------------------------------------------------------------
  // SAVE BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 37,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          disabledBackgroundColor: darkBlue.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _deleteChopdi,
      child: Container(
        width: double.infinity,
        height: 41,
        decoration: BoxDecoration(
          color: deleteBackground,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: deleteBorder,
            width: 0.9,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),

            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFF8D0C2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                size: 15,
                color: deleteRed,
              ),
            ),

            const SizedBox(width: 9),

            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete Chopdi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: deleteRed,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'This action cannot be undone',
                  style: TextStyle(
                    fontSize: 7.2,
                    color: deleteRed,
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
