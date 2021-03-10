# Introduction

Semblage is an open source 3D CAD application that seeks to blend the mouse-driven and programmatic CAD worlds. To get an idea of where Semblage is headed in the future, have a look at the [roadmap](roadmap.md). However, Semblage needs a firm foundation first, with stable core functionality and UX in mind. That is the current focus of this project.

## Features

* 2D sketching with preview
* 3D operations (extrude, cut, etc)
* Export for manufacturing: STEP, STL and SVG, with DXF and AMF on the way

## Goals

The high-level goals of Semblage are as follows.

* Focused on desktop manufacturing, hobbyists, makerspaces, etc.
* Mouse driven as much as possible, doing more with mouse interaction as time progresses without losing the depth of control the user has.
* Keep the highly parametric nature of CadQuery available through the user interface.
* Provide the user with the full depth of scripted CAD when they want/need it.
* Be able to export to formats that are useful for desktop and makerspace manufacturing, such as 3D printing, laser cutting, CNC routing, vinyl cutting, etc.
* Generated CadQuery code should be portable and standard, and capable of be being run from the command line.

## Terms

* ***Component*** - Can be a 2D sketch, a face, a solid, or (eventually) an assembly. Eventually it will be possible for components to be used together, as in the case of a sweep operation, or nested within each other to build assemblies.
* ***CadQuery*** - A Python based CAD scripting API that is at the heart of Semblage. CadQuery is good at capturing design intent with features like selectors, and is capable of creating very powerful, highly parametric design scripts.
* ***Script*** - A collection of statements that are executed when needed, rather than compiled into a binary program. Semblage uses the CadQuery CAD scripting API to generate models. Each Semblage component is simply a CadQuery Python script. This has multiple advantages, including making it easier to track CAD models within a code versioning system like git. It can bring security challenges with it as well, which is why Semblage will prompt you with a warning if the component script you are opening imports anything more than the standard CadQuery packages.

## What To Expect

Semblage is in alpha at this time, so core features may be missing or broken. Use at your own risk.

The operations available in Semblage have not been annotated with documentation yet, but have been derived directly from their CadQuery counterparts. The [CadQuery documentation](https://cadquery.readthedocs.io/en/latest/) can be a stand-in until annotations are available, and will be useful for advanced Semblage usage even after annotations are avaialble.

Here is a list of currently missing features that users may find limiting. Each item in this list can be read as a "not yet" item. The goal is to implement all of the missing features below over time.

* 2D sketches are not visualized in the main 3D view. After adding a 2D sketch it appears as if nothing happened. Looking in the history tree at the left, users will see the 2D operation though, and can continue adding new operations (i.e. extrude).
* Multiple items cannot be selected at once yet, making boolean operations and operations like sweep and loft unavailable.
* Features of the model (edges, vertices, faces) cannot be selected yet.
* Selector definition is not mouse-driven at this time. Selectors must be set up manually.
* 2D sketching with preview is available in the Operations dialog, but is not mouse driven at this time.
* 2D sketching does not include constraints.
* 3D assembly is not available yet.
* Some export formats (notably DXF) are not available yet.

A good next step from here is to continue to the [Installation](installation.md) documentation.
