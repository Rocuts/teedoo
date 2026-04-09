# Modulo de Optimizacion Fiscal — Diseno Tecnico Completo

**Version**: 1.0
**Fecha**: 30 marzo 2026
**Autor**: Arquitectura TeeDoo
**Estado**: Propuesta tecnica lista para desarrollo

---

## 1. Normativa Espanola Vigente 2026 Relevante para el Modulo

### 1.1 IRPF (Ley 35/2006, modificada por Ley 7/2024)

**Base normativa**: Ley 35/2006, de 28 de noviembre, del IRPF. Reglamento: RD 439/2007.

**Escala estatal general (Art. 63 LIRPF, vigente 2025-2026)**:

| Base liquidable hasta (EUR) | Cuota integra (EUR) | Resto base hasta (EUR) | Tipo (%) |
|---|---|---|---|
| 0 | 0 | 12.450 | 9,50 |
| 12.450 | 1.182,75 | 7.750 | 12,00 |
| 20.200 | 2.112,75 | 15.000 | 15,00 |
| 35.200 | 4.362,75 | 24.800 | 18,50 |
| 60.000 | 8.950,75 | 240.000 | 22,50 |
| 300.000 | 62.950,75 | En adelante | 24,50 |

**Escala estatal del ahorro (Art. 66 LIRPF, modificado por Ley 7/2024)**:

| Base liquidable hasta (EUR) | Tipo (%) |
|---|---|
| 6.000 | 9,50 |
| 6.000 - 50.000 | 10,50 |
| 50.000 - 200.000 | 11,50 |
| 200.000 - 300.000 | 13,50 |
| 300.000 en adelante | 14,00 |

**Reducciones y deducciones clave**:
- **Reduccion por rendimientos del trabajo** (Art. 20 LIRPF): Hasta 6.498 EUR para rentas netas <= 16.825 EUR. Reduccion de 2.000 EUR generica para todos los trabajadores (otros gastos deducibles Art. 19.2.f).
- **Planes de pensiones** (Art. 51-52 LIRPF): Limite maximo de aportacion deducible = 1.500 EUR/ano (individual). Hasta 8.500 EUR adicionales si contribuciones empresariales.
- **Deduccion por maternidad** (Art. 81 LIRPF): 1.200 EUR/ano por hijo < 3 anos para madres trabajadoras. Incremento 1.000 EUR por gastos de guarderia.
- **Familia numerosa** (DA 42 LIRPF): 1.200 EUR (general) o 2.400 EUR (especial).
- **Deduccion por inversion en vivienda habitual**: Solo aplicable a adquisiciones anteriores a 01/01/2013 (regimen transitorio DT 18 LIRPF).

**Gastos deducibles para autonomos en estimacion directa (Art. 28-30 LIRPF + Art. 22 RIRPF)**:
- Suministros de vivienda afecta: 30% de la parte proporcional (Art. 30.2.5.b LIRPF).
- Manutencion en desplazamientos: 26,67 EUR/dia Espana, 48,08 EUR/dia extranjero. Pago electronico obligatorio.
- Primas de seguro de enfermedad: 500 EUR/ano por persona (contribuyente + conyuge + hijos menores 25).
- Amortizaciones segun tablas (Art. 12 LIS por remision).
- Gastos de dificil justificacion: 5% del rendimiento neto, maximo 2.000 EUR (estimacion directa simplificada, Art. 30 LIRPF).

### 1.2 IVA (Ley 37/1992)

**Tipos impositivos vigentes (Art. 90-91 LIVA)**:
- **General**: 21%
- **Reducido**: 10% (alimentos no basicos, transporte viajeros, hosteleria, vivienda nueva, etc.)
- **Superreducido**: 4% (pan, leche, huevos, frutas, verduras, cereales, queso, libros, medicamentos, vivienda VPO)
- **Exento**: Servicios sanitarios, educativos, financieros, seguros (Art. 20 LIVA)

**Requisitos de deducibilidad del IVA soportado (Art. 92-114 LIVA)**:
- Art. 92: Solo deducible IVA soportado en adquisiciones para actividad empresarial/profesional.
- Art. 93: Requisito subjetivo — ser empresario o profesional.
- Art. 94: Operaciones que originan derecho a deduccion (entregas sujetas y no exentas).
- Art. 95: Limitaciones — bienes no afectos a la actividad no deducibles. Vehiculos: presuncion 50% afectacion (Art. 95.Tres.2).
- Art. 96: Exclusiones absolutas — joyas, alimentos, tabaco, espectaculos.
- Art. 97: Requisitos formales — factura completa conforme RD 1619/2012.
- Art. 99: Ejercicio del derecho — plazo 4 anos desde devengo.
- Art. 102-106: **Regla de prorrata** — cuando existen operaciones con y sin derecho a deduccion:
  - Prorrata general (Art. 104): % = (operaciones con derecho / total operaciones) x 100, redondeado al entero superior.
  - Prorrata especial (Art. 106): Deduccion directa por sectores diferenciados.

**Regimenes especiales IVA (Titulo IX LIVA)**:
- Simplificado (Art. 122-123): Para autonomos en modulos. Cuotas por indices/modulos.
- Recargo de equivalencia (Art. 148-163): Comercio minorista. No presentan IVA.
- Agricultura, ganaderia y pesca (Art. 124-134): Compensacion 12%/10,5%.
- Criterio de caja (Art. 163 decies y ss.): Devengo al cobro/pago. Volumen < 2M EUR.

### 1.3 Impuesto sobre Sociedades (Ley 27/2014)

**Tipo general (Art. 29 LIS)**: 25%

**Tipos reducidos (actualizados segun Ley 7/2024, periodos desde 01/01/2025)**:
- **Entidades de nueva creacion** (Art. 29.1 LIS): 15% en primer periodo con base positiva y el siguiente.
- **Entidades de reducida dimension** (Art. 101 LIS, INCN < 10M EUR): **20%** (definitivo desde 2025, antes 25%).
- **Microempresas** (DA 12 LIS, introducida por Ley 7/2024): Cifra de negocios < 1M EUR:
  - 2025: 17% primeros 50.000 EUR BI, 20% resto.
  - **2026: 19% primeros 50.000 EUR BI, 21% resto.**
  - Regimen transitorio hasta 2028.
- **Pymes** (cifra negocios < 10M EUR): 20% + acceso a incentivos del Capitulo XI Titulo VII LIS.
- **Cooperativas fiscalmente protegidas**: 20% (Ley 20/1990).

**Deducciones relevantes**:
- **I+D+i** (Art. 35 LIS): 25% gastos I+D (42% si exceden media 2 anos anteriores). 12% innovacion tecnologica (Art. 36 LIS).
- **Creacion de empleo** (Art. 37 LIS): Trabajadores con discapacidad — 9.000/12.000 EUR por persona.
- **Producciones cinematograficas** (Art. 36.2 LIS): 30% primer millon, 25% exceso.
- **Donativos** (Ley 49/2002): 40% general, 50% si recurrente.

**Incentivos pymes (Art. 101-105 LIS)**:
- **Amortizacion acelerada** (Art. 103 LIS): Coeficiente x 2 de tablas.
- **Reserva de nivelacion** (Art. 105 LIS): Hasta 10% base imponible (max 1M EUR). Permite compensar bases negativas futuras en 5 anos.
- **Reserva de capitalizacion** (Art. 25 LIS): Desde 01/01/2025, reduccion del **20%** (antes 15%) del incremento de fondos propios. Limite: 20% BI positiva (25% para microempresas INCN < 1M EUR). Vinculada a incremento de plantilla media.

**Gastos no deducibles (Art. 15 LIS)**:
- Retribucion fondos propios
- IS propio
- Multas, sanciones, recargos
- Perdidas del juego
- Donativos y liberalidades (con excepciones: relaciones publicas, empleados, promocion)
- Gastos con personas/entidades vinculadas en paraiso fiscal sin sustancia
- Gastos financieros > 30% beneficio operativo (Art. 16 LIS), minimo 1M EUR deducible

### 1.4 Obligaciones de Facturacion

**Reglamento de facturacion**: RD 1619/2012, de 30 de noviembre.

**Contenido obligatorio factura completa (Art. 6 RD 1619/2012)**:
- Numero correlativo y serie
- Fecha de expedicion y operacion (si diferente)
- NIF y datos completos emisor y receptor
- Descripcion operaciones, base imponible, tipo IVA, cuota
- Si exencion: referencia al articulo de exencion

**Factura simplificada (Art. 7 RD 1619/2012)**: Permitida hasta 400 EUR (general) o 3.000 EUR (sectores especificos). No es necesario NIF receptor.

**Facturacion electronica — Ley 18/2022 (Crea y Crece)**:
- Obligacion de factura electronica B2B desde 2026 (empresas > 8M EUR facturacion) y 2027 (resto).
- Formato: Facturae 3.2.x o superior.
- Debe garantizar integridad, autenticidad y legibilidad.

**Verifactu (RD 1007/2023, modificado por RD 254/2025, plazos ampliados por RDL 15/2025)**:
- **Contribuyentes IS**: adaptacion obligatoria desde **1 enero 2027**.
- **Resto de obligados tributarios**: desde **1 julio 2027**.
- Periodo previo (2026): fase de pruebas voluntaria.
- Sujetos en SII estan **exentos** de Verifactu.
- Dos modalidades: VERI*FACTU (envio en tiempo real a AEAT, preferida) o SIF no verificado (hash encadenado, disponible bajo demanda).
- Software debe generar registro con hash encadenado, NIF, fecha, tipo operacion, base, cuota.
- Sanciones por software no conforme: hasta 150.000 EUR (Art. 29.2.j LGT, Ley 11/2021).

**SII — Suministro Inmediato de Informacion (Art. 62.6 RIVA)**:
- Obligados: grandes empresas (> 6M EUR), grupos IVA, inscritos REDEME.
- Envio electronico de registros de facturacion en 4 dias habiles (8 dias en 2026 para primeros 6 meses).
- Libros: emitidas, recibidas, bienes de inversion, operaciones intracomunitarias.

### 1.5 Ley Antifraude (Ley 11/2021)

