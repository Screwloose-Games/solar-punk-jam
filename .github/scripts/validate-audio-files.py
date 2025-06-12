# Run this with: python .github/scripts/validate-audio-files.py $(cat audio_files.txt)

import json
import os
import sys
import wave

MAX_FILE_SIZE = 49 * 1024 * 1024  # 49 MB

WAV_FILE_SPECIFICATIONS = {
    "sample_rate": 44100,  # Hz
    "bit_depth": 16,       # bits per sample
    "channels": 1,         # 1 for mono, 2 for stereo
    "target_lufs": -16,    # LUFS loudness normalization
    "peak_volume": -1.0,   # dBFS, avoid clipping
    "looping": False,      # true only for seamless loops
    "filename_convention": {
        "casing": "lowercase",
        "separator": "underscore",
        "extension": ".wav"
    },
    "max_length": 10,      # seconds
    "max_file_size": MAX_FILE_SIZE,  # 49 MB
}

class AudioFileReport:
    """Class to generate a report for audio file data. Includes detailed information about the audio file.
        Attributes:
            file_path (str): Path to the audio file.
            file_size (int): Size of the audio file in Megabytes.
            sample_rate (int): Sample rate of the audio file.
            bit_depth (int): Bit depth of the audio file.
            channels (int): Number of channels in the audio file.
            duration (float): Duration of the audio file in seconds.
            errors (list): List of validation errors encountered during processing."""

    report_template = """Audio File Report:
    File Path: `{file_path}`
    File Size: {file_size:.2f} Megabytes
    Sample Rate: {sample_rate} Hz
    Bit Depth: {bit_depth} bits
    Channels: {channels}
    Duration: {duration:.2f} seconds
    Errors: {errors}
    """

    def __init__(self, file_path):
        self.file_path = file_path
        self.file = wave.open(file_path, 'rb')
        self.file_size = os.path.getsize(file_path) / (1024 * 1024) # in Megabytes
        self.sample_rate = self.file.getframerate()
        self.bit_depth = self.file.getsampwidth() * 8
        self.channels = self.file.getnchannels()
        self.duration = self.file.getnframes() / float(self.sample_rate)
        self.errors = []

        validator = AudioFileValidator(self.file_path)
        validator.validate()
        for error in validator.errors:
            self.errors.append(error)

    
    def __str__(self):
        return self.report_template.format(
            file_path=self.file_path,
            file_size=self.file_size,
            sample_rate=self.sample_rate,
            bit_depth=self.bit_depth,
            channels=self.channels,
            duration=self.duration,
            errors=self.errors
        )

class AudioFileValidator:
    def __init__(self, file_path):
        self.file_path = file_path
        self.errors = []

    def validation_results(self):
        return "\n".join(self.errors) if self.errors else "No errors found."

    def validate(self):
        if not os.path.isfile(self.file_path):
            self.errors.append(f"File does not exist: {self.file_path}")
            return False

        file_size = os.path.getsize(self.file_path)
        if file_size > WAV_FILE_SPECIFICATIONS["max_file_size"]:
            self.errors.append(f"File size exceeds limit: {file_size} bytes > {WAV_FILE_SPECIFICATIONS['max_file_size']} bytes")
        
        if not self.file_path.endswith(WAV_FILE_SPECIFICATIONS["filename_convention"]["extension"]):
            self.errors.append(f"Invalid file extension: {self.file_path}")

        if not self.file_path.islower():
            self.errors.append(f"Filename is not lowercase: {self.file_path}")
        
        if "_" not in self.file_path:
            self.errors.append(f"Filename does not contain underscore: {self.file_path}")
        
        # is 16 bit depth
        if not self.file_path.endswith('.wav'):
            self.errors.append(f"File is not a WAV file: {self.file_path}")
        
        # Check audio properties using wave module

        try:
            with wave.open(self.file_path, 'rb') as wav_file:
                sample_rate = wav_file.getframerate()
                channels = wav_file.getnchannels()
                sampwidth = wav_file.getsampwidth()  # in bytes

            # Check sample rate
            if sample_rate != WAV_FILE_SPECIFICATIONS["sample_rate"]:
                self.errors.append(
                f"Sample rate mismatch: {sample_rate} Hz (expected {WAV_FILE_SPECIFICATIONS['sample_rate']} Hz) in {self.file_path}"
                )

            # Check channels
            if channels != WAV_FILE_SPECIFICATIONS["channels"]:
                self.errors.append(
                f"Channel count mismatch: {channels} (expected {WAV_FILE_SPECIFICATIONS['channels']}) in {self.file_path}"
                )

            # Check bit depth
            bit_depth = sampwidth * 8
            if bit_depth != WAV_FILE_SPECIFICATIONS["bit_depth"]:
                self.errors.append(
                f"Bit depth mismatch: {bit_depth} (expected {WAV_FILE_SPECIFICATIONS['bit_depth']}) in {self.file_path}"
                )

            # Check duration
            n_frames = wav_file.getnframes()
            duration = n_frames / float(sample_rate)
            if duration > WAV_FILE_SPECIFICATIONS["max_length"]:
                self.errors.append(
                f"Audio duration exceeds limit: {duration:.2f} seconds (max {WAV_FILE_SPECIFICATIONS['max_length']} seconds) in {self.file_path}"
                )

        except wave.Error as e:
            self.errors.append(f"Error reading WAV file: {self.file_path} ({e})")
        except Exception as e:
            self.errors.append(f"Unexpected error reading WAV file: {self.file_path} ({e})")

        return not self.errors


def main(audio_files):
    validators = [AudioFileValidator(file_path) for file_path in audio_files]
    reports = [AudioFileReport(file_path) for file_path in audio_files]
    for validator in validators:
        if not validator.validate():
            print(f"Validation failed for {validator.file_path}:")
            for error in validator.errors:
                print(f" - {error}")
            print()
        else:
            print(f"Validation succeeded for {validator.file_path}")
    for report in reports:
        print(report)
    
    out_path = os.environ["GITHUB_OUTPUT"]
    if os.path.exists(out_path):
        with open(out_path, "a") as fh:
            reports_str = "\n\n".join([str(report) for report in reports])
            metadata = {
                "audio_reports": reports_str,
            }
            print("metadata<<EOF", file=fh)
            print(json.dumps(metadata, indent=2), file=fh)
            print("EOF", file=fh)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python validate-audio-files.py <audio_file1> <audio_file2> ...")
        sys.exit(1)

    audio_files = sys.argv[1:]
    main(audio_files)