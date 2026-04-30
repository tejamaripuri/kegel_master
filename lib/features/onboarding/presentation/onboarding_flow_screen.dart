import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_mutual_exclusion.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _step = 0;
  GenderIdentity _gender = GenderIdentity.male;
  PrimaryGoal _primaryGoal = PrimaryGoal.preventionMaintenance;
  AgeBand _ageBand = AgeBand.age18to34;
  Set<Symptom> _symptoms = {Symptom.none};
  Set<ClinicalHistory> _clinicalHistory = {ClinicalHistory.none};

  OnboardingProfile _profile() {
    return OnboardingProfile(
      gender: _gender,
      primaryGoal: _primaryGoal,
      ageBand: _ageBand,
      symptoms: _symptoms,
      clinicalHistory: _clinicalHistory,
    );
  }

  Future<void> _acceptDisclaimer() async {
    await OnboardingScope.of(context).setDisclaimerAccepted(DateTime.now());
    if (!mounted) return;
    setState(() => _step = 1);
  }

  Future<void> _finish(OnboardingProfile profile) async {
    await OnboardingScope.of(context).completeWithProfile(profile);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup')),
      body: switch (_step) {
        0 => _DisclaimerStep(onAccept: _acceptDisclaimer),
        1 => _RadioStep<GenderIdentity>(
          title: 'Gender identity',
          value: _gender,
          values: GenderIdentity.values,
          label: _genderLabel,
          onChanged: (v) => setState(() => _gender = v),
          onNext: () => setState(() => _step = 2),
        ),
        2 => _RadioStep<PrimaryGoal>(
          title: 'Primary goal',
          value: _primaryGoal,
          values: PrimaryGoal.values,
          label: _goalLabel,
          onChanged: (v) => setState(() => _primaryGoal = v),
          onNext: () => setState(() => _step = 3),
        ),
        3 => _RadioStep<AgeBand>(
          title: 'Age range',
          value: _ageBand,
          values: AgeBand.values,
          label: _ageLabel,
          onChanged: (v) => setState(() => _ageBand = v),
          onNext: () => setState(() => _step = 4),
        ),
        4 => _MultiChipStep<Symptom>(
          title: 'Symptoms (optional)',
          selected: _symptoms,
          values: Symptom.values,
          label: _symptomLabel,
          onToggle: (s) =>
              setState(() => _symptoms = OnboardingMutualExclusion.toggleSymptom(_symptoms, s)),
          onNext: () => setState(() => _step = 5),
        ),
        5 => _MultiChipStep<ClinicalHistory>(
          title: 'Clinical context',
          selected: _clinicalHistory,
          values: ClinicalHistory.values,
          label: _clinicalLabel,
          onToggle: (c) => setState(
            () => _clinicalHistory =
                OnboardingMutualExclusion.toggleClinicalHistory(_clinicalHistory, c),
          ),
          onNext: () => setState(() => _step = 6),
        ),
        6 => _SummaryStep(
          profile: _profile(),
          onEdit: (int step) => setState(() => _step = step),
          onConfirm: () {
            final OnboardingProfile p = _profile();
            if (p.hasCatheter) {
              setState(() => _step = 7);
            } else {
              unawaited(_finish(p));
            }
          },
        ),
        7 => _SafetyStep(
          onUnderstand: () => unawaited(_finish(_profile())),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

String _genderLabel(GenderIdentity g) => switch (g) {
      GenderIdentity.male => 'Male',
      GenderIdentity.female => 'Female',
      GenderIdentity.nonBinary => 'Non-binary',
    };

String _goalLabel(PrimaryGoal g) => switch (g) {
      PrimaryGoal.postpartumRecovery => 'Postpartum recovery',
      PrimaryGoal.postSurgicalProstateRecovery => 'Post-prostate surgery recovery',
      PrimaryGoal.preventionMaintenance => 'Prevention / maintenance',
      PrimaryGoal.sexualPerformanceEnhancement => 'Sexual performance',
      PrimaryGoal.incontinenceManagement => 'Incontinence management',
    };

String _ageLabel(AgeBand a) => switch (a) {
      AgeBand.age18to34 => '18–34',
      AgeBand.age35to54 => '35–54',
      AgeBand.age55plus => '55+',
    };

String _symptomLabel(Symptom s) => switch (s) {
      Symptom.leakingCoughSneeze => 'Leaks with cough/sneeze',
      Symptom.suddenUrges => 'Sudden urges',
      Symptom.difficultyStartingStream => 'Difficulty starting stream',
      Symptom.chronicPelvicPain => 'Chronic pelvic pain',
      Symptom.none => 'None',
    };

String _clinicalLabel(ClinicalHistory c) => switch (c) {
      ClinicalHistory.birthWithin8Weeks => 'Birth within 8 weeks',
      ClinicalHistory.recentProstateSurgery => 'Recent prostate surgery',
      ClinicalHistory.catheter => 'Catheter in use',
      ClinicalHistory.none => 'None',
    };

class _DisclaimerStep extends StatelessWidget {
  const _DisclaimerStep({required this.onAccept});

  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'This app offers general pelvic floor education and exercise timing. '
          'It is not medical advice. Consult a qualified clinician for diagnosis or treatment.',
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onAccept,
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

class _RadioStep<T> extends StatelessWidget {
  const _RadioStep({
    required this.title,
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
    required this.onNext,
  });

  final String title;
  final T value;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Expanded(
          child: RadioGroup<T>(
            groupValue: value,
            onChanged: (T? x) {
              if (x != null) onChanged(x);
            },
            child: ListView(
              children: values
                  .map(
                    (T v) => RadioListTile<T>(
                      title: Text(label(v)),
                      value: v,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(onPressed: onNext, child: const Text('Next')),
        ),
      ],
    );
  }
}

class _MultiChipStep<T> extends StatelessWidget {
  const _MultiChipStep({
    required this.title,
    required this.selected,
    required this.values,
    required this.label,
    required this.onToggle,
    required this.onNext,
  });

  final String title;
  final Set<T> selected;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T> onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: values
                    .map(
                      (T v) => FilterChip(
                        label: Text(label(v)),
                        selected: selected.contains(v),
                        onSelected: (_) => onToggle(v),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(onPressed: onNext, child: const Text('Next')),
        ),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    required this.profile,
    required this.onEdit,
    required this.onConfirm,
  });

  final OnboardingProfile profile;
  final ValueChanged<int> onEdit;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Summary', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListTile(
          title: Text(_genderLabel(profile.gender)),
          subtitle: const Text('Gender'),
          trailing: TextButton(onPressed: () => onEdit(1), child: const Text('Edit')),
        ),
        ListTile(
          title: Text(_goalLabel(profile.primaryGoal)),
          subtitle: const Text('Goal'),
          trailing: TextButton(onPressed: () => onEdit(2), child: const Text('Edit')),
        ),
        ListTile(
          title: Text(_ageLabel(profile.ageBand)),
          subtitle: const Text('Age'),
          trailing: TextButton(onPressed: () => onEdit(3), child: const Text('Edit')),
        ),
        ListTile(
          title: Text(profile.symptoms.map(_symptomLabel).join(', ')),
          subtitle: const Text('Symptoms'),
          trailing: TextButton(onPressed: () => onEdit(4), child: const Text('Edit')),
        ),
        ListTile(
          title: Text(profile.clinicalHistory.map(_clinicalLabel).join(', ')),
          subtitle: const Text('Clinical'),
          trailing: TextButton(onPressed: () => onEdit(5), child: const Text('Edit')),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: onConfirm, child: const Text('Confirm')),
      ],
    );
  }
}

class _SafetyStep extends StatelessWidget {
  const _SafetyStep({required this.onUnderstand});

  final VoidCallback onUnderstand;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Pelvic floor exercises are not appropriate while a catheter is in place '
          'unless your clinician has cleared you. The app will show education only.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onUnderstand,
          child: const Text('I understand'),
        ),
      ],
    );
  }
}
