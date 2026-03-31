/// Modèle de trajectoire pré-calculée.
/// Implémenté en Dev Session 2.
///
/// Une trajectoire = liste de positions (x, y) frame par frame,
/// associée à une case cible et une zone de lancement.
class TrajectoryFrame {
  final double x;
  final double y;
  const TrajectoryFrame(this.x, this.y);

  factory TrajectoryFrame.fromJson(Map<String, dynamic> json) =>
      TrajectoryFrame(json['x'] as double, json['y'] as double);
}

class Trajectory {
  /// Index de la case cible (0–6)
  final int slotIndex;

  /// Index de la zone de lancement (0–4)
  final int zoneIndex;

  /// Point de lancement X exact (en unités physiques)
  final double launchX;

  /// Positions frame par frame
  final List<TrajectoryFrame> frames;

  const Trajectory({
    required this.slotIndex,
    required this.zoneIndex,
    required this.launchX,
    required this.frames,
  });

  factory Trajectory.fromJson(Map<String, dynamic> json) => Trajectory(
        // Supporte les deux formats :
        //   ancien : {"slotIndex": 0, "zoneIndex": 0, "launchX": 1.5, "frames": [{"x":..,"y":..}]}
        //   Python : {"slot": 0, "zone": 0, "frames": [[x, y], ...]}
        slotIndex: (json['slotIndex'] ?? json['slot']) as int,
        zoneIndex: (json['zoneIndex'] ?? json['zone']) as int,
        launchX: json['launchX'] != null
            ? (json['launchX'] as num).toDouble()
            : 0.0,
        frames: (json['frames'] as List).map((f) {
          if (f is List) {
            // Format Python : [x, y]
            return TrajectoryFrame(
              (f[0] as num).toDouble(),
              (f[1] as num).toDouble(),
            );
          }
          // Format ancien : {"x": ..., "y": ...}
          return TrajectoryFrame.fromJson(f as Map<String, dynamic>);
        }).toList(),
      );
}
