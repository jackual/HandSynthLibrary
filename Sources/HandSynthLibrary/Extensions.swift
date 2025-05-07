//
//  Extensions.swift
//  HandSynthLibrary
//
//  Created by Jack Brodie on 02/05/2025.
//

import Tonic

public extension Note {
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

public extension Chord {
    func getMidi(_ octave: Int) -> [UInt8] {
        var midiNoteNumbers: [UInt8] = []
        
        self.noteClasses.forEach({ NoteClass in
            midiNoteNumbers.append(UInt8(NoteClass.canonicalNote.noteNumber))
        })
        
        return midiNoteNumbers
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

public extension Note {
    public func getMidi(_ octave: Int) -> UInt8 {
        return UInt8(self.toOct(octave).pitch.midiNoteNumber)
    }
}

public extension Note {
    var description: String {
        return "\(letter)\(accidental)"
    }
}
