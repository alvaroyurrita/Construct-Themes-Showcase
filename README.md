# Construct Themes Showcase

A Crestron Construct project showing all possible UI elements that are controlled by Themes.

Use it to test your themes and ensure they work as expected across all UI elements.

# Construct Version
* Crestron Construct: 2.801.22.00
* User Interface Plugin: 1.4401.12.0
* CH5 Version: 2.17.0

# Issues found while working on this projects

## Slider Advanced Ticks

Ticks need to be entered exactly as explained [here](https://sdkcon78221.crestron.com/downloads/ShowcaseApp/ch5-slider/ticks.html):

```
Defines the ticks on the slider. The value should be a valid JSON string.

The slider uses advanced tick scales: non-linear or logarithmic.

Sliders can be created with ever-increasing increments by specifying the value for the slider at certain intervals.

The first value defines the % position along the length of the slider scale to place a tick mark.
The second value is the label value to place next to the tick at that position.
An example would be ticks='{"0":"-60", "25":"-40", "50":"-20", "75":"-10", "100": "0" }'

When using ticks, attributes like min, max, and step are ignored.
```

It would have been nice if it could figure it out from min, max, and step automatically. But I guess this is necessary to accommodate for non-linear scales.

## Slider Advanced 

The Slider theme does not support theming the following slider component
* Slider Button (ON OFF)
    * Button Style
    * Shape
    * Label
* Slider Title
    * Content


