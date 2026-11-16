import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/data/models/auth_models.dart';
import 'features/auth/presentation/auth_controller.dart';

void main() => runApp(const ProviderScope(child: MyDriveApp()));

class MyDriveApp extends StatelessWidget {
    const MyDriveApp({super.key});
    @override
    Widget build(BuildContext context) => MaterialApp(
        title: 'My Drive',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F8FC),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6758E8)),
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE3E6EF)),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE3E6EF)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 17,
                ),
            ),
        ),
        home: const WelcomeScreen(),
    );
}

class WelcomeScreen extends StatelessWidget {
    const WelcomeScreen({super.key});
    @override
    Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const _Brand(),
                                const SizedBox(height: 54),
                                Container(
                                    height: 220,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            colors: [Color(0xFF6F61ED), Color(0xFF9E82F1)],
                                        ),
                                        borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Stack(
                                        children: [
                                            Positioned(
                                                right: 24,
                                                top: 24,
                                                child: Icon(
                                                    Icons.cloud,
                                                    size: 140,
                                                    color: Colors.white.withAlpha(40),
                                                ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.fromLTRB(25, 30, 155, 20),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(
                                                            'Your files,\none simple space.',
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 27,
                                                                height: 1.08,
                                                                fontWeight: FontWeight.w800,
                                                            ),
                                                        ),
                                                        SizedBox(height: 14),
                                                        Text(
                                                            'Connect every cloud.\nFind anything, anywhere.',
                                                            style: TextStyle(
                                                                color: Color(0xFFE9E5FF),
                                                                fontSize: 14,
                                                                height: 1.4,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                    'Welcome to My Drive',
                                    style: Theme.of(context).textTheme.headlineMedium
                                            ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                    'A calmer way to manage all your cloud storage from one beautiful app.',
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                        onPressed: () => _auth(context, false),
                                        child: const Text('Get started'),
                                    ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                        onPressed: () => _auth(context, true),
                                        child: const Text('I already have an account'),
                                    ),
                                ),
                                const SizedBox(height: 22),
                                const Center(
                                    child: Text(
                                        'Secure by SAIFULLAH  •  Your files stay yours',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF8A92A5)),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        ),
    );
    void _auth(BuildContext context, bool login) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen(login: login)),
    );
}

