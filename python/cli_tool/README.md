# {{project_name}}

{{project_name}} does {{project_name}} stuff

## Installation

Run the following in the source directory to install a linked source repo:
	
	$make install_source

If you want to build and install a wheel, run:

	$make install_wheel

or if you already have a wheel file, just run:

	$python3 -m wheel install {{project_name}}-0.1-py3-none-any.whl
	
## Distribution

To generate the wheel file, run:

	$make build_wheel
	
Or manually:

	$python3 setup.py bdist_wheel
	
This will create the wheel file in  ```{{project_name}}/dist```
