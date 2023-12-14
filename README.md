# Pantograph

Pantograph is a Lua DSL and command line tool for generating programmatic animations. It was developed for *The Mathematics of Kinematic Chains*, entry for the 2023 Summer of Math Exposition (SoME3).

## Installation

Edit `install.sh` to customize the Lua module and script installation paths, then run it.

### Requirements

* Lua 5.1+
* `ffmpeg`
* `rsvg-convert`

For LaTeX rendering (optional)

* `pdflatex`
* `pdfcrop`
* `pdf2svg`

## How it works

### Video Rendering

Pantograph renders each frame as an SVG file, then it uses rsvg-convert to
rasterize them, piping them to ffmpeg, generating an video file.

Lua does not do any of the rendering work, it merely outputs SVG and makes use
of external commands to do the file format conversions and video rendering.

### LateX equations

Pantograph uses external commands to convert LaTeX equations to SVG. temporary
files are stored in `~/.config/pantograph`

## Usage

```
$ pantograph file1.lua file2.lua -o output_file.mp4
```

The flags `---width`, `--height` and `--scale` can be used to set the size of the animation.

For example, the following set of options will render SVG frames with a size ox 800x600 but generate a video with a resolution of 1600x1200

```
$ pantograph animation.lua --width 800 --height 600 --scale 2 -o render.mp4
```

Frames per second can be adjusted with the `--fps` flag.

## Examples

The [examples](examples) folder contains a set of scripts and their respective animations.

You can see the animations used for the SoME3 entry in the now outdated
**some3** branch. Note that they make heavy use of `mechanics.lua`.

## Documentation

Work in Progress

## Limitations

* Has only been used on Linux.
* The limitations of SVG rendering libraries make complex text drawing difficult.
