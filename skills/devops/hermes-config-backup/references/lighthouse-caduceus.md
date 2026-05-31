# Lighthouse Group ASCII Art Assets

## ULAK Logo (cli.py HERMES_AGENT_LOGO replacement)

```
[bold #FFD700]██╗   ██╗██╗      █████╗ ██╗  ██╗[/]
[bold #FFD700]██║   ██║██║     ██╔══██╗██║ ██╔╝[/]
[#FFBF00]██║   ██║██║     ███████║█████╔╝ [/]
[#FFBF00]██║   ██║██║     ██╔══██║██╔═██╗ [/]
[#CD7F32]╚██████╔╝███████╗██║  ██║██║  ██╗[/]
[#CD7F32] ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝[/]
```

## Lighthouse Caduceus (cli.py HERMES_CADUCEUS replacement)

Generate fromfavicon: `https://lighthousegroup.com.tr/wp-content/uploads/2024/02/im-o-150x150.png`

```python
from PIL import Image
img = Image.open("/tmp/lighthouse_logo.png").convert("RGBA")
img = img.resize((30, 15), Image.LANCZOS)
# brightness → ░▒▓█, color → #FFD700/#FFBF00/#CD7F32/#B8860B
# a < 30 → ⠀ (empty braille)
```
