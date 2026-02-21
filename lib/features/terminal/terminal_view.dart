import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../connection/providers/connection_provider.dart';
import 'providers/terminal_provider.dart';

class TerminalView extends ConsumerStatefulWidget {
  const TerminalView({super.key});

  @override
  ConsumerState<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends ConsumerState<TerminalView> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendCommand(AppLocalizations l10n) {
    final cmd = _commandController.text.trim();
    if (cmd.isEmpty) return;

    final apiClient = ref.read(apiClientProvider);
    apiClient
        ?.sendCommand(cmd)
        .then((_) {
          _commandController.clear();
          // Optional: add a pseudo-log entry to show we sent it
          // ref.read(terminalProvider.notifier).state = [...ref.read(terminalProvider), 'Send: $cmd'];
        })
        .catchError((err) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.commandFailed}: $err')),
          );
        });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _autoScroll) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(terminalProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Attempt to auto scroll after new logs arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.terminal),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _autoScroll
                  ? Icons.vertical_align_bottom
                  : Icons.pause_circle_filled,
              color: _autoScroll
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            tooltip: _autoScroll
                ? l10n.terminalAutoScrollOn
                : l10n.terminalAutoScrollOff,
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
              if (_autoScroll) _scrollToBottom();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.terminalClear,
            onPressed: () {
              ref.read(terminalProvider.notifier).clearLogs();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Slick dark background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    // Turn off auto-scroll if user scrolls up manually
                    if (notification is ScrollUpdateNotification &&
                        notification.scrollDelta != null &&
                        notification.scrollDelta! < 0) {
                      if (_autoScroll) {
                        setState(() => _autoScroll = false);
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      // Primitive coloring based on starting substrings
                      Color color = Colors.greenAccent;
                      if (log.startsWith('Send:')) color = Colors.blue;
                      if (log.contains('Error') || log.contains('error')) {
                        color = Colors.redAccent;
                      }
                      if (log.startsWith('Recv:')) color = Colors.white70;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: SelectableText(
                          log,
                          style: GoogleFonts.firaCode(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commandController,
                      style: GoogleFonts.firaCode(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.terminalHint,
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          fontFamily: 'sans-serif',
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _sendCommand(l10n),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: theme.colorScheme.onPrimary,
                      onPressed: () => _sendCommand(l10n),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
