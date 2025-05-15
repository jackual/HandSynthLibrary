import Foundation
import Tonic
import AVFoundation

public class Synth {
    private var engine = AVAudioEngine()
    private var sampler = AVAudioUnitSampler()
    
    private var cache: [UInt8]? = nil
    
    public private(set) var chords: [[UInt8]] = []
    
    public init(_ patch: Patch) {
        chords = patch.pattern.getMidiNotes()  // Now correctly converts ChordNotes to MIDI numbers
        
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("Couldn't start audio engine: \(error)")
        }
    }
    
    public func loadURL(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        
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
            case "aupreset":
                let data = try Data(contentsOf: url)
                let preset = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]
                try sampler.loadInstrument(at: url)
            default:
                return false
            }
            return true
        } catch {
            return false
        }
    }
    
    public func send(pitch: Float, volume: Float = 1) {
        let chord = chords.chordFromFloat(pitch)
        guard chord != cache else { return }
        if let oldChord = cache {
            for note in oldChord {
                sampler.stopNote(note, onChannel: 1)
            }
        }
        cache = chord
        let velocity = UInt8(30 + 60 * volume)
        for note in chord {
            sampler.startNote(note, withVelocity: velocity, onChannel: 1)
        }
    }
    
    public func mod(_ value: Float) {
        //not tested yet !
        let ccValue = UInt8(clamping: Int(value * 127))
        sampler.sendController(1, withValue: ccValue, onChannel: 1)
    }
}