- **Limite pagos en efectivo** (Art. 7 Ley 7/2012 mod.): 1.000 EUR cuando alguna parte sea empresario/profesional.
- **Prohibicion software doble contabilidad** (Art. 29.2.j LGT): Software debe garantizar integridad, conservacion, accesibilidad, legibilidad, trazabilidad e inalterabilidad de registros.
- **Requisitos sistemas informaticos facturacion**: Deben cumplir especificaciones tecnicas del RD 1007/2023 (Verifactu).

### 1.6 Deducciones Autonomicas Principales

**Madrid (Ley 5/2024 de Presupuestos CM 2025)**:
- Nacimiento/adopcion: 600 EUR (1er hijo), 750 EUR (2do), 900 EUR (3ro y ss.)
- Alquiler vivienda habitual < 35 anos: 30% (max 1.000 EUR). Renta < 25.620 EUR.
- Gastos educativos: 15% ensenanza idiomas, 10% vestuario escolar, 5% escolaridad (max 400-900 EUR).
- Inversion en empresas nueva creacion: 30% (max 6.000 EUR).

**Cataluna**:
- Nacimiento/adopcion: 300 EUR.
- Alquiler vivienda <= 32 anos: Hasta 300 EUR (600 EUR familia numerosa).
- Donativos entidades catalanas: 15%.

**Andalucia (DL 1/2024)**:
- Inversion vivienda habitual protegida: 5% (max 9.040 EUR).
- Alquiler vivienda habitual < 35 anos: 15% (max 600 EUR).
- Gastos de enfermedad: 15% (max 500 EUR individual).

**Comunidad Valenciana**:
- Nacimiento/adopcion: 270 EUR.
- Alquiler < 35 anos: 20% (max 700 EUR).
- Material escolar: 110 EUR/hijo.

### 1.7 Regimenes Especiales

**Estimacion objetiva (modulos) IRPF (Art. 31 LIRPF + OM anual)**:
- Limite: 250.000 EUR ingresos (150.000 EUR si facturan a empresarios).
- 125.000 EUR compras.
- Rendimiento = modulos x unidades. Reduccion general 5% (2025-2026).

**Regimen simplificado IVA (Art. 122 LIVA)**:
- Vinculado a modulos IRPF.
- Cuotas devengadas = indices/modulos.
- Cuota minima: 60% cuotas devengadas por modulos menos cuotas soportadas operaciones corrientes.

---

## 2. Principios Legales y Limites del Sistema

### 2.1 Principios fundamentales

1. **Determinismo fiscal**: Toda decision sobre deducibilidad, aplicabilidad o elegibilidad la toma el motor de reglas, NUNCA la IA generativa.
2. **Trazabilidad normativa**: Cada conclusion vinculada a articulo de ley, real decreto o criterio administrativo concreto.
3. **Versionado temporal**: Las reglas son snapshot por ejercicio fiscal. Cambios normativos mid-year generan nueva version.
4. **Separacion de concerns**: Motor de reglas (determinista) vs. capa de redaccion (OpenAI). Son independientes.
5. **Conservadurismo fiscal**: Ante duda, clasificar como "requiere revision humana" en lugar de afirmar deducibilidad.
6. **Auditabilidad completa**: Input, reglas evaluadas, output, y explicacion IA almacenados con timestamps.

### 2.2 Lo que el sistema SI hace

- Evalua deducibilidad de gastos contra reglas deterministas.
- Detecta oportunidades de optimizacion fiscal verificables.
- Calcula ahorro potencial con formulas explicitas.
- Genera explicaciones legibles via OpenAI (sobre conclusiones ya resueltas).
- Identifica documentacion faltante.
- Clasifica nivel de riesgo y confianza.

### 2.3 Lo que el sistema NO hace

- No sustituye asesoramiento fiscal profesional.
- No presenta declaraciones.
- No toma decisiones en casos ambiguos — los escala.
- No permite que OpenAI determine elegibilidad.
- No inventa base normativa no presente en el motor de reglas.
- No garantiza resultado ante inspeccion (advierte niveles de riesgo).

### 2.4 Niveles de confianza

| Nivel | Significado | Accion |
|---|---|---|
| `confirmed` | Regla aplicable sin ambiguedad, documentacion suficiente | Aplicar automaticamente |
| `likely` | Regla probablemente aplicable, alguna condicion pendiente | Sugerir con advertencia |
| `possible` | Aplicabilidad condicionada o interpretativa | Requiere revision profesional |
| `not_applicable` | Regla no aplica por condiciones excluyentes | Descartar con justificacion |

---

## 3. Arquitectura Funcional

```
                    +-------------------+
                    |  Documentos       |
                    |  Fiscales         |
                    |  (facturas,       |
                    |   gastos, etc.)   |
                    +--------+----------+
                             |
                    +--------v----------+
                    |  1. INGESTA       |
                    |  Normalizacion    |
                    |  Extraccion       |
                    +--------+----------+
                             |
                    +--------v----------+
                    |  2. CLASIFICACION |
                    |  Tipo gasto       |
                    |  Impuesto afecto  |
                    |  CNAE/actividad   |
                    +--------+----------+
                             |
                    +--------v----------+
                    |  3. MOTOR REGLAS  |
                    |  (Determinista)   |
                    |  Evalua cada      |
                    |  regla vs datos   |
                    +--------+----------+
                             |
              +--------------+--------------+
              |                             |
    +---------v---------+      +------------v-----------+
    | 4. SCORING        |      | 5. CALCULO AHORRO     |
    | Riesgo/confianza  |      | Impacto economico     |
    +--------+----------+      +------------+-----------+
              |                             |
              +--------------+--------------+
                             |
                    +--------v----------+
                    | 6. GENERADOR      |
                    |    EXPLICACIONES   |
                    |    (OpenAI API)    |
                    +--------+----------+
                             |
                    +--------v----------+
                    | 7. REPORTE FINAL  |
                    | Resumen ejecutivo |
                    | Hallazgos + trail |
                    +-------------------+
```

### Flujo detallado:

1. **Ingesta**: Recibe facturas (del modelo `Invoice` existente), gastos adicionales, perfil fiscal del cliente (forma juridica, CNAE, CCAA, regimen).
2. **Clasificacion**: Cada documento se clasifica por tipo de gasto (suministros, transporte, profesional, etc.), impuesto afecto (IRPF, IVA, IS) y vinculacion con actividad.
3. **Motor de reglas**: Itera sobre todas las reglas aplicables al ejercicio, tipo de contribuyente y CCAA. Produce evaluaciones deterministas.
4. **Scoring**: Asigna nivel de riesgo (ante inspeccion) y confianza (en la conclusion).
5. **Calculo ahorro**: Estima impacto economico con formulas explicitas por impuesto.
6. **Explicaciones**: Envia al endpoint de OpenAI SOLO los resultados ya resueltos para generar texto legible.
7. **Reporte**: Agrega todo en un informe estructurado con trazabilidad completa.

---

## 4. Arquitectura Tecnica

```
lib/features/fiscal/
  data/
    models/                          # Modelos de datos inmutables
      fiscal_profile.dart            # Perfil fiscal del cliente
      fiscal_rule.dart               # Definicion de regla fiscal
      rule_evaluation.dart           # Resultado de evaluar una regla
      tax_optimization.dart          # Oportunidad detectada
      optimization_report.dart       # Reporte agregado
      expense_classification.dart    # Clasificacion de gasto
      fiscal_config.dart             # Config por ejercicio (tramos, tipos, limites)
    rules/                           # Motor de reglas determinista
      rule_engine.dart               # Evaluador central
      rule_registry.dart             # Registro versionado de reglas
      irpf/
        irpf_rules.dart              # Reglas IRPF
        irpf_autonomo_rules.dart     # Reglas especificas autonomos
        irpf_autonomico_rules.dart   # Deducciones autonomicas
      iva/
        iva_rules.dart               # Reglas IVA generales
        iva_deductibility_rules.dart # Deducibilidad IVA soportado
        iva_regime_rules.dart        # Regimenes especiales IVA
      sociedades/
        is_rules.dart                # Reglas Impuesto Sociedades
        is_pyme_rules.dart           # Incentivos pymes
        is_deductions_rules.dart     # Deducciones IS
      facturacion/
        invoicing_rules.dart         # Requisitos facturacion
        verifactu_rules.dart         # Compliance Verifactu
    datasources/
      fiscal_config_datasource.dart  # Carga config por ejercicio
    repositories/
      fiscal_repository.dart         # Repositorio
  domain/
    fiscal_analyzer.dart             # Orquestador principal
    expense_classifier.dart          # Clasificador de gastos
    savings_calculator.dart          # Calculador de ahorro
    risk_scorer.dart                 # Scoring riesgo/confianza
  providers/
    fiscal_provider.dart             # Riverpod providers
  presentation/
    screens/
      fiscal_screen.dart             # Pantalla principal
      optimization_detail_screen.dart
    widgets/
      savings_summary_panel.dart     # KPIs ahorro
      optimizations_list.dart        # Lista hallazgos
      risk_matrix.dart               # Matriz riesgo
      rule_trace_panel.dart          # Audit trail reglas
      ai_explanation_card.dart       # Texto generado OpenAI

api/fiscal/
  explain.js                         # Serverless fn para OpenAI

lib/core/
  services/
    fiscal_explanation_service.dart   # Cliente que llama a api/fiscal/explain
```

### Stack tecnico:

| Componente | Tecnologia |
|---|---|
| Motor de reglas | Dart puro (client-side, sin dependencias externas) |
| Modelos | Dart inmutable con copyWith (patron existente) |
| Estado | Riverpod AutoDispose |
| API OpenAI | Vercel serverless function (Node.js) |
| Cliente HTTP | DioClient existente con Result<T> |
| Graficos | fl_chart (ya en pubspec) |
| Persistencia reglas | JSON assets versionados por ejercicio |

---

## 5. Modelo de Datos

### 5.1 FiscalProfile

```dart
enum LegalForm { autonomo, sociedadLimitada, sociedadAnonima, cooperativa, comunidadBienes, otra }

enum FiscalRegime { estimacionDirecta, estimacionDirectaSimplificada, estimacionObjetiva, general }

enum IvaRegime { general, simplificado, recargoEquivalencia, criterioCaja, agricultura }

class FiscalProfile {
  final String id;
  final String organizationId;
  final LegalForm legalForm;
  final FiscalRegime fiscalRegime;
  final IvaRegime ivaRegime;
  final String cnae;              // Codigo CNAE actividad
  final String activityDescription;
  final String autonomousCommunity; // "madrid", "cataluna", "andalucia", etc.
  final bool isNewEntity;         // < 2 ejercicios con base positiva
  final double annualTurnover;    // Cifra de negocios
  final int employeeCount;
  final bool isSiiObligated;
  final bool isVerifactuObligated;
  final int fiscalYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FiscalProfile({...});
  FiscalProfile copyWith({...});
}
```

