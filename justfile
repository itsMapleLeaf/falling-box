ITCH_USERNAME := "itsmapleleaf"

play:
    godot

debug:
    godot_console --debug

test:
    godot_console --headless --path . --script addons/gut/gut_cmdln.gd

build: build-windows build-linux build-web

build-windows:
    rm -rf .export/falling-box-win.zip
    godot_console --headless --path . --export-release "Windows"

build-linux:
    rm -rf .export/falling-box-linux.zip
    godot_console --headless --path . --export-release "Linux"

build-web:
    rm -rf .export/falling-box-web.zip
    mkdir -p .export/falling-box-web
    godot_console --headless --path . --export-release "Web"
    cd .export/falling-box-web; zip -r ../falling-box-web.zip .

publish: build publish-only

publish-only:
    butler push --if-changed .export/falling-box-win.zip {{ ITCH_USERNAME }}/falling-box:windows
    butler push --if-changed .export/falling-box-linux.zip {{ ITCH_USERNAME }}/falling-box:linux
    butler push --if-changed .export/falling-box-web {{ ITCH_USERNAME }}/falling-box:html5
