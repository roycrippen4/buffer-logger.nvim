# buffer-logger.nvim

**buffer-logger.nvim** is a simple lua logger for Neovim.

![image](./assets/logger-example.png)

## Feature

This plugin aims to do one thing and one thing only, make logging in lua easy.

buffer-logger.nvim simply opens a new vertical split and any log statements made using it will appear in the buffer. That's it.

## Installation

```lua
-- lazy.nvim
return {
  'roycrippen4/buffer-logger.nvim',
  config = function()
    -- plugin only has one configuration item at the moment
    require('logger'):setup({ show_on_start = false })

    -- Set up a keymap to toggle the split. Toggling does not clear the logger content
    vim.keymap.set('n', '<leader>L', function()
      require('logger'):toggle()
    end)

    -- This is nice. You can do something like `:lua log('my log statement')`
    function _G.log(...)
      require('logger'):log(...)
    end
  end,
}
```

**Note**: Don't use `opts = {}` in your lazy setup. The plugin won't load correctly. And I'm not fixing it.

## Logger functions

`logger:log()`

```lua
-- Adds an entry to the log
require('logger'):log('my log message')

local a = 'my variable'
local b = 2
local c = false
local d = { key: 'value' }
local e

-- Can log multiple items of any type
require('logger'):log('a:', a, 'b:', b, 'c:', c, 'd:', d, 'e:', e )
```

`logger:toggle()`

```lua
-- Toggles the logger buffer
require('logger'):toggle()
```
