import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/constants/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.getPrimaryColor(context),
        elevation: 0,
      ),
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Consumer2<AuthService, FavoritesService>(
        builder: (context, authService, favoritesService, child) {
          if (!authService.isLoggedIn) {
            return _buildLoginPrompt(context, authService);
          }

          return _buildProfileContent(context, authService, favoritesService);
        },
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, AuthService authService) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.person,
                size: 64,
                color: AppColors.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Jelentkezz be a Google fiókoddal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.getPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'A bejelentkezés után szinkronizálhatod a kedvenceidet és beállításaidat a felhőbe.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed:
                  authService.isLoading
                      ? null
                      : () async {
                        final success = await authService.signInWithGoogle();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sikeres bejelentkezés!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
              icon:
                  authService.isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Symbols.login),
              label: Text(
                authService.isLoading
                    ? 'Bejelentkezés...'
                    : 'Bejelentkezés Google fiókkal',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    AuthService authService,
    FavoritesService favoritesService,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil info kártya
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        authService.userPhotoURL != null
                            ? NetworkImage(authService.userPhotoURL!)
                            : null,
                    child:
                        authService.userPhotoURL == null
                            ? Icon(
                              Symbols.person,
                              size: 30,
                              color: AppColors.getPrimaryColor(context),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authService.userDisplayName ?? 'Felhasználó',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authService.userEmail ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Szinkronizáció beállítások
          Text(
            'Felhő szinkronizáció',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Automatikus szinkronizáció'),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kedvencek automatikus szinkronizálása',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      // SYNC badge csak akkor jelenik meg, ha be van kapcsolva
                      if (favoritesService.isCloudSyncEnabled)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_sync,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'SYNC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  value: favoritesService.isCloudSyncEnabled,
                  onChanged: (value) async {
                    // Előzetesen beállítjuk az UI-t az azonnali visszajelzéshez
                    setState(() {
                      // A Provider értesíteni fogja a többi widget-et
                    });

                    try {
                      if (value) {
                        await favoritesService.enableCloudSync();
                        // Első szinkronizáció
                        await favoritesService.syncToCloud();
                      } else {
                        await favoritesService.disableCloudSync();
                      }

                      // Frissítjük a UI-t a végleges állapottal
                      if (mounted) {
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  value ? Icons.cloud_done : Icons.cloud_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  value
                                      ? 'Szinkronizáció bekapcsolva ✓'
                                      : 'Szinkronizáció kikapcsolva',
                                ),
                              ],
                            ),
                            backgroundColor:
                                value ? Colors.green : Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text('Hiba történt: $e'),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  activeColor: AppColors.getPrimaryColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                if (favoritesService.isCloudSyncEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Symbols.cloud_sync,
                      color: AppColors.getPrimaryColor(context),
                    ),
                    title: const Text('Manuális szinkronizáció'),
                    subtitle: Text(
                      '${favoritesService.favorites.length} kedvenc megálló',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Symbols.refresh),
                      onPressed: () async {
                        final success = await favoritesService.syncToCloud();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Szinkronizáció sikeres!'
                                    : 'Szinkronizáció sikertelen!',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Egyéb beállítások
          Text(
            'Fiók beállítások',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Symbols.download,
                    color: AppColors.getPrimaryColor(context),
                  ),
                  title: const Text('Adatok visszaállítása'),
                  subtitle: const Text('Kedvencek letöltése a felhőből'),
                  onTap: () async {
                    final success = await favoritesService.syncFromCloud();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Adatok visszaállítva!'
                                : 'Visszaállítás sikertelen!',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Symbols.logout, color: Colors.red),
                  title: const Text(
                    'Kijelentkezés',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sikeresen kijelentkeztél!'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
