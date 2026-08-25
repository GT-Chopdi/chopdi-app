import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/view/took_loan_add_new_lender_screen.dart';
import 'package:mychopdi/view/took_loan_customer_detail_add.dart';
import 'package:mychopdi/view/took_loan_customer_details_screen.dart';
import 'package:mychopdi/widgets/took_loan_add_new_lender_card.dart';

import '../widgets/alphabet_index.dart';
import '../widgets/contact_tile.dart';
import '../widgets/search_box.dart';

class TookLoanAddLenderScreen extends StatefulWidget {
  final int chopdiId;
  const TookLoanAddLenderScreen({super.key,required this.chopdiId});

  @override
  State<TookLoanAddLenderScreen> createState() => _TookLoanAddLenderScreen();
}

class _TookLoanAddLenderScreen extends State<TookLoanAddLenderScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _contactsScrollController = ScrollController();

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  bool isLoading = true;
  bool permissionDenied = false;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  // LOAD REAL DEVICE CONTACTS

  Future<void> loadContacts() async {
    try {
      setState(() {
        isLoading = true;
        permissionDenied = false;
      });

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to load contacts: $e",
          ),
        ),
      );
    }
  }

  // SEARCH CONTACTS

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
  }

  // SELECT CONTACT

  String normalizePhoneNumber(String phone) {
    String cleaned =
        phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.startsWith('91') &&
        cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }

    return cleaned;
  }

  Future<void> selectContact(Contact contact) async {
    if (contact.phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This contact does not have a phone number',
          ),
        ),
      );

      return;
    }

    final phoneNumber =
        normalizePhoneNumber(contact.phones.first.number);

    final contactName =
        contact.displayName ?? 'Unknown';

    // // Check existing customer
    final existingCustomer =
        await IsarService.getCustomerByPhoneAndChopdi(
      phoneNumber,
      widget.chopdiId,
    );

    if (!mounted) return;

    // Existing customer
    if (existingCustomer != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TookLoanCustomerDetailsScreen(
            customer: existingCustomer,
          ),
        ),
      );

      return;
    }

    // New customer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TookLoanCustomerDetailAdd(
          contactName: contactName,
          contactPhone: phoneNumber,
          chopdiId: widget.chopdiId,
        ),
      ),
    );
  }

  void _scrollToLetter(String letter) {
    if (filteredContacts.isEmpty) {
      return;
    }

    // '#' means contacts that don't start with A-Z
    if (letter == '#') {
      _contactsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
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

        return name.toUpperCase().startsWith(letter);
      },
    );

    if (index == -1) {
      return;
    }

    // Approximate height of each ContactTile.
    const double itemHeight = 65;

    final offset = index * itemHeight;

    _contactsScrollController.animateTo(
      offset.clamp(
        0.0,
        _contactsScrollController
            .position
            .maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF8EEDC),

      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 16),

                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------

                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xff223A5E),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        "Add Lender",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff223A5E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ------------------------------------------------
                  // SEARCH
                  // ------------------------------------------------

                  SearchBox(
                    controller: searchController,
                    onChanged: search,
                  ),

                  const SizedBox(height: 18),

                  // ------------------------------------------------
                  // ADD NEW CUSTOMER
                  // ------------------------------------------------
                  AddNewLenderCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddNewLenderScreen(
                            chopdiId: widget.chopdiId,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // ALL CONTACTS
                  // ------------------------------------------------

                  const Text(
                    "All Contacts",
                    style: TextStyle(
                      color: Color(0xff223A5E),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: buildContactsList(),
                  ),
                ],
              ),
            ),

            // ALPHABET INDEX

            Positioned(
              right: 6,
              top: 260,

              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                        0.62,

                // child: const AlphabetIndex(),
                child: AlphabetIndex(
                  onLetterSelected: _scrollToLetter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTACT LIST
  // ------------------------------------------------------------

  Widget buildContactsList() {
    // Loading
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Permission denied
    if (permissionDenied) {
      return Center(
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
      );
    }

    // No contacts
    if (filteredContacts.isEmpty) {
      return const Center(
        child: Text(
          "No contacts found",
          style: TextStyle(
            color: Color(0xff223A5E),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _contactsScrollController,
      itemCount: filteredContacts.length,
      itemBuilder: (_, index) {
        final contact = filteredContacts[index];

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