### 5.2 FiscalRule

```dart
enum TaxType { irpf, iva, sociedades, facturacion, general }
enum RiskLevel { low, medium, high, critical }
enum ConfidenceLevel { confirmed, likely, possible, notApplicable }
enum ContributorType { autonomo, sociedad, both }

class FiscalRule {
  final String id;                    // e.g. "IRPF-AUT-001"
  final String name;                  // e.g. "Deduccion suministros vivienda autonomo"
  final int fiscalYear;               // 2026
  final String version;               // "2026-v1"
  final TaxType taxType;
  final ContributorType contributorType;
  final String? autonomousCommunity;  // null = estatal
  final List<String> conditions;      // Condiciones de aplicacion (texto)
  final List<String> exclusions;      // Condiciones excluyentes
  final List<String> formalRequirements;
  final List<String> materialRequirements;
  final List<String> minimumDocumentation;
  final String legalBasis;            // "Art. 30.2.5.b LIRPF"
  final String? administrativeCriteria; // Consulta vinculante DGT si aplica
  final String impactFormula;         // "base_deducible * 0.30 * tipo_marginal"
  final RiskLevel defaultRiskLevel;
  final bool requiresHumanReview;
  final String justificationTemplate; // Template para prompt OpenAI

  const FiscalRule({...});
}
```

### 5.3 RuleEvaluation

```dart
class RuleEvaluation {
  final String id;
  final String ruleId;
  final String ruleName;
  final bool matched;                     // La regla aplica?
  final ConfidenceLevel confidence;
  final RiskLevel riskLevel;
  final Map<String, dynamic> inputSnapshot; // Datos que vio la regla
  final List<String> metConditions;       // Condiciones cumplidas
  final List<String> unmetConditions;     // Condiciones NO cumplidas
  final List<String> missingDocuments;    // Documentacion faltante
  final double? estimatedSavings;         // Ahorro estimado EUR
  final String legalBasis;
  final DateTime evaluatedAt;
  final int durationMs;                   // Tiempo de evaluacion

  const RuleEvaluation({...});
}
```

### 5.4 TaxOptimization

```dart
enum OptimizationStatus { identified, inProgress, applied, dismissed, requiresReview }

class TaxOptimization {
  final String id;
  final String fiscalYear;
  final TaxType taxType;
  final String ruleId;
  final String title;
  final String description;              // Descripcion tecnica determinista
  final String? aiExplanation;           // Texto generado por OpenAI (nullable)
  final bool aiExplanationGenerated;     // Flag explicito
  final double estimatedSavingsEur;
  final ConfidenceLevel confidence;
  final RiskLevel riskLevel;
  final String legalBasis;
  final List<String> requiredActions;    // Que debe hacer el cliente
  final List<String> missingDocuments;
  final List<String> evidenceInvoiceIds; // Facturas que soportan el hallazgo
  final OptimizationStatus status;
  final bool requiresHumanReview;
  final DateTime detectedAt;

  const TaxOptimization({...});
}
```

### 5.5 OptimizationReport

```dart
class OptimizationReport {
  final String id;
  final String fiscalProfileId;
  final int fiscalYear;
  final String ruleSetVersion;          // Version del set de reglas usado
  final DateTime generatedAt;
  final List<TaxOptimization> optimizations;
  final List<RuleEvaluation> allEvaluations; // TODAS las reglas evaluadas (audit)
  final ReportSummary summary;

  const OptimizationReport({...});
}

class ReportSummary {
  final double totalEstimatedSavings;
  final int totalOptimizations;
  final int confirmedCount;
  final int likelyCount;
  final int possibleCount;
  final int requiresReviewCount;
  final Map<TaxType, double> savingsByTax; // Ahorro por impuesto
  final int totalRulesEvaluated;
  final int totalRulesMatched;

  const ReportSummary({...});
}
```

### 5.6 ExpenseClassification

```dart
enum ExpenseCategory {
  suministros,        // Luz, agua, gas, internet, telefono
  alquiler,           // Alquiler local/oficina
  transporte,         // Combustible, peajes, transporte publico
  vehiculo,           // Adquisicion, leasing, renting vehiculo
  profesional,        // Honorarios profesionales externos
  personal,           // Gastos de personal, nominas
  materialOficina,    // Papeleria, consumibles
  tecnologia,         // Hardware, software, SaaS
  formacion,          // Cursos, conferencias
  marketing,          // Publicidad, RRPP
  seguros,            // Primas de seguro
  financieros,        // Intereses, comisiones bancarias
  amortizacion,       // Amortizacion bienes
  representacion,     // Comidas, regalos clientes
  manutencion,        // Dietas en desplazamientos
  reparaciones,       // Mantenimiento y reparaciones
  tributos,           // Otros impuestos y tasas (IBI, IAE)
  otros,
}

enum Deductibility { deductible, notDeductible, partiallyDeductible, requiresReview }

class ExpenseClassification {
  final String invoiceId;
  final ExpenseCategory category;
  final Deductibility deductibility;
  final double deductiblePercentage;    // 0.0 a 1.0
  final TaxType affectedTax;
  final String reason;                   // Razon determinista
  final String legalBasis;
  final RiskLevel riskLevel;
  final List<String> missingRequirements;

  const ExpenseClassification({...});
}
```

---

## 6. Diseno del Motor de Reglas

### 6.1 Estructura de una regla

Cada regla implementa la interfaz:

```dart
abstract class IFiscalRule {
  String get id;
  String get name;
  int get fiscalYear;
  TaxType get taxType;
  ContributorType get contributorType;
  String? get autonomousCommunity;
  String get legalBasis;

  /// Evalua si la regla aplica dado el contexto.
  /// Retorna RuleEvaluation con matched=true/false y toda la traza.
  RuleEvaluation evaluate(FiscalContext context);
}
```

### 6.2 FiscalContext

```dart
class FiscalContext {
  final FiscalProfile profile;
  final List<Invoice> invoices;          // Facturas del ejercicio
  final List<Invoice> receivedInvoices;  // Facturas recibidas (gastos)
  final double totalIncome;
  final double totalExpenses;
  final Map<ExpenseCategory, double> expensesByCategory;
  final Map<String, ExpenseClassification> classifications;
  final int fiscalYear;
  final DateTime analysisDate;

  const FiscalContext({...});
}
```

### 6.3 Ejemplo de regla concreta

```dart
/// IRPF-AUT-001: Deduccion gastos suministros vivienda afecta (Art. 30.2.5.b LIRPF)
class DeduccionSuministrosViviendaRule implements IFiscalRule {
  @override String get id => 'IRPF-AUT-001';
  @override String get name => 'Deduccion suministros vivienda afecta';
  @override int get fiscalYear => 2026;
  @override TaxType get taxType => TaxType.irpf;
  @override ContributorType get contributorType => ContributorType.autonomo;
  @override String? get autonomousCommunity => null; // Estatal
  @override String get legalBasis => 'Art. 30.2.5.b Ley 35/2006 IRPF';

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final start = DateTime.now();
    final metConditions = <String>[];
    final unmetConditions = <String>[];
    final missingDocs = <String>[];

    // Condicion 1: Debe ser autonomo
    if (context.profile.legalForm == LegalForm.autonomo) {
      metConditions.add('Contribuyente es autonomo persona fisica');
    } else {
      unmetConditions.add('Solo aplicable a autonomos persona fisica');
      return _buildResult(false, ConfidenceLevel.notApplicable,
          metConditions, unmetConditions, missingDocs, null, start);
    }

    // Condicion 2: Debe estar en estimacion directa
    if (context.profile.fiscalRegime == FiscalRegime.estimacionDirecta ||
        context.profile.fiscalRegime == FiscalRegime.estimacionDirectaSimplificada) {
      metConditions.add('Regimen de estimacion directa');
    } else {
      unmetConditions.add('Requiere estimacion directa (no modulos)');
      return _buildResult(false, ConfidenceLevel.notApplicable,
          metConditions, unmetConditions, missingDocs, null, start);
    }

    // Condicion 3: Debe haber gastos de suministros
    final suministros = context.expensesByCategory[ExpenseCategory.suministros] ?? 0;
    if (suministros > 0) {
      metConditions.add('Existen gastos de suministros: ${suministros.toStringAsFixed(2)} EUR');
    } else {
      unmetConditions.add('No se detectan gastos de suministros');
      return _buildResult(false, ConfidenceLevel.notApplicable,
          metConditions, unmetConditions, missingDocs, null, start);
    }

    // Requisito formal: facturas de suministros a nombre del contribuyente
    missingDocs.add('Facturas suministros a nombre del titular');
    missingDocs.add('Declaracion censal con porcentaje afectacion vivienda');

    // Calculo ahorro: 30% de la parte proporcional x tipo marginal estimado
    // Asumimos afectacion del 30% (la ley dice "proporcion declarada")
    final baseDeducible = suministros * 0.30;
    final tipoMarginal = _estimarTipoMarginal(context.totalIncome - context.totalExpenses);
    final ahorro = baseDeducible * tipoMarginal;

    metConditions.add('Base deducible estimada: ${baseDeducible.toStringAsFixed(2)} EUR (30% de suministros)');

    return _buildResult(true, ConfidenceLevel.likely,
        metConditions, unmetConditions, missingDocs, ahorro, start);
  }

  double _estimarTipoMarginal(double baseImponible) {
    // Escala estatal + autonomica aproximada
    if (baseImponible <= 12450) return 0.19;
    if (baseImponible <= 20200) return 0.24;
    if (baseImponible <= 35200) return 0.30;
    if (baseImponible <= 60000) return 0.37;
    if (baseImponible <= 300000) return 0.45;
    return 0.47;
  }

  RuleEvaluation _buildResult(bool matched, ConfidenceLevel confidence,
      List<String> met, List<String> unmet, List<String> docs,
      double? savings, DateTime start) {
    return RuleEvaluation(
      id: 'eval_${DateTime.now().millisecondsSinceEpoch}',
      ruleId: id,
      ruleName: name,
      matched: matched,
      confidence: confidence,
      riskLevel: RiskLevel.low,
      inputSnapshot: {}, // Se llena con datos relevantes
      metConditions: met,
      unmetConditions: unmet,
      missingDocuments: docs,
      estimatedSavings: savings,
      legalBasis: legalBasis,
      evaluatedAt: DateTime.now(),
      durationMs: DateTime.now().difference(start).inMilliseconds,
    );
  }
}
```

