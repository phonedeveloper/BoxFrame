/*
BoxFrame.scad - Accepts custom hand cut, 3D printed, or laser-cut side panels

These 3D printed rails can be assembled along with separate panels to
create a box in a fraction of the time it takes to 3D print a full box
and in a structure that reinforces, and is reinforced by, the panels.
Individual panels can be replaced without reprinting the entire box.

version 0.1
2016.04.17

======

The MIT License (MIT)
Copyright (c) 2016 Sean Sheedy

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

======

IMPORTANT: Setting for "rres=36" below can produce preview times of 2+ minutes
and render times of possibly much longer. Set to "rres=1" to "rres=8" for practice
or if a high resolution radius isn't needed.

======

This OpenSCAD file will let you print the parts needed to create a custom box.
The box requires eight screws to assemble. It consists of edge rails that
can hold slide-in panels. It has several advantages over trying to print a
3D printed box more than Arduino-size:

- You save lots of print time by printing only the support rails
- You can quickly cut sides from different materials
- A laser cutter can be used to quickly make panels requiring holes
- A metal panel and rivnuts can hold circuit boards
- If holes in a panel are misaligned, toss the panel, not the entire print
- You can add custom code to this file if you want to incorporate
  features like screw mount standoffs or want to use materials with
  different thicknesses on different sides
- Custom code can also be used to do things like add features to the
  box like attachment points, cable clips, cable tie holes, etc.
  
There a lot of settings in this file, but far less than trying to build
a 3D-printable box from scratch. The biggest tradeoffs over a custom
design are the space consumed by the rails, the fact that it's going
to always be w x l x h, and that it takes eight screws (as opposed to
designs which use few or no screws.)

If you are going to use slide-in panels for every side, you will need
four each of a width_rail, length_rail and height_rail.

If you are just doing one top, bottom, back, or front, you don't need
the rails for that side. Here are the rails that each side uses:

shell: uses four length_rails
top/bottom: uses two length_rails each
front/back: uses two width_rails and two height_rails each

If you print a front, or back, you won't be able
to stick a panel into that side, and you will need to add custom
code to fill in the side (unless your intention is to keep it open.)
Similarly, a top or bottom needs custom code or it will simply print
two length_rails. If you print a shell with no custom code you will
get four length_rails, and if not printed on end, a lot of wasted
support material for the top two rails.

If you have custom code, put it in a module. Similarly, if you want
to remove material from the model, put it in a seperate module.
The steps below provide a place for you to call your modules for
adding material to or subtracting material from the model.

Finally, you can only print one part of box at a time. You will
need to make changes to settings below for each part. The simplest
thing to do is to practice getting your settings right, then when
you're satisfied, save this file under a different name for each side.

To see what you are getting, follow the directions below and then
hit save, F5, or F6.
*/

// What are you printing? Set one of these to true, the rest to false.
// If you accidentally leave more than one true, only one will be output.
print_width_rail = false;
print_length_rail = false;
print_height_rail = false;
// These should not be used unless you want open sides or you have
// added custom code.
print_shell = false;
print_front = false;
print_back = false;     // instead of print_back, just print_front twice
print_top = false;
print_bottom = false;   // instead of print_bottom, just print_top twice
// Or, if you just want a preview of what the box will look
// like (without custom code), use this.
print_preview = true;

// Now, specify the interior space in the box. This is the width
// along the x-axis, length along the y-axis, and height along the
// z-axis of the space inside the box, that is, if you took a
// calipers and measured the distance between the rails, from
// inside edge to inside edge of two parallel rails in the same plane.

// w x l x h = interior space, corresponds to x-y-z
w = 75;   // width along the x-axis
l = 120;  // length along the y-axis
h = 50;   // height along the z-axis

// And now we define the screws that hold the box together. The
// screw head is recessed into the rail; the width_ and height_
// rails need to be wide enough for the screw to pass through;
// the length_rail must have a hole small enough for the threads
// to bit into but not so small as to split the rail. And the hole
// in the length_rail must be deep enough.
// If hou make the screw head height deep enough, you could fill
// the recessed hole and not see the screw. However, this can make
// the rail tabs too thin unless you make the rails thicker.
shd = 6.4;  // Screw head diameter.  (See note for rail width, below.)
shh = 3;    // Screw head height - determines amount of recess.
ssd = 3.5;  // Screw shank diameter - the width needed for the screw to clear holes
std = 2.5;  // Screw thread diameter - the hole width needed for the threads to bite
// Screw thread length (from head to tip) defines screw hole depth.
// The hole will then be deeper by the amount the screw head is recessed (shh, above).
stl = 15;

