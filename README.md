# Construct Themes Showcase

A Crestron Construct project showing all possible UI elements that are controlled by Themes.

Use it to test your themes and ensure they work as expected across all UI elements.

# Construct Version
* Crestron Construct: 2.801.22.00
* User Interface Plugin: 1.4401.12.0
* CH5 Version: 2.17.0

> [!WARNING]
> This projet is to big. Loading the CH5z in a touch panel will result in very slow performance or even crashing, even when Preload and Cache has been turn off in every page. For best results (still not ideal) upload the CH5z in a series 4 processor under **Web Pages and Mobility Projects** as a CH5 XPanel.

# Observations found while working on this projects

## SIMPL Contracts

It would have been nice to be able to assign certain cotracts as global.  IT appears that when assigning a widget to a page, the contracts generated are per page. I can see how that is important when the elements of a widget are buttons, butn when the element is something like a nav bar, that is used in several pages at once, a new contract is generated in simple under each page, which means the signals need to be duplicated between contracts.  A global setting, would bubble the contract to the top, so the signals would only need to be created and maintained in one place.



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

## Tabs

~~For some reason whenthe tabs are shown in both the touchpanel or the browser, some of them get pushed all the way up, even though they display fine under construct~~ Selecting all the offending objects and pressing the up and down arrow to make them all move up and down one step, fixed the issue