### 6.4 Registro de reglas

```dart
class RuleRegistry {
  static final Map<int, List<IFiscalRule>> _rules = {
    2026: [
      // IRPF Autonomos
      DeduccionSuministrosViviendaRule(),
      DeduccionMantenimientoDesplazamientoRule(),
      DeduccionSeguroEnfermedadRule(),
      DeduccionAmortizacionesRule(),
      GastosDificilJustificacionRule(),
      ReduccionRendimientoTrabajoRule(),
      RetencionAutonomoNuevoRule(),

      // IVA
      IvaDeducibilidadGastoRule(),
      IvaVehiculoAfectacionRule(),
      IvaProrataRule(),
      IvaRegimenOptimizacionRule(),
      IvaCriterioCajaRule(),

      // Impuesto Sociedades
      TipoReducidoNuevaEntidadRule(),
      TipoReducidoMicroempresaRule(),
      ReservaCapitalizacionRule(),
      ReservaNivelacionRule(),
      AmortizacionAceleradaPymeRule(),
      DeduccionIDiRule(),
      GastosNoDeduciblesISRule(),
      LimitacionGastosFinancierosRule(),

      // Facturacion
      RequisitosFormalessFacturaRule(),
      FacturaSimplificadaLimiteRule(),
      ObligacionSIIRule(),
      ObligacionVerifactuRule(),
      NumeracionCorrelativaRule(),

      // Autonomicas (Madrid)
      MadridNacimientoAdopcionRule(),
      MadridAlquilerJovenesRule(),
      MadridGastosEducativosRule(),
      MadridInversionEmpresasRule(),
      // ... mas CCAA
    ],
  };

  static List<IFiscalRule> getRules(int fiscalYear) => _rules[fiscalYear] ?? [];

  static List<IFiscalRule> getFilteredRules({
    required int fiscalYear,
    required ContributorType contributorType,
    String? autonomousCommunity,
  }) {
    return getRules(fiscalYear).where((r) {
      if (r.contributorType != ContributorType.both && r.contributorType != contributorType) return false;
      if (r.autonomousCommunity != null && r.autonomousCommunity != autonomousCommunity) return true;
      return true;
    }).toList();
  }
}
```

---

## 7. Diseno del Flujo de Procesamiento

### Pipeline paso a paso:

```
Paso 1: CONSTRUIR CONTEXTO FISCAL
  Input:  FiscalProfile + Invoice[] del ejercicio
  Output: FiscalContext (con totales, clasificaciones, etc.)

Paso 2: CLASIFICAR GASTOS
  Input:  Cada Invoice recibida
  Output: ExpenseClassification por factura
  Logica: Mapear descripcion/categoria -> ExpenseCategory
          Evaluar requisitos formales basicos

Paso 3: OBTENER REGLAS APLICABLES
  Input:  FiscalYear + ContributorType + AutonomousCommunity
  Output: List<IFiscalRule> filtradas

Paso 4: EVALUAR CADA REGLA
  Input:  FiscalContext + IFiscalRule
  Output: RuleEvaluation (matched/not, conditions, savings)
  Logica: Determinista. Cada regla evalua sus condiciones.

Paso 5: SCORING DE RIESGO Y CONFIANZA
  Input:  List<RuleEvaluation> donde matched=true
  Output: RiskLevel + ConfidenceLevel ajustados
  Logica: Cruza documentacion faltante, condiciones no verificables,
          historico de criterios AEAT

Paso 6: CALCULAR AHORRO POTENCIAL
  Input:  List<RuleEvaluation> donde matched=true
  Output: Ahorro por optimizacion y total
  Logica: Aplica formula de impacto de cada regla

Paso 7: GENERAR OPTIMIZACIONES
  Input:  RuleEvaluations matched + scoring + ahorro
  Output: List<TaxOptimization> (sin aiExplanation aun)

Paso 8: GENERAR EXPLICACIONES (ASYNC, OpenAI)
  Input:  Cada TaxOptimization
  Output: TaxOptimization con aiExplanation populated
  Logica: Llama a api/fiscal/explain con datos estructurados

Paso 9: ENSAMBLAR REPORTE
  Input:  Todo lo anterior
  Output: OptimizationReport completo
```

---

## 8. Diseno de la Capa OpenAI API para Justificaciones

### 8.1 Arquitectura de integracion

```
Flutter App                         Vercel Serverless
+-----------------------+          +-------------------------+
| fiscal_analyzer.dart  |          | api/fiscal/explain.js   |
|                       |   HTTP   |                         |
| Envia:                +--------->+ Recibe payload          |
| - optimization data   |          | Construye prompt        |
| - rule evaluation     |          | Llama OpenAI Chat API   |
| - legal basis         |          | Valida respuesta        |
|                       |<---------+ Retorna explicacion     |
| Recibe:               |          |                         |
| - aiExplanation text  |          | Almacena log            |
| - validation result   |          +-------------------------+
+-----------------------+                    |
                                    +--------v--------+
                                    | OpenAI API      |
                                    | gpt-4o-mini     |
                                    | temperature=0.1 |
                                    | response_format |
                                    +-----------------+
```

### 8.2 Cuando se llama a OpenAI

- **Momento**: DESPUES de que el motor de reglas haya evaluado TODAS las reglas y generado las optimizaciones.
- **Trigger**: El usuario pulsa "Generar explicaciones" o se ejecuta automaticamente post-analisis.
- **Frecuencia**: Una llamada por optimizacion detectada. Batch de hasta 5 en paralelo.
- **Fallback**: Si OpenAI falla, la optimizacion se entrega sin `aiExplanation` (el campo es nullable). La funcionalidad no se degrada.

### 8.3 Que parte del sistema llama

- `FiscalExplanationService` (en `lib/core/services/`) hace POST a `/api/fiscal/explain`.
- La serverless function `api/fiscal/explain.js` es la unica que tiene el API key de OpenAI.
- El servicio Dart NUNCA tiene acceso directo al API key.

---

## 9. Prompting Strategy para OpenAI

### 9.1 System Prompt

```
Eres un redactor fiscal profesional especializado en normativa tributaria espanola.
Tu UNICA funcion es transformar hallazgos fiscales ya determinados por un sistema
automatizado en explicaciones claras, profesionales y comprensibles.

REGLAS ABSOLUTAS:
1. NO determines si una deduccion aplica o no. Esa decision ya fue tomada.
2. NO inventes articulos de ley, consultas vinculantes o criterios no presentes en el input.
3. NO agregues recomendaciones fiscales mas alla de las indicadas en "required_actions".
4. SOLO usa la base normativa proporcionada en "legal_basis".
5. Si el input dice que algo "requiere revision humana", di exactamente eso.
6. Usa tono formal pero comprensible para un empresario no especialista.
7. Estructura la explicacion con: que se detecto, por que aplica/no aplica,
   base legal, ahorro estimado, y proximos pasos.
8. Responde SIEMPRE en espanol de Espana.
9. NO uses emojis.
10. Si no puedes generar una explicacion fiel al input, responde con
    "explanation_possible": false y explica por que en "rejection_reason".
```

### 9.2 User Prompt Template

```
Genera una justificacion fiscal profesional para el siguiente hallazgo:

TIPO DE JUSTIFICACION: {justification_type}
TITULO: {title}
DESCRIPCION TECNICA: {description}
IMPUESTO AFECTADO: {tax_type}
BASE NORMATIVA: {legal_basis}
CRITERIO ADMINISTRATIVO: {administrative_criteria}
CONFIANZA: {confidence_level}
RIESGO: {risk_level}
AHORRO ESTIMADO: {estimated_savings} EUR
CONDICIONES CUMPLIDAS:
{met_conditions}
CONDICIONES NO CUMPLIDAS:
{unmet_conditions}
DOCUMENTACION FALTANTE:
{missing_documents}
ACCIONES REQUERIDAS:
{required_actions}
REQUIERE REVISION HUMANA: {requires_human_review}

Responde en el formato JSON especificado.
```

### 9.3 Tipos de justificacion (`justification_type`)

| Tipo | Descripcion |
|---|---|
| `deduction_accepted` | Deduccion aceptada/confirmada |
| `deduction_rejected` | Deduccion rechazada/no aplicable |
| `savings_opportunity` | Oportunidad de ahorro detectada |
| `fiscal_risk_alert` | Alerta de riesgo fiscal |
| `missing_documentation` | Solicitud documentacion faltante |
| `executive_summary` | Resumen ejecutivo para cliente |

---

## 10. Estructura JSON de Entrada al Generador de Justificaciones

```json
{
  "request_id": "req_20260330_001",
  "fiscal_year": 2026,
  "justification_type": "savings_opportunity",
  "optimization": {
    "id": "opt_001",
    "rule_id": "IRPF-AUT-001",
    "title": "Deduccion suministros vivienda afecta al 30%",
    "description": "El contribuyente autonomo puede deducir el 30% de la parte proporcional de los gastos de suministros de la vivienda habitual que esta parcialmente afecta a la actividad economica.",
    "tax_type": "irpf",
    "legal_basis": "Art. 30.2.5.b Ley 35/2006 IRPF",
    "administrative_criteria": null,
    "confidence": "likely",
    "risk_level": "low",
    "estimated_savings_eur": 847.50,
    "met_conditions": [
      "Contribuyente es autonomo persona fisica",
      "Regimen de estimacion directa simplificada",
      "Gastos de suministros detectados: 9.416,67 EUR anuales"
    ],
    "unmet_conditions": [],
    "missing_documents": [
      "Facturas suministros a nombre del titular",
      "Declaracion censal modelo 036/037 con porcentaje afectacion"
    ],
    "required_actions": [
      "Verificar que las facturas de suministros estan a nombre del contribuyente",
      "Confirmar porcentaje de afectacion de la vivienda en modelo 036/037",
      "Conservar facturas y justificantes de pago"
    ],
    "requires_human_review": false
  },
  "client_context": {
    "legal_form": "autonomo",
    "activity": "Desarrollo de software (CNAE 6201)",
    "autonomous_community": "madrid",
    "fiscal_regime": "estimacion_directa_simplificada"
  }
}
```