// This is generally used to introduce a gap between mating surfaces
// to compensate for larger-than-desired dimensions caused by 3D printing.
// You might set this to an integer of the layer thickness of your
// 3D print (if less than a layer thickness, the printer may ignore
// it.)
// If you are printing quickly, the roughness from the lower quality
// may require you to make this larger or file down the parts. If
// you are printing at very high quality, there might be some gap.
// Experiment.
lt = 0.2;

// Do you need slot(s) for panels in this piece?
// (This will cut the same panel slots for all sides.
// The only time you won't want slots is if don't want
// panels or you are using custom code to make your
// own sides. Since this puts slots on all sides, use custom code
// to fill in the slot on sides you don't need it or if you
// need different size slots on different sides of the same
// rail that you are printing.)
panel = true;

// Now we provide some information about the panels. A groove is
// cut into the rails to hold the panels. So, the panels are slightly
// bigger than l x w, l x h, or w x h defined above. How much?
// Enough to fit into the grooves and not fall out. Here is were we
// define the width of the groove (the width of the panel), the
// depth of the groove (which means that each dimension of the panel
// should be the width, length or height plus twice the depth), and
// how far from the inside edge of the rail the panel should begin.
// We also define how much a and deeper the groove should be
// to allow extra room since the 3D printed plastic usually doesn't
// stop right at the boundary and will impinge into the groove.
// Finally, when choosing the groove width and depth, keep in mind
// two things: if you make it so deep that the grooves from two
// sides touch, then the inside edge of the rail will be cut off
// from the rest of the rail. Similarly, the groove may crash into
// the holes for the screws. If you need a deep groove, you can make
// the rails wider (further down) to accomodate them.
// Cut panel to
// (w+2*gd) x (l+2*gd), or (w+2*gd) x (h+2*gd), or (l+2*gd) x (h+2*gd)
gw = 3;  // Groove width. Make narrow for steel, wider for plastic panel.
gd = 2;  // Groove depth. Be sure it doesn't crash into the screw.
go = 3;  // Groove offset from the inside edge of the rail.
// These next two settings provide a little extra since the groove 
// will be smaller than the width and depth specified above due to the
// 3D printed plastics impinging into the groove.
gwe = lt; // Groove width extra. Added to each side of the groove.
gde = lt; // Groove depth extra. The groove is made deeper by this amount.

// Rail thickness determines the thickness of the rails. This can
// be made larger or smaller to better accommodate the recess for
// the screw heads, the slots for the panels, or the radius on the
// edge of the rails.
t = 10;

// Do you have custom code? You might use custom code to make
// supports for circuit board if you don't put those supports
// in a panel.
// Add that code, or calls to it, within this module.
// (Remember, it may be easier to create custom panels in a separate
// OpenSCAD file.)
module custom_add() {
}

// Do you have custom code to remove material from what you're printing?
// Maybe you want to make the grooves for one side wider than the others?
// Add that code, or calls to it, within this module.
module custom_remove() {
}

// Better rail resolution is needed for rails with larger radius and smaller
// print layers. As the radius increases and the print layer height decreases,
// the rail resolution increases and the render can take VERY long. If
// experimenting, use a low resolution so you don't have to wait long if 
// you change something that affects rail rendering. Use a multiple of four
// to ensure evenness (not so important for very high resolution.) Some values:
// 0 - default
// 8 - 15 second preview
// 12 - about 30 second preview
// 16 - about 45 second preview 
// 20 - about one minute preview
// 36 - about 2 1/4 minute preview
rres = 36;  

// Now we determine the radius on the rails. If there are no rails, the
// radius will be the distance from the edge of the screw head to the edge
// of the rail. If there are panels, it will be the smaller of the screw
// head distance or the distance from the edge of the panel to the
// edge of the rail, whichever is least. This can be overridden by
// setting the "r" variable immediately after this block of code.
// (Note: we give one layer thickness space between edge of screw hole or
// edge of panel before the start of the radius.)
// Choose one of the four below (comment out the rest).
// The best is probably the first unless your panel is closer to the edge.
r = (t-shd-2*lt)/2;            // Use screw hole to determine rail edge radius.
//r = go - gwe - lt;             // Use inside panel edge to determine edge radius.
//r = t - (go + gw + gwe + lt);  // Use outside panel edge to determine radius.
//r = 0;                         // Specify a custom rail edge radius.

// r = 2;  // Uncomment to specify the radius rather than accept above calculation.

//=============== Really, no more user-changeable settings past this point. ================

// Screw resolution ($fn=) determines the smoothness of the screw holes.
sres = 36;

// How far shank recesses into length_rail hole, to prevent hole distortion
// caused by screw thread from separating the length_rail and width_rail.
sr = 2;

