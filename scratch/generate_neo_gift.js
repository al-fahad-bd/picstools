const fs = require('fs');

// Neo-Brutalist Colors
const cBlack = [0.07, 0.07, 0.07, 1];       // #121212
const cYellow = [1.0, 0.902, 0.0, 1];       // #FFE600
const cPink = [1.0, 0.2, 0.4, 1];           // #FF3366
const cCyan = [0.0, 0.898, 1.0, 1];         // #00E5FF
const cGreen = [0.0, 0.902, 0.463, 1];      // #00E676
const cPurple = [0.545, 0.361, 0.965, 1];   // #8B5CF6
const cWhite = [1.0, 1.0, 1.0, 1];          // #FFFFFF
const cDarkGrey = [0.2, 0.2, 0.22, 1];

function staticVal(v) {
  return { a: 0, k: v };
}

function shapeFill(color) {
  return {
    ty: "fl",
    c: staticVal(color),
    o: staticVal(100),
    r: 1,
    nm: "Fill"
  };
}

function shapeStroke(color, width) {
  return {
    ty: "st",
    c: staticVal(color),
    o: staticVal(100),
    w: staticVal(width),
    lc: 2, // round cap
    lj: 2, // round join
    nm: "Stroke"
  };
}

function shapeTransform(pos = [0, 0], scale = [100, 100], rot = 0) {
  return {
    ty: "tr",
    p: staticVal(pos),
    a: staticVal([0, 0]),
    s: staticVal(scale),
    r: staticVal(rot),
    o: staticVal(100),
    nm: "Transform"
  };
}

function makeRectGroup(name, w, h, radius, fillColor, strokeColor, strokeWidth, offset = [0, 0]) {
  const items = [
    {
      ty: "rc",
      d: 1,
      s: staticVal([w, h]),
      p: staticVal([0, 0]),
      r: staticVal(radius),
      nm: "Rect"
    }
  ];
  if (fillColor) items.push(shapeFill(fillColor));
  if (strokeColor && strokeWidth) items.push(shapeStroke(strokeColor, strokeWidth));
  items.push(shapeTransform(offset));
  return {
    ty: "gr",
    it: items,
    nm: name
  };
}

function makeEllipseGroup(name, w, h, fillColor, strokeColor, strokeWidth, offset = [0, 0]) {
  const items = [
    {
      ty: "el",
      d: 1,
      s: staticVal([w, h]),
      p: staticVal([0, 0]),
      nm: "Ellipse"
    }
  ];
  if (fillColor) items.push(shapeFill(fillColor));
  if (strokeColor && strokeWidth) items.push(shapeStroke(strokeColor, strokeWidth));
  items.push(shapeTransform(offset));
  return {
    ty: "gr",
    it: items,
    nm: name
  };
}

