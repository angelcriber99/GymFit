# GymFit

GymFit es una aplicación iOS desarrollada en SwiftUI para el seguimiento y análisis del progreso físico. La aplicación se centra en proporcionar una experiencia intuitiva y detallada para el seguimiento del peso corporal.

## Características

- 📊 Seguimiento detallado del peso corporal
- 📈 Gráficos interactivos y análisis de tendencias
- 📱 Interfaz moderna y atractiva
- 📅 Registro de fechas y pesos
- 📊 Estadísticas detalladas:
  - Peso actual
  - Cambio total
  - Promedio de peso
  - Cambio semanal
  - Peso mínimo y máximo
  - Tendencia general

## Requisitos

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/angelcriber99/GymFit.git
```

2. Abre el proyecto en Xcode:
```bash
cd GymFit
open GymFit.xcodeproj
```

3. Compila y ejecuta el proyecto en tu dispositivo o simulador.

## Estructura del Proyecto

```
GymFit/
├── Models/
│   └── WeightEntry.swift
├── ViewModels/
│   └── WeightStore.swift
├── Views/
│   └── Weight/
│       ├── Components/
│       │   ├── WeightChartView.swift
│       │   ├── WeightEntryForm.swift
│       │   ├── RecentEntriesList.swift
│       │   ├── SelectedEntryDetail.swift
│       │   ├── SummaryCard.swift
│       │   └── MetricItem.swift
│       └── WeightTrackingView.swift
└── GymFitApp.swift
```

## Contribuir

Las contribuciones son bienvenidas. Por favor, abre un issue primero para discutir los cambios que te gustaría hacer.

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles. 