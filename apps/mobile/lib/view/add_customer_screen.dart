import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mychopdi/service/isar_service.dart';

import 'package:mychopdi/view/add_new_customer_screen.dart';
import 'package:mychopdi/view/customer_detail_add.dart';
import 'package:mychopdi/view/customer_details_screen.dart';

import '../widgets/add_new_customer_card.dart';
import '../widgets/alphabet_index.dart';
import '../widgets/contact_tile.dart';
import '../widgets/search_box.dart';

class AddCustomerScreen extends StatefulWidget {
  final int chopdiId;

  const AddCustomerScreen({
    super.key,
    required this.chopdiId,
  });

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _contactsScrollController =
      ScrollController();

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  bool isLoading = true;
  bool permissionDenied = false;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  // ============================================================
  // LOAD REAL DEVICE CONTACTS
  // ============================================================

  Future<void> loadContacts() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          permissionDenied = false;
        });
      }

      // Request contacts permission
      final permissionStatus =
          await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (permissionStatus != PermissionStatus.granted) {
        if (!mounted) return;

        setState(() {
          permissionDenied = true;
          isLoading = false;
        });

        return;
      }

      // Get contacts WITH all their properties
      final deviceContacts = await FlutterContacts.getAll(
        properties: ContactProperties.all,
      );

      // Remove contacts that don't have a name
      final validContacts = deviceContacts.where((contact) {
        return contact.displayName != null &&
            contact.displayName!.trim().isNotEmpty;
      }).toList();

      // Sort alphabetically
      validContacts.sort(
        (a, b) {
          final nameA = a.displayName ?? '';
          final nameB = b.displayName ?? '';

          return nameA.toLowerCase().compareTo(
                nameB.toLowerCase(),
              );
        },
      );

      if (!mounted) return;

      setState(() {
        contacts = validContacts;
        filteredContacts = validContacts;
        isLoading = false;
      });

      debugPrint(
        "Loaded ${validContacts.length} contacts",
      );

      // Debug first few contacts
      for (final contact in validContacts.take(5)) {
        debugPrint(
          "NAME: ${contact.displayName}, "
          "PHONE: ${contact.phones.map((p) => p.number).toList()}",
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Error loading contacts: $e");
      debugPrint("$stackTrace");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showErrorDialog(
        "Unable to load contacts: $e",
      );
    }
  }

  // ============================================================
  // ERROR POPUP
  // ============================================================

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff223A5E),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xff223A5E),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SEARCH CONTACTS
  // ============================================================

  void search(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredContacts = contacts;
        return;
      }

      filteredContacts = contacts.where((contact) {
        final name =
            (contact.displayName ?? '').toLowerCase();

        final phone = contact.phones.isNotEmpty
            ? contact.phones.first.number.toLowerCase()
            : '';

        return name.contains(query) ||
            phone.contains(query);
      }).toList();
    });

    // Reset list position after filtering.
    if (_contactsScrollController.hasClients) {
      _contactsScrollController.jumpTo(0);
    }
  }

  // ============================================================
  // NORMALIZE PHONE NUMBER
  // ============================================================

  String normalizePhoneNumber(String phone) {
    String cleaned =
        phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.startsWith('91') &&
        cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }

    return cleaned;
  }

  // ============================================================
  // SELECT CONTACT
  // ============================================================

  Future<void> selectContact(Contact contact) async {
    // Phone number is optional.
    final phoneNumber = contact.phones.isNotEmpty
        ? normalizePhoneNumber(
            contact.phones.first.number,
          )
        : '';

    final contactName =
        contact.displayName ?? 'Unknown';

    // Only check duplicate when a phone number exists.
    if (phoneNumber.isNotEmpty) {
      final existingCustomer =
          await IsarService.getCustomerByPhoneAndChopdi(
        phoneNumber,
        widget.chopdiId,
      );

      if (!mounted) return;

      if (existingCustomer != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerDetailsScreen(
              customer: existingCustomer,
            ),
          ),
        );

        return;
      }
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailsAdd(
          contactName: contactName,
          contactPhone: phoneNumber,
          chopdiId: widget.chopdiId,
        ),
      ),
    );
  }

  // ============================================================
  // SCROLL TO LETTER
  // ============================================================

  void _scrollToLetter(String letter) {
    if (filteredContacts.isEmpty) {
      return;
    }

    if (!_contactsScrollController.hasClients) {
      return;
    }

    // '#' means contacts that don't start with A-Z.
    if (letter == '#') {
      _contactsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

      return;
    }

    final index = filteredContacts.indexWhere(
      (contact) {
        final name =
            (contact.displayName ?? '').trim();

        if (name.isEmpty) {
          return false;
        }

        return name
            .toUpperCase()
            .startsWith(letter);
      },
    );

    if (index == -1) {
      return;
    }

    /*
      ContactTile can have slightly different heights depending
      on screen size and text wrapping.

      We therefore use a responsive estimated height instead
      of a large fixed height.
    */

    final screenWidth =
        MediaQuery.of(context).size.width;

    double itemHeight;

    if (screenWidth < 360) {
      itemHeight = 60;
    } else if (screenWidth < 600) {
      itemHeight = 64;
    } else {
      itemHeight = 68;
    }

    final offset = index * itemHeight;

    final maxScroll =
        _contactsScrollController.position.maxScrollExtent;

    final safeOffset =
        offset.clamp(0.0, maxScroll);

    _contactsScrollController.animateTo(
      safeOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    _contactsScrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8EEDC),
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // Responsive horizontal padding.
            final horizontalPadding = width < 360
                ? 14.0
                : width < 600
                    ? 18.0
                    : width * 0.05;

            // Responsive vertical padding.
            final verticalPadding = height < 600
                ? 8.0
                : height < 800
                    ? 14.0
                    : 18.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      InkWell(
                        borderRadius:
                            BorderRadius.circular(20),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Color(0xff223A5E),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Flexible(
                        child: Text(
                          "Add Customer",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width < 360
                                ? 17
                                : 18,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                const Color(0xff223A5E),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: height < 600
                        ? 14
                        : 22,
                  ),

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  SearchBox(
                    controller: searchController,
                    onChanged: search,
                  ),

                  SizedBox(
                    height: height < 600
                        ? 12
                        : 18,
                  ),

                  // ==================================================
                  // ADD NEW CUSTOMER
                  // ==================================================

                  AddNewCustomerCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddNewCustomerScreen(
                            chopdiId: widget.chopdiId,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height: height < 600
                        ? 14
                        : 20,
                  ),

                  // ==================================================
                  // ALL CONTACTS HEADER
                  // ==================================================

                  const Text(
                    "All Contacts",
                    style: TextStyle(
                      color: Color(0xff223A5E),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // CONTACT AREA
                  // ==================================================

                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // --------------------------------------------
                        // CONTACT LIST
                        // --------------------------------------------

                        Padding(
                          padding: EdgeInsets.only(
                            right: width < 360
                                ? 20
                                : 24,
                          ),
                          child: buildContactsList(),
                        ),

                        // --------------------------------------------
                        // ALPHABET INDEX
                        // --------------------------------------------

                        if (!isLoading &&
                            !permissionDenied &&
                            filteredContacts.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 4,
                            bottom: 4,
                            child: LayoutBuilder(
                              builder:
                                  (context, indexConstraints) {
                                return SizedBox(
                                  width: width < 360
                                      ? 20
                                      : 22,
                                  height:
                                      indexConstraints.maxHeight,
                                  child: AlphabetIndex(
                                    onLetterSelected:
                                        _scrollToLetter,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CONTACT LIST
  // ============================================================

  Widget buildContactsList() {
    // ==========================================================
    // LOADING
    // ==========================================================

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ==========================================================
    // PERMISSION DENIED
    // ==========================================================

    if (permissionDenied) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.contacts_outlined,
                size: 50,
                color: Color(0xff223A5E),
              ),

              const SizedBox(height: 12),

              const Text(
                "Contacts permission is required",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff223A5E),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: loadContacts,
                child: const Text(
                  "Allow Contacts",
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // NO CONTACTS
    // ==========================================================

    if (filteredContacts.isEmpty) {
      return const Center(
        child: Text(
          "No contacts found",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xff223A5E),
            fontSize: 16,
          ),
        ),
      );
    }

    // ==========================================================
    // CONTACT LIST
    // ==========================================================

    return ListView.builder(
      controller: _contactsScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      itemCount: filteredContacts.length,
      itemBuilder: (_, index) {
        final contact =
            filteredContacts[index];

        final phone = contact.phones.isNotEmpty
            ? contact.phones.first.number
            : "No phone number";

        return ContactTile(
          name: contact.displayName ?? 'Unknown',
          phone: phone,
          onTap: () {
            selectContact(contact);
          },
        );
      },
    );
  }
}