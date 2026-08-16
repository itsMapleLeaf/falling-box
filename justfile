play:
    godot

debug:
    godot_console --debug

test:
    godot_console --headless --path . --script addons/gut/gut_cmdln.gd

clean:
    rm -rf .export
    # mkdir .export

export-windows: clean
    godot_console --headless --path . --export-release "Windows"

export-linux: clean
    godot_console --headless --path . --export-release "Linux"

export-web: clean
    mkdir -p .export/falling-box-web
    godot_console --headless --path . --export-release "Web"
    cd .export/falling-box-web; zip -r ../falling-box-web.zip .

export-all: export-windows export-linux export-web
