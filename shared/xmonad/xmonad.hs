-- xmonad config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config

import System.IO
import System.Exit
import XMonad
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.Decoration
import XMonad.Layout.WindowArranger
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Reflect
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances(StdTransformers(MIRROR))
import XMonad.Layout.MultiToggle.Instances(StdTransformers(FULL))
import XMonad.Layout.MultiToggle.Instances(StdTransformers(NOBORDERS))
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "alacritty"

myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
myNumlockMask   = mod2Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
--myWorkspaces    = ["1:code","2:web","3:msg","4:vm","5:media","6","7","8","9"]
myWorkspaces = map show [1..9]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#7c7c7c"
myFocusedBorderColor = "#ffb6b0"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- launch a terminal
    [ ((modMask, xK_Return), spawn $ XMonad.terminal conf)

    -- lock screen
    , ((modMask .|. controlMask, xK_l     ), spawn "loginctl lock-session")

    -- suspend computer
    , ((modMask .|. controlMask, xK_s     ), spawn "systemctl suspend")

    -- launch dmenu
    , ((modMask,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")

    -- launch gmrun
    , ((modMask .|. shiftMask, xK_p     ), spawn "gmrun")


    -- close focused window
    , ((modMask .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modMask,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modMask,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modMask,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modMask,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modMask,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modMask,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modMask .|. shiftMask, xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modMask,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modMask,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))

    -- Mirror, reflect around x or y axis
    , ((modMask               , xK_m), sendMessage $ Toggle MIRROR)
    , ((modMask               , xK_x), sendMessage $ Toggle REFLECTX)
    , ((modMask               , xK_y), sendMessage $ Toggle REFLECTY)
    , ((modMask               , xK_f), sendMessage $ Toggle FULL)

    -- toggle the status bar gap
    -- TODO, update this binding with avoidStruts , ((modMask              , xK_b     ),

    -- Quit xmonad
    , ((modMask .|. shiftMask .|. controlMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modMask .|. shiftMask .|.controlMask, xK_r     ), restart "xmonad" True)

    -- windowArranger keybindings
    , ((modMask .|. controlMask              , xK_s    ), sendMessage  Arrange         )
    , ((modMask .|. controlMask .|. shiftMask, xK_s    ), sendMessage  DeArrange       )
    , ((modMask .|. controlMask              , xK_Left ), sendMessage (MoveLeft      10))
    , ((modMask .|. controlMask              , xK_Right), sendMessage (MoveRight     10))
    , ((modMask .|. controlMask              , xK_Down ), sendMessage (MoveDown      10))
    , ((modMask .|. controlMask              , xK_Up   ), sendMessage (MoveUp        10))
    , ((modMask                 .|. shiftMask, xK_Left ), sendMessage (IncreaseLeft  10))
    , ((modMask                 .|. shiftMask, xK_Right), sendMessage (IncreaseRight 10))
    , ((modMask                 .|. shiftMask, xK_Down ), sendMessage (IncreaseDown  10))
    , ((modMask                 .|. shiftMask, xK_Up   ), sendMessage (IncreaseUp    10))
    , ((modMask .|. controlMask .|. shiftMask, xK_Left ), sendMessage (DecreaseLeft  10))
    , ((modMask .|. controlMask .|. shiftMask, xK_Right), sendMessage (DecreaseRight 10))
    , ((modMask .|. controlMask .|. shiftMask, xK_Down ), sendMessage (DecreaseDown  10))
    , ((modMask .|. controlMask .|. shiftMask, xK_Up   ), sendMessage (DecreaseUp    10))

    -- Volume keys
    , ((0,               xF86XK_AudioMute), spawn "amixer sset Master toggle &")
    , ((0,               xF86XK_AudioLowerVolume), spawn "amixer set Master 2dB- unmute &")
    , ((0,               xF86XK_AudioRaiseVolume), spawn "amixer set Master 2dB+ unmute &")
    -- Brightness
    , ((0,               xF86XK_MonBrightnessUp), spawn "xbacklight -inc 5 &")
    , ((0,               xF86XK_MonBrightnessDown), spawn "xbacklight -dec 5 &")
    , ((0,               xK_Print), spawn "escrotum -s -C &")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myTabConfig = def {   activeBorderColor = "#cd8b00"
                             , activeTextColor = "#CEFFAC"
                             , activeColor = "#000000"
                             , inactiveBorderColor = "#7C7C7C"
                             , inactiveTextColor = "#EEEEEE"
                             , inactiveColor = "#000000"
                             , fontName = "xft:DejaVu Sans,Migu 1M" }
myLayout = mkToggle(single MIRROR) $
           mkToggle(single REFLECTX) $
           mkToggle(single REFLECTY) $
           mkToggle(NOBORDERS ?? FULL ?? EOT) $
           windowArrange (tiled ||| ThreeCol 1 (3/100) (1/3) ||| tabbed shrinkText myTabConfig ||| Full ||| spiral (6/7))
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = ewmh $ docks $ def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
--        numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = avoidStruts $ smartBorders $ myLayout,
        manageHook         = myManageHook <+> manageDocks,
        startupHook        = myStartupHook,
        handleEventHook    = def <+> fullscreenEventHook <+> docksEventHook
    }

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  -- xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobar"
  -- xmproc <- spawnPipe "nitrogen --restore"
  -- xmproc <- spawnPipe "nm-applet"
  xmonad defaults
    { startupHook = setWMName "LG3D" }
