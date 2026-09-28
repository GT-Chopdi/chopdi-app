import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/view/add_new_customer_screen.dart';
import 'package:mychopdi/view/customer_details_screen.dart';

import '../widgets/add_new_customer_card.dart';
import '../widgets/alphabet_index.dart';
import '../widgets/contact_tile.dart';
import '../widgets/search_box.dart';

class AddCustomerScreen extends StatefulWidget {
  final int chopdiId;
  const AddCustomerScreen({super.key, required this.chopdiId});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _contactsScrollController = ScrollController();

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  bool isLoading = true;
  bool permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      loadContacts();
    });
  }

  Future<void> loadContacts() async {
    try {
      setState(() {
        isLoading = true;
        permissionDenied = false;
      });

      final permissionStatus = await FlutterContacts.permissions.request(
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

      final deviceContacts = await FlutterContacts.getAll(
        properties: ContactProperties.all,
      );

      final validContacts = deviceContacts.where((contact) {
        return contact.displayName != null &&
            contact.displayName!.trim().isNotEmpty;
      }).toList();

      validContacts.sort((a, b) {
        final nameA = a.displayName ?? '';
        final nameB = b.displayName ?? '';
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      });

      if (!mounted) return;

      setState(() {
        contacts = validContacts;
        filteredContacts = validContacts;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint("Error loading contacts: $e\n$stackTrace");

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.unableToLoadContacts}: $e")),
      );
    }
  }

  void search(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredContacts = contacts;
        return;
      }

      filteredContacts = contacts.where((contact) {
        final name = (contact.displayName ?? '').toLowerCase();
        final phone = contact.phones.isNotEmpty
            ? contact.phones.first.number.toLowerCase()
            : '';

        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  String normalizePhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }
    return cleaned;
  }

  Future<void> selectContact(Contact contact) async {
    final phoneNumber = contact.phones.isNotEmpty
        ? normalizePhoneNumber(contact.phones.first.number)
        : '';

    final contactName = contact.displayName ?? 'Unknown';

    if (phoneNumber.isNotEmpty) {
      final existingCustomer = await IsarService.getCustomerByPhoneAndChopdi(
        phoneNumber,
        widget.chopdiId,
      );

      if (!mounted) return;

      // Existing customer → open details screen directly
      if (existingCustomer != null) {
        Navigator.pushReplacement(
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

    // New contact → open AddNewCustomerScreen with pre-filled details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewCustomerScreen(
          chopdiId: widget.chopdiId,
          initialName: contactName,
          initialPhone: phoneNumber,
        ),
      ),
    );
  }

  void _scrollToLetter(String letter) {
    if (filteredContacts.isEmpty) return;

    if (letter == '#') {
      _contactsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    final index = filteredContacts.indexWhere((contact) {
      final name = (contact.displayName ?? '').trim();
      if (name.isEmpty) return false;
      return name.substring(0, 1).toUpperCase() == letter;
    });

    if (index == -1) return;

    const double itemHeight = 65.0;
    final double offset = index * itemHeight;
    final double maxScroll =
        _contactsScrollController.position.maxScrollExtent;

    _contactsScrollController.animateTo(
      offset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _contactsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xff223A5E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.addCustomer,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff223A5E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SearchBox(
                    controller: searchController,
                    onChanged: search,
                  ),
                  const SizedBox(height: 18),

                  // FIXED: Navigate to AddNewCustomerScreen without auto-popping the next screen
                  AddNewCustomerCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddNewCustomerScreen(
                            chopdiId: widget.chopdiId,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 22),
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
            Positioned(
              right: 6,
              top: 260,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.62,
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

  Widget buildContactsList() {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (permissionDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.contacts_outlined,
              size: 50,
              color: Color(0xff223A5E),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.contactsPermissionRequired,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff223A5E),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadContacts,
              child: Text(l10n.allowContacts),
            ),
          ],
        ),
      );
    }

    if (filteredContacts.isEmpty) {
      return Center(
        child: Text(
          l10n.noContactsFound,
          style: const TextStyle(
            color: Color(0xff223A5E),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _contactsScrollController,
      itemExtent: 65.0,
      itemCount: filteredContacts.length,
      itemBuilder: (_, index) {
        final contact = filteredContacts[index];
        final phone = contact.phones.isNotEmpty
            ? contact.phones.first.number
            : l10n.noPhoneNumber;

        return ContactTile(
          name: contact.displayName ?? l10n.unknownContact,
          phone: phone,
          onTap: () => selectContact(contact),
        );
      },
    );
  }
}