// Here is where the main printing happens. We print the first part of the box
// that the user has specified, above.
if (print_shell) {
  difference() {
    translate() {
      shell();
      custom_add();
    }
    custom_remove();
  }
} else if (print_front) {
  difference() {
    translate() {
      front();
      custom_add();
    }
    custom_remove();
  }
} else if (print_back) {
  difference() {
    translate() {
      back();
      custom_add();
    }
    custom_remove();
  }
} else if (print_top) {
  difference() {
    translate() {
      top();
      custom_add();
    }
    custom_remove();
  }
} else if (print_bottom) {
  difference() {
    translate() {
      bottom();
      custom_add();
    }
    custom_remove();
  }
} else if (print_width_rail) {
  difference() {
    translate() {
      width_rail();
      custom_add();
    }
    custom_remove();
  }
} else if (print_length_rail) {
  difference() {
    translate() {
      length_rail();
      custom_add();
    }
    custom_remove();
  }
} else if (print_height_rail) {
  difference() {
    translate() {
      height_rail();
      custom_add();
    }
    custom_remove();
  }
} else if (print_preview) {
  frame();
}

// view is normal (from front)
module front() {
  difference() {
    frame();
    translate([-lt,t,-lt]) cube([(t+lt)*2+w,l+2*t+lt,(t+lt)*2+h]);
  }
}

// view is looking from back directly at surface (rotated 180 degrees around z axis)
module back() {
  translate([w+2*t,l+2*t,0]) {
    rotate([0,0,180]) {
      difference() {
        frame();
        translate([-lt,-lt,-lt]) cube([(t+lt)*2+w,l+t+lt,(t+lt)*2+h]);
      }
    }
  }
}

// A shell consisting of four Y-axis rails.
// View is from front looking into shell. 
module shell() {
  translate([0,-t,0]) {
    difference() {
      frame();
      translate([-lt,-lt,-lt]) {
        cube([w+2*(t+lt),t+lt,h+2*(t+lt)]);
        translate([0,t+l+lt,0]) cube([w+2*(t+lt),t+lt,h+2*(t+lt)]);
      }
    }
  }
}

// A top section consisting of two parallel Y-axis rails.
// View is normal - looking down on top from z-axis
module top() {
  translate([0,0,-(t+h)]) {
    difference() {
      shell();
      translate([-lt,-lt,-lt]) cube([w+2*(t+lt),l+2*(t+lt),h+t+lt]);
    }
  }
}

// A bottom section consisting of two parallel Y-axis rails.
// View is as if part has been rotated 180 degrees along y axis.
// (flipped upside down) and looking down on surface.
module bottom() {
  translate([w+2*t,0,t]) {
    rotate([0,-180,0]) {
      difference() {
        shell();
        translate([-lt,-lt,t]) cube([w+2*(t+lt),l+2*(t+lt),h+t+lt]);
      }
    }
  }
}

// A rail parallel to the X-axis.
//
// Rails are positioned so that at least one groove edge is on bottom.
// This leads to prettier prints but may cause problem inside groove.
// The groove may have to be cleaned up after printing, if print material
// sags into groove or if supports are used and must be cleaned out.
module width_rail() {
  // cut off screw head area + half of remaining area
  difference() {
    translate([0,0,-(h+t)]) {
      front();
    }
    translate([0,0,0]) {
      translate([-lt,-lt,-(h+t+lt)]) cube([w+2*(t+lt),t+2*lt,t+h+lt]);
      // trim lt off each end of the rail so the rails fit together better
      translate([-lt,-lt,-lt]) cube([t+2*lt,shh+(t-shh)/2,t+2*lt]);
      translate([w+t-lt,-lt,-lt]) cube([t+2*lt,shh+(t-shh)/2,t+2*lt]);
    }
  }
}

// A rail parallel to the Y-axis.
module length_rail() {
  difference() {
    top();
    translate([t,-lt,-lt]) cube([w+t+2*lt,l+2*(t+lt),t+2*lt]);
  }
}

// A rail parallel to the Z-axis.
module height_rail() {
    // leave screw head area and half of remaining area less lt
  difference() {
    translate([h+2*t,0,-(w+t)]) {
      rotate([0,-90,0]) {
        front();
      }
    }
    translate() {
      translate([-lt,-lt,-(w+t+lt)]) cube([h+2*(t+lt),t+2*lt,t+w+lt]);
      // trim lt off each end of the rail so the rails fit together better,
      // make tab a little thinner so rails fit together better.
      translate([-lt,shh+(t-shh)/2-lt,-lt]) cube([t+2*lt,lt+(t-shh)/2,t+2*lt]);
      translate([h+t-lt,shh+(t-shh)/2-lt,-lt]) cube([t+2*lt,lt+(t-shh)/2,t+2*lt]);
    }
  }
}

