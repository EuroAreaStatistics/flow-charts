# Flow Visualization Library Reference

# Rendering a player

The library defines a global object `FlowViz` with one method `renderPlayer`.

`renderPlayer` expects an target element selector and the data for the presentation. The flow visualization player is rendered into the given element. The selector can be any valid jQuery selector.

Example:

```js
var presentationData = {…};
FlowViz.renderPlayer('#player', presentationData);
```

This expects an empty target element with the id player is present:

```html
<div id="player"></div>
```

The `renderPlayer` method returns an object with two properties:

```js
{
  model: Backbone.Model,
  view: Backbone.View
}
```

`model` is a [Backbone.Model](http://backbonejs.org/#Model) instance, the data container. `view` is a [Backbone.View](http://backbonejs.org/#View) instance, the player view component.

```js
var player = FlowViz.renderPlayer('#player', presentationData);
console.log(player.model);
console.log(player.view);
```

# Disposing a player

The player can be properly disposed by calling:

```js
player.view.dispose();
```

This removes the player and the visualization from the DOM and removes any global event handlers.

# Loading keyframes

New keyframes can be loaded after the player has been rendered. This replaces the existing keyframes with the new keyframes and starts the player at the first keyframe again.

Use the `loadKeyframe` method of the model:

```
player.model.loadKeyframes(newKeyframes);
```

The method expects an array of keyframe objects (see below).

```js
newKeyframes = Array<keyframe>
```

Note: The new keyframes need to use the same `color`, `locale` and `typeData` configuration as the original keyframes. If you load keyframes with new data types (unilateral or bilateral) than the original keyframes, make sure that the types are present in the original `color`, `locale` and `typeData` configuration.

# Presentation Data Format

The second parameter of `renderPlayer` is an object that needs to have the following properties:

```js
presentationData = {
  // The keyframes in the presentations
  keyframes: Array<Object>,
  // Color configuration
  colors: Object,
  // UI Translations / Internationalization
  locale: Object,
  // Type information for unilateral and bilateral relations
  typeData: Object
}
```

## Keyframes (`keyframes`)

A presentation consists of several keyframes. Each keyframe represents a single set of data that is visualized in a flow chart. The player allows to navigate between the keyframes, animating the flow chart.

Each keyframe has the following properties:

```js
keyframe = {
  // The title of the keyframe as shown in the player (top left)
  title: String,
  // The date of the dataset as shown in the player (bottom center)
  date: String,
  // The data type of the bilateral relations found in the elements
  dataType: Object,
  // The data types of the unilateral indicator data found in the elements
  indicatorTypes: Array<Object> (optional),
  // The elements of the flow chart
  elements: Array<Object>,
  // The sum of incoming and outgoing relations of the largest element.
  // This is used as a reference for scaling the bars in the chart.
  // The value might be the sum of `sumIn` and `sumOut` of the largest element
  // in this keyframe or another keyframe.
  maxSum: Number
}
```

The `dataType` object has the following properties:

```js
dataType = {
  // Id of the bilateral data type for this keyframe as specified
  // in `typeData` and `locale`, e.g. `'import'`
  type: String,
  // Id of the bilateral data unit for this keyframe as specified
  // in `typeData` and `locale`, e.g. `'bln_real_dollars'`
  unit: String
}
```

The `indicatorTypes` array specifies the data types of unilateral indicator data as found in the elements. Each item is an object with the following properties:

```js
indicatorType = {
  // Id of the unilateral data type as specified in `typeData` and `locale`,
  // e.g. `'gdp'`
  type: String,
  // Id of the unilateral data unit as specified in `typeData` and `locale`,
  // e.g. `'bln_real_dollars'`
  unit: String
}
```

## Elements (`keyframes[i].elements`)

An element represents an entity with bilateral flow data and optional unilateral indicator data, for example countries, political unions, companies.

Each item in the `elements` array is an object with the following properties:

```js
element = {
  // The id of the element as specified in `locale`.
  // Used for identification and to look up the display name in `locale`.
  // e.g. `usa`
  id: String,
  // The sum of all incoming flows. Determines the sizes of the part of
  // the bar that represents the incoming flow.
  sumIn: Number,
  // The sum of all outgoing flows. Determines the sizes of the part of
  // the bar that represents the incoming flow.
  sumOut: Number,
  // Outgoing relations to other elements present in the keyframe.
  outgoing: Object (optional),
  // Incoming relations from other elements NOT present in the keyframe
  // (therefore they can’t be specified as `outgoing` relations of the partner)
  incoming: Object (optional),
  // Element ids with missing data for outgoing relations.
  // Used when `sumOut` is 0 to denounce the actual value isn’t actually 0
  // but data is just unknown or missing.
  noOutgoing: Array<String> (optional),
  // Element ids with missing data for incoming relations.
  noIncoming: Array<String> (optional),
  // Indicates missing relation data.
  missingRelations: Object (optional),
  // Unilateral indicator data for this element
  indicators: Array (optional)
}
```

`outgoing` and `incoming` are objects with element ids as keys and flow amounts as values, e.g.

```js
outgoing = {
  usa: 1234.5678
}
```

`missingRelations` is an object with element ids (relation source / from) as keys and element ids (relation target / to) as values, e.g.

```js
missingRelations = {
  usa: 'deu'
}
```

## Indicator data (`keyframes[i].elements[j].indicators`)

`indicators` is an array with unilateral indicator values for an element. This can be used to show additional non-flow data in the chart next to the element bars. For example, if the flow data is import, an indicator value might be GDP for comparison.

The order in the `indicators` array is meaningful: It needs to be the same order as in the `indicatorTypes` array in the keyframe. For example, if indicatorTypes is `[ { type: 'gdp', unit: 'bln_real_dollars' } ]`, the first item in `indicators` needs to the GDP value.

Each item in the `indicators` array is an object with the following properties:

```js
indicator = {
  // The indicator value
  value: Number,
  // Change from the previous time period’s value for displaying
  // a tendency arrow. May have five values:
  // 2: Heavy increase
  // 1: Slight increase
  // 0: Steady
  // -1: Slight decline
  // -2: Heavy decline
  tendency: Number,
  // Change from the previous time period’s value in percent
  tendencyPercent: Number,
  // Whether the value is missing for this time period.
  missing: Boolean (optional)
}
```

## Color configuration (`colors`)

The `colors` is an object with color names as keys and color values as values (except for the complex `magnets` property).

The color values must be valid CSS / SVG colors, e.g. `green`, `#0f0` or `#00FF00`.

```js
colors = {
  // Main foreground color, e.g. 'black'
  fg: String
  // Main background color / inverted foreground color; e.g. 'white'
  bg: String,

  // Bar colors (split into two)
  magnets: Object,
  // Color if the text on top of the bar if the value is missing
  magnetMissingValueFg: String,
  // Color for the bar if the value is missing
  magnetMissingValueBg: String,

  // Main relation color in highlight mode.
  // The normal mode is the same color with a lower opacity.
  relation: String,

  // Color of the indicator circle
  indicatorCirclePositive: String,
  // Color of the indicator circle, negative values
  indicatorCircleNegative: String,
  // Color of the indicator percent arc (for percent values)
  indicatorPercentArc: String,
  // Color of the circle on top of the indicator percent arc
  indicatorPercentMiddle: String,
  // Color of the indicator tendency arrow
  tendencyArrow: String
}
```

`magnets` contains the colors for the different bilateral data types, as used for the bars. `magnets` is an object with data type ids as keys and objects as values. Each value is an object with `outgoing` and `incoming`, the two colors of the incoming and the outgoing bar part.

```js
magnets = {
  [typeId]: {
    outgoing: String,
    incoming: String,
  }
}

```

## UI Translations / Internationalization (`locale`)

`locale` contains all internationalization settings, e.g. number formatting, element names, type names and UI labels.

Some labels may contain placeholders in the form `%{placeholderName}` which are replaced with values in the UI.

See the example file `locale.js` for a full list of settings. Most of them are self-explanatory, some need explanation:

```js
locale = {
  // Displayed names for the entities of the data flow.
  // Keys are element ids, values are displayed names.
  // e.g. { usa: 'United States' }
  entityNames: Object,
  // Displayed name for the bilateral data types.
  // Keys are data type ids, values are displayed names.
  // e.g. { import: 'Trade' }
  dataType: Object,
  // Labels that describe the flow of bilateral data types.
  flow: Object,
  // Long description of bilateral data flow
  data: Object,
  // Description of the units for both unilateral and bilateral data
  units: Object,
  // Sources for the data as shown in the legend.
  sources: Object,
  // …
}
```

The `flow` labels describe the flow from the perspective of the incoming or outgoing element. `flow` is an object with data type ids as keys and objects with three string labels as values:

```js
flow = {
  [typeId]: {
    // Flow from the outgoing perspective, e.g. 'Export'
    outgoing: String,
    // Flow from the incoming perspective, e.g. 'Import'
    incoming: String,
    // Sentence with a verb and the flow partners
    // e.g. 'exported from %{from} to %{to}'
    fromTo: String with the placeholders %{from} and %{to}
  }
}
```

The `data` labels are long descriptions of the bilateral data types used in the chart legend. `data` is an object with data type ids as keys and objects with two string labels as values:

```js
data = {
  [typeId]: {
    // Legend describing the bars
    magnet: String with the placeholders %{date} and %{unit},
    // Legend describing the relation arrows
    flow: String with the placeholder %{unit}
  }
}
```

The `unit` labels are used whereever bilateral or unilateral data values are shown. `unit` is an object with data unit ids as keys and objects with four string labels as values:

```js
unit = {
  [unitId]: {
    // Short description of the unit
    short: String,
    // Long description of the unit
    full: String,
    // Template for displaying a formatted value.
    value: String with the placeholder %{number},
    // Template for displaying a formatted value as HTML.
    // May contain HTML markup.
    value: String with the placeholder %{number}
 }
}
```

The `sources` contain names and links to sources where the data has been obtained from. This information is shown in the chart legend. `sources` is an object with two properties, `data` for bilateral data and `indicator` for unilateral data. For each type id, they contain an object with `name` and `url`:

```js
sources = {
  // Bilateral flow data sources
  data: {
    [typeId]: {
      // Source name
      name: String,
      // Source HTTP URL
      url: String,
    }
  },
  // Unilateral indicator sources
  indicator: {
    [typeId]: {
      // Source name
      name: String,
      // Source HTTP URL
      url: String
    }
  }
}
```

## Type data (`typeData`)

`typeData` contains metadata for units used in the keyframes, both for bilateral and unilateral data. Currently, units can be absolute (e.g. 12.3 billion USD) or proportional (e.g. 12.3%).

`typeData` is an object with one property:

```js
typeData = {
  // Metadata for the units
  units: Object
}
```

`units` is an object with unit ids as keys and objects with one property as values:

```js
units = {
  [unitId]: {
    representation: String, either 'absolute' or 'proportional'
  }
}
```

Typically, bilateral data units are `'absolute'` while unilateral data units are `'absolute'` or `'proportional'`.
