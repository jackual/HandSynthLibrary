import Foundation
import Tonic
import AVFoundation

extension Note {
    func octUp() -> Note {
        return self.shiftUp(.M9)!.shiftDown(.M2)!
    }

    func octDown() -> Note {
        return self.shiftDown(.M9)!.shiftUp(.M2)!
    }

    func toOct(_ targetOctave: Int) -> Note {
        let currentOctave = self.octave
        var result = self
        let diff = targetOctave - currentOctave
        if diff > 0 {
            for _ in 0..<diff {
                result = result.octUp()
            }
        } else if diff < 0 {
            for _ in 0..<(-diff) {
                result = result.octDown()
            }
        }
        return result
    }
}

extension Key {
    func getMidi(_ octaveRange: ClosedRange<Int>) -> [UInt8] {
        var midiNoteNumbers: [UInt8] = []

        for octave in octaveRange {
            self.noteSet.forEach({ Note in
                midiNoteNumbers.append(UInt8(Note.toOct(octave).pitch.midiNoteNumber))
            })
        }

        return midiNoteNumbers
    }
}

public extension Chord {
    func getMidi(_ octave: Int) -> [UInt8] {
        var midiNoteNumbers: [UInt8] = []

        self.noteClasses.forEach({ NoteClass in
            midiNoteNumbers.append(UInt8(NoteClass.canonicalNote.octDown().pitch.midiNoteNumber))
        })

        print(midiNoteNumbers)
        return midiNoteNumbers
    }
}

extension Array where Element == UInt8 {
    func noteFromFloat(_ pitch: Float) -> UInt8 {
        guard !isEmpty else { return 0 }
        let clampedPitch = Swift.max(0, Swift.min(pitch, 1))
        let index = Int(Float(count - 1) * clampedPitch)
        return self[index]
    }
}

public extension Array where Element == [UInt8] {
    func chordFromFloat(_ pitch: Float) -> [UInt8] {
        guard !isEmpty else { return [] }
        let clampedPitch = Swift.max(0, Swift.min(pitch, 1))
        let index = Int(Float(count - 1) * clampedPitch)
        return self[index]
    }
}

public class HandSynthEngine {
    private var engine = AVAudioEngine()
    private var sampler = AVAudioUnitSampler()

    private var noteCache: UInt8? = nil
    private var chordCache: [UInt8]? = nil

    public private(set) var notes: [UInt8] = []
    public private(set) var chords: [[UInt8]] = []

    public init(key: Key = .C, noteOctaves: ClosedRange<Int> = 1...4, chordOctave: Int = 3) {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)

        setupEngine()
        loadSampleSound()

        notes = key.getMidi(noteOctaves)
        chords = [
            [48, 52, 55], // C major: C3, E3, G3
            [43, 47, 50], // G major: G2, B2, D3
            [45, 48, 52], // A minor: A2, C3, E3
            [41, 45, 48]  // F major: F2, A2, C3
        ]
        
        
    }

    private func setupEngine() {
        do {
            try engine.start()
        } catch {
            print("Couldn't start audio engine: \(error)")
        }
    }

    private func loadSampleSound() {
        let ext = "wav"
        guard let url = Bundle.module.url(forResource: "d5", withExtension: ext) else {
            print("Sample file not found")
            return
        }

        do {
            switch ext {
            case "wav":
                try sampler.loadAudioFiles(at: [url])
            case "sf2":
                try sampler.loadSoundBankInstrument(
                    at: url,
                    program: 0,
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: UInt8(kAUSampler_DefaultBankLSB))
            case "exs":
                try sampler.loadInstrument(at: url)
            default:
                print("Unsupported file type.")
            }
        } catch {
            print("Couldn't load sample: \(error)")
        }
    }

    public func send(pitch: Float, volume: Float) {
        let note = notes.noteFromFloat(pitch)
        guard note != noteCache else { return }

        if let oldNote = noteCache {
            sampler.stopNote(oldNote, onChannel: 0)
        }

        noteCache = note
        let velocity = UInt8(30 + 60 * volume)
        sampler.startNote(note, withVelocity: velocity, onChannel: 0)
    }

    public func sendChord(pitch: Float, volume: Float) {
        let chord = chords.chordFromFloat(pitch)
        guard chord != chordCache else { return }

        if let oldChord = chordCache {
            for note in oldChord {
                sampler.stopNote(note, onChannel: 1)
            }
        }

        chordCache = chord
        let velocity = UInt8(30 + 60 * volume)
        for note in chord {
            sampler.startNote(note, withVelocity: velocity, onChannel: 1)
        }
    }
}
