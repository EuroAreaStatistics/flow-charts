var exampleLocale = {
  "language_name": "English",
  "decimal_mark": ".",
  "thousands_separator": ",",
  "thousands_separator_html": ",",
  "not_available": "N/A",
  "enum_separator": ", ",
  "enum_separator_last": " and ",
  "value_in_unit": "in %{unit}",
  "entityNames": {
    "arg": "Argentina",
    "aus": "Australia",
    "aut": "Austria",
    "bel": "Belgium",
    "bgr": "Bulgaria",
    "bra": "Brazil",
    "can": "Canada",
    "che": "Switzerland",
    "chl": "Chile",
    "chn": "China",
    "cyp": "Cyprus",
    "cze": "Czech Republic",
    "deu": "Germany",
    "dnk": "Denmark",
    "esp": "Spain",
    "est": "Estonia",
    "fin": "Finland",
    "fra": "France",
    "gbr": "United Kingdom",
    "grc": "Greece",
    "hrv": "Croatia",
    "hun": "Hungary",
    "ind": "India",
    "irl": "Ireland",
    "isl": "Iceland",
    "isr": "Israel",
    "ita": "Italy",
    "jpn": "Japan",
    "kor": "Korea",
    "ltu": "Lithuania",
    "lux": "Luxembourg",
    "lva": "Latvia",
    "mex": "Mexico",
    "mlt": "Malta",
    "nld": "Netherlands",
    "nor": "Norway",
    "nzl": "New Zealand",
    "pol": "Poland",
    "prt": "Portugal",
    "rou": "Romania",
    "rus": "Russian Federation",
    "svk": "Slovakia",
    "svn": "Slovenia",
    "swe": "Sweden",
    "tur": "Turkey",
    "usa": "United States",
    "zaf": "South Africa"
  },
  "dataType": {
    "import": "Trade"
  },
  "flow": {
    "import": {
      "incoming": "Import",
      "outgoing": "Export",
      "fromTo": "exported from %{from} to %{to}"
    }
  },
  "legend": {
    "sources": "Sources",
    "legend": "Legend",
    "about_heading": "About",
    "about_body": "<p>This slideshow uses the Flow Visualization Library based on the source code of <a href='https://github.com/bertelsmannstift/GED-VIZ' target='_blank'>GED VIZ</a>.</p>",
    "toggle_open": "more",
    "toggle_close": "less",
    "close": "close",
    "indicatorIcon": {
      "absolute": "Bubble size relative to largest indicator value.",
      "proportional": "Ring segment indicates percentage."
    },
    "tendency": "Tendency arrows indicate change to previous year's value<br>(i) for absolute values: relative change;<br>(ii) for percentage values: difference in percent points.",
    "maximum_size": "max. size"
  },
  "data": {
    "import": {
      "magnet": "%{date} Merchandise exports/imports to/from all available countries in %{unit} as reported by import countries’ statistics.<br>Bar lengths relative to largest sum of imports and exports (among displayed countries for all years).",
      "flow": "Merchandise exports/imports in %{unit}"
    }
  },
  "indicators": {
    "gdp": {
      "short": "GDP",
      "full": "Gross Domestic Product"
    },
    "population": {
      "short": "POP",
      "full": "Population"
    }
  },
  "units": {
    "bln_current_dollars": {
      "short": "billion $",
      "full": "billion US-$ (current prices)",
      "value": "$ %{number}bn",
      "value_html": "<span class='unit'>$</span><span class='value'>%{number}</span><span class='suffix'>bn</span>"
    },
    "bln_real_dollars": {
      "short": "billion $",
      "full": "billion US-$ (constant prices, base 2005)",
      "value": "$ %{number}bn",
      "value_html": "<span class='unit'>$</span><span class='value'>%{number}</span><span class='suffix'>bn</span>"
    },
    "mln_persons": {
      "short": "million",
      "full": "million persons",
      "value": "%{number}m",
      "value_html": "<span class='value'>%{number}</span><span class='suffix'>m persons</span>"
    }
  },
  "sources": {
    "data": {
      "import": {
        "name": "UN Comtrade",
        "url": "http://comtrade.un.org/"
      }
    },
    "indicator": {
      "gdp": {
        "name": "OECD/European Commission",
        "url": "http://www.oecd.org/statistics/"
      },
      "population": {
        "name": "OECD/European Commission",
        "url": "http://www.oecd.org/statistics/"
      }
    }
  },
  "contextbox": {
    "relation": {
      "import": "In %{date} %{from} exported %{value} %{unit} worth of goods to %{to}.",
      "claims": "In %{date} %{to} owed %{value} %{unit} to banks in %{from}.",
      "migration": "In %{date} %{value} %{unit} migrated from %{from} to %{to}.",
      "missing": {
        "intro": "Some data sets are not available:",
        "entry": "From %{source} to %{targets}"
      }
    },
    "relationPercentage": {
      "import": "This represented %{percentFrom} of exports from %{from} in all available countries and %{percentTo} of imports to %{to} from all available countries.",
      "claims": "This represented %{percentFrom} of bank claims from %{from} against all available countries and %{percentTo} of debt of %{to} to banks in all available countries.",
      "migration": "This represented %{percentFrom} of emigrants from %{from} to all available countries and %{percentTo} of immigrants to  %{to} from all available countries.",
    },
    "magnet": {
      "import": "In %{date} %{name} imported %{sumIn} %{unit} worth of goods from all available countries and exported %{sumOut} %{unit} worth of goods to all available countries."
    },
    "magnet_missing": {
      "outgoing": {
        "import": "No export data available for %{list}.",
        "claims": "No claim data available for %{list}.",
        "migration": "No emigration data available for %{list}."
      },
      "incoming": {
        "import": "No import data available for %{list}.",
        "claims": "No debt data available for %{list}.",
        "migration": "No immigration data available for %{list}."
      }
    }
  },
  "chart": {
    "element_count_error": "Please select at least one country or country group.",
    "keyframe_subtitle": "%{dataType} %{date}"
  },
  "player": {
    "play": "Play",
    "previous_keyframe": "Previous",
    "next_keyframe": "Next",
    "fullscreen": "Fullscreen"
  },
  "magnet": {
    "one_to_one_others": "others"
  }
};
