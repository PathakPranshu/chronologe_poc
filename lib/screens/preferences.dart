import 'package:chronologe_poc/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Preferences extends ConsumerStatefulWidget {
  const Preferences({super.key});

  @override
  ConsumerState<Preferences> createState() => _PreferencesState();
}

enum ChosenFont { FANCY, DEFAULT }

class _PreferencesState extends ConsumerState<Preferences> {
  @override
  Widget build(BuildContext context) {
    ChosenFont? selectedFont = ref.watch(customFontsProvider).value;
    ThemeMode selectedTheme = ref.watch(themeProvider);
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                headlineMedium: Theme.of(context).textTheme.displaySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                titleLarge: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            child: SliverAppBar.large(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text("Preferences"),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(),
                  Text(
                    "App Theme",
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    borderRadius: BorderRadius.circular(28),
                    color: theme.colorScheme.surfaceContainerLowest,
                    clipBehavior: Clip.antiAlias,
                    child: RadioGroup(
                      groupValue: selectedTheme,
                      onChanged: (ThemeMode? mode) {
                        if (mode != null) {
                          setState(() {
                            selectedTheme = mode;
                          });
                          ref.read(themeProvider.notifier).setTheme(mode);
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile(
                            value: ThemeMode.light,
                            title: Text("Light Mode"),
                          ),
                          RadioListTile(
                            value: ThemeMode.dark,
                            title: Text("Dark Mode"),
                          ),
                          RadioListTile(
                            value: ThemeMode.system,
                            title: Text("System Default"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Diary Fonts",
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    borderRadius: BorderRadius.circular(28),
                    color: theme.colorScheme.surfaceContainerLowest,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioGroup(
                          groupValue: selectedFont,
                          onChanged: (ChosenFont? font) {
                            setState(() {
                              selectedFont = font;
                            });
                            if (font != null) {
                              ref
                                  .read(customFontsProvider.notifier)
                                  .setCustomFonts(font);
                            }
                          },
                          child: Column(
                            children: [
                              RadioListTile(
                                value: ChosenFont.DEFAULT,
                                title: Text(
                                  "Default",
                                  style: TextStyle(fontFamily: "Fraunces"),
                                ),
                              ),

                              RadioListTile(
                                value: ChosenFont.FANCY,
                                title: Text(
                                  "Fancy",
                                  style: GoogleFonts.literata(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Font Preview",
                            style: theme.textTheme.labelMedium!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Title of entries looks like this",
                                  style: selectedFont == ChosenFont.DEFAULT
                                      ? theme.textTheme.titleLarge!.copyWith(
                                          fontFamily: "Fraunces",
                                        )
                                      : theme.textTheme.titleLarge!.merge(
                                          GoogleFonts.literata(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "your dialy entries texts looks like this with this font.",
                                  style: selectedFont == ChosenFont.FANCY
                                      ? theme.textTheme.bodyLarge!.merge(
                                          GoogleFonts.comicNeue(),
                                        )
                                      : theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
