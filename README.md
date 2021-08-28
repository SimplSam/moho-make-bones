# moho-make-bones
**Make Bones** is a Moho tool to split, clone and reform Moho Bones. To use - Select one or more Bones (_normally one_), then Activate and configure the tool. By default the tool will divide the length of the selected _Bone_ into a _{number of pieces}_ of equal lengths, parent the new bones to each other in a chain and re-assign prior child bones to the last bone in the newly created set.

### Version ###

*	version: 001.0 #510828 AS11-MH13.5+      -- by Sam Cogheil (SimplSam)
*	release: 1.00

### How do I get set up ? ###

* To install:

  - Save the 'ss_make_bones.lua' and 'ss_make_bones.png' files to your computer into your &lt;custom&gt;/scripts/tool folder
  - Reload Moho/AnimeStudio scripts (or Restart Moho)

* To use:

  - Select a bone layer, and one or more bones
  - Run the tool from the Tools palette
  - A popup panel will appear allowing you to review and adjust the settings

* Notes:
    - The tool is primarily intended to be used at rigging & design time, but should cope with some limited pre-existing animation (reparenting and repositioning) if those elements of the _selected bone_ and/or _children_ have already been keyframed.

### Demo ###
![ss-make-bones-demo-01](https://i.ibb.co/Jshgbkx/ss-make-bones-demo-01-x1200.gif)

### Options & Features ###

* Set the **No. of Pieces #** that the selected bone should be broken into (or # clones)
* Use **Parental Link** to form a Parent-Child relationship with newly created bones
    * **Chained**: New bones are parentally linked back to the base bone
    * **Shared**: New bones share the same parent as the base bone (or none if base bone has none)
* Disable **Parental Link** to create the new bones with no parenting
* **Rescale** the selected Bone based on No. of Pieces, with a default simple Linear scale relation of 1/#
    * Use **Weighted Bones** to gradually reduce the new Bone sizes based on Fibonacci sequencing - where the length of the Parent is equal to the length of the Child + Grandchild … i.e. (8, 5, 3) or (89, 55, 34, 21)
    * Use **Scale Strength** to scale Bone strength in proportion to Bone size
* Disable **Rescale** to clone/duplicate the selected bone at full size # times
* Use **Angular Offset** to create curly wurly bones, or bones set at an angle (if not Chained in a Parental Link)
    * Use **ReAngle First Bone** - if you also want the base bone to have an angular offset
* Use **Reset** to restore default settings. **OK** to Apply settings & changes. **Cancel** to Cancel

&nbsp;
* The color of the base bone will be copied to the new bones
* New bones are auto-named based the name of the base bone (MH12+)
* Multiple selected bones will be processed in order
* The last used settings are automatically saved
* Compatible with AS11+
* Optimised for MH12+

\* ‘_base bone’ is the originally selected bone, which may itself be altered in size & rotation by the Split/Clone process_
&nbsp;

## SPECIAL THANKS to: ##

*	Stan (and the team): MOHO Scripting -- https://mohoscripting.com
*	The friendly faces @ Lost Marble Moho forum -- https://www.lostmarble.com/forum/