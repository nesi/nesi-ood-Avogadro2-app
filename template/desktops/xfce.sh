# adapted from: https://github.com/OSC/ondemand/blob/master/apps/bc_desktop/template/desktops/xfce.sh

# Remove any preconfigured monitors
if [[ -f "${HOME}/.config/monitors.xml" ]]; then
  mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
fi

# Copy over default panel if doesn't exist, otherwise it will prompt the user
PANEL_CONFIG="${HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
if [[ ! -e "${PANEL_CONFIG}" ]]; then
  mkdir -p "$(dirname "${PANEL_CONFIG}")"
  cp "/etc/xdg/xfce4/panel/default.xml" "${PANEL_CONFIG}"
fi

# Disable startup services
xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
xfconf-query -c xfce4-session -p /startup/gpg-agent/enabled -n -t bool -s false

# No screensaver or power mgmt
xfconf-query -c xfce4-screensaver -p /saver/enabled -n -t bool -s false
xfconf-query -c xfce4-screensaver -p /lock/enabled -n -t bool -s false

# Disable useless services on autostart
AUTOSTART="${HOME}/.config/autostart"
rm -fr "${AUTOSTART}"    # clean up previous autostarts
mkdir -p "${AUTOSTART}"
for service in "pulseaudio" "rhsm-icon" "spice-vdagent" "tracker-extract" "tracker-miner-apps" "tracker-miner-user-guides" "xfce4-power-manager" "xfce-polkit"; do
  echo -e "[Desktop Entry]\nHidden=true" > "${AUTOSTART}/${service}.desktop"
done

# Run Xfce4 Terminal as login shell (sets proper TERM)
TERM_CONFIG="${HOME}/.config/xfce4/terminal/terminalrc"
if [[ ! -e "${TERM_CONFIG}" ]]; then
  mkdir -p "$(dirname "${TERM_CONFIG}")"
  sed 's/^ \{4\}//' > "${TERM_CONFIG}" << EOL
    [Configuration]
    CommandLoginShell=TRUE
EOL
else
  sed -i \
    '/^CommandLoginShell=/{h;s/=.*/=TRUE/};${x;/^$/{s//CommandLoginShell=TRUE/;H};x}' \
    "${TERM_CONFIG}"
fi

# launch dbus first through eval becuase it can conflict with a conda environment
# see https://github.com/OSC/ondemand/issues/700
eval $(dbus-launch --sh-syntax)

# Force kill any existing compositors that might be running
killall compton picom xcompmgr compiz 2>/dev/null || true

# Ensure xfwm4 will manage compositing by setting the property explicitly
xfconf-query -c xfwm4 -p /general/use_compositing -t bool -s true

# Remove the Minimize (Hide) and Maximize buttons from the window title bar
# 'O' = Options menu, '|' = Title text, 'C' = Close button
xfconf-query -c xfwm4 -p /general/button_layout -s "|" 2>/dev/null

# START THE WINDOW MANAGER COMPONENTS IN THE BACKGROUND
xfwm4 --compositor=off --sm-client-disable &
xsetroot -solid "#D3D3D3" &
xfsettingsd --sm-client-disable &
#xfce4-panel --sm-client-disable &

# Start up xfce desktop (block until user logs out of desktop)
#xfce4-session

unset LIBGL_ALWAYS_INDIRECT
export LIBGL_ALWAYS_SOFTWARE=1

module load ${xtb_module}
module load ${amber_module}
#module load ${avogadro2_module}

module use /nesi/nobackup/nesi99999/geoffreyweal/Installations/Avogradro2/modules/all
#module load glibc/2.35-GCCcore-11.3.0
#module load Avogadro2/1.103.0-linux-x86_64
module load Avogadro2/1.103.0-foss-2022a

# Launch Avogadro2
#avogadro2.app

# -----------------------------------------------------------------------------
# 4. FIX 3D RENDERING (Force CPU-based OpenGL software rendering)
# -----------------------------------------------------------------------------
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
export QT_OPENGL=software
export QT_XCB_FORCE_SOFTWARE_OPENGL=1

vglrun avogadro2
