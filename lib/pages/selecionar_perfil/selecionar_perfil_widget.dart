import '/features/profiles/child_profile_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela estilo streaming: "Quem está assistindo?".
class SelecionarPerfilWidget extends StatefulWidget {
  const SelecionarPerfilWidget({super.key});

  static const String routeName = 'SelecionarPerfil';
  static const String routePath = '/selecionarPerfil';

  /// Rota antiga "Gerenciar perfis" (mesma tela; evita link quebrado).
  static const String legacyPerfisGerenciarRouteName = 'PerfisGerenciar';
  static const String legacyPerfisGerenciarRoutePath = '/perfisGerenciar';

  @override
  State<SelecionarPerfilWidget> createState() => _SelecionarPerfilWidgetState();
}

class _SelecionarPerfilWidgetState extends State<SelecionarPerfilWidget> {
  List<ChildProfile> _list = [];
  String? _activeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    ChildProfileService.instance.setProfilePickerRouteOpen(true);
    _reload();
  }

  @override
  void dispose() {
    ChildProfileService.instance.setProfilePickerRouteOpen(false);
    super.dispose();
  }

  Future<void> _reload() async {
    final s = ChildProfileService.instance;
    await s.syncActiveProfileWithStoredList();
    final list = await s.loadProfiles();
    final id = await s.activeProfileId();
    if (!mounted) return;
    setState(() {
      _list = list;
      _activeId = id;
      _loading = false;
    });
  }

  Future<void> _select(ChildProfile p) async {
    await ChildProfileService.instance.setActiveProfileId(p.id);
    if (!mounted) return;
    context.safePop();
  }

  Future<void> _rename(ChildProfile p) async {
    final controller = TextEditingController(text: p.name);
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Renomear perfil',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nome da criança',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      );
      if (ok == true && mounted) {
        await ChildProfileService.instance.renameProfile(p.id, controller.text);
        if (mounted) await _reload();
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _remove(ChildProfile p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Remover perfil "${p.name}"?',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remover', style: GoogleFonts.inter(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final removed = await ChildProfileService.instance.removeProfile(p.id);
    if (!removed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crie outro perfil antes de excluir o único.'),
        ),
      );
      return;
    }
    if (mounted) await _reload();
  }

  Future<void> _add() async {
    final name = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Novo perfil'),
          content: TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Nome da criança',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      );
      if (ok == true && mounted) {
        final wasEmpty = _list.isEmpty;
        await ChildProfileService.instance.addProfile(name.text, 0xFF36B4FF);
        if (!mounted) return;
        if (wasEmpty) {
          context.safePop();
          return;
        }
        await _reload();
      }
    } finally {
      name.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tertiary = FlutterFlowTheme.of(context).tertiary;
    final isEmpty = _list.isEmpty;
    // Enquanto [isEmpty] (incl. carregando), bloquear voltar: evita Home sem perfil.
    final mustStay = isEmpty;
    return PopScope(
      canPop: !mustStay,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: mustStay
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white70),
                  onPressed: () => context.safePop(),
                ),
        title: isEmpty
            ? const SizedBox.shrink()
            : Text(
                'Dulang',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: tertiary,
                  letterSpacing: -0.5,
                ),
              ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: _loading ? null : _add,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.add,
                size: 16,
                color: Colors.white.withValues(alpha: 0.45),
              ),
              label: Text(
                'Novo perfil +',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : isEmpty
              ? SafeArea(
                  child: _EmptyWhoIsWatching(
                    onAdd: _add,
                  ),
                )
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Quem está assistindo?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: _list.length + 1,
                          itemBuilder: (context, i) {
                            if (i == _list.length) {
                              return _AddProfileSquareInGrid(
                                onTap: _add,
                              );
                            }
                            final p = _list[i];
                            final active = p.id == _activeId;
                            return _ProfileTile(
                              profile: p,
                              selected: active,
                              canDelete: _list.length > 1,
                              onTap: () => _select(p),
                              onRename: () => _rename(p),
                              onRemove: () => _remove(p),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

/// Tela vazia: título leve, quadrado com + (estilo “adicionar perfil”) e logo discreto.
class _EmptyWhoIsWatching extends StatelessWidget {
  const _EmptyWhoIsWatching({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Quem está assistindo?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 36),
            _AddProfileSquare(
              onTap: onAdd,
              size: 196,
            ),
            const SizedBox(height: 20),
            Text(
              'Toque no quadrado para criar o primeiro perfil',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quadrado com borda e + no centro (estilo “adicionar perfil” de streaming).
class _AddProfileSquare extends StatelessWidget {
  const _AddProfileSquare({
    required this.onTap,
    this.size = 196,
  });

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Semantics(
          label: 'Adicionar novo perfil',
          button: true,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF141414),
              border: Border.all(
                color: Colors.white30,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: size * 0.3,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mesmo padrão no final da grade, alinhado ao tile de perfil.
class _AddProfileSquareInGrid extends StatelessWidget {
  const _AddProfileSquareInGrid({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF141414),
                  border: Border.all(
                    color: Colors.white30,
                    width: 1.2,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, c) {
                    return Center(
                      child: Icon(
                        Icons.add,
                        size: c.maxWidth * 0.3,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Novo perfil',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.selected,
    required this.canDelete,
    required this.onTap,
    required this.onRename,
    required this.onRemove,
  });

  final ChildProfile profile;
  final bool selected;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = Color(profile.colorValue);
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.85),
                              color.withValues(alpha: 0.45),
                            ],
                          ),
                          border: Border.all(
                            color: selected
                                ? FlutterFlowTheme.of(context).tertiary
                                : Colors.white12,
                            width: selected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty
                                ? profile.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: PopupMenuButton<String>(
                        tooltip: 'Opções do perfil',
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        color: const Color(0xFF2A2A2A),
                        onSelected: (value) {
                          if (value == 'rename') onRename();
                          if (value == 'remove') onRemove();
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(
                              'Renomear',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                          if (canDelete)
                            PopupMenuItem(
                              value: 'remove',
                              child: Text(
                                'Excluir',
                                style: GoogleFonts.inter(color: Colors.redAccent),
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Colors.greenAccent : Colors.white24,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