// 4-pointed Neo-Brutalist Star shape group
function makeStarGroup(name, size, fillColor, strokeColor, strokeWidth, offset = [0, 0]) {
  const s = size / 2;
  const i = s * 0.28;
  const items = [
    {
      ty: "sh",
      ks: {
        a: 0,
        k: {
          i: [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
          o: [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
          v: [
            [0, -s],
            [i, -i],
            [s, 0],
            [i, i],
            [0, s],
            [-i, i],
            [-s, 0],
            [-i, -i]
          ],
          c: true
        }
      },
      nm: "StarPath"
    }
  ];
  if (fillColor) items.push(shapeFill(fillColor));
  if (strokeColor && strokeWidth) items.push(shapeStroke(strokeColor, strokeWidth));
  items.push(shapeTransform(offset));
  return {
    ty: "gr",
    it: items,
    nm: name
  };
}

// Plus sign shape group
function makePlusGroup(name, size, thick, fillColor, strokeColor, strokeWidth, offset = [0, 0]) {
  const s = size / 2;
  const t = thick / 2;
  const items = [
    {
      ty: "sh",
      ks: {
        a: 0,
        k: {
          i: Array(12).fill([0,0]),
          o: Array(12).fill([0,0]),
          v: [
            [-t, -s], [t, -s], [t, -t], [s, -t], [s, t], [t, t],
            [t, s], [-t, s], [-t, t], [-s, t], [-s, -t], [-t, -t]
          ],
          c: true
        }
      },
      nm: "PlusPath"
    }
  ];
  if (fillColor) items.push(shapeFill(fillColor));
  if (strokeColor && strokeWidth) items.push(shapeStroke(strokeColor, strokeWidth));
  items.push(shapeTransform(offset));
  return {
    ty: "gr",
    it: items,
    nm: name
  };
}

// Bow Loop (stylized teardrop / oval)
function makeBowLoopGroup(name, w, h, rot, fillColor, strokeColor, strokeWidth, offset = [0, 0]) {
  const items = [
    {
      ty: "el",
      d: 1,
      s: staticVal([w, h]),
      p: staticVal([0, 0]),
      nm: "LoopEllipse"
    }
  ];
  if (fillColor) items.push(shapeFill(fillColor));
  if (strokeColor && strokeWidth) items.push(shapeStroke(strokeColor, strokeWidth));
  items.push(shapeTransform(offset, [100, 100], rot));
  return {
    ty: "gr",
    it: items,
    nm: name
  };
}

// Assemble Layers
// In Lottie, Layer with lowest `ind` (e.g. 1) is rendered at the FRONT (on top of everything)!
// Higher index layers are rendered in the BACK.
// Within a shape layer, the shape at index 0 is rendered at the FRONT, and last shape is in the BACK.
// To avoid ANY ambiguity and guarantee 100% perfect rendering order:
// We will separate the components into individual dedicated layers in clear back-to-front order!

const layers = [];
let nextInd = 1;

// Helper to push layer with automatic index
function pushLayer(layer) {
  layer.ind = nextInd++;
  layer.ddd = 0;
  layer.sr = 1;
  layer.ao = 0;
  layer.st = 0;
  layer.bm = 0;
  layers.push(layer);
}

// -------------------------------------------------------------------------------------------------
// Top Layers (Frontmost): Confetti / Stars
// -------------------------------------------------------------------------------------------------
function createParticleLayer({ name, shapeGroup, startFrame, endFrame, startPos, peakPos, endPos, peakScale, rotSpeed }) {
  return {
    ty: 4,
    nm: name,
    ks: {
      o: {
        a: 1,
        k: [
          { t: 0, s: [0], e: [0] },
          { t: startFrame, s: [0], e: [100] },
          { t: startFrame + 6, s: [100], e: [100] },
          { t: endFrame - 10, s: [100], e: [0] },
          { t: endFrame, s: [0], e: [0] },
          { t: 120, s: [0], e: [0] }
        ]
      },
      r: {
        a: 1,
        k: [
          { t: startFrame, s: [0], e: [rotSpeed] },
          { t: endFrame, s: [rotSpeed], e: [rotSpeed] }
        ]
      },
      p: {
        a: 1,
        k: [
          { t: 0, s: [startPos[0], startPos[1], 0], e: [startPos[0], startPos[1], 0] },
          { t: startFrame, s: [startPos[0], startPos[1], 0], e: [peakPos[0], peakPos[1], 0] },
          { t: startFrame + Math.floor((endFrame - startFrame) * 0.45), s: [peakPos[0], peakPos[1], 0], e: [endPos[0], endPos[1], 0] },
          { t: endFrame, s: [endPos[0], endPos[1], 0], e: [endPos[0], endPos[1], 0] }
        ]
      },
      a: staticVal([0, 0, 0]),
      s: {
        a: 1,
        k: [
          { t: 0, s: [0, 0, 100], e: [0, 0, 100] },
          { t: startFrame, s: [0, 0, 100], e: [peakScale, peakScale, 100] },
          { t: startFrame + 12, s: [peakScale, peakScale, 100], e: [peakScale * 0.85, peakScale * 0.85, 100] },
          { t: endFrame, s: [0, 0, 100], e: [0, 0, 100] }
        ]
      }
    },
    shapes: [shapeGroup],
    ip: startFrame,
    op: endFrame
  };
}

pushLayer(createParticleLayer({
  name: "Star Cyan",
  shapeGroup: makeStarGroup("Star1", 34, cCyan, cBlack, 3.5),
  startFrame: 22,
  endFrame: 78,
  startPos: [200, 180],
  peakPos: [110, 80],
  endPos: [85, 115],
  peakScale: 120,
  rotSpeed: 180
}));

pushLayer(createParticleLayer({
  name: "Star Pink",
  shapeGroup: makeStarGroup("Star2", 36, cPink, cBlack, 3.5),
  startFrame: 23,
  endFrame: 80,
  startPos: [200, 180],
  peakPos: [290, 75],
  endPos: [315, 110],
  peakScale: 125,
  rotSpeed: -190
}));

pushLayer(createParticleLayer({
  name: "Star Yellow",
  shapeGroup: makeStarGroup("Star3", 38, cYellow, cBlack, 3.5),
  startFrame: 21,
  endFrame: 76,
  startPos: [200, 180],
  peakPos: [195, 40],
  endPos: [190, 65],
  peakScale: 130,
  rotSpeed: 210
}));

pushLayer(createParticleLayer({
  name: "Star Green",
  shapeGroup: makeStarGroup("Star4", 28, cGreen, cBlack, 3.5),
  startFrame: 24,
  endFrame: 79,
  startPos: [200, 180],
  peakPos: [310, 145],
  endPos: [325, 190],
  peakScale: 110,
  rotSpeed: -160
}));

pushLayer(createParticleLayer({
  name: "Plus Purple",
  shapeGroup: makePlusGroup("Plus1", 26, 8, cPurple, cBlack, 3.0),
  startFrame: 24,
  endFrame: 75,
  startPos: [200, 180],
  peakPos: [145, 55],
  endPos: [130, 90],
  peakScale: 115,
  rotSpeed: 240
}));

pushLayer(createParticleLayer({
  name: "Plus Yellow",
  shapeGroup: makePlusGroup("Plus2", 24, 7, cYellow, cBlack, 3.0),
  startFrame: 25,
  endFrame: 77,
  startPos: [200, 180],
  peakPos: [250, 60],
  endPos: [265, 95],
  peakScale: 110,
  rotSpeed: -220
}));

pushLayer(createParticleLayer({
  name: "Circle Pink",
  shapeGroup: makeEllipseGroup("Circle1", 16, 16, cPink, cBlack, 3.0),
  startFrame: 22,
  endFrame: 74,
  startPos: [200, 180],
  peakPos: [85, 150],
  endPos: [75, 185],
  peakScale: 100,
  rotSpeed: 90
}));

pushLayer(createParticleLayer({
  name: "Circle Cyan",
  shapeGroup: makeEllipseGroup("Circle2", 15, 15, cCyan, cBlack, 3.0),
  startFrame: 23,
  endFrame: 76,
  startPos: [200, 180],
  peakPos: [255, 135],
  endPos: [270, 170],
  peakScale: 100,
  rotSpeed: -100
}));

// -------------------------------------------------------------------------------------------------
// Lid & Bow Layer (Animates: Blasts up, tilts -26deg, bounces back down)
// -------------------------------------------------------------------------------------------------
// In shapes order: LAST element is rendered FIRST (at the back).
// So:
// 1. Bow Knot (Front)
// 2. Bow Knot Shadow
// 3. Bow Loops
// 4. Bow Loops Shadow
// 5. Lid Ribbon
// 6. Lid Base (Pink)
// 7. Lid Shadow (Back)
const lidShapes = [
  // Front: Bow Center Knot (Yellow with 4.5px black border)
  makeRectGroup("Bow Knot", 24, 24, 6, cYellow, cBlack, 4.5, [0, -25]),

  // Bow Loops (Green with 4.5px black border)
  makeBowLoopGroup("Bow Left", 38, 26, -35, cGreen, cBlack, 4.5, [-20, -26]),
  makeBowLoopGroup("Bow Right", 38, 26, 35, cGreen, cBlack, 4.5, [20, -26]),

  // Lid Vertical Ribbon (Cyan with 4px black border)
  makeRectGroup("Lid Ribbon", 34, 38, 0, cCyan, cBlack, 4.0, [0, 0]),

  // Lid Base (Hot Pink with 5.5px black border)
  makeRectGroup("Lid Base", 154, 38, 8, cPink, cBlack, 5.5, [0, 0]),

  // Back: Lid Hard Shadow (Black, offset +6, +6)
  makeRectGroup("Lid Shadow", 154, 38, 8, cBlack, null, 0, [6, 6])
];

pushLayer({
  ty: 4,
  nm: "Lid & Bow Layer",
  ks: {
    o: staticVal(100),
    r: {
      a: 1,
      k: [
        { t: 0, s: [0], e: [-4] },
        { t: 8, s: [-4], e: [4] },
        { t: 16, s: [4], e: [0] },
        // BLAST POP UP & TILT!
        { t: 20, s: [0], e: [-26] },
        { t: 36, s: [-26], e: [-28] },
        { t: 52, s: [-28], e: [-12] },
        // DROP DOWN & BOUNCE
        { t: 68, s: [-12], e: [6] },
        { t: 78, s: [6], e: [-2] },
        { t: 88, s: [-2], e: [0] },
        { t: 120, s: [0], e: [0] }
      ]
    },
    p: {
      a: 1,
      k: [
        { t: 0, s: [200, 180, 0], e: [200, 186, 0] },
        { t: 16, s: [200, 186, 0], e: [200, 178, 0] },
        // BLAST UPWARD!
        { t: 20, s: [200, 178, 0], e: [186, 105, 0] },
        { t: 36, s: [186, 105, 0], e: [186, 100, 0] },
        { t: 52, s: [186, 100, 0], e: [194, 135, 0] },
        // DROP DOWN & OVERSHOOT
        { t: 68, s: [194, 135, 0], e: [200, 186, 0] },
        { t: 76, s: [200, 186, 0], e: [200, 176, 0] },
        { t: 86, s: [200, 176, 0], e: [200, 180, 0] },
        { t: 120, s: [200, 180, 0], e: [200, 180, 0] }
      ]
    },
    a: staticVal([0, 0, 0]),
    s: {
      a: 1,
      k: [
        { t: 0, s: [100, 100, 100], e: [106, 94, 100] },
        { t: 16, s: [106, 94, 100], e: [96, 106, 100] },
        { t: 22, s: [96, 106, 100], e: [104, 104, 100] },
        { t: 68, s: [104, 104, 100], e: [108, 92, 100] },
        { t: 78, s: [108, 92, 100], e: [98, 102, 100] },
        { t: 88, s: [98, 102, 100], e: [100, 100, 100] },
        { t: 120, s: [100, 100, 100], e: [100, 100, 100] }
      ]
    }
  },
  shapes: lidShapes,
  ip: 0,
  op: 120
});

// -------------------------------------------------------------------------------------------------
// Box Body Layer with PicsTools Camera Icon Badge!
// -------------------------------------------------------------------------------------------------
// Rendering order from Front (index 0) to Back (last index):
// 1. Camera Lens Inner Glint (White dot)
// 2. Camera Lens Core (Cyan circle with black border)
// 3. Camera Lens Outer Ring (Yellow circle with black border)
// 4. Camera Viewfinder Bump (White rect on top of camera)
// 5. Camera Red Flash Dot (Pink circle)
// 6. Camera Body Badge (Crisp White rounded rect with 4.5px black border)
// 7. Camera Hard Shadow (Solid black rect offset [4, 4])
// 8. Box Horizontal Ribbon (Cyan with black border)
// 9. Box Vertical Ribbon (Cyan with black border)
// 10. Box Base (Vibrant Neo Yellow with 5.5px black border)
// 11. Box Hard Shadow (Solid black rect offset [7, 7] at the very BACK!)
const boxShapes = [
  // 1. Camera Lens Inner Reflection / Glint
  makeEllipseGroup("Lens Glint", 6, 6, cWhite, null, 0, [2, 1]),

  // 2. Camera Lens Core (Vibrant Cyan with 3px black border)
  makeEllipseGroup("Lens Core", 18, 18, cCyan, cBlack, 3.0, [0, 3]),

  // 3. Camera Lens Outer Ring (Dark Grey / Black housing)
  makeEllipseGroup("Lens Ring", 26, 26, cDarkGrey, cBlack, 3.5, [0, 3]),

  // 4. Camera Top Viewfinder / Flash bump
  makeRectGroup("Camera Viewfinder", 18, 8, 3, cWhite, cBlack, 3.5, [-11, -19]),

  // 5. Camera Red/Pink Recording Indicator Dot
  makeEllipseGroup("Camera Rec Dot", 7, 7, cPink, cBlack, 2.0, [15, -10]),

  // 6. Camera Body (Crisp White with 4.5px thick black border)
  makeRectGroup("Camera Body", 58, 42, 8, cWhite, cBlack, 4.5, [0, 3]),

  // 7. Camera Badge Hard Shadow (+4, +4)
  makeRectGroup("Camera Shadow", 58, 42, 8, cBlack, null, 0, [4, 7]),

  // 8. Vertical Ribbon (Neo Cyan with 4.5px black border)
  makeRectGroup("Box Vert Ribbon", 36, 104, 0, cCyan, cBlack, 4.5, [0, 0]),

  // 9. Horizontal Ribbon (Neo Cyan with 4.5px black border)
  makeRectGroup("Box Horiz Ribbon", 136, 26, 0, cCyan, cBlack, 4.5, [0, 4]),

  // 10. Box Base (Vibrant Neo Yellow with 5.5px black border)
  makeRectGroup("Box Base", 136, 104, 8, cYellow, cBlack, 5.5, [0, 0]),

  // 11. Box Body Hard Shadow (Solid Black offset +7, +7, at the very BACK)
  makeRectGroup("Box Shadow", 136, 104, 8, cBlack, null, 0, [7, 7])
];

pushLayer({
  ty: 4,
  nm: "Box Body Layer",
  ks: {
    o: staticVal(100),
    r: {
      a: 1,
      k: [
        { t: 0, s: [0], e: [-2] },
        { t: 8, s: [-2], e: [2] },
        { t: 16, s: [2], e: [0] },
        { t: 20, s: [0], e: [-4] },
        { t: 28, s: [-4], e: [2] },
        { t: 36, s: [2], e: [0] },
        { t: 120, s: [0], e: [0] }
      ]
    },
    p: {
      a: 1,
      k: [
        { t: 0, s: [200, 244, 0], e: [200, 248, 0] },
        { t: 16, s: [200, 248, 0], e: [200, 230, 0] },
        { t: 28, s: [200, 230, 0], e: [200, 244, 0] },
        { t: 68, s: [200, 244, 0], e: [200, 248, 0] },
        { t: 76, s: [200, 248, 0], e: [200, 242, 0] },
        { t: 86, s: [200, 242, 0], e: [200, 244, 0] },
        { t: 120, s: [200, 244, 0], e: [200, 244, 0] }
      ]
    },
    a: staticVal([0, 0, 0]),
    s: {
      a: 1,
      k: [
        // Anticipate squash
        { t: 0, s: [100, 100, 100], e: [108, 92, 100] },
        // Jump stretch
        { t: 16, s: [108, 92, 100], e: [94, 108, 100] },
        // Land
        { t: 28, s: [94, 108, 100], e: [104, 96, 100] },
        { t: 36, s: [104, 96, 100], e: [100, 100, 100] },
        // Catch lid landing
        { t: 68, s: [100, 100, 100], e: [106, 94, 100] },
        { t: 76, s: [106, 94, 100], e: [98, 102, 100] },
        { t: 86, s: [98, 102, 100], e: [100, 100, 100] },
        { t: 120, s: [100, 100, 100], e: [100, 100, 100] }
      ]
    }
  },
  shapes: boxShapes,
  ip: 0,
  op: 120
});

// -------------------------------------------------------------------------------------------------
// Ground Floor Shadow (At the very bottom of everything)
// -------------------------------------------------------------------------------------------------
const shadowShapes = [
  makeEllipseGroup("Floor Shadow", 146, 22, cBlack, null, 0, [0, 0])
];

pushLayer({
  ty: 4,
  nm: "Ground Shadow Layer",
  ks: {
    o: {
      a: 1,
      k: [
        { t: 0, s: [85], e: [95] },
        { t: 16, s: [95], e: [50] },
        { t: 28, s: [50], e: [85] },
        { t: 68, s: [85], e: [95] },
        { t: 76, s: [95], e: [80] },
        { t: 86, s: [80], e: [85] },
        { t: 120, s: [85], e: [85] }
      ]
    },
    r: staticVal(0),
    p: staticVal([200, 310, 0]),
    a: staticVal([0, 0, 0]),
    s: {
      a: 1,
      k: [
        { t: 0, s: [100, 100, 100], e: [112, 110, 100] },
        { t: 16, s: [112, 110, 100], e: [78, 75, 100] },
        { t: 28, s: [78, 75, 100], e: [105, 105, 100] },
        { t: 36, s: [105, 105, 100], e: [100, 100, 100] },
        { t: 68, s: [100, 100, 100], e: [110, 110, 100] },
        { t: 76, s: [110, 110, 100], e: [95, 95, 100] },
        { t: 86, s: [95, 95, 100], e: [100, 100, 100] },
        { t: 120, s: [100, 100, 100], e: [100, 100, 100] }
      ]
    }
  },
  shapes: shadowShapes,
  ip: 0,
  op: 120
});

const lottieJson = {
  v: "5.5.2",
  fr: 60,
  ip: 0,
  op: 120,
  w: 400,
  h: 400,
  nm: "Neo Brutalist PicsTools Gift",
  ddd: 0,
  assets: [],
  layers: layers
};

fs.writeFileSync('assets/animations/gift.json', JSON.stringify(lottieJson, null, 2));
console.log("Successfully generated neo-brutalist gift.json with Camera Emblem!");
console.log("Total layers:", layers.length);
