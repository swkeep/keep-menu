![menu](https://raw.githubusercontent.com/swkeep/keep-menu/master/.github/images/menu.jpg)

This is a modified version of **[NH Context](https://github.com/nerohiro/nh-context)** by **[NeroHiro](https://github.com/nerohiro) [LICENSE](https://github.com/nerohiro/nh-context/blob/main/LICENSE)**

# Usage

- Here is a base menu to show how it works.

```
    {
        header = "The Header, whatever you want to put", -- Required
        subheader = "The base of the text in the button",
        footer = "The bottom text on the button",
        disabled = "pass "true" if you want to disable this button from being pressed, and will change to a disabled color",
        submenu = "pass "true" if you want to have a arrow showing that this button will access another menu",
        server = "pass "true" if you want the button to trigger a server event",
        command = "ExecuteCommand @swkeep",
        QBCommand = "QBCore:CallCommand @swkeep",
        action = "trigger a function @swkeep",
        image = "add an image url here and itll show off to the left side when you hover over this button, example below",
        event = "the event you actually want to trigger, remember if you set it server = true this will pass to the server side",
        icon = "show a fontawesome icon @swkeep",
        back = "add back icon to btn @swkeep",
        leave = "add leave icon to btn @swkeep",
        args = { -- These are the arguments you send with the event
            table,
            integer,
            boolean -- the order you put these in will be the order they kick out thru the receiving event function(table, integer, boolean)
        }
    }
```

- Exmaple of using the Function to build a menu

```lua
     local Menu = {
          {
               header = "Go Back",
               back = true,
          },
          {
               header = "Main Title",
          },
          {
               header = "Sub Menu Button",
               subheader = "This goes to a sub menu",
               -- event = "keep-crafting:client:test",
               image = "weapon_assaultrifle",
               icon = 'fa-solid fa-diagram-successor',
               args = { 1, 2 },
               action = function(args)
                    print('boom', args)
               end,
               submenu = true,
          },
          {
               header = "Sub Menu Button",
               subheader = "This goes to a sub menu",
               event = "keep-crafting:client:test",
               image = "weapon_assaultrifle",
               icon = 'fa-solid fa-diagram-successor',
               submenu = true,
               disabled = true,
               args = { 1, 2 }
          },
          {
               header = "Leave",
               event = "keep-menu:closeMenu",
               leave = true
          }
     }

     exports['keep-menu']:createMenu(Menu)
```
