import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/core/theme/color.dart';
import 'package:mashrou3i/presentation/widgets/compnents.dart';
import '../../../../../data/models/availability_model.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../screens/creator/dashboard_screen/availability/availability_cubit.dart';
import '../screens/creator/dashboard_screen/availability/availability_state.dart';


class AvailabilityScreen extends StatefulWidget {
  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  TimeOfDay _openTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = TimeOfDay(hour: 17, minute: 0);
  bool _isDaily = true;
  bool _isLoading = true;
  bool _isSaving = false;
  final Map<int, bool> _selectedDays = {
    1: false, // Monday
    2: false, // Tuesday
    3: false, // Wednesday
    4: false, // Thursday
    5: false, // Friday
    6: false, // Saturday
    7: false, // Sunday
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentAvailability();
  }

  void _loadCurrentAvailability() {
    final cubit = context.read<AvailabilityCubit>();
    cubit.fetchAvailability().then((_) {
      if (cubit.state is AvailabilityLoaded) {
        final availability = (cubit.state as AvailabilityLoaded).availability;
        _updateUIFromAvailability(availability);
      } else {
        setState(() {
          _isDaily = true;
          _openTime = TimeOfDay(hour: 9, minute: 0);
          _closeTime = TimeOfDay(hour: 17, minute: 0);
          // Explicitly set all days to false
          _selectedDays.updateAll((key, value) => false);
        });
      }
      setState(() => _isLoading = false);
    });
  }

  void _updateUIFromAvailability(Availability availability) {
    setState(() {
      _isDaily = availability.type == 'daily';

      final openParts = availability.openAt.split(':');
      _openTime = TimeOfDay(
        hour: int.parse(openParts[0]),
        minute: int.parse(openParts[1]),
      );

      final closeParts = availability.closeAt.split(':');
      _closeTime = TimeOfDay(
        hour: int.parse(closeParts[0]),
        minute: int.parse(closeParts[1]),
      );

      _selectedDays.updateAll((key, value) => false);
      for (var dayName in availability.days) {
        final dayIndex = _dayNameToIndex(dayName);
        if (dayIndex != null) {
          _selectedDays[dayIndex] = true;
        }
      }
    });
  }

  int? _dayNameToIndex(String dayName) {
    final dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };
    return dayMap[dayName];
  }

  String _indexToDayName(int index) {
    switch (index) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
  Future<void> _saveAvailability() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final cubit = context.read<AvailabilityCubit>();

      final selectedDays = _selectedDays.entries
          .where((entry) => entry.value)
          .map((entry) => _indexToDayName(entry.key))
          .toList();

      final availability = Availability(
        type: _isDaily ? 'daily' : 'specific',
        openAt: '${_openTime.hour.toString().padLeft(2, '0')}:${_openTime.minute.toString().padLeft(2, '0')}',
        closeAt: '${_closeTime.hour.toString().padLeft(2, '0')}:${_closeTime.minute.toString().padLeft(2, '0')}',
        days: selectedDays,
      );

      await cubit.saveAvailability(availability);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.availabilitySaved.tr(),
                style: const TextStyle(color: Colors.black)),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${LocaleKeys.failedToSaveAvailability.tr()}: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AvailabilityCubit, AvailabilityState>(
      listener: (context, state) {
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.availabilitySettings.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          leading: popButton(context),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body:_buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface.withOpacity(0.05),
                Theme.of(context).colorScheme.surface.withOpacity(0.1),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 200),
                const SizedBox(height: 20),
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.availabilityType.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTypeToggle(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isDaily)
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.workingHours.tr(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTimeRangeSelector(),
                      ],
                    ),
                  )
                else ...[
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.selectWorkingDays.tr(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _selectedDays.entries.map((entry) {
                            final dayId = entry.key;
                            final isSelected = entry.value;
                            return FilterChip(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              selectedColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1.5,
                              ),
                              label: Text(
                                _dayName(dayId),
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.black,
                                  fontSize: 15
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedDays[dayId] = selected);
                              },
                              checkmarkColor: Colors.black,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.workingHoursForDays.tr(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTimeRangeSelector(),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSaving
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isSaving
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                      : Text(
                    LocaleKeys.save.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isSaving)
          const ModalBarrier(
            dismissible: false,
            color: Colors.black54,
          ),
        if (_isSaving)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: child,
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleOption(LocaleKeys.dailyAvailability.tr(), _isDaily, () {
            setState(() => _isDaily = true);
          }),
          SizedBox(width: 8),
          _toggleOption(LocaleKeys.specificDays.tr(), !_isDaily, () {
            setState(() => _isDaily = false);
          }),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Column(
      children: [
        _buildTimeTile(LocaleKeys.openAt.tr(), _openTime, () async {
          final picked = await await showTimePicker(
            context: context,
            initialTime: _openTime,
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor:Colors.white,
                    dialBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    dialHandColor: textColor,
                    entryModeIconColor: textColor,
                    hourMinuteTextColor: Colors.black,
                    hourMinuteShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    dayPeriodColor:Theme.of(context).primaryColor,
                    dayPeriodTextColor: Colors.black,
                  ),
                  colorScheme: ColorScheme.light(
                    primary: textColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) setState(() => _openTime = picked);
        }),
        const SizedBox(height: 16),
        _buildTimeTile(LocaleKeys.closeAt.tr(), _closeTime, () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: _closeTime,
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor:Colors.white,
                    dialBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    dialHandColor: textColor,
                    entryModeIconColor: textColor,
                    hourMinuteTextColor: Colors.black,
                    hourMinuteShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    dayPeriodColor:Theme.of(context).primaryColor,
                    dayPeriodTextColor: Colors.black,
                  ),
                  colorScheme: ColorScheme.light(
                    primary: textColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) setState(() => _closeTime = picked);
        }),
      ],
    );
  }

  Widget _buildTimeTile(String title, TimeOfDay time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              time.format(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayName(int day) {
    switch (day) {
      case 1: return LocaleKeys.monday.tr();
      case 2: return LocaleKeys.tuesday.tr();
      case 3: return LocaleKeys.wednesday.tr();
      case 4: return LocaleKeys.thursday.tr();
      case 5: return LocaleKeys.friday.tr();
      case 6: return LocaleKeys.saturday.tr();
      case 7: return LocaleKeys.sunday.tr();
      default: return '';
    }
  }
}