+++
date = 2026-10-15
title = "RovyVon GS15 remote switch signaling"
description = "How the RovyVon GS15's two-button remote switch signals over a two-contact Crane plug."
+++

The [RovyVon GS15 remote switch](https://www.rovyvon.com/products/rovyvon-gs15-remote-switch) has two buttons: a large one, and a small one for the visible override.
It connects over a Crane plug, which only has two contacts, so the light tells the buttons apart by resistance:

| Button                   | Resistance |
|--------------------------|------------|
| Large                    | 1.5 kΩ     |
| Small (visible override) | 3.3 kΩ     |

For comparison, a standard Modbutton Lite is a dead short, effectively 0 Ω, and the GS15 treats it like the large button.

I doubt anyone else will ever need to know this, but if you do, there it is.
