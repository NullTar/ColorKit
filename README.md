# ColorKit

A collection of useful SwiftUI Color extensions for color conversion, serialization, manipulation, and harmony generation.

ColorToolkit provides a convenient way to work with SwiftUI colors, including HEX conversion, Codable support, color inversion, and color harmony generation.

## Features

HEX Conversion – Convert between SwiftUI Color and hexadecimal color strings.

Codable Support – Encode and decode SwiftUI colors through the Colour representation.

Color Inversion – Generate inverted colors while preserving opacity.

Color Harmony – Generate complementary, analogous, triadic, split-complementary, tetradic, and square color schemes.

Cross-Platform – Supports iOS and macOS.


## Swift Package Manager
Add this package to your `Package.swift`:

dependencies: [
    .package(url: "https://github.com/NullTar/ColorKit.git")
]

Or add it in Xcode:
`File > Add Package Dependencies`
Paste repo url: `https://github.com/NullTar/ColorKit.git`

## Usage

```swift
import ColorKit
```

1. HEX Conversion

Convert a hexadecimal color string into SwiftUI Color.
```swift
let color = Color.fromHex("#FF5733")
let colorWithAlpha = Color.fromHex("#FF573380")
```

Convert a SwiftUI Color into a hexadecimal string.
```swift
let hex = color.toHex()
// #FF5733FF

let hexWithoutAlpha = color.toHex(true, false)
// #FF5733

let hexWithoutPrefix = color.toHex(false, true)
// FF5733FF

let all = color.toHex(true, true)
// #FF5733FF

```

2. Codable Support

SwiftUI Color does not directly conform to Codable.

ColorToolkit provides Colour, a Codable representation that stores color components, color space information, and alpha values.

Convert SwiftUI Color into Colour:

```swift
let color = Color.red.toColour()
```

Convert Colour back into SwiftUI Color:

```swift
let restoredColor = colour.toColor()
```

Encode and decode:

```swift
let colour = Color.blue.toColour()

let encoder = JSONEncoder()
let data = try encoder.encode(colour)

let decoder = JSONDecoder()
let decodedColour = try decoder.decode(Colour.self, from: data)

let restoredColor = decodedColour.toColor()
```

3. Color Inversion

Generate an inverted color while preserving its original opacity.

```swift
let inverted = Color.black.inverted()
```
RGB components are individually inverted using 1 - component.

4. Color Harmony

Generate harmonious color schemes based on the color wheel.

Available harmony methods:
| Method | Hue Rotation | Generated Colors |
|---|---|---:|
| `complementary()` | 180° | 1 |
| `analogous()` | ±30° | 2 |
| `triadic()` | 120°, 240° | 2 |
| `splitComplementary()` | 150°, 210° | 2 |
| `tetradic()` | 60°, 180°, 240° | 3 |
| `square()` | 90°, 180°, 270° | 3 |

Analogous and split-complementary methods support custom angles:

```swift
let analogous = color.analogous(angle: 45)
let split = color.splitComplementary(angle: 20)
```
Harmony generation preserves the original saturation, brightness, and opacity while adjusting the hue.



