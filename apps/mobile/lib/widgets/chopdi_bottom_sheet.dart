import 'package:flutter/material.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/chopdi_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/create_new_chopdi.dart';


class ChopdiBottomSheet extends StatefulWidget {
  const ChopdiBottomSheet({super.key});

  @override
  State<ChopdiBottomSheet> createState() =>
      _ChopdiBottomSheetState();
}

class _ChopdiBottomSheetState extends State<ChopdiBottomSheet> {
  List<Chopdi> chopdis = [];
  Chopdi? currentChopdi;

  @override
  void initState() {
    super.initState();
    loadChopdis();
  }

  Future<void> loadChopdis() async {
    final allChopdis = await ChopdiService.getAllChopdis();
    final activeChopdi = await ChopdiService.getCurrentChopdi();

    if (!mounted) return;

    setState(() {
      chopdis = allChopdis;
      currentChopdi = activeChopdi;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentChopdi == null) {
      return const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Current Chopdi",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff7A7A7A),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              Column(
                children: chopdis.map((chopdi) {
                  final bool isActive =
                      chopdi.id == currentChopdi?.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () async {
                        await ChopdiService.setActiveChopdi(chopdi);

                        if (!mounted) return;

                        Navigator.pop(context, chopdi);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xffC7D6F5)
                                : const Color(0xffE0E0E0),
                            width: isActive ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xffE7F0FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                "assets/menu_logo.png",
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                chopdi.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff233B66),
                                ),
                              ),
                            ),

                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffE4ECFF),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      "Active",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff233B66),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check,
                                      color: Color(0xff233B66),
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 120),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff243B67),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final newChopdi =
                        await showModalBottomSheet<Chopdi>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => CreateChopdiBottomSheet(
                        parentContext: context,
                      ),
                    );

                    if (!mounted) return;

                    if (newChopdi != null) {
                      // Return new Chopdi to HomeScreen
                      Navigator.pop(context, newChopdi);
                    }
                  },
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            "Add New Chopdi",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Create a new chopdi book",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}