---

## 11. Estructura JSON de Salida Esperada del Generador

```json
{
  "request_id": "req_20260330_001",
  "optimization_id": "opt_001",
  "explanation_possible": true,
  "rejection_reason": null,
  "explanation": {
    "summary": "Se ha detectado una oportunidad de ahorro fiscal de 847,50 EUR en su declaracion de IRPF mediante la deduccion de los gastos de suministros de su vivienda habitual afecta a la actividad profesional.",
    "detail": "Como profesional autonomo en estimacion directa simplificada, tiene derecho a deducir el 30% de la parte proporcional de los gastos de suministros (electricidad, agua, gas, telefono, internet) de su vivienda habitual, en la medida en que esta se encuentre parcialmente afecta a su actividad economica de desarrollo de software.\n\nDe acuerdo con el articulo 30.2.5.b de la Ley 35/2006 del IRPF, la parte deducible se calcula aplicando el 30% sobre la proporcion de la vivienda destinada a la actividad, segun lo declarado en su modelo censal 036 o 037.\n\nEn su caso, con gastos de suministros anuales de 9.416,67 EUR, la base deducible estimada asciende a 2.825,00 EUR, lo que genera un ahorro fiscal aproximado de 847,50 EUR en funcion de su tipo marginal.",
    "legal_reference": "Articulo 30.2.5.b de la Ley 35/2006, de 28 de noviembre, del Impuesto sobre la Renta de las Personas Fisicas.",
    "next_steps": "Para aplicar esta deduccion correctamente, debera: (1) verificar que las facturas de suministros figuran a nombre del titular de la actividad; (2) confirmar que su declaracion censal (modelo 036/037) refleja el porcentaje de afectacion de la vivienda; y (3) conservar toda la documentacion justificativa.",
    "confidence_note": "Esta optimizacion se considera probable. Se recomienda confirmar el porcentaje exacto de afectacion de la vivienda declarado ante la AEAT.",
    "disclaimer": "Este analisis es orientativo y no sustituye el asesoramiento fiscal profesional. Los resultados estan basados en la normativa vigente a fecha de analisis."
  },
  "metadata": {
    "model": "gpt-4o-mini",
    "model_version": "2026-01-25",
    "tokens_used": 487,
    "generation_time_ms": 1230
  }
}
```

---

## 12. Validaciones y Controles Anti-Alucinacion

### 12.1 Validaciones pre-envio (antes de llamar a OpenAI)

1. **Completitud del payload**: Verificar que todos los campos obligatorios estan presentes.
2. **Coherencia interna**: `confidence` y `risk_level` deben ser consistentes con `met_conditions` y `unmet_conditions`.
3. **Base legal presente**: `legal_basis` no puede estar vacio.

### 12.2 Validaciones post-respuesta (despues de recibir de OpenAI)

```javascript
function validateExplanation(input, output) {
  const errors = [];

  // 1. Verificar que la base legal citada esta en el input
  const inputLegalBasis = input.optimization.legal_basis.toLowerCase();
  const outputLegalRef = output.explanation.legal_reference.toLowerCase();
  if (!outputLegalRef.includes(inputLegalBasis.split(' ')[0])) {
    errors.push('LEGAL_BASIS_MISMATCH: La referencia legal no coincide con el input');
  }

  // 2. Verificar que no se inventan articulos nuevos
  const legalPattern = /art[ií]culo?\s+\d+/gi;
  const outputArticles = outputLegalRef.match(legalPattern) || [];
  const inputArticles = inputLegalBasis.match(legalPattern) || [];
  const inventedArticles = outputArticles.filter(a =>
    !inputArticles.some(ia => ia.toLowerCase() === a.toLowerCase())
  );
  if (inventedArticles.length > 0) {
    errors.push(`HALLUCINATED_ARTICLES: Articulos no presentes en input: ${inventedArticles.join(', ')}`);
  }

  // 3. Verificar coherencia de la conclusion
  if (input.optimization.confidence === 'not_applicable' &&
      !output.explanation.summary.includes('no aplica')) {
    errors.push('CONFIDENCE_MISMATCH: Input dice no aplicable pero explicacion no lo refleja');
  }

  // 4. Verificar que el ahorro citado coincide
  const inputSavings = input.optimization.estimated_savings_eur;
  const summaryHasSavings = output.explanation.summary.includes(
    inputSavings.toFixed(2).replace('.', ',')
  );
  if (inputSavings > 0 && !summaryHasSavings) {
    errors.push('SAVINGS_MISMATCH: El ahorro en la explicacion no coincide con el input');
  }

  // 5. Verificar que requires_human_review se respeta
  if (input.optimization.requires_human_review &&
      !output.explanation.detail.toLowerCase().includes('revision profesional') &&
      !output.explanation.detail.toLowerCase().includes('revision humana')) {
    errors.push('REVIEW_FLAG_IGNORED: Se requiere revision humana pero la explicacion no lo menciona');
  }

  // 6. Verificar que no hay recomendaciones fuera de required_actions
  // (heuristico: buscar verbos imperativos no presentes en las acciones)

  return {
    valid: errors.length === 0,
    errors,
    severity: errors.some(e => e.startsWith('HALLUCINATED')) ? 'critical' : 'warning'
  };
}
```

### 12.3 Estrategia de rechazo y reintento

| Tipo de error | Accion |
|---|---|
| `HALLUCINATED_ARTICLES` | **RECHAZAR**. No usar la explicacion. Log completo. Reintentar 1 vez con prompt reforzado. |
| `LEGAL_BASIS_MISMATCH` | **RECHAZAR**. Reintentar con instruccion explicita de citar solo la base del input. |
| `CONFIDENCE_MISMATCH` | **RECHAZAR**. Reintentar. |
| `SAVINGS_MISMATCH` | **ADVERTIR**. Usar pero agregar nota "[Cifra de ahorro verificada por el sistema: X EUR]". |
| `REVIEW_FLAG_IGNORED` | **ADVERTIR**. Inyectar parrafo: "Este hallazgo requiere validacion por un profesional fiscal." |
| OpenAI timeout/error | Entregar optimizacion sin `aiExplanation`. No bloquear el flujo. |
| 2 reintentos fallidos | Marcar `aiExplanation = null`, `aiExplanationGenerated = false`. |

---

## 13. Logica de Calculo del Ahorro Potencial

### 13.1 Formulas por impuesto

**IRPF (autonomo, estimacion directa)**:
```
ahorro_irpf = base_deducible * tipo_marginal_estimado
```
Donde `tipo_marginal_estimado` se calcula aplicando la escala estatal + autonomica a la base imponible general estimada.

**IVA**:
```
ahorro_iva = iva_soportado_no_deducido_actualmente - iva_soportado_no_deducible
```
Es decir, IVA que el cliente NO esta deduciendo pero PODRIA deducir legitimamente.

**Impuesto sobre Sociedades**:
```
ahorro_is = base_imponible_reducida * tipo_is - base_imponible_actual * tipo_is
```
Donde `base_imponible_reducida` incorpora las reducciones/deducciones detectadas (reserva capitalizacion, nivelacion, etc.)

### 13.2 Ejemplo concreto

Autonomo en Madrid, CNAE 6201, estimacion directa simplificada:
- Ingresos: 85.000 EUR
- Gastos declarados: 22.000 EUR
- Suministros vivienda: 9.416 EUR (actualmente NO deduce nada)

```
Base deducible suministros = 9.416 * 0.30 = 2.825 EUR
Base imponible estimada = 85.000 - 22.000 = 63.000 EUR
Tipo marginal a 63.000 EUR = ~37% (estatal 22,5% + autonomico ~14,5%)
Ahorro = 2.825 * 0.37 = 1.045,25 EUR
```

---

## 14. Sistema de Scoring de Riesgo y Confianza

### 14.1 Scoring de riesgo

```dart
RiskLevel computeRisk(RuleEvaluation eval) {
  int score = 0;

  // +2 por cada documento faltante
  score += eval.missingDocuments.length * 2;

  // +3 si hay condiciones no cumplidas pero la regla matched (caso "likely")
  if (eval.matched && eval.unmetConditions.isNotEmpty) score += 3;

  // +5 si es un gasto de representacion o mixto personal/profesional
  // (mayor escrutinio en inspecciones)
  if (_isHighScrutinyCategory(eval)) score += 5;

  // +3 si la deduccion excede umbrales habituales
  if ((eval.estimatedSavings ?? 0) > 5000) score += 3;

  // +2 si no hay criterio administrativo que respalde
  if (eval.legalBasis.contains('DGT') == false) score += 1;

  if (score <= 2) return RiskLevel.low;
  if (score <= 5) return RiskLevel.medium;
  if (score <= 8) return RiskLevel.high;
  return RiskLevel.critical;
}
```

### 14.2 Scoring de confianza

```dart
ConfidenceLevel computeConfidence(RuleEvaluation eval) {
  if (!eval.matched) return ConfidenceLevel.notApplicable;

  if (eval.unmetConditions.isEmpty && eval.missingDocuments.isEmpty) {
    return ConfidenceLevel.confirmed;
  }

  if (eval.unmetConditions.isEmpty && eval.missingDocuments.isNotEmpty) {
    return ConfidenceLevel.likely; // Aplica pero falta documentacion
  }

  if (eval.unmetConditions.length <= 1) {
    return ConfidenceLevel.possible;
  }

  return ConfidenceLevel.possible; // Multiples condiciones pendientes
}
```

---

## 15. Formato de Salida para Frontend

```dart
/// Estructura para mostrar en la pantalla fiscal del Flutter app.
class FiscalScreenData {
  // KPI Cards (arriba)
  final double totalSavings;
  final int optimizationsCount;
  final int confirmedCount;
  final int requiresReviewCount;

  // Ahorro por impuesto (grafico barras)
  final double irpfSavings;
  final double ivaSavings;
  final double isSavings;

  // Lista de optimizaciones (ordenadas por ahorro desc)
  final List<TaxOptimization> optimizations;

  // Matriz de riesgo
  final Map<RiskLevel, int> riskDistribution;
}
```

---