class AuthScreen extends ConsumerStatefulWidget {
    const AuthScreen({super.key, required this.login});
    final bool login;
    @override
    ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
    late bool login = widget.login;
    final email = TextEditingController();
    final password = TextEditingController();
    final name = TextEditingController();
    final phone = TextEditingController();
    final dob = TextEditingController();
    final gender = TextEditingController();
    final confirmPassword = TextEditingController();
    @override
    void dispose() {
        email.dispose();
        password.dispose();
        name.dispose();
        phone.dispose();
        dob.dispose();
        gender.dispose();
        confirmPassword.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: const BackButton(),
        ),
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 18, 28, 32),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const _Brand(),
                                const SizedBox(height: 42),
                                Text(
                                    login ? 'Welcome back' : 'Create your account',
                                    style: Theme.of(context).textTheme.headlineLarge
                                            ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    login
                                            ? 'Sign in to pick up where you left off.'
                                            : 'Start managing your clouds in one place.',
                                ),
                                const SizedBox(height: 28),
                                if (!login) ...[
                                    TextField(
                                        controller: name,
                                        decoration: const InputDecoration(
                                            labelText: 'Full name',
                                            prefixIcon: Icon(Icons.person_outline),
                                        ),
                                    ),
                                    const SizedBox(height: 14),
                                    TextField(
                                        controller: phone,
                                        keyboardType: TextInputType.phone,
                                        decoration: const InputDecoration(
                                            labelText: 'Phone',
                                            prefixIcon: Icon(Icons.phone_outlined),
                                        ),
                                    ),
                                    const SizedBox(height: 14),
                                    TextField(
                                        controller: dob,
                                        decoration: const InputDecoration(
                                            labelText: 'Date of birth (YYYY-MM-DD)',
                                            prefixIcon: Icon(Icons.calendar_today_outlined),
                                        ),
                                    ),
                                    const SizedBox(height: 14),
                                    TextField(
                                        controller: gender,
                                        decoration: const InputDecoration(
                                            labelText: 'Gender',
                                            prefixIcon: Icon(Icons.wc_outlined),
                                        ),
                                    ),
                                    const SizedBox(height: 14),
                                ],
                                TextField(
                                    controller: email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                        labelText: 'Email address',
                                        prefixIcon: Icon(Icons.mail_outline),
                                    ),
                                ),
                                if (!login) ...[
                                    const SizedBox(height: 14),
                                    TextField(
                                        controller: confirmPassword,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                            labelText: 'Confirm password',
                                            prefixIcon: Icon(Icons.lock_reset_outlined),
                                        ),
                                    ),
                                ],
                                const SizedBox(height: 14),
                                TextField(
                                    controller: password,
                                    obscureText: true,
                                    onSubmitted: (_) => _continue(),
                                    decoration: const InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.lock_outline),
                                    ),
                                ),
                                if (login)
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                            onPressed: () {},
                                            child: const Text('Forgot password?'),
                                        ),
                                    ),
                                const SizedBox(height: 12),
                                SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                        onPressed: _continue,
                                        child: Text(login ? 'Sign in' : 'Create account'),
                                    ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                    children: [
                                        const Expanded(child: Divider()),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text('or', style: TextStyle(color: Colors.grey)),
                                        ),
                                        const Expanded(child: Divider()),
                                    ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                        onPressed: _continue,
                                        icon: const Icon(Icons.g_mobiledata, size: 27),
                                        label: const Text('Continue with Google'),
                                    ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                    child: TextButton(
                                        onPressed: () => setState(() => login = !login),
                                        child: Text(
                                            login
                                                    ? 'New to My Drive? Create an account'
                                                    : 'Already have an account? Sign in',
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        ),
    );
    Future<void> _continue() async {
        if (login) {
            await ref
                    .read(authControllerProvider.notifier)
                    .login(email.text.trim(), password.text);
        } else {
            final parts = name.text.trim().split(RegExp(r'\s+'));
            await ref
                    .read(authControllerProvider.notifier)
                    .register(
                        RegisterRequest(
                            firstName: parts.isEmpty ? '' : parts.first,
                            lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
                            password: password.text,
                            dob: dob.text.trim(),
                            gender: gender.text.trim(),
                            email: email.text.trim(),
                            phone: phone.text.trim(),
                            confirmPassword: confirmPassword.text,
                        ),
                    );
        }
        if (!mounted) return;
        final state = ref.read(authControllerProvider);
        if (state.hasError) {
            ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.error.toString())));
            return;
        }
        if (login) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AppShell()),
                (_) => false,
            );
        } else {
            setState(() => login = true);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account created. Please sign in.')),
            );
        }
    }
}

class AppShell extends StatefulWidget {
    const AppShell({super.key});
    @override
    State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
    int index = 1;
    final connected = <String>{'Google Drive'};
    @override
    Widget build(BuildContext context) {
        final pages = [
            const HomePage(),
            AccountsPage(connected: connected),
            const SearchPage(),
            const SettingsPage(),
        ];
        return Scaffold(
            body: IndexedStack(index: index, children: pages),
            bottomNavigationBar: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (v) => setState(() => index = v),
                destinations: const [
                    NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Home',
                    ),
                    NavigationDestination(
                        icon: Icon(Icons.folder_outlined),
                        selectedIcon: Icon(Icons.folder),
                        label: 'List',
                    ),
                    NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                    NavigationDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: 'Settings',
                    ),
                ],
            ),
        );
    }
}

