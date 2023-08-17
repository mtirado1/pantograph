# Pantograph

Pantograph is a Lua DSL and command line tool for generating programmatic animations. It was developed for *The Mathematics of Kinematic Chains*, entry for the 2023 Summer of Math Exposition (SoME3).

## Requirements

* Lua 5.1+
* `ffmpeg`
* `rsvg-convert`

## How it works

### Video Rendering

Pantograph renders each frame as an SVG file, then it uses rsvg-convert to rasterize them, piping them to ffmpeg, generating an video file.

Lua does not do any of the rendering work, it merely outputs SVG and makes use of external commands to do the file format conversions and video rendering.

## Usage

`./anim file1.lua file2.lua -o output_file.mp4`

## Examples

You can see the animatons used for the SoME3 entry in `some3/`. Note that they make heavy use of `mechanics.lua`.

## Documentation

Work in Progress

## Limitations

* Has only been used on Linux.
* The limitations of SVG rendering libraries make complex text drawing difficult.
* No LaTeX rendering.