## 16. Formato de Salida para Reporte Tecnico / Auditoria

```json
{
  "report_id": "RPT-2026-001",
  "generated_at": "2026-03-30T15:30:00Z",
  "fiscal_year": 2026,
  "rule_set_version": "2026-v1",
  "profile": { "...": "FiscalProfile completo" },
  "summary": {
    "total_rules_evaluated": 32,
    "total_rules_matched": 8,
    "total_estimated_savings": 4235.75,
    "savings_by_tax": { "irpf": 2847.50, "iva": 1020.25, "sociedades": 368.00 },
    "confidence_distribution": { "confirmed": 3, "likely": 4, "possible": 1 },
    "risk_distribution": { "low": 5, "medium": 2, "high": 1 }
  },
  "optimizations": [ "...List<TaxOptimization> con aiExplanation" ],
  "audit_trail": {
    "all_evaluations": [ "...List<RuleEvaluation> completa" ],
    "openai_calls": [
      {
        "request_id": "req_001",
        "optimization_id": "opt_001",
        "prompt_hash": "sha256:abc123...",
        "response_hash": "sha256:def456...",
        "model": "gpt-4o-mini",
        "tokens_used": 487,
        "validation_result": { "valid": true, "errors": [] },
        "timestamp": "2026-03-30T15:30:05Z"
      }
    ]
  },
  "disclaimers": [
    "Este analisis es orientativo y no sustituye asesoramiento fiscal profesional.",
    "Basado en normativa vigente a 30/03/2026.",
    "Las explicaciones marcadas con [IA] fueron generadas por modelo de lenguaje."
  ]
}
```

---

## 17. Edge Cases y Limitaciones

### 17.1 Facturas sin requisitos formales

- **Deteccion**: Regla `RequisitosFormalessFacturaRule` verifica campos obligatorios del Art. 6 RD 1619/2012.
- **Accion**: Clasificar como `Deductibility.requiresReview`. Generar alerta de documentacion faltante.
- **IVA**: Sin factura completa NO es deducible el IVA soportado (Art. 97 LIVA). Riesgo = HIGH.

### 17.2 Gastos parcialmente afectos

- **Vehiculos**: Presuncion 50% afectacion (Art. 95.Tres.2 LIVA). Solo 50% IVA deducible salvo prueba en contrario.
- **Vivienda**: Proporcion declarada en 036/037. Suministros al 30% de esa proporcion.
- **Telefono**: Afectacion mixta. Recomendacion: linea separada o estimacion razonada.
- **Calculo**: `deductible_amount = total * affectation_percentage`.

### 17.3 Gastos uso mixto personal/profesional

- Sistema clasifica como `partiallyDeductible` con `deductiblePercentage` < 1.0.
- Risk = MEDIUM automaticamente (mayor escrutinio AEAT).
- Siempre genera recomendacion de documentar la proporcion profesional.

### 17.4 Autonomos vs Sociedades

| Aspecto | Autonomo | Sociedad |
|---|---|---|
| Impuesto renta | IRPF (hasta 47%) | IS (25%/15%/17%) |
| Deduccion suministros | Art. 30.2.5.b (30%) | Gasto de la sociedad si local afecto |
| Vehiculo | 50% IVA presuncion | 50% IVA presuncion |
| Gastos dificil justificacion | 5% (max 2.000 EUR) | No aplica |
| Reserva nivelacion | No | Si (pymes) |
| Tipo reducido micro | No | Si (< 1M EUR, 17%) |

El motor filtra reglas por `ContributorType` automaticamente.

### 17.5 Comunidad autonoma no informada

- Si `autonomousCommunity` es null, solo se evaluan reglas estatales.
- Se genera alerta: "No se ha informado la comunidad autonoma. Pueden existir deducciones autonomicas no evaluadas."
- Confianza de reglas autonomicas = `notApplicable`.

### 17.6 Soporte documental insuficiente

- Cada regla define `minimumDocumentation`.
- Si faltan documentos, la regla puede matched=true pero con `confidence=likely` y documentos en `missingDocuments`.
- Se genera hallazgo de tipo `missing_documentation`.

### 17.7 Tickets no validos como factura

- Tickets son facturas simplificadas (Art. 7 RD 1619/2012).
- Limite: 400 EUR general.
- Sin NIF receptor: IVA NO deducible.
- Regla detecta y alerta.

### 17.8 Operaciones ambiguas

- Descripcion de factura no permite clasificar con certeza.
- Sistema clasifica como `ExpenseCategory.otros` con `Deductibility.requiresReview`.
- Confidence = `possible`, RequiresHumanReview = `true`.

### 17.9 Contradiccion documento vs clasificacion

- Si la clasificacion automatica contradice datos del documento (p.ej. factura de restaurante clasificada como "material oficina"), el sistema lo detecta via heuristicos de palabras clave y genera alerta.

### 17.10 Deducciones sujetas a interpretacion

- Reglas con `requiresHumanReview = true` por defecto.
- Ejemplo: correlacion gasto-ingreso en gastos de representacion.
- Sistema evalua pero marca como `possible` y requiere validacion.

---

## 18. Recomendaciones de Implementacion

### 18.1 Fases

| Fase | Alcance | Estimacion |
|---|---|---|
| **MVP** | Motor reglas IRPF autonomo + IVA basico + UI resumen | Sprint 1-2 |
| **V1** | + Sociedades + facturacion + scoring + ahorro | Sprint 3-4 |
| **V1.5** | + OpenAI explicaciones + auditoria completa | Sprint 5 |
| **V2** | + Deducciones autonomicas + regimenes especiales | Sprint 6-7 |

### 18.2 Testing

- **Unit tests** para cada regla fiscal (input conocido -> output esperado).
- **Golden tests** con escenarios completos (autonomo tipo, sociedad tipo).
- **Integration tests** para el pipeline completo.
- **Snapshot tests** para validar que cambios en reglas no alteran resultados existentes.

### 18.3 Versionado

- Reglas versionadas por ejercicio: `rules_2026_v1.dart`.
- Al publicar cambio normativo: nueva version `rules_2026_v2.dart`.
- Reportes generados guardan `ruleSetVersion` para reproducibilidad.

### 18.4 Configuracion por CCAA

- Cada CCAA tiene su propio archivo de reglas: `irpf_madrid_rules.dart`, etc.
- El registry filtra automaticamente por la CCAA del perfil.
- CCAA no implementadas generan advertencia, no error.

---

## 19. Estructura Inicial de Carpetas, Clases, Servicios y Funciones

```
lib/features/fiscal/
|-- data/
|   |-- models/
|   |   |-- fiscal_profile.dart              # LegalForm, FiscalRegime, FiscalProfile
|   |   |-- fiscal_rule.dart                 # TaxType, RiskLevel, ConfidenceLevel, FiscalRule
|   |   |-- rule_evaluation.dart             # RuleEvaluation
|   |   |-- tax_optimization.dart            # TaxOptimization, OptimizationStatus
|   |   |-- optimization_report.dart         # OptimizationReport, ReportSummary
|   |   |-- expense_classification.dart      # ExpenseCategory, Deductibility, ExpenseClassification
|   |   |-- fiscal_config.dart               # IrpfBracket, IvaRate, IsConfig
|   |-- rules/
|   |   |-- i_fiscal_rule.dart               # Interface IFiscalRule
|   |   |-- rule_engine.dart                 # FiscalRuleEngine.evaluate()
|   |   |-- rule_registry.dart               # RuleRegistry.getRules()
|   |   |-- fiscal_context.dart              # FiscalContext
|   |   |-- irpf/
|   |   |   |-- deduccion_suministros.dart
|   |   |   |-- deduccion_manutencion.dart
|   |   |   |-- deduccion_seguro_enfermedad.dart
|   |   |   |-- gastos_dificil_justificacion.dart
|   |   |   |-- retencion_autonomo_nuevo.dart
|   |   |-- iva/
|   |   |   |-- iva_deducibilidad.dart
|   |   |   |-- iva_vehiculo_afectacion.dart
|   |   |   |-- iva_prorrata.dart
|   |   |   |-- iva_regimen_optimizacion.dart
|   |   |-- sociedades/
|   |   |   |-- tipo_reducido_nueva_entidad.dart
|   |   |   |-- tipo_reducido_microempresa.dart
|   |   |   |-- reserva_capitalizacion.dart
|   |   |   |-- reserva_nivelacion.dart
|   |   |   |-- amortizacion_acelerada.dart
|   |   |   |-- gastos_no_deducibles.dart
|   |   |-- facturacion/
|   |   |   |-- requisitos_formales.dart
|   |   |   |-- obligacion_sii.dart
|   |   |   |-- obligacion_verifactu.dart
|   |   |-- autonomicas/
|   |   |   |-- madrid_rules.dart
|   |   |   |-- cataluna_rules.dart
|   |   |   |-- andalucia_rules.dart
|   |   |   |-- valencia_rules.dart
|-- domain/
|   |-- fiscal_analyzer.dart                 # Orquestador principal
|   |-- expense_classifier.dart              # Clasificador gastos
|   |-- savings_calculator.dart              # Calculador ahorro
|   |-- risk_scorer.dart                     # Scoring riesgo/confianza
|-- providers/
|   |-- fiscal_provider.dart                 # Riverpod providers
|-- presentation/
|   |-- screens/
|   |   |-- fiscal_screen.dart               # Pantalla principal
|   |   |-- optimization_detail_screen.dart  # Detalle hallazgo
|   |-- widgets/
|   |   |-- savings_summary_panel.dart       # KPIs ahorro
|   |   |-- optimizations_list.dart          # Lista hallazgos
|   |   |-- tax_breakdown_chart.dart         # Grafico por impuesto
|   |   |-- risk_matrix.dart                 # Matriz riesgo
|   |   |-- rule_trace_panel.dart            # Audit trail
|   |   |-- ai_explanation_card.dart         # Texto OpenAI

lib/core/services/
|-- fiscal_explanation_service.dart           # Cliente HTTP para /api/fiscal/explain

api/fiscal/
|-- explain.js                               # Vercel serverless function
```

---

## 20. Ejemplo Completo de Evaluacion de una Factura

### Input: Factura recibida

```
FACT-REC-2026-042
Emisor: Iberdrola Clientes S.A.U. (NIF: A95758389)
Concepto: Suministro electrico - Enero 2026
Base imponible: 142,35 EUR
IVA (21%): 29,89 EUR
Total: 172,24 EUR
Fecha: 31/01/2026
```