class HomePage extends StatelessWidget {
    const HomePage({super.key});
    @override
    Widget build(BuildContext context) => _Page(
        title: 'Good morning, Alex',
        subtitle: 'Everything in one place.',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1E2540),
                        borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Text(
                                'TOTAL STORAGE',
                                style: TextStyle(
                                    color: Color(0xFFB4BAD0),
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                ),
                            ),
                            const SizedBox(height: 11),
                            const Text(
                                '18.4 GB  /  35 GB',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                ),
                            ),
                            const SizedBox(height: 15),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: const LinearProgressIndicator(
                                    value: .52,
                                    minHeight: 8,
                                    backgroundColor: Color(0xFF454B63),
                                    color: Color(0xFF8D7BF1),
                                ),
                            ),
                            const SizedBox(height: 9),
                            const Text(
                                '52% used across 1 connected account',
                                style: TextStyle(color: Color(0xFFB4BAD0), fontSize: 12),
                            ),
                        ],
                    ),
                ),
                const SizedBox(height: 28),
                Text('Quick access', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                const Row(
                    children: [
                        _Tile(
                            icon: Icons.image_outlined,
                            title: 'Photos',
                            count: '248 files',
                            color: Color(0xFFFFE9D9),
                        ),
                        SizedBox(width: 12),
                        _Tile(
                            icon: Icons.description_outlined,
                            title: 'Documents',
                            count: '96 files',
                            color: Color(0xFFE5E5FF),
                        ),
                    ],
                ),
                const SizedBox(height: 12),
                const Row(
                    children: [
                        _Tile(
                            icon: Icons.video_library_outlined,
                            title: 'Videos',
                            count: '32 files',
                            color: Color(0xFFDFF6EF),
                        ),
                        SizedBox(width: 12),
                        _Tile(
                            icon: Icons.star_border,
                            title: 'Starred',
                            count: '18 files',
                            color: Color(0xFFFFF3CF),
                        ),
                    ],
                ),
            ],
        ),
    );
}

class AccountsPage extends StatefulWidget {
    const AccountsPage({super.key, required this.connected});
    final Set<String> connected;
    @override
    State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
    final providers = const [
        _Provider('Google Drive', 'alex@example.com', 'G', Color(0xFF4285F4)),
        _Provider('Dropbox', 'Connect your Dropbox', 'D', Color(0xFF1677FF)),
        _Provider('JioCloud', 'Connect your JioCloud', 'J', Color(0xFFEF4C56)),
    ];
    @override
    Widget build(BuildContext context) => _Page(
        title: 'Your cloud accounts',
        subtitle: 'Connect accounts to see all your files together.',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                            'Connected accounts',
                            style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                            '${widget.connected.length} of 3',
                            style: const TextStyle(
                                color: Color(0xFF6758E8),
                                fontWeight: FontWeight.w700,
                            ),
                        ),
                    ],
                ),
                const SizedBox(height: 14),
                ...providers.map(
                    (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _Account(
                            provider: p,
                            connected: widget.connected.contains(p.name),
                            onTap: () => _toggle(p),
                        ),
                    ),
                ),
                const SizedBox(height: 12),
                const _InfoBanner(),
            ],
        ),
    );
    void _toggle(_Provider p) {
        setState(
            () => widget.connected.contains(p.name)
                    ? widget.connected.remove(p.name)
                    : widget.connected.add(p.name),
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    widget.connected.contains(p.name)
                            ? '${p.name} connected'
                            : '${p.name} disconnected',
                ),
            ),
        );
    }
}

