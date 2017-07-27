var exampleKeyframes = [
  {
    "title": "First keyframe",
    "date": "2010",
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "elements": [
      {
        "id": "usa",
        "sumIn": 1561.4725,
        "sumOut": 963.1993,
        "outgoing": {
          "chn": 102.7342,
          "fra": 35.2346
        },
        "incoming": {},
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {}
      },
      {
        "id": "chn",
        "sumIn": 823.5422,
        "sumOut": 1326.0545,
        "outgoing": {
          "usa": 382.9538,
          "fra": 48.8727
        },
        "incoming": {},
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {}
      },
      {
        "id": "fra",
        "sumIn": 564.6641,
        "sumOut": 477.5866,
        "outgoing": {
          "chn": 24.1245,
          "usa": 42.4884
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 2524.6718
  },
  {
    "title": "Second keyframe",
    "date": 2010,
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "indicatorTypes": [
      {
        "type": "gdp",
        "unit": "bln_real_dollars"
      },
      {
        "type": "population",
        "unit": "mln_persons"
      }
    ],
    "elements": [
      {
        "id": "usa",
        "sumIn": 1561.4725,
        "sumOut": 963.1993,
        "indicators": [
          {
            "value": 13595.64,
            "tendency": 0.0,
            "tendencyPercent": 0.0251,
            "missing": false
          },
          {
            "value": 309.776,
            "tendency": 0.0,
            "tendencyPercent": 0.0083,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 35.2346,
          "deu": 59.5936,
          "jpn": 69.1147,
          "chn": 102.7342
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "chn",
        "sumIn": 823.5422,
        "sumOut": 1326.0545,
        "indicators": [
          {
            "value": 3890.9243,
            "tendency": 2.0,
            "tendencyPercent": 0.1045,
            "missing": false
          },
          {
            "value": 1337.938,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 48.8727,
          "deu": 101.3771,
          "jpn": 153.2032,
          "usa": 382.9538
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "jpn",
        "sumIn": 437.482,
        "sumOut": 565.1927,
        "indicators": [
          {
            "value": 4657.7154,
            "tendency": 1.0,
            "tendencyPercent": 0.0465,
            "missing": false
          },
          {
            "value": 128.057,
            "tendency": 0.0,
            "tendencyPercent": 0.0043,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 11.7193,
          "deu": 29.2324,
          "usa": 123.556,
          "chn": 176.7361
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "deu",
        "sumIn": 979.7763,
        "sumOut": 1079.7145,
        "indicators": [
          {
            "value": 2955.5343,
            "tendency": 1.0,
            "tendencyPercent": 0.0401,
            "missing": false
          },
          {
            "value": 81.757,
            "tendency": 0.0,
            "tendencyPercent": -0.0014,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 19.2915,
          "chn": 74.2513,
          "usa": 84.3623,
          "fra": 103.4339
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "fra",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 10.3006,
          "chn": 17.1166,
          "usa": 39.1786,
          "deu": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 3013.3583,
    "indicatorBounds": [
      [
        0.0,
        14231.57
      ],
      [
        0.0,
        1351.114
      ]
    ],
    "locking": null
  },
  {
    "title": "Third keyframe",
    "date": 2012,
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "indicatorTypes": [
      {
        "type": "gdp",
        "unit": "bln_real_dollars"
      },
      {
        "type": "population",
        "unit": "mln_persons"
      }
    ],
    "elements": [
      {
        "id": "usa",
        "sumIn": 1857.0767,
        "sumOut": 1156.2816,
        "indicators": [
          {
            "value": 14231.57,
            "tendency": 0.0,
            "tendencyPercent": 0.0278,
            "missing": false
          },
          {
            "value": 314.278,
            "tendency": 0.0,
            "tendencyPercent": 0.0072,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 42.3641,
          "deu": 66.5569,
          "jpn": 78.2128,
          "chn": 133.7658
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "chn",
        "sumIn": 1034.759,
        "sumOut": 1514.2074,
        "indicators": [
          {
            "value": 4580.0157,
            "tendency": 1.0,
            "tendencyPercent": 0.077,
            "missing": false
          },
          {
            "value": 1351.114,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 53.037,
          "deu": 100.6758,
          "jpn": 188.4348,
          "usa": 444.4072
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "jpn",
        "sumIn": 536.286,
        "sumOut": 606.3587,
        "indicators": [
          {
            "value": 4721.0867,
            "tendency": 0.0,
            "tendencyPercent": 0.0196,
            "missing": false
          },
          {
            "value": 127.515,
            "tendency": 0.0,
            "tendencyPercent": -0.0022,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 11.7574,
          "deu": 29.8566,
          "usa": 150.4011,
          "chn": 177.8323
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "deu",
        "sumIn": 1068.9207,
        "sumOut": 1196.6634,
        "indicators": [
          {
            "value": 3075.0839,
            "tendency": 0.0,
            "tendencyPercent": 0.0069,
            "missing": false
          },
          {
            "value": 81.917,
            "tendency": 0.0,
            "tendencyPercent": 0.0017,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 24.7054,
          "chn": 91.9331,
          "usa": 110.6028,
          "fra": 114.5816
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "fra",
        "sumIn": 564.6641,
        "sumOut": 477.5866,
        "indicators": [
          {
            "value": 2250.3428,
            "tendency": 0.0,
            "tendencyPercent": 0.0001,
            "missing": false
          },
          {
            "value": 65.4334,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 12.8306,
          "chn": 24.1245,
          "usa": 42.4884,
          "deu": 83.2407
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 3013.3583,
    "indicatorBounds": [
      [
        0.0,
        14231.57
      ],
      [
        0.0,
        1351.114
      ]
    ],
    "locking": null
  },
  {
    "title": "Fourth keyframe",
    "date": 2012,
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "indicatorTypes": [
      {
        "type": "gdp",
        "unit": "bln_real_dollars"
      },
      {
        "type": "population",
        "unit": "mln_persons"
      }
    ],
    "elements": [
      {
        "id": "usa",
        "sumIn": 1857.0767,
        "sumOut": 1156.2816,
        "indicators": [
          {
            "value": 14231.57,
            "tendency": 0.0,
            "tendencyPercent": 0.0278,
            "missing": false
          },
          {
            "value": 314.278,
            "tendency": 0.0,
            "tendencyPercent": 0.0072,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 42.3641,
          "deu": 66.5569,
          "jpn": 78.2128,
          "chn": 133.7658
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "chn",
        "sumIn": 1034.759,
        "sumOut": 1514.2074,
        "indicators": [
          {
            "value": 4580.0157,
            "tendency": 1.0,
            "tendencyPercent": 0.077,
            "missing": false
          },
          {
            "value": 1351.114,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 53.037,
          "deu": 100.6758,
          "jpn": 188.4348,
          "usa": 444.4072
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "jpn",
        "sumIn": 536.286,
        "sumOut": 606.3587,
        "indicators": [
          {
            "value": 4721.0867,
            "tendency": 0.0,
            "tendencyPercent": 0.0196,
            "missing": false
          },
          {
            "value": 127.515,
            "tendency": 0.0,
            "tendencyPercent": -0.0022,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 11.7574,
          "deu": 29.8566,
          "usa": 150.4011,
          "chn": 177.8323
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "fra",
        "sumIn": 564.6641,
        "sumOut": 477.5866,
        "indicators": [
          {
            "value": 2250.3428,
            "tendency": 0.0,
            "tendencyPercent": 0.0001,
            "missing": false
          },
          {
            "value": 65.4334,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 12.8306,
          "chn": 24.1245,
          "usa": 42.4884,
          "deu": 83.2407
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "deu",
        "sumIn": 1068.9207,
        "sumOut": 1196.6634,
        "indicators": [
          {
            "value": 3075.0839,
            "tendency": 0.0,
            "tendencyPercent": 0.0069,
            "missing": false
          },
          {
            "value": 81.917,
            "tendency": 0.0,
            "tendencyPercent": 0.0017,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 24.7054,
          "chn": 91.9331,
          "usa": 110.6028,
          "fra": 114.5816
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 3013.3583,
    "indicatorBounds": [
      [
        0.0,
        14231.57
      ],
      [
        0.0,
        1351.114
      ]
    ],
    "locking": null
  },
  {
    "title": "Fifth keyframe",
    "date": 2012,
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "indicatorTypes": [
      {
        "type": "gdp",
        "unit": "bln_real_dollars"
      },
      {
        "type": "population",
        "unit": "mln_persons"
      }
    ],
    "elements": [
      {
        "id": "usa",
        "sumIn": 1857.0767,
        "sumOut": 1156.2816,
        "indicators": [
          {
            "value": 14231.57,
            "tendency": 0.0,
            "tendencyPercent": 0.0278,
            "missing": false
          },
          {
            "value": 314.278,
            "tendency": 0.0,
            "tendencyPercent": 0.0072,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 42.3641,
          "jpn": 78.2128,
          "chn": 133.7658
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "chn",
        "sumIn": 1034.759,
        "sumOut": 1514.2074,
        "indicators": [
          {
            "value": 4580.0157,
            "tendency": 1.0,
            "tendencyPercent": 0.077,
            "missing": false
          },
          {
            "value": 1351.114,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 53.037,
          "jpn": 188.4348,
          "usa": 444.4072
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "jpn",
        "sumIn": 536.286,
        "sumOut": 606.3587,
        "indicators": [
          {
            "value": 4721.0867,
            "tendency": 0.0,
            "tendencyPercent": 0.0196,
            "missing": false
          },
          {
            "value": 127.515,
            "tendency": 0.0,
            "tendencyPercent": -0.0022,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 11.7574,
          "usa": 150.4011,
          "chn": 177.8323
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "fra",
        "sumIn": 564.6641,
        "sumOut": 477.5866,
        "indicators": [
          {
            "value": 2250.3428,
            "tendency": 0.0,
            "tendencyPercent": 0.0001,
            "missing": false
          },
          {
            "value": 65.4334,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 12.8306,
          "chn": 24.1245,
          "usa": 42.4884
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 3013.3583,
    "indicatorBounds": [
      [
        0.0,
        14231.57
      ],
      [
        0.0,
        1351.114
      ]
    ],
    "locking": null
  },
  {
    "title": "Fifth keyframe",
    "date": 2012,
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "indicatorTypes": [],
    "elements": [
      {
        "id": "usa",
        "sumIn": 1857.0767,
        "sumOut": 1156.2816,
        "indicators": [],
        "outgoing": {
          "chn": 133.7658
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "chn",
        "sumIn": 1034.759,
        "sumOut": 1514.2074,
        "indicators": [],
        "outgoing": {
          "usa": 444.4072
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 3013.3583,
    "indicatorBounds": [],
    "locking": null
  },
  {
    "title": "Sixth keyframe",
    "date": 2012,
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "indicatorTypes": [],
    "elements": [
      {
        "id": "usa",
        "sumIn": 0,
        "sumOut": 1156.2816,
        "indicators": [],
        "outgoing": {
          "jpn": 444.4072,
          "chn": 133.7658
        },
        "noIncoming": ["usa"],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "jpn",
        "sumIn": 1034.759,
        "sumOut": 1514.2074,
        "indicators": [],
        "outgoing": {
          "chn": 217.0238
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "chn",
        "sumIn": 1034.759,
        "sumOut": 0,
        "indicators": [],
        "outgoing": {},
        "noIncoming": [],
        "noOutgoing": ["chn"],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 3013.3583,
    "indicatorBounds": [],
    "locking": null
  },
  {
    "title": "Seventh keyframe",
    "date": 2010,
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "indicatorTypes": [
      {
        "type": "gdp",
        "unit": "bln_real_dollars"
      },
      {
        "type": "population",
        "unit": "mln_persons"
      }
    ],
    "elements": [
      {
        "id": "usa",
        "sumIn": 1561.4725,
        "sumOut": 963.1993,
        "indicators": [
          {
            "value": 13595.64,
            "tendency": 0.0,
            "tendencyPercent": 0.0251,
            "missing": false
          },
          {
            "value": 309.776,
            "tendency": 0.0,
            "tendencyPercent": 0.0083,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 35.2346,
          "deu": 59.5936,
          "jpn": 69.1147,
          "chn": 102.7342
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "chn",
        "sumIn": 823.5422,
        "sumOut": 1326.0545,
        "indicators": [
          {
            "value": 3890.9243,
            "tendency": 2.0,
            "tendencyPercent": 0.1045,
            "missing": false
          },
          {
            "value": 1337.938,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 48.8727,
          "deu": 101.3771,
          "jpn": 153.2032,
          "usa": 382.9538
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "jpn",
        "sumIn": 437.482,
        "sumOut": 565.1927,
        "indicators": [
          {
            "value": 4657.7154,
            "tendency": 1.0,
            "tendencyPercent": 0.0465,
            "missing": false
          },
          {
            "value": 128.057,
            "tendency": 0.0,
            "tendencyPercent": 0.0043,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 11.7193,
          "deu": 29.2324,
          "usa": 123.556,
          "chn": 176.7361
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "deu",
        "sumIn": 979.7763,
        "sumOut": 1079.7145,
        "indicators": [
          {
            "value": 2955.5343,
            "tendency": 1.0,
            "tendencyPercent": 0.0401,
            "missing": false
          },
          {
            "value": 81.757,
            "tendency": 0.0,
            "tendencyPercent": -0.0014,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 19.2915,
          "chn": 74.2513,
          "usa": 84.3623,
          "fra": 103.4339
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "fra",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 10.3006,
          "chn": 17.1166,
          "usa": 39.1786,
          "deu": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "isl",
        "sumIn": 18.4365,
        "sumOut": 46.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 1.3006,
          "chn": 1.1166,
          "usa": 3.1786,
          "deu": 8.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "zaf",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 10.3006,
          "chn": 17.1166,
          "usa": 39.1786,
          "deu": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "hrv",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 10.3006,
          "chn": 17.1166,
          "usa": 39.1786,
          "deu": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "bra",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "deu": 10.3006,
          "isl": 17.1166,
          "hrv": 39.1786,
          "zaf": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 3013.3583,
    "indicatorBounds": [
      [
        0.0,
        14231.57
      ],
      [
        0.0,
        1351.114
      ]
    ],
    "locking": null
  },
  {
    "title": "Eight keyframe",
    "date": 2010,
    "maxLabelsVisible": 9,
    "dataType": {
      "type": "import",
      "unit": "bln_current_dollars"
    },
    "indicatorTypes": [
      {
        "type": "gdp",
        "unit": "bln_real_dollars"
      },
      {
        "type": "population",
        "unit": "mln_persons"
      }
    ],
    "elements": [
      {
        "id": "usa",
        "sumIn": 1561.4725,
        "sumOut": 963.1993,
        "indicators": [
          {
            "value": 13595.64,
            "tendency": 0.0,
            "tendencyPercent": 0.0251,
            "missing": false
          },
          {
            "value": 309.776,
            "tendency": 0.0,
            "tendencyPercent": 0.0083,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 35.2346,
          "deu": 59.5936,
          "jpn": 69.1147,
          "chn": 102.7342
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "chn",
        "sumIn": 823.5422,
        "sumOut": 1326.0545,
        "indicators": [
          {
            "value": 3890.9243,
            "tendency": 2.0,
            "tendencyPercent": 0.1045,
            "missing": false
          },
          {
            "value": 1337.938,
            "tendency": 0.0,
            "tendencyPercent": 0.0049,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 48.8727,
          "deu": 101.3771,
          "jpn": 153.2032,
          "usa": 382.9538
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "jpn",
        "sumIn": 437.482,
        "sumOut": 565.1927,
        "indicators": [
          {
            "value": 4657.7154,
            "tendency": 1.0,
            "tendencyPercent": 0.0465,
            "missing": false
          },
          {
            "value": 128.057,
            "tendency": 0.0,
            "tendencyPercent": 0.0043,
            "missing": false
          }
        ],
        "outgoing": {
          "fra": 11.7193,
          "deu": 29.2324,
          "usa": 123.556,
          "chn": 176.7361
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "deu",
        "sumIn": 979.7763,
        "sumOut": 1079.7145,
        "indicators": [
          {
            "value": 2955.5343,
            "tendency": 1.0,
            "tendencyPercent": 0.0401,
            "missing": false
          },
          {
            "value": 81.757,
            "tendency": 0.0,
            "tendencyPercent": -0.0014,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 19.2915,
          "chn": 74.2513,
          "usa": 84.3623,
          "fra": 103.4339
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "fra",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 10.3006,
          "chn": 17.1166,
          "usa": 39.1786,
          "deu": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "isl",
        "sumIn": 18.4365,
        "sumOut": 46.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 1.3006,
          "chn": 1.1166,
          "usa": 3.1786,
          "deu": 8.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "zaf",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 10.3006,
          "chn": 17.1166,
          "usa": 39.1786,
          "deu": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "hrv",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "jpn": 10.3006,
          "chn": 17.1166,
          "usa": 39.1786,
          "deu": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "bra",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "mex": 1.3006,
          "deu": 10.3006,
          "isl": 17.1166,
          "hrv": 39.1786,
          "zaf": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      },
      {
        "id": "mex",
        "sumIn": 518.4365,
        "sumOut": 446.0124,
        "indicators": [
          {
            "value": 2205.3304,
            "tendency": 0.0,
            "tendencyPercent": 0.0172,
            "missing": false
          },
          {
            "value": 64.7807,
            "tendency": 0.0,
            "tendencyPercent": 0.005,
            "missing": false
          }
        ],
        "outgoing": {
          "deu": 10.3006,
          "isl": 17.1166,
          "hrv": 39.1786,
          "zaf": 81.8042
        },
        "noIncoming": [],
        "noOutgoing": [],
        "missingRelations": {},
        "incoming": {}
      }
    ],
    "maxSum": 3013.3583,
    "indicatorBounds": [
      [
        0.0,
        14231.57
      ],
      [
        0.0,
        1351.114
      ]
    ],
    "locking": null
  }
];