// Complete assembled frame, with holes for screws
module frame() {
  difference() {
    translate([0,0,0]) {
      minkowski() {
        translate([r,r,r]) {
          difference() {
            cube([w + (2*t) - (2*r),l + (2*t) - (2*r),h + (2*t) - (2*r)]);
            translate([-r,-r,-r]) {
              translate([0,t-r,t-r]) cube([w + (2*t) + (4*r),l + (2*r),h + (2*r)]);
              translate([t-r,0,t-r]) cube([w + (2*r),l + (2*t) + (2*r),h + (2*r)]);
              translate([t-r,t-r,0]) cube([w + (2*r),l + (2*r),h + (2*t) + (2*r)]);
            }
          }
        }
        sphere(r=r, $fn=rres);
      }
    }
    translate([0,0,0]) {
      // screw head indentations, front
      translate([t/2,-lt,t/2]) screw_head_recess();
      translate([w+t+t/2,-lt,t/2]) screw_head_recess();
      translate([t/2,-lt,h+t+t/2]) screw_head_recess();
      translate([w+t+t/2,-lt,h+t+t/2]) screw_head_recess();
      // screw head indentations, front
      translate([t/2,l+2*t-shh,t/2]) screw_head_recess();
      translate([w+t+t/2,l+2*t-shh,t/2]) screw_head_recess();
      translate([t/2,l+2*t-shh,h+t+t/2]) screw_head_recess();
      translate([w+t+t/2,l+2*t-shh,h+t+t/2]) screw_head_recess();
      // screw shank, front. Allow shank to recess 2mm into hole.
      translate([t/2,0,t/2]) screw_shank();
      translate([w+t+t/2,0,t/2]) screw_shank();
      translate([t/2,0,h+t+t/2]) screw_shank();
      translate([w+t+t/2,0,h+t+t/2]) screw_shank();
      // screw shank, back. Allow shank to recess 2mm into hole.
      translate([t/2,l+t-sr,t/2]) screw_shank();
      translate([w+t+t/2,l+t-sr,t/2]) screw_shank();
      translate([t/2,l+t-sr,h+t+t/2]) screw_shank();
      translate([w+t+t/2,l+t-sr,h+t+t/2]) screw_shank();
      // screw hole, front
      translate([t/2,0,t/2]) screw_hole();
      translate([w+t+t/2,0,t/2]) screw_hole();
      translate([t/2,0,h+t+t/2]) screw_hole();
      translate([w+t+t/2,0,h+t+t/2]) screw_hole();
      // screw hole, back
      translate([t/2,l+2*t-stl-shh,t/2]) screw_hole();
      translate([w+t+t/2,l+2*t-stl-shh,t/2]) screw_hole();
      translate([t/2,l+2*t-stl-shh,h+t+t/2]) screw_hole();
      translate([w+t+t/2,l+2*t-stl-shh,h+t+t/2]) screw_hole();
      // panels
      if (panel == true) {
        // front panel
        translate([t-gd-gde,t-go-gw-gwe,t-gd-gde]) cube([w+2*(gd+gde),gw+2*gwe,h+2*(gd+gde)]);
        // back panel
        translate([t-gd-gde,t+l+go-gwe,t-gd-gde]) cube([w+2*(gd+gde),gw+2*gwe,h+2*(gd+gde)]);
        // left panel
        translate([t-go-gw-gwe,t-gd-gde,t-gd-gde]) cube([gw+2*gwe,l+2*(gd+gde),h+2*(gd+gde)]);
        // right panel
        translate([t+w+go-gwe,t-gd-gde,t-gd-gde]) cube([gw+2*gwe,l+2*(gd+gde),h+2*(gd+gde)]);
        // bottom panel
        translate([t-gd-gde,t-gd-gde,t-go-gw-gwe]) cube([w+2*(gd+gde),l+2*(gd+gde),gw+2*gwe]);
        // top panel
        translate([t-gd-gde,t-gd-gde,t+h+go-gwe]) cube([w+2*(gd+gde),l+2*(gd+gde),gw+2*gwe]);
      }
    }
  }
}

// A cylinder in which the screw head can fit.
module screw_head_recess() {
  rotate([-90,0,0]) cylinder(d=shd,h=shh+lt,$fn=sres);
}

// A cylinder in which the screw threads pass without touching the sides.
// The screw shank is made 2mm longer so that it enters
// the screw hole by 2mm, and prevents distortion of the
// screw hole by the thread from creating a gap between
// the length_rail and the width_rail where they meet.
module screw_shank() {
  rotate([-90,0,0]) cylinder(d=ssd,h=t+sr,$fn=sres);
}

// A cylinder into  which the screw threads can bite.
module screw_hole() {
  rotate([-90,0,0]) cylinder(d=std,h=stl+shh,$fn=sres);
}