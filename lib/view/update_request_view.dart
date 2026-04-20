import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';

import 'package:tech_app/provider/service_timer_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/Timmer_Service.dart';
import 'package:tech_app/services/Update_Service.dart';
import 'package:tech_app/widgets/inputs/app_text_field.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';
import 'package:tech_app/widgets/media_upload.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class UpdateRequestView extends ConsumerStatefulWidget {
  final String serviceRequestId;
  final String userServiceId;
  const UpdateRequestView({
    super.key,
    required this.serviceRequestId,
    required this.userServiceId,
  });

  @override
  ConsumerState<UpdateRequestView> createState() => _UpdateRequestViewState();
}

class _UpdateRequestViewState extends ConsumerState<UpdateRequestView>   with WidgetsBindingObserver {
  Set<int> selectedIndexes = {
    0,
    1,
  }; // Accepted & In Progress selected by default

  bool isLoading = false;
  bool isOnHold = false;
final TimerService _timerService = TimerService();
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  final UpdateService _updateService = UpdateService();
  final statustext = TextEditingController();

  // Voice recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlayingVoice = false;
  String? _voicePath;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  final List<Map<String, dynamic>> status = [
    {"title": "Accepted"},
    {"title": "In Progress"},
    {"title": "completed"},
  ];
  bool get isCompletedSelected => selectedIndexes.contains(2);
  @override
  void initState() {
    super.initState();
    selectedIndexes = {0, 1}; // Always selected
WidgetsBinding.instance.addObserver(this);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadTimer();
  });

  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    statustext.dispose();
    _recordTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (!await _audioRecorder.hasPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission denied")),
        );
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() {
        _isRecording = true;
        _voicePath = null;
        _recordDuration = Duration.zero;
      });
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordDuration += const Duration(seconds: 1));
      });
    } catch (e) {
      debugPrint("Record start error: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _recordTimer?.cancel();
      setState(() {
        _isRecording = false;
        _voicePath = path;
      });
    } catch (e) {
      debugPrint("Record stop error: $e");
    }
  }

  Future<void> _togglePlayVoice() async {
    if (_voicePath == null) return;
    if (_isPlayingVoice) {
      await _audioPlayer.stop();
      setState(() => _isPlayingVoice = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(_voicePath!));
      setState(() => _isPlayingVoice = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        if (!mounted) return;
        setState(() => _isPlayingVoice = false);
      });
    }
  }

  void _deleteVoice() {
    if (_isPlayingVoice) {
      _audioPlayer.stop();
    }
    setState(() {
      _voicePath = null;
      _isPlayingVoice = false;
      _recordDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

 @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _loadTimer(); // sync with backend
  }
}

 Future<void> _loadTimer() async {
    await Appperfernces.saveuserServiceId( widget.userServiceId);
    try {
      final response = await _timerService.fetchTimerData(
        userServiceId: widget.userServiceId,
      );

      ref.read(timerProvider.notifier).initialize(
            totalSeconds: response["totalSeconds"] ?? 0,
            isRunning: response["isRunning"] ?? false,
          );
    } catch (e) {
      debugPrint("Timer load error: $e");
    }
  }
  Future<void> _toggleTimer() async {
    final timerState = ref.read(timerProvider);

    try {
      if (timerState.isRunning) {
        await _timerService.pauseTimer(
          userServiceId: widget.userServiceId,
        );
      } else {
        await _timerService.resumeTimer(
          userServiceId: widget.userServiceId,
        );
      }

      await _loadTimer(); // sync again
    } catch (e) {
      debugPrint("Toggle error: $e");
    }
  }
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImages.add(image);
      });
    }
  }
  Future<void> SaveUpdates() async {
    try {
      final files = selectedImages.map((xfile) => File(xfile.path)).toList();
      setState(() => isLoading = true);
      final result = await _updateService.fetchupdatedservice(
        images: files,
        userServiceId: widget.userServiceId,
        serviceStatus: statustext.text.trim(),
        voice: _voicePath != null ? File(_voicePath!) : null,
      );
   if (isCompletedSelected) {
        ref.read(timerProvider.notifier).reset();
      }
   await Appperfernces.clearUserServiceId();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.updateSavedSuccessfully),
          backgroundColor: AppColors.scoundry_clr,
        ),
      );
      context.push(RouteName.sparepart_used, extra: widget.userServiceId);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }


  @override
  Widget build(BuildContext context) {
   final timerState = ref.watch(timerProvider);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.pop();
        }
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color.fromRGBO(223, 221, 221, 1),
                ),
                child: Center(
                  child: Text(
                    widget.serviceRequestId.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17,color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
               Text(
                AppLocalizations.of(context)!.timer,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.scoundry_clr,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
Text(
  timerState.formattedTime,
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),
                      ],
                    ),
                  ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor:
        timerState.isRunning ? Colors.red : Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: _toggleTimer,
  child: Text(
    timerState.isRunning
        ? AppLocalizations.of(context)!.onHold
        : AppLocalizations.of(context)!.start,
    style: const TextStyle(color: Colors.white),
  ),
),
                  ],
                ),
              ),

              const SizedBox(height: 10),
               Text(
                 AppLocalizations.of(context)!.updatedStatus,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 4,
                ),
                itemCount: status.length,

                itemBuilder: (context, index) {
                  final statusItem = status[index];
                  final bool isSelected = selectedIndexes.contains(index);

                  return InkWell(
                    onTap: () {
                      //  Accepted (0) & In Progress (1) → DO NOTHING
                      if (index == 0 || index == 1) return;

                      setState(() {
                        if (isSelected) {
                          selectedIndexes.remove(index);
                        } else {
                          selectedIndexes.add(index);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.scoundry_clr
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.scoundry_clr,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          statusItem['title'],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.scoundry_clr,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),
               Text(
                    AppLocalizations.of(context)!.addNotes,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              AppTextField(
                maxLines: 3,
                controller: statustext,
                label: AppLocalizations.of(context)!.description,
              ),
              const SizedBox(height: 15),

               Text(
                AppLocalizations.of(context)!.mediaUploadOptional,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(
                "${selectedImages.length} / 10 images selected",
                style: TextStyle(
                  fontSize: 12,
                  color: selectedImages.length == 10 ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              // UPLOAD BUTTON
              MediaUploadWidget(
                images: selectedImages,
                onAddTap: () {
                  showImagePickerSheet(context);
                },
                onRemoveTap: (index) {
                  setState(() {
                    selectedImages.removeAt(index);
                  });
                },
              ),

              const SizedBox(height: 15),
              Text(
                "Voice Note (Optional)",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildVoiceRecorder(),

              const SizedBox(height: 25),

              // PrimaryButton(
              //   radius: 15,
              //   Width: double.infinity,
              //   height: 55,
              //   color: AppColors.scoundry_clr,
              //   onPressed: () {
              //     // context.push(RouteName.sparepart_used);
              //     SaveUpdates();
              //   },
              //   text: "Save Updates",
              // ),
              isCompletedSelected
                  ? PrimaryButton(
                      radius: 15,
                      Width: double.infinity,
                      height: 55,
                      color: AppColors.scoundry_clr,
                      isLoading: isLoading,
                      onPressed: SaveUpdates,
                      text:   AppLocalizations.of(context)!.saveUpdates,
                    )
                  : PrimaryButton(
                      radius: 15,
                      Width: double.infinity,
                      height: 55,
                      color: Colors.grey,
                      onPressed: null, // disabled
                      text: AppLocalizations.of(context)!.saveUpdates,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceRecorder() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.scoundry_clr, width: 1.2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: _isRecording
                  ? Colors.red
                  : AppColors.scoundry_clr,
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRecording
                      ? "Recording... ${_formatDuration(_recordDuration)}"
                      : _voicePath != null
                          ? "Voice note ready"
                          : "Tap mic to record",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (_voicePath != null && !_isRecording)
                  Text(
                    _formatDuration(_recordDuration),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          if (_voicePath != null && !_isRecording) ...[
            IconButton(
              onPressed: _togglePlayVoice,
              icon: Icon(
                _isPlayingVoice ? Icons.pause_circle : Icons.play_circle,
                color: AppColors.scoundry_clr,
                size: 30,
              ),
            ),
            IconButton(
              onPressed: _deleteVoice,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  void showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title:  Text( AppLocalizations.of(context)!.camera),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title:  Text(AppLocalizations.of(context)!.gallery),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