class SearchPage extends StatelessWidget {
    const SearchPage({super.key});
    @override
    Widget build(BuildContext context) => _Page(
        title: 'Search files',
        subtitle: 'Find anything across your connected clouds.',
        child: Column(
            children: [
                const TextField(
                    decoration: InputDecoration(
                        hintText: 'Search files and folders',
                        prefixIcon: Icon(Icons.search),
                    ),
                ),
                const SizedBox(height: 28),
                const Icon(Icons.search, size: 54, color: Color(0xFFC8CDE0)),
                const SizedBox(height: 12),
                const Text(
                    'Search across all your accounts',
                    style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                const Text(
                    'Your results will appear here.',
                    style: TextStyle(fontSize: 13),
                ),
            ],
        ),
    );
}

class SettingsPage extends StatelessWidget {
    const SettingsPage({super.key});
    @override
    Widget build(BuildContext context) => _Page(
        title: 'Settings',
        subtitle: 'Make My Drive work for you.',
        child: Column(
            children: const [
                ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Account'),
                    subtitle: Text('alex@example.com'),
                    trailing: Icon(Icons.chevron_right),
                ),
                Divider(),
                ListTile(
                    leading: Icon(Icons.notifications_none),
                    title: Text('Notifications'),
                    trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                    leading: Icon(Icons.security_outlined),
                    title: Text('Privacy & security'),
                    trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Help & support'),
                    trailing: Icon(Icons.chevron_right),
                ),
            ],
        ),
    );
}

class _Page extends StatelessWidget {
    const _Page({
        required this.title,
        required this.subtitle,
        required this.child,
    });
    final String title, subtitle;
    final Widget child;
    @override
    Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const _Brand(),
                    const SizedBox(height: 38),
                    Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 7),
                    Text(subtitle),
                    const SizedBox(height: 28),
                    child,
                ],
            ),
        ),
    );
}

class _Tile extends StatelessWidget {
    const _Tile({
        required this.icon,
        required this.title,
        required this.count,
        required this.color,
    });
    final IconData icon;
    final String title, count;
    final Color color;
    @override
    Widget build(BuildContext context) => Expanded(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    CircleAvatar(
                        radius: 20,
                        backgroundColor: color,
                        child: Icon(icon, color: const Color(0xFF4D566B)),
                    ),
                    const SizedBox(height: 14),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(count, style: const TextStyle(fontSize: 12)),
                ],
            ),
        ),
    );
}

class _Provider {
    const _Provider(this.name, this.detail, this.letter, this.color);
    final String name, detail, letter;
    final Color color;
}

class _Account extends StatelessWidget {
    const _Account({
        required this.provider,
        required this.connected,
        required this.onTap,
    });
    final _Provider provider;
    final bool connected;
    final VoidCallback onTap;
    @override
    Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: connected ? const Color(0xFFDAD6FF) : const Color(0xFFE9EBF2),
            ),
        ),
        child: Row(
            children: [
                CircleAvatar(
                    radius: 23,
                    backgroundColor: provider.color.withAlpha(24),
                    child: Text(
                        provider.letter,
                        style: TextStyle(
                            color: provider.color,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                        ),
                    ),
                ),
                const SizedBox(width: 13),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                provider.name,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                                connected ? provider.detail : 'Not connected',
                                style: const TextStyle(fontSize: 12),
                            ),
                        ],
                    ),
                ),
                connected
                        ? const Icon(Icons.check_circle, color: Color(0xFF38B27A))
                        : TextButton(onPressed: onTap, child: const Text('Connect')),
            ],
        ),
    );
}

class _InfoBanner extends StatelessWidget {
    const _InfoBanner();
    @override
    Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xFFEDEBFF),
            borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Icon(Icons.lock_outline, size: 18, color: Color(0xFF6758E8)),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                        'Your files stay with their original cloud provider. My Drive only helps you access them in one place.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF514B89),
                            height: 1.4,
                        ),
                    ),
                ),
            ],
        ),
    );
}

class _Brand extends StatelessWidget {
    const _Brand();
    @override
    Widget build(BuildContext context) => const Row(
        children: [
            CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFFEAE7FF),
                child: Icon(Icons.cloud_done, color: Color(0xFF6758E8), size: 20),
            ),
            SizedBox(width: 10),
            Text(
                'my drive',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                ),
            ),
        ],
    );
}