### Perfil fiscal

```
Tipo: Autonomo persona fisica
Regimen: Estimacion directa simplificada
CNAE: 6201 (Actividades de programacion informatica)
CCAA: Madrid
Vivienda afecta: 25% segun modelo 036
```

### Paso 1: Clasificacion

```
Categoria: suministros
Impuesto afecto: IRPF + IVA
Vinculacion actividad: parcial (vivienda)
```

### Paso 2: Evaluacion motor de reglas

**Regla IRPF-AUT-001 (Deduccion suministros)**:
```
matched: true
confidence: likely
met_conditions:
  - Es autonomo persona fisica
  - Estimacion directa simplificada
  - Gasto de suministros detectado: 142,35 EUR
unmet_conditions: []
missing_documents:
  - Declaracion censal con % afectacion actualizado
estimated_savings: 142.35 * 0.25 * 0.30 * 0.30 = 3.20 EUR (esta factura)
legal_basis: Art. 30.2.5.b LIRPF
```

**Regla IVA-DED-001 (IVA deducible)**:
```
matched: true
confidence: likely
met_conditions:
  - Factura completa conforme Art. 6 RD 1619/2012
  - IVA soportado en actividad sujeta y no exenta
  - Plazo deduccion dentro de 4 anos
unmet_conditions:
  - Afectacion parcial: solo deducible proporcion actividad
missing_documents: []
estimated_savings: 29.89 * 0.25 = 7.47 EUR IVA deducible (proporcion actividad)
legal_basis: Art. 92-97 Ley 37/1992
```

### Paso 3: Scoring

```
Riesgo: LOW (suministro es gasto habitual, bien documentado)
Confianza: LIKELY (falta confirmar % afectacion actualizado)
```

---

## 21. Ejemplo Completo de Justificacion Redactada mediante OpenAI API

### Input enviado a OpenAI

(Ver seccion 10, ejemplo completo del JSON de entrada)

### Output recibido de OpenAI

```json
{
  "request_id": "req_20260330_001",
  "optimization_id": "opt_001",
  "explanation_possible": true,
  "rejection_reason": null,
  "explanation": {
    "summary": "Se ha identificado una oportunidad de ahorro fiscal estimada en 847,50 EUR en su declaracion de IRPF correspondiente al ejercicio 2026, derivada de la aplicacion de la deduccion por gastos de suministros de la vivienda habitual parcialmente afecta a su actividad profesional.",
    "detail": "Como trabajador autonomo dado de alta en la actividad de desarrollo de software (CNAE 6201) y tributando en el regimen de estimacion directa simplificada, usted tiene derecho a deducir en su declaracion de IRPF una parte de los gastos de suministros de su vivienda habitual, siempre que esta se encuentre parcialmente afecta a su actividad economica.\n\nConforme al articulo 30.2.5.b de la Ley 35/2006 del Impuesto sobre la Renta de las Personas Fisicas, el porcentaje de deduccion aplicable es del 30% sobre la proporcion de la vivienda destinada a la actividad, segun conste en su declaracion censal (modelo 036 o 037).\n\nEl sistema ha detectado gastos anuales de suministros por importe de 9.416,67 EUR. Aplicando el 30% sobre la parte proporcional afecta, la base deducible estimada asciende a 2.825,00 EUR. Considerando su tipo marginal estimado, el ahorro fiscal resultante se cifra en aproximadamente 847,50 EUR.",
    "legal_reference": "Articulo 30.2.5.b de la Ley 35/2006, de 28 de noviembre, del Impuesto sobre la Renta de las Personas Fisicas.",
    "next_steps": "Para materializar este ahorro, debera: (1) verificar que las facturas de los suministros (electricidad, gas, agua, telefono e internet) figuran a nombre del titular de la actividad economica; (2) comprobar que su declaracion censal, modelo 036 o 037, refleja correctamente el porcentaje de la vivienda destinado a la actividad; y (3) conservar todas las facturas y justificantes de pago como soporte documental ante una eventual comprobacion.",
    "confidence_note": "Esta recomendacion se califica como probable. Se aconseja confirmar el porcentaje de afectacion de la vivienda que figura en su declaracion censal vigente y verificar que no se han producido modificaciones en las condiciones de uso del inmueble.",
    "disclaimer": "Este analisis tiene caracter orientativo y no constituye asesoramiento fiscal vinculante. Se basa en la normativa vigente a fecha del analisis y en los datos facilitados. Se recomienda consultar con un profesional fiscal antes de aplicar cualquier optimizacion."
  },
  "metadata": {
    "model": "gpt-4o-mini",
    "model_version": "2026-01-25",
    "tokens_used": 512,
    "generation_time_ms": 1450
  }
}
```

### Validacion post-respuesta

```
- LEGAL_BASIS_MISMATCH: OK (output cita "articulo 30.2.5.b de la Ley 35/2006" = input)
- HALLUCINATED_ARTICLES: OK (no se inventan articulos nuevos)
- CONFIDENCE_MISMATCH: OK (input=likely, output="probable")
- SAVINGS_MISMATCH: OK (output cita "847,50 EUR" = input)
- REVIEW_FLAG_IGNORED: N/A (requires_human_review=false)
=> RESULTADO: VALIDO. Explicacion aceptada.
```

---

## 22. Pseudocodigo del Pipeline Completo

```
function analyzeFiscalOptimizations(profile, invoices, receivedInvoices):

  // ── PASO 1: Clasificar gastos ──
  classifications = {}
  for each invoice in receivedInvoices:
    classification = ExpenseClassifier.classify(invoice, profile)
    classifications[invoice.id] = classification

  // ── PASO 2: Construir contexto fiscal ──
  context = FiscalContext(
    profile: profile,
    invoices: invoices,
    receivedInvoices: receivedInvoices,
    totalIncome: sum(invoices.map(i => i.total)),
    totalExpenses: sum(receivedInvoices.map(i => i.total)),
    expensesByCategory: groupAndSum(classifications),
    classifications: classifications,
    fiscalYear: profile.fiscalYear,
    analysisDate: DateTime.now()
  )

  // ── PASO 3: Obtener reglas aplicables ──
  contributorType = profile.legalForm == autonomo ? autonomo : sociedad
  rules = RuleRegistry.getFilteredRules(
    fiscalYear: profile.fiscalYear,
    contributorType: contributorType,
    autonomousCommunity: profile.autonomousCommunity
  )

  // ── PASO 4: Evaluar cada regla (DETERMINISTA) ──
  allEvaluations = []
  for each rule in rules:
    evaluation = rule.evaluate(context)
    allEvaluations.add(evaluation)

  // ── PASO 5: Filtrar reglas matched ──
  matchedEvaluations = allEvaluations.where(e => e.matched)

  // ── PASO 6: Scoring ──
  for each eval in matchedEvaluations:
    eval.riskLevel = RiskScorer.computeRisk(eval)
    eval.confidence = RiskScorer.computeConfidence(eval)

  // ── PASO 7: Calcular ahorro ──
  totalSavings = SavingsCalculator.compute(matchedEvaluations, profile)

  // ── PASO 8: Generar optimizaciones ──
  optimizations = []
  for each eval in matchedEvaluations:
    optimization = TaxOptimization(
      id: generateId(),
      fiscalYear: profile.fiscalYear,
      taxType: eval.taxType,
      ruleId: eval.ruleId,
      title: eval.ruleName,
      description: buildDescription(eval),
      aiExplanation: null,          // Pendiente
      aiExplanationGenerated: false,
      estimatedSavingsEur: eval.estimatedSavings,
      confidence: eval.confidence,
      riskLevel: eval.riskLevel,
      legalBasis: eval.legalBasis,
      requiredActions: buildActions(eval),
      missingDocuments: eval.missingDocuments,
      evidenceInvoiceIds: findRelatedInvoices(eval, receivedInvoices),
      status: eval.requiresHumanReview ? requiresReview : identified,
      requiresHumanReview: eval.requiresHumanReview,
      detectedAt: DateTime.now()
    )
    optimizations.add(optimization)

  // ── PASO 9: Generar explicaciones OpenAI (ASYNC) ──
  for each optimization in optimizations (parallel, max 5):
    try:
      payload = buildExplanationPayload(optimization, profile)
      response = await FiscalExplanationService.explain(payload)

      // Validar respuesta
      validation = validateExplanation(payload, response)
      if validation.valid:
        optimization.aiExplanation = response.explanation
        optimization.aiExplanationGenerated = true
      else if validation.severity == 'warning':
        optimization.aiExplanation = response.explanation + "\n[Nota: verificado por sistema]"
        optimization.aiExplanationGenerated = true
      else:
        // Reintento
        response2 = await FiscalExplanationService.explain(payload, reinforced: true)
        validation2 = validateExplanation(payload, response2)
        if validation2.valid:
          optimization.aiExplanation = response2.explanation
          optimization.aiExplanationGenerated = true
        // Si falla 2 veces: dejar aiExplanation = null
    catch error:
      log(error)
      // No bloquear: optimizacion se entrega sin explicacion IA

  // ── PASO 10: Ensamblar reporte ──
  summary = ReportSummary(
    totalEstimatedSavings: optimizations.sum(o => o.estimatedSavingsEur),
    totalOptimizations: optimizations.length,
    confirmedCount: optimizations.count(o => o.confidence == confirmed),
    likelyCount: optimizations.count(o => o.confidence == likely),
    possibleCount: optimizations.count(o => o.confidence == possible),
    requiresReviewCount: optimizations.count(o => o.requiresHumanReview),
    savingsByTax: groupAndSum(optimizations, by: taxType),
    totalRulesEvaluated: allEvaluations.length,
    totalRulesMatched: matchedEvaluations.length
  )

  report = OptimizationReport(
    id: generateId(),
    fiscalProfileId: profile.id,
    fiscalYear: profile.fiscalYear,
    ruleSetVersion: RuleRegistry.version(profile.fiscalYear),
    generatedAt: DateTime.now(),
    optimizations: optimizations,
    allEvaluations: allEvaluations,
    summary: summary
  )

  // ── PASO 11: Registrar en auditoria ──
  AuditService.log(AuditEvent(
    type: fiscalAnalysis,
    title: 'Analisis fiscal ${profile.fiscalYear}',
    description: '${optimizations.length} optimizaciones, ahorro ${summary.totalEstimatedSavings} EUR',
    relatedEntityId: report.id,
    metadata: { 'rule_set_version': report.ruleSetVersion }
  ))

  return report
```

