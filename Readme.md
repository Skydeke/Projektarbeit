# Projektarbeit zur Embedded Linux Bootzeitoptimierung auf STM32F769I
Dieses Projekt zielt darauf ab, die Bootzeit eines Embedded Linux-Systems auf dem **STM32F769I-Discovery-Board** zu optimieren. Das Projekt verwendet **Buildroot** als Build-System, um ein minimales und optimiertes Linux-Image zu erstellen. Die Optimierungen werden in verschiedenen Bereichen des Bootprozesses vorgenommen, von der Bootloader-Konfiguration bis hin zur Kernel- und Dateisystemoptimierung. Die Methodik basiert auf den Prinzipien, die in den Schulungsunterlagen von Bootlin dargelegt sind.

## Projektstruktur
*   **`buildroot_customisations`**: Dieses Verzeichnis enthält alle Anpassungen für Buildroot.
    **Ziel ist die Erstellung eines minimalen und optimierten Linux-Systems mit Buildroot**.
*   **`Documentation`**: In diesem Verzeichnis befinden sich die LaTeX-Dokumente, die die Projektarbeit und ihre Ergebnisse beschreiben.

## Git Repository
Die Projektdateien sind unter folgender URL verfügbar: `git@github.com:Skydeke/Projektarbeit.git`

## Initial Setup
```
cd buildroot_customisations
make bootstrap
```

