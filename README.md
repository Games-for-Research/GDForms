# GDForms
GDForms is a plugin for Godot that allows the creation of interactive forms for collecting information from the user.

## Features

### Various customizable form widgets

GDForms comes with a number of custom (and customizable) form widgets for creating forms. The widgets can be styled using Godot themes.

![gdforms_screenshot_checkboxes](https://user-images.githubusercontent.com/481778/178927226-3a3de364-5586-421c-97a8-289841996424.png)

For instance, GDForms **Checkbox** widgets encapsulate standard Godot Checkboxes, but you can position the label to the left, above or below the button.

The **Options** widget can be used for displaying several options to the user. You can select whether multiple choices are allowed or not.

![gdforms_screenshot_radio_buttons1](https://user-images.githubusercontent.com/481778/178929224-6ed350d6-fea0-4380-ba87-62491d633279.png)

The options can be presented either vertically or horizontally. A line can also be optionally drawn in the background to suggest a scale.

![gdforms_screenshot_radio_buttons2](https://user-images.githubusercontent.com/481778/178929311-e5d935da-129c-4637-b03c-7470201a1e40.png)

![gdforms_screenshot_radio_buttons3](https://user-images.githubusercontent.com/481778/178929490-2cc22962-ec68-4850-b743-8b973f8e30ff.png)

The **OptionGrid** presents several options in a grid with labels for each row and column.

![gdforms_screenshot_option_grid](https://user-images.githubusercontent.com/481778/178929778-419e83fb-89a8-44f0-8ab3-ce09aa0ddc22.png)

The **TextInput** widget is simply a wrapper for the standard TextInput element. The **ValidatedInput** widget on the other hand allows you to limit the input to specific characters, and you can provide a regular expression that will be used for determining if the input text is "valid".

![gdforms_screenshot_validation](https://user-images.githubusercontent.com/481778/178930463-5aaca5c7-e4d3-4e54-8d4a-079a08bef299.png)

There are also a number of standard buttons that can be used for interacting with the form: **CancelButton**, **SubmitButton**, **NextButton**, **BackButton**, as well as a generic **FormButton**.

![gdforms_screenshot_example2](https://user-images.githubusercontent.com/481778/178930780-7e2cf9a3-b7d0-49e0-ba51-06470abd200f.png)

Longer forms can be split into several **FormPage** containers. These are Vertical Box Containers that are recognized as pages by their parent form. Simply by placing **NextButton** and **BackButton** widgets to your form, the user can navigate from one page to the next.

![gdforms_screenshot_form_structure](https://user-images.githubusercontent.com/481778/178931660-5ac6df09-a06f-498c-a5b5-bf2f1e3a12e2.png)

### A Flexible Branching System

**Branch** nodes can be added to any GDForms widget, to implement branching behaviour.

![gdforms_screenshot_branching1](https://user-images.githubusercontent.com/481778/178932244-596f01bf-11fc-4687-afd9-6e5339b494e2.png)

These **Branch** node can potentially affect three other CanvasItem nodes. The *target* node's visibility will be turned on and off depending on whether the branch's condition is met. The *alternate target* branch's visibility will be set to the opposite of the *target*, allowing you to toggle between two messages, or two buttons, for instance. Lastly, the *disabled target* will be disabled when the branch condition is met. You can use this to prevent users from editing their choices.

The **Branch** inspector will only show you the parameters relevent to its parent widget. For instance, here we see options for a **Branch** attached to an **Options** widget.

![gdforms_screenshot_branching](https://user-images.githubusercontent.com/481778/178933489-c0ead9d0-c24c-4b1e-a587-2f7ba1b657d2.png)

The *condition type* can be set to *any value*, in which case the target is made visible as soon as the user interacts with the widget. If instead, this value is set to *specific value*, then the branch will only activate if the condition is met. For **Options**, we provide an array of valid indices. We can specify whether we want the user to chose all the specified options or only some of them. **OptionGrid** branches work in the same way, but we can provide "answer keys" for each row.

Several **Branch** nodes can be added to the same widget to allow for relatively complex branching patterns.


https://user-images.githubusercontent.com/481778/178936124-83859500-cf9c-4bca-8dea-0d2ceb05965e.mp4

### A Dock Utility

When you enable the GDForms plugin, a new dock panel is added to the bottom-left of the screen. This provides a number of useful shortcuts for creating forms.

![gdforms_screenshot_dock](https://user-images.githubusercontent.com/481778/178936645-accdd8d9-a946-469a-b99a-4f4745c3fe22.png)


### Simple Integration

In GDForms, forms are simple CanvasItem nodes that can be easily integrated into any GUI. You can have more than one form displayed at the same time and each form can have several pages.

On the scripting side, all you need to do to use GDForms is to connect to the *submit* and *cancel* signals. Everything else is taken care of.

![gdforms_screenshot_signals](https://user-images.githubusercontent.com/481778/178937899-7f5088e4-2d9a-4701-8792-79d25779c8c0.png)

The *submit* signal will provide you with a form id (which you provide) and a Dictionary containing the state of all widgets. (In order for a widget to report its state to its parent form, you must provide an identifier that will be used as a key in the Dictionary.)

![gdforms_screenshot_item_id](https://user-images.githubusercontent.com/481778/178938621-6738290b-5c45-4a46-8a27-05f93f47c1c0.png)

## Dictionary Format

Here is a sample of GDForm data, formatted as JSON, with JavaScript comments, that shows the structure of the data for each widget type.

```JavaScript
{

// Checkbox: bool
    "agreement": true,
    
// Options (single selection): both the index and the label is reported.
    "colors": [
        {
            "index": 2,
            "label": "Option grids"
        }
    ],
    
// Options (multiple selections): the selected indices and the labels are reported.
    "programming languages": [
        {
            "index": 1,
            "label": "GDScript"
        },
        {
            "index": 3,
            "label": "C#"
        }
    ],
    
 // Another Option item. Note that you can specify an index offset. Here 'disagree' would have an index of -1.
    "likert": [
        {
            "index": 1,
            "label": "Agree"
        }
    ],
    
 // OptionGrid: much like Options, but every row has its own Dictionary
    "grid": [
        {
            "label": "Service",
            "selection": [
                {
                    "index": -1,
                    "label": "Poor"
                }
            ]
        },
        {
            "label": "Food",
            "selection": [
                {
                    "index": 1,
                    "label": "Good"
                }
            ]
        },
        {
            "label": "Mood",
            "selection": [
                {
                    "index": 0,
                    "label": "Average"
                }
            ]
        }
    ],
    
 // TextInput and ValidatedInput: all values are strings.
    "Free text": "Hello! How are you?",
    "user_id": "1234"
}
```
