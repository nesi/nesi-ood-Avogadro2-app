

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

avogadro2 --platform vnc