---

## Apendice A: Implementacion del Servicio OpenAI (Node.js — Vercel Serverless)

```javascript
// api/fiscal/explain.js
const { OpenAI } = require('openai');

const SYSTEM_PROMPT = `Eres un redactor fiscal profesional especializado en normativa tributaria espanola.
Tu UNICA funcion es transformar hallazgos fiscales ya determinados por un sistema automatizado en explicaciones claras, profesionales y comprensibles.

REGLAS ABSOLUTAS:
1. NO determines si una deduccion aplica o no. Esa decision ya fue tomada.
2. NO inventes articulos de ley, consultas vinculantes o criterios no presentes en el input.
3. NO agregues recomendaciones fiscales mas alla de las indicadas en "required_actions".
4. SOLO usa la base normativa proporcionada en "legal_basis".
5. Si el input dice "requires_human_review": true, menciona explicitamente que requiere validacion profesional.
6. Usa tono formal pero comprensible para un empresario no especialista.
7. Responde SIEMPRE en espanol de Espana.
8. NO uses emojis.
9. Si no puedes generar una explicacion fiel al input, pon "explanation_possible": false.`;

const RESPONSE_SCHEMA = {
  type: "object",
  properties: {
    request_id: { type: "string" },
    optimization_id: { type: "string" },
    explanation_possible: { type: "boolean" },
    rejection_reason: { type: ["string", "null"] },
    explanation: {
      type: "object",
      properties: {
        summary: { type: "string" },
        detail: { type: "string" },
        legal_reference: { type: "string" },
        next_steps: { type: "string" },
        confidence_note: { type: "string" },
        disclaimer: { type: "string" }
      },
      required: ["summary", "detail", "legal_reference", "next_steps", "confidence_note", "disclaimer"]
    },
    metadata: {
      type: "object",
      properties: {
        model: { type: "string" },
        tokens_used: { type: "integer" },
        generation_time_ms: { type: "integer" }
      }
    }
  },
  required: ["request_id", "optimization_id", "explanation_possible", "explanation"]
};

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'OpenAI API key not configured' });
  }

  try {
    const input = req.body;
    const startTime = Date.now();

    const client = new OpenAI({ apiKey });

    const userPrompt = buildUserPrompt(input);

    const completion = await client.chat.completions.create({
      model: 'gpt-4o-mini',
      temperature: 0.1,          // Muy baja para salidas controladas
      max_tokens: 1000,
      response_format: {
        type: 'json_schema',
        json_schema: {
          name: 'fiscal_explanation',
          strict: true,
          schema: RESPONSE_SCHEMA
        }
      },
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: userPrompt }
      ]
    });

    const output = JSON.parse(completion.choices[0].message.content);
    output.metadata = {
      model: completion.model,
      tokens_used: completion.usage?.total_tokens ?? 0,
      generation_time_ms: Date.now() - startTime
    };

    // Validacion post-respuesta
    const validation = validateExplanation(input, output);
    if (!validation.valid && validation.severity === 'critical') {
      console.error('Explanation rejected:', validation.errors);
      return res.status(422).json({
        error: 'Explanation rejected by validation',
        errors: validation.errors,
        request_id: input.request_id
      });
    }

    // Log para auditoria
    console.log(JSON.stringify({
      type: 'fiscal_explanation',
      request_id: input.request_id,
      optimization_id: input.optimization?.id,
      model: completion.model,
      tokens: completion.usage?.total_tokens,
      valid: validation.valid,
      errors: validation.errors,
      timestamp: new Date().toISOString()
    }));

    return res.status(200).json(output);

  } catch (error) {
    console.error('OpenAI error:', error.message);
    return res.status(500).json({
      error: 'Failed to generate explanation',
      message: error.message,
      request_id: req.body?.request_id
    });
  }
};

function buildUserPrompt(input) {
  const opt = input.optimization;
  return `Genera una justificacion fiscal profesional para el siguiente hallazgo:

TIPO DE JUSTIFICACION: ${input.justification_type}
TITULO: ${opt.title}
DESCRIPCION TECNICA: ${opt.description}
IMPUESTO AFECTADO: ${opt.tax_type}
BASE NORMATIVA: ${opt.legal_basis}
CRITERIO ADMINISTRATIVO: ${opt.administrative_criteria || 'N/A'}
CONFIANZA: ${opt.confidence}
RIESGO: ${opt.risk_level}
AHORRO ESTIMADO: ${opt.estimated_savings_eur} EUR
CONDICIONES CUMPLIDAS:
${(opt.met_conditions || []).map(c => '- ' + c).join('\n')}
CONDICIONES NO CUMPLIDAS:
${(opt.unmet_conditions || []).length > 0 ? opt.unmet_conditions.map(c => '- ' + c).join('\n') : '- Ninguna'}
DOCUMENTACION FALTANTE:
${(opt.missing_documents || []).length > 0 ? opt.missing_documents.map(d => '- ' + d).join('\n') : '- Ninguna'}
ACCIONES REQUERIDAS:
${(opt.required_actions || []).map(a => '- ' + a).join('\n')}
REQUIERE REVISION HUMANA: ${opt.requires_human_review ? 'Si' : 'No'}

CONTEXTO DEL CLIENTE:
- Forma juridica: ${input.client_context?.legal_form}
- Actividad: ${input.client_context?.activity}
- Comunidad autonoma: ${input.client_context?.autonomous_community}
- Regimen fiscal: ${input.client_context?.fiscal_regime}

Responde usando request_id="${input.request_id}" y optimization_id="${opt.id}".`;
}

function validateExplanation(input, output) {
  const errors = [];
  const opt = input.optimization;

  // 1. Base legal
  if (opt.legal_basis && output.explanation?.legal_reference) {
    const inputRef = opt.legal_basis.toLowerCase();
    const outputRef = output.explanation.legal_reference.toLowerCase();
    const artMatch = inputRef.match(/art[^\d]*(\d+)/);
    if (artMatch && !outputRef.includes(artMatch[1])) {
      errors.push('LEGAL_BASIS_MISMATCH');
    }
  }

  // 2. Articulos inventados
  if (output.explanation?.legal_reference) {
    const outputArts = (output.explanation.legal_reference.match(/art[ií]culo?\s+(\d+)/gi) || [])
      .map(a => a.match(/\d+/)?.[0]).filter(Boolean);
    const inputArts = (opt.legal_basis.match(/art[ií]culo?\s+(\d+)/gi) || [])
      .map(a => a.match(/\d+/)?.[0]).filter(Boolean);
    const invented = outputArts.filter(a => !inputArts.includes(a));
    if (invented.length > 0) {
      errors.push(`HALLUCINATED_ARTICLES: ${invented.join(', ')}`);
    }
  }

  // 3. Review flag
  if (opt.requires_human_review && output.explanation?.detail) {
    const detail = output.explanation.detail.toLowerCase();
    if (!detail.includes('revision') && !detail.includes('profesional') && !detail.includes('asesor')) {
      errors.push('REVIEW_FLAG_IGNORED');
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    severity: errors.some(e => e.startsWith('HALLUCINATED')) ? 'critical' : 'warning'
  };
}
```

### Estrategia OpenAI: temperature y salidas controladas

| Parametro | Valor | Razon |
|---|---|---|
| `model` | `gpt-4o-mini` | Coste bajo, velocidad alta, suficiente para redaccion |
| `temperature` | `0.1` | Minima creatividad. Salidas estables y reproducibles. |
| `max_tokens` | `1000` | Limitar extension. Explicacion concisa. |
| `response_format` | `json_schema` (strict) | Fuerza estructura exacta. Evita texto libre. |
| `top_p` | `0.9` | Complementa temperature baja |

### Reglas para rechazar respuestas

1. Si `explanation_possible === false`: Aceptar pero no mostrar explicacion.
2. Si validacion detecta `HALLUCINATED_ARTICLES`: **RECHAZAR inmediatamente**. No mostrar al usuario.
3. Si validacion detecta `LEGAL_BASIS_MISMATCH`: **RECHAZAR**. Reintentar 1 vez.
4. Si 2 reintentos fallan: Entregar optimizacion sin explicacion IA.
5. Si OpenAI retorna error HTTP o timeout (>10s): Entregar sin explicacion. No reintentar mas de 1 vez.

---

---

## Apendice B: Referencias BOE Verificadas

| Norma | Referencia BOE | Materia |
|---|---|---|
| Ley 35/2006 | BOE-A-2006-20764 | IRPF |
| Ley 37/1992 | BOE-A-1992-28740 | IVA |
| Ley 27/2014 | BOE-A-2014-12328 | Impuesto sobre Sociedades |
| RD 1619/2012 | BOE-A-2012-14696 | Reglamento de facturacion |
| Ley 11/2021 | BOE-A-2021-11473 | Ley Antifraude |
| Ley 18/2022 | BOE-A-2022-15818 | Ley Crea y Crece |
| RD 1007/2023 | BOE-A-2023-24840 | Reglamento SIF / Verifactu |
| Orden HAC/1177/2024 | BOE-A-2024-22138 | Especificaciones tecnicas Verifactu |
| RD 254/2025 | BOE-A-2025-6600 | Modificacion Reglamento SIF |
| Ley 7/2024 | — | Medidas fiscales 2025 (IS pymes, escala ahorro IRPF) |
| RDL 15/2025 | — | Ampliacion plazos SIF/Verifactu a 2027 |
| Orden HAC/1425/2025 | BOE-A-2025-25272 | Modulos IRPF y regimen simplificado IVA 2026 |
| Orden HAC/1347/2024 | BOE-A-2024-24949 | Modulos IRPF y regimen simplificado IVA 2025 |

**Fuentes oficiales consultadas**:
- sede.agenciatributaria.gob.es (manuales practicos, retenciones, SII, Verifactu)
- boe.es (textos consolidados de leyes y reales decretos)
- AEAT PDFs: tipos IVA 2026, retenciones IRPF 2025-2026, actividades regimen simplificado 2026

---

*Fin del documento de diseno tecnico. Este documento es la base para el desarrollo del modulo de optimizacion fiscal de TeeDoo.*
