import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/plinko_config.dart';
import '../game/plinko_game.dart';
import '../models/prize_lot.dart';

/// Stockage en mémoire des configs nommées — DEBUG.
/// Persistance : durée de la session Flutter (in-memory).
/// Post-MVP : remplacer par shared_preferences pour persistance entre sessions.
class _ConfigStorage {
  static final Map<String, Map<String, dynamic>> _store = {};

  static void save(String name, {
    required double ballRadius,
    required double pegRadius,
    required double gravity,
    required double pegRestitution,
    required double ballRestitution,
  }) {
    _store[name] = {
      'ballRadius':      ballRadius,
      'pegRadius':       pegRadius,
      'gravity':         gravity,
      'pegRestitution':  pegRestitution,
      'ballRestitution': ballRestitution,
    };
  }

  static Map<String, dynamic>? load(String name) => _store[name];
  static void delete(String name) => _store.remove(name);
  static List<String> get names => _store.keys.toList();
}

/// Représentation locale d'un lot dans l'éditeur.
class _LotRow {
  TextEditingController nameCtrl;
  TextEditingController probCtrl;
  bool isJackpot;
  bool isLoss;

  _LotRow({
    required String name,
    required double probability,
    required this.isJackpot,
    this.isLoss = false,
  }) : nameCtrl = TextEditingController(text: name),
       probCtrl = TextEditingController(text: probability.toStringAsFixed(1));

  double get probability => double.tryParse(probCtrl.text) ?? 0.0;

  void dispose() {
    nameCtrl.dispose();
    probCtrl.dispose();
  }
}

/// Panneau de configuration live — DEBUG uniquement.
/// Permet de tester différentes configs sans relancer le jeu.
class ConfigPanel extends StatefulWidget {
  final PlinkoGame game;
  const ConfigPanel({super.key, required this.game});

  @override
  State<ConfigPanel> createState() => _ConfigPanelState();
}

class _ConfigPanelState extends State<ConfigPanel> {
  // ── Config plateau ───────────────────────────────────────────────────────
  late double _ballRadius;
  late double _pegRadius;
  late double _gravity;
  late double _pegRestitution;
  late double _ballRestitution;

  bool _open = false;

  // ── Sauvegarde configs nommées ───────────────────────────────────────────
  final _saveNameController = TextEditingController();
  List<String> _savedNames = [];

  // ── Table de lots ────────────────────────────────────────────────────────
  List<_LotRow> _lotRows = [];

  @override
  void initState() {
    super.initState();
    _loadFromConfig();
    _savedNames = _ConfigStorage.names;
    _loadLotsFromConfig();
  }

