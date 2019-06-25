"""Aliases and completions for Kitty"""
import os

from xonsh.platform import ON_LINUX, ON_BSD


XONSH_KITTY_DATA_HOME = os.path.join($XDG_DATA_HOME, 'xonsh-kitty')
XONSH_KITTY_BASH_COMP = os.path.join(XONSH_KITTY_DATA_HOME, 'bash-completions.sh')

# add bash completers, because it is easier than writing our own
# this should probably use the kitty Python API
if not os.path.isfile(XONSH_KITTY_BASH_COMP):
    os.makedirs(XONSH_KITTY_DATA_HOME, exist_ok=True)
    ![kitty + complete setup bash > @(XONSH_KITTY_BASH_COMP)]
$BASH_COMPLETIONS.insert(0, XONSH_KITTY_BASH_COMP)

aliases["icat"] = ("kitty", "+kitten", "icat")
aliases["d"] = ("kitty", "+kitten", "diff",
    "--override", "pygments_style=$XONSH_COLOR_STYLE")
aliases["hints"] = ("kitty", "+kitten", "hints")
aliases["clipboard"] = ("kitty", "+kitten", "clipboard")
if ON_LINUX or ON_BSD:
    aliases["panel"] = ("kitty", "+kitten", "panel")
