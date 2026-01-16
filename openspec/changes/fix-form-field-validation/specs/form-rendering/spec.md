# form-rendering Spec Delta

## ADDED Requirements

### Requirement: ComboBox Value/Display Separation

The system SHALL support separate storage values from display values in ComboBox fields.

When `VaGrCamp` is populated:
- The system SHALL use `VaGrCamp` values as the `value` attribute of options
- The system SHALL use `VareCamp` values as the displayed text of options
- Values MUST be paired by index (VareCamp[0] displays VaGrCamp[0], etc.)

When `VaGrCamp` is empty or null:
- The system SHALL use `VareCamp` for both `value` and displayed text
- This is the current behavior and MUST be maintained as fallback

#### Scenario: ComboBox com valores separados
- **GIVEN** um campo ComboBox com CompCamp='C'
- **AND** VareCamp contendo "Ativo|Inativo|Pendente"
- **AND** VaGrCamp contendo "A|I|P"
- **WHEN** o campo e renderizado
- **THEN** os options devem ter value="A", "I", "P"
- **AND** os options devem exibir texto "Ativo", "Inativo", "Pendente"
- **AND** ao salvar, o valor gravado deve ser do VaGrCamp

#### Scenario: ComboBox sem VaGrCamp (fallback)
- **GIVEN** um campo ComboBox com CompCamp='C'
- **AND** VareCamp contendo "Sim|Nao"
- **AND** VaGrCamp vazio ou nulo
- **WHEN** o campo e renderizado
- **THEN** os options devem ter value="Sim", "Nao"
- **AND** os options devem exibir texto "Sim", "Nao"
- **AND** ao salvar, o valor gravado deve ser o texto exibido

#### Scenario: ComboBox calculado (EC) com valores separados
- **GIVEN** um campo ComboBox calculado com CompCamp='EC'
- **AND** VareCamp e VaGrCamp preenchidos
- **WHEN** o campo e renderizado
- **THEN** o comportamento DEVE ser identico ao ComboBox tipo C