  @override
  void dispose() {
    _saveNameController.dispose();
    for (final row in _lotRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _loadFromConfig() {
    _ballRadius      = PlinkoConfig.ballRadius;
    _pegRadius       = PlinkoConfig.pegRadius;
    _gravity         = PlinkoConfig.gravity;
    _pegRestitution  = PlinkoConfig.pegRestitution;
    _ballRestitution = PlinkoConfig.ballRestitution;
  }

  void _loadLotsFromConfig() {
    for (final row in _lotRows) {
      row.dispose();
    }
    _lotRows = PlinkoConfig.lots
        .map((l) => _LotRow(
              name: l.name,
              probability: l.probability,
              isJackpot: l.isJackpot,
              isLoss: l.isLoss,
            ))
        .toList();
  }

  // ── Stats plateau ────────────────────────────────────────────────────────
  bool get _ballFitsThrough => PlinkoConfig.pegGX > 2 * _pegRadius + 2 * _ballRadius;

  // ── Stats lots ───────────────────────────────────────────────────────────
  double get _totalProb =>
      _lotRows.fold(0.0, (sum, r) => sum + r.probability);
  bool get _lotsValid => (_totalProb - 100.0).abs() < 0.5 && _lotRows.isNotEmpty;

  // ── Actions ──────────────────────────────────────────────────────────────
  void _apply() {
    PlinkoConfig.ballRadius      = _ballRadius;
    PlinkoConfig.pegRadius       = _pegRadius;
    PlinkoConfig.gravity         = _gravity;
    PlinkoConfig.pegRestitution  = _pegRestitution;
    PlinkoConfig.ballRestitution = _ballRestitution;
    widget.game.rebuildBoard();
    setState(() => _open = false);
  }

  void _applyLots() {
    if (!_lotsValid) return;
    PlinkoConfig.lots = _lotRows
        .map((r) => PrizeLot(
              name: r.nameCtrl.text.trim().isEmpty ? '?' : r.nameCtrl.text.trim(),
              probability: r.probability,
              isJackpot: r.isJackpot,
              isLoss: r.isLoss,
            ))
        .toList();
    widget.game.refreshLotLabels();
    setState(() {});
  }

  void _addLot() {
    setState(() {
      _lotRows.add(_LotRow(name: 'Nouveau lot', probability: 0, isJackpot: false));
    });
  }

  void _removeLot(int index) {
    setState(() {
      _lotRows[index].dispose();
      _lotRows.removeAt(index);
    });
  }

  // ── Sauvegarde ───────────────────────────────────────────────────────────
  void _saveConfig() {
    final name = _saveNameController.text.trim();
    if (name.isEmpty) return;
    _ConfigStorage.save(name,
      ballRadius:      _ballRadius,
      pegRadius:       _pegRadius,
      gravity:         _gravity,
      pegRestitution:  _pegRestitution,
      ballRestitution: _ballRestitution,
    );
    setState(() {
      _savedNames = _ConfigStorage.names;
      _saveNameController.clear();
    });
  }

  void _loadSavedConfig(String name) {
    final cfg = _ConfigStorage.load(name);
    if (cfg == null) return;
    setState(() {
      _ballRadius      = (cfg['ballRadius']      as double);
      _pegRadius       = (cfg['pegRadius']      as double);
      _gravity         = (cfg['gravity']        as double);
      _pegRestitution  = (cfg['pegRestitution'] as double);
      _ballRestitution = (cfg['ballRestitution'] as double?) ?? PlinkoConfig.ballRestitution;
    });
  }

  void _deleteSavedConfig(String name) {
    _ConfigStorage.delete(name);
    setState(() => _savedNames = _ConfigStorage.names);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Bouton flottant ────────────────────────────────────────────────
        Positioned(
          top: 16,
          right: 12,
          child: GestureDetector(
            onTap: () => setState(() {
              _open = !_open;
              if (_open) {
                _loadFromConfig();
                _loadLotsFromConfig();
              }
            }),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A14).withOpacity(0.75),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF00D9FF).withOpacity(0.85), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withOpacity(0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                _open ? Icons.close : Icons.menu,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),

        // ── Panneau ────────────────────────────────────────────────────────
        if (_open)
          Positioned(
            top: 64,
            right: 12,
            bottom: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  color: const Color(0xF01a1a30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3a2060)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Section : Config plateau ───────────────────────
                      const Text('⚙ Config plateau',
                          style: TextStyle(color: Color(0xFF00c8ff),
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 10),

                      _slider('🔵 Bille radius', _ballRadius, 0.15, 0.80, 0.05,
                          (v) => setState(() => _ballRadius = v)),
                      _slider('⚪ Picot radius', _pegRadius, 0.10, 0.50, 0.05,
                          (v) => setState(() => _pegRadius = v)),
                      _slider('⬇ Gravité (vitesse)', _gravity, 5.0, 50.0, 1.0,
                          (v) => setState(() => _gravity = v)),
                      _slider('↗ Rebond picot', _pegRestitution, 0.10, 0.90, 0.05,
                          (v) => setState(() => _pegRestitution = v)),
                      _slider('🏀 Rebond bille', _ballRestitution, 0.05, 0.90, 0.05,
                          (v) => setState(() => _ballRestitution = v)),

                      const SizedBox(height: 8),

                      if (!_ballFitsThrough)
                        _warning('⚠ Bille trop grande — ne passe pas entre picots'),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _ballFitsThrough ? _apply : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00c8ff),
                            foregroundColor: const Color(0xFF0a0a18),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Appliquer',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFF3a2060), thickness: 1),
                      const SizedBox(height: 8),

                      // ── Section : Table de lots ─────────────────────────
                      _buildLotTable(),

                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFF3a2060), thickness: 1),
                      const SizedBox(height: 8),

                      // ── Section : Debug ────────────────────────────────
                      const Text('🔧 Debug',
                          style: TextStyle(color: Color(0xFF00c8ff),
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text('Mode physique forcé',
                                style: TextStyle(
                                    color: Color(0xFFaaaacc), fontSize: 11)),
                          ),
                          Switch(
                            value: PlinkoConfig.forcePhysicsMode,
                            onChanged: (v) =>
                                setState(() => PlinkoConfig.forcePhysicsMode = v),
                            activeColor: const Color(0xFFFF8C00),
                            inactiveTrackColor: const Color(0xFF3a2060),
                          ),
                        ],
                      ),
                      if (PlinkoConfig.forcePhysicsMode)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            '⚠ Trajectoires bypassées — résultat aléatoire',
                            style: TextStyle(
                                color: Color(0xFFFF8C00), fontSize: 10),
                          ),
                        ),

                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFF3a2060), thickness: 1),
                      const SizedBox(height: 8),

                      // ── Section : Sauvegarde configs ───────────────────
                      const Text('💾 Configs sauvegardées',
                          style: TextStyle(color: Color(0xFF00c8ff),
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),

                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _saveNameController,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                            decoration: InputDecoration(
                              hintText: 'Nom de la config…',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF555577), fontSize: 11),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF3a2060)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF00c8ff)),
                              ),
                            ),
                            onSubmitted: (_) => _saveConfig(),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _saveConfig,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a1a30),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF00c8ff)),
                            ),
                            child: const Icon(Icons.save,
                                color: Color(0xFF00c8ff), size: 16),
                          ),
                        ),
                      ]),

                      if (_savedNames.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ..._savedNames.map((name) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _loadSavedConfig(name),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111128),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF3a2060)),
                                  ),
                                  child: Text(name,
                                      style: const TextStyle(
                                          color: Color(0xFFccccee), fontSize: 11)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _deleteSavedConfig(name),
                              child: const Icon(Icons.close,
                                  color: Color(0xFF555577), size: 14),
                            ),
                          ]),
                        )),
                      ] else ...[
                        const SizedBox(height: 6),
                        const Text('Aucune config sauvegardée.',
                            style: TextStyle(color: Color(0xFF555577), fontSize: 10)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Table de lots ─────────────────────────────────────────────────────────
  Widget _buildLotTable() {
    final total = _totalProb;
    final totalOk = _lotsValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(children: [
          const Expanded(
            child: Text('🎁 Table de lots',
                style: TextStyle(color: Color(0xFF00c8ff),
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          // Total %
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: totalOk
                  ? const Color(0xFF00ff8820)
                  : const Color(0xFFff444420),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: totalOk
                      ? const Color(0xFF00ff88)
                      : const Color(0xFFff4444)),
            ),
            child: Text(
              '${total.toStringAsFixed(1)}%',
              style: TextStyle(
                color: totalOk
                    ? const Color(0xFF00ff88)
                    : const Color(0xFFff4444),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          'Somme = 100%. Jackpot ⭐ → case centrale.',
          style: const TextStyle(color: Color(0xFF555577), fontSize: 9),
        ),
        const SizedBox(height: 8),

        // En-tête colonnes
        Row(children: const [
          SizedBox(width: 20), // jackpot toggle
          SizedBox(width: 6),
          Expanded(child: Text('Nom', style: TextStyle(color: Color(0xFF7777aa), fontSize: 10))),
          SizedBox(width: 4),
          SizedBox(width: 46, child: Text('%', style: TextStyle(color: Color(0xFF7777aa), fontSize: 10))),
          SizedBox(width: 20), // delete
        ]),
        const SizedBox(height: 4),

        // Lignes de lots
        ..._lotRows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          return _buildLotRow(i, row);
        }),

        const SizedBox(height: 8),

        // Bouton ajouter
        GestureDetector(
          onTap: _addLot,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF111128),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3a2060), style: BorderStyle.solid),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Color(0xFF555577), size: 14),
                SizedBox(width: 4),
                Text('Ajouter un lot',
                    style: TextStyle(color: Color(0xFF555577), fontSize: 11)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Bouton appliquer lots
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _lotsValid ? _applyLots : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7c5cbf),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              disabledBackgroundColor: const Color(0xFF2a2040),
              disabledForegroundColor: const Color(0xFF555577),
            ),
            child: Text(
              _lotsValid ? 'Appliquer les lots' : 'Total ≠ 100%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLotRow(int index, _LotRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          // Toggle jackpot (⭐)
          GestureDetector(
            onTap: () => setState(() => row.isJackpot = !row.isJackpot),
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: row.isJackpot
                    ? const Color(0xFFFFD70030)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: row.isJackpot
                        ? const Color(0xFFFFD700)
                        : const Color(0xFF3a2060)),
              ),
              child: Icon(
                Icons.star,
                size: 12,
                color: row.isJackpot
                    ? const Color(0xFFFFD700)
                    : const Color(0xFF3a2060),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Nom du lot
          Expanded(
            child: TextField(
              controller: row.nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: row.isJackpot
                        ? const Color(0xFFFFD70080)
                        : const Color(0xFF3a2060),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF00c8ff)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Probabilité %
          SizedBox(
            width: 46,
            child: TextField(
              controller: row.probCtrl,
              style: const TextStyle(
                  color: Color(0xFF00c8ff), fontSize: 11,
                  fontWeight: FontWeight.bold),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                suffixText: '%',
                suffixStyle: const TextStyle(color: Color(0xFF555577), fontSize: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF3a2060)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF00c8ff)),
                ),
              ),
              onChanged: (_) => setState(() {}), // refresh total
            ),
          ),
          const SizedBox(width: 4),

          // Supprimer
          GestureDetector(
            onTap: () => _removeLot(index),
            child: const Icon(Icons.close, color: Color(0xFF555577), size: 16),
          ),
        ],
      ),
    );
  }

  // ── Widgets helper ────────────────────────────────────────────────────────
  Widget _slider(String label, double value, double min, double max, double step,
      ValueChanged<double> onChanged, {String suffix = ''}) {
    final display = value.toStringAsFixed(2);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label,
            style: const TextStyle(color: Color(0xFFaaaacc), fontSize: 11))),
        Text('$display$suffix',
            style: const TextStyle(color: Color(0xFF00c8ff), fontSize: 11,
                fontWeight: FontWeight.bold)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: const Color(0xFF00c8ff),
          inactiveTrackColor: const Color(0xFF3a2060),
          thumbColor: const Color(0xFF00c8ff),
          overlayColor: const Color(0x2200c8ff),
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min, max: max,
          divisions: ((max - min) / step).round(),
          onChanged: onChanged,
        ),
      ),
    ]);
  }

  Widget _sliderInt(String label, int value, int min, int max,
      ValueChanged<int> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label,
            style: const TextStyle(color: Color(0xFFaaaacc), fontSize: 11))),
        Text('$value ticks',
            style: const TextStyle(color: Color(0xFF00c8ff), fontSize: 11,
                fontWeight: FontWeight.bold)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: const Color(0xFF00c8ff),
          inactiveTrackColor: const Color(0xFF3a2060),
          thumbColor: const Color(0xFF00c8ff),
          overlayColor: const Color(0x2200c8ff),
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        child: Slider(
          value: value.toDouble(),
          min: min.toDouble(), max: max.toDouble(),
          divisions: max - min,
          onChanged: (v) => onChanged(v.round()),
        ),
      ),
    ]);
  }

  Widget _warning(String msg) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(msg,
        style: const TextStyle(color: Color(0xFFff4444), fontSize: 10)),
  );
}
