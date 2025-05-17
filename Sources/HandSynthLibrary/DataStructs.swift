//
//  DataStructs.swift
//  HandSynthTesting
//
//  Created by Jack Brodie on 01/05/2025.
//

import Foundation
import Tonic

public struct ChordNote {
    public let note: Note
    public let octave: Int
    
    public init(note: Note, octave: Int) {
        self.note = note
        self.octave = octave
    }
    
    public var midiNoteNumber: UInt8 {
        return note.getMidi(octave)
    }
}

public struct Pattern {
    public let name: String
    public let key: Key           // No longer optional
    public let octBound: ClosedRange<Int>  // No longer optional
    public let patternNotes: [[ChordNote]]
    
    public init(name: String, key: Key, octBound: ClosedRange<Int>, patternNotes: [[ChordNote]]) {
        self.name = name
        self.key = key
        self.octBound = octBound
        self.patternNotes = patternNotes
    }
    
    public func getMidiNotes() -> [[UInt8]] {
        return patternNotes.map { chord in
            chord.map { $0.midiNoteNumber }
        }
    }
}

public struct PatchConfig {
    public let defaultMod: Float
    public let tie: Bool
    public let volume: Float
    public let name: String
    
    public init(name: String, defaultMod: Float = 0, tie: Bool = true, volume: Float = 1) {
        self.name = name
        self.defaultMod = defaultMod
        self.tie = tie
        self.volume = volume
    }
}

public enum FileExtension: String {
    case aupreset, exs, wav, wave, aif, aiff, caf, sf, sf2
    
    var formatDescription: String {
        switch self {
        case .aupreset:
            return "AUPreset"
        case .exs:
            return "EXS-24 File"
        case .wav, .wave:
            return "Wave File"
        case .aif, .aiff:
            return "AIFF File"
        case .caf:
            return "CAF File"
        case .sf:
            return "SoundFont File"
        case .sf2:
            return "SoundFont 2 File"
        }
    }
}

public struct PatchMetadata {
    public let desc: String?
    public let titleHumanReadable: String?
    public let author: String?
    
    public init(desc: String?, titleHumanReadable: String?, author: String?) {
        self.desc = desc
        self.titleHumanReadable = titleHumanReadable
        self.author = author
    }
}

public struct Preset {
    public let filename: String
    public let ext: FileExtension
    
    public init(filename: String, ext: FileExtension) {
        self.filename = filename
        self.ext = ext
    }

    public var filenameFull: String {
        return "\(filename).\(ext.rawValue)"
    }
    
    public var formatHumanReadable: String {
        return ext.formatDescription
    }
}

public struct Patch {
    public let pattern: Pattern
    public let config: PatchConfig
    public let preset: Preset
    public let metadata: PatchMetadata?
    
    public init(pattern: Pattern, config: PatchConfig, preset: Preset, metadata: PatchMetadata?) {
        self.pattern = pattern
        self.config = config
        self.preset = preset
        self.metadata = metadata
    